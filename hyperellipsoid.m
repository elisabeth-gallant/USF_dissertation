% inputs:
%   p(6) = [A, B, x0, y0, z0, theta]
%       A-> axis about X
%       b-> axis about Y
%       x0-> x coordinate of center
%       y0-> y coordinate of center
%       z0-> height at center
%       theta-> rotation of hyperellipsoid
%   x(2,:) = [x coordinate; y coordinate] to calculate height
%
% output:
%   z(1,:) = height of hyper ellipsoid at x
function z = hyperellipsoid(p,x)

C = cos(p(6));
S = sin(p(6));

z = (p(1)*C^2+p(2)*S^2)*(x(1,:)-p(3)).^2+...
    (p(1)*S^2+p(2)*C^2)*(x(2,:)-p(4)).^2+...
    2*(p(2)-p(1))*S*C*(x(1,:)-p(3)).*(x(2,:)-p(4))+p(5);