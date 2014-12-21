% function [HarmonicSpectralCentroid] = mp7DHarmonicSpectralCentroid(freqh_v, amplh_v, H)
%
% compute instantaneous harmonic spectral centroid
%
% INPUTS:
% =======
% - freqh_v : vector containing harmonic frequencies [Hz]
% - amplh_v : vector containing harmonic amplitudes  [lin]
% - H       : maximum number of harmonic taken into accounts
%
% OUTPUTS:
% ========
% - HarmonicSpectralCentroid    : instantaneous harmonic spectral centroid
%
% Target:   MP7-XM version
% Author:   CUIDADO/IRCAM/ G. Peeters 
% LastEdit: 2001/03/12
%

function [HarmonicSpectralCentroid] = mp7DHarmonicSpectralCentroid(freqh_v, amplh_v, H)

if (length(freqh_v) < H) | (length(amplh_v) < H), error('mp7HarmonicSpectralCentroid');, end

freqh_v = freqh_v(:);
amplh_v = amplh_v(:);

% === ihsc computing
num       = sum(freqh_v(1:H).*amplh_v(1:H));
denum     = sum(amplh_v(1:H));

HarmonicSpectralCentroid      = num / denum;
