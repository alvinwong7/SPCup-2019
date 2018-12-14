%% mixMotorNoise - add specified motor speed noise to an input

function noise = mixMotorNoise(x, speed)
% I'll optimise this later
lowest = 1000000000;
for k = 1:4
    PATH_AUDIO = ['individual_motors_cut/Motor' num2str(k) '_' num2str(speed) '.wav'];
    [y, fs] = audioread(PATH_AUDIO);
    if lowest > length(y)
        lowest = length(y);
        r = floor(1 + (length(y)-length(x)-1).*rand(1,1));
    end
end
[row, col] = size(x);
noise = zeros(row, col);
for k = 1:4
    PATH_AUDIO = ['individual_motors_cut/Motor' num2str(k) '_' num2str(speed) '.wav'];
    [y, fs] = audioread(PATH_AUDIO);
    noise = noise + y(r:r+length(x)-1,:);
end

end