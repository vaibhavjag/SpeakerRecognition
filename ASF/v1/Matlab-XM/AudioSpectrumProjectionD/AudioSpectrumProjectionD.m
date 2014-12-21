function [P,maxenv] = AudioSpectrumProjectionD(X,V,varargin)

% [ASP,maxenv] = AudioSpectrumProjectionD(ARG1, V, XML)
%
% Inputs:
% ARG1 - AudioSpectrumEnvelopeD matrix ( t x n, t=time points, n=spectral channels)
% ARG1 - if ARG1 is a STRING then == audio file name to extract from
% V = matrix containing AudioSpectrumBasisD values (n x k, n=frequency bins, k=basis functions)
%
% The following variables are optional, and are specified using
% ['parameter', value pairs] on the command line.
%
%    'hopSize'            'PT10N1000F'  - AudioSpectrumEnvelopeD hopSize
%    'loEdge'              62.5,        - AudioSpectrumEnvelopeD low Hz
%    'hiEdge'              16000,       - AudioSpectrumEnvelopeD high Hz
%    'octaveResolution'    '1/8'        - AudioSpectrumEnvelopeD resolution
%    'outputFile'           ''          - Filename for Model output [stem+mp7.xml]
%
% Output:
% ASP = t x (1 + k) matrix where each row contains 1 x L2-norm envelope
% coefficient and k x spectral projection coefficients.
% maxenv = maximum value of L2-norm envelope (used for SoundModelDS training data normalisation) 
% ASP is written to XML file outputFile if specified in optional arguments.

% Copyright, 1997-2003 Michael A. Casey, MIT Media Lab, MERL, The City University (London),
% All Rights Reserved

if nargin<2, error('requires two arguments (X,V)'); end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Handle Optional Arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vargs = h_AudioSpectrumBasisOptions(varargin);
hopSize = vargs.hopSize;
attributegrp.hiEdge = vargs.hiEdge;
if(isstr(attributegrp.hiEdge))
   attributegrp.hiEdge = str2num(attributegrp.hiEdge);
end
attributegrp.loEdge = vargs.loEdge;
if(isstr(attributegrp.loEdge))
   attributegrp.loEdge = str2num(attributegrp.loEdge);
end
attributegrp.octaveResolution = vargs.octaveResolution;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Optional: Extract AudioSpectrumEnvelopeD from audio file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(isstr(X))
    % Extract AudioSpectrumEnvelopeD
    filename = X;
    X = AudioSpectrumEnvelopeD(filename,hopSize,attributegrp);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if X is a well-formed spectrum
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[a,b]=size(X);
if(a<b)
    error('AudioSpectrumBasisD: Time points must be in the rows');
end

% Convert power spectrum to dB scale
X = 10*log10(X+realmin);

% Extract the spectral envelope
env =  sqrt(sum(X'.*X')'); % 2-norm of log magnitude spectrum

% Extract spectral shape
X = X ./ (env*ones(1,b));

% Project spectral shape onto spectral basis functions
P = [env X*V];
maxenv=max(env);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write the DDL code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(~isempty(vargs.outputFile))
    h_AudioSpectrumProjectiontoXML(P,vargs);
end
