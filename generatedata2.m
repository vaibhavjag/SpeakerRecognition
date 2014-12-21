clear
clc
instruments = {'piano';'violin';'trumpet';'flute';'bassoon';'oboe'};
t1size=50;
t2size = 50;
t3size = 25;
for i=1:size(instruments,1)
    instrument = instruments{i};
    filename = strcat('D:\',instrument,'.wav');
    [SIZE,fs] = wavread(filename,'size');
    nC = SIZE(2);
    nSamples = SIZE(1);
    inc = ceil(60*fs);
    fst = 1;
    lst = fst + inc;
    outdir = strcat('D:\temp\',instrument,'\');
    j=1;
    while lst<nSamples
        outfile = strcat(outdir,int2str(j),'.wav');
        y = remove_silence(filename,fst,lst);
        if nC == 2
            y = mean(y,2);
        end
        wavwrite(y,fs,outfile);
        j = j + 1;
        fst = lst;
        lst = fst + inc;
    end
end
