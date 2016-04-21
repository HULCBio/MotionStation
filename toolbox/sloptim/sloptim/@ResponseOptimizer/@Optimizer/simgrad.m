function G = simgrad(this,fcn,x,Info)
% Computes gradient wrt decision variables using
% simulation of gradient model.

% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:45:34 $
rstep = 1e-3;

% min/max and scale data
xMin = Info.xMin;
xMax = Info.xMax;
xScale = Info.xScale;
xScale(xScale==0) = 1;
ndv = length(x)-1;

% Clear gradient logs
for j=1:ndv
   % Compute perturbation size
   dx = rstep * (abs(x(j)) + 0.01 * xScale(j));
   xjL = max(xMin(j),x(j)-dx);
   xjR = min(xMax(j),x(j)+dx);
   % Convert x values into parameter values
   xL = x;  xL(j) = xjL;
   xR = x;  xR(j) = xjR;
   % Simulate gradient model to evaluate F(xR)-F(xL)
   if strcmp(this.Project.OptimStatus,'run')
      dF = feval(fcn,this,x,j,xL,xR);
   else
      % Interrupted
      G = [];  return
   end
   % Compute gradient wrt xj
   G(j,:) = dF.'/(xjR - xjL);
end
