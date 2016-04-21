%function out = vec2sm(x,dim)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

 function out = vec2sm(x,dim)
    out = zeros(dim,dim);
    loc = 1;
    for j=1:dim
      out(j,j:dim) = x(loc:loc+dim-j)';
      out(j,j) = out(j,j)/2;
      loc = loc + dim-j+1;
    end
    out = out + out';