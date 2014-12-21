function [ ubmModel ] = generateUBM(dataDIR)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    load('settings.mat');
    disp(strcat('Generating the UBM using files in ------',dataDIR,'------'));
    for inst = 1:size(instruments,1)
        DIR = strcat(dataDIR,'trainGMM\',instruments{inst},'\');
        for i = 1:nFilesGMM
            filename = strcat(DIR,int2str(i),'.wav');
            %disp(filename);
            [y,fs] = wavread(filename);
            if i == 1
                featureVector = getFeatures2(y,fs,features);
            else
                featureVector = getFeatures2(y,fs,features,featureVector);
            end
            if asfPresent > 0
                featureVector{asfPresent} = [featureVector{asfPresent};asf{inst,i}];
            end
        end
        DIR = strcat(dataDIR,'trainCodebook\',instruments{inst},'\');
        for i = 1:nFilesGMM
            filename = strcat(DIR,int2str(i),'.wav');
            %disp(filename);
            [y,fs] = wavread(filename);
            featureVector = getFeatures2(y,fs,features,featureVector);
            if asfPresent > 0
                featureVector{asfPresent} = [featureVector{asfPresent};asf{inst,i+25}];
            end
        end
        DIR = strcat(dataDIR,'test\',instruments{inst},'\');
        for i = 1:nFilesGMM
            filename = strcat(DIR,int2str(i),'.wav');
            %disp(filename);
            [y,fs] = wavread(filename);
            featureVector = getFeatures2(y,fs,features,featureVector);
            if asfPresent > 0
                featureVector{asfPresent} = [featureVector{asfPresent};asf{inst,i+50}];
            end
        end
    end
    m = getGMM(featureVector);
    ubmModel = cell(size(m));
    for i = 1:size(features,1)
        ubmModel{i}.mu = m{i}{1};
        ubmModel{i}.sigma = m{i}{2};
        ubmModel{i}.w = m{i}{3};
    end
end

