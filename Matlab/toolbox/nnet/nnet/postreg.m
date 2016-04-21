function [m,b,r] = postreg(a,t)
%POSTREG Postprocesses the trained network response with a linear regression.
%  
%  Syntax
%
%    [m,b,r] = postreg(A,T)
%
%  Description
%  
%    POSTREG postprocesses the network training
%    set by performing a linear regression between one element
%     of the network response and the corresponding target.
%  
%    POSTREG(A,T) takes these inputs,
%      A - 1xQ array of network outputs. One element of the network output.
%       T - 1xQ array of targets. One element of the target vector.
%    and returns,
%       M - Slope of the linear regression.
%       B - Y intercept of the linear regression.
%       R - Regression R-value.  R=1 means perfect correlation.
%    
%  Example
%
%    In this example we normalize a set of training data with
%     PRESTD, perform a principal component transformation on
%     the normalized data, create and train a network using the pca
%     data, simulate the network, unnormalize the output of the
%     network using POSTSTD, and perform a linear regression between 
%     the network outputs (unnormalized) and the targets to check the
%     quality of the network training.
%  
%      p = [-0.92 0.73 -0.47 0.74 0.29; -0.08 0.86 -0.67 -0.52 0.93];
%       t = [-0.08 3.4 -0.82 0.69 3.1];
%      [pn,meanp,stdp,tn,meant,stdt] = prestd(p,t);
%       [ptrans,transMat] = prepca(pn,0.02);
%       net = newff(minmax(ptrans),[5 1],{'tansig' 'purelin'},'trainlm');
%       net = train(net,ptrans,tn);
%       an = sim(net,ptrans);
%       a = poststd(an,meant,stdt);
%       [m,b,r] = postreg(a,t);
%
%  Algorithm
%
%     Performs a linear regression between the network response
%     and the target, and computes the correlation coefficient
%     (R value) between the network response and the target.
%
%  See also PREMNMX, PREPCA.

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $  $Date: 2002/04/14 21:30:38 $

Q = length(a);

h = [t' ones(size(t'))];
at = a';
theta = h\at;
m = theta(1);
b = theta(2);

cla reset
plot(t,a,'o')
tsort = sort(t);
line = m*tsort + b;
hold on
plot(tsort,line,'r')
plot(tsort,tsort,':')
xlabel('T');
ylabel('A');
axis('square')

an = a - mean(a);
tn = t - mean(t);
sta = std(an);
stt = std(tn);
r = an*tn'/(Q - 1);
r = r/(sta*stt);

v = axis;
alpha1 = 0.05;
alpha2 = 0.1;
llx = alpha1*v(2) + (1-alpha1)*v(1);
lly = (1-alpha2)*v(4) + alpha2*v(3);
index = fix(Q/2);
title(['Best Linear Fit:  A = (',num2str(m,3),') T + (', num2str(b,3), ')']);
text(llx,lly,['R = ', num2str(r,3)]);
legend('Data Points','Best Linear Fit','A = T',-1);

hold off
