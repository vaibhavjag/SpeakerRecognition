% function [HarmonicSpectralSpread] = mp7DHarmonicSpectralSpread(freqh_v, amplh_v, H)
%
% compute instantaneous harmonic spectral spread
%
% INPUTS:
% =======
% - freqh_v : vector containing harmonic frequencies
% - amplh_v : vector containing harmonic amplitudes
% - H       : maximum number of harmonic taken into accounts
%
% OUTPUTS:
% ========
% - HarmonicSpectralSpread    : instantaneous harmonic spectral spread
%
% Target:   MP7-XM version
% Author:   CUIDADO/IRCAM/ G. Peeters 
% LastEdit: 2001/03/12
%

function [HarmonicSpectralSpread] = mp7DHarmonicSpectralSpread(freqh_v, amplh_v, H)

if (length(freqh_v) < H) | (length(amplh_v) < H), error('Fihss');, end

freqh_v  = freqh_v(:);
amplh_v  = amplh_v(:); 

% === ihsc computing
num       					= sum(freqh_v(1:H).*amplh_v(1:H));
denum     					= sum(amplh_v(1:H));
HarmonicSpectralCentroid= num / denum;

% === ihss computing
num   = sum( (amplh_v(1:H) .* (freqh_v(1:H)-HarmonicSpectralCentroid) ).^2 );
denum = sum( amplh_v(1:H).^2 );

HarmonicSpectralSpread  = 1/HarmonicSpectralCentroid * sqrt(num/denum);