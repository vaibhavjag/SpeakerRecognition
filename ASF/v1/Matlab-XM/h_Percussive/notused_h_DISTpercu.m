% function [distance] = Fdistmultipercu(vector1_v, vector2_v);
%
% INPUTS
% - vector1_v  : vector of parameters för the first sound
% - vector2_v  : vector of parameters för the second sound
% OUTPUTS:
% - distance
%
% (Gfp 2001/05/23)
%

function [distance] = Fdistmultipercu(vector1_v, vector2_v);

% vector1_v : lat, tc, sc
% vector2_v : lat, tc, sc

Alat = vector1_v(1);  Blat = vector2_v(1);
Atc  = vector1_v(2);  Btc  = vector2_v(2);
Asc  = vector1_v(3);  Bsc  = vector2_v(3);   
  
x1  = -0.3;
x2  = -0.6;
xs3 = -1e-4;
  
disx  = (x1*(Alat-Blat) + x2*(Atc-Btc)^2);
disy  = (xs3*(Asc-Bsc)^2);
  
distance = sqrt(disx + disy);
  