function [uout,DuoutDx] = pdeval(m,x,ui,xout)
%PDEVAL  Evaluate the solution computed by PDEPE and its spatial derivative.
%   When an array SOL is returned by PDEPE, UI = SOL(j,:,i) approximates 
%   component i of the solution of the PDE at time T(j) and mesh points X.  
%   [UOUT,DUOUTDX] = PDEVAL(M,X,UI,XOUT) evaluates the approximation and 
%   its partial derivative Dui/Dx at the array of points XOUT and returns 
%   them in UOUT and DUOUTDX, respectively.  
%
%   See also PDEPE.

%   Lawrence F. Shampine and Jacek Kierzenka
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/05/19 11:15:58 $

uout = zeros(size(xout));
DuoutDx = zeros(size(uout));

if (min(xout) < x(1)) || (x(end) < max(xout)) % entries of x are strictly increasing
  error('MATLAB:pdeval:SolOutsideInterval',...
        'Attempting to evaluate outside [a, b].');
end

evaluated = 0;       % greatest index of xout already processed
bottom = 1;          % index of current right-open subinterval in x

while bottom < length(x)
  % find xout that lie in the current subinterval in x
  index = find( (xout(evaluated+1:end) - x(bottom+1)) < 0 );
  if ~isempty(index)
    [uout(evaluated+index),DuoutDx(evaluated+index)] = ...
               pdentrp(m,x(bottom),ui(bottom),x(bottom+1),ui(bottom+1),...
                       xout(evaluated+index));
    evaluated = evaluated + length(index);
  end
  bottom = bottom + 1;
end

% Special case for x(end).
if evaluated < length(xout)
  index = 1:(length(xout)-evaluated);
  [uout(evaluated+index),DuoutDx(evaluated+index)] = ...
      pdentrp(m,x(bottom-1),ui(bottom-1),x(bottom),ui(bottom),...
              xout(evaluated+index));
  uout(evaluated+index) = repmat(ui(bottom),index(end),1);
end

