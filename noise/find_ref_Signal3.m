function [ref] = find_ref_Signal2(speeds, fs, ref_time_length)
% This is another version of getting reference signals
% Inputs: speeds: 4 rotor speeds from given data
% Output: only 1 channel of reference signal for Wiener filtering, and all
%         8 channels are assumed to be same, although not very convictive

    samples = ref_time_length * fs;
    ref = zeros(samples,8);
    start_samp = 10000;
    for i = 1:4 % 4 motor's speeds
        curr_speed = round(speeds(i));
        
        if (mod(curr_speed,10) == 0)
            noise_file = ['../data/individual_motors_cut/' 'Motor' num2str(i) '_' num2str(curr_speed) '.wav'];
            noise = audioread(noise_file);
            noise_sum = noise(start_samp:start_samp + samples - 1,:);
        else
            lower_speed = floor(curr_speed/10)*10;
            higher_speed = lower_speed+10;
            higher_weight = curr_speed/10 - floor(curr_speed/10);
            lower_weight = 1-higher_weight;
            
            lower_MotorNoiseFile = ['../data/individual_motors_cut/' 'Motor' num2str(i) '_' num2str(lower_speed) '.wav'];
            [x1,~] = audioread(lower_MotorNoiseFile);
            
            higher_MotorNoiseFile = ['../data/individual_motors_cut/' 'Motor' num2str(i) '_' num2str(higher_speed) '.wav'];
            [x2,~] = audioread(higher_MotorNoiseFile);
            
            m1 = resample(x1(start_samp:start_samp + round(1.2*samples),:),lower_speed,curr_speed)*lower_speed/curr_speed;
            m2 = resample(x2(start_samp:start_samp + round(1.2*samples),:),higher_speed,curr_speed)*higher_speed/curr_speed;
            
            noise_sum = m1(1:samples,:)*lower_weight + m2(1:samples,:)*higher_weight; %weighted sum of warped noise
        end
        
        ref = ref + noise_sum; % sum of noise from each motor
    end
end
