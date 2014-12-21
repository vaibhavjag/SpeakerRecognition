% function [TemporalCentroid] = mp7TemporalCentroid(envelop_bp)
%
% estimate the temporal centroid of the energy envelop
%
% INPUTS
% ======
% - envelop_bp    	: energy envelope (first column: time [second] | second column: value)
%
% OUTPUTS
% =======
% - TemporalCentroid	: temporal centroid
%
% Target:   MP7-XM version
% Author:   CUIDADO/IRCAM/ G. Peeters 
% LastEdit: 2001/03/12
%

function [TemporalCentroid] = mp7TemporalCentroid(envelop_bp)

  time_v   = envelop_bp(:,1);
  energy_v = envelop_bp(:,2);
  
  TemporalCentroid = sum( energy_v .* time_v ) / sum(energy_v);


