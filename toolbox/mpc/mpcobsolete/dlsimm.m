function [yplt,xplt] = dlsimm(a,b,c,d,u,x0)
%DLSIMM  Simulation of discrete-time linear systems.
%	[y,x] = dlsimm(A,B,C,D,u,x0);
%	[y,x] = dlsimm(num,den,u);
%
%Simulates the time response of the discrete system:
%		x[n+1] = Ax[n] + Bu[n]
% 		y[n]   = Cx[n] + Du[n]
%	or
%		y(z) = num(z)/den(z) u(z)
%
% The initial condition x0 is optional.  When invoked without left
% arguments, DLSIMM plots the time response on the screen.

%     Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

ind = 0;
if(nargin < 3),
  error('Not enough inputs')
end

if(nargin == 3),  %this means num, den
  num = a;
  den = b;
  u   = c;
  [nr,nc] = size(num);
  if(nc > length(den)),
     error('transfer function is not proper')
  end
  [a,b,c,d] = tf2ssm(num,den);
  [ny,nx] = size(c);
  [nx,nu] = size(b);
  [npts,nu2] = size(u);
  if(nu2 ~= nu),
    error('Dimension mismatch between input sequence and state space')
  end

else

  [nx,nx2] = size(a);
  if(nx ~= nx2),
    error('Matrix A must be square')
  end
  [nx2,nu] = size(b);
  if(nx ~= nx2),
   error('Matrix A and B must have same number of rows')
  end
  [ny,nx2] = size(c);
  if(nx ~= nx2),
   error('Matrix A and C must have same number of columns')
  end
  [ny2,nu2] = size(d);
  if(ny ~= ny2)
   error('Matrix C and D must have same number of rows')
  end
  if(nu ~= nu2)
   error('Matrix B and D must have same number of columns')
  end
  [npts,nu2] = size(u);
  if(nu ~= nu2),
    error('Dimension error between input sequence and state space')
  end

end

  if(nargin == 6),
    x          = x0;
  else
    x          = zeros(nx,1);
  end
  xplt         = [x'];
  y            = c*x + d*u(1,:)';
  yplt         = [y'];
  u            = [u;u(npts,:)];

  for i = 1:npts-1

     x    = a*x + b*u(i,:)';
     y    = c*x + d*u(i+1,:)';

     xplt = [xplt;x'];
     yplt = [yplt;y'];

  end

if(ny < 3),
     n_plto = 100 + ny*10;
else
     n_plto = 220;
end

 if (nargout == 0),
  if(ny > 4),
    clf
    subplot(111)
    stairs(yplt)
    xlabel('Sample')
    ylabel('Outputs')
  else

    clf
  	 for iy = 1:ny

      n_plt = n_plto + iy;
      subplot(n_plt)
      stairs(yplt(:,iy))
      title([' Output ',int2str(iy)])
      xlabel('Sample')
      ylabel('Output')
    end               % end for output plots
  end                 % end for something
  pause               % pause at the end of one screen

end