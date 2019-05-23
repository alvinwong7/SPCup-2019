close all; clear all; clc

%% PATHS
addpath(fullfile('..','baseline','MBSSLocate','localization_tools'));
folder = dir(fullfile('..','data','individual_motors_cut'));
files = dir(fullfile(folder(1).folder,folder(1).name,'*.wav'));

%% PREPARING DATA
v = [];
for speed = 50:10:90
    % Add same speed motors together
    for k = 1:4
        fileName = ['Motor' num2str(k) '_' num2str(speed) '.wav'];
        [x, fs] = audioread(fullfile(folder(1).folder,fileName));
        if k == 1
           y = x;
        else
           if length(y) > length(x)
              y = y(1:length(x),:) + x;
           else
              y = y + x(1:length(y),:);
           end
        end
    end
    % Calculate the noise correlation matrix
    Xn = MBSS_stft_multi(y',1024);
    Xn = Xn(2:end,:,:);
    Rnn = MBSS_covariance(Xn);

    % Prepare feature vectors
    u = zeros(1,10);
    u(7:10) = speed;

    % Vectorising the noise correlation matrix
    for i = 1:8
        L = chol(reshape(t(i,:,:),[8, 512]));
        for j = 1:size(L)
           L(j,j) = sqrt(L(j,j)); 
        end
        v(i,(speed/10-4),:,:) = L(:);
    end
    
end

% Vectorise the noise correlation matrix by:
    % 1. Performing a Cholevsky decomposition to obtain an upper triangular
    % matrix L_t,f
    % 2. Take the square roots of diagonal elements of L_t,f and
    % concatenate the upper triangular elements of the column vectors into
    % an M(M+1)/2-dimensional vector v_t,f


    
    
% Regression result (noise correlation matrix) is the mean of the
% conditional distribution of the dependent variable v_T+1,f given the
% training data D and a newly observed feature u_T+1