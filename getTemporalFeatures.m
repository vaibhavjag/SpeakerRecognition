function [temporalFeature] = getTemporalFeatures(y,fs)
%     S1 = y(1:end-1) .* y(2:end);
% 	ind = find( S1 < 0 );
%     z = find(y == 0);
%     ind = sort([z ; ind]);
    z = zerocros(y,'r');
    zc = zerocros(y);
    zcr = size(z,1)*fs/size(y,1);
% 	temporalFeature = zeros(size(z,1)-1,2);
	attack = zeros(size(z,1)-1,1);
	decay = zeros(size(z,1)-1,1);
	for i = 1:size(z,1)-1;
		[~,I] = max(abs(y(z(i):z(i+1))));
		maxima = I+z(i);
		attack(i) = (maxima-z(i))/fs;	
		decay(i) = (z(i+1)-maxima)/fs;		
	end
	temporalFeature = [mean(attack),mean(decay),zcr];
end