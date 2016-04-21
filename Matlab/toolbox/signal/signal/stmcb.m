function [b,a] = stmcb( x, u_in, q, p, niter, a_in )
%STMCB Compute linear model via Steiglitz-McBride iteration
%   [B,A] = stmcb(H,NB,NA) finds the coefficients of the system 
%   B(z)/A(z) with approximate impulse response H, NA poles and 
%   NB zeros.
%
%   [B,A] = stmcb(H,NB,NA,N) uses N iterations.  N defaults to 5.
%
%   [B,A] = stmcb(H,NB,NA,N,Ai) uses the vector Ai as the initial 
%   guess at the denominator coefficients.  If you don't specify Ai, 
%   STMCB uses [B,Ai] = PRONY(H,0,NA) as the initial conditions.
%
%   [B,A] = STMCB(Y,X,NB,NA,N,Ai) finds the system coefficients B and 
%   A of the system which, given X as input, has Y as output.  N and Ai
%   are again optional with default values of N = 5, [B,Ai] = PRONY(Y,0,NA).
%   Y and X must be the same length.
%
%   See also PRONY, LEVINSON, LPC, ARYULE.

%   Author(s): Jim McClellan, 2-89
%   	       T. Krauss, 4-22-93, new help and options
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/15 01:14:25 $

error(nargchk(3,6,nargin))

if length(u_in) == 1,
    if nargin == 3,
        niter = 5; p = q; q = u_in;
        a_in = prony(x,0,p);
    elseif nargin == 4,
        niter = p; p = q; q = u_in; 
        a_in = prony(x,0,p);
    elseif nargin == 5,
        a_in = niter; niter = p; p = q; q = u_in; 
    end
    u_in = zeros(size(x));
    u_in(1) = 1;         % make a unit impulse whose length is same as x
else
    if length(u_in)~=length(x),
        error('Input signal X and output signal Y must have the same length.')
    end
    if nargin < 6
       [b,a_in] = prony(x,0,p);
    end
    if nargin < 5
       niter = 5;
    end
end

a = a_in;
N = length(x);
for i=1:niter
   u = filter( 1, a, x );
   v = filter( 1, a, u_in );
%   [a,b] = kalman( u, p, v, q);  - see GATECH m-files for kalman.m
   C1 = convmtx(u(:),p+1);
   C2 = convmtx(v(:),q+1);
   T = [ -C1(1:N,:) C2(1:N,:) ];
   c = T(:,2:p+q+2) \ [-T(:,1)];   % move 1st column to RHS and do least-squares
   a = [1; c(1:p)];                % denominator coefficients
   b = c(p+1:p+q+1);               % numerator coefficients
end
a=a.';
b=b.';

