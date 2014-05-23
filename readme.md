# Readme

## Coursera Getting and Cleaning Data Project
The purpose of this project is to demonstrate the ability to collect, work with, 
and clean a data set.  The goal is to prepare tidy data that can be used for after
analysis.  The data used in the exercise were collected from the accelerometers
from the Samsung Galaxy S smartphone while subjects performed a variety of activities.

### Project script description

The script requires the plyr and reshape2 packages to be installed and loaded.
----------------------------------------
	## load required packages
	install.packages("plyr")
	library(plyr)
	install.packages("reshape2")
	library(reshape2)
----------------------------------------
A directory is created, and a zip file containing all pertinent files for the project is downloaded.
--------------------------------------------------------------------------------------------------------	
	## get data
	dir.create("./HAR")
	fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
	download.file(fileUrl, destfile = "./HAR/activity.zip")
---------------------------------------------------------------------------------------------------------
	
Next, the file is unzipped in the directory in which it resides.
-----------------------------------------------------------------------------------------------------------	
	## unzip data
	unzip("./HAR/activity.zip", exdir = "./HAR")
----------------------------------------------------------------------------------
	
The first data loaded pertains to both the test and training data and consists of names for activities
and names for the individual variables.
-----------------------------------------------------------------------------------
	## load universal data
	activityLabels <- read.table("./HAR/UCI HAR Dataset/activity_labels.txt")
	features <- read.table("./HAR/UCI HAR Dataset/features.txt")
--------------------------------------------------------------------------------------

This section loads the training data and links the activity labels to the activity codes.	
-----------------------------------------------------------------------------------------
	## load train data
	train <- read.table("./HAR/UCI HAR Dataset/train/X_train.txt")
	trainLabels <- read.table("./HAR/UCI HAR Dataset/train/y_train.txt")
	trainSubject <- read.table("./HAR/UCI HAR Dataset/train/subject_train.txt")
	trainLabels <- join(trainLabels, activityLabels, by = "V1")
-------------------------------------------------------------------------------------

This section loads the test data and links the activity labels to the activity codes.
-------------------------------------------------------------------------------	
	## load test data
	test <- read.table("./HAR/UCI HAR Dataset/test/X_test.txt")
	testLabels <- read.table("./HAR/UCI HAR Dataset/test/y_test.txt")
	testSubject <- read.table("./HAR/UCI HAR Dataset/test/subject_test.txt")
	testLabels <- join(testLabels, activityLabels, by = "V1")
---------------------------------------------------------------------------------

Next, cbind is used to add the subject data and activity lables to the train and test dataframes.
--------------------------------------------------------	
	## built train table
	train <- cbind(trainSubject, trainLabels, train)

	## built test table
	test <- cbind(testSubject, testLabels, test)
----------------------------------------------------------

Then, the train and test dataframes are merged with rbind to form a dataframe containing
the full Human Activity Recognition (HAR) dataset.  The columns are named with the 
included features data.	
-----------------------------------------------------------------------------------
	## merge train and test tables and apply column names
	HAR <- rbind(train, test)
	names(HAR) <- c("subject", "activityCode", "activity", as.vector(features$V2))
--------------------------------------------------------------------------------------

The HAR dataframe is subsetted to only include those features containing mean and std values.
This was accomplished with a combination of the intersect and grep functions.	
----------------------------------------------------------------------------
	## subset mean and std columns
	colSelect <- intersect(grep("mean|std|activity|subject", names(HAR)), 
	grep("Freq", names(HAR), invert = TRUE))
	HAR <- HAR[, colSelect]
-----------------------------------------------------------------------------

The column names of the newly subsetted HAR dataframe are cleaned up to make them more
readable.  This is done by stripping out symbols and re-formatting the names.	
-----------------------------------------------------------------------------
	## clean up column names
	names(HAR) <- gsub("\\()", "", names(HAR))
	names(HAR) <- gsub("-", ".", names(HAR))
------------------------------------------------------------------------------

The HAR data set is melted to long format and dcast to aggregate mean values of each variable
for each subject and activity.	
-----------------------------------------------------------------------------
	## construct tidy data set
	molten <- melt(HAR, id.vars = c(1:3))
	tidyHAR <- dcast(molten, subject + activityCode + activity ~ variable,
	fun.aggregate = mean)
------------------------------------------------------------------------------

Finally, the tidy dataset tidyHAR is exported to a tab-separated text file.	
------------------------------------------------------------------------------		
	## export tidy data set to txt file
	write.table(tidyHAR, "./HAR/tidyHAR.txt", sep="\t") 
---------------------------------------------------------------------------------



