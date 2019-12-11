filename= "C:\Users\Joel\Desktop\download.jpg"%"C:\Users\Joel\Desktop\stuffs\RecordData\10-13\Mics\s!SM304472_0+1_20191013_061500.wav"; %Mics{k,3}
img = rgb2gray(imread(filename));
Y = fft2(img);
imagesc(abs(fftshift(Y)))

% [raw,fs]=audioread(filename);
% window = 0.3;
% n = round(0.1*window*fs);
% F = 1000:10:3000;
% fn = fs/2;
% x = bandpass(raw(:,1),[1000/fn 3000/fn]);
% [s1, ~, t] = spectrogram(x,n,round(0.8*n),F,fs);
% 
% % [s2, ~, t] = spectrogram(raw(:,2),n,round(0.8*n),F,fs);
% 
% spectrogram(x,n,round(0.8*n),F,fs,'yaxis');