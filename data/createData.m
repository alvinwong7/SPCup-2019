% Creates data at specific SNRs

close all; clear all; clc

%% PATHS
PATH = 'new_data/';

%% TOGGLES/SETTINGS
% Toggles
speech = 0;
createSource = 0;
vary = 0;

snrs = [-10];
motorSpeed = 50;

%% SOURCE GENERATION
mkdir(PATH)
if createSource
    if speech

    else

    end
else
    if speech
        
    else
        PATH_SOURCE = 'dev_static/audio/';
        whiteNoiseFiles = dir('dev_static/audio/*.wav');
        for i = 1:length(snrs)
            filenum = 1;
            FILE_PATH = [PATH int2str(snrs(i)) '/'];
            mkdir(FILE_PATH)
            for j = 1:length(whiteNoiseFiles)
                PATH_AUDIO = [PATH_SOURCE whiteNoiseFiles(j).name];
                [y, fs] = audioread(PATH_AUDIO);
                noise = mixMotorNoise(y,motorSpeed);
                noise = (noise/norm(noise))*(norm(y)/10.0^(0.05*snrs(i)));
                y = y + noise;
                while 1
                    filename = [FILE_PATH int2str(filenum) '.wav'];
                    filenum = filenum + 1;
                    if ~isfile([filename])
                        audiowrite(filename,y,fs);
                        break
                    end
                end
            end
        end
    end
end