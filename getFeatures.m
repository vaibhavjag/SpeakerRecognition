function [ features ] = getFeatures( frames,fs,reqFeatures,featureVector )
%GETFEATURES Summary of this function goes here
%   INPUTS:
%       frames = y
%       fs = fs
%       reqFeatures = row cell array listing required features (strings)
%		featureVector = optional ... if present then data is appended to the given vector (row addition)
%   OUTPUTS:
%       features = row cell array containing feature matrices
    features = cell(size(reqFeatures));
	if nargin == 4
	    for i = 1:size(reqFeatures,1)
	        if strcmpi(reqFeatures{i},'mfcc')
	            features{i} = [featureVector{i};melcepst(frames,fs,'0Dd')];
	        elseif strcmpi(reqFeatures{i},'asf')
	            [HarmonicSpectralCentroid, HarmonicSpectralDeviation, HarmonicSpectralSpread, HarmonicSpectralVariation, LogAttackTime, SpectralCentroid, TemporalCentroid] = InstrumentTimbreDS(frames,fs);
	            a = [HarmonicSpectralCentroid, HarmonicSpectralDeviation, HarmonicSpectralSpread, HarmonicSpectralVariation, LogAttackTime, SpectralCentroid, TemporalCentroid];
                a(isnan(a)) = 0;
                features{i} = [featureVector{i};a];
	        elseif strcmpi(reqFeatures{i},'temporal')
	            features{i} = [featureVector{i};getTemporalFeatures(frames,fs)];
	        end
	    end
	else
	    for i = 1:size(reqFeatures,1)
	        if strcmpi(reqFeatures{i},'mfcc')
	            features{i} = melcepst(frames,fs,'0Dd');
	        elseif strcmpi(reqFeatures{i},'asf')
	            [HarmonicSpectralCentroid, HarmonicSpectralDeviation, HarmonicSpectralSpread, HarmonicSpectralVariation, LogAttackTime, SpectralCentroid, TemporalCentroid] = InstrumentTimbreDS(frames,fs);
	            a = [HarmonicSpectralCentroid, HarmonicSpectralDeviation, HarmonicSpectralSpread, HarmonicSpectralVariation, LogAttackTime, SpectralCentroid, TemporalCentroid];
                a(isnan(a)) = 0;
                features{i} = a;
	        elseif strcmpi(reqFeatures{i},'temporal')
	            features{i} = getTemporalFeatures(frames,fs);
	        end
    	end
    end
end

