clc;
clear;
warning off;

%settings
instruments = {'piano';'violin';'trumpet';'flute';'bassoon';'oboe'};
features = {'asf';'mfcc'};
asfPresent = 1;
noOfInstruments = size(instruments,1);
noOfFeatures = size(features,1);
nFilesGMM = 25;
nFilesCB = 25;
nFilesTest = 25;
fileLen = 10;
dataDIR = strcat('C:\Users\Vaibhav\Documents\MATLAB\SpeakerRecognition\dataset\',int2str(fileLen),'second\');
load(strcat('asf',int2str(fileLen),'.mat'));
save('settings.mat');
%GMM

%model = generateModel();
model = generateIRM();

save('model.mat','model')

%%
%CodeBook
[ model2 , weight ,featureQuality , fconfusion ] = trainCodebook( model );

disp('Feature Quality');
disp(featureQuality);
disp('Feature Confusion');
disp(fconfusion);

save('model.mat','model','model2','weight');

%%
%testing

[ accuracy1, confusion1 ] = testModel( 'regression' );
disp('Accuracy - Regression');
disp(accuracy1);
disp('Confusion - Regression');
disp(confusion1);

[ accuracy2, confusion2 ] = testModel( 'feature quality' );
disp('Accuracy - Feature Quality');
disp(accuracy2);
disp('Confusion - Feature Quality');
disp(confusion2);


%%
% filename = 'D:\ViolinAndBGPiano.wav';
% filename = 'C:\Users\Vaibhav\Music\Joohyun Park and Bear McCreary - Kara Remembers (Piano Duet)111.wav';
% disp(filename);
% load('settings.mat');
% load('model.mat');
% [y,fs] = wavread(filename);
% y = mean(y,2);
% featureVector = getFeatures(y,fs,features);
% [probabilities,class,cp] = getClassification( featureVector );
% disp(probabilities);
% disp(instruments{class});
% disp(cp);
% 
% 
% %%
% clearvars -except accuracy featureQuality *confusion;



