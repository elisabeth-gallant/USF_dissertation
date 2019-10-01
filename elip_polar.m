function Y = elip_polar(p,angle)

Y = [p(1)+p(3)*cos(angle+p(5)); p(2)+p(4)*sin(angle+p(5))];