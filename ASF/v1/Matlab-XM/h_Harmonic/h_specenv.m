% function [SE_lin_v] = Fspecenv(amplh_lin_v)
%
% functionality: spectral envelope estimation
%
% Target:   MP7-XM version
% Author:   CUIDADO/IRCAM/ G. Peeters 
% LastEdit: 2001/03/12
%

function [SE_lin_v] = Fspecenv(amplh_lin_v)
  
  amplh_lin_v = amplh_lin_v(:);
  H           = length(amplh_lin_v);
  SE_lin_v    = zeros(H,1);
  
  % === spectral envelope estimation (informative part)
  if H > 1
      kk = 1;
      SE_lin_v(kk)= (amplh_lin_v(kk)+amplh_lin_v(kk+1)) / 2;
      for kk = 2:H-1
        SE_lin_v(kk)   = (amplh_lin_v(kk-1) + amplh_lin_v(kk) + amplh_lin_v(kk+1)) / 3;
      end
      kk = H;
      SE_lin_v(kk)= (amplh_lin_v(kk-1)+amplh_lin_v(kk)) / 2;
  else
      SE_lin_v(1)= amplh_lin_v(1);
  end

  
  