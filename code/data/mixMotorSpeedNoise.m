%% mixMotorSpeedNoise - add specified motor speed noise to an input

function varyNoise = mixMotorSpeedNoise(x)
% I'll optimise this later
lowest = 1000000000000000;
for speed = 50:10:90
    for k = 1:4
        PATH_AUDIO = ['individual_motors_cut/Motor' num2str(k) '_' num2str(speed) '.wav'];
        [y, fs] = audioread(PATH_AUDIO);
        if lowest > length(y)
            lowest = length(y);
            r = floor(1 + (length(y)-length(x)-1).*rand(1,1));
        end
    end
end
[row, col] = size(x);
samples = floor(length(x)/5);
varyNoise = [];
for speed = 50:10:90
    if speed ~= 90
        noise = zeros(samples, col);
    else
        noise = zeros((r+length(x)) - (r+samples*(speed/10-5)),col);
    end
    for k = 1:4
        PATH_AUDIO = ['individual_motors_cut/Motor' num2str(k) '_' num2str(speed) '.wav'];
        [y, fs] = audioread(PATH_AUDIO);
        if speed ~= 90
            noise = noise + y(r+samples*(speed/10-5):r+samples*(speed/10-4)-1,:);
        else
            noise = noise + y(r+samples*(speed/10-5):r+(length(x)-1),:);
        end
    end
    varyNoise = [varyNoise; noise];
end
end