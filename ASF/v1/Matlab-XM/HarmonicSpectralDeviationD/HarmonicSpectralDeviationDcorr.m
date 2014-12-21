% function [HarmonicSpectralDeviation] = mp7DHarmonicSpectralDeviationCorrigendum(amplh_v, SE_v, H)
%
% CORRIGENDUM VERSION (w4770) 2002/07/22 
%
% compute instantaneous harmonic spectral deviation
%
% INPUTS:
% =======
% - amplh_v : vector containing harmonic amplitudes
% - SE_v    : vector containing the estimation  of the Spectral Envelope
%             at the position of the harmonic peaks
% - H       : maximum number of harmonic taken into accounts
%
% OUTPUTS:
% ========
% - HarmonicSpectralDeviation    : instantaneous harmonic spectral deviation
%
% Target:   MP7-XM version
% Author:   CUIDADO/IRCAM/ G. Peeters 
% LastEdit: 2001/03/12
%

function [HarmonicSpectralDeviation] = mp7DHarmonicSpectralDeviationCorrigendum(amplh_v, SE_v, H)

if (length(amplh_v) < H) | (length(SE_v) < H), error('Fihsd');, end

amplh_v = amplh_v(:);
SE_v    = SE_v(:);

% === ihsd computing
HarmonicSpectralDeviation = sum( abs( amplh_v(1:H) - SE_v(1:H) ) );

%HarmonicSpectralDeviation = HarmonicSpectralDeviation / sum( amplh_v(1:H) );
% === CORRIGENDA VERSION (w4770) 2002/07/22 
nb_harmo = H;
HarmonicSpectralDeviation  	= HarmonicSpectralDeviation / nb_harmo;