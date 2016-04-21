function b = isfinite(sys)
%ISFINITE  Check if LTI model does not contain NaN's or Inf's.
%
%   B = ISFINITE(SYS) returns a boolean array of the same size as 
%   the LTI array SYS ([1 1] for a single model) indicating which 
%   models have all finite data.

%   Author(s): P. Gahinet, 5-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%	 $Revision: 1.1 $  $Date: 2002/05/10 19:55:45 $

s = size(sys.k);
b = all(reshape(isfinite(sys.k),[s(1)*s(2) s(3:end) 1]),1);
b = reshape(b,[s(3:end) 1 1]);