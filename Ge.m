function xplus = Ge(x,C,D,G, rule)

% rule for jumps
% rule = 1 -> priority for jumps
% rule = 2 -> priority for flows

if (C(x)==1 && D(x)==0)
    xplus = x;
elseif (C(x)==0 && D(x)==1)
    xplus = G(x);
elseif (C(x)==1 && D(x)==1)
    if (rule==1)
        xplus = G(x);
    elseif (rule==2)
        xplus = x;
    else
        pos = [x,G(x)];
        xplus = pos(randi(2));
    end
else 
    display('x is not in C or D')
end

end