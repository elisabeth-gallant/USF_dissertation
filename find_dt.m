function cost = find_dt(dt,p,x,y,angle,dr)
    xt = p(1)+p(3)*cos(angle+p(5)+dt);
    yt = p(2)+p(4)*sin(angle+p(5)+dt); 
    
    cr = sqrt((x-xt)^2+(y-yt)^2);
    
    cost = abs(dr-cr);
end