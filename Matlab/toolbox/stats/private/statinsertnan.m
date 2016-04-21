function [varargout]=statinsertnan(wasnan,varargin)
%STATINSERTNAN Insert NaN values into inputs where they were removed

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.4.2.2 $  $Date: 2004/01/24 09:36:30 $

nanvec = zeros(size(wasnan),class(varargin{1}))*NaN;
ok = ~wasnan;

% Find NaN, check length, and store outputs temporarily
for j=1:nargin-1
   y = varargin{j};
   if (size(y,1)==1), y =  y'; end

   [n p] = size(y);
   if (p==1)
      x = nanvec;
   else
      x = repmat(nanvec,1,p);
   end
   x(ok,:) = y;
   varargout{j} = x;
end
