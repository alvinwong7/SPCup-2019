% Creates data at specific SNRs

close all; clear all; clc

%% TOGGLES
% Toggles
% speech - toggles simulated source speech creation
% broadband - toggles broadband data creation
% simulated_source - toggles between simulated source creation using
    % broadband data (1) and non-simulated source creation (0)
% snrRange - toggles between varying snr between 2 numbers (1)
    % (e.g. [5 8] will create SNRs 5 to 8 by some increment specified by
    % snrIncrement) and only creating specified SNR values (0) (e.g. [5 8]
    % will only create +5, and +8 SNRs)
% snrIncrement - 
speech = 1;
broadband = 1;
simulate_source = 1;
snrRange = 1;
snrIncrement = 4;

%% SETTINGS
% speakerNum specifies the amount of speakers to simulate
% filesPerSpeaker specifies the amount of files to simulate per speaker
% speakerNum and filesPerSpeaker maximum is 10
speakerNum = 10;
filesPerSpeaker = 2;

% brdbndNum affects the number of static white noise source files to use as a
% base for simulation. max value is 3.
% filesPerSource specifies the number of files to generate per base file.
% max value is 10.
brdbndNum = 3;
filesPerSource = 5;

% snrs is a list of the SNR's you wish to generate the files at.
% alternatively use snrrange = 1 (see above) to generate vary SNR between 
% 2 given values by some increment defined by snrIncrement
% motorSpeed is the speed of the motors used to generate the simulated
% files.
snrs = [-25 15];
motorSpeed = 50;

%% CHECK SETTINGS
if snrRange == 1 && length(snrs) == 2
    if snrIncrement == 0
        msg = 'Error (line 20): snrRange is TRUE but snrIncrement is ZERO, must be greater than ONE';
        error(msg)
    end
    snrs = sort(snrs);
    i = 1;
    for snr = snrs(1):snrIncrement:snrs(2)
        snrs(i) = snr;
        i = i + 1;
    end
elseif snrRange == 1 && length(snrs) ~= 2
    msg = 'Error (line 15/36): snrRange is TRUE and requires only TWO values in snrs setting';
    error(msg)
end
validMotorSpeeds = [50 60 70 80 90];
if ~ismember(motorSpeed, validMotorSpeeds)
    msg = 'Error (line 42): motorSpeed is invalid, must be 50, 60, 70, 80 or 90';
    error(msg)
end
if speech && (speakerNum < 1 || speakerNum > 10)
    msg = 'Error (line 26): speakerNum value is invalid, must be 1-10';
    error(msg)
end
if speech && (filesPerSpeaker < 1 || filesPerSpeaker > 10)
    msg = 'Error (line 27): filesPerSpeaker value is invalid, must be 1-10';
    error(msg)
end
if broadband && simulate_source && (brdbndNum < 1 || brdbndNum > 3)
    msg = 'Error (line 33): brdbndNum value is invalid, must be 1-3';
    error(msg)
end
if broadband && simulate_source && (filesPerSource < 1 || filesPerSource > 8)
    msg = 'Error (line 34): filesPerSource value is invalid, must be 1-8';
    error(msg)
end

%% PATHS
% Path to save new data
PATH = 'new_data/';

%% Generate files

if speech 
    PATH_SOURCE = 'clean_speech_mono/speech/';
    PATH_NEW_DATA = [PATH 'speech/'];
    mkdir(PATH)
    mkdir(PATH_NEW_DATA)
    c = 34300;
    % The (X,Y,Z) positions of the 8 microphones, in meters, 
    % with respect to the center of the array are given below:
    micPos = 100*[0.0420   0.0615  -0.0410;  % mic 1
             -0.0420   0.0615   0.0410;  % mic 2
             -0.0615   0.0420  -0.0410;  % mic 3
             -0.0615  -0.0420   0.0410;  % mic 4
             -0.0420  -0.0615  -0.0410;  % mic 5
              0.0420  -0.0615   0.0410;  % mic 6
              0.0615  -0.0420  -0.0410;  % mic 7
	          0.0615   0.0420   0.0410]; % mic 8
    delay = zeros(1,8);
    for i = 1:length(snrs)
        PATH_FILE = [PATH_NEW_DATA int2str(snrs(i)) '/'];
        mkdir(PATH_FILE)
        PATH_SOURCE_DATA = [PATH_FILE 'sourceData.mat'];
        if exist('sourceData', 'var') == 1
            clearvars sourceData
        end
        if isfile(PATH_SOURCE_DATA)
            load(PATH_SOURCE_DATA)
        end
        for file = 1:speakerNum
            fileNum = 1;
            PATH_SPEAKER = [PATH_SOURCE 'Speaker' int2str(file) '/'];
            speechFiles = dir([PATH_SPEAKER '*.WAV']);
            for j = 1:filesPerSpeaker
                PATH_AUDIO = [PATH_SPEAKER speechFiles(j).name];
                [y, fs] = audioread(PATH_AUDIO);
                % distance in cm
                theta = -180 + (179 + 180).*rand(1,1);
                phi = -45 + 45.*rand(1,1);
                d = 100 + (1000-100).*rand(1,1);
                if exist('sourceData', 'var') == 1
                    sourceData = [sourceData; theta phi];
                else
                    sourceData = [theta phi];
                end
                cart = [d*cos(theta*pi/180)*cos(phi*pi/180) d*sin(theta*pi/180)*cos(phi*pi/180) d*sin(phi*pi/180)];
                for k = 1:8
                    delay(k) = norm(cart - micPos(k,:))/c;
                end
                delaySampled = round(delay*16*fs);
                yResampled = resample(y,16,1);
                % Largest delay shift
                maxDelay = max(delaySampled);
                minDelay = min(delaySampled);
                clearvars delayedY
                for k = 1:8
                    Y_temp = [zeros(delaySampled(k),1); yResampled];
                    delayedY(:,k) = Y_temp(maxDelay:length(yResampled)+minDelay);
                end
                y = resample(delayedY,441,2560);
                noise = mixMotorNoise(y,motorSpeed);
                noise = (noise/norm(rms(noise)))*(norm(rms(y))/10.0^(0.05*snrs(i)));
                mixed = y + noise;
                mixed = mixed/max(max(abs(mixed)));
                while 1
                    fileName = [PATH_FILE int2str(fileNum) '.wav'];
                    fileNum = fileNum + 1;
                    if ~isfile(fileName)
                        audiowrite(fileName,mixed,44100);
                    break
                    end
                end
            end
        end
        save(PATH_SOURCE_DATA, 'sourceData')
    end
end

if broadband && simulate_source
    PATH_SOURCE = 'dev_static/audio';
    PATH_NEW_DATA = [PATH 'broadband_simulated/'];
    mkdir(PATH);
    mkdir(PATH_NEW_DATA);
    c = 34300;
    % The (X,Y,Z) positions of the 8 microphones, in meters, 
    % with respect to the center of the array are given below:
    micPos = 100*[0.0420   0.0615  -0.0410;  % mic 1
             -0.0420   0.0615   0.0410;  % mic 2
             -0.0615   0.0420  -0.0410;  % mic 3
             -0.0615  -0.0420   0.0410;  % mic 4
             -0.0420  -0.0615  -0.0410;  % mic 5
              0.0420  -0.0615   0.0410;  % mic 6
              0.0615  -0.0420  -0.0410;  % mic 7
	          0.0615   0.0420   0.0410]; % mic 8
    delay = zeros(1,8);
    for i = 1:length(snrs)
        PATH_FILE = [PATH_NEW_DATA int2str(snrs(i)) '/'];
        mkdir(PATH_FILE)
        PATH_SOURCE_DATA = [PATH_FILE 'sourceData.mat'];
        if exist('sourceData', 'var') == 1
            clearvars sourceData
        end
        if isfile(PATH_SOURCE_DATA)
            load(PATH_SOURCE_DATA)
        end
        for file = 1:brdbndNum
            fileNum = 1;
            PATH_AUDIO = [PATH_SOURCE '/' int2str(file) '.wav'];
            [source, fs] = audioread(PATH_AUDIO);
            for j = 1:filesPerSource
                y = source(:,j);
                % distance in cm
                theta = -180 + (179 + 180).*rand(1,1);
                phi = -45 + 45.*rand(1,1);
                d = 100 + (1000-100).*rand(1,1);
                if exist('sourceData', 'var') == 1
                    sourceData = [sourceData; theta phi];
                else
                    sourceData = [theta phi];
                end
                cart = [d*cos(theta*pi/180)*cos(phi*pi/180) d*sin(theta*pi/180)*cos(phi*pi/180) d*sin(phi*pi/180)];
                for k = 1:8
                    delay(k) = norm(cart - micPos(k,:))/c;
                end
                delaySampled = round(delay*16*fs);
                yResampled = resample(y,16,1);
                % Largest delay shift
                maxDelay = max(delaySampled);
                minDelay = min(delaySampled);
                clearvars delayedY
                for k = 1:8
                    Y_temp = [zeros(delaySampled(k),1); yResampled];
                    delayedY(:,k) = Y_temp(maxDelay:length(yResampled)+minDelay);
                end
                y = resample(delayedY,1,16);
                noise = mixMotorNoise(y,motorSpeed);
                noise = (noise/norm(rms(noise)))*(norm(rms(y))/10.0^(0.05*snrs(i)));
                mixed = y + noise;
                mixed = mixed/max(max(abs(mixed)));
                while 1
                    fileName = [PATH_FILE int2str(fileNum) '.wav'];
                    fileNum = fileNum + 1;
                    if ~isfile(fileName)
                        audiowrite(fileName,mixed,44100);
                    break
                    end
                end
            end
        end
        save(PATH_SOURCE_DATA, 'sourceData')
    end
end

if broadband && simulate_source == 0
    PATH_SOURCE = 'dev_static/audio/';
    PATH_NEW_DATA = [PATH 'broadband_real/'];
    mkdir(PATH);
    mkdir(PATH_NEW_DATA);
    whiteNoiseFiles = dir('dev_static/audio/*.wav');
    for i = 1:length(snrs)
        fileNum = 1;
        PATH_FILE = [PATH_NEW_DATA int2str(snrs(i)) '/'];
        mkdir(PATH_FILE)
        for j = 1:length(whiteNoiseFiles)
            PATH_AUDIO = [PATH_SOURCE whiteNoiseFiles(j).name];
            [y, fs] = audioread(PATH_AUDIO);
            noise = mixMotorNoise(y,motorSpeed);
            noise = (noise/norm(rms(noise)))*(norm(rms(y))/10.0^(0.05*snrs(i)));
            mixed = y + noise;
            while 1
                fileName = [PATH_FILE int2str(fileNum) '.wav'];
                fileNum = fileNum + 1;
                if ~isfile(fileName)
                     audiowrite(fileName,mixed,fs);
                    break
                end
            end
        end
    end
end