% function [pic_struct] = Fharmo(X_m, sr_hz, f0_bp)
%
% INPUTS:
% =======
% - X_m       : FILEREAD [ascii string] or data matrix
% - sr_hz     : sampling rate of sound file
% - f0_bp     : breakpoint fonction de f0 (temps|valeurs)
%
% OUTPUTS:
% ========
% - pic_struct : structure .freqh_v, .amplh_lin_v
%
% Target:   MP7-XM version
% Author:   CUIDADO/IRCAM/ G. Peeters 
% LastEdit: 2001/03/12
%

function [pic_struct] = Fharmo(X_m, sr_hz, f0_bp)

  param.crible = 0.1;
  
  nb_frames = size(X_m, 2);
  nsams     = size(X_m, 1)-1;
  N         = nsams*2;
  
  % ================
  for frame = 1:nb_frames
    
    t          = X_m(1,frame);
    ampl_fft_v = X_m(2:N/2+1,frame);
    
    f0_hz = h_evalbp(f0_bp, t);
    
    H = ceil(.5 * sr_hz / f0_hz);
    
    [freqh_hz_v, amplh_lin_v] = h_harmopic(H, f0_hz, param.crible, ampl_fft_v, sr_hz, N);
    
    pic_struct(frame).freqh_v      = freqh_hz_v;
    pic_struct(frame).amplh_lin_v  = amplh_lin_v;
  end
  
  % ================
  
  