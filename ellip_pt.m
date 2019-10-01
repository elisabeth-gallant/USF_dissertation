function Y = ellip_pt(p,X)

Y = zeros(2,2*length(X));

Y(1,:) = [X, X];

for k=1:length(X)
    a = p(3);
    b = p(2)*(X(1,k)-p(4))-2*p(3)*p(5);
    c = p(1)*(X(1,k)-p(4))^2-1-p(2)*p(5)*(X(1,k)-p(4))+p(3)*p(5)^2;
    
    tmp = b^2-4*a*c;
    if(tmp>0)
        Y(2,k) = (-b+sqrt(tmp))/(2*a);
        Y(2,k+length(X)) = (-b-sqrt(tmp))/(2*a);
    else
        Y(2,k) = nan;
        Y(2,k+length(X)) = nan;
    end
end

Y(:,isnan(Y(2,:))) = [];
% Y(1,:) = Y(1,:)+p(4);
% Y(2,:) = Y(2,:)+p(5);