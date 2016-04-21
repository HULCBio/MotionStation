function [theta,yres] = mlr(xreg,yreg,ninput,plotopt,wtheta,wdeltheta);
%MLR	Determine impulse response coefficients.
%  	 [theta, yres] = mlr(xreg,yreg,ninput)
%	 [theta, yres] = mlr(xreg,yreg,ninput,plotopt,wtheta,wdeltheta)
% MLR determines impulse response coefficients for a multi-input
% single-output system via Multivariable Least Squares Regression or
% Ridge Regression.
%
% Inputs:
%  xreg & yreg: input matrix and output vector produced by function
%               wrtreg or by other means.
%  ninput:  number of input.
% Optional inputs:
%     plotopt: = 0 (default), no plot is produced;
%	       = 1, plot of actual output (yreg) and predicted output;
%	       = 2, plot of yreg and yfit, and plot of residues (yres).
%      wtheta: penalty on theta^2, default = 0.
%   wdeltheta: penalty on the squares of delta theta, default = 0.
%
% Outputs:
%  theta: impulse response coeff. matrix.  Each column corresponds to
%  	  impulse response coeff. for a particular input to the output.
%  yres:  residue output or prediction error.
%
% See also PLSR, VALIDMOD, WRTREG.

%     Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if nargin == 0
   disp('Usage: [theta,yres] = mlr(xreg,yreg,ninput,plotopt,wtheta,wdeltheta)')
   return
end
if nargin < 3
   error('Minimum number of input arguments is 3!');
   return
end
if nargin < 4
   plotopt = 0;
end
if nargin < 5
   wtheta = 0;
end
if nargin < 6
   wdeltheta = 0;
end
[nrx,ncx] = size(xreg);
[nry,ncy] = size(yreg);
if nrx ~= nry
   error('Number of rows for input and output must be same!');
   return
end
%  Construct the input matrix for LS regression.
[nrx,ncx] = size(xreg);
I = eye(ncx);
delI = -I + [zeros(ncx,1) [eye(ncx-1);zeros(1,ncx-1)]];
x = [xreg; wtheta*I; wdeltheta*delI];
y = [yreg; zeros(2*ncx,1)];
thetam = x\y;
ypred = xreg * thetam;
yres = yreg - ypred;
rms = norm(yres);
if plotopt == 1 | plotopt == 2
   clf
   if plotopt == 2
      subplot(211);
      plot(1:nrx,yreg,1:nrx,yreg,'or',1:nrx,ypred,1:nrx,ypred,'+g');
      title('Actual value (o) versus Predicted Value (+)');
      xlabel('Sample Number');
      ylabel('Output');
      subplot(212)
      plot(yres);
      title('Output Residual or Prediction Error');
      xlabel('Sample Number');
      ylabel('Residual');
   else
      plot(1:nrx,yreg,1:nrx,yreg,'or',1:nrx,ypred,1:nrx,ypred,'+g');
      title('Actual value (o) versus Predicted Value (+)');
      xlabel('Sample Number');
      ylabel('Output');
   end
end
n = ncx /ninput;
for i = 1:ninput
   theta(:,i) = thetam(n*(i-1)+1:n*i);
end

%  End of function mlr
