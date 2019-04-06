obj = JR_Data('C:\Users\joggl\Texas Tech University\Quail Call - Recordings\SM304472_0+1_20181004$110000.wav','C:\Users\joggl\Desktop\Academics\test h5\SM304472_0+1_20181219$102500.h5',40,0:10:10000,0.8);    
[s1,f1,t1]=obj.get(40,80,'spgram','1');
f2=0:10:10000;
noverlap = (round(0.8*0.1*obj.scale*obj.audiofs));
window = round(0.1*obj.scale*obj.audiofs);
audio=audioread('C:\Users\joggl\Texas Tech University\Quail Call - Recordings\SM304472_0+1_20181004$110000.wav');
audio=zscore(audio(:,1));
[s2,~,t2] = spectrogram(audio(floor(0*obj.audiofs)+1:floor(40*obj.audiofs)),window,...
    noverlap,f2,obj.audiofs);
s2 = db(abs(s2'));
t2 = t2;