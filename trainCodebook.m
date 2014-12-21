function [ model2 , weight ,featureQuality , confusion ] = trainCodebook( model )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    load('settings.mat');
    featureQuality = zeros(size(model));
    confusion = zeros(size(model,1),size(model,1),noOfFeatures);
    instrumentVectors = cell(noOfInstruments,1);
    instrumentClassification = cell(noOfInstruments,1);
    classificationOutput = [ones(25,1);zeros(125,1)];
    disp('Training CodeBook Weights');
    for inst = 1:noOfInstruments
        instrumentClassification{inst} = circshift(classificationOutput,(inst-1)*25);
        count = [];
        DIR = strcat(dataDIR,'trainCodebook\',instruments{inst},'\');
        for i = 1:nFilesCB
            filename = strcat(DIR,int2str(i),'.wav');
            %disp(filename);
            [y,fs] = wavread(filename);
            featureVector = getFeatures2(y,fs,features);
            if asfPresent > 0
                featureVector{asfPresent} = [featureVector{asfPresent};asf{inst,i+25}];
            end
            probabilities = getClassification( featureVector );
            instrumentVectors = cellfun(@(x,y) [x;y],instrumentVectors,num2cell(probabilities,2),'UniformOutput',false);
            [~,I] = max(probabilities);
            count = [count;I];
        end
        featureQuality(inst,:) = sum(count == inst);
        for f = 1:noOfFeatures
           a = histc(count(:,f),1:size(model,1));
           confusion(inst,:,f) = confusion(inst,:,f) + a';
        end    
    end
    model2.w = zeros(noOfInstruments,noOfFeatures+1);
    for inst = 1:noOfInstruments
    %    mdl = fitlm(svmData.x{inst},svmData.y{inst},'Intercept',false);
        mdl = fitlm(instrumentVectors{inst},instrumentClassification{inst});
        coeff = mdl.Coefficients.Estimate;
        model2.w(inst,:) = coeff';
    end
    s = reshape(sum(confusion),size(featureQuality)) - featureQuality;
    s(s == 0) = 0.5;
    s = featureQuality ./ s ;
    weight = bsxfun(@rdivide,s,sum(s,2));
    featureQuality = featureQuality / nFilesCB;
end

