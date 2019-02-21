function [refSignal] = find_ref_Signal(speeds)
%this function gives you the rotor noise signal according to estimated
%rotor speed.

    for i = 1:length(speeds)
        lower_speed = floor(speeds(i)/10)*10;
        higher_speed = lower_speed+10;
        lower_index = (speeds(i)-floor(speeds(i)/10)*10)/10;
        higher_index = 1-lower_speed;
        
        lower_MotorNoiseFile = ["..\individual_motors_recordings\" + "Motor1_" + ...
        num2str(lower_speed) + ".wav"];
        [m1,~] = audioread(lower_MotorNoiseFile);
    
        higher_MotorNoiseFile = ["..\individual_motors_recordings\" + "Motor1_" + ...
        num2str(higher_speed) + ".wav"];
        [m2,~] = audioread(higher_MotorNoiseFile);
        refSignal = m1*lower_index + m2*higher_index; %weighted sum of the motor noise
    end
end

