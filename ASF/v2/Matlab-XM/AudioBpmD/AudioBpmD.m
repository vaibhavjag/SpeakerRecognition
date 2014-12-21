% ************************* main function **********************************************
% function [audioBpm,audioCorr,audioRel]=AudioBpmD(inFile, loLimit, hiLimit, xmlDir) ***
% **** - Tempo (Bpm) detection algorithm
% **** - Envelope extraction front end after Eric Scheirer (MIT)
% **** - ACF-based periodicity detection via forward and inverse fft (biased Autocorrelation)
% **** - input from WAV files
% **** - XML-Output. If no directory name given no XML-output
% **** - v1.0 written by Jan Rohden along MPEG output document w5212 (15938-4:2001/FPDAM)  

% **************************************************************************************
function [audioBpm,audioCorr,audioRel]=AudioBpmD(inFile, loLimit, hiLimit, xmlDir)


% ****************** Set input parameters *********************
start = 1000;
display = 1;														% Diagnostics on/of
wait_flag = 0;														% Wait after each segment on/o
click_flag = 1;													% play music plus meter-click	
xml_flag = 1;														% generate XML-Output

segtime = 4;														% Analyze 4 sec time segments(4 sec equals to HopSize = 400)
analysetime = 8;                                    	% total analyse time        

op_sys = computer;
if(strcmp(op_sys,'PCWIN'))
   file_separator = '\';
else
   file_separator = '/';
end   

if nargin > 3
	if(xmlDir(length(xmlDir))==file_separator)
   	xmlDir = xmlDir;
	else
   	xmlDir = [xmlDir,file_separator];
   end
end

si = findstr(inFile,file_separator);
file_in = inFile(si(end)+1:length(inFile));
fprintf('file_in %s\n',file_in);

%fprintf('wav-file: %s\n',[src_dir,file_in]);
fprintf('wav-file: %s\n',inFile);

%file_format = wavinfo([src_dir,file_in]);  
file_format = wavinfo(inFile);
channels = file_format(2);          						% Number of channels
fs = file_format(3);                						% Sample rate  
samples=round( analysetime *fs) + start + 1;				% file_format(7)/2/channels;
segsize = round( segtime * fs );    						% samples pro segment

if (fs > 32000),  fs=fs/2;  end

% ****** Set up conversion constants *******

df = round( fs/512 );											% decimation factor to 512 Hz
bpm2lag = 60*(fs/df);											% Conversion bpm -> lag

% ********** Set range paramters ***********
bpm_lo = loLimit;
bpm_hi = hiLimit;
lag_hi= round( bpm2lag/bpm_lo );				% LoLimit for search range
lag_lo= round( bpm2lag/bpm_hi );				% HiLimit for search range

fprintf('Tempo range: [%.0f ... %.0f]bpm = [%.0f ... %.0f] samples\n\n',bpm_lo, bpm_hi, lag_lo, lag_hi);

% ********************************************************
% ********** Prepare XML Output ********************+*****
% ********************************************************

z=length(file_in);
if nargin > 3
	xml_file = [xmlDir, file_in(1:z-4), '.xml'];
   fid_xml=fopen(xml_file,'wa');
end

% *********************************************************
% ********** Load and process one segment   ***************
% *********************************************************

deviation_vec = [];  tempo_vec = [];	audioBpm = [];	audioCorr = [];	audioRel = [];

