%% Quantizer Error Statistics
%
% This is a demonstration of the statistics of the error when signals are
% quantized using various rounding methods.
%
% First, a random signal is created that spans the range of the quantizer.
%
% Next, the signal is quantized, respectively, with roundmodes 'fix', 'floor',
% 'ceil', 'round', and 'convergent', and the statistics of the signal are
% estimated.
%
% The theoretical probability density function of the quantization error will be
% computed with ERRPDF, the theoretical mean of the quantization error will be
% computed with ERRMEAN, and the theoretical variance of the quantization error
% will be computed with ERRVAR.

%% Uniformly distributed random signal
%
% First we create a uniformly distributed random signal that spans the domain -1
% to 1 of the fixed-point quantizers that we will look at.

q = quantizer([8 7]);
r = realmax(q);
u = r*(2*rand(50000,1) - 1);        % Uniformly distributed (-1,1)
xi=linspace(-2*eps(q),2*eps(q),256);


%% Fix:  Round towards zero.
% Notice that with 'fix' rounding, the probability density function is
% twice as wide as the others.  For this reason, the variance is four times
% that of the others.

q = quantizer('fix',[8 7]);
err = quantize(q,u) - u;    
f_t = errpdf(q,xi);
mu_t = errmean(q);
v_t  = errvar(q);
% Theoretical variance = eps(q)^2 / 3
% Theoretical mean     = 0
qerrordemoplot(q,f_t,xi,mu_t,v_t,err)

%% Floor: Round towards minus infinity.
% Floor rounding is often called truncation when used with integers and
% fixed-point numbers that are represented in two's complement.  It is the most
% common rounding mode of DSP processors because it requires no hardware to
% implement.  Floor does not produce quantized values that are as close to the
% true values as ROUND will, but it has the same variance, and small signals
% that vary in sign will be detected, whereas in ROUND they will be lost.

q = quantizer('floor',[8 7]);
err = quantize(q,u) - u;    
f_t = errpdf(q,xi);
mu_t = errmean(q);
v_t  = errvar(q);
% Theoretical variance =  eps(q)^2 / 12
% Theoretical mean     = -eps(q)/2
qerrordemoplot(q,f_t,xi,mu_t,v_t,err)

%% Ceil:  Round towards plus infinity.

q = quantizer('ceil',[8 7]);
err = quantize(q,u) - u;    
f_t = errpdf(q,xi);
mu_t = errmean(q);
v_t  = errvar(q);
% Theoretical variance = eps(q)^2 / 12
% Theoretical mean     = eps(q)/2
qerrordemoplot(q,f_t,xi,mu_t,v_t,err)

%% Round: Round to nearest.  In a tie, round to largest magnitude.
% Round is more accurate than floor, but all values smaller than eps(q) get
% rounded to zero and so are lost.
q = quantizer('round',[8 7]);
err = quantize(q,u) - u;    
f_t = errpdf(q,xi);
mu_t = errmean(q);
v_t  = errvar(q);
% Theoretical variance = eps(q)^2 / 12
% Theoretical mean     = 0
qerrordemoplot(q,f_t,xi,mu_t,v_t,err)

%% Convergent: Round to nearest. In a tie, round to even.
% Convergent rounding eliminates the bias introduced by ordinary "round"
% caused by always rounding the tie in the same direction.
q = quantizer('convergent',[8 7]);
err = quantize(q,u) - u;    
f_t = errpdf(q,xi);
mu_t = errmean(q);
v_t  = errvar(q);
% Theoretical variance = eps(q)^2 / 12
% Theoretical mean     = 0
qerrordemoplot(q,f_t,xi,mu_t,v_t,err)

%% Comparison of 'round' vs. 'convergent'
% The error probability density function for convergent rounding is difficult to
% distiguish from that of round-to-nearest by looking at the plot.  
%
% The error p.d.f. of convergent is
%
%   f(err) = 1/eps(q),  for -eps(q)/2 <= err <= eps(q)/2, and 0 otherwise
%
% while the error p.d.f. of round is
%
%   f(err) = 1/eps(q),  for -eps(q)/2 <  err <= eps(q)/2, and 0 otherwise
%
% Note that the error p.d.f. of convergent is symmetric, while round is
% slightly biased towards the positive.
%
% The only difference is the direction of rounding in a tie.
x=[-3.5:3.5]';
[x convergent(x) round(x)]


%% qerrordemoplot
% The helper function that was used to generate the plots in this demo is
% listed below.
type qerrordemoplot.m

%%
% Copyright 1999-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $


