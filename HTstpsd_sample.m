[audio,fs]=audioread('Z:\QuailKit\audio\SM304472_0+1_20181219$100000.wav');
ch=1;
interval=[0,40];
scale=0.08;
overlap=0.8;
freqs=[0,10000,10];
samples=max(round((1-overlap)*scale*fs/2)+1,interval(1)*fs-round(scale*fs/2)+1):min(size(audio,1),interval(2)*fs+round(scale*fs/2));
signal=audio(samples,ch); % This will produce the same exact interval as the asked interval (compnesation for window size)
[s1,t,props] = HTstpsd(signal,fs,'scale',scale,'overlap',overlap,'freqs',freqs);
t1=t+samples(1)/fs;
interval=[40,80];
samples=max(round((1-overlap)*scale*fs/2)+1,interval(1)*fs-round(scale*fs/2)+1):min(size(audio,1),interval(2)*fs+round(scale*fs/2));
signal=audio(samples,ch); % This will produce the same exact interval as the asked interval (compnesation for window size)
[s2,t,props] = HTstpsd(signal,fs,'scale',scale,'overlap',overlap,'freqs',freqs);
t2=t+samples(1)/fs;
t=[t1,t2];
s=[s1,s2];
surf(t,freqs(1):freqs(3):freqs(2),db(s,'power'),'edgecolor','none');view(0,90)
