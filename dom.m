function dom1 = dom(t,j)

    temp = [t,j];
    t_j = t(1);
    k = 1;
    dom1 = zeros(j(end)+1,3);
    if(numel(j) < 2)
       dom1(k,:) = [t_j, t(1), j(1)];
    else
        for i = 2:1:length(temp)
            if (j(i)-j(i-1))
                dom1(k,:) = [t_j, t(i-1), j(i-1)];
                t_j = t(i);
                k = k+1;
            end
        end
    end
  
    dom1(end,:) = [t_j, t(end), j(end)];
end