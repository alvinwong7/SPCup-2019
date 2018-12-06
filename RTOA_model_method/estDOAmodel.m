%% estDOAmodel.m - Script to estimate DOA on flight
% Estimate DOA using correlation for delay estimation, and model fitting
% method 

clear variables;
close all;

% Set this to 1 if you wish to recompute the model
recalcModel = 0;

% Recompute model if desired or if it doesn't exist
if recalcModel
    getModel([-179 180 360],[-90 90 181],[0.1 5 50]);
elseif ~isfile('model.mat')
    getModel([],[],[]);
end

% Load model from directory, load in ground truths for static and flight
% tasks
load('model.mat');

% Set static for static task, indicates the file number to test, n
% indicates which window if testing dynamic data
mode = 'static'; fileNum = 3; n = 12; 
parentdir = fileparts(pwd);
if strcmp(mode,'static')
    [data, Fs] = audioread(fullfile(parentdir,'data','dev_static','audio',strcat(int2str(fileNum),'.wav')));
    load(fullfile(parentdir,'data','dev_static','SPCUP19_dev_static.mat'));
else
    [data, Fs] = audioread(fullfile(parentdir,'data','dev_flight','audio',strcat(int2str(fileNum),'.wav')));
    load(fullfile(parentdir,'data','dev_flight','SPCUP19_dev_flight.mat'));
    data = data(0.5*Fs*((n-1)/2) + 1:0.5*Fs*((n-1)/2+1),:).*hamming(0.5*Fs);
end

% Compute relative times of arrival
RTOA = zeros(7,1);
for i = 1:7
    [xcf,lags] = xcorr(data(:,i+1),data(:,1),50);
    [~,max_idx] = max(xcf);
    RTOA(i) = lags(max_idx);
end

% Find best match (with a p metric cost function).
p_metric = 2;
SSE = sum((Fs*model-RTOA).^p_metric).^(1/p_metric);
[MIN_SSE,I] = min(SSE(:));
[~,t_min,p_min,d_min] = ind2sub(size(SSE),I);
pos = [theta(t_min),phi(p_min),D(d_min)];

% Get result error
if strcmp(mode,'static')
    err = [(pos(1) - static_azimuth(fileNum)) (pos(2) - static_elevation(fileNum))];
else
    err = [(pos(1) - broadband_azimuth(fileNum,n)) (pos(2) - broadband_elevation(fileNum,n))];
end

