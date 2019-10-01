function [Y, angle, r, h] = contour_pt2(DEM,xcoor,ycoor,center,rad,omitL,fitL,NA)

% range
r = zeros(1,NA);
r(1) = norm(rad-center);

% samples in angle space
angleomit = omitL/(2*r(1));
anglefit = fitL/r(1);
base_angle = atan2(rad(2)-center(2),rad(1)-center(1));

% covers the whole "ring"
if(2*anglefit>=(2*(pi-angleomit)))
    angle = linspace(0,2*pi,NA+1); angle(end) = [];
    angle = base_angle+angle;
else
    angle = linspace(0,anglefit,NA/2)+angleomit;
    angle = base_angle+[angle, -angle];
end

% XY position
Y = zeros(2,NA);
% Y(:,1) = rad;

[Xc, Yc] = meshgrid(xcoor,ycoor);
h = interp2(Xc,Yc,DEM,rad(1),rad(2));

opt.Display = 'off';

for k=1:NA
    fun = @(x) find_range(x,DEM,Xc,Yc,center,angle(k),h);
    if(k~=1)
        r(k) = fzero(fun,r(k-1),opt);
    else
        r(k) = fzero(fun,r(1),opt);
    end
    Y(:,k) = center+r(k)*[cos(angle(k)); sin(angle(k))];
end

end

% cost function for intercept
function cost = find_range(r,D,Xc,Yc,center,angle,h)
    pt = center+r*[cos(angle); sin(angle)];
    hpt = interp2(Xc,Yc,D,pt(1),pt(2));
    
    cost = h-hpt;
end