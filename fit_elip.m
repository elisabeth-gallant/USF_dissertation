function [pout, cost] = fit_elip(X,wt)

lb = [0; -inf; 0; min(X,[],2)];
ub = [inf; inf; inf; max(X,[],2)];

p = [1;1;1;mean(X,2)];

fun = @(y) Ecost(y,X,wt);
noncon = @(y) nonlin(y);

[pout, cost] = fmincon(fun,p,[],[],[],[],lb,ub,noncon);

end

function cost=Ecost(p,X,wt)
    z = p(1)*(X(1,:)-p(4)).^2+p(2)*(X(1,:)-p(4)).*(X(2,:)-p(5))+...
        p(3)*(X(2,:)-p(5)).^2;
    
    cost = mean(abs(z-1).*wt);
end

function [cost, costeq]=nonlin(p)
    cost = zeros(5,1);
    cost(1:3) = p(2)^2-4*p(1)*p(3);
    costeq = zeros(5,1);
end