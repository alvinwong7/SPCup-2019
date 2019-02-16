%% transition.m

function p = transition(t1,p1,t2,p2,k)
    if isfile(['min_factor_' num2str(k) '.mat'])
        load(['min_factor_' num2str(k) '.mat']);
    else
        factor = 0;
        min = warpDist(0,0,180,0,k);
        for i = 0:259
            for j = -90:90
                factor = factor + warpDist(0,0,i,j,k) - min;
            end
        end
        save(['min_factor_' num2str(k) '.mat'],'min','factor');
    end
    p = (warpDist(t1,p1,t2,p2,k)-min)/factor;
end

function C = warpDist(t1,p1,t2,p2,k)
    C = 1/(dist(t1,p1,t2,p2)+k);
end

function d = dist(t1,p1,t2,p2)
    [x1(1),x1(2),x1(3)] = sph2cart(deg2rad(t1),deg2rad(p1),1);
    [x2(1),x2(2),x2(3)] = sph2cart(deg2rad(t2),deg2rad(p2),1);
    ang = acos(dot(x1,x2));
    d = ang/2;
end