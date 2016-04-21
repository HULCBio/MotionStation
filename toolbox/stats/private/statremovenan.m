function [badin,wasnan,varargout]=statremovenan(varargin)
%STATREMOVENAN Remove NaN values from inputs

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.3.2.1 $  $Date: 2004/01/24 09:36:31 $

badin = 0;
wasnan = 0;
n = -1;

% Find NaN, check length, and store outputs temporarily
for j=1:nargin
   y = varargin{j};
   if (size(y,1)==1), y =  y'; end

   ny = size(y,1);
   if (n==-1)
      n = ny;
   elseif (n~=ny & ny~=0)
      if (badin==0), badin = j; end
   end
   
   varargout{j} = y;

   if (badin==0 & ny>0), wasnan = wasnan | any(isnan(y),2); end
end

if (badin>0), return; end

% Fix outputs
if (any(wasnan))
   t = ~wasnan;
   for j=1:nargin
      y = varargout{j};
      if (length(y)>0), varargout{j} = y(t,:); end
   end
end
