# Getting and Cleaning Data Course Project
This is the course project for the Getting and Cleaning Data, which is part of 
the Data Science specialization offfered by John Hopkins University and 
available on Coursera.

The objective of this project is to prepare a tidy data set from a large, 
not-so-readable data set. The data linked to this project is a collection of
measurements from the accelerometers and gyroscopes of a smartphone. The 
objective of collecting such data is to correlate those measurements and a 
certain activity, such as walking, setting, standing, etc.

This project contains a script that reads through the data and outputs the
average of those measurements for each activity and each subject.

# Pre-requisites
* You need to have [R installed on your computer.](https://www.r-project.org/)
* Within R, those packages should be installed before running this project:
  - data.table
  - reshape2
* Download the data required to run the analysis [here.](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)

# Project Structure

This project contains a single R script names `run_analysis.R`, which should 
be run within R. However, the data needed to run this script needs to be 
downloaded using the link above and extracted on the same directory as the 
script. 

The project's directory should look like this:

```
project/
  README.md
  run_analysis.R
  ...
  UCI HAR Dataset/
    activity_labels.txt
    features_info.txt
    features.txt
    README.txt
    test/
       ...
    train/
       ...

```

The codebook for this script's output file is available on the `codebook.pdf` 
file.


# How to Run

Once you have downloaded and extracted the data, you need to run the 
`run_analysis.R` script on the R Console:

```
source("run_analysis.R")
```

The script will load the `reshape2` and `data.table` libraries automatically.
If everything goes right, it will output a table in the `output.txt` file, 
which you can read using the following command:

```
read.table("output.txt", header = T)
```

As described previously, the table will constain the average of each 
measurement for each activity and each subject.

