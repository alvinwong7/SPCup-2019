function [new] = SingleChannelFiltering(videoNum)
    %Put this function under dir of 'static_task'
    [y,fs] = audioread(["audio\"+ num2str(videoNum) + ".wav"]);
    MotorNoiseFile = ["..\individual_motors_recordings\" + "Motor1_" + ...
        num2str(GuessSpeed(y,fs)) + ".wav"];
    [m,~] = audioread(MotorNoiseFile);
    

    est = y;
    for i = 1:size(y,2)
        y(:,i) = bandpass(y(:,i),[150,4000],fs); % y = bandpass(y)
        m(:,i) = bandpass(m(:,i),[150,4000],fs);  % bandpass motor noise signal
        coe = lpc(m(:,i),3);
        est(:,i) = y(:,i) - filter([0 -coe(2:end)], 1, y(:,i));
    end
    y1 = y-est;
    y1 = y1*(1/max(max(abs(y1))));

    %y1 = y with some motor noise removed using 3rd order lpc.
    %order number can be changed, just for testing here.
    
    
    
    %The procedure below aims to remove noise using lpc again,
    %but this time, we treat the signal 'before 0.1s' as input to lpc
    %i.e. this is 'real-time' noise cancelling,
    %but again, only with single channel.
    %time_window_length can be changed, 0.1 is acceptable for most cases
 
    time_window_length = 0.1;
    new = y1;
    for i = 1:8
        x = bandpass(y1(:,i), [400 4000], fs);
        j = 1;
        while (j+2*time_window_length*fs) < size(y,1)
            coe = lpc(x(j:(j+time_window_length*fs)),3);
            input = x((j+time_window_length*fs):(j+2*time_window_length*fs));
            est = filter([0 -coe(2:end)], 1, input);
            subs = input - est;
            new((j+time_window_length*fs):(j+2*time_window_length*fs), i) = subs;
            j = j+time_window_length*fs;
        end
        
        %new(:,i) = tsmovavg(new(:,i),'e',12,1);
        %exponential moving average, this is optional

        %new(:,i) = medfilt1(new(:,i));
        %median filter, this is optional
    end
    new(isnan(new)== 1) = 0;
    new = RemoveOutliers(new,0.95);
    new = new((time_window_length*fs:(end-time_window_length*fs)),:);
    new = new / max(max(abs(new)));
    %{
    figure;
    plot(new(:,1));
    figure;
    plot(y(:,1))
    plot(db(abs(fft(new(:,1)))));
    title('new signal')
    plot(db(abs(fft(y(:,1)))));
    title('Original signal');
    %}
    audiowrite('result.wav',new,fs);

    
    function [PredictedSpeed] = GuessSpeed(InputSignals, fs)
        %This function tries to predict the closet motor speed that can be
        %used from given motor noise data sets.
        n = size(InputSignals,2);
        MagPeakPositions = zeros(1,n);
        for k = 1:n
            mags = abs(fft(InputSignals(:,k)));
            MagPeakPositions(k) = find(max(mags) == mags,1);
        end
        speeds = MagPeakPositions/size(InputSignals,1)*fs;
        for c = 1:length(speeds)
            while speeds(c) > 90
                speeds(c) = speeds(c) / 2;
            end
            while speeds(c) < 50
                speeds(c) = speeds(c) * 2;
            end
        end
        speeds = round(speeds/10)*10;
        PredictedSpeed = mode(speeds);
    end

    function[Modified] = RemoveOutliers(InputSignals,BoundaryVal)
        %This function removes any outliers outside of range given by
        %parameter 'Percentage'
        Modified = InputSignals;
        for a = 1:size(Modified,2)
            temp = sort(abs(Modified(:,a)));
            boundary = temp(round(length(temp)*BoundaryVal));
            for b = 1:length(Modified(:,a))
                if (Modified(b,a) > boundary) || (Modified(b,a) < -boundary)
                    if (b == 1) || (b == size(Modified,1))
                        Modified(b,a) = 0;
                    else
                        Modified(b,a) = Modified(b-1,a);
                        %if outlier found, just keep the value as before
                    end
                end
            end
        end
    end
end

