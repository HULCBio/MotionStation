function y = wrev(x)
%WREV Flip vector.
%   Y = WREV(X) reverses the vector X.
%
%   See also FLIPLR, FLIPUD.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 13-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.10.4.2 $

y = x(end:-1:1);
