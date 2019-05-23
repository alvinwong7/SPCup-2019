%% transition2.m

function p = transition3(t1,p1,t2,p2,s,reach)
    p = truncGauss(t1,p1,t2,p2,s,reach);
end

function C = truncGauss(t1,p1,t2,p2,s,reach)
    d = dist(t1,p1,t2,p2);
    if d < dist(0,0,0,reach)
        C = exp(-d^2/(2*s^2));
    else
        C = 1e-10;
    end
end

function d = dist(t1,p1,t2,p2)
    [x1(1),x1(2),x1(3)] = sph2cart(deg2rad(t1),deg2rad(p1),1);
    [x2(1),x2(2),x2(3)] = sph2cart(deg2rad(t2),deg2rad(p2),1);
    ang = acos(dot(x1,x2));
    d = ang/2;
end