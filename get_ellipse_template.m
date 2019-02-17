% inputs:
%   major - major axis length
%   minor - minor axis length
%   orientation - angle between the Y-axis and the major axis
%   NA - desired number of angles to sample the ellipse
% outputs:
%   angles - uniform set of NA sample locations in degrees
%   template - template distance from the origin at specified angles with
%     respect to the Y axis
function [angles, template] = get_ellipse_template(major,minor,orientation,NA)

% desired uniform sampling in angle
angles = linspace(0,2*pi,NA);

% calculate the outline of the template
X = major*cos(angles)*cos(orientation)-minor*sin(angles)*sin(orientation);
Y = major*cos(angles)*sin(orientation)+minor*sin(angles)*cos(orientation);

% plot the template
figure;
plot(X,Y);
axis equal;

% distance from mean with respect to parametric representation
template = sqrt(X.^2+Y.^2);

% angle between the template point (X,Y) and the Y-axis
shift_angles = atan2(X,Y);

% make angles positive by definition
shift_angles(shift_angles<0) = shift_angles(shift_angles<0)+2*pi;
[shift_angles, inx] = sort(shift_angles);
template = template(inx);

% pad the template with negative angle definition
shift_angles = [shift_angles(end-5:end-1)-2*pi, shift_angles];
template = [template(end-5:end-1), template];

% pad the template with angles > 2pi
shift_angles = [shift_angles shift_angles(6:9)+2*pi];
template = [template template(6:9)];

% interpolate the template to uniform angles 0-2pi
template = interp1(shift_angles,template,angles,'spline');

% convert angles in radians to degrees
angles = angles*180/pi;
