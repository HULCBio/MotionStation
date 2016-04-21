function sx = scal(x,means,stds)
%SCAL	Scale a matrix by specified means and/or standard deviations.
%	sx = scal(x,mx)
%	sx = scal(x,mx,stdx)
% If two input arguments are supplied, then x is scaled by specified
% means only.
%
% Inputs:
%  x   : input data.
%  mx  : means to be used in scaling.
%  stdx: standard deviations to be used in scaling.
%
% Output:
%  sx  : scaled data.
%
% See also AUTOSC, RESCAL, MLR, PLSR, WRTREG.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if nargin == 0,
   disp('Usage: sx = scal(x,mx,stdx)');
   return
end
if nargin <2,
   disp('Error:  too few input arguments!');
   return
end
[nrx,ncx] = size(x);
if nargin == 3
   stdx=stds(:)';   % force to be row vector
   mx=means(:)';
   if any([length(stdx) length(mx)] ~= ncx)
      error(['STDX and MX must have ',int2str(ncx),' elements'])
   end
   sx = (x-mx(ones(nrx,1),:))./stdx(ones(nrx,1),:);
else
   mx=means(:)';
   if length(mx) ~= ncx
      error(['MX must have ',int2str(ncx),' elements'])
   end
   sx = x-mx(ones(nrx,1),:);
end