segment = 0;
while (start+segsize < samples)
   
   segment = segment + 1;   
   
   if(display)	
		fprintf('\n\n******** Segment #%.0f, File Offset: %.0f = %.1f%% ********\n', segment, start, 100*start/samples);
   end
   
   %[sig,fs] = wavread([src_dir,file_in],[start+1 start+segsize]);
   [sig,fs] = wavread(inFile,[start+1 start+segsize]);

    
	start = start + segsize;
	
	% If stereo mixdown to mono
	if (size(sig,2) > 1),  sig = mean( sig.' ).';  end
	
	% Decimate (saves memory and time) to half of sampling rate
	if (fs > 32000), sig = decimate(sig,2);  fs=fs/2;  end

       
	% ******* calculate Envelopes and ACFs in 6 frequency Bands ************************************************************ 
   [envelopes,acfs,energies] = get_acf_and_env(sig,fs);
   % ******* calculate weighted ACF by adding bandwise ACFs weighted with bandwise reliabilty measures  *******************
   [weighted_acf,rel_m] = get_weighted_acf_and_rel(acfs,lag_lo,lag_hi);
   % ******* calculate weighted envelope by adding bandwise envelpoes weighted with bandwise reliability measures *********
   rel_weighted_envelope = get_rel_weighted_envelope(envelopes,rel_m);
   % ******* calculate ACF of weighted envelope (differs to weighted ACF !!!) *********************************************
   [acf_of_rel_weighted_envelope,spec_of_rel_weighted_envelope] = get_acf_and_spec(rel_weighted_envelope);
   % ******* calculate the average Reliabilty (mean of bandwise reliabilzy measures) **************************************
   [reliability,mean_of_rel_weighted_acf] = get_reliability(acf_of_rel_weighted_envelope,lag_lo,lag_hi);
   
   if(display)
   	figure(1);
      plot(lag_lo-20:lag_hi+20,acf_of_rel_weighted_envelope(lag_lo-20:lag_hi+20));
      title('CEACF');
      ylabel('correlation (normalized), treshold');
      xlabel('lag');
   	grid on; zoom on;
   	hold on;
   	plot(lag_lo:lag_hi,mean_of_rel_weighted_acf,'r');
      grid on; zoom on;
      	   
   	fprintf('Mean: %f  AverageReliabilty: %f\n',mean_of_rel_weighted_acf,reliability); 
   end
   
   if(display)
      figure(3);clf;
      plot(rel_weighted_envelope);
      title('weighted summerized envelope');
      ylabel('normalized amplitude');
      xlabel('time	,fs=512 Hz');
   	grid on; zoom on;
   end

   % ******* find the relevant peaks of ACF of weighted envelope within the range of periodicty interest(lag_lo:lag_hi) **
   maximum_lags = get_acfPeaks(acf_of_rel_weighted_envelope,lag_lo,lag_hi,display);
      
   % ******* define tempo regions, calculate probability for each tempo region **************
   tempo_vec = get_tempo(tempo_vec,maximum_lags,reliability,bpm2lag,segment);
   
   if(display)
      tmp = sqrt(tempo_vec(:,6));
   	figure(4); clf;
      plot(tmp,tempo_vec(:,3),'ob');
      title('Tempo Possibility');
      grid on; zoom on; hold on;
      xlabel('bpm');
      ylabel('summed weighted correlation values');
   	plot(tempo_vec(:,2),tempo_vec(:,1),'*r');
   	grid on; zoom on; 
   	hold on;
   end
   
	% ******* final tempo estimation ************************************** 
      
   [bpm,corr,index] = get_bpm(tempo_vec); 
   audioBpm = [audioBpm bpm(1)];
   audioCorr = [audioCorr corr(1)];
   audioRel = [audioRel reliability];
   
   % ******* estimation of click positions (still under construction) **** 
   
	offset = calcPeriodicEnv(floor((bpm2lag+bpm(1)/2)/bpm(1)),rel_weighted_envelope);

	if(click_flag)
      playSignalPlusClick(sig,fs,df,offset,bpm2lag/bpm(1));  
      %playSignalPlusClick(sig,fs,df,offset,maximum_lags(1,2));
   end


end
if nargin > 3
   writeXMLData(fid_xml,audioBpm,audioRel,analysetime,segtime,0);
end




% *********************************************************
% ********** prepare for cross-correlation   **************
% *********************************************************
% function offset = calcPeriodicEnv(lag,env)

function offset = calcPeriodicEnv(lag,env)

display = 0;

l = length(env);
mask = zeros(l+lag,1);
n = floor((l+lag)/lag);

for i=1:n+1
	mask((i-1)*lag+1) = 1;
	mask((i-1)*lag+2) = 1;
	mask((i-1)*lag+3) = 1;
	mask((i-1)*lag+4) = 1;
	mask((i-1)*lag+5) = 1;

end

xc = zeros(lag,1);
maximum = 0;
offset = 0;
for i=1:lag
   xc(i) = sum(env.*mask(i:l+i-1));
   if(xc(i)>maximum)
      maximum = xc(i);
      offset = i;
   end
   
   %xc(i) = sum(env*mask(i:l+i-1));
end

if(display)   
	figure(5); clf;
	plot(env);
	grid on; zoom on;
	hold on;
	plot(mask((offset):(offset)+l),'r');
	grid on; zoom on;

	figure(6); clf;
	plot(xc);
	grid on; zoom on;
end


%*** function [envs,acfs,nrgs] = get_envelopes (sig,fs)
%*** calculate seperate frequency channels vie IIR-filtering ***
%*** low-pass filtering and downsample each channel
%*** high_pass filtering leads to one envelope signal for each frequency channel

function [envs,acfs,nrgs] = get_acf_and_env(sig,fs)

envs=[];acfs=[];nrgs=[];

df = round( fs/512 );																		% decimation factor to 512 Hz

bands = [200 400 800 1600 3200 fs/2];													% Set filterbank bands

nbands = length(bands);																		% number of bands

%*********************************************
%******** Design filterbank filters **********
%*********************************************

order = 6;																						% filter order
a = zeros(nbands, order+1);																% denominator coefficients
b = zeros(nbands, order+1);																% enumerator coefficients

for bd=1:nbands
	if (bd==1)
		[bb,aa] = ellip(order,3,40,bands(bd)/(fs/2),'low'); 						% lowpass
	elseif (bd==length(bands))
		[bb,aa] = ellip(order,3,40,bands(bd-1)/(fs/2),'high');					% highpass
	else
		[bb,aa] = ellip(order/2,3,40,[bands(bd-1)/(fs/2) bands(bd)/(fs/2)]);	% bandpass
	end
	b(bd,:) = bb;  a(bd,:) = aa;
end

%*** Design smoothing filter ***
[be ae]=ellip(1,3,40,10/(fs/2),'low');													% 10 Hz low pass; could be done simpler

%**********************************************
%**bandwise filtering and envelope extraction**
%**********************************************

for bd=1:nbands
    
	%fprintf('Processing band #%.0f\n',bd);          
   sig1 = filter( b(bd,:), a(bd,:), sig);           	% bandwise filtering
   env = abs( sig1 );	                            	% rectify
   env = filter( be, ae, env );								% 10 Hz lowpass smoothing (simplified compared to Scheirer)
	env = env(1:df:length(env));								% simple subsampling  
   env = filter( [1 -1], [1 -0.85], env );				% highpass filtering (soft differentation)
	env = max( env, 0 );											% half way rectification
	env_max = max(env);
   env = env ./ env_max;										% envelope normalization
   envs = [envs env];

   fftlen = 2^ceil(log( 2*length(env) )/log(2));		% FFT size: double, power of 2
   spec = fft( env, fftlen );									% padded FFT
   acf = real( ifft( abs(spec).^2 ) );						% biased autocorrelation
   acf = acf( 1:length(env)+1 );
   nrgs = [nrgs acf(1)];										% energy of envelope	
   acf = acf ./ acf(1);											% acf normalization 
   acfs = [acfs acf];
   
 end

%*** function [envs,acfs,nrgs] = get_envelopes (sig,fs)
%*** calculate seperate frequency channels vie IIR-filtering ***
%*** low-pass filtering and downsample each channel
%*** high_pass filtering leads to one envelope signal for each frequency channel

function [envs,acfs,nrgs] = get_envelopes (sig,fs)

envs=[];acfs=[];nrgs=[];

df = round( fs/512 );																		% decimation factor to 512 Hz

bands = [200 400 800 1600 3200 fs/2];													% Set filterbank bands

nbands = length(bands);																		% number of bands

%*********************************************
%******** Design filterbank filters **********
%*********************************************

order = 6;																						% filter order
a = zeros(nbands, order+1);																% denominator coefficients
b = zeros(nbands, order+1);																% enumerator coefficients

for bd=1:nbands
	if (bd==1)
		[bb,aa] = ellip(order,3,40,bands(bd)/(fs/2),'low'); 						% lowpass
	elseif (bd==length(bands))
		[bb,aa] = ellip(order,3,40,bands(bd-1)/(fs/2),'high');					% highpass
	else
		[bb,aa] = ellip(order/2,3,40,[bands(bd-1)/(fs/2) bands(bd)/(fs/2)]);	% bandpass
	end
	b(bd,:) = bb;  a(bd,:) = aa;
end

%*** Design smoothing filter ***
[be ae]=ellip(1,3,40,10/(fs/2),'low');													% 10 Hz low pass; could be done simpler

%**********************************************
%**bandwise filtering and envelope extraction**
%**********************************************

for bd=1:nbands
    
	%fprintf('Processing band #%.0f\n',bd);          
   sig1 = filter( b(bd,:), a(bd,:), sig);           	% bandwise filtering
   env = abs( sig1 );	                            	% rectify
   env = filter( be, ae, env );								% 10 Hz lowpass smoothing (simplified compared to Scheirer)
	env = env(1:df:length(env));								% simple subsampling  
   env = filter( [1 -1], [1 -0.85], env );				% highpass filtering (soft differentation)
	env = max( env, 0 );											% half way rectification
	env_max = max(env);
   env = env ./ env_max;										% envelope normalization
   envs = [envs env];

   fftlen = 2^ceil(log( 2*length(env) )/log(2));		% FFT size: double, power of 2
   spec = fft( env, fftlen );									% padded FFT
   acf = real( ifft( abs(spec).^2 ) );						% biased autocorrelation
   acf = acf( 1:length(env)+1 );
   nrgs = [nrgs acf(1)];										% energy of envelope	
   acf = acf ./ acf(1);											% acf normalization 
   acfs = [acfs acf];
   
end


% *** function [acf,spec] = get_acf_and_spec(e)        ***
% *** calculate biased acf via forward and inverse fft *** 
% *******************************************************
function [acf,spec] = get_acf_and_spec(e)

	fftlen = 2^ceil(log( 2*length(e) )/log(2));			% FFT size: double, power of 2
   spec = fft( e, fftlen );									% padded FFT
   acf = real( ifft( abs(spec).^2 ) );
   acf = acf( 1:length(e)+1 );
   acf = acf ./ (acf(1)^1.00);								% soft normalization (?)
   acf = acf';
   
   
% function maximum_lags = get_acfPeaks(acf,lag_lo,lag_hi,display)
% ******* find the relevant peaks of ACF of weighted envelope *****
% ******* within the range of periodicty interest(lag_lo:lag_hi) **
function maximum_lags = get_acfPeaks(acf,lag_lo,lag_hi,display)
   
%acf(lag_lo:lag_hi) = acf(lag_lo:lag_hi)./max(acf(lag_lo:lag_hi));  %neu !!!

max_vec = [];
ind_vec = [];

peak = 0;

orig_lag_lo = lag_lo;
orig_lag_hi = lag_hi;

while(acf(lag_lo-1)>acf(lag_lo) & lag_lo>1)
	lag_lo = lag_lo-1;
end
 
while(acf(lag_hi+1)>acf(lag_hi) & lag_hi<length(acf))
	lag_hi = lag_hi+1;
end

min_acf_val = min(acf(lag_lo:lag_hi));

tres = mean(acf(lag_lo:lag_hi) - min_acf_val) + min_acf_val;

i=lag_lo;
while i<lag_hi
   while acf(i)<tres&i<lag_hi
      peak=0;
      i = i+1;
   end
   while acf(i)>tres&i<lag_hi
      if(acf(i)>peak)
         peak = acf(i);
         index = i;
      end
      i = i+1;
   end
   if peak>0
      max_vec = [max_vec peak];
      ind_vec = [ind_vec index-1];
   end
end

if(display)
	figure(2); clf;
	plot(30720./(170:1024),acf(170:1024));
	title('CEACF');
	grid on; zoom on;
	xlabel('bpm');
	ylabel('Correlation (normalized)');
	hold on;
	%plot(30720./(lag_lo:lag_hi),tres,'g');
	%hold on;
	%plot(30720./(lag_lo:lag_hi),min_acf_val,'r');
end    



if(size(max_vec,2)==0)
    tmp = acf(lag_lo:lag_hi);
    peak = max(tmp);
    max_vec = [max_vec peak];
    ind_vec = [ind_vec find(peak == tmp)+lag_lo-1];
end
    
maximum_lags = zeros(size(max_vec,2),2);

%max_vec = max_vec./mean(acf(lag_lo:lag_hi)) - 1;  %neu !!!

maximum_lags(:,1) = max_vec';
maximum_lags(:,2) = ind_vec';
maximum_lags(:,1) = -1.0*sort(-1.0*maximum_lags(:,1)); % sort by peak value ( max peak at begin of vector )

for i=1:size(maximum_lags,1)
   maximum_lags(i,2) = ind_vec(find(maximum_lags(i,1)==max_vec'))'+1;
end

if(display) 
	plot(30720./maximum_lags(:,2),maximum_lags(:,1),'r*');
	hold on;
	plot(30720/lag_lo,0,'b*');
	hold on;	
	plot(30720/orig_lag_lo,0,'y');
	hold on;
	plot(30720/lag_hi,0,'b*');
	hold on;
	plot(30720/orig_lag_hi,0,'y');
   grid on; zoom on;
end


         
%*** function [bpm,val,index] = get_bpm(tempo_vec)
%*** estimate correct bpm via empiric weighting
function [bpm,val,index] = get_bpm(tempo_vec)

tempo_vec(:,6) = sqrt(tempo_vec(:,6));

tempo_vec_sorted = zeros(size(tempo_vec,1),2);

tempo_vec_sorted(:,1) = -1.0*sort(-1.0*tempo_vec(:,3));

bpm = zeros(2,1);
index = 1;


for i=1:size(tempo_vec,1)
   tempo_vec_sorted(i,2) = tempo_vec(find( tempo_vec_sorted(i,1)==tempo_vec(:,3) ),6);
end


bpm(1) = tempo_vec_sorted(1,2);
val(1) = tempo_vec_sorted(1,1);

if(size(tempo_vec_sorted,1)<2)
    bpm(2) = 1.0;
    val(2) = -1.0;
else
    bpm(2) = tempo_vec_sorted(2,2);
    val(2) = tempo_vec_sorted(2,1);
end


if (tempo_vec_sorted(1,2) > 150.0 )
    bpm(1) = tempo_vec_sorted(1,2)/2;
    index = 2;
    
elseif (tempo_vec_sorted(1,2) > 80.0 & tempo_vec_sorted(1,2) < 150.0)
    if(size(tempo_vec_sorted,1)>1 & round(9.75*tempo_vec_sorted(1,2)/tempo_vec_sorted(2,2))/10.0 == 1.3)
        bpm(1) = tempo_vec_sorted(2,2);
        index = 2;
    end
    if(size(tempo_vec_sorted,1)>2 & round(9.75*tempo_vec_sorted(1,2)/tempo_vec_sorted(2,2))/10.0 == 2.6)
        bpm(1) = tempo_vec_sorted(2,3);
        index = 3;
    end


elseif( tempo_vec_sorted(1,2) < 80.0 )
    for i=1:min(size(tempo_vec_sorted,1)-1,2)
        if( tempo_vec_sorted(i+1,1)>0.7*tempo_vec_sorted(1,1) )
            
            if( tempo_vec_sorted(i+1,2) > tempo_vec_sorted(i,2) & tempo_vec_sorted(i+1,2) < 146.0 )
                fprintf('Changed Tempo from %f bpm to %f bpm !\n',tempo_vec_sorted(i,2),tempo_vec_sorted(i+1,2));
                bpm(2) = tempo_vec_sorted(i,2);
                val(2) = tempo_vec_sorted(i,1);
                bpm(1) = tempo_vec_sorted(i+1,2);
                val(1) = tempo_vec_sorted(i+1,1);
                index = i+1;
            end
        end
    end
end


% ******* function rel_w_env = get_rel_weighted_envelope(envs,rel_m) *******
% ****** summarize bandwise envelopes weighted with reliabilty measure *****
function rel_w_env = get_rel_weighted_envelope(envs,rel_m)

rel_w_env = zeros(size(envs,1),1);

for bd = 1:6
	rel_w_env = rel_w_env + envs(:,bd) * rel_m(bd);			% summarize bandwise envelopes weighted with reliabilty measure
end
    
rel_w_env = rel_w_env./max(rel_w_env);							% normalization	


% function [rel,mean_val] = get_reliability(acf,lag_lo,lag_hi)
%*** calculate reliability for each tempo estimate ***

function [rel,mean_val] = get_reliability(acf,lag_lo,lag_hi)

max_val = max(acf(lag_lo:lag_hi));
mean_val = mean(acf(lag_lo:lag_hi));

rel = max_val / mean_val - 1;


%*** function tempo_vec = get_tempo(tempo_vec,max_lags,rel,bpm2lag,segNum)
%*** dynamic histogramming of significant tempo information ****

function tempo_vec = get_tempo(tempo_vec,max_lags,rel,bpm2lag,segNum)

display = 0;								% diagnostic printing enabled/disabled

if(segNum > 1)

index = zeros(size(max_lags,1),1);
count_1 = 0;
for i=1:size(max_lags,1)
    deviation = zeros(size(tempo_vec,1),1);
    for j=1:size(tempo_vec,1)
        deviation(j) = (bpm2lag/max_lags(i,2))/sqrt(tempo_vec(j,6))-1;
    end
    %deviation
    tmp_index = find(min(abs(deviation))==abs(deviation));
    %i
    %tmp_index
    index(i) = tmp_index(1);
    %index
    if(abs(deviation(index(i)))>0.05)   %0.1
        count_1 = count_1 +1;
        index(i)=size(tempo_vec,1)+count_1;
        %fprintf('New Tempo in Vector %f %f %f\n',index(i),size(tempo_vec,1),count_1);
    end
end 

count = 0;
if(0)
for i=1:length(index)
    for(j=i+1:length(index))
        if(index(i)==index(j))
            count = count +1;
            if(abs(deviation(index(i)))>abs(deviation(index(j))));
                index(i)= length(index)-count;
            end
        end
    end
end
end


    
else
    index = zeros(size(max_lags,1),1);
    for i=1:size(max_lags,1)
        index(i) = i;
    end
end


for i=1:size(max_lags,1)
    if(index(i)>size(tempo_vec,1))
        tempo_vec(index(i),3) = 0.0;
        tempo_vec(index(i),4) = 0.0;
        tempo_vec(index(i),5) = 0.0;
        tempo_vec(index(i),6) = 0.0;
        tempo_vec(index(i),7) = 0.0;
        
    end
    
    tempo_vec(index(i),1) = max_lags(i,1);    
        
    tempo_vec(index(i),2) = bpm2lag/max_lags(i,2);
    
    tempo_vec(index(i),3) = tempo_vec(index(i),3) + ((tempo_vec(index(i),1))*rel);
        
    tempo_vec(index(i),4) = tempo_vec(index(i),4) + tempo_vec(index(i),2);
    
    tempo_vec(index(i),5) = tempo_vec(index(i),5) + 1;

    tempo_vec(index(i),6) = tempo_vec(index(i),4)/tempo_vec(index(i),5)*tempo_vec(index(i),4)/tempo_vec(index(i),5);
    
    tempo_vec(index(i),7) = tempo_vec(index(i),4)/segNum;

    %index(i)
   
end

if(display)
	for i=1:size(tempo_vec,1)
		fprintf('V1[%d]: %f \t',i,tempo_vec(i,1) );
  		fprintf('V2[%d]: %f \n',i,tempo_vec(i,2) );
		fprintf('V3[%d]: %f \t',i,tempo_vec(i,3) );
		fprintf('V6[%d]: %f \n',i,sqrt(tempo_vec(i,6)) );   
	end
end


% ***************************************************************************
% function [weighted_acf,rel_m]=get_weighted_acf_and_rel(acf,lag_lo,lag_hi) *
% ******** Compute combined ACF *********************************************
function [weighted_acf,rel_m]=get_weighted_acf_and_rel(acf,lag_lo,lag_hi)

  	
   rel_m = [];  
   tmp=[];
   weighted_acf = zeros(1,size(acf,1));
   
   for bd = 1:6
     	tmp = acf(lag_lo+1:lag_hi+1,bd);									% subsequent calculations only within periodicity range of interest	
     	rel_m(bd) = (max(tmp) / mean(tmp) - 1) ^ 1.0;						% calculate reliability measure for each band
		weighted_acf = weighted_acf + acf(:,bd)' * rel_m(bd);    	% per band reliability weightin       
   end
   
   
   weighted_acf = weighted_acf ./ (weighted_acf(1)^1.00);					% soft normalization (?)
	  
     
     
% **** function playSignalPlusClick(sig,fs,df,offset,maxLag) ****
function playSignalPlusClick(sig,fs,df,offset,maxLag)

		click = 0.9 * hanning( 8 );	
    	lclick = length(click);
    
    	sig_low = 0.1 * sig;
   
   	i=0; 
    	o=1;
    	while (o<length(sig_low)-df*maxLag-lclick)
      	o=round(df*(offset+i*maxLag));
        	sig_low(o:o+lclick-1) = sig_low(o:o+lclick-1) + click;
        	i=i+1;
    	end    
      
    	while (1)
	   	sound(sig_low,fs);			
        	key = input('Press <n> to continue with next segment: ','s');
	    	if (strcmp(upper(key),'N') ),  break,  end
    	end
    
       
% **** function writeXMLData(fid,bpm,rel,analysetime,segtime,weight_flag) ****
function writeXMLData(fid,bpm,rel,analysetime,segtime,weight_flag)

%fprintf('Write out %s\n',xml_file);

weight = rel./max(rel);

cnt = analysetime/segtime;

hopSize = segtime*100;

fprintf( fid, '<AudioDescriptor xsi:type="AudioTempoType" loLimit="60" hiLimit="140" hopSize="%d">\n', hopSize );
fprintf( fid, '  <SeriesOfScalar totalSampleNum="%d">\n', cnt );

fprintf( fid, '    <Raw> ' );
for i=1:length(bpm)
   fprintf(fid,'%3.2f\t',bpm(i));
end
fprintf(fid,'    <raw>\n');

if(weight_flag)
   fprintf(fid,'    <weight> ');
   for i=1:length(weight)
      fprintf(fid,'%1.2f\t',weight(i));
   end
   fprintf(fid,'    <weight>\n');
end

fprintf( fid, '  </SeriesOfScalar>\n' );
fprintf( fid, '</AudioDescriptor>\n' );

fclose(fid);
	       
    
    
    
