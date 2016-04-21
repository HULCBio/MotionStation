% TRAININV Train two ANFISs for inverse modeling of two-link robot arm.
%   The trained ANFISs are used in the demo invkine.m. 

%   J.-S. Roger Jang, 6-28-94.
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/14 22:17:24 $

% collect training data
l1 = 10;
l2 = 7;
bound = [0 19; 0 19];
point = 20;
x = linspace(bound(1,1), bound(1,2), point);
y = linspace(bound(2,1), bound(2,2), point);
th1 = zeros(length(x), length(y));
th2 = zeros(length(x), length(y));
data1 = zeros(point^2, 3); 
data2 = zeros(point^2, 3); 

data_n = 1;
for i = 1:length(x),
    fprintf('Iteration count = %d\n', i);
    for j = 1:length(y),
        xx = x(i);
        yy = y(j);
        c2 = (xx^2 + yy^2 - l1^2 - l2^2)/(2*l1*l2);
        s2 = sqrt(1 - c2^2);
        th2(i, j) = atan2(s2, c2);

        k1 = l1 + l2*c2;
        k2 = l2*s2;
        th1(i, j) = atan2(yy, xx) - atan2(k2, k1);

        if abs(c2) < 1;
            data1(data_n, :) = [xx yy th1(i, j)];
            data2(data_n, :) = [xx yy th2(i, j)];
            data_n = data_n + 1;
        end
    end
end

invkine1 = data1(1:data_n, :);
invkine2 = data2(1:data_n, :);

% save training data sets
% save invkine.mat invkine1 invkine2

% load data sets for training
load invkine.mat

% training 1
[fismat1, error1] = anfis(invkine1, 3, [50, 0, 0.2]);
% writefis(fismat1, 'invkine1.fis');

% training 2
[fismat2, error2] = anfis(invkine2, 3, [50, 0, 0.2]);
% writefis(fismat2, 'invkine2.fis');
