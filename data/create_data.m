% Creates data at specific SNRs

close all; clear all; clc

%% Toggles & Parameters
% Toggles

white_noise = 0;
speech = 0;

[y1, fs] = audioread('individual_motors_recordings/Motor1_50.wav');
% [y2, fs] = audioread('individual_motors_recordings/Motor2_50.wav');
% [y3, fs] = audioread('individual_motors_recordings/Motor3_50.wav');
% [y4, fs] = audioread('individual_motors_recordings/Motor4_50.wav'); 
[y5, fs] = audioread('dev_static/audio/1.wav');

n = 1;
[row col] = size(y1);
y0 = zeros(1,length(y1));
for n = 1:col
    y0 = y0 + y1(:,n)';
end
y1 = y0(202000:length(y0));
for n = 1:length(y1)
    if abs(y1(n)) > 0.02
        x = y1(n:length(y1));
        break
    end
end
n = length(x);
while n > 1
    n = n - 1;
    if abs(x(n)) > 0.02
        x = x(1:n);
        break
    end
end
plot(x)


% subplot(2,2,1)
% plot(y1)
% subplot(2,2,2)
% plot(y2)
% subplot(2,2,3)
% plot(y3)
% subplot(2,2,4)
% plot(y4)
% figure
% plot(y5)
% size1 = floor(length(y1)/2);
% size2 = floor(length(y2)/2);
% y1 = y1';
% y2 = y2';
% y3 = y3';
% y4 = y4';
% y5 = y5';
% y5 = y5 + y1(:,size1:size1+length(y5)-1) + y2(:,size2:size2+length(y5)-1) +...
%         y3(:,size2:size2+length(y5)-1) + y4(:,size2:size2+length(y5)-1);
% y5 = y5';