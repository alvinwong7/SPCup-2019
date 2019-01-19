%% motorInit.m - Function to crop the individual motor recordings to
%                consist of only the motor sound, removing any silence and
%                initial motor start up noises

close all; clear all; clc

%% PATHS
% PATH - path to current motor recordings
% NEW_PATH - desired path of cropped motor recordings (NOTE: it will create
% a new folder if the destination does not exist
PATH = 'individual_motors_recordings/';
NEW_PATH = 'individual_motors_cut/';

%% MOTOR RECORDING CUT
files = dir('individual_motors_recordings/*.wav');
mkdir(NEW_PATH)
load('cut.mat')
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