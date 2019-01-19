%% evaluate.m -- Master function to evaluate methods

function evaluate(method)

clear variables;
close all;

% Fetch folders from speech
folders = dir(fullfile('..','data','new_data','speech'));
for i=1:numel(folders)
    if folders(i).name == '.'
            row2clr = i;
            break;
    end
end
folders(row2clr) = []; folders(row2clr) = [];

num_files = size(dir(fullfile(folders(1).folder,folders(1).name,'*.wav')),1);
DOA = zeros(numel(folders),num_files,3);
SNR = zeros(1,numel(folders));
correct_azimuth = zeros(numel(folders),num_files);
correct_elevation = zeros(numel(folders),num_files);
error_azimuth = zeros(numel(folders),1);
error_elevation = zeros(numel(folders),1);

for i=1:numel(folders)
    SNR(i) = str2double(folders(i).name);
    files = dir(fullfile(folders(i).folder,folders(i).name,'*.wav'));
    load(fullfile(folders(i).folder,folders(i).name,'sourceData.mat'));
    for k = 1:numel(files)
        [data,Fs] = audioread(fullfile(files(k).folder,files(k).name));
        % Insert desired function here
        DOA(i,k,:) = method(data,Fs,varargin);
        disp(['Folder [',num2str(i),'/',num2str(numel(folders)),']']);
        disp(['File [',num2str(k),'/',num2str(numel(files)),']']);
    end
    correct_azimuth(i,:) = abs(sourceData(:,1) - DOA(i,:,1)') < 10;
    correct_elevation(i,:) = abs(sourceData(:,2) - DOA(i,:,2)') < 10;
    error_azimuth(i) = mean((sourceData(:,1) - DOA(i,:,1)').^2);
    error_elevation(i) = mean((sourceData(:,2) - DOA(i,:,2)').^2);
end

total_correct = correct_azimuth & correct_elevation;

score = sum(total_correct(:));

fprintf(strcat('\t Total Score = [',num2str(score),'/',num2str(numel(correct_azimuth)),']\n'));

figure;
title('MSE vs SNR');
subplot(2,1,1);
plot(SNR,error_azimuth);
subplot(2,1,2);
plot(SNR,error_elevation);

figure;
title('Accuracy vs SNR');
subplot(2,1,1);
plot(SNR,mean(correct_azimuth,2));
subplot(2,1,2);
plot(SNR,mean(correct_elevation,2));

end




