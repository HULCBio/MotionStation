%function out = vec2ssm(x,dim)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

 function out = vec2ssm(x,dim)
    out = zeros(dim,dim);
    loc = 1;
    for i=1:dim-1
      out(i,i+1:dim) = x(loc:loc+dim-i-1)';
      loc = loc + dim-i;
    end
    out = out - out';