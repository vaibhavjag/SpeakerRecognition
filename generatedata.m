clear
clc
instruments = {'piano';'violin';'trumpet';'flute';'bassoon';'oboe'};
for i=1:size(instruments,1)
    instrument = instruments{i};
    CWD = strcat(pwd,'\SpeakerRecognition\dataset\');
    DIR = strcat('second\trainGMM\',instrument,'\');
    t1size=25;
    t2size = 25;
    t3size = 25;
    filename = strcat('D:\inst\',instrument,'.wav');
    [SIZE,fs] = wavread(filename,'size');
    nC = SIZE(2);
    nSamples = SIZE(1);
    for i = 1:t1size
        for seconds = 5:5:15
            inc = ceil(seconds*fs);
            fst = (i)*inc;
            lst = fst+inc;
            y = wavread(filename,[fst lst]);
            if nC == 2
                y = mean(y,2);
            end
            outfile = strcat(CWD,int2str(seconds),DIR,int2str(i),'.wav');
            disp(outfile);
            wavwrite(y,fs,outfile);
        end
    end
    DIR = strcat('second\trainCodebook\',instrument,'\');
    for i = 1:t2size
        for seconds = 5:5:15
            inc = ceil(seconds*fs);
            fst = (t1size+i)*inc;
            lst = fst+inc;
            y = wavread(filename,[fst lst]);
            if nC == 2
                y = mean(y,2);
            end
            outfile = strcat(CWD,int2str(seconds),DIR,int2str(i),'.wav');
            wavwrite(y,fs,outfile);
            disp(outfile);
        end
    end
    DIR = strcat('second\test\',instrument,'\');
    for i = 1:t3size
        for seconds = 5:5:15
            inc = ceil(seconds*fs);
            fst = (t1size+t2size+i)*inc;
            lst = fst+inc;
            y = wavread(filename,[fst lst]);
            if nC == 2
                y = mean(y,2);
            end
            outfile = strcat(CWD,int2str(seconds),DIR,int2str(i),'.wav');
            disp(outfile);
            wavwrite(y,fs,outfile);
        end
    end    
end
    