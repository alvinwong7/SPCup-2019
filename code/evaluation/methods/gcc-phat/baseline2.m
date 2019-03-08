function DOA = baseline(wavforms,fs_wav,params, sourceData, fileNum)
%% PATHs
data = char(params{1});
if contains(data, 'flight')
    J = 1;
    T = 15;
    DATA = 'flight';
else
    J = 1;
    T = 1;
    DATA = 'static';
end

plotting = 0;

% add MBSSLocate toolbox to the current matlab session
addpath(genpath('./MBSSLocate/'));

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
applySpecInstNormalization = 1;          % 1: Normalize instantaneous local angular spectra - 0: No normalization
% Search space
azBound                    = [-179 180]; % Azimuth search boundaries ((degree))
elBound                    = [-90   10]; % Elevation search boundaries ((degree))
gridRes                    = 1;          % Resolution (degree) of the global 3D reference system {azimuth,elevation}
alphaRes                   = 5;          % Resolution (degree) of the 2D reference system defined for each microphone pair
% Multiple sources parameters
nsrce                      = 10;          % Number of sources to be detected
minAngle                   = 10;         % Minimum angle between peaks
% Moving sources parameters
blockDuration_sec          = [];         % Block duration in seconds (default []: one block for the whole signal)
blockOverlap_percent       = [];         % Requested block overlap in percent (default []: No overlap) - is internally rounded to suited values
% Wiener filtering
enableWienerFiltering      = 1;          % 1: Process a Wiener filtering step in order to attenuate / emphasize the provided excerpt signal into the mixture signal. 0: Disable Wiener filtering
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
% variable allocation
azPred = zeros(J, T);
elPred = zeros(J, T);

DOA = [];

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
    
    if enableWienerFiltering == 1
        wav_frame = highpass(wav_frame, 1000 ,fs);
        wienerRefSignal = zeros(10*fs, n_chan);
        motor_nums = 1:4;
        ref_time_length = 10;
        speeds = OldGuessSpeed(wav_frame, fs);
        wienerRefSignal = find_ref_Signal(speeds, motor_nums, fs, ref_time_length);
        %speeds = broadband_flight_motor_speed(fileNum, t, :); 
        %speeds = reshape(speeds, [1, 4]);
        %wienerRefSignal = find_ref_Signal2(speeds, fs, ref_time_length);
    end
    
    % Run the localization method
    % here you should write your own code
    [azEst, elEst, specGlobal, ~, ~] = ...
        MBSS_locate_spec(wav_frame,wienerRefSignal,sMBSSParam);

    sources(t,:,1) = azEst;
    sources(t,:,2) = elEst;

    specGlobal2D = reshape(specGlobal, [360,101]);
    
    if plotting == 1
        figure
        surf(sMBSSParam.azimuth, sMBSSParam.elevation, specGlobal2D(:,:)','EdgeColor','none')
        axis xy; axis tight; colormap(jet); view(0,90);
        hold on

        %for multiple sources
        for i = 1:length(azEst)
            scatter3(azEst(1,i),elEst(1,i),1, 'kx','lineWidth',2);
        end
    
        %plots the source
        %fileToPlot = load([fileparts(pwd) '\data\new_data\flight_real_\sourceData.mat']);
        %scatter3(sourceData(t+(fileNum-1)*15,1),sourceData(t+(fileNum-1)*15,2), 1, 'gx','lineWidth',2);
        %test(round(fileToPlot.sourceData(J,2)+91),round(fileToPlot.sourceData(1,1)+180))+5000

        savefig("angularSpectrum" + t + ".fig");
        hold off
    end
    
    for i = 1:length(azEst)
        emission(t, i) = specGlobal2D(azEst(i)+180,elEst(i)+91);
    end
end

[total, argmax, valmax, P] = viterbi(T, sources, emission);
pred = [];

close all
for t = 1:T
    pred = [pred; sources(t,argmax(t),1) sources(t,argmax(t),2)];
    if plotting == 1
        openfig("angularSpectrum" + t + ".fig");
        hold on
        scatter3(sources(t,argmax(t),1),sources(t,argmax(t),2), 1, 'o','lineWidth',2);
        hold off
        savefig("angularSpectrum" + t + ".fig");
        close all
    end
end

if plotting == 1
    for t = 1:T
        openfig("angularSpectrum" + t + ".fig");
    end
end
DOA = [DOA pred];

fprintf('\n')
end