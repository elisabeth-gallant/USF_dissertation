function [Y, H, h] = plot_profiles(profiles, DEMcont)

np = length(profiles);

for k=1:np
    mid = floor(length(profiles{k}.H)/2)+1;
    
    h = DEMcont{k}.h;
    
    r = sqrt(sum(diff(profiles{k}.XY,[],2).^2));
    
    center = sum(r(1:mid));
    
    x = [0,cumsum(r)]-center;
    
    plot(x,profiles{k}.H);

    axis([-150 150 -40 35]);
    
    temp= ['profile at',num2str(DEMcont{k}.h),'.jpg']
    
    saveas(gca, temp);

end





end