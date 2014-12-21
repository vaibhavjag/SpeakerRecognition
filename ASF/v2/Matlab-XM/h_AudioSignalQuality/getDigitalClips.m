%#########################################################################
%##  Function: getDigitalClips.m;  calculates position of digital Clips ##
%#########################################################################
%
%   function [dclips] = getDigitalClips(auData,channels)
%
%   getDigitalClips calculates the position and the duration of 
%   digital clips for each channel of the signal
%
%   auData   = inputmatrix of audiostream N channels in columns
%   channels = channel to analyze (if empty all channels are used)
%
%   dclips = Matrix with channel, position and duration of clips
%   dclips[channel,position,duration]
%
%      Unit:	samples
%      Range: 	[0, signallength]
%
%   Written By Stefan Kudras
%   Version 1.0 Sep 2001
%	Version 2.0 March 2002
%	Version 2.1 August 2002 by Stefan Kudras handling of multichannel data described in 15398-5 (MDS)Amd.1


function [dclips] = getDigitalClips(auData,channels)

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

% calculation of digital clips
dclips = [];
[rpos cpos] = find (abs(auData)>0.999969);
le = length(rpos);
nr = 0;
idx = 1;
while idx < le
   cliplength = 1;
   if (rpos(idx)==rpos(idx+1)-1) & (cpos(idx)==cpos(idx+1)) 
      nr = nr + 1;
      dclips(nr,1) = cpos(idx);
      dclips(nr,2) = rpos(idx);
      cliplength = cliplength + 1;
      idx = idx + 1;
      if idx < le
		   while (rpos(idx)==rpos(idx+1)-1) 
            cliplength = cliplength + 1;
            if idx+1 == le
               break
            else
               idx = idx + 1;
            end
         end
      end
	   dclips(nr,3) = cliplength;
   end
   idx = idx + 1;
end