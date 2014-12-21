clc;
clear;
[piano,fs1] = wavread('D:\piano.wav',[1 1000000]);
[piano1,fs2] = wavread('D:\piano.wav',[1000001 1110250]);
[piano2,fs3] = wavread('D:\piano.wav',[2000001 2110250]);
[violin,fs4] = wavread('D:\violin.wav',[1 1000000]);
[violin1,fs5] = wavread('D:\violin.wav',[1000001 1110250]);
[violin2,fs6] = wavread('D:\violin.wav',[2000001 2110250]);
[trumpet,fs7] = wavread('D:\trumpet1.wav',[1 1000000]);
[trumpet1,fs8] = wavread('D:\trumpet1.wav',[1000001 1110250]);
[trumpet2,fs9] = wavread('D:\trumpet1.wav',[2000001 2110250]);


piano = (piano(:,1) + piano(:,2))/2;
piano1 = (piano1(:,1) + piano1(:,2))/2;
piano2 = (piano2(:,1) + piano2(:,2))/2;
violin = (violin(:,1) + violin(:,2))/2;
violin1 = (violin1(:,1) + violin1(:,2))/2;
violin2 = (violin2(:,1) + violin2(:,2))/2;
trumpet = (trumpet(:,1) + trumpet(:,2))/2;
trumpet1 = (trumpet1(:,1) + trumpet1(:,2))/2;
trumpet2 = (trumpet2(:,1) + trumpet2(:,2))/2;


piano_features = getFeatures(piano,fs1);
piano1_features = getFeatures(piano1,fs2);
piano2_features = getFeatures(piano2,fs3);
violin_features = getFeatures(violin,fs4);
violin1_features = getFeatures(violin1,fs5);
violin2_features = getFeatures(violin2,fs6);
trumpet_features = getFeatures(trumpet,fs7);
trumpet1_features = getFeatures(trumpet1,fs8);
trumpet2_features = getFeatures(trumpet2,fs9);

[piano_mfcc_m,piano_mfcc_v,piano_mfcc_w,gp,~,~,~] = gaussmix(piano_features,[],[],1,'vhp');
[violin_mfcc_m,violin_mfcc_v,violin_mfcc_w,gv,~,~,~] = gaussmix(violin_features,[],[],1,'vhp');
[trumpet_mfcc_m,trumpet_mfcc_v,trumpet_mfcc_w,gv,~,~,~] = gaussmix(trumpet_features,[],[],1,'vhp');

model = {{piano_mfcc_m,piano_mfcc_v,piano_mfcc_w};{violin_mfcc_m,violin_mfcc_v,violin_mfcc_w};{trumpet_mfcc_m,trumpet_mfcc_v,trumpet_mfcc_w}};

save('model.mat','model')

disp('Piano 1 ----');
p = getClassification(piano1_features,model);
disp(strcat('piano probabilty : ',mat2str(p(1))));
disp(strcat('violin probabilty : ',mat2str(p(2))));
disp(strcat('trumpet probabilty : ',mat2str(p(3))));

disp('Piano 2 ----');
p = getClassification(piano2_features,model);
disp(strcat('piano probabilty : ',mat2str(p(1))));
disp(strcat('violin probabilty : ',mat2str(p(2))));
disp(strcat('trumpet probabilty : ',mat2str(p(3))));

disp('Violin 1 ----');
p = getClassification(violin1_features);
disp(strcat('piano probabilty : ',mat2str(p(1))));
disp(strcat('violin probabilty : ',mat2str(p(2))));
disp(strcat('trumpet probabilty : ',mat2str(p(3))));

disp('Violin 2 ----');
p = getClassification(violin2_features,model);
disp(strcat('piano probabilty : ',mat2str(p(1))));
disp(strcat('violin probabilty : ',mat2str(p(2))));
disp(strcat('trumpet probabilty : ',mat2str(p(3))));

disp('Trumpet 1 ----');
p = getClassification(trumpet1_features,model);
disp(strcat('piano probabilty : ',mat2str(p(1))));
disp(strcat('violin probabilty : ',mat2str(p(2))));
disp(strcat('trumpet probabilty : ',mat2str(p(3))));

disp('Trumpet 2 ----');
p = getClassification(trumpet2_features,model);
disp(strcat('piano probabilty : ',mat2str(p(1))));
disp(strcat('violin probabilty : ',mat2str(p(2))));
disp(strcat('trumpet probabilty : ',mat2str(p(3))));


clearvars -except model axe;



