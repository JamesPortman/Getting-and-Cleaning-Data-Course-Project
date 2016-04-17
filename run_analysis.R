# run_analysis.R

## This R script does the following:
## Merges the training and the test sets to create one data set.
## Extracts only the measurements on the mean and standard deviation for each measurement.
## Uses descriptive activity names to name the activities in the data set
## Appropriately labels the data set with descriptive activity names.
## Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Install and load the required packages.
install.packages("data.table")
install.packages("reshape2")
library("data.table")
library("reshape2")

# Step 1: Load activity labels.
activity_labels <- read.table("./ActivityData/activity_labels.txt")[,2]

# Step 2: Load column names and extract features.
features <- read.table("./ActivityData/features.txt")[,2]
extract_features <- grepl("mean|std", features)

# Step 3A: Load and process TEST data.
X_test <- read.table("./ActivityData/test/X_test.txt")
y_test <- read.table("./ActivityData/test/y_test.txt")
subject_test <- read.table("./ActivityData/test/subject_test.txt")
names(X_test) = features

# Step 3B: Load and process TRAIN data.
X_train <- read.table("./ActivityData/train/X_train.txt")
y_train <- read.table("./ActivityData/train/y_train.txt")
subject_train <- read.table("./ActivityData/train/subject_train.txt")
names(X_train) = features

# Step 4: Extract mean and standard deviation for each measurement.
X_test = X_test[,extract_features]
X_train = X_train[,extract_features]

# Step 5A: Load TEST activity labels
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

# Step 5B: Load TRAIN activity labels.
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

# Step 6: Combine data.
test_data <- cbind(as.data.table(subject_test), y_test, X_test)
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

# Step 7: Merge test and train data.
combined_data = rbind(test_data, train_data)

# Step 8: Melt data.
id_labels = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(combined_data), id_labels)
melt_data = melt(combined_data, id = id_labels, measure.vars = data_labels)

# Step 9: Apply mean function to dataset using dcast function.
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

# Step 10: Write out new tidy data.
write.table(tidy_data, file = "./tidy_data.txt", row.names=F, col.names=F, quote=2)

# End of run_analysis.R
