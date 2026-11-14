female_js <- readLines(test_path("fixtures", "FemalePlayerCareer.js"), warn = FALSE)
male_js <- readLines(test_path("fixtures", "MalePlayerCareer.js"), warn = FALSE)

test_that("player names are written the tennisabstract way", {
  expect_equal(clean_name("serena williams"), "SerenaWilliams")
  expect_equal(clean_name("Serena Williams"), "SerenaWilliams")
  expect_equal(clean_name("SerenaWilliams"), "SerenaWilliams")
})

test_that("JS files are turned into tables", {
  female <- js_to_table(female_js)
  male <- js_to_table(male_js)
  expect_equal(nrow(female), 3)
  expect_equal(nrow(male), 3)
  expect_equal(female$opponent[1], "Anne Miller")
  expect_equal(male$opp_info[1], "22.264202601")
})

test_that("female and male files are told apart", {
  expect_true(is_female(js_to_table(female_js)$opp_info))
  expect_false(is_female(js_to_table(male_js)$opp_info))
})

test_that("female opponent ages come from birth dates", {
  serena <- add_ages(js_to_table(female_js), as.Date("1981-09-26"), "Serena Williams")
  expected <- as.numeric(as.Date("1995-10-30") - as.Date("1977-01-19")) / 365.25
  expect_equal(serena$opponent_age[1], expected)
  expect_equal(serena$result, c("Loss", "Loss", "Loss"))
})

test_that("male opponent ages are read directly", {
  rafa <- add_ages(js_to_table(male_js), as.Date("1986-06-03"), "Rafael Nadal")
  expect_equal(rafa$opponent_age, c(22.264202601, 24.2902121834, 18.7597535934))
  expect_equal(rafa$result, c("Loss", "Loss", "Win"))
  expect_equal(rafa$age_diff, rafa$player_age - rafa$opponent_age)
})

test_that("the birth date is read from the player info file", {
  expect_equal(get_birth_date("var dob=19810926;"), as.Date("1981-09-26"))
  expect_error(get_birth_date("no birth date here"), "birth date")
})

test_that("plot_career_ages returns a ggplot", {
  rafa <- add_ages(js_to_table(male_js), as.Date("1986-06-03"), "Rafael Nadal")
  expect_s3_class(plot_career_ages(rafa), "ggplot")
  expect_error(plot_career_ages(mtcars), "get_career_data")
})