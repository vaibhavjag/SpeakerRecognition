SpeakerRecognition
==================


Add this folder and all subdirectories to path
make this directory the current working directory
make changes to InstrumentRecognition.m (change settings) 
run InstrumentRecognition.m


settings--------------

instruments = {'piano';'violin';'trumpet';'flute';'bassoon';'oboe'}; %list of instruments to use
features = {'asf';'mfcc';'temporal'}; %list of features to use ... currently these three options available
asfPresent = 1; % uses pre calculated asf -- set to zero to compute asf while training otherwise index of asf in features array
noOfInstruments = size(instruments,1);
noOfFeatures = size(features,1);
nFilesGMM = 25;
nFilesCB = 25;
nFilesTest = 25;
fileLen = 10; %5 , 10 or 15 second file dataset
dataDIR = strcat(pwd,'\dataset\',int2str(fileLen),'second\'); % can change to absolute path
load(strcat('asf',int2str(fileLen),'.mat'));
save('settings.mat');
