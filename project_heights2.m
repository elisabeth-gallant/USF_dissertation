function profiles = project_heights2(DEMcont,DEM,xcoor,ycoor,walk,dr,L,nanmap)

Np = size(walk,2);
profiles = cell(1,Np-2);
[Xc, Yc] = meshgrid(xcoor,ycoor);
DEM3d(3,:)=DEM(:);
DEM3d(1,:)=Xc(:);
DEM3d(2,:)=Yc(:);

if(nargin==8)
    DEM3d(:,nanmap)=[];
end

f = waitbar(0,'Getting Profile');

for k=1:Np-2
    waitbar(k/(Np-2),f,['Getting Profile ' num2str(k) ' of ' num2str(Np-2)]);
    
    cur = k+1;
    
    % length of whole ellipse
    totalL = 2*pi*sqrt((DEMcont{cur}.efit(3)^2+DEMcont{cur}.efit(4)^2)/2);
    
    % base angle
    base_angle = atan2(walk(2,cur)-DEMcont{cur}.efit(2),...
        walk(1,cur)-DEMcont{cur}.efit(1));
    
    % step over dr to cover the whole ellipse
    if(L>totalL)
        L = totalL;
    end
    
    NL = round(L/dr)+1;
    profiles{k}.XY = zeros(2,NL);
    profiles{k}.H = zeros(1,NL);
    profiles{k}.len = zeros(1,NL);
    profiles{k}.angle = zeros(1,NL);
    profiles{k}.Nvec = zeros(3,NL);
    
    % first point
    [profiles{k}.XY(:,1), profiles{k}.H(1), profiles{k}.Nvec(:,1), profiles{k}.slope(1)] = ...
        get_transforms2(DEMcont,cur,base_angle,dr,DEM3d);
    profiles{k}.angle(1) = base_angle;
    profiles{k}.len(1) = 0;
    
    % walk over positive length direction
    n=1;
    for walkdist = dr:dr:L/2
        n=n+1;
        fun = @(dt) find_dt(dt,DEMcont{cur}.efit,profiles{k}.XY(1,n-1),...
            profiles{k}.XY(2,n-1),profiles{k}.angle(n-1),dr);
        theta = fminbnd(fun,0,pi/2);
        
        profiles{k}.angle(n) = profiles{k}.angle(n-1)+theta;
        profiles{k}.len(n) = walkdist;
        
        [profiles{k}.XY(:,n), profiles{k}.H(n), profiles{k}.Nvec(:,n), profiles{k}.slope(n)] = ...
            get_transforms2(DEMcont,cur,profiles{k}.angle(n),dr,DEM3d);
    end
    
    % walk over negative length direction
    mid = n;
    % first step
    n=n+1;
    fun = @(dt) find_dt(dt,DEMcont{cur}.efit,profiles{k}.XY(1,1),...
        profiles{k}.XY(2,1),profiles{k}.angle(1),dr);
    theta = fminbnd(fun,-pi/2,0);
    
    profiles{k}.angle(n) = profiles{k}.angle(1)+theta;
    profiles{k}.len(n) = -dr;
    
    [profiles{k}.XY(:,n), profiles{k}.H(n), profiles{k}.Nvec(:,n), profiles{k}.slope(n)] = ...
        get_transforms2(DEMcont,cur,profiles{k}.angle(n),dr,DEM3d);
    
    % subsequent steps
    for walkdist = -2*dr:-dr:-L/2
        n=n+1;
        fun = @(dt) find_dt(dt,DEMcont{cur}.efit,profiles{k}.XY(1,n-1),...
            profiles{k}.XY(2,n-1),profiles{k}.angle(n-1),dr);
        theta = fminbnd(fun,-pi/2,0);
        
        profiles{k}.angle(n) = profiles{k}.angle(n-1)+theta;
        profiles{k}.len(n) = walkdist;
        
        [profiles{k}.XY(:,n), profiles{k}.H(n), profiles{k}.Nvec(:,n), profiles{k}.slope(n)] = ...
            get_transforms2(DEMcont,cur,profiles{k}.angle(n),dr,DEM3d);
    end
    
    index = [(n:-1:mid+1), 1:mid];
    
    profiles{k}.XY = profiles{k}.XY(:,index);
    profiles{k}.H = profiles{k}.H(index);
    profiles{k}.len = profiles{k}.len(index);
    profiles{k}.angle = profiles{k}.angle(index);
    profiles{k}.Nvec = profiles{k}.Nvec(:,index);
    profiles{k}.slope = profiles{k}.slope(index);
%     plot(profiles{k}.len,profiles{k}.H);
%     savefig(['profile at ', num2str(DEMcont{cur}.h),'m elevation.fig']);
%     saveas(gcf,['profile at ', num2str(DEMcont{cur}.h),'m elevation.jpg']);
    
end

close(f);

end

