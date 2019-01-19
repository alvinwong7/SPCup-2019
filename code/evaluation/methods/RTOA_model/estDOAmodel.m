%% estDOAmodel.m - Function to estimate DOA on data provided
% Estimate DOA using correlation for delay estimation, and model fitting
% method

function DOA = estDOAmodel(data,Fs,recalcModel)

% Recompute model if desired or if it doesn't exist
if recalcModel == 1
    getModel([-179 180 360],[-90 90 181],[0.1 5 50]);
elseif ~isfile('model.mat')
    getModel([],[],[]);
end

% Load model from directory, load in ground truths for static and flight
% tasks
load('model.mat');

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
[~,I] = min(SSE(:));
[~,t_min,p_min,d_min] = ind2sub(size(SSE),I);
DOA = [theta(t_min),phi(p_min),D(d_min)];

end

