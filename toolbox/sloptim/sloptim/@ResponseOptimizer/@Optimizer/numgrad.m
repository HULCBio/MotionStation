function G = numgrad(this,fcn,x,Info)
% Computes gradient wrt decision variables using
% two simulations of the original model and finite 
% centered differences.

% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2004/04/11 00:45:30 $

% min/max and scale data
xMin = Info.xMin;
xMax = Info.xMax;
xScale = Info.xScale;
xScale(xScale==0) = 1;

for j=1:length(x)-1
   % Compute perturbation size
   dx = 0.1 * abs(x(j)) + 0.01 * xScale(j);
   xjL = max(xMin(j),x(j)-dx);
   xjR = min(xMax(j),x(j)+dx);
   % Evaluate constraints at x-dx
   xL = x;  xL(j) = xjL;
   if strcmp(this.Project.OptimStatus,'run')
      FL = feval(fcn,this,xL,-j);
   else
      % Interrupted or error -> return as soon as simulation ends
      G = [];  return
   end
   % Evaluate constraints at x+dx
   xR = x;  xR(j) = xjR;
   if strcmp(this.Project.OptimStatus,'run')
      FR = feval(fcn,this,xR,j);
   else
      G = [];  return
   end
   % Estimate gradient wrt xj
   dF = FR - FL;
   dF(imag(FR)~=0 | imag(FL)~=0) = 0; % complex -> sim failure
   G(j,:) = dF.'/(xjR - xjL);
end

