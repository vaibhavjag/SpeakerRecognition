%#########################################################################
%##  Function: getSampleHolds.m;  calculates position of SampleHolds    ##
%#########################################################################
%
%   function [SH] = getSampleHolds(auData,channels)
%
%   getSampleHolds calculates the position and the duration of 
%   SampleHolds for each channel of the signal
%
%   auData   = inputmatrix of audiostream N channels in columns
%   channels = channel to analyze (if empty all channels are used)
%
%   SH = Matrix with channel, position and duration of SampleHolds
%   SH[channel,position,duration]
%
%      Unit:	samples
%      Range: 	[0, signallength]
%
%   Written By Stefan Kudras
%   Version 1.0 19 Sep 2001
%	Version 2.0 March 2002 
%	Version 2.1 August 2002 by Stefan Kudras handling of multichannel data described in 15398-5 (MDS)Amd.1

function [SH] = getSampleHolds(auData,channels)

nr = 0;

[lengthx,nChannels] = size(auData);
% Check if empty, use all channels (compatibility to V1 AudioD)
if (isempty(channels))
    channels = 1:nChannels;    
end

% Check if specified channels numbers are valid
idx = find (channels > nChannels);
channels(idx) = [];
idx = find (channels < 1);
channels(idx) = [];

% rearranging data
auData = auData(:,channels);
[lengthx,nChannels] = size(auData);

% calculation of sample holds
%difference Vector
diffv = [auData;ones(1,nChannels)*i]-[ones(1,nChannels)*i;auData]; %*i damit Signalwerte ausgeschlossen
[vr vc] = find(diffv==0);
vr = vr - 1;
le = length(vr);

ErrNr = 0;
idx = 0;
ivor = -1; 
cvor = -1;

while idx < le
   idx = idx + 1;
   if (vr(idx) ~= (ivor+1)) | (vc(idx) ~= cvor)
      ErrorLen = 2;
      ErrNr = ErrNr +1;
      ivor = vr(idx);
      cvor = vc(idx);
      SH(ErrNr,1) = vc(idx);
      SH(ErrNr,2) = vr(idx);
      SH(ErrNr,3) = ErrorLen;
	else
      ivor = vr(idx);
      cvor = vc(idx);
      ErrorLen = ErrorLen + 1;
      SH(ErrNr,3) = ErrorLen;
   end
end

%find sample holds longer than 2
pos = find(SH(:,3)<3);
SH(pos,:)=[];