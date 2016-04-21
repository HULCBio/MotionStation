function [ax,mx,stdx] = autosc(x);
%AUTOSC	Scale a matrix by its means and standard deviations.
%	[ax,mx,stdx] = autosc(x)
%
% Input:
%   x:  input data.
%
% Outputs:
%  ax  : scaled data.
%  mx  : mean value of x.  If x is a matrix, it is a row vector
%	 containing the mean value of each column.
%  stdx: standard deviation of x.  If x is a matrix, it is a row
%        vector containing the standard deviation of each column.
%
%  See also SCAL, RESCAL, MLR, PLSR, WRTREG.

%     Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $
if nargin == 0
   disp('Usage: [ax,mx,stdx] = autosc(x)');
   return
end
[nrx,ncx] = size(x);
mx = mean(x);
stdx = std(x);
ax = (x - mx(ones(nrx,1),:))./stdx(ones(nrx,1),:);

%  End of function autosc.