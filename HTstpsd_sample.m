[audio,fs]=audioread('C:\Users\joggl\Texas Tech University\Quail Call - Recordings\SM304472_0+1_20181004$110000.wav');
ch=1;
interval=[120,130];
scale=0.08;
overlap=0.8;
freqs=[0,10000,10];
signal=audio(interval(1)*fs-floor(scale*fs/2)+1:interval(2)*fs+floor(scale*fs/2),ch); % This will produce the same exact interval as the asked interval (compnesation for window size)
[s,t,props] = HTstpsd(signal,fs,'scale',scale,'overlap',overlap,'freqs',freqs);
t=t+interval(1)+(1-floor(scale*fs/2))/fs;
surf(t,freqs(1):freqs(3):freqs(2),db(s,'power'),'edgecolor','none');view(0,90)
