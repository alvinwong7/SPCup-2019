function [refSignal] = find_ref_Signal(speeds, motor_nums, fs, ref_time_length)
% This function gives you the rotor noise signal according to estimated rotor speed.
% motor_nums should be an array of any sequences between 1:4
% fs is sampling frequency, ref_time_length is the time length you want to take as Wiener reference

    refSignal = zeros(8,fs*ref_time_length);
    for i = 1:length(speeds)
        if speeds(i) > 50 && speeds(i) < 90
            lower_speed = floor(speeds(i)/10)*10;
            higher_speed = lower_speed+10;
            lower_weight = (speeds(i)-floor(speeds(i)/10)*10)/10;
            higher_weight = 1-lower_speed;
        end
        
        for j = 1:length(motor_nums)
            if speeds(i) > 50 && speeds(i) < 90
                lower_MotorNoiseFile = ["..\individual_motors_recordings\" + "Motor" + num2str(motor_nums(j)) + "_" + num2str(lower_speed) + ".wav"];
                [m1,~] = audioread(lower_MotorNoiseFile);

                higher_MotorNoiseFile = ["..\individual_motors_recordings\" + "Motor" + num2str(motor_nums(j)) + "_" + num2str(higher_speed) + ".wav"];
                [m2,~] = audioread(higher_MotorNoiseFile);
                noise_sum = m1*lower_weight + m2*higher_weight;
                refSignal(i,:) = refSignal(i,:) + noise_sum(1:fs*ref_time_length); %weighted sum of the motor noise
            else
                % i.e. speeds(i) == 50 or 90
                MotorNoiseFile = ["..\individual_motors_recordings\" + "Motor" + num2str(motor_nums(j)) + "_" + num2str(speed(i)) + ".wav"];
                [m,~] = audioread(MotorNoiseFile);
                refSignal(i,:) = refSignal(i,:) + m(1:fs*ref_time_length);
            end
        end
        
    end
end

