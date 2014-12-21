function H = SoundModelStateHistogramD(filename, arg2, varargin)
%SoundModelStateHistogramD(filename, SoundModelDS, [Optional Arguments])
%
% Extract normalized segmental state-path histograms
%
% Inputs:
% filename - the filename of the file to extract from
% SoundModelDS - SoundModelDS structure
%
% The following variables are optional, and are specified using
% 'parameter' value pairs on the command line.
%
%    'hopSize'          'PT10N1000F'
%    'loEdge'            62.5,      
%    'hiEdge'            16000,     
%    'octaveResolution'  '1/8'
%    'sequenceHopSize'     '',
%    'sequenceFrameLength' ''
%    'outputFile'         ''
%
% Outputs
%
% Path - hidden Markov model optimal state path for sequence
% loglike - log-likelihood of sequence
%
% Outputs:
% H - t x n matrix containing segmented state occupancy histograms
%           t=time points, n=states



if nargin<1 printErrorMsg;end
vargs = h_SoundModelOptions(varargin);
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
outputFile = vargs.outputFile;
segSkip = vargs.sequenceHopSize;
segLen = vargs.sequenceFrameLength;

% If arg2 is a string then read the SoundModelDS instance file
if isstr(arg2)
   load(arg2);
else
   Y=arg2;
   clear arg2;
end
Nstates=size(Y.T,1);
[Path,ll] = SoundModelStatePathD(filename,Y,'loEdge',vargs.loEdge,'hiEdge',vargs.hiEdge,'octaveResolution',vargs.octaveResolution,'hopSize',vargs.hopSize);

pathLength=length(Path);
numSegs = floor(1+((pathLength-segLen)/segSkip));
for k=1:numSegs
    H(k,:) = hist(Path( ((k-1)*segSkip+1):((k-1)*segSkip+segLen)), 1:Nstates );
    % Normalize histogram entries
    H(k,:) = H(k,:) / norm(H(k,:),2);
end
hopSize = ['PT' num2str(vargs.sequenceHopSize*10) 'N1000F'];

if(~isempty(outputFile))
    [p,name,e]=fileparts(Y.soundName);
    h_SoundModelStateHistogramtoXML(H,outputFile,name,hopSize);
end
