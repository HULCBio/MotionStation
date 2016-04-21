%% Medium-scale nonlinear data fitting.
% This example demonstrates fitting a nonlinear function to data using several 
% of the different medium-scale methods available in the Optimization Toolbox.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.23.4.2 $  $Date: 2004/04/06 01:10:17 $

%% Problem setup
% Consider the following data:

Data = ...
  [0.0000    5.8955
   0.1000    3.5639
   0.2000    2.5173
   0.3000    1.9790
   0.4000    1.8990
   0.5000    1.3938
   0.6000    1.1359
   0.7000    1.0096
   0.8000    1.0343
   0.9000    0.8435
   1.0000    0.6856
   1.1000    0.6100
   1.2000    0.5392
   1.3000    0.3946
   1.4000    0.3903
   1.5000    0.5474
   1.6000    0.3459
   1.7000    0.1370
   1.8000    0.2211
   1.9000    0.1704
   2.0000    0.2636];

%%
% Let's plot these data points.
close all
fig = colordef(gcf, 'white');
t = Data(:,1);
y = Data(:,2);
axis([0 2 -0.5 6])
figure(fig)
hold on
plot(t,y,'ro','EraseMode','none') 
title('Data points')
hold off

%%
% We would like to fit the function
%
%     y =  c(1)*exp(-lam(1)*t) + c(2)*exp(-lam(2)*t)
%
% to the data.  This function has two linear parameters c and two nonlinear 
% parameters lam.
%
% Since the function has a combination of linear and nonlinear parameters, we
% will separate the solving into two steps. We will use one of the optimization
% routines such as LSQNONLIN to solve for the nonlinear parameters, and inside
% our function we will use "\" to solve for the linear parameters.
%
% We write a function, called FITFUN2, that, given the nonlinear parameters lam
% and the data, solves for the current estimate of the linear parameters and 
% then returns the error in the fit.  

%%
% This is the M-file for function FITFUN2:

type fitfun2

%% 
% We set some option parameters via OPTIMSET. Our objective function requires 
% additional parameters (namely, the matrix Data); the most convenient way to 
% pass these is through an anonymous function:

f = @(x) (norm(fitfun2(x,Data)))

%%
% Next, we set some option parameters via OPTIMSET and we provide a guess 
% for the initial estimates of the nonlinear parameters 

options=optimset('LargeScale','off','Display','iter','TolX',1e-3); 
lam0 = [1; 0];  % Initial guess for nonlinear parameters    

%% Fit using unconstrained optimization
% First, we optimize running the BFGS quasi-Newton algorithm, implemented
% in the function FMINUNC:

plothandle = plotdatapoints(t,y); % plot data points and get plot handle.
% Output function requires additional parameters data and plothandle; use
% an anonymous function:
foutputfcn = @(x,optimvalues,state) fitfun2outputfcn(x,optimvalues,state, ...
                                                     Data,plothandle);
options = optimset(options,'OutputFcn',foutputfcn);
t0 = clock; 
[lam,fval,exitflag,output] = fminunc(f,lam0,options);

execution_time=etime(clock, t0);
fprintf('\nNumber of iterations: %g\nNumber of function evaluations: %g\n', output.iterations, output.funcCount);
fprintf('Sum of squared residuals at solution: %g\n',fval^2);
fprintf('Execution time: %g\n',execution_time);

%% Fit using simplex search
% Now we run FMINSEARCH, which implements the Nelder-Mead algorithm:

plothandle = plotdatapoints(t,y); % plot data points and get plot handle.
% Output function requires additional parameters data and plothandle; use
% an anonymous function:
foutputfcn = @(x,optimvalues,state) fitfun2outputfcn(x,optimvalues,state, ...
                                                     Data,plothandle);
options = optimset(options,'OutputFcn',foutputfcn);
t0 = clock;
[lam,fval,exitflag,output] = fminsearch(f,lam0,options);
execution_time=etime(clock, t0);
fprintf('\nNumber of iterations: %g\nNumber of function evaluations: %g\n', output.iterations, output.funcCount);
fprintf('Sum of squared residuals at solution: %g\n',fval^2);
fprintf('Execution time: %g\n',execution_time);

%% Fit using nonlinear least squares (Levenberg-Marquardt)
% We now try the Levenberg-Marquardt method in the nonlinear least 
% squares solver LSQNONLIN:

plothandle = plotdatapoints(t,y); % plot data points and get plot handle.
% Output function requires additional parameters data and plothandle; use
% an anonymous function:
F = @(x) fitfun2(x,Data);
foutputfcn = @(x,optimvalues,state) fitfun2outputfcn(x,optimvalues,state, ...
                                                     Data,plothandle);
options = optimset(options,'OutputFcn',foutputfcn);
options = optimset(options,'NonlEqnAlgorithm','lm');
t0 = clock;
[lam,resnorm,residual,exitflag,output]= lsqnonlin(F,lam0,[],[],options);
execution_time=etime(clock, t0);
fprintf('\nNumber of iterations: %g\nNumber of function evaluations: %g\n', output.iterations, output.funcCount);
fprintf('Sum of squared residuals at solution: %g\n',resnorm);
fprintf('Execution time: %g\n',execution_time);

%% Fit using nonlinear least squares (Gauss-Newton)
% Next, we run again LSQNONLIN, but this time we select the Gauss-Newton method:

plothandle = plotdatapoints(t,y); % plot data points and get plot handle.
% Output function requires additional parameters data and plothandle; use
% an anonymous function:
F = @(x) fitfun2(x,Data);
foutputfcn = @(x,optimvalues,state) fitfun2outputfcn(x,optimvalues,state, ...
                                                     Data,plothandle);
options = optimset(options,'OutputFcn',foutputfcn);
options = optimset(options,'NonlEqnAlgorithm','gn');
t0 = clock;
[lam,resnorm,residual,exitflag,output]= lsqnonlin(F,lam0,[],[],options);
execution_time=etime(clock, t0);
fprintf('\nNumber of iterations: %g\nNumber of function evaluations: %g\n', output.iterations, output.funcCount);
fprintf('Sum of squared residuals at solution: %g\n',resnorm);
fprintf('Execution time: %g\n',execution_time);

%% Fit using minimax optimization
% We can also minimize the worst-case error by calling the solver FMINIMAX:

plothandle = plotdatapoints(t,y); % plot data points and get plot handle.
% Output function requires additional parameters data and plothandle; use
% an anonymous function:
F = @(x) fitfun2(x,Data);
foutputfcn = @(x,optimvalues,state) fitfun2outputfcn(x,optimvalues,state, ...
                                                     Data,plothandle);
options = optimset(options,'OutputFcn',foutputfcn);
t0 = clock;
options = optimset(options,'MinAbsMax',length(t));

[lam,allfvals,maxfval,exitflag,output]=fminimax(F,lam0,[],[],[],[],[],[],[],options);
execution_time=etime(clock, t0);
fprintf('\nNumber of iterations: %g\nNumber of function evaluations: %g\n', output.iterations, output.funcCount);
fprintf('Sum of squared residuals at solution: %g\n',allfvals'*allfvals);
fprintf('Execution time: %g\n',execution_time);

close(fig)


