function [ GMMS ] = getGMM( featureVector )
%GETGMM Summary of this function goes here
%   INPUTS
%       featureVector = row cell array containing feature matrices
%   OUTPUTS
%       GMMS = row cell array containing feature matrices
    GMMS = cell(size(featureVector));
    for i = 1:size(featureVector,1)
        [m,v,w,g,f,pp,gg] = gaussmix(featureVector{i},[],[],1,'v');
        GMMS{i} = {m,v,w,g,f,pp,gg};
    end
end

