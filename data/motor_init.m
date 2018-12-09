% Motor data fix

close all; clear all; clc

PATH = 'individual_motors_recordings/';
NEW_PATH = 'individual_motors_cut/';
files = dir('individual_motors_recordings/*.wav');

load('cut.mat')
mkdir(NEW_PATH)
threshold = 0.008;
for k = 1:length(files)
    PATH_FILE = [PATH files(k).name];
    [y, fs] = audioread(PATH_FILE);
    y = y';
    [row col] = size(y);
    y = y(:,cut(k):length(y));
    for n = 1:col
        if abs(y(1,n)) > threshold
            x = y(:,n:length(y));
            break
        end
    end
    [row col] = size(x);
    for n = col:-1:1
        if abs(x(1,n)) > threshold
            x = x(:,1:n);
            break
        end
    end
    NEW_PATH_FILE = [NEW_PATH files(k).name];
    audiowrite(NEW_PATH_FILE, x', fs);
end