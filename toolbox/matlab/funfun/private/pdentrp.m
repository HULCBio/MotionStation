function [U,Ux] = pdentrp(m,xL,uL,xR,uR,xout)
%PDENTRP  Interpolation helper function for PDEPE.
%   [U,UX] = PDENTRP(M,XL,UL,XR,UR,XOUT) uses solution values UL at XL and UR at XR 
%   for successive mesh points XL < XR to interpolate the solution values U and 
%   the partial derivative with respect to x, UX, at arguments XOUT(i) with 
%   XL <= XOUT(i) <= XR.  UL and UR are column vectors. Column i of the output 
%   arrays U, UX correspond to XOUT(i).
%
%   See also PDEPE, PDEVAL, PDEODES.

%   Lawrence F. Shampine and Jacek Kierzenka
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/16 22:06:51 $

xout = xout(:)';
nout = length(xout);

U = repmat(uL,1,nout);
Ux = zeros(size(U));

uRL = uR - uL;
if (xL == 0 && m > 0) %  Singular case
  U  = U + uRL*((xout .^ 2 - xL^2) / (xR^2 - xL^2));
  Ux =     uRL*(2*xout / (xR^2 - xL^2));
else
  switch m
  case 0
    U  = U + uRL*( (xout - xL) / (xR - xL));
    Ux =     uRL*(ones(1,nout) / (xR - xL));
  case 1
    U  = U + uRL*(log(xout/xL) / log(xR/xL));
    Ux =     uRL*( (1 ./ xout) / log(xR/xL));
  case 2
    U  = U + uRL*((xR ./ xout) .* ((xout - xL)/(xR - xL)));
    Ux =     uRL*((xR ./ xout) .* (xL ./ xout)/(xR - xL));
  end
end

