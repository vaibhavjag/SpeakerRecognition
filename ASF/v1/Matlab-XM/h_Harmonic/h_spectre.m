% function [X_m] = Fspectre(data_v, sr_hz, L_sec, overlap_factor, windowTYPE)
%
% compute Short-Time-Fourier-Transform over time
% 
% INPUTS:
% =======
% - data_v     : input vector
% - sr_hz      : sampling rate of sound file
% - L_sec      : length in [seconds] of sound file
% - overlap_factor: overlap factor 
% - windowTYPE : 'boxcar', 'hanning', 'hamming', 'blackman'
%
% OUTPUTS:
% =======
% - X_m(nb_frames, 1+N/2): matrix of FFT, first row is time in [second]
%
% Target:   MP7-XM version
% Author:   CUIDADO/IRCAM/ G. Peeters 
% LastEdit: 2001/03/12
%

function [X_m] = Fspectre(data_v, sr_hz, L_sec, overlap_factor, windowTYPE)

  L_n     = round(L_sec*sr_hz)+1;
  L_n     = L_n + ~rem(L_n,2);
  LD_n    = (L_n-1)/2;
  N       = 2*2^nextpow2(L_n);
  STEP_n  = round(L_n/overlap_factor);
  
  if     strcmp(windowTYPE, 'boxcar')
    window_v       = boxcar(L_n);
  elseif strcmp(windowTYPE, 'hanning')
    window_v       = hanning(L_n);
  elseif strcmp(windowTYPE, 'hamming')
    window_v       = hamming(L_n);
  elseif strcmp(windowTYPE, 'blackman')
    window_v       = blackman(L_n);
  end
  normalisation    = sum(window_v);
  
  
  mark_n_v = [1+LD_n:STEP_n:length(data_v)-LD_n];
  
  nb_analyses = length(mark_n_v);
  
  % ================================================
  for frame = 1 : length(mark_n_v)
    
    n = mark_n_v(frame);
    t = (n-1)/sr_hz;
    
    signal_v     = data_v(n-LD_n:n+LD_n);
    signal_v     = signal_v - mean(signal_v);
    signal_v     = signal_v.*window_v;
    
    X_fft_iv = fft(signal_v, N) / normalisation;
    ampl_fft_v   = abs(X_fft_iv(1:N/2));
    
    X_m(1:N/2+1,frame) = [t; ampl_fft_v(1:N/2)];
    
  end
  % ================================================
  
  