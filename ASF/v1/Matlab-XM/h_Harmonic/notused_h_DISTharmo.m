% function [distance] = FDISTharmo(vector1_v, vector2_v)
%
% INPUTS
% - vector1_v  : vector of parameters för the first sound
% - vector2_v  : vector of parameters för the second sound
% OUTPUTS:
% - distance
%
% (Gfp 2001/05/23)
%

function [distance] = FDISTharmo(vector1_v, vector2_v)
  
  % vector1_v : lat, hsc, hsd, hss, hsv
  % vector2_v : lat, hsc, hsd, hss, hsv
    
  
  Alat   = vector1_v(1); Blat   = vector2_v(1);
  Ahsc   = vector1_v(2); Bhsc   = vector2_v(2);
  Ahsd   = vector1_v(3); Bhsd   = vector2_v(3);
  Ahss   = vector1_v(4); Bhss   = vector2_v(4);
  Ahsv   = vector1_v(5); Bhsv   = vector2_v(5);
  
  xs1 = 8;
  xs2 = 3e-5;
  xs3 = 3e-4;
  x4  = 10;
  x5  = -60;
  
  disx  = xs1*(Alat-Blat).^2;
  disy  = xs2*(Ahsc-Bhsc).^2;
  disz1 = xs3*(Ahsd-Bhsd).^2;
  disz2 = (x4*(Ahss-Bhss) + x5*(Ahsv-Bhsv)).^2;

  distance = sqrt(disx + disy + disz1 + disz2);
  