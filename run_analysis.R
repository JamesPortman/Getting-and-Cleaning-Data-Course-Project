##
## Student: James Portman
## Email: james@portman.ca
## Course Project Assignment: Getting and Cleaning Data 
## Description: 
## The purpose of this project is to demonstrate your ability to collect, work
## with, and clean a data set. The goal is to prepare tidy data that can be used
## for later analysis. You will be graded by your peers on a series of yes/no
## questions related to the project. You will be required to submit: 
## 1) a tidy data set as described below.
## 2) a link to a Github repository with your script for performing the analysis.
## 3) a code book that describes the variables, the data, and any transformations or work that you performed to
## clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. 
## This repo explains how all of the scripts work and how they are connected.
## 
## One of the most exciting areas in all of data science right now is wearable
## computing - see for example this article . Companies like Fitbit, Nike, and
## Jawbone Up are racing to develop the most advanced algorithms to attract new
## users. The data linked to from the course website represent data collected
## from the accelerometers from the Samsung Galaxy S smartphone. A full
## description is available at the site where the data was obtained:
##   
##   http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
## 
## Here are the data for the project: 
##   
##   https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
##
## Steps in creating a tidy data set.
## Step 1: Load activity labels.
## Step 2: Load column names and extract features.
## Step 3: Load and process TEST data.
## Step 4: Load and process TRAIN data.
## Step 5: Extract mean and standard deviation for each measurement.
## Step 6: Load TEST activity labels.
## Step 7: Load TRAIN activity labels.
## Step 8: Combine the data.
## Step 9: Merge TEST and TRAIN data.
## Step 10: Melt the data.
## Step 11: Apply mean function to dataset using dcast function.
## Step 12: Write out the new tidy data

# Install and load the required packages.
install.packages("data.table")
install.packages("reshape2")
library("data.table")
library("reshape2")

# set the download, URL, and unzip file name
downloadFile <- "data/getdata_dataset.zip"

# download and unzip the filename
downloadURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

# test for data foloder and zip file, if NOT found create
if (!file.exists("./data")) {
  dir.create("./data")
}
if (!file.exists(downloadFile)) {
  download.file(downloadURL, downloadFile, method = "curl");
  unzip(downloadFile, overwrite = T, exdir = ".")
}


#________________________________________________________________________________________________
# Step 1: Load activity labels.
activity_labels <- read.table("./data/activity_labels.txt")[,2]

# Step 2: Load column names and extract features.
features <- read.table("./data/features.txt")[,2]
extract_features <- grepl("mean|std", features)

# Step 3: Load and process TEST data.
X_test <- read.table("./data//test/X_test.txt")
y_test <- read.table("./data/test/y_test.txt")
subject_test <- read.table("./data/test/subject_test.txt")
names(X_test) = features

# Step 4: Load and process TRAIN data.
X_train <- read.table("./data/train/X_train.txt")
y_train <- read.table("./data/train/y_train.txt")
subject_train <- read.table("./data/train/subject_train.txt")
names(X_train) = features

# Step 5: Extract mean and standard deviation for each measurement.
X_test = X_test[,extract_features]
X_train = X_train[,extract_features]

# Step 6: Load TEST activity labels
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

# Step 7: Load TRAIN activity labels.
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

# Step 8: Combine the data.
test_data <- cbind(as.data.table(subject_test), y_test, X_test)
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

# Step 9: Merge TEST and TRAIN data.
combined_data = rbind(test_data, train_data)

# Step 10: Melt the data.
id_labels = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(combined_data), id_labels)
melt_data = melt(combined_data, id = id_labels, measure.vars = data_labels)

# Step 11: Apply mean function to dataset using dcast function.
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

# Step 12: Write out the new tidy data.
write.table(tidy_data, file = "./tidy_data.txt", row.names=F, col.names=F, quote=2)

# End of run_analysis.R
