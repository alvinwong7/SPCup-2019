function DOA = baseline(wavforms,fs_wav,params)
% main function for participants of the SPCUP19 challenge to 
% load each recording and to run their algorithm.
%
% Inputs:  N/A (loads data from mat files specified by the
%          variables in PATH)
% Outputs: N/A (saves data to mat files)
%
% Authors: Diego Di Carlo
%          Antoine Deleforge
%
% Notice:  This is a preliminary version as part of the SPCUP19 consultation
%          pre-release. Please report problems and bugs to the author on the
%          PIAZZA platform webpage or on the github page
%

close all; clear; clc

%% PATHs
DATA = 'static'; % static or flight
PATH_DATA = fullfile('..','..','..','data','dev_flight');

PATH_AUDIO = fullfile('..','..','..','data','new_data','speech','-17');
PATH_GT = PATH_DATA;

% add MBSSLocate toolbox to the current matlab session
addpath(genpath('./MBSSLocate/'));

%% FLAGs
% if 'development' is 1, load the ground-truth files and
% perform the evaluation
development = 0;

%% HARD CODED VARIBLEs
%    coord:    x         y         z
micPos = [  0.0420    0.0615   -0.0410;  % mic 1
           -0.0420    0.0615    0.0410;  % mic 2
           -0.0615    0.0420   -0.0410;  % mic 3
           -0.0615   -0.0420    0.0410;  % mic 4
           -0.0420   -0.0615   -0.0410;  % mic 5
            0.0420   -0.0615    0.0410;  % mic 6
            0.0615   -0.0420   -0.0410;  % mic 7
            0.0615    0.0420    0.0410]; % mic 8

%% GROUND TRUTH
% mat files are:
%   - SPCUP19_dev_flight.mat, containing:
%       - broadband_azimuth
%       - broadband_elevation
%   - SPCUP19_dev_static.mat, containing:
%       - static_azimuth
%       - static_elevation
% Thus an additional variabile, 'data_specification', is used
if strcmp(DATA, 'flight')
    data_specification = 'broadband';
end
if strcmp(DATA, 'static')
    data_specification = 'static';
end
    
if development
    % load groud-truth files
    file = load([PATH_GT 'SPCUP19_dev_' DATA '.mat']);
    
    eval(['gt_azimuth = file.' data_specification '_azimuth;'])
    eval(['gt_elevation = file.' data_specification '_elevation;'])
    
    [J, T] = size(gt_azimuth); % J audio files x T frames
    
    azRef = gt_azimuth;   % azimuth reference
    elRef = gt_elevation; % elevation refernce
end


%% BASELINE

% Signal parameters
% -----------------

% Sampling frequency for the algorithm. It can be changed and 
% resampling is performed later
fs = 44100; 
% if the flight data, than process the signal frame-wise
if strcmp(DATA, 'flight')
    frame_size = 0.500; % 500 [ms] - !hardcode; see Challenge's syllabus
    frame_hop  = 0.250; % 250 [ms] - !hardcode; see Challenge's syllabus
else
    frame_size = 4; % 4 [s]        - !hardcode; see Challenge's syllabus
    frame_hop  = 0; % no hop size  - !hardcode; see Challenge's syllabus
end


% MBSS Locate Parameters
% ----------------------

% array parameters
micPos = micPos';     % transpose
isArrayMoving   = 0;  % The microphone array is not moving
subArray        = []; % []: all microphones are used
sceneTimeStamps = []; % Both array and sources are statics => no time stamps
                      % in the this code, the process is done frame-wise, 
                      % thus MBSSLocate's tracking function is Sdisabled

% localization method
angularSpectrumMeth        = 'GCC-PHAT'; % Local angular spectrum method {'GCC-PHAT' 'GCC-NONLIN' 'MVDR' 'MVDRW' 'DS' 'DSW' 'DNM'}
pooling                    = 'max';      % Pooling method {'max' 'sum'}
applySpecInstNormalization = 0;          % 1: Normalize instantaneous local angular spectra - 0: No normalization
% Search space
azBound                    = [-179 180]; % Azimuth search boundaries ((degree))
elBound                    = [-90   10]; % Elevation search boundaries ((degree))
gridRes                    = 1;          % Resolution (degree) of the global 3D reference system {azimuth,elevation}
alphaRes                   = 5;          % Resolution (degree) of the 2D reference system defined for each microphone pair
% Multiple sources parameters
nsrce                      = 6;          % Number of sources to be detected
minAngle                   = 10;         % Minimum angle between peaks
% Moving sources parameters
blockDuration_sec          = [];         % Block duration in seconds (default []: one block for the whole signal)
blockOverlap_percent       = [];         % Requested block overlap in percent (default []: No overlap) - is internally rounded to suited values
% Wiener filtering
enableWienerFiltering      = 0;          % 1: Process a Wiener filtering step in order to attenuate / emphasize the provided excerpt signal into the mixture signal. 0: Disable Wiener filtering
wienerMode                 = [];         % Wiener filtering mode {'[]' 'Attenuation' 'Emphasis'}
wienerRefSignal            = [];         % Excerpt of the source(s) to be emphasized or attenuated
% Display results
specDisplay                = 0;          % 1: Display angular spectrum found and sources directions found - 0: No display
% Other parameters
speedOfSound               = 343;        % Speed of sound (m.s-1) - typical value: 343 m.s-1 (assuming 20�C in the air at sea level)
fftSize_sec                = [];         % FFT size in seconds (default []: 0.064 sec)
freqRange                  = [];         % Frequency range (pair of values in Hertz) to aggregate the angular spectrum : [] means that all frequencies will be used
% Debug
angularSpectrumDebug       = 0;          % 1: Enable additional plots to debug the angular spectrum aggregation

% Convert algorithm parameters to MBSS structures
% -----------------------------------------------
sMBSSParam = MBSS_InputParam2Struct(angularSpectrumMeth,speedOfSound,fftSize_sec,blockDuration_sec,blockOverlap_percent,pooling,azBound,elBound,gridRes,alphaRes,minAngle,nsrce,fs,applySpecInstNormalization,specDisplay,enableWienerFiltering,wienerMode,freqRange,micPos,isArrayMoving,subArray,sceneTimeStamps,angularSpectrumDebug);

%% FILE-WISE and FRAME-WISE PROCESSING
J = 1;
T = 1;

% variable allocation
azPred = zeros(J, T);
elPred = zeros(J, T);

DOA = [];

for j = 1:J
    
    fprintf('Processing audio sample %02i/%02i:\n',j,J)
    
    % Load audio filename    
    [wavforms,fs_wav] = audioread([PATH_AUDIO '\' '2.wav']);
    % resampling to the given sampling frequency
    [p,q] = rat(fs/fs_wav,0.0001);
    wavforms = resample(wavforms,p,q);
    
    [n_samples, n_chan] = size(wavforms);
    
    % Pick current frame of length frame_size
    for t = 1:T
        
        fprintf('  -- frame: %02i/%02i\n',t,T)
        
        % frame processing
        frame_start = floor(fs*((t-1)*frame_hop))+1;
        frame_end = frame_start + floor(fs*frame_size)-1;
        if frame_end > n_samples
            frame_end = n_samples;
        end
        
        wav_frame = wavforms(frame_start:frame_end,:); % nsampl x nchan
        
        % Run the localization method
        % here you should write your own code
        [azEst, elEst, specGlobal, ~, ~] = ...
            MBSS_locate_spec(wav_frame,wienerRefSignal,sMBSSParam);
        
        sources(t,:,1) = azEst;
        sources(t,:,2) = elEst;
        
        test = reshape(specGlobal, [360,101]);
        figure
        surf(sMBSSParam.azimuth, sMBSSParam.elevation, test(:,:)','EdgeColor','none')
        axis xy; axis tight; colormap(jet); view(0,90);
        hold on
        
        %for multiple sources
        for i = 1:length(azEst)
            scatter3(azEst(1,i),elEst(1,i),1, 'kx','lineWidth',2);
        end
        %fileToPlot = load([PATH_AUDIO 'sourceData.mat']);
        %scatter3(fileToPlot.sourceData(j,1),fileToPlot.sourceData(j,2), test(round(fileToPlot.sourceData(J,2)+91),round(fileToPlot.sourceData(1,1)+180))+5000, 'kx','lineWidth',2);   
        hold off
        
        % Printing for the development
        if development
            azPred(j,t) = azEst;
            fprintf('%1.2f %1.2f\n',azRef(j,t), azPred(j,t));
            elPred(j,t) = elEst;
            fprintf('%1.2f %1.2f\n\n',elRef(j,t), elPred(j,t));
        end
        
    end
    [total, argmax, valmax, P] = viterbi(T, sources);
    pred = [];
    for t = 1:T
        pred = [pred; sources(t,argmax(t),1) sources(t,argmax(t),2)];
    end
    
    DOA = [DOA pred];
    
    fprintf('\n')
end
end