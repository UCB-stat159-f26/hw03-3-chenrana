# Functions to get and clean the career data of a tennis player

#' Get the career matches of a tennis player
#'
#' Downloads the career matches of a player from tennisabstract.com and
#' computes the player's age, the opponent's age and the age difference.
#'
#' @param player Name of the player, e.g. "serena williams",
#'   "Serena Williams" or "SerenaWilliams".
#' @return A data frame with one row per match.
#' @export
#' @examples
#' \dontrun{
#' serena <- get_career_data("serena williams")
#' }
get_career_data <- function(player) {
  name <- clean_name(player)
  career <- read_web_file(paste0(name, "Career.js"))
  info <- read_web_file(paste0(name, ".js"))
  if (is.null(career) || is.null(info) || !any(grepl("morematchmx", career))) {
    stop("Could not find the player '", player, "' on tennisabstract.com. ",
         "Check the spelling, e.g. 'Serena Williams'.", call. = FALSE)
  }
  matches <- js_to_table(career)
  dob <- get_birth_date(info)
  add_ages(matches, dob, player = gsub("([a-z])([A-Z])", "\\1 \\2", name))
}

# "serena williams" -> "SerenaWilliams"
clean_name <- function(player) {
  words <- strsplit(trimws(player), " +")[[1]]
  paste0(toupper(substr(words, 1, 1)), substring(words, 2), collapse = "")
}

# Read a file from tennisabstract.com/jsmatches/ (NULL if it does not exist)
read_web_file <- function(file) {
  url <- paste0("https://www.tennisabstract.com/jsmatches/", file)
  tryCatch(suppressWarnings(readLines(url, warn = FALSE)),
           error = function(e) NULL)
}

# Convert the career match array into a data frame
js_to_table <- function(js) {
  text <- paste(js, collapse = "\n")
  text <- sub(".*?var morematchmx\\s*=\\s*", "", text, perl = TRUE)
  text <- sub("\\]\\s*\\].*", "]]", text)
  matches <- jsonlite::fromJSON(text, simplifyMatrix = FALSE)
  get <- function(i) sapply(matches, "[", i)
  data.frame(
    date = as.Date(get(1), "%Y%m%d"),
    tournament = get(2),
    result = get(5),
    opponent = get(12),
    opp_info = get(17)
  )
}

# Find "dob=19810926" in a player's info file and return it as a Date
get_birth_date <- function(info) {
  info <- paste(info, collapse = " ")
  dob <- regmatches(info, regexpr("dob=[0-9]{8}", info))
  if (length(dob) == 0) stop("Could not find the player's birth date.", call. = FALSE)
  as.Date(sub("dob=", "", dob), "%Y%m%d")
}

# Age in years between a birth date and a match date
age_at <- function(birth, date) {
  as.numeric(date - birth) / 365.25
}

# Female files have the opponent's birth date (8 digits); male files their age
is_female <- function(opp_info) {
  values <- opp_info[!is.na(opp_info) & opp_info != ""]
  length(values) > 0 && mean(grepl("^[0-9]{8}$", values)) > 0.5
}

# Add player age, opponent age, age difference and result
add_ages <- function(matches, dob, player) {
  if (is_female(matches$opp_info)) {
    opp_age <- age_at(as.Date(matches$opp_info, "%Y%m%d"), matches$date)
  } else {
    opp_age <- suppressWarnings(as.numeric(matches$opp_info))
  }
  data <- data.frame(player = player, date = matches$date, tournament = matches$tournament,
                     opponent = matches$opponent, player_age = age_at(dob, matches$date),
                     opponent_age = opp_age, result = ifelse(matches$result == "W", "Win", "Loss"))
  data$age_diff <- data$player_age - data$opponent_age
  data[!is.na(data$age_diff) & matches$result %in% c("W", "L"), ]
}