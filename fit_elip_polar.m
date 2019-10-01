function [p, C] = fit_elip_polar(Y,center,pg)

if(nargin==2)
    pg = [center; max(abs(bsxfun(@minus,Y,center)),[],2); pi/4];
end

lb = [-inf; -inf; 0; 0; -pi];
ub = [inf; inf; inf; inf; pi];

fun = @(x) cost_efit(x,Y);

opt.Display = 'off';
[p, C] = fmincon(fun,pg,[],[],[],[],lb,ub,[],opt);

% [p, C] = lsqnonlin(fun,pg,lb,ub);

end

function cost = cost_efit(x,Y)

    pos = bsxfun(@minus,Y,x(1:2));
    angle = atan2(pos(2,:),pos(1,:));
    Yfit = [x(1)+x(3)*cos(angle+x(5));x(2)+x(4)*sin(angle+x(5))];
    cost = mean(sqrt(sum((Y-Yfit).^2)));

%     cost = (sqrt(sum((Y-Yfit).^2)));

end