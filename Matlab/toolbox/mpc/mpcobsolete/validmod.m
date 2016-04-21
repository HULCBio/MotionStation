function yres = validmod(xreg,yreg,theta,plotopt);
%VALIDMOD Validate the model for a new set of data, xreg & yreg.
%	yres = validmod(xreg,yreg,theta,plotopt)
%
% Required Inputs:
%   xreg, yreg: a new set of data.
%        theta: impulse response coefficients for the testing model.
%
% Optional input:
%      plotopt: = 0 (default), no plot is produced;
%	        = 1, plot of actual output (yreg) and predicted output;
%	        = 2, plot of yreg and yfit, and plot of residues (yres).
%
% Output:
%     yres:  residue output or prediction error.
%
% See also MLR, PLSR.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if nargin == 0,
   disp('Usage: yres = validmod(xreg,yreg,theta,plotopt)');
   return
end
[nrx,ncx] = size(xreg);
[nry,ncy] = size(yreg);
if nrx ~= nry,
   disp('Error: number of rows for input and output must be same!');
   return;
end
if nargin < 3,
   disp('Error:  minimum number of input arguments is 3!')
   return
end
if nargin == 3,
   plotopt = 0;
end
[nrt,nct] = size(theta);
for i = 1:nct,
   thetac(nrt*(i-1)+1:nrt*i) = theta(:,i);
end
ypred = xreg * thetac';
yres = yreg - ypred;
[nrx,ncx] = size(xreg);
if plotopt == 1 | plotopt == 2,
   clf
   if plotopt == 2,
      subplot(211);
      plot(1:nrx,yreg,1:nrx,yreg,'or',1:nrx,ypred,1:nrx,ypred,'+g');
      title('Actual value (o) versus Predicted Value (+)');
      xlabel('Sample Number');
      ylabel('Output');
      subplot(212);
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
   pause
end
