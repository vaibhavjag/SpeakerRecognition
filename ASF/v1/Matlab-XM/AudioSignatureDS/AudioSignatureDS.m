function [as_mean,as_var, hiedge, XMLFile]=AudioSignature(audioFile,hiEdge,decim,writeXML,XMLFile)
%function [as_mean,as_var]=AudioSignature(audiosignal,fs,decim)     %previous version

% [as_mean,as_var,  XMLFile] = AudioSignature(audioFile,hiEdge,decim,writeXML,XMLFile)
% This function extracts the values of the MPEG-7 Audio AudioSignature DS
% where audiosignal contains the raw data to be analysed
% fs is the sampling frequency of this data
% decim optionally specifies the decimation factor (default: 32)
%
% s = AudioSignature(audiosignal,fs,decim) returns the data as XML in string variables
%
% v1.0 Written 12th October 2001 by Juergen Herre
% v2.0 Written 30th April   2002 by Juergen Herre
% Modified 30/04/2002 by Thorsten Kastner -  added XML-Output 
%                                         -  hiEdge can be set; loedge is fixed at 250Hz
% Modified 11/06/2002 by Thorsten Kastner -  added return value hiedge; returns exact value for upper edge frequency
%--------------------------------------------------------------------
% audioFile is the name of the audio file to process
% 2 types of files can be read: .wav and .au 

% writeXML is a flag for the generation of the XML file
% writeXML=0 -> no generation
% writeXML=1 -> generation
% XMLFile is the name of the XML file to be generated (optional)

  
% Settings 
try	% variable defined
    if isempty(decim)			% variable defined but no value
      decim = 32; 
    else
      if (2^round(log2(decim)) ~= decim), error('Illegal decimation factor'), end
    end   
catch
    decim = 32;
end


loEdge = 250; % Setting loEdge for AudioSignature
if (hiEdge < 500), error('Illegal upper frequency'), end   % hiEdge minimum 500Hz
hopSize = 'PT30N1000F'; % Setting hopsize for AudioSignature;

[sfm,loEdge,hiEdge] = AudioSpectrumFlatnessD(audioFile,hopSize,loEdge,hiEdge,'');  

as_mean = [];  as_var = [];
num_blocks = floor(size(sfm,1) / decim);
for k=1:num_blocks
        block_data = sfm((k-1)*decim+1:k*decim,:);
	as_mean = [as_mean mean(block_data)'];
	as_var = [as_var (std(block_data,1).^2)'];
end
hiedge = hiEdge;
if writeXML
        if ~exist('XMLFile')
	  XMLFile=h_AudioSignatureToXML(as_mean,as_var,loEdge,hiEdge,hopSize,decim );
	else
	  XMLFile
	  XMLFile=h_AudioSignatureToXML(as_mean,as_var,loEdge,hiEdge,hopSize,decim,XMLFile );
	end
end
as_mean= as_mean';
as_var = as_var';