function [total, argmax, valmax, P] = viterbi(obs, states)
    T = {};
    for output = 1:obs
        for state = 1:length(states(1,:,:))
            T{output,state} = {log(1),state,log(1)};
        end
    end
    for output = 2:obs
        U = {};
        for next_state = 1:length(states(1,:,:))
            total = 0;
            argmax = [];
            valmax = -10000;
            next_az = states(output, next_state, 1);
            next_el = states(output, next_state, 2);
            for source_state = 1:length(states(1,:,:))
                Ti = T{output-1,source_state};
                prob = Ti{1}; v_path = Ti{2}; v_prob = Ti{3};
                source_az = states(output-1, source_state, 1);
                source_el = states(output-1, source_state, 2);
                p = log(transition(source_az, source_el, next_az, next_el, 0.1));
                prob = prob + p;
                v_prob = v_prob + p;
                P(output-1,next_state,source_state) = p;
                total = total + prob;
                if v_prob > valmax
                    argmax = [v_path, next_state];
                    valmax = v_prob;
                end
            end
            U{next_state} = {total,argmax,valmax};
        end
        for i = 1:length(U)
            T{output,i} = U{i};
        end
    end
    total = 0;
    argmax = [];
    valmax = -10000;
    for state = 1:length(states(1,:,:))
        Ti = T{obs, state};
        prob = Ti{1}; v_path = Ti{2}; v_prob = Ti{3};
        total = total + prob;
        if v_prob > valmax
            argmax = v_path;
            valmax = v_prob;
        end
    end
end