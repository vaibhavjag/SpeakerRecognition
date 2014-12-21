%##################################################################################
%##  Function: IsOriginalMono.m;  describes if a signal is original Mono         ##
%##################################################################################
%
%   function [IM] = IsOriginalMono(auData,fs,channels)
%
%   IsOriginalMono describes if a signal is original Mono although it has mor than
%   one channel
%
%   auData   = inputmatrix of audiostream N channels in columns
%   fs 	     = Samplerate of audiostream
%   channels = channel to analyze (if empty all channels are used)
%
%   IM = flag, 1 = is original Mono, 0 = is not original Mono
%
%        Unit:	[-]
%        Range: [0, 1]
%
%   Written By Stefan Kudras
%   Version 1.0 Sep 2001
%   Version 1.1 Oct 2001, blockwise calculation of data
%	Version 2.0 March 2002 
%	Version 2.1 August 2002 by Stefan Kudras handling of multichannel data described in 15398-5 (MDS)Amd.1


function [IM] = IsOriginalMono(auData,fs,channels)

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

% calculation of original mono
if nChannels > 1
   
   blockSize_ms = 50;							%blocksize in ms
	blockSize = fix(blockSize_ms/1000*fs);      %blocksize in samples
	blocks = fix(lengthx/blockSize);			%nr of blocks
	meanIM = zeros(11,nChannels-1);			    %initialization
	IM = zeros(1,nChannels-1);					%initialization
   
   for idx = 1:blocks
       blockx = auData((idx-1)*blockSize+1:(idx-1)*blockSize+blockSize,:); %actual block
 	   if max(abs(blockx))~=0
           blockx = blockx ./ (ones(blockSize,1)*max(abs(blockx)));	%normalized block
   	   end
       akf_1 = xcorr(blockx(:,1));
       maxco_1 = akf_1(blockSize);				%maximum autocorrelation of 1. channel
       for n=2:nChannels
           akf_n = xcorr(blockx(:,n));
           maxco_n = akf_n(blockSize);			%maximum autocorrelation of n-th channel
	       maxco = sqrt(maxco_1*maxco_n);		%mean maximum of autocorrelations
   	       co = xcorr(blockx(:,1),blockx(:,n)); %calcualtion of cross correlation
      	   if maxco~=0
               co = co/maxco;			%normalized cross correlation
           end
           co = co(blockSize-5:blockSize+5);		%take 11 middle coefficients
           meanIM(:,n-1) = meanIM(:,n-1) + co;
   	   end
   end
   
   meanIM = meanIM / blocks;
   
   if max(max(meanIM))>0.99
      IM = 1;
      break;
   else
      IM = 0;
   end
      
else	%nChannels = 1
   IM = 1;
end
