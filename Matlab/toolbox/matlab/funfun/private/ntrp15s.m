function [yinterp,ypinterp] = ntrp15s(tinterp,t,y,tnew,ynew,h,dif,k)
%NTRP15S  Interpolation helper function for ODE15S.
%   YINTERP = NTRP15S(TINTERP,T,Y,TNEW,YNEW,H,DIF,K) uses data computed in
%   ODE15S to approximate the solution at time TINTERP. TINTREP may be a
%   scalar or a row vector.   
%   [YINTERP,YPINTERP] = NTRP15S(TINTERP,T,Y,TNEW,YNEW,H,DIF,K) returns
%   also the derivative of the polynomial approximating the solution. 
%   
%   See also ODE15S, DEVAL.

%   Mark W. Reichelt and Lawrence F. Shampine, 6-13-94
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2004/04/16 22:06:39 $

s = (tinterp - tnew)/h;     

if k == 1
  yinterp = repmat(ynew,size(tinterp)) + dif(:,1) * s;
  if nargout > 1
    ypinterp = repmat(1/h*dif(:,1),size(tinterp));
  end  
else                    % cumprod collapses vectors
  K = (1:k)';
  kI = repmat(K,size(tinterp));
  yinterp = repmat(ynew,size(tinterp)) + ...
      dif(:,K) * cumprod((repmat(s,k,1)+kI-1)./kI);
  
  if nargout > 1
    ypinterp = repmat(dif(:,1),size(tinterp));
    S  = ones(size(tinterp));
    dS = ones(size(tinterp)); 
    for i=2:k
      S = S .* (i-2+s)/i;
      dS = dS .* (i-1+s)/i + S;
      ypinterp = ypinterp + dif(:,i)*dS;    
    end
    ypinterp = ypinterp/h;
  end  
  
end
