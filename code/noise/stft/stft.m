% Displays one or multiple spectrogram(s) for a specified file

close all; clear all; clc

%% Toggles & Parameters
% Toggles
%   allMic - toggle spectrogram display between one(!1) or all(1) microphone(s)
allMic = 0;

% Parameters
% Default values:
%   windowsize = 1024
%   window = hanning(windowsize)
%   nfft = windowsize
%   noverlap = windowsize/2
[y, fs] = audioread('../data/static_task/audio/1.wav');
windowsize = 1024;
window = hanning(windowsize);
nfft = windowsize;
noverlap = windowsize/2;

%% Spectrogram Display
t = 1/fs:1/fs:length(y)*(1/fs);
y = y';
figure;
if allMic == 1
    n = 1;
    [row col] = size(y);
    for n = 1:row
        subplot(4,2,n)
        spectrogram(y(n,:),window,noverlap,nfft,fs,'yaxis')
        xlabel('Time (secs)')
        ylabel('Freq (kHz)')
        title('Short-time Fourier Transform spectrum')
    end
else
    spectrogram(y(1,:),window,noverlap,nfft,fs,'yaxis')
    xlabel('Time (secs)')
    ylabel('Freq (kHz)')
    title('Short-time Fourier Transform spectrum')
end