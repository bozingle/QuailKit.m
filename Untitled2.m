obj = JR_Data(fullfile('Z:','QuailKit','audio','SM304472_0+1_20181219$102500.wav'),fullfile('Z:','QuailKit','data','SM304472_0+1_20181219$102500.h5'),40,0:10:10000,0.8);    
[s1,f1,t1]=obj.get(50,100,'spgram','1');
f2=0:10:10000;
noverlap = (round(0.8*0.1*obj.scale*obj.audiofs));
window = round(0.1*obj.scale*obj.audiofs);
audio=audioread(fullfile('Z:','QuailKit','audio','SM304472_0+1_20181219$102500.wav'));
audio=zscore(audio(:,1));
[s2,~,t2] = spectrogram(audio(50*obj.audiofs:100*obj.audiofs),window,...
    noverlap,f2,obj.audiofs);
s2 = db(abs(s2'));