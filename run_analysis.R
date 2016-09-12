library(reshape2)

projectfile <- "projectfile.zip"

#Download file and unzip its contents
if (!file.exists(projectfile)){
  url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(url=url, destfile = "projectfile.zip", method = "curl")
}

if (!file.exists("UCI HAR Dataset")) { 
  unzip(projectfile)
}

# Load activity features and label them
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Pull Mean and Stdev
Measures <- grep(".*mean.*|.*std.*", features[,2])
Measures.names <- features[Measures,2]
Measures.names = gsub('-mean', 'Mean', Measures.names)
Measures.names = gsub('-std', 'Std', Measures.names)
Measures.names <- gsub('[-()]', '', Measures.names)

# Load datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[Measures]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[Measures]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# Merge and Label
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", Measures.names)

# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)