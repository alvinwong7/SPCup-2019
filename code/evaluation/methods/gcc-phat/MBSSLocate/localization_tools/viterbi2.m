function [argmax, valmax] = viterbi2(obs, states, emission)
    T = {};
    for output = 1:obs
        for state = 1:length(states(1,:,:))
            T{output,state} = {log(1),state};
        end
    end
    for output = 2:obs
        for next_state = 1:length(states(1,:,:))
            argmax = [];
            valmax = -10000;
            next_az = states(output, next_state, 1);
            next_el = states(output, next_state, 2);
            for source_state = 1:length(states(1,:,:))
                Ti = T{output-1,source_state};
                prob = Ti{1}; v_path = Ti{2};
                source_az = states(output-1, source_state, 1);
                source_el = states(output-1, source_state, 2);
                p_trans = log(transition3(source_az, source_el, next_az, next_el, 0.2,40));
                prob = prob + p_trans;
                if prob > valmax
                    argmax = [v_path, next_state];
                    valmax = prob;
                end
            end
            T{output,next_state} = {valmax+log(emission(output,next_state)),argmax};
        end
    end
    argmax = [];
    valmax = -10000;
    for state = 1:length(states(1,:,:))
        Ti = T{obs, state};
        prob = Ti{1}; v_path = Ti{2};
        if prob > valmax
            argmax = v_path;
            valmax = prob;
        end
    end
end