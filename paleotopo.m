function DEMout = paleotopo(DEMcont,profiles,DEM,xcoor,ycoor,csvfile)

ND = length(DEMcont);

for k=2:ND
    heights(k-1) = (DEMcont{k}.h+DEMcont{k-1}.h)/2;
end

C = jet;
N = length(profiles{1}.H);

fac = [1, 2, 2+N, 1+N];
while(fac(end,3)<2*N)
    fac = [fac; fac(end,:)+1];
end

LH = linspace(min(heights),max(heights),64);

% all xyz points of the paleo topo thing
all_cont = [profiles{1}.XY; DEMcont{2}.h*ones(1,N)];

for k=2:length(profiles)

    prev = [profiles{k-1}.XY; DEMcont{k}.h*ones(1,N)];
    cur = [profiles{k}.XY; DEMcont{k+1}.h*ones(1,N)];
    
    all_cont = [all_cont, cur];
    
    vert = [prev, cur]';
    
    ix = interp1(LH,1:64,heights(k-1),'nearest');
    
    patch('faces',fac,'vertices',vert,'facecolor',C(ix,:),'edgecolor','none')
end

axis equal;
axis vis3d;

cb = colorbar;
colormap(jet);
set(cb,'ytick',0:0.125:1,'yticklabel',num2str(linspace(min(heights),max(heights),9)',4));

DEMout = DEM;
resy = ycoor(2)-ycoor(1);
Ywin = [min(all_cont(2,:))-resy, max(all_cont(2,:))+resy];
resx = xcoor(2)-xcoor(1);
Xwin = [min(all_cont(1,:))-resx, max(all_cont(1,:))+resx];
s = size(DEM);
mindist = 3*sqrt(resx^2/4+resy^2/4);
for k=1:s(1)
    if(ycoor(k)>=Ywin(1) && ycoor(k)<=Ywin(2))
        for j=1:s(2)
            if(xcoor(j)>=Xwin(1) && xcoor(j)<=Xwin(2))
                point = [xcoor(j); ycoor(k)];
                dist = sqrt(sum(bsxfun(@minus,all_cont(1:2,:),point).^2));
                [D, ix] = min(dist);
                if(D<=mindist)
                    DEMout(k,j) = all_cont(3,ix);
                end
            end
        end
    end
end

% hold on;
% imagesc(xcoor,ycoor,DEM,[min(heights), max(heights)])


if(nargin==6)
[XC, YC] = meshgrid(xcoor,ycoor);
YC = flipud(YC);
topomat = [XC(:), YC(:), DEMout(:)];

csvwrite(csvfile,topomat);
end