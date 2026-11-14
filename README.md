# tennisages

`tennisages` is an R package that retrieves a tennis player's career
matches from [Tennis Abstract](https://www.tennisabstract.com) and plots
the age difference between the player and their opponents.

The plot follows the idea of the New York Times visualization of
Serena Williams's career, without annotations.

## Installation

Install the package from GitHub:

```r
# Install devtools first if needed:
# install.packages("devtools")

devtools::install_github("chenrana/HW3")
```

Alternatively:

```r
# install.packages("pak")
pak::pak("chenrana/HW3")
```

## Usage

```r
library(tennisages)

# Get Serena Williams's career matches and create a plot
serena <- get_career_data("serena williams")
head(serena)
plot_career_ages(serena)

# Get Rafael Nadal's career matches and create a plot
rafa <- get_career_data("Rafael Nadal")
plot_career_ages(rafa)
```

The data function accepts names in these formats:

```r
get_career_data("serena williams")
get_career_data("Serena Williams")
get_career_data("SerenaWilliams")
```

An unknown player produces an error asking the user to check the name:

```r
get_career_data("GastonSanchez")
```

An internet connection is required to retrieve career data.

## Main Functions

| Function | Input | Output |
|---|---|---|
| `get_career_data(player)` | A player's name | A cleaned data frame of career matches |
| `plot_career_ages(data)` | The data frame returned by `get_career_data()` | A ggplot scatter plot |

## Returned Data

The cleaned data frame contains the following columns:

| Column | Description |
|---|---|
| `player` | Player's name |
| `date` | Tournament date |
| `tournament` | Tournament name |
| `opponent` | Opponent's name |
| `player_age` | Player's approximate age at the tournament, in years |
| `opponent_age` | Opponent's approximate age at the tournament, in years |
| `result` | Match result: `"Win"` or `"Loss"` |
| `age_diff` | Player's age minus opponent's age |

A positive `age_diff` means the player was older than the opponent.
A negative value means the player was younger.

## Plot

Each point represents one match:

- The x-axis shows the player's age.
- The y-axis shows the age difference between the player and the opponent.
- Point color indicates whether the player won or lost.

## Data Processing

The package formats the player's name for Tennis Abstract's URLs,
downloads the career match data and player information, and extracts
the fields needed for plotting.

Female and male career files store opponent information differently.
Female files contain opponents' birth dates, while male files contain
opponents' ages. The package handles both formats.

Ages calculated from birth dates use the number of days between the
birth date and tournament date divided by 365.25. These ages are
approximate because tournament dates may differ from the exact dates
of individual matches.

Records with missing age differences or results other than a win or
loss are excluded from the returned data.

## Tests

Automated tests use the mock career files in
`tests/testthat/fixtures/`:

- `FemalePlayerCareer.js`
- `MalePlayerCareer.js`

The tests check data parsing and age calculations without connecting
to the live website.

Run the tests from the package's root directory:

```r
testthat::test_local()
```

## Reflections

In HW1, I planned to use rvest to extract HTML tables and organize my work into three scripts. In HW3, I switched to reading the JavaScript files and organizing the code into an R package. This helped me understand that downloading a webpage does not necessarily give me the match data displayed on it.

Finding the player's birth date was harder than I expected. The career file contained match records, but I needed another file for the player's own birth date. After checking the page and its JavaScript files, I found dob=19810926 in SerenaWilliams.js. This showed me that the information needed for one analysis can be spread across several files.

I also wanted to use jsonlite::fromJSON() because manually splitting strings felt complicated. However, the match rows had different lengths, and my first attempt produced an “incorrect number of dimensions” error. Using simplifyMatrix = FALSE kept the records as a list so I could extract the fields I needed. I learned to check the structure of an object before treating it as a table.

## Data Source

Career match data comes from
[Tennis Abstract](https://www.tennisabstract.com).
The source data remains subject to its original terms of use.

## License

The package code is available under the MIT License.