function irisfcm
% IRISFCM Fuzzy c-means clustering demo (4-D).
%   This is a script illustrating how to use fuzzy c-means routines for
%   IRIS data clustering, with on-line animation.
%
%   See also DISTFCM, INITFCM, FCMDEMO, STEPFCM, FCM.

%   R. Jang, 12-12-94.
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/14 22:16:05 $

load iris.dat               % Load data
class1 = iris(find(iris(:,5)==1), :);   % data for class 1
class2 = iris(find(iris(:,5)==2), :);   % data for class 2
class3 = iris(find(iris(:,5)==3), :);   % data for class 3
data = iris;                % whole data set to be clustered
data_n = size(data, 1);         % number of data 

expo = 2.0;         % Exponent for U
cluster_n = 3;          % Number of clusters
max_iter = 100;         % Max. iteration
min_impro = 1e-6;       % Min. improvement
obj_fcn = zeros(max_iter, 1);   % Array for objective function
digitH = zeros(cluster_n, 6);   % Array for handles of cluster centers

U = initfcm(cluster_n, data_n);         % Initial fuzzy partition
[U, center] = stepfcm(data, U, cluster_n, expo);% Initial cluster centers

% Project data to 2-D and plot them 
mark = '.';
seq = [1 2; 1 3; 1 4; 2 3; 2 4; 3 4];
for j = 1:6,
    x = seq(j, 1); y = seq(j, 2);   % inputs selected for plot
    subplot(2,3,j);
    h = plot([class1(:,x) class2(:,x) class3(:,x)], ...
         [class1(:,y) class2(:,y) class3(:,y)], mark);
    set(h, 'markersize', 8);
    xlabel(['x' int2str(x)]); ylabel(['x' int2str(y)]);
    % Initialize centers
    for k = 1:cluster_n,
        digitH(k,j) = text(center(k, seq(j,1)), ...
            center(k,seq(j,2)), int2str(k));
        set(digitH(k,j), 'erase', 'xor', 'horizon', 'center');
    end
end

% Main loop
for i = 1:max_iter,
    [U, center, obj_fcn(i)] = stepfcm(data, U, cluster_n, expo);
    fprintf('Iteration count = %d, obj. fcn = %f\n', i, obj_fcn(i));
    if i > 1,   % check termination condition
        if abs(obj_fcn(i) - obj_fcn(i-1)) < min_impro, break; end,
    end
    % refresh centers for animation
    for j = 1:6,
        for k = 1:cluster_n,
            set(digitH(k,j), 'pos', center(k, seq(j,:)));
        end
    end
    drawnow;
end

% Plot of objection function
iter_n = i;         % Actual number of iterations 
figure;             % New figure
obj_fcn(iter_n+1:max_iter) = [];% Delete unused elements
plot(obj_fcn); axis([1 i min(obj_fcn) max(obj_fcn)]);
title('Objective Function for IRIS Data Clustering');
xlabel('Numbers of Iterations');
