function [AudioSpectrumEnvelope, attributegrp, map, XMLFile] = AudioSpectrumEnvelopeD(audioFile,hopSize,attributegrp,writeXML,XMLFile,map)
%[AudioSpectrumEnvelope, attributegrp, map, XMLFile] = AudioSpectrumEnvelopeType(audioFile,hopSize,attributegrp,writeXML,XMLFile,map)
% This function determines an AudioSpectrumEnvelope
% and also returns the map from linear to log bands.
%
%

% Written by Melanie Jackson
% Based on ISO/IEC WD 15938-4
%
% Version 2.0 15/12/2000
% Modified 18/12/2000 - Debugging
% Modified 9/1/2001 - Complete function description
% Modified 16th March 2001 - Removed common sepectrum analysis to generic function
% Modified 15/04/2002 by Thibaut Sacreste - add XML generation
% Modified 18/04/2002 by Thibaut Sacreste - changed to be a stand alone function
% Modified 03/05/2003 by Holger Crysandt - power spectrum bug-fix, see w5048 for details
%--------------------------------------------------------------------
% audioFile is the name of the audio file to process
% 2 types of files can be read: .wav and .au 

% attributegrp is a structure containing
% the attributes of the AudioSpectrumEnvelope
% as defined in the audioSpectrumAttributeGrp:
% loEdge, hiEdge, octaveResolution


% writeXML is a flag for the generation of the XML file
% writeXML=0 -> no generation
% writeXML=1 -> generation

% XMLFile is the name of the XML file to be generated (optional)


%--------------------------------------------------------------------
% Initialisation:

if nargin<4 writeXML=0;end
if nargin<2 hopSize='PT10N1000F'; end;

% Read in audio file
if audioFile(end-3:end)=='.wav'
    [audioData, sr] = wavread(audioFile);
elseif audioFile(end-2:end)=='.au'
    [audioData, sr] = auread(audioFile);
else
    Error = 'Incorrect filename'
    return
end

% Descriptors only deal with monaural recordings 
if size(audioData,2)>1 
    % in the wavread function the second dimension contains the number of channels
    audioData = mean(audioData')';
end

% Start calculating descriptors

% Hopsize conversion
% format PT10N1000F
i = find(hopSize=='N');
 hop = [str2num(hopSize(3:i-1)) str2num(hopSize(i+1:end-1))];
%hop = [str2num(hopSize(3:i-1))/str2num(hopSize(i+1:end-1))];
standvar = h_mpeg7init(sr,hop);

%------------------------------------------------------------------
% STFT with 1/3 overlap and window size of three times the hopsize.
% Zero padding of the last few frames will occur, to ensure there is one spectral frame
% for each corresponding power estimate in the power descriptor. Zero padding will also occur
% at the start for the same purpose, since 1/3 overlap is used, the emphasis of the
% information lay in the centre of the window.

[fftout,phase] = h_mpeg7getspec(audioData,standvar);

try
    if isempty(attributegrp.hiEdge)
        attributegrp.hiEdge= 16000;
    end
catch
    attributegrp.hiEdge= 16000;
end

try
    if isempty(attributegrp.loEdge)
        attributegrp.loEdge= 62.5;
    end
catch
    attributegrp.loEdge= 62.5;
end

try
    if isempty(attributegrp.octaveResolution)
        attributegrp.octaveResolution= '1';
    end
catch
    attributegrp.octaveResolution= '1';
end

AudioSpectrumEnvelope = [];

% If a map has already been created then the previous resolution will have been included

try 
    size(map);
catch
    map = [];
end

if isempty(map)		% variable defined but no value
    
    % Now determine the resolution.
    
    % attributegrp.octaveResolution will be given as a string
    % as specified in th audioSpectrumAttributeGrp
    
    res=str2num(attributegrp.octaveResolution);
    
    
    % Now determine low edge
    attributegrp.loEdge = max(h_ASEbounds(standvar.fs,standvar.FFTsize,res,1),attributegrp.loEdge);
    
    % This section maps the fft spectrum to the log freq spectrum with specified attributegrp.resolution
    N = standvar.FFTsize;
    fs = standvar.fs;
    f_fft = (0:N/2)*fs/N; % The frequencies of the fft samples
    DF = fs/N;
    % Check hiEdge less than fs/2 - if not default to nearest valid edge less than fs/2
    if attributegrp.hiEdge>fs/2
        attributegrp.hiEdge = 62.5*2^((floor(log2(fs/(2*62.5))/res))*res);
    end
    low = round(log2(attributegrp.loEdge/62.5)/res)*res;
    high = round(log2(attributegrp.hiEdge/62.5)/res)*res;
    edge = [0 62.5*2.^(low:res:high) fs/2];
    num_bands = length(edge)-1;
    e_index = 1;
    f_fft_index = [];
    bin_index = [];
    value = [];
    for f_index = 1:(N/2+1)
        if f_fft(f_index)<attributegrp.loEdge-DF/2
            % outside range
            f_fft_index = [f_fft_index; f_index];
            bin_index = [bin_index; 1];
            value = [value; 1];
        elseif (f_fft(f_index)>attributegrp.hiEdge+DF/2)
            % outside range
            f_fft_index = [f_fft_index; f_index];
            bin_index = [bin_index; num_bands];
            value = [value; 1];
        else
            dif =edge(e_index+1)- f_fft(f_index);
            if abs(dif)<DF/2
                % Coefficient must be shared between adjacent bins
                f_fft_index = [f_fft_index; f_index; f_index];
                bin_index = [bin_index; e_index; e_index+1];
                prop = 1/2+dif/DF; % Hence prop is a value between 1/2 and 1
                value = [value; prop; 1-prop];
                e_index = e_index+1; % move to next bin
            else % dif > DF/2
                % totally within bin
                f_fft_index = [f_fft_index; f_index];
                bin_index = [bin_index; e_index];
                value = [value; 1];
            end
        end
    end
    map = sparse(bin_index,f_fft_index,value);
end
% now if the output of the fft has been converted to power values which can be added
% then to resample to frequency scale just premultiply by the bins matrix
% as long as the fft output is a column vector.

powers = fftout.^2;
powers(2:end-1,:) = 2*powers(2:end-1,:);
AudioSpectrumEnvelope = (map*powers)';


%---------------------
%XML generation:

if writeXML
    if ~exist('XMLFile')
        XMLFile=h_ASEtoXML(AudioSpectrumEnvelope,attributegrp.loEdge,attributegrp.hiEdge,attributegrp.octaveResolution,hopSize);
    else
        XMLFile=h_ASEtoXML(AudioSpectrumEnvelope,attributegrp.loEdge,attributegrp.hiEdge,attributegrp.octaveResolution,hopSize,XMLFile);
    end 
end    
    


