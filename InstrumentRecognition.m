%% collect data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Convert Youtube Videos to audio wav files.
%  Create 3 databases for samples of length 5s , 10s, 15s
%% extract features %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Preprocessing
%  Segment each sample into overlapping frames. Try using enframes from voicebox or write a script to do it 
%% MFCC
%  Use voicebox to get MFCC, Delta MFCC, Delta-Delta MFCC
%% ASF
%  Use Experimental ASF code to obtain ASF Features
%% Other Features
%
%% Machine Learning %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Preprocessing
%  Split the data into training1, training2, and testing data (Use K-fold
%  Cross-Validation on the training data or overall?)
%% GMM for individual codebooks (Using training1 data)
%  Obtain intial values through k-means
%  Perform EM to get GMMs
%  Identify Classes as instruments
%% Weighting codebooks (Using training2 data)
%  
%% Testing
%  Test the models on unseen testing data (also check results on training data again) and report the results
%%