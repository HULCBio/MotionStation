function s = hdsGetSize(ltiarray)
%HDSGETSIZE  Return size of data point array.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:29:47 $
s = size(ltiarray);
s = [s(3:end) ones(1,4-length(s))];