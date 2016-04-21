function [theta,w,cw,ssqdif,yres] = plsr(xreg,yreg,ninput,lv,plotopt);
%PLSR	Determine impulse response coefficients via Partial Least Squares.
%   	[theta,w,cw,ssqdif,yres] = plsr(xreg,yreg,ninput,lv,plotopt)
% Required Inputs:
%   xreg, yreg: input & output data.
%       ninput: number of input.
%           lv: number of latent vectors, ie., number of directions chosen
%               to maximize the cross variance between the input and output
%               data in PLS routine.
% Optional Inputs:
%      plotopt = 0 (default), no plot is produced;
%	       = 1, plot of actual output (yreg) and predicted output;
%	       = 2, plot of yreg and yfit, and plot of residues (yres).
% Outputs:
%            w: orthogonal matrix of dimension n by lv consisting of
%       	principle directions maximizing the cross variance between
%		input and output.  n is number of impulse response coeff.
%           cw: a vector containing coefficients associated with each column
%	        of w in determining theta.
%        theta: impulse response coefficient matrix of dimension n by nu.
%   		nu is number of inputs. Column i corresponds to the impulse
%		response coefficients for input i.
%       ssqdif:	percentage variances of input & output captured by PLS.
%	  yres: residue output.
% See also MLR, VALIDMOD, WRTREG.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if nargin == 0
   disp('Usage: [theta,w,cw,ssqdif,yres] = plsr(xreg,yreg,ninput,lv,plotopt)')
   return
end
if nargin < 4
   error('Minimum number of input arguments is 4!');
   return
end
if nargin == 4
   plotopt = 0;
end
[nrx,ncx] = size(xreg);
[nry,ncy] = size(yreg);
if nrx ~= nry
   error('Number of rows for input and output must be same!');
   return
end
ssqx = sum(sum(xreg.^2)');
ssqy = sum(sum(yreg.^2)');
x = xreg;
y = yreg;
I = eye(ncx);
w = zeros(ncx,lv);
for i = 1:lv
   w(:,i) = x'*y;
   w(:,i) = w(:,i)/norm(w(:,i));
   r(:,i) = x * w(:,i);
   x = x -  r(:,i) * w(:,i)';
   y = y - r*(r\y);
   ssq(i,1) = (sum(sum(x.^2)'))*100/ssqx;
   ssq(i,2) = (sum(sum(y.^2)'))*100/ssqy;
end
cw = r\yreg;
thetam = w * cw;
ssqdif = zeros(lv,2);
ssqdif(1,1) = 100 - ssq(1,1);
ssqdif(1,2) = 100 - ssq(1,2);
for i = 2:lv
  for j = 1:2
    ssqdif(i,j) = -ssq(i,j) + ssq(i-1,j);
  end
end
disp('  ')
disp('        Percent Variance Captured by PLS Model')
disp('  ')
disp('             ----X-Block------   ----Y-Block------')
disp('      LV#    This LV    Total    This LV    Total ')
disp([(1:lv)' ssqdif(:,1) cumsum(ssqdif(:,1)) ssqdif(:,2) cumsum(ssqdif(:,2))])
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
end
n = ncx / ninput;
for i = 1:ninput
   theta(:,i) = thetam(n*(i-1)+1:n*i);
end

%  End of function plsr.
