function [V,env]=AudioSpectrumBasisD(X, NUM_IC, varargin)

% AudioSpectrumBasisType - Eigen spectra subspace components of a spectrum matrix.
%                          Optionally extracts independent components
%                          (see optional arguments)
%
% [ASB,env]=AudioSpectrumBasis(ARG1, k, [Optional Arguments])
%
% Inputs:
%
% ARG1 - AudioSpectrumBasisD matrix ( t x n, t=time points, n=spectral channels)
% ARG1 - if ARG1 is a STRING then == audio file name to extract from
% k - number of components to extract
%
% The following variables are optional, and are specified using
% ['parameter', value pairs] on the command line.
%
%    'JADE'                0             - Flag to indicate use of JADE (requires jade.m to be installed)
%    'hopSize'            'PT10N1000F'  - AudioSpectrumEnvelopeD hopSize
%    'loEdge'              62.5,        - AudioSpectrumEnvelopeD low Hz
%    'hiEdge'              16000,       - AudioSpectrumEnvelopeD high Hz
%    'octaveResolution'    '1/8'        - AudioSpectrumEnvelopeD resolution
%    'outputFile'           ''          - Filename for Model output [stem+mp7.xml]
%
% Outputs:
%
% ASB - n x k matrix of basis functions
% env - L2-norm envelope of log Spectrogram data
% ASB is written to XML file outputFile if specified in optional arguments.

% Copyright, 1997-2003 Michael A. Casey, MIT Media Lab, MERL, The City University (London),
% All Rights Reserved

if nargin<2 error('Must have at least two arguments: AudioSpectrumBasisD(X,N)'); end

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert power spectrum to dB scale
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X = 10*log10(X+realmin);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract L2-norm of total spectral energy envelope
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
env =  sqrt(sum(X'.*X')'); % 2-norm of log magnitude spectrum

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract spectral shape
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X = X ./ (env*ones(1,b));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract spectral shape basis functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[U,A,V] = svd(X,0); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Basis Function Dimension Reduction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
V=V(:,1:NUM_IC);
delta=diag(A(:,1:NUM_IC));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OPTIONAL: ICA
% Place any optional Independent Components Analysis or Non-Negative Matrix
% Factorization code HERE. Additional code operates on the V matrix rotating
% it according to different constraints.
% The following is just one of many possible basis extraction schemes.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(vargs.JADE ~=0)
    if(~exist('jade'))
        error('AudioSpectrumBasisD: must have jade.m in path to use JADE option. Available on WWW, search: jade.m');
    end
    % We estimate basis from the projection of X onto V
    Y=X*V; 
    % Use Cordoso's JADE algorithm as a reference
    [V2,XX] = jade(Y', NUM_IC);
    % The final basis functions are the product of SVD and ICA rotations
     V=V*pinv(V2)';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write the DDL code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(~isempty(vargs.outputFile))
    h_AudioSpectrumBasistoXML(V,vargs);
end
