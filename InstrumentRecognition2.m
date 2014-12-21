clc;
clear;
warning off;
%%
%settings
instruments = {'piano';'violin';'trumpet';'flute';'bassoon';'oboe'};
features = {'mfcc';'temporal';'asf'};
model = cell(size(instruments,1),size(features,1));
nFilesGMM = 15;
nFilesCB = 15;
nFilesTest = 15;
fileLen = 5;
save('settings.mat');
%%
%GMM
clc;
clear;
load('settings.mat');
for inst = 1:size(instruments,1)
    DIR = strcat(pwd,'\SpeakerRecognition\dataset\',int2str(fileLen),'second\trainGMM\',instruments{inst},'\');
    mfcc=[];
    asf=[];
    for i = 1:nFilesGMM
        filename = strcat(DIR,int2str(i),'.wav');
        disp(filename);
        [y,fs] = wavread(filename);
        if i == 1
            featureVector = getFeatures(y,fs,features);
        else
            featureVector = getFeatures(y,fs,features,featureVector);
        end
    end
    model(inst,:) = getGMM(featureVector);
end
save('model.mat','model')

%%
%CodeBook
clear;
load('settings.mat');
load('model.mat')
model2 = cell(size(instruments,1),1);
featureQuality = zeros(size(model));
mdSize = numel(model);
weight = [];
BCconfusion = zeros(size(model,1),size(model,1),size(features,1));
for inst = 1:size(instruments,1)
    count = [];
    DIR = strcat(pwd,'\SpeakerRecognition\dataset\',int2str(fileLen),'second\trainCodebook\',instruments{inst},'\');
    cbVect = zeros(mdSize,nFilesCB)';
    for i = 1:nFilesCB
        filename = strcat(DIR,int2str(i),'.wav');
        disp(filename);
        [y,fs] = wavread(filename);
        featureVector = getFeatures(y,fs,features);
        probabilities = getClassification( featureVector );
        [~,I] = max(probabilities);
        count = [count;I];
        cbVect(i,:) = reshape(probabilities,1,mdSize);
        %BCconfusion(inst,I) = BCconfusion(inst,I) + 1;
        %disp(probabilities);
    end
    featureQuality(inst,:) = sum(count == inst);
    for f = 1:size(features,1)
       a = histc(count(:,f),1:size(model,1));
       BCconfusion(inst,:,f) = BCconfusion(inst,:,f) + a';
    end
    [m,v] = getGaussian(cbVect);
    v = v + .0001 * eye(size(v,1));
    model2{inst} = {m,v};
end
%disp(featureQuality);

tot = sum(featureQuality,2);
s = reshape(sum(BCconfusion),size(featureQuality)) - featureQuality;
s(s == 0) = 0.5;
s = featureQuality ./ s ;
weight = s ./ repmat(sum(s,2),1,size(features,1));
save('model.mat','model','model2','weight');

%%
%testing
%clear;
load('settings.mat');
load('model.mat')
accuracy = zeros(size(model,1),1);
confusion = zeros(size(model,1));
for inst = 1:size(instruments,1)
    count = zeros(nFilesTest,1);
    DIR = strcat(pwd,'\SpeakerRecognition\dataset\',int2str(fileLen),'second\test\',instruments{inst},'\');
    for i = 1:nFilesTest
        filename = strcat(DIR,int2str(i),'.wav');
        disp(filename);
        [y,fs] = wavread(filename);
        featureVector = getFeatures(y,fs,features);
        [~,class,cp1] = getClassification( featureVector );
%         [~,class2,cp2] = getClassification2( featureVector );
%         cp1 = cp1 / sum(cp1);
%         cp2 = cp2 / sum(cp2);
%         cp = cp1 + cp2;
%         [~,class] = max(cp);
        count(i) = class;
%       disp(probabilities);    
%       disp(instruments{class});
    end
    accuracy(inst) = sum(count == inst);
    a = histc(count(:),1:size(model,1));
    confusion(inst,:) = confusion(inst,:) + a';
end

accuracy = accuracy/(nFilesTest);
disp('ACCURACY');
disp(accuracy);
disp('confusion');
disp(confusion);

%%
% filename = 'D:\ViolinAndBGPiano.wav';
% disp(filename);
% [y,fs] = wavread(filename);
% y = mean(y,2);
% featureVector = getFeatures(y,fs,features);
% [probabilities,class] = getClassification2( featureVector );
% disp(probabilities);
% disp(instruments{class});


%%
clearvars -except accuracy featureQuality *confusion;



