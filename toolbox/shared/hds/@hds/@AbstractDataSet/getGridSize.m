function s = getGridSize(this,dim)
%GETGRIDSIZE  Returns grid size or grid dimension length.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:06 $

if isempty(this.Grid_)
   s = [0 0];
else
   s = [this.Grid_.Length];
end
s = [s ones(1,2-length(s))];

if nargin>1
   if dim>length(s)
      s = 1;
   else
      s = s(dim);
   end
end