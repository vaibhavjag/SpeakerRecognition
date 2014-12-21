function model = generateModel()
    load('settings.mat');
    for inst = 1:size(instruments,1)
        DIR = strcat(dataDIR,'trainGMM\',instruments{inst},'\');
        mfcc=[];
        for i = 1:nFilesGMM
            filename = strcat(DIR,int2str(i),'.wav');
            disp(filename);
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
%     DIR = strcat(pwd,'\SpeakerRecognition\dataset\',int2str(fileLen),'second\test\',instruments{inst},'\');
%     mfcc=[];
%     for i = 1:nFilesGMM
%         filename = strcat(DIR,int2str(i),'.wav');
%         disp(filename);
%         [y,fs] = wavread(filename);
%         featureVector = getFeatures2(y,fs,features,featureVector);
%         if asfPresent > 0
%             featureVector{asfPresent} = [featureVector{asfPresent};asf{inst,i+50}];
%         end
%    end
        m = getGMM(featureVector);
        for k = 1:size(featureVector,1)
            model{inst,k}.mu = m{k}{1};
            model{inst,k}.sigma = m{k}{2};
            model{inst,k}.w = m{k}{3};
        end
    end
end