%% transition2.m

function p = transition2(t1,p1,t2,p2,s,reach)
    if isfile(['min_factor_trans2_' num2str(s) '.mat'])
        load(['min_factor_trans2_' num2str(s) '.mat']);
    else
        factor = 0;
        min = truncGauss(0,0,180,0,s,reach);
        for i = 0:259
            for j = -90:90
                factor = factor + truncGauss(0,0,i,j,s,reach) - min;
            end
        end
        save(['min_factor_trans2_' num2str(s) '.mat'],'min','factor');
    end
    p = (truncGauss(t1,p1,t2,p2,s,reach)-min)/factor;
end

function C = truncGauss(t1,p1,t2,p2,s,reach)
    d = dist(t1,p1,t2,p2);
    if d < dist(0,0,0,reach)
        C = exp(-d^2/(2*s^2));
    else
        C = 0.0001;
    end
end

function d = dist(t1,p1,t2,p2)
    [x1(1),x1(2),x1(3)] = sph2cart(deg2rad(t1),deg2rad(p1),1);
    [x2(1),x2(2),x2(3)] = sph2cart(deg2rad(t2),deg2rad(p2),1);
    ang = acos(dot(x1,x2));
    d = ang/2;
end