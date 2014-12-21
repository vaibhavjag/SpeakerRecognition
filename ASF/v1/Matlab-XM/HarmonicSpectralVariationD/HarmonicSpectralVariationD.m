% function [HarmonicSpectralVariation] = mp7DHarmonicSpectralVariation(x1_v, x2_v, H)
%
% INPUTS:
% =======
% - x1_v : vector containing harmonic amplitude at frame F-1
% - x2_v : vector containing harmonic amplitudes at frame F
% - H    : maximum number of harmonic taking into accounts
%
% OUTPUTS:
% ========
% - HarmonicSpectralVariation : instantaneous harmonic spectral variation
%
% Target:   MP7-XM version
% Author:   CUIDADO/IRCAM/ G. Peeters 
% LastEdit: 2001/03/12
%

function [HarmonicSpectralVariation] = mp7DHarmonicSpectralVariation(x1_v, x2_v, H)
  
  if (length(x1_v) < H) | (length(x2_v) < H), error('Fihsv');, end
  
  crossprod    = sum(x1_v(1:H).*x2_v(1:H));
  autoprod_x1  = sum(x1_v(1:H).^2);
  autoprod_x2  = sum(x2_v(1:H).^2);
  
  HarmonicSpectralVariation         = 1 - crossprod / (sqrt(autoprod_x1*autoprod_x2));
  
  