# Best Linear model calculator

## Introduction
This program is to find the best combination of features for a linear model depending on the response variables. It does this by runnning `regsubsets` and then finding the largest $R^2$ and smallest BIC and C_P, which are all common ways of estimating the test MSE differently. From there, it extracts the formula and provides it to the user. The user can change the selection method, dataset, and responce to develop an equation.

## Running online
If you wish to run it online, visit this URL:
https://rocklionmba.shinyapps.io/computational-statistcs-final-main/

## Running on R
If you want to run it on your own, please run the below code:
```r
if(!require(shiny)) install.packages("shiny")
shiny::runGitHub("Computational-statistcs-final", user="rocklionmba",ref="main")
```
## Instructions on how to run
There are three inputs you need to enter:
1. Feature selection
2. Dataset
3. Response name
### Feature Selection
In `regsubsets`, there are three different methods it can use to find the best model, those being:
* Best Fit Selection
* Forwards Selection
* Backwards Selection

Best fit will try every combination of features to find the best model, forwards selection will start with no features and continually adds more features, selecting the best one each iteration, and backwards selection will start will all features and continually remove features each iteration. 

To choose which type of feature selection you want, open the dropdown and choose which one you want to use.

### Dataset
There are currently three available datasets:
* `College`, from the `ISLR` package
* `Hitters`, from the `ISLR` package
* `Diamonds`, from the `ggplot2` package

To choose which dataset you want, open the dropdown and choose which one you want to use.

### Response name

To be able to create the feature selection, a response variable is needed to develop the rest of the model. For example, if you're trying to model the salary of a baseball player with the dataset `Hitters`, the formula would be `Salary ~ .`, where `Salary` is the response.

To enter which response variable you want to use, simply write the name of the column. If there is not a column with that name, the UI will tell you. Please make sure to capitilize exactly how it is on the dataset.

Once all three inputs are in, the program will create 3 graphs for each test MSE estimate and their respective formulas.
