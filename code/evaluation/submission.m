%% submission.m -- Master function to evaluate methods
% Inputs:
% - method    - Function handle for the method being tested
% - args      - Cell array containing any arguments the method needs
% - testType  - The type of files to test on. 
%               Current options: 'broadband_simulated' or 'speech'

function submission()

dirStatic = dir(fullfile('..','data','static_task','audio'));
dirBroadband = dir(fullfile('..','data','flight_task','audio','broadband'));
dirSpeech = dir(fullfile('..','data','flight_task','audio','speech'));
for j = 1:3
    switch j
        case 1
            files = dirStatic;
        case 2
            files = dirBroadband;
        case 3
            files = dirSpeech;
    end
    for i = 1:numel(files)
        if files(i).name == '.'
                row2clr = i;
                break;
        end
    end
    files(row2clr) = []; files(row2clr) = [];
    switch j
        case 1
            dirStatic = files;
        case 2
            dirBroadband = files;
        case 3
            dirSpeech = files;
    end
end
static_azimuth = [];
static_elevation = [];
speech_azimunth = [];
speech_elevation = [];
broadband_azimuth = [];
broadband_elevation = [];
for j = 1:3
    switch j
        case 1
            args{1} = 'static';
            files = dirStatic;
        case 2
            args{1} = 'flight';
            files = dirBroadband;
        case 3
            args{1} = 'flight';
            files = dirSpeech;
    end
    num_files = size(dir(fullfile(files(1).folder,files(1).name,'*.wav')),1);
    if ~contains(files(1).folder, 'flight')
        DOA = zeros(numel(files),num_files,2);
    else
        DOA = zeros(numel(files),num_files*15,2);
    end

    methodDOA = [];
    for k = 1:numel(files)
        fileName = [int2str(k) '.wav'];
        [data,Fs] = audioread(fullfile(files(k).folder,fileName));
        methodDOA = baseline2(data,Fs,args,0,k);
        disp(['Folder [',num2str(i),'/',num2str(numel(files)),']']);
        disp(['File [',num2str(k),'/',num2str(numel(files)),']']);
        switch j
            case 1
                static_azimuth = [static_azimuth methodDOA(:,1)];
                static_elevation = [static_elevation methodDOA(:,2)];
            case 2
                broadband_azimuth = [broadband_azimuth; methodDOA(:,1)];
                broadband_elevation = [broadband_elevation; methodDOA(:,2)];
            case 3
                speech_azimuth = [speech_azimuth; methodDOA(:,1)];
                speech_elevation = [speech_elevation; methodDOA(:,2)];
        end
    end
end
save('SPCUP19_static.mat', static_azimuth, static_elevation);
save('SPCUP19_flight.mat', speech_azimuth, speech_elevation, broadband_azimuth, broadband_elevation);
end