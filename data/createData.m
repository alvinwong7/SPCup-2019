% Creates data at specific SNRs

close all; clear all; clc

%% TOGGLES
% Toggles
% speech - toggles between speech (1) and white noise (0)
% vary - toggles between varying snr
speech = 1;
snrRange = 0;

%% SETTINGS
snrs = [-10];
motorSpeed = 50;

%% PATHS
PATH = 'new_data/';
if speech 
    PATH_SOURCE = 'dev_static/speech/';
    PATH_NEW_DATA = [PATH 'speech/'];
else
    PATH_SOURCE = 'dev_static/audio/';
    PATH_NEW_DATA = [PATH 'broadband/'];
end

%% FOLDER CREATION
mkdir(PATH)
mkdir(PATH_NEW_DATA)

%% 

if speech
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
    for spkrNum = 1:10
        PATH_SPEAKER = [PATH_SOURCE 'Speaker' int2str(spkrNum) '/'];
        speechFiles = dir([PATH_SPEAKER '*.WAV']);
        for i = 1:length(snrs)
            fileNum = 1;
            PATH_FILE = [PATH_NEW_DATA int2str(snrs(i)) '/'];
            mkdir(PATH_FILE)
            for j = 1:length(speechFiles)
                PATH_AUDIO = [PATH_SPEAKER speechFiles(j).name];
                [y, fs] = audioread(PATH_AUDIO);
                % distance in cm
                theta = 40;
                phi = -45;
                d = 1000;
                cart = [d*cos(theta*pi/180)*cos(phi*pi/180) d*sin(theta*pi/180)*cos(phi*pi/180) d*sin(phi*pi/180)];
                for k = 1:8
                    delay(k) = norm(cart - micPos(k,:))/c;
                end
                delaySampled = round(delay*16*fs);
                yResampled = resample(y,16,1);
                % Largest delay shift
                maxDelay = max(delaySampled);
                minDelay = min(delaySampled);
                for k = 1:8
                    Y_temp = [zeros(delaySampled(k),1); yResampled];
                    delayedY(:,k) = Y_temp(maxDelay:length(yResampled)+minDelay);
                end
                y = resample(delayedY,1,16);
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
else
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