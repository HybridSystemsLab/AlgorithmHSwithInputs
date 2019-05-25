function domB = domAdd(t_j,j,domA)
    domB = domA;
    [m,n] = size(domA);
    for i = 1:1:m
        domB(i,:) = [domA(i,1) + t_j, domA(i,2) + t_j, domA(i,3) + j];
    end
end