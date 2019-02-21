 function [speeds] = GuessSpeed(InputSignals, fs)
    % input: InputSignals: input speech+motor noise signal
    % output: speeds: gives your the estimated rotor speed for each channal
 
        %This function tries to predict the closet motor speed that can be
        %used from given motor noise data sets.
        n = size(InputSignals,2);
        MagPeakPositions = zeros(1,n);
        for k = 1:n
            mags = abs(fft(InputSignals(:,k)));
            MagPeakPositions(k) = find(max(mags) == mags,1);
        end
        speeds = MagPeakPositions/size(InputSignals,1)*fs;
        
        % We want the guessed speed to always be in the range of [50,90], this still needs more effective methods!
        for c = 1:length(speeds)
            if speed(c) > 50 && speed(c) < 90
                continue;
            else
                while speed(c) <= 45
                    speed(c) = speed(c) * 2;
                    continue;
                end
                while speed(c) >= 100
                    speed(c) = speed(c) / 2;
                end
                if speed(c) > 45
                    speed(c) = 50;
                else
                    % i.e. [90, 100)
                    speed(c) = 90;
                end
            end
        end
        %speeds = round(speeds/10)*10;
        %PredictedSpeed = mode(speeds);
    end
