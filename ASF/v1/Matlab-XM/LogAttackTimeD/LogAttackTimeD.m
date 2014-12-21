% function [LogAttackTime] = mp7DLogAttackTime(envelop_bp, threshold_percent)
%
% estimate the attack start and end time of a signal envelop
% and 
% compute the log-attack-time
%
% INPUTS
% ======
% - envelop_bp        : energy envelope (first column: time [second] | second column: value)
% - threshold_percent : percentage of maximum signal energy applied in order to determine start time
% 
% OUTPUTS
% =======
% - LogAttackTime               : log-attack-time
%
% Target:   MP7-XM version
% Author:   CUIDADO/IRCAM/ G. Peeters 
% LastEdit: 2001/03/12
%

function [LogAttackTime] = mp7DLogAttackTime(envelop_bp, threshold_percent)
  
  time_v   = envelop_bp(:,1);
  energy_v = envelop_bp(:,2);
  
  % === informative
  [stopattack.value, stopattack.pos] = max(energy_v);
  threshold = stopattack.value * threshold_percent/100;
  tmp       = find(energy_v > threshold);
  startattack.pos = tmp(1);
  if (startattack.pos == stopattack.pos), startattack.pos = startattack.pos - 1;, end
  
  % === normative
  LogAttackTime = log10( ( time_v(stopattack.pos) - time_v(startattack.pos) ) );
  