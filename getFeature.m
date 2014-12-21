function [ features ] = getFeature( data,reqFeature )
%GETFEATURES Summary of this function goes here
%   INPUTS:
%       frames = y
%       fs = fs
%       reqFeatures = row cell array listing required features (strings)
%		featureVector = optional ... if present then data is appended to the given vector (row addition)
%   OUTPUTS:
%       features = row cell array containing feature matrices
    n = size(data.fs,1);
    features = [];
    for i=1:n
        if strcmpi(reqFeature,'mfcc')
            features = vertcat(features,melcepst(data.y{i},data.fs(i),'0Dd'));
        elseif strcmpi(reqFeature,'asf')
            [HarmonicSpectralCentroid, HarmonicSpectralDeviation, HarmonicSpectralSpread, HarmonicSpectralVariation, LogAttackTime, SpectralCentroid, TemporalCentroid] = InstrumentTimbreDS(data.y{i},data.fs(i));
            a = [HarmonicSpectralCentroid, HarmonicSpectralDeviation, HarmonicSpectralSpread, HarmonicSpectralVariation, LogAttackTime, SpectralCentroid, TemporalCentroid];
            a(isnan(a)) = 0;
            features = vertcat(features,a);
        elseif strcmpi(reqFeature,'temporal')
            features = vertcat(features,getTemporalFeatures(data.y{i},data.fs(i)));
        end
    end
    features = num2cell(features,2);
end
