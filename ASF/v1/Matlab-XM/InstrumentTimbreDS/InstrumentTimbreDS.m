% function [HarmonicSpectralCentoid, HarmonicSpectralDeviation, HarmonicSpectralSpread, HarmonicSpectralVariation, LogAttackTime, SpectralCentroid, TemporalCentroid] = ...
%				mp7DSInstrumentTimbre(FILENAME, writeXML, XMLFile);
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
% - HarmonicSpectralCentoid, 
% - HarmonicSpectralDeviation, 
% - HarmonicSpectralSpread, 
% - HarmonicSpectralVariation, 
% - LogAttackTime
% - SpectralCentroid
% - TemporalCentroid
%
% Target:   MP7-XM version
% Author:   CUIDADO/IRCAM/ G. Peeters 
% LastEdit: 2002/10/30
%

%function[HarmonicSpectralCentroid, HarmonicSpectralDeviation, HarmonicSpectralSpread, HarmonicSpectralVariation, LogAttackTime, SpectralCentroid, TemporalCentroid] = ...
%   mp7DSHarmonicInstrumentTimbre(FILENAME, writeXML, XMLFile);
function[HarmonicSpectralCentroid, HarmonicSpectralDeviation, HarmonicSpectralSpread, HarmonicSpectralVariation, LogAttackTime, SpectralCentroid, TemporalCentroid] = ...
   mp7DSHarmonicInstrumentTimbre(data_v,sr_hz);

%fprintf(1, 'opening: %s\n', FILENAME);
%[data_v, sr_hz, nbits] = wavread(FILENAME);
%if size(data_v, 2)==2, data_v = mean(data_v, 2);, end

% ========================================
% === compute f0
%disp('estimating fundamental frequency');
% melanie import
ivar_s     = h_mpeg7init(sr_hz);
num_frames = floor((length(data_v) -2 * ivar_s.hopsize)/ ...
   ivar_s.hopsize);
timeF0     = (1:num_frames) * ivar_s.hopsize / sr_hz;
f0_v       = AudioFundamentalFrequencyD(data_v, ivar_s, num_frames);
f0_bp      = [timeF0' f0_v];
% end of melanie import

% specgram(data_v, 2048, sr_hz);
% hold on, plot(f0_bp(:,1), f0_bp(:,2), 'k');, hold off

pos_v  = find(f0_bp(:,2)> 10);
mf0_hz = median(f0_bp(pos_v,2));

% === parametres
param.nbT0              = 8;
param.overlap_factor    = 2;
param.L_sec             = param.nbT0/mf0_hz;
param.windowTYPE        = 'hamming';

%disp('estimating harmonic partials');
% 1) === compute STFTs
X_m = h_spectre(data_v, sr_hz, param.L_sec, param.overlap_factor, param.windowTYPE);

% 2) === estimate harmonic peaks
pic_struct = h_harmo(X_m, sr_hz, f0_bp);

%disp('computing descriptors');
% 3) === compute HarmonicSpectralCentoid, HarmonicSpectralDeviation, HarmonicSpectralSpread, HarmonicSpectralVariation
[HarmonicSpectralCentroid, HarmonicSpectralDeviation, HarmonicSpectralSpread, HarmonicSpectralVariation] = ...
   h_harmoiParam (pic_struct);

% === temporal signal envelope (informative)
param.energy_cutfreq_hz        = 20;        
param.energy_dsfact            = 3;         
energy_bp = h_energy(data_v, sr_hz, param.energy_cutfreq_hz, param.energy_dsfact);
% === log-attack-time
try
	LogAttackTime     = LogAttackTimeD(energy_bp, 2);
catch
	disp('error occurred during log-attack-time calculation');
	LogAttackTime = 0;
end
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

%if writeXML
%    if ~exist('XMLFile')
%      XMLFile=h_ITtoXML(LogAttackTime, SpectralCentroid, TemporalCentroid, HarmonicSpectralCentroid, HarmonicSpectralDeviation, HarmonicSpectralSpread, HarmonicSpectralVariation);
%    else 
%      XMLFile=h_ITtoXML(LogAttackTime, SpectralCentroid, TemporalCentroid, HarmonicSpectralCentroid, HarmonicSpectralDeviation, HarmonicSpectralSpread, HarmonicSpectralVariation, XMLFile);
%    end  
end  