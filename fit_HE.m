function [p1, cost] = fit_HE(x,z)

lb = [-inf; -inf; -inf; -inf; 0; 0];
ub = [0; 0; inf; inf; inf; pi/2];

% get a set of potential starting points
Ns=10000;
psam(6,:) = rand(1,Ns)*pi/2;
psam(5,:) = rand(1,Ns)*max(z(:));
psam(4,:) = rand(1,Ns)*(max(x(2,:))-min(x(2,:)))+min(x(2,:));
psam(3,:) = rand(1,Ns)*(max(x(1,:))-min(x(1,:)))+min(x(1,:));
psam(1:2,:) = -rand(2,Ns)-0.1;

C = ones(1,Ns)*inf;

for k=1:Ns
    C(k) = HE_MSE(psam(:,k),x,z);
end

nk = 500;
[C, ind] = sort(C);
psam = psam(:,ind);

Nit=25;
fit_fun = @(p) HE_MSE(p,x,z);
for k=1:Nit
    I = max(C)-C;
    CDF = I/sum(I);
    CDF = cumsum(CDF);
    for j=1:Ns-nk
        ix = rand(3,1);
        ix = interp1(CDF(1:end-1),1:Ns-1,ix,'nearest');
        lam = .4+rand(1)*.2;
        ix(isnan(ix)) = 1;
        kid(:,j) = psam(:,ix(1))+lam*(psam(:,ix(2))-psam(:,ix(3)));
        
        test = kid(:,j)<lb | kid(:,j)>ub;
        if(test(1))
            kid(1,j) = -rand(1);
        end
        if(test(2))
            kid(2,j) = -rand(1);
        end
        if(test(3))
            kid(3,j) = rand(1)*(max(x(1,:))-min(x(1,:)))+min(x(1,:));
        end
        if(test(4))
            kid(4,j) = rand(1)*(max(x(2,:))-min(x(2,:)))+min(x(2,:));
        end
        if(test(5))
            kid(5,j) = rand(1)*max(z(:));
        end
        if(test(6))
            kid(6,j) = rand(1)*pi/2;
        end
        C(j+nk) = fit_fun(kid(:,j));
    end
    psam(:,nk+1:end) = kid;
    [C, ind] = sort(C);
    psam = psam(:,ind);
    
end

[p1, cost] = fmincon(fit_fun,psam(:,1),[],[],[],[],lb,ub);

% [~, k] = min(C);
% 
% p0 = psam(:,k);
% fit_fun = @(p) HE_MSE(p,x,z);
% 
% [p1, cost] = fmincon(fit_fun,p0,[],[],[],[],lb,ub);

end

function cost = HE_MSE(p,x,z)

    HE = hyperellipsoid(p,x);
    cost = mean((HE-z).^2);
    
end