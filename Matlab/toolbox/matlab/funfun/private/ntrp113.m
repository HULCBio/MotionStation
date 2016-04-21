function [yinterp,ypinterp] = ntrp113(tinterp,t,y,tnew,ynew,klast,phi,psi)
%NTRP113  Interpolation helper function for ODE113.
%   YINTERP = NTRP113(TINTERP,T,Y,TNEW,YNEW,KLAST,PHI,PSI) uses data computed
%   in ODE113 to approximate the solution at time TINTERP. TINTERP may be a
%   scalar or a row vector.  
%   [YINTERP,YPINTERP] = NTRP113(TINTERP,T,Y,TNEW,YNEW,KLAST,PHI,PSI) returns
%   also the derivative of the polynomial approximating the solution. 
%
%   See also ODE113, DEVAL.

%   Mark W. Reichelt and Lawrence F. Shampine, 6-13-94
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2004/04/16 22:06:37 $

yinterp = zeros(size(ynew,1),length(tinterp));
if nargout > 1
  ypinterp = zeros(size(ynew,1),length(tinterp));
end  
ki = klast + 1;
KI = 1:ki;
hinterp = tinterp - tnew;            

for k = 1:length(tinterp)
  hi = hinterp(k);

  w = 1 ./ (1:13)';
  g = zeros(13,1);
  rho = zeros(13,1);
  g(1) = 1;
  rho(1) = 1;
  term = 0;
  for j = 2:ki
    gamma = (hi + term) / psi(j-1);
    eta = hi / psi(j-1);
    for i = 1:ki+1-j
      w(i) = gamma * w(i) - eta * w(i+1);
    end
    g(j) = w(1);
    rho(j) = gamma * rho(j-1);    
    term = psi(j-1);
  end  
  yinterp(:,k) = ynew + hi * phi(:,KI) * g(KI);
  if nargout > 1
    ypinterp(:,k) = phi(:,KI) * rho(KI);
  end  
end  
