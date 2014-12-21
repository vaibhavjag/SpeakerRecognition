% function [SpectralCentroid] = mp7SpectralCentroid(freq_v, ampl_v, H)
%
% compute instantaneous spectral centroid
%
% INPUTS:
% =======
% - freq_v : vector containing bins frequencies [Hz]
% - ampl_v : vector containing bins amplitudes  [lin]
% - H      : maximum number of bins taken into accounts
%
% OUTPUTS:
% ========
% - SpectralCentroid    : istantaneous harmonic spectral centroid
%
% Target:   MP7-XM version
% Author:   CUIDADO/IRCAM/ G. Peeters 
% LastEdit: 2001/03/12
%

function [SpectralCentroid] = mp7SpectralCentroid(freq_v, ampl_v, H)
  
  if (length(freq_v) < H) | (length(ampl_v) < H), error('mp7SpectralCentroid');, end
  
  freq_v = freq_v(:);
  ampl_v = ampl_v(:);
  
  % === ihsc computing
  num       = sum(freq_v(1:H).*ampl_v(1:H));
  denum     = sum(ampl_v(1:H));
  
  SpectralCentroid      = num / denum;
      