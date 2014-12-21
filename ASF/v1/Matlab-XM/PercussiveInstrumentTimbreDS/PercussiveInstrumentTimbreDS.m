% function [LogAttackTime, SpectralCentroid, TemporalCentroid] = ...
% 				mp7DSPercussiveInstrumentTimbre(FILENAME, writeXML, XMLFile);
%
% INPUTS:
% =======
% - FILENAME [ascii string]: name of the file to be processed
% - writeXML 					: a flag for the generation of the XML file
% 										writeXML=0 -> no generation
% 										writeXML=1 -> generation
% - XMLFile 					: name of the XML file to be generated (optional)
%
% OUTPUTS:
% ========
% - LogAttackTime, 
% - SpectralCentroid, 
% - TemporalCentroid
%
%
% Target:   MP7-XM version
% Author:   CUIDADO/IRCAM/ G. Peeters 
% LastEdit: 2001/03/12
%

function[LogAttackTime, SpectralCentroid, TemporalCentroid] = mp7DSPercussiveInstrumentTimbre(FILENAME, writeXML, XMLFile);


fprintf(1, 'opening: %s\n', FILENAME);
[data_v, sr_hz, nbits] = wavread(FILENAME);
if size(data_v, 2)==2, data_v = mean(data_v, 2);, end

% ========================================
% === temporal signal envelope (informative)
param.energy_cutfreq_hz        = 20;        
param.energy_dsfact            = 3;         
energy_bp = h_energy(data_v, sr_hz, param.energy_cutfreq_hz, param.energy_dsfact);

% === log-attack-time
LogAttackTime		= LogAttackTimeD(energy_bp, 2);
% === temporal centroid
TemporalCentroid	= TemporalCentroidD(energy_bp);

% === power spectrum (informative)
param.powerspectrum_resolution = 10;
[power_v, freq_v] = spectrum(data_v, 2^param.powerspectrum_resolution, 0, hamming(2^param.powerspectrum_resolution), sr_hz);
sqrtpower_v       = sqrt(power_v(:,1));
H                 = length(sqrtpower_v);
% === spectral centroid
SpectralCentroid  = SpectralCentroidD(freq_v, sqrtpower_v, H);

%---------------------
%XML generation:

if writeXML
    if ~exist('XMLFile')
      XMLFile=h_PITtoXML(LogAttackTime, SpectralCentroid, TemporalCentroid);
    else 
      XMLFile=h_PITtoXML(LogAttackTime, SpectralCentroid, TemporalCentroid,XMLFile);
    end  
end    

