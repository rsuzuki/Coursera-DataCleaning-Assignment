## -------------------------------------------------------------------------------------------------
## The purpose of this project is to demonstrate your ability to collect, work with, and clean a 
## data set.
##
## Review criterialess 
## 1. The submitted data set is tidy.
## 2. The Github repo contains the required scripts.
## 3. GitHub contains a code book that modifies and updates the available codebooks with the data
##    to indicate all the variables and summaries calculated, along with units, and any other 
##    relevant information.
## 4. The README that explains the analysis files is clear and understandable.
## 5. The work submitted for this project is the work of the student who submitted it.
##
## Getting and Cleaning Data Course Projectless 
#3
## The purpose of this project is to demonstrate your ability to collect, work with, and clean a 
## data set. The goal is to prepare tidy data that can be used for later analysis. You will be 
## graded by your peers on a series of yes/no questions related to the project. You will be 
## required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with
## your script for performing the analysis, and 3) a code book that describes the variables, the 
## data, and any transformations or work that you performed to clean up the data called 
## CodeBook.md. You should also include a README.md in the repo with your scripts. This repo 
## explains how all of the scripts work and how they are connected.
## 
## One of the most exciting areas in all of data science right now is wearable computing - see for 
## example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the 
## most advanced algorithms to attract new users. The data linked to from the course website 
## represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full 
## description is available at the site where the data was obtained:
##
## http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
##
## Here are the data for the project:
##
## https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
##
## You should create one R script called run_analysis.R that does the following.
##
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names.
## 5. From the data set in step 4, creates a second, independent tidy data set with the average of
##    each variable for each activity and each subject.
##
## Good luck!
## -------------------------------------------------------------------------------------------------

## Checklist of libraries needed to run this script
## -------------------------------------------------------------------------------------------------
writeLines("Checking required libraries...")
required_packages <- c("data.table", "reshape2")
missing_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if (length(missing_packages) > 0) {
    writeLines(paste("This script requires the following packages: ", toString(required_packages), sep = ""))
    return()
}


## Read the list of features, filter and rename them into more readable names
## -------------------------------------------------------------------------------------------------
writeLines("Reading the feature list...")
feature_table <- read.table("UCI HAR Dataset/features.txt", 
                            header = FALSE, 
                            sep = " ", 
                            col.names = c("RowIndex", "Feature"), 
                            colClasses = c("numeric", "character"))
feature_list <- feature_table$Feature

## Let's find out which ones have measurements of the mean and standard deviation of something
## and that starts with a "t" (Time Domain) or "f" (Frequency Domain)
## TODO Should we accept the "angle(something)" features? For now, don't.
select_features <- function(x) {
    grepl("^(t|f)(.*)(mean|std)\\(\\)", x)
}
feature_indices <- sapply(feature_list, select_features, simplify = "array", USE.NAMES = F)

## Removing characters such as '-', '(' and ')' from the names
rename_features <- function(x) {
    x <- gsub("\\(", "", x)
    x <- gsub("\\)", "", x)
    x <- gsub("\\_", ".", x)
    x
}
feature_list <- sapply(feature_list, rename_features, simplify = "array", USE.NAMES = F)

## Read the training and test sets
## -------------------------------------------------------------------------------------------------
writeLines("Loading data.table library...")
library(data.table)

writeLines("Preparing to read each data set. This may take a while...")
read_x <- function(filename, colnames) {
    writeLines(paste("Reading '", filename, "'...", sep = ""))
    read.table(filename, header = F, as.is = T, col.names = colnames)
}

read_y <- function(filename, colnames) {
    writeLines(paste("Reading '", filename, "'...", sep = ""))
    read.table(filename, header = F, as.is = T, col.names = colnames, colClasses = c("integer"))
}

read_subject <- function(filename, colnames) {
    writeLines(paste("Reading '", filename, "'...", sep = ""))
    read.table(filename, header = F, as.is = T, col.names = colnames, colClasses = c("integer"))
}

## X
train_x <- read_x("UCI HAR Dataset/train/X_train.txt", feature_list)
test_x  <- read_x("UCI HAR Dataset/test/X_test.txt", feature_list)
## Y
train_y <- read_y("UCI HAR Dataset/train/Y_train.txt", c("Activity"))
test_y  <- read_y("UCI HAR Dataset/test/Y_test.txt", c("Activity"))
## Subjects
train_s <- read_subject("UCI HAR Dataset/train/subject_train.txt", c("Subject"))
test_s  <- read_subject("UCI HAR Dataset/test/subject_test.txt", c("Subject"))

## Appending...
writeLines("Merging...")
merged_x <- rbind(train_x, test_x)
merged_y <- rbind(train_y, test_y)
merged_s <- rbind(train_s, test_s)


## Cleaning the new sets
## -------------------------------------------------------------------------------------------------
writeLines("Data cleaning...")
## Remove the columns we don't want.
merged_x <- merged_x[, feature_indices]

## Read the name of the labels and change the characters' cases, making them more readable.
## Also, remove the "_" being used as whitespace.
labels <- read.table("UCI HAR Dataset/activity_labels.txt", 
                     col.names = c("Label", "Name"), 
                     colClasses = c("integer", "character"))

rename_label <- function(x) {
    s <- strsplit(x, "_")[[1]]
    paste(toupper(substring(s, 1,1)), tolower(substring(s, 2)), sep="", collapse=" ")
}
labels$Name <- sapply(labels$Name, rename_label, simplify = "array", USE.NAMES = F)

## And now, rename the labels given on the test/training sets.
rename_y <- function(x) {
    labels$Name[x]
}
merged_y$Activity <- sapply(merged_y$Activity, rename_y, simplify = "array", USE.NAMES = F)

## And now, append the features, activies and subjects into one table.
merged_x$Activity <- merged_y$Activity
merged_x$Subject  <- merged_s$Subject


## And now, create a tidy data set with the average of each variable for each activity and each 
## subject
## -------------------------------------------------------------------------------------------------
writeLines("Loading reshape2 library...")
library(reshape2)

## Melt.
writeLines("Melting and casting...")
long_data        <- melt(merged_x, id.vars = c("Subject", "Activity"))
average_features <- dcast(long_data, Subject + Activity ~ variable, mean)

## Save output.
writeLines("Saving file to output.csv")
write.table(average_features, "output.txt", row.names = F)
writeLines("Done!")
