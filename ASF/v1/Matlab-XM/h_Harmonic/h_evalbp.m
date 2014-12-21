% function[value] = Fevalbp(bp, t)
%
% interpolate breakpoint function bp at time t
%
% INPUTS:
% =======
% - bp : break point function
%   format [first column time | second column value]
% - t  : time
%
% OUTPUTS:
% ========
% - value : interpolated value
%
% Target:   MP7-XM version
% Author:   CUIDADO/IRCAM/ G. Peeters 
% LastEdit: 2001/03/12
%

function[value] = Fevalbp(bp, t)
  
  if length(t) ~= 1
    error('Fevalbp : length(t) ~= 1');
  end

  [minimum,pos] = min(abs(bp(:,1) - t));
  
  taille = size(bp);

  if (bp(pos,1) == t) | ...
	(taille(1) == 1) | ...
	((bp(pos,1) < t) & (pos==taille(1))) | ...
	((bp(pos,1) > t) & (pos==1))
    
    value = bp(pos,2);
    
  elseif (bp(pos,1) < t)
    
    value = (bp(pos+1,2) - bp(pos,2)) / ...
	(bp(pos+1,1) - bp(pos,1)) * ...
	(t - bp(pos,1)) + bp(pos,2);
    
  elseif (bp(pos,1) > t)
    
    value = (bp(pos,2)-bp(pos-1,2)) / ...
	(bp(pos,1) - bp(pos-1,1)) * ...
	(t - bp(pos-1,1)) + bp(pos-1,2);
    
  end
  