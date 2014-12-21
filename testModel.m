function [ accuracy, confusion, RMSE ] = testModel( method )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    load('settings.mat');
    load('model.mat');
    accuracy = zeros(size(model,1),1);
    confusion = zeros(size(model,1));
    disp(strcat('Testing Model using --->',method));
    for inst = 1:noOfInstruments
        count = zeros(nFilesTest,1);
        DIR = strcat(dataDIR,'test\',instruments{inst},'\');
        for i = 1:nFilesTest
            filename = strcat(DIR,int2str(i),'.wav');
            %disp(filename);
            [y,fs] = wavread(filename);
            featureVector = getFeatures2(y,fs,features);
            if asfPresent > 0
                featureVector{asfPresent} = [featureVector{asfPresent};asf{inst,i+50}];
            end
            if strcmpi(method,'regression')
                [~,class,~] = getClassification2( featureVector );
            elseif strcmpi(method,'feature quality')
                [~,class,~] = getClassification( featureVector );
            else
                error('Incorrect parameter -- try either regression or weighted average');
            end
            count(i) = class;
        end 
        accuracy(inst) = sum(count == inst);
        a = histc(count(:),1:size(model,1));
        confusion(inst,:) = confusion(inst,:) + a';
    end
    accuracy = accuracy/(nFilesTest);
end

