function model = generateIRM()
    %get settings
    %settings
    load('settings.mat');
    %generateUBM
    ubm = generateUBM(dataDIR);
    save('ubm.mat','ubm');
    %load('ubm.mat')
    %Adapt UBM
    
    for inst=1:noOfInstruments
        disp(strcat('Adapting the UBM to get the GMM for an instrument  --->',instruments{inst})) ;
        data = load_data(dataDIR,instruments{inst});
        for feat=1:noOfFeatures
            if strcmpi(features{feat}, 'asf')
                featureVector = cell(25,1);
                for k=1:25
                    featureVector{k} = asf{inst,k};
                end
            else
                featureVector = getFeature(data,features{feat});
            end
            model{inst,feat} = mapAdapt(featureVector,ubm{feat});
        end
    end
end

function data = load_data(dataDIR,instrument)
    data.fs = zeros(25,1);
    data.y = cell(25,1);
    for i=1:25
        DIR = strcat(dataDIR,'trainGMM\',instrument,'\',int2str(i),'.wav');
        [y,fs] = wavread(DIR);
        data.fs(i) = fs;
        data.y{i} = y;
    end
end