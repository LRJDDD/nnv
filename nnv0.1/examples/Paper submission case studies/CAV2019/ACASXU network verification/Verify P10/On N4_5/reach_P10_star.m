load ACASXU_run2a_4_5_batch_2000.mat;
Layers = [];
n = length(b);
for i=1:n - 1
    bi = cell2mat(b(i));
    Wi = cell2mat(W(i));
    Li = Layer(Wi, bi, 'ReLU');
    Layers = [Layers Li];
end
bn = cell2mat(b(n));
Wn = cell2mat(W(n));
Ln = Layer(Wn, bn, 'Linear');

Layers = [Layers Ln];
F = FFNN(Layers);

% Input Constraints (see paper Reluplex: An Efficient SMT Solver for Verifying Deep Neural Networks, CAV 2017)
% 36000<= i1 (\rho) <= 60760,  
% 0.7<= i2 (\theta) <= 3.141592
% -3.141592 <= i3 (\shi) <= -3.141592 + 0.01
% 900 <= i4 (\v_own) <= 1200,
% 600 <= i5 (\v_in) <= 1200

lb = [36000; 0.7; -3.141592; 900; 600];
ub = [60760; 3.141592; -3.141592 + 0.01; 1200; 1200];

% normalize input
for i=1:5
    lb(i) = (lb(i) - means_for_scaling(i))/range_for_scaling(i);
    ub(i) = (ub(i) - means_for_scaling(i))/range_for_scaling(i);   
end

load ACASXU_run2a_3_3_batch_2000.mat;
Layers = [];
n = length(b);
for i=1:n - 1
    bi = cell2mat(b(i));
    Wi = cell2mat(W(i));
    Li = Layer(Wi, bi, 'ReLU');
    Layers = [Layers Li];
end
bn = cell2mat(b(n));
Wn = cell2mat(W(n));
Ln = Layer(Wn, bn, 'Linear');

Layers = [Layers Ln];
F = FFNN(Layers);

% Input Constraints (see paper Reluplex: An Efficient SMT Solver for Verifying Deep Neural Networks, CAV 2017)
% 2000 <= i1 (\rho) <= 7000,  
% -0.4 <= i2 (\theta) <= -0.14
% -3.141592 <= i3 (\shi) <= -3.141592 + 0.01
% 100 <= i4 (\v_own) <= 150,
% 0 <= i5 (\v_in) <= 150

lb = [2000; -0.4; -3.141592; 100; 0];
ub = [60760; -0.14; -3.141592 + 0.01; 150; 150];

% normalize input
for i=1:5
    lb(i) = (lb(i) - means_for_scaling(i))/range_for_scaling(i);
    ub(i) = (ub(i) - means_for_scaling(i))/range_for_scaling(i);   
end

B = Box(lb, ub);
I = B.toStar;

numCores = 90; % number of cores used in computation

[R, t] = F.reach(I, 'exact', numCores, []); % exact reach set
outputSet = F.outputSet;
save outputSet.mat outputSet; % save the verified network
F.print('F.info'); % print all information to a file
