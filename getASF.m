instruments = {'piano';'violin';'trumpet';'flute';'bassoon';'oboe'};
asf = cell(6,75);
for inst=1:6
	for i=1:25
		DIR = strcat(pwd,'\dataset\15second\trainGMM\',instruments{inst},'\');
		filename = strcat(DIR,int2str(i),'.wav');
		disp(filename);
		[y,fs] = wavread(filename);
		[HarmonicSpectralCentroid, HarmonicSpectralDeviation, HarmonicSpectralSpread, HarmonicSpectralVariation, LogAttackTime, SpectralCentroid, TemporalCentroid] = InstrumentTimbreDS(y,fs);
		asf{inst,i} = [HarmonicSpectralCentroid, HarmonicSpectralDeviation, HarmonicSpectralSpread, HarmonicSpectralVariation, LogAttackTime, SpectralCentroid, TemporalCentroid];
	end
	for i=1:25
		DIR = strcat(pwd,'\dataset\15second\trainCodebook\',instruments{inst},'\');
		filename = strcat(DIR,int2str(i),'.wav');
		disp(filename);
		[y,fs] = wavread(filename);
		[HarmonicSpectralCentroid, HarmonicSpectralDeviation, HarmonicSpectralSpread, HarmonicSpectralVariation, LogAttackTime, SpectralCentroid, TemporalCentroid] = InstrumentTimbreDS(y,fs);
		asf{inst,i+25} = [HarmonicSpectralCentroid, HarmonicSpectralDeviation, HarmonicSpectralSpread, HarmonicSpectralVariation, LogAttackTime, SpectralCentroid, TemporalCentroid];
	end
	for i=1:25
		DIR = strcat(pwd,'\dataset\15second\test\',instruments{inst},'\');
		filename = strcat(DIR,int2str(i),'.wav');
		disp(filename);
		[y,fs] = wavread(filename);
		[HarmonicSpectralCentroid, HarmonicSpectralDeviation, HarmonicSpectralSpread, HarmonicSpectralVariation, LogAttackTime, SpectralCentroid, TemporalCentroid] = InstrumentTimbreDS(y,fs);
		asf{inst,i+50} = [HarmonicSpectralCentroid, HarmonicSpectralDeviation, HarmonicSpectralSpread, HarmonicSpectralVariation, LogAttackTime, SpectralCentroid, TemporalCentroid];
	end
end
save('asf15.mat','asf')