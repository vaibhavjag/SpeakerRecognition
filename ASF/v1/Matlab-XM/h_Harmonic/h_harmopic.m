% function [freqh_hz_v, amplh_lin_v] = Fharmopic(H, f0_hz, c, am_fft_v, sr_hz, N)
%
% functionality: estimate the frequency and the amplitude of the harmonic peaks of the signal
%
% INPUTS:
% =======
% - H          : number of harmonic peaks to estimate
% - f0_hz      : fundamental frequency [Hz]
% - c          : inharmonicity tolerance ]0,0.5[ : 0=purely harmonic
% - am_fft_v   : vector of FFT amplitudes
% - sr_hz      : sampling rate of the sound signal [hz]
% - N          : size of the FFT
%
% OUTPUTS:
% ========
% - freqh_v : vector containing harmonic frequencies [Hz]
% - amplh_v : vector containing harmonic amplitudes  [lin]
%
% Target:   MP7-XM version
% Author:   CUIDADO/IRCAM/ G. Peeters 
% LastEdit: 2001/03/12
%

function [freqh_hz_v, amplh_lin_v] = Fharmopic(H, f0_hz, c, am_fft_v, sr_hz, N);
  
  harmo_hz_v = [1:H]*f0_hz;
  freqh_hz_v = zeros(H,1);
  amplh_lin_v= zeros(H,1);
  
  for h = 1:H
    
    zone_hz         = [max([0, harmo_hz_v(h)-c*f0_hz]) : ...
		       min([harmo_hz_v(h)+c*f0_hz, sr_hz/2-sr_hz/N])];
    zone_k          = round(zone_hz/sr_hz*N)+1;
    if length(zone_k)
      [maximum.value, maximum.pos] = max(am_fft_v(zone_k));
      maximum.pos     = zone_k(maximum.pos);
      freqh_hz_v(h)   = (maximum.pos-1)/N*sr_hz;
      amplh_lin_v(h)  = maximum.value;
    end
  end
  pos_v = find(freqh_hz_v > 0);
  if size(pos_v) == 0
      H = 1;
  else
      H     = pos_v(end);
  end
  freqh_hz_v = freqh_hz_v(1:H);
  amplh_lin_v= amplh_lin_v(1:H);
  
  