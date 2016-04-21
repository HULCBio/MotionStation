function rx = rescal(x,mx,stdx)
%RESCAL Rescale a matrix by specified means and/or standard deviations.
% 	rx = rescal(x,mx)
%	rx = rescal(x,mx,stdx)
% If two input arguments are supplied, then x is rescaled by specified
% means only.
%
% Inputs:
%   x  : input data.
%  mx  : means to be used in rescaling.
%  stdx: standard deviations to be used in rescaling.
%
% Output:
%    rx: scaled data.
%
% See also SCAL, AUTOSC, MLR, PLSR, WRTREG.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if nargin == 0
   disp('Usage: rx = rescal(x,mx,stdx)');
   return
end
if nargin <2
   disp('Error:  too few input arguments!');
   return
end
[nrx,ncx] = size(x);
if nargin == 3
   stdx=stdx(:)';   % force to be row vector
   mx=mx(:)';
   if any([length(stdx) length(mx)] ~= ncx)
      error(['STDX and MX must have ',int2str(ncx),' elements'])
   end
   rx = (x.*stdx(ones(nrx,1),:))+mx(ones(nrx,1),:);
else
   mx=mx(:)';
   if length(mx) ~= ncx
      error(['MX must have ',int2str(ncx),' elements'])
   end
   rx = x + mx(ones(nrx,1),:);
end