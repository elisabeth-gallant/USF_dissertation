function DEMcont = create_contour(DEM,xcoor,ycoor,center,walk,omit_center,keep_side,NA)

Np = size(walk,2);

DEMcont = cell(1,Np);
% get the contours along the walk
f = waitbar(0,'Contour Mapping');
for k=1:Np
    waitbar((k-1)/Np,f,['Contour Mapping ', num2str(k), ' of ' num2str(Np)]);
    [DEMcont{k}.Y, DEMcont{k}.angle, DEMcont{k}.r, DEMcont{k}.h] = ...
        contour_pt2(DEM,xcoor,ycoor,center,walk(:,k),omit_center,keep_side,NA);
end

% fit ellipses to data
% first point
waitbar(1/Np,f,['Contour Fitting 1 of ' num2str(Np)]);
[DEMcont{1}.efit, DEMcont{1}.efitcost] = fit_elip_polar(DEMcont{1}.Y,...
    center);
% subsequent points
for k=2:Np
    waitbar((k-1)/Np,f,['Contour Fitting', num2str(k), ' of ' num2str(Np)]);
[DEMcont{k}.efit, DEMcont{k}.efitcost] = fit_elip_polar(DEMcont{k}.Y,...
    [],DEMcont{k-1}.efit);    
end
close(f);