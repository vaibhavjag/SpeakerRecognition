function [ features ] = getMFCCFeatures( frames,fs )
%GETFEATURES Summary of this function goes here
%   Detailed explanation goes here
features = melcepst(frames,fs,'0Dd');

end

