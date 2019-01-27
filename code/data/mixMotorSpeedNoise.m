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
    noise = zeros(samples, col);
    for k = 1:4
        PATH_AUDIO = ['individual_motors_cut/Motor' num2str(k) '_' num2str(speed) '.wav'];
        [y, fs] = audioread(PATH_AUDIO);
        noise = noise + y(r+samples*(speed/10-5):r+samples*(speed/10-4)-1,:);
    end
    varyNoise = [varyNoise; noise];
end
end