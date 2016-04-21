function hh = ezpolar(varargin)
% EZPOLAR Easy to use polar coordinate plotter.
%   EZPOLAR(f) plots the polar curve rho = f(theta) over the
%   default domain 0 < theta < 2*pi.
%
%   EZPOLAR(f,[a,b]) plots f for a < theta < b.
%
%   EZPOLAR(AX,...) plots into AX instead of GCA.
%
%   H = EZPOLAR(...) returns a handle to the plotted object in H.
%
%   Examples
%     f is typically an expression, but it can also be specified
%     using @ or an inline function:
%       ezpolar('1 + cos(t)')
%       ezpolar('cos(2*t)')
%       ezpolar('sin(tan(t))')
%       ezpolar('sin(3*t)')
%       ezpolar('cos(5*t)')
%       ezpolar('sin(2*t)*cos(3*t)',[0,pi])
%       ezpolar('1 + 2*sin(t/2)')
%       ezpolar('1 - 2*sin(3*t)')
%       ezpolar('sin(t)/t', [-6*pi,6*pi])
%
%       r = '100/(100+(t-1/2*pi)^8)*(2-sin(7*t)-1/2*cos(30*t))';
%       ezpolar(r,[-pi/2,3*pi/2])
%
%       h = inline('log(gamma(x+1))');
%       ezpolar(h)
%       ezpolar(@cot,[0,pi])
%
%  See also EZPLOT3, EZPLOT, EZSURF, PLOT, PLOT3, POLAR

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.11.4.2 $  $Date: 2004/04/06 21:53:37 $

% If r = f(theta) is an inline function, then vectorize it as need be.

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});

% Create plot 
cax = newplot(cax);

[rho,rho0,rhoargs] = ezfcnchk(args{1},0,'t');
if (length(rhoargs)>1)
   error('Cannot plot polar curves of more than 1 variable.');
end

Npts = 314;

% Determine the domain in t:
switch nargs
   case 1
      T =  linspace(0,2*pi,Npts);
   case 2
      T = linspace(args{2}(1),args{2}(2),Npts);
end

RHO = ezplotfeval(rho,T);

% If RHO is constant (i.e., 1 by 1), then ...
if all( size(RHO) == 1 ), RHO = RHO.*ones(size(T)); end
if ~isempty(cax)
    h = polar(cax,T,RHO);
else
    h = polar(T,RHO);
end

text(0,-1.2*max(abs(RHO)),['r = ', texlabel(rho0)], ...
    'HorizontalAlignment','Center','Parent',cax);

if nargout > 0
    hh = h;
end