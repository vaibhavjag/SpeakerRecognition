function [ probabilities,classification,combinedProbabilities ] = getClassification2( data,model )
%GETCLASSIFICATION Summary of this function goes here
%   Detailed explanation goes here
    if nargin == 1
        load('model.mat');        
    else
        model2.w = [zeros(size(model,1),1),ones(size(model))];
    end
    load('ubm.mat');
	probabilities = zeros(size(model));
    for feature = 1:size(model,2)
        probs = zeros(size(data{feature},1),size(model,1));
        for instrument = 1:size(model,1)
	    	singleModel = model{instrument,feature};
            ubmModel = ubm{feature};
            probs(:,instrument) = gaussmixp(data{feature},singleModel.mu,singleModel.sigma,singleModel.w) - gaussmixp(data{feature},ubmModel.mu,ubmModel.sigma,ubmModel.w);	
        end     
        if size(probs,1) == 1
            b = normalizevalues(sum(probs,1),2);
            s = b / sum(b);
            probabilities(:,feature) = s;
        else
            [~,a] = max(probs,[],2);
            b = histc(a,1:size(model,1));
            s = b / sum(b);
            probabilities(:,feature) = s;
        end
    end
    if nargout > 1
        combinedProbabilities = sum([ones(size(probabilities,1),1),probabilities].*model2.w,2);
        x = normalizevalues(combinedProbabilities,1);
        cp = x / sum(x);
        %combinedProbabilities = sum(probabilities .* model2.w,2);  
        [~,classification] = max(combinedProbabilities);
    end       
end