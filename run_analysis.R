## load required packages
install.packages("plyr")
library(plyr)
install.packages("reshape2")
library(reshape2)

## get data
dir.create("./HAR")
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./HAR/activity.zip")

## unzip data
unzip("./HAR/activity.zip", exdir = "./HAR")

## load universal data
activityLabels <- read.table("./HAR/UCI HAR Dataset/activity_labels.txt")
features <- read.table("./HAR/UCI HAR Dataset/features.txt")

## load train data
train <- read.table("./HAR/UCI HAR Dataset/train/X_train.txt")
trainLabels <- read.table("./HAR/UCI HAR Dataset/train/y_train.txt")
trainSubject <- read.table("./HAR/UCI HAR Dataset/train/subject_train.txt")
trainLabels <- join(trainLabels, activityLabels, by = "V1")

## load test data
test <- read.table("./HAR/UCI HAR Dataset/test/X_test.txt")
testLabels <- read.table("./HAR/UCI HAR Dataset/test/y_test.txt")
testSubject <- read.table("./HAR/UCI HAR Dataset/test/subject_test.txt")
testLabels <- join(testLabels, activityLabels, by = "V1")

## built train table
train <- cbind(trainSubject, trainLabels, train)

## built test table
test <- cbind(testSubject, testLabels, test)

## merge train and test tables and apply column names
HAR <- rbind(train, test)
names(HAR) <- c("subject", "activityCode", "activity", as.vector(features$V2))

## subset mean and std columns
colSelect <- intersect(grep("mean|std|activity|subject", names(HAR)), 
        grep("Freq", names(HAR), invert = TRUE))
HAR <- HAR[, colSelect]

## clean up column names
names(HAR) <- gsub("\\()", "", names(HAR))
names(HAR) <- gsub("-", ".", names(HAR))

## construct tidy data set
molten <- melt(HAR, id.vars = c(1:3))
tidyHAR <- dcast(molten, subject + activityCode + activity ~ variable,
        fun.aggregate = mean)

## export tidy data set to txt file
write.table(tidyHAR, "./HAR/tidyHAR.txt", sep="\t") 




