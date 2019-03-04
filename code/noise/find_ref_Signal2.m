function [refSignal] = find_ref_Signal2(speeds, fs, ref_time_length)
% This is another version of getting reference signals
% Inputs: speeds: 4 rotor speeds from given data
% Output: only 1 channel of reference signal for Wiener filtering, and all
%         8 channels are assumed to be same, although not very convictive

    min_samples = ref_time_length * fs;
    for i = 1:4 % 4 motor's speeds
        lower_speed = floor(speeds(i)/10)*10;
        higher_speed = lower_speed+10;
        lower_weight = speeds(i)/10 - floor(speeds(i)/10);
        higher_weight = 1-lower_speed;
        
        
        lower_MotorNoiseFile = ["../data/individual_motors_cut/" + "Motor" + num2str(i) + "_" + num2str(lower_speed) + ".wav"];
        [m1,~] = audioread(lower_MotorNoiseFile);

        higher_MotorNoiseFile = ["../data/individual_motors_cut/" + "Motor" + num2str(i) + "_" + num2str(higher_speed) + ".wav"];
        [m2,~] = audioread(higher_MotorNoiseFile);
        noise_sum = m1(1:fs*ref_time_length,:)*lower_weight + m2(1:fs*ref_time_length,:)*higher_weight;
        ref = ref + noise_sum; %weighted sum of the motor noise
        if min_samples > min(size(m1,1),size(m2,1))
            min_samples = min(size(m1,1),size(m2,1));
        end
        refSignal = ref(1:min_samples,:);
    end
end