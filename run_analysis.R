

 # Download the zip file to current wd using : https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
 # Unzip all the files. 
 # Merge test and training data. 
 # 


 # Getting current directory and setting zip folder: 
 mainDir<-getwd()
 dataFldr  <- 'UCI HAR Dataset'

 # Download the activity data in the current dir. 
 # If the data already exists ignore the download. 
 
 if (!file.exists(dataFldr)){
   dataUrl <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
   tempFile <- tempfile()
   download.file(dataUrl, destfile=tempFile, method="curl")
   unzip(tempFile) 
 }
 
 #The dataset includes the following files:
 #  'README.txt'
 #  'features_info.txt': Shows information about the variables used on the feature vector.
 #  'train/Inertial Signals/total_acc_x_train.txt': The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis. 
 #  'train/Inertial Signals/body_acc_x_train.txt': The body acceleration signal obtained by subtracting the gravity from the total acceleration. 
 #  'train/Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second. 
 
  featuresFile       <- file.path(dataFldr,'features.txt')              # : List of all features.
  activityLabelsFile <- file.path(dataFldr,'activity_labels.txt')       # : Links the class labels with their activity name.
  trainingSetFile    <- file.path(dataFldr,'train','X_train.txt')       # : Training set.
  trainingLabelFile  <- file.path(dataFldr,'train','y_train.txt')       # : Training labels.
  testSetFile        <- file.path(dataFldr,'test','X_test.txt')         # : Test set.
  testLabelFile      <- file.path(dataFldr,'test','y_test.txt')         # : Test labels.
  subjectTrainFile   <- file.path(dataFldr,'train','subject_train.txt') # : Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 
  subjectTestFile    <- file.path(dataFldr,'test','subject_test.txt')   # : Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30.  
   
  
  # Read files into R data frames ####
  activity     <- read.table(activityLabelsFile, col.names=c('ActivityId', 'Activity'))
  features     <- read.table(featuresFile, col.names=c('Number', 'Feature'))
  testSubject  <- read.table(subjectTestFile, col.names=c('Subject'))
  testLabels   <- read.table(testLabelFile, col.names=c('ActivityId'))
  testData     <- read.table(testSetFile)
  trainSubject <- read.table(subjectTrainFile, col.names=c('Subject'))
  trainLabels  <- read.table(trainingLabelFile, col.names=c('ActivityId'))
  trainData    <- read.table(trainingSetFile)
  
  
  # Fix features names to be used as column names ####
  features$Feature <- gsub('\\(|\\)', '', features$Feature)
  features$Feature <- gsub('-|,', '.', features$Feature)
  features$Feature <- gsub('BodyBody', 'Body', features$Feature)
  features$Feature <- gsub('^f', 'Frequency.', features$Feature)
  features$Feature <- gsub('^t', 'Time.', features$Feature)
  features$Feature <- gsub('^angle', 'Angle.', features$Feature)
  features$Feature <- gsub('mean', 'Mean', features$Feature)
  features$Feature <- gsub('tBody', 'TimeBody', features$Feature)
  
  #Handle Duplicate column names 
  features$Feature <- make.names(features$Feature, unique=TRUE)
  
  # Change the name of the data sets using the features data ####
  colnames(testData) <- features$Feature
  colnames(trainData) <- features$Feature
  
  # Merge labels in test and train data with actual activity
  # Merge Test and Training data. 
  allSubjects<-rbind(testSubject,trainSubject)
  allLabels<-rbind(testLabels,trainLabels)
  allData<-rbind(testData,trainData)
  allData<-cbind(allSubjects,allLabels,allData)
  
  
  # Remove unused data.tables from memory
  rm("testData","trainData","testLabels","trainLabels","allLabels","allSubjects","trainSubject","testSubject")
  

  # Uses descriptive activity names to name the activities in the data set
  allData<-left_join(allData,activity)
  
  # Extracts only the measurements on the mean and standard deviation for each measurement.
  mean_stdData<-select(allData,Subject,Activity,contains("mean"),contains("std"))
  
  # independent tidy data set with the average of each variable for each activity and each subject.
  mean_stdData<-group_by(mean_stdData,Subject,Activity)
  mean_stdData<-summarise_all(mean_stdData,mean)
   