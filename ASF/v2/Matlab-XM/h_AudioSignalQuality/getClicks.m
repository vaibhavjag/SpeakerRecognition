%######################################################################
%##  Function: getClicks.m;  calculates position of Clicks           ##
%######################################################################
%
%   function [clicks] = getClicks(auData,channels)
%
%   getClicks detects the position of digital clips for each channel 
%   of the signal by using a robust HighPass filter
%
%   auData   = inputmatrix of audiostream N channels in columns
%   channels = channel to analyze (if empty all channels are used)
%
%   clicks = Matrix with channel, position of clicks 
%   clicks[channel,position]
%
%      Unit:	samples
%      Range: 	[0, signallength]
%
%   Written By J. Bitzer HDA 
%   Version 1.0 21 Sep 2001
%   Modified by Stefan Kudras HDA
%   Version 1.1 24.09.2001
%	Version 2.0 March 2002 
%	Version 2.1 August 2002 by Stefan Kudras handling of multichannel data described in 15398-5 (MDS)Amd.1


function [clicks] = getClicks(auData,channels)

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

% calculation of clicks
nr = 0;

clicks = zeros(0,0);
signal = auData;

% Determine HP
[b,a]  = butter(4,0.4,'high');

for ch=1:nChannels
	% filter input signal to get detection signal
	detectSignal = filter(b,a,signal(:,ch));
	detectSignal = abs(detectSignal);
   
	%smooth detection signal to get a robust estimation of the energy in the High Frequencies
	% First Nonlinear
	MedLen = 41;
	detectSmooth = medfilt1(detectSignal,MedLen,20000);

	% Second linear with mean filter
	len = 25;
	b2 = ones(len,1);
	detectSmooth = 1/len.*filter(b2,1,detectSmooth);
   
   %figure;plot(detectSignal);
	%hold;
	%plot(detectSmooth,'r');

   
	Thresh = 12;
   clickpos = find(detectSignal>Thresh*detectSmooth);
   
   clickpos2 = clickpos;
   for ind=2:length(clickpos)
      if (clickpos(ind)-clickpos(ind-1)<200)
         clickpos2(ind)=0;
      end
   end
   
   cpos = find(clickpos2>0);
   clickpos2 = clickpos2(cpos);
   
   clickm(:,1)=ones(length(clickpos2),1)*ch;
   clickm(:,2)=clickpos2;
   
   clicks = [clicks; clickm];
   
   clickm = [];
   
end

