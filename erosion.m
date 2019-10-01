function [depth, Qmax_sp, Qmin_sp, Qlikely_sp, Hmax, Hmin, elev] = erosion(theta, profiles, DEMcont)

np = length(profiles);

depth = zeros(1,np);

% convert to radians = 
theta = theta*pi/180;

% calculate depths
for k=1:np

    elev(k) = DEMcont{k+1}.h;
    
    % get 'x' samples along profile   

    mid = floor(length(profiles{k}.H)/2)+1;
    r = sqrt(sum(diff(profiles{k}.XY,[],2).^2));
    center = sum(r(1:mid));
    x = [0,cumsum(r)]-center;
    
    % remove nans
    inx = find(isnan(profiles{k}.H));
    H = profiles{k}.H;
    if(~isempty(inx))
        x(inx) = [];
        H(inx) = [];
    end
    
    % get location of peaks closest to '0'
    [pks, locs] = findpeaks(H);
    ineg = find(x(locs)<=0,1,'last');
    ipos = find(x(locs)>=0,1);
    
    % get the depth
    depth(k) = min(H(locs(ineg):locs(ipos)));
    assignin('base','depth',depth);


% creates variables that measure the max and min lava flux values for both
% models of mechanical erosion (s = stream power (Sklar and Dietrich, 1998)
% and (vl = vertical load (Siewert and Ferlito, 2008)

rho = 2600; % kg/m3 - lava flow density
g = 9.81; %m/s2 - gravity

tmax = 432000; %5 days, in seconds
tmin = 172800; %2 days, in seconds

Kmin = (10^-10);
Kmax = (10^-1);
Klikely = (10^-9);

kmin_pub = (10^-3);
kmax_pub = (10^-2);
 
Hmin_pub = (10^5)/3;
Hmax_pub = (10^6)/3;

Qmin_sp(k) = (depth(k))/(Kmax*rho*g*sin(theta(k+1))*tmax);
assignin('base','Qmin_sp',Qmin_sp);

Qmax_sp(k) = (depth(k))/(Kmin*rho*g*sin(theta(k+1))*tmin);
assignin('base','Qmax_sp',Qmax_sp);

Qlikely_sp(k) = (depth(k))/(Klikely*rho*g*sin(theta(k+1))*tmin);
assignin('base','Qlikely_sp',Qlikely_sp);

Hmin = (kmin_pub*rho*g*cos(theta(k+1)))/depth(k);
assignin('base','Hmin',Hmin);

Hmax = (kmax_pub*rho*g*cos(theta(k+1)))/depth(k);
assignin('base','Hmax',Hmax);

kmin = ((depth(k))*(Hmin_pub))/(rho*g*cos(theta(k+1)));
assignin('base','kmin',kmin);

kmax = ((depth(k))*(Hmax_pub))/(rho*g*cos(theta(k+1)));
assignin('base','kmax',kmax);

end