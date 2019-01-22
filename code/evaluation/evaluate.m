%% evaluate.m -- Master function to evaluate methods
% Inputs:
% - method    - Function handle for the method being tested
% - args      - Cell array containing any arguments the method needs
% - testType  - The type of files to test on. 
%               Current options: 'broadband_simulated' or 'speech'

function evaluate(method,args,testType)

% Fetch folders from speech
folders = dir(fullfile('..','data','new_data',testType));
if numel(folders) == 0
    error(['No folders found in dsp-cup/data/new_data/speech. If these' ...
        ' files do not exist, generate them with createData.m found in'...
        ' the dsp-cup/data directory.']);
end
for i=1:numel(folders)
    if folders(i).name == '.'
            row2clr = i;
            break;
    end
end
folders(row2clr) = []; folders(row2clr) = [];

num_files = size(dir(fullfile(folders(1).folder,folders(1).name,'*.wav')),1);
DOA = zeros(numel(folders),num_files,2);
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
        fileName = [int2str(k) '.wav'];
        [data,Fs] = audioread(fullfile(files(k).folder,fileName));
        DOA(i,k,:) = method(data,Fs,args);
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
subplot(2,1,1);
plot(SNR,error_azimuth,'-x','lineWidth',2);
title('Azimuth MSE vs SNR');
subplot(2,1,2);
plot(SNR,error_elevation,'-x','lineWidth',2);
title('Elevation MSE vs SNR');

figure;
title('Accuracy vs SNR');
subplot(2,1,1);
plot(SNR,mean(correct_azimuth,2),'-x','lineWidth',2);
title('Azimuth Accuracy vs SNR');
subplot(2,1,2);
plot(SNR,mean(correct_elevation,2),'-x','lineWidth',2);
title('Elevation Accuracy vs SNR');

end




