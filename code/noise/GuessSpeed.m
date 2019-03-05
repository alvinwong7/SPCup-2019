function [speeds] = GuessSpeed(InputSignals, fs)
    % input: InputSignals: input speech+motor noise signal
    % output: speeds: gives your the estimated rotor speed for each channal
 
        %This function tries to predict the closet motor speed that can be
        %used from given motor noise data sets.
        n = size(InputSignals,2);
        speeds = zeros(1,n);
        for k = 1:n
            mags = abs(fft(InputSignals(:,k)));
            sorted_mags = sort(mags, 'descend');
            for counter = 1:length(sorted_mags)
                peak = sorted_mags(counter);
                index = find(mags == peak, 1);
                speed = index/size(InputSignals,1)*fs;
                if speed >= 50 && speed <= 90
                    break;
                end
            end
            speeds(k) = speed;
        end
        
        ten_digits = round(speeds/10);
        most = mode(ten_digits * 10);
        for i = 1:length(speeds)
            if abs(speeds(i) - most) >= 20
                % This is an error estimation, re do it again
                mags = abs(fft(InputSignals(:,k)));
                sorted_mags = sort(mags, 'descend');
                for counter = 1:length(sorted_mags)
                    peak = sorted_mags(counter);
                    index = find(mags == peak, 1);
                    speed = index/size(InputSignals,1)*fs;
                    if abs(speed - most) < 20
                        break;
                    end
                end
            end
        end
        
        % We want the guessed speed to always be in the range of [50,90], this still needs more effective methods!

    end
