clear all    

global tbar_a tbar_b

% simulation variables for \HS_a and \HS_b and associated initial
% conditions
tbar_a = 1;
tbar_b = 0.5;
x_a0 = 0;
x_b0 = 0.3;

% rule for jumps
% rule = 1 -> priority for jumps
% rule = 2 -> priority for flows
% rule = 3 -> no priority : random  %% to be defined
rule = 1;
options = odeset('RelTol',1e-6,'MaxStep',.01);

% simulation horizon for \HS_a
TSPAN=[0 10];
JSPAN = [0 1000];

% simulation of solution to \HS_a
[t_a, j_a, x_a] = HyEQsolver(@f_a,@g_a,@C_a,@D_a,x_a0,TSPAN,JSPAN,rule,options);

% initialization of variables for Algo III
j = 0;
t_j = 0;

% final vectors for plotting
j_b = [];
t_b = [];

% Set D where [t_j, t_{j+1}, j]
D_set = [];

x_b = [];
u_r = [];
t_u_r = [];
j_u_r = [];
p_u = [0 0];

for j_u = 0:1:j_a(end)
    u_CT = get_s_ju(x_a,j_a,j_u);
    t_CT = get_s_ju(t_a,j_a,j_u);
    
    if (isempty(t_CT))
        break
    else
        t_CT = t_CT-t_CT(1);
    end
    T_u = t_CT(end);
    
    % Check if there is no solution
    if ((D_b(x_b0) == 0) && (cl_C_b(x_b0) == 0))
        break
    else

        % simulation of solution to \HS_2
        [t_bar, j_bar, x_bar] = HyEQsolver(@f_b,@g_b,@C_b,@D_b,x_b0,[0 T_u],JSPAN,rule,options);
        
        % removal of the jumps occurring in x_bar at time T_u
        if (t_bar(end)>=T_u)
            x_p = x_bar(t_bar<T_u);
            x_p = [x_p;x_bar(size(x_p,1)+1,:)];
            x_bar = x_p;
            t_bar = t_bar(1:size(x_bar,1));
            j_bar = j_bar(1:size(x_bar,1));
        end
        
        x_b = [x_b; x_bar];
        t_b = [t_b; t_j + t_bar];
        j_b = [j_b; j + j_bar];
        T_m = t_bar(end);
        j_m = j_bar(end);
        
        % construction of u^r
        dom_bar = dom(t_bar,j_bar);
        u_bar = [];
        t_u_bar = [];
        j_u_bar = [];
        if size(dom_bar,1)==1  % meaning \HS_b does not jump on the interval
            u_bar = u_CT;
            t_u_bar = t_CT;
            j_u_bar = zeros(size(u_CT));
        else
            for k=1:size(dom_bar,1)
                tt1 = dom_bar(k,1);
                tt2 = dom_bar(k,2);
                jj = dom_bar(k,3);
                range = logical((t_CT>=tt1).*(t_CT<=tt2));
                if sum(range)==0
                    u_bar = [u_bar; u_bar(end)];
                    t_u_bar = [t_u_bar; t_u_bar(end)];
                    j_u_bar = [j_u_bar; jj];
                else
                    u_bar = [u_bar; u_CT(range)];
                    t_u_bar = [t_u_bar; t_CT(range)];
                    j_u_bar = [j_u_bar; jj*ones(size(u_CT(range)))];
                end
            end
        end
        t_u_r = [t_u_r; t_j + t_u_bar];
        j_u_r = [j_u_r; j+ j_u_bar];
        u_r = [u_r; u_bar];
        

        % Checking condtions for whether the solution \HS_b has reached
        % the end of the flow
        Tm_flag = 0;
        
        if(T_m>0 && ((D_b(x_b(end)) == 0) && (C_b(x_b(end)) == 0)))
            Tm_flag = 1;
        end

        if((D_b(x_b(end)) == 0) && (cl_C_b(x_b(end)) == 0))
            Tm_flag = 1;
        end

        if (T_m < T_u)
            Tm_flag = 1;
        end


        if (Tm_flag == 1)
            break;
        else
            t_j = t_j + T_m;
            j = j + j_m + 1;
            if T_m > 0
                x_b0 = Ge(x_b(end),@C_b,@D_b,@g_b,rule);
            else
                x_b0 = Ge(x_b(end),@cl_C_b,@D_b,@g_b,rule);
            end
        end
    end
end


%%

figure(1)
clf
subplot(1,1,1)
plotHarc(t_a,j_a,x_a);
hold on
plotHarc(t_b,j_b,x_b,[],{'r'},{'r--','Marker','*'});
% leg=legend('$x_1$','$x$')
%set(leg, 'Interpreter', 'latex')
xlabel('t')
title('Hybrid trajectories: $(x_a,x_b)$','Interpreter','latex')
grid on

figure(2)
clf
subplot(1,1,1)
plotHarc(t_u_r,j_u_r,u_r);
hold on
plotHarc(t_b,j_b,x_b,[],{'r'},{'r--','Marker','*'});
% leg=legend('$x_{a,cl}$','$x_b$')
% set(leg, 'Interpreter', 'latex')
xlabel('t')
title('Hybrid trajectories: $(x_{a,cl},x_b)$','Interpreter','latex')
grid on

figure(3)
subplot(211)
plotjumps(t_a,j_a,x_a);
xlabel('j')
title('Jumps of H_a')
subplot(212)
plotjumps(t_b,j_b,x_b);
title('Jumps of H_b')
xlabel('j')




