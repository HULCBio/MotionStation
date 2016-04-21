function Y = abs(X1,X2)
%ABS    Absolute value.
%   ABS(X) is the absolute value of the elements of X. When
%   X is complex, ABS(X) is the complex modulus (magnitude) of
%   the elements of X.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2002/04/15 03:12:18 $

if nargin == 1
   Y = maple('map','abs',X1);
else
   Y = ['sign(' char(X2) ')'];
end
