function edge = ASEbounds(fs,hopsize,res,samples)

% function edge = minloedge(fs,hopsize,res)
%
% This function uses the sampling frequency, fs, the hopsize (in ms) and the 
% resolution in octaves to determine the minimum loedge for the application
% with samples being a flag set to zero.
%
% if the FFT size has already been determined then hopsize may be set to the
% FFT size and the samples flag set to 1.
%
% Written by Melanie Jackson
% 28th September 2001.

if samples
    DF = fs/hopsize;
else
    windowsize = ceil(hopsize*3*fs);
    FFTsize = 2^nextpow2(windowsize);
    DF = fs/FFTsize;
end
c = 0:DF:16000;
edges = 62.5*2.^(0:res:8);

n = find((edges(1:end-1)+DF/2)>(edges(2:end)-DF/2));
found = 0;
nc = max(n);
if nc
    while ~found
        found = sum(find( ((edges(nc+1)-DF/2)<c)&(edges(nc)+DF/2)>c ) );
        nc = nc-1;
        if nc==0
            break
        end
    end
    edge = edges(nc+2);
else
    edge = 62.5;
end
