%% Minimax optimization
% We use the Optimization Toolbox to solve a nonlinear filter design 
% problem. Note that to run this demo you must have the Signal Processing 
% Toolbox installed.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.20.4.2 $  $Date: 2004/04/06 01:10:19 $

%% Set finite precision parameters
% Consider an example for the design of finite precision filters.  For
% this, you need to specify not only the filter design parameters such 
% as the cut-off frequency and number of coefficients, but also how many
% bits are available since the design is in finite precision.
nbits  = 8;         % How many bits have we to realize filter 
maxbin = 2^nbits-1; % Maximum number expressable in nbits bits
n      = 4;         % Number of coefficients (order of filter plus 1)
Wn     = 0.2;       % Cutoff frequency for filter
Rp     = 1.5;       % Decibels of ripple in the passband
w      = 128;       % Number of frequency points to take 

%% Continuous design first
% This is a continuous filter design; we use |cheby1|, but we could also
% use |ellip|, |yulewalk| or |remez| here: 
[b1,a1]=cheby1(n-1,Rp,Wn); 

[h,w]=freqz(b1,a1,w);   % Frequency response
h = abs(h);             % Magnitude response
plot(w, h)
title('Frequency response using non-integer variables')
x = [b1,a1];            % The design variables

%% Set bounds for filter coefficients
% We now set bounds on the maximum and minimum values: 

if (any(x < 0))
%   If there are negative coefficients - must save room to use a sign bit
%   and therefore reduce maxbin
    maxbin = floor(maxbin/2);
    vlb = -maxbin * ones(1, 2*n)-1;
    vub = maxbin * ones(1, 2*n); 
else
%   otherwise, all positive
    vlb = zeros(1,2*n); 
    vub = maxbin * ones(1, 2*n); 
end

%% Scale coefficients
% Set the biggest value equal to maxbin and scale other filter coefficients
% appropriately.

[m, mix] = max(abs(x)); 
factor =  maxbin/m; 
x =  factor * x;    % Rescale other filter coefficients
xorig = x;

xmask = 1:2*n;
% Remove the biggest value and the element that controls D.C. Gain
% from the list of values that can be changed. 
xmask(mix) = [];
nx = 2*n; 

%% Set optimization criteria
% Using OPTIMSET, adjust the termination criteria to reasonably high values 
% to promote short running times. Also turn on the display of results
% at each iteration:

options = optimset('TolX',0.1,'TolFun',1e-4,'TolCon',1e-6,'Display','iter');

%% Minimize the absolute maximum values
% We need to minimize absolute maximum values, so we set options.MinAbsMax to
% the number of frequency points:

if length(w) == 1
   options = optimset(options,'MinAbsMax',w);
else
   options = optimset(options,'MinAbsMax',length(w));
end

%% Eliminate first value for optimization.
% Discretize and eliminate first value and perform optimization by calling
% FMINIMAX:
[x, xmask] = elimone(x, xmask, h, w, n, maxbin)

niters = length(xmask); 
disp(sprintf('Performing %g stages of optimization.\n\n', niters));

for m = 1:niters
    disp(sprintf('Stage: %g \n', m));
    x(xmask) = fminimax(@filtobj,x(xmask),[],[],[],[],vlb(xmask),vub(xmask), ...
                        @filtcon,options,x,xmask,n,h,maxbin);
    [x, xmask] = elimone(x, xmask, h, w, n, maxbin);
end

%% Check nearest integer values
% See if nearby values produce a for better filter.

xold = x;
xmask = 1:2*n;
xmask([n+1, mix]) = [];
x = x + 0.5; 
for i = xmask
    [x, xmask] = elimone(x, xmask, h, w, n, maxbin);
end
xmask = 1:2*n;
xmask([n+1, mix]) = [];
x= x - 0.5;
for i = xmask
    [x, xmask] = elimone(x, xmask, h, w, n, maxbin);
end
if any(abs(x) > maxbin)
  x = xold; 
end

%% Frequency response comparisons
% We first plot the frequency response of the filter and we compare it to a
% filter where the coefficients are just rounded up or down:

subplot(211)
bo = x(1:n); 
ao = x(n+1:2*n); 
h2 = abs(freqz(bo,ao,128));
plot(w,h,w,h2,'o')
title('Optimized filter versus original')

xround = round(xorig)
b = xround(1:n); 
a = xround(n+1:2*n); 
h3 = abs(freqz(b,a,128));
subplot(212)
plot(w,h,w,h3,'+')
title('Rounded filter versus original')
set(gcf,'NextPlot','replace')
