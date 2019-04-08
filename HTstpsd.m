function [s,t,props] = HTstpsd(x,fs,varargin)
%HTstpsd wrapper for MATLAB's spectrogram function
%   inputs:
%       x: signal to calculate spectrogram for.
%       fs: sampling frequency of signal
%       scale: the larger the lower the temporal resolution.
%       overlap: STFT window overlap relative to window size.
%       freqs: frequencies to calculate STFT for.
%   outputs:
%       s: STPSD (short-time power spectral density).
%       t: time values of the STPSD.
%       props: properties of what is contained in s for later use.

% © 2019 Hanif Tiznobake

defaultWindow = 'Hamming';
defaultScale = 0.08;
defaultOverlap = 0.8;
defaultFreqs = 0:10:10000;

p = inputParser;
validOverlap = @(x) isnumeric(x) && (x >= 0) && (x < 1);
validScale = @(x) isnumeric(x) && (x > 0) && (x < 1);
validFreqs = @(x) isnumeric(x) && length(x)==3;
addParameter(p,'window',defaultWindow,@ischar);
addParameter(p,'scale',defaultScale,validScale);
addParameter(p,'overlap',defaultOverlap,validOverlap);
addParameter(p,'freqs',defaultFreqs,validFreqs);
parse(p,varargin{:});

freqs=p.Results.freqs;
window = round(p.Results.scale*fs);
noverlap = round(p.Results.overlap*p.Results.scale*fs);
[~,~,t,s] = spectrogram(x,window,noverlap,freqs(1):freqs(3):freqs(2),fs);
props=struct(...
    'data','STPSD',...
    'window','Hamming',...
    'scale',p.Results.scale,...
    'overlap',p.Results.overlap,...
    'fs',1/(t(2)-t(1)),...
    'freqs',freqs,...
    't0',round((2-p.Results.overlap)*p.Results.scale*fs/2)/fs);

end

