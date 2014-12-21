% function [HarmonicSpectralCentroid, HarmonicSpectralDeviation, HarmonicSpectralSpread, HarmonicSpectralVariation] = ...
% 				FharmoiParam(pic_struct)
%
% === CORRIGENDA VERSION (w4770) 2002/07/22 
%
% INPUTS:
% =======
% - pic_struct: structure .freqh_v, .amplh_lin_v
%
% OUTPUTS:
% ========
% - hsc: harmonic spectral centroid
% - hsd: harmonic spectral deviation
% - hss: harmonic spectral spread
% - hsv: harmonic spectral variation
%
% Target:   MP7-XM version
% Author:   CUIDADO/IRCAM/ G. Peeters 
% LastEdit: 2001/03/12
%

function [HarmonicSpectralCentroid, HarmonicSpectralDeviation, HarmonicSpectralSpread, HarmonicSpectralVariation] = ...
   		FharmoiParam(pic_struct)

nb_frames  = length(pic_struct);

inrg = zeros(nb_frames, 1);
iHarmonicSpectralCentroid	= zeros(nb_frames, 1);
iHarmonicSpectralDeviation	= zeros(nb_frames, 1);
iHarmonicSpectralSpread		= zeros(nb_frames, 1);
iHarmonicSpectralVariation	= zeros(nb_frames, 1);

% === Instantaneous values
for frame = 1:nb_frames
   
   freqh_v      = pic_struct(frame).freqh_v;
   amplh_lin_v  = pic_struct(frame).amplh_lin_v;
   H            = length(freqh_v);
   
   % ===== inrg
   inrg(frame) 							= sqrt(sum(amplh_lin_v(1:H).^2)); % === informatif
   % ===== ihsc
   iHarmonicSpectralCentroid(frame) = HarmonicSpectralCentroidD(freqh_v, amplh_lin_v, H);
   % ===== ihsd
   SE_lin_v    							= h_specenv(amplh_lin_v); % === informatif
   %iHarmonicSpectralDeviation(frame)= HarmonicSpectralDeviationD(log(amplh_lin_v), log(SE_lin_v), H);
   % === CORRIGENDA VERSION (w4770) 2002/07/22 
   iHarmonicSpectralDeviation(frame)= HarmonicSpectralDeviationDcorr(log(amplh_lin_v), log(SE_lin_v), H);
   % ===== ihss
   iHarmonicSpectralSpread(frame) 	= HarmonicSpectralSpreadD(freqh_v, amplh_lin_v, H);
   % ===== ihsv
   if frame > 1
      minH = min([H_old,H]);
      iHarmonicSpectralVariation(frame) = HarmonicSpectralVariationD(amplh_lin_v_old(1:minH), amplh_lin_v(1:minH), minH);
   end
   amplh_lin_v_old = amplh_lin_v;
   H_old           = H;
end

% ================


pos_v = find(inrg > max(inrg) * 0.1); % === informatif

HarmonicSpectralCentroid	= mean(iHarmonicSpectralCentroid(pos_v));
HarmonicSpectralDeviation	= mean(iHarmonicSpectralDeviation(pos_v));
HarmonicSpectralSpread		= mean(iHarmonicSpectralSpread(pos_v));
HarmonicSpectralVariation	= mean(iHarmonicSpectralVariation(pos_v));


