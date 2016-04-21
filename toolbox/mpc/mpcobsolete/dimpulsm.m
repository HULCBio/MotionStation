function [yout,xplt] = dimpulsm(a,b,c,d,iu,n)
%DIMPULSE Impulse response of discrete-time linear systems.
%       [y,x] = dimpulsm(A,B,C,D,iu,n);
%       [y,x] = dimpulsm(num,den,n);
% DIMPULSM simulates the response of the discrete system:
%           x[k+1] = Ax[k] + Bu[k]
%           y[k]   = Cx[k] + Du[k]
%      or
%	    y(z) = num(z)/den(z) u(z)
%  to an unit sample applied to the single input IU.  The number of
%  points is N. When invoked without left hand
%  arguments, DIMPULSM plots the response on the screen.
%
% Note: this function is similar to dimpulse in Control Toolbox.

%     Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

ind = 0;
n_actual2=[];

npts = 99999;
if(nargin == 3),  % num, den, number of points avaliable
  npts = c;
elseif(nargin == 6)
  npts = n;
end

if(nargin == 2 | nargin == 3),  %this means num, den
  num = a;
  den = b;
  iu  = 1;                   % That is Only One Input Possible
  ind = 1;                   % Indicator: This is a transfer function

%  Check for sizes; NOTE: Leading Zeros Not Accounted

  [nr,nc] = size(num);
  if(nc > length(den)),
     error('transfer function is not proper')
  end
  [a,b,c,d] = tf2ssm(num,den);
else

  error(abcdchkm(a,b,c,d));

end
[ny,nx] = size(c);
[nx,nu] = size(b);

warn = 0;
ea   = max(abs(eig(a)));

if(ea > 1),
  disp('WARNING: System is Unstable')
  warn = 1;
end
if(ea == 1),
  disp('WARNING: System has pure integrators')
  warn = 1;
end

if(ind ~= 1 & nargin < 5),      % all inputs needed
  iu_begin = 1;
  iu_end   = nu;
else                             % need only one input
  iu_begin = iu;
  iu_end   = iu;
end

u  = zeros(nu,1);

yout=[];

for i_input = iu_begin:iu_end

  u(i_input,1) = 1.0;
  x            = zeros(nx,1);
  xplt         = [x'];
  y            = c*x + d*u;
  yplt         = [y'];


  for i = 1:npts-1,

     x    = a*x + b*u;
     y    = c*x ;      %NOTE: This is y(k=i) and u(k=i) = 0, all i = 1,...

     xplt = [xplt;x'];
     yplt = [yplt;y'];

     u(i_input,1) = 0;

     if (i > 5),
        y1 = yplt(i-4:i,:);
        y2 = yplt(i-5:i-1,:);
        er = y2 - y1;
        ma = ones(1,ny)*diag(er'*er);
        if(sqrt(ma/ny) < .001 & npts == 99999),
           break
        end
        if(sqrt(y1'*y1) > 100 & warn == 1),
          sstr = ['Unstable System was Halted after ', int2str(i), 'iterations']
          disp(sstr)
          break
        end

     end

  end
  n_actual = i+1;
  if(i_input == 1),
    n_actual2 = n_actual;
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
        title(['Input ',int2str(i_input),' Output ',int2str(iy)])
        xlabel('Sample')
        ylabel('Output')
      end               % end for output plots
    end                 % end for something
    pause               % pause at the end of one screen
  else                 % that is, there are outputs to this m-file

    if n_actual < n_actual2     % that is, these y's have less terms
        ndif = n_actual2 - n_actual;
        yplt = [yplt;ones(ndif,1)*y(n_actual,:)];
    elseif n_actual > n_actual2
        ndif = n_actual - n_actual2;
        yout = [yout;ones(ndif,1)*yout(n_actual2,:)];
        n_actual2 = n_actual;
    end

    yout = [yout yplt];

  end
end