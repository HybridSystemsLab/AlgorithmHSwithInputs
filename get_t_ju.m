function S_u = get_s_ju(s,j,j_u)

    min = -1;
    max = -1;
    if j_u <= j(end)
        for i = 2:1:length(j)
            if j(i) == j_u
                if min == -1
                    min = i;
                end
            end
            if (j(i) - j(i-1)) > 0
                if j(i-1) == j_u
                    max = i-1;
                end
            end
        end
        S_u = s(min:max);
    else
        error('Error. j_u exceeds supJ')
    end
end