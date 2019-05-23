%% baseline.m -- baseline turned into a function
function DOA = baseline(wavforms,fs_wav,params,sourceData, fileNum, static_motor_speed)
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
%% PATHs
    % add MBSSLocate toolbox to the current matlab session
    addpath(fullfile('..','baseline','MBSSLocate'));

    %% FLAGs
    % if 'development' is 1, load the ground-truth files and
    % perform the evaluation
    development = 1;

    %% HARD CODED VARIABLEs
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
    angularSpectrumMeth        = 'GCC-NONLIN'; % Local angular spectrum method {'GCC-PHAT' 'GCC-NONLIN' 'MVDR' 'MVDRW' 'DS' 'DSW' 'DNM'}
    pooling                    = 'max';      % Pooling method {'max' 'sum'}
    applySpecInstNormalization = 0;          % 1: Normalize instantaneous local angular spectra - 0: No normalization
    % Search space
    azBound                    = [-179 180]; % Azimuth search boundaries ((degree))
    elBound                    = [-90   10]; % Elevation search boundaries ((degree))
    gridRes                    = 1;          % Resolution (degree) of the global 3D reference system {azimuth,elevation}
    alphaRes                   = 5;          % Resolution (degree) of the 2D reference system defined for each microphone pair
    % Multiple sources parameters
    nsrce                      = 1;          % Number of sources to be detected
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
    % T will have to change between flight and static
    azPred = zeros(1, T);
    elPred = zeros(1, T);

    [n_samples, n_chan] = size(wavforms);
    DOA = [];
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
        
        ref_time_length = 8;
        %wienerRefSignal = find_ref_Signal(speeds, motor_nums, fs, ref_time_length);
        
        speeds = static_motor_speed(fileNum, :);
        %speeds = [80 80 80 80];
        wienerRefSignal = find_ref_Signal3(speeds, fs, ref_time_length);
        
        % Run the localization method
        % here you should write your own code
        [azEst, elEst, specGlobal, ~, ~] = ...
            MBSS_locate_spec(wav_frame,wienerRefSignal,sMBSSParam);
        
        specGlobal2D = reshape(specGlobal, [360,101]);
        figure
        surf(sMBSSParam.azimuth, sMBSSParam.elevation, specGlobal2D(:,:)','EdgeColor','none')
        axis xy; axis tight; colormap(jet); view(0,90);
        title("Real Wiener " + fileNum);
        hold on
        
        %for multiple sources      
        for i = 1:length(azEst)
           scatter3(azEst(1,i),elEst(1,i),50000, 'kx','lineWidth',2);
        end
        %scatter3(sourceData(fileNum,1),sourceData(fileNum,2), 5000, 'ko','lineWidth',2);
        %test(round(fileToPlot.sourceData(J,2)+91),round(fileToPlot.sourceData(1,1)+180))+5000
        hold off
        
        % Printing for the development
        if development
            azPred(t) = azEst;
            fprintf('%1.2f %1.2f\n',azPred(t));
            elPred(t) = elEst;
            fprintf('%1.2f %1.2f\n\n',elPred(t));
        end

    end
    DOA = [azPred; elPred]';

    fprintf('\n')
end