%% final_submission.m -- Master function to evaluate methods
% Inputs:
% - method    - Function handle for the method being tested
% - args      - Cell array containing any arguments the method needs
% - testType  - The type of files to test on. 
%               Current options: 'broadband_simulated' or 'speech'

function final_submission()

dirStatic = dir(fullfile('..','data','final_task','static_speech','audio'));
dirFlight = dir(fullfile('..','data','final_task','flight_speech','audio'));
for j = 1:2
    switch j
        case 1
            files = dirStatic;
        case 2
            files = dirFlight;
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
            dirFlight = files;
    end
end
static_azimuth = [];
static_elevation = [];
speech_azimuth = [];
speech_elevation = [];
for j = 2:2
    switch j
        case 1
            args{1} = 'static';
            files = dirStatic;
        case 2
            args{1} = 'flight';
            files = dirFlight;
    end
    num_files = size(dir(fullfile(files(1).folder,files(1).name,'*.wav')),1);

    methodDOA = [];
    for k = 1:numel(files)
        fileName = [int2str(k) '.wav'];
        [data,Fs] = audioread(fullfile(files(k).folder,fileName));
        switch j
            case 1
                load(fullfile('..','data','final_task','static_speech','static_motor_speed.mat'));
                methodDOA = baseline(data,Fs,args,0,k, static_motor_speed);
            case 2  
                load(fullfile('..','data','final_task','flight_speech','speech_flight_motor_speed.mat'));
                methodDOA = baseline2(data,Fs,args,0,k, speech_flight_motor_speed);
        disp(['Folder [',num2str(j),'/',num2str(3),']']);
        disp(['File [',num2str(k),'/',num2str(numel(files)),']']);
        switch j
            case 1
                static_azimuth = [static_azimuth; methodDOA(:,1)];
                static_elevation = [static_elevation; methodDOA(:,2)];
            case 2
                speech_azimuth = [speech_azimuth; methodDOA(:,1)'];
                speech_elevation = [speech_elevation; methodDOA(:,2)'];
        end
    end
end
save('SPCUP19_team_cooee_static.mat', 'static_azimuth', 'static_elevation');
save('SPCUP19_team_cooee_flight.mat', 'speech_azimuth', 'speech_elevation');
end