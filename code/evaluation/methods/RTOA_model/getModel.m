%% getModel.m - Function to generate and save RTOA model locally

% Inputs:
% az   - A 3x1 array that indicates the lower angle, upper angle, and
%        number of points for azimuth values in the model. Defaults to
%        [-178 180 180] if left empty (units in degrees).
% el   - A 3x1 array that indicates the lower angle, upper angle, and
%        number of points for elevation values in the model. Defaults to
%        [-90 90 181] if left empty (units in degrees).
% dist - A 3x1 array that indicates the lower distance, upper distance, and
%        number of points for distance values in the model. Defaults to
%        [0.1 5 50] if left empty (units in meters).
%
% Outputs:
% N/A (output is written to local file titled 'model.mat').
function getModel(az,el,dist)

% The (X,Y,Z) positions of the 8 microphones, in meters, 
% with respect to the center of the array are given below:
micPos = 100*[0.0420   0.0615  -0.0410;  % mic 1
             -0.0420   0.0615   0.0410;  % mic 2
             -0.0615   0.0420  -0.0410;  % mic 3
             -0.0615  -0.0420   0.0410;  % mic 4
             -0.0420  -0.0615  -0.0410;  % mic 5
              0.0420  -0.0615   0.0410;  % mic 6
              0.0615  -0.0420  -0.0410;  % mic 7
	          0.0615   0.0420   0.0410]; % mic 8

% Generate array of input coordinates (spherical)
if ~isempty(az)
    theta = linspace(az(1),az(2),az(3));
else
    theta = linspace(-178,180,180);
end

if ~isempty(el)
    phi = linspace(el(1),el(2),el(3));
else
    phi = linspace(-90,90,181);
end

if ~isempty(dist)
    D = 100*linspace(dist(1),dist(2),dist(3));
else
    D = 100*linspace(0.1, 5, 50);
end

c = 34400;

% Initialise space for model
model = zeros(7,length(theta),length(phi),length(D));
dist = zeros(1,8);

% Compute expected RTOA for each source spherical coordinate
for d = 1:length(D)
    for p = 1:length(phi)
        for t = 1:length(theta)
            % Convert spherical coordinates (t,p,d) to cartesian (x,y,z)
            cart = [D(d)*cos(theta(t)*pi/180)*cos(phi(p)*pi/180) D(d)*sin(theta(t)*pi/180)*cos(phi(p)*pi/180) D(d)*sin(phi(p)*pi/180)];
            for i = 1:8
                dist(i) = norm(cart - micPos(i,:));
            end
            model(:,t,p,d) = (dist(2:end) - dist(1))/c;
        end
    end
end

save('methods/RTOA_model/model.mat','model','theta','phi','D');

end