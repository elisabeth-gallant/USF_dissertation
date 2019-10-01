function [XY, height, Nvec, slope] = get_transforms2(DEMcont,cur,angle,dr,DEM3d)

DEMpts = zeros(3,9);

% center point
DEMpts(:,1) = [elip_polar(DEMcont{cur}.efit,angle); DEMcont{cur}.h];

% adjacent points in 'h'
DEMpts(:,2) = [elip_polar(DEMcont{cur-1}.efit,angle); DEMcont{cur-1}.h];
DEMpts(:,3) = [elip_polar(DEMcont{cur+1}.efit,angle); DEMcont{cur+1}.h];

% adjacent points in + angle
fun = @(dt) find_dt(dt,DEMcont{cur}.efit,DEMpts(1,1),DEMpts(2,1),angle,dr);
theta1 = fminbnd(fun,0,pi/2);
theta2 = fminbnd(fun,-pi/2,0);
for k=-1:1
    DEMpts(:,k+5) = [elip_polar(DEMcont{cur+k}.efit,angle+theta1); DEMcont{cur+k}.h];
    DEMpts(:,k+8) = [elip_polar(DEMcont{cur+k}.efit,angle+theta2); DEMcont{cur+k}.h];
end

% compute a best fit plane (least squares of normal distance)
pts = mean(DEMpts,2);

R = bsxfun(@minus,DEMpts,pts);

[V, D] = eig(R*R');

% normal vector to the plane
Nvec = V(:,1);
% force upward pointing normal
if(Nvec(3)<0)
    Nvec = -Nvec;
end

% XY location
XY = DEMpts(1:2,1);

% Height relative to ellipse fits
% fun = @(a) find_height(a,DEM,Xc,Yc,Nvec,DEMpts(:,1));
% 
% H = fzero(fun,0);

% get rotation matrix
q = cross(Nvec,[0;0;1]);
q = q/norm(q);
w = cross(q,Nvec); w=w/norm(w);
rot = [q,w,Nvec]';

slope=-asin(Nvec(3))*180/pi;

% rotated points
A = rot*(bsxfun(@minus,DEM3d,DEMpts(:,1)));

% get 4 nearest rotated points
num = 1:size(A,2);
ra = sqrt(sum(A(1:2,:).^2));

% 
% inx = ra<dr;
% if(any(inx))
%     num = num(inx);
%     [~,ix] = min(abs(A(3,num)));
%     height = A(3,num(ix));
% else
%     [~, inx] = min(ra);
%     height = A(3,inx);
% end

% % pt1
inx = A(1,:)>=0 & A(2,:)>=0;
[rw(1),ix] = min(ra(inx));
ind = num(inx);
H(1) = A(3,ind(ix));

% pt2
inx = A(1,:)<=0 & A(2,:)>=0;
[rw(2),ix] = min(ra(inx));
ind = num(inx);
H(2) = A(3,ind(ix));

% pt3
inx = A(1,:)>=0 & A(2,:)<=0;
[rw(3),ix] = min(ra(inx));
ind = num(inx);
H(3) = A(3,ind(ix));

% pt4
inx = A(1,:)<=0 & A(2,:)<=0;
[rw(4),ix] = min(ra(inx));
ind = num(inx);
H(4) = A(3,ind(ix));

height = sum(H.*(sum(rw)-rw)/sum(sum(rw)-rw));

end

function cost = find_height(a,DEM,Xc,Yc,Nvec,pos)

newPos = a*Nvec+pos;

terrainH = interp2(Xc,Yc,DEM,newPos(1),newPos(2));

cost = terrainH-newPos(3);
end