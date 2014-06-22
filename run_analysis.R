## run_analysis.R

## Create one R script called run_analysis.R that does the following:
## Merges the training and the test sets to create one data set.
## Extracts only the measurements on the mean and standard deviation for each measurement.
## Uses descriptive activity names to name the activities in the data set
## Appropriately labels the data set with descriptive activity names.
## Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## The full description of the data set is available at:
## http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones


starttime <-timestamp()

# load data.table and reshape2 packages for data load

if (!require("data.table")) {
     install.packages("data.table")
}

if (!require("reshape2")) {
     install.packages("reshape2")
}

require("data.table")
require("reshape2")

# Download data from Coursera zipfile location
# original file reference 
# http://archive.ics.uci.edu/ml/machine-learning-databases/00240/UCI%20HAR%20Dataset.zip

if (!file.exists("data/UCI HAR Dataset")) {
     # download the data
     fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
     zipfile="./dataset.zip"
     message("Downloading data")
     download.file(fileURL, destfile=zipfile)
     unzip(zipfile)
}


# Load data into environment variables

     testData <- read.table("./UCI HAR Dataset/test/X_test.txt",header=FALSE)
     testData_activity <- read.table("./UCI HAR Dataset/test/y_test.txt",header=FALSE)
     testData_subject <- read.table("./UCI HAR Dataset/test/subject_test.txt",header=FALSE)
     trainData <- read.table("./UCI HAR Dataset/train/X_train.txt",header=FALSE)
     trainData_activity <- read.table("./UCI HAR Dataset/train/y_train.txt",header=FALSE)
     trainData_subject <- read.table("./UCI HAR Dataset/train/subject_train.txt",header=FALSE)

# set descriptive activity names to name the activities in the data set
     activities <- read.table("./UCI HAR Dataset/activity_labels.txt",header=FALSE,colClasses="character")
     testData_activity$V1 <- factor(testData_activity$V1,levels=activities$V1,labels=activities$V2)
     trainData_activity$V1 <- factor(trainData_activity$V1,levels=activities$V1,labels=activities$V2)

# set labels
     features <- read.table("./UCI HAR Dataset/features.txt",header=FALSE,colClasses="character")
     colnames(testData)<-features$V2
     colnames(trainData)<-features$V2
     colnames(testData_activity)<-c("Activity")
     colnames(trainData_activity)<-c("Activity")
     colnames(testData_subject)<-c("Subject")
     colnames(trainData_subject)<-c("Subject")

# merge test and training sets into one data set, including the activities
     testData<-cbind(testData,testData_activity)
     testData<-cbind(testData,testData_subject)
     trainData<-cbind(trainData,trainData_activity)
     trainData<-cbind(trainData,trainData_subject)
     mergeData<-rbind(testData,trainData)

# get mean and sd
     mergeData_mean<-suppressWarnings(sapply(mergeData,mean,na.rm=TRUE))
     mergeData_sd<-suppressWarnings(sapply(mergeData,sd,na.rm=TRUE))

# create second, tidy data set with collated averages and sd.
     DT <- data.table(mergeData)
     tidy<- DT[,lapply(.SD,mean),by="Activity,Subject"]

# write tidy output 

     if (!file.exists("data/tidy_UCIdata.csv")) {
          suppressWarnings(write.table(tidy,file="tidy_UCIdata.csv",sep=",",row.names = FALSE))
          }
endtime <-timestamp()
