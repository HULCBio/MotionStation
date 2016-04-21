function string = num2ordinal(number)
%NUM2ORDINAL Convert positive integer to ordinal string.
%   STRING = NUM2ORDINAL(NUMBER) converts a positive integer to an
%   ordinal string.  For example, NUM2ORDINAL(4) returns the string
%   'fourth' and NUM2ORDINAL(23) returns '23rd'.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2003/01/26 06:00:43 $

%   I/O Spec
%   ========
%   NUMBER     Scalar positive integer
%              Numeric
%
%   NUMBER is not checked for validity.

if number <= 20
  table1 = {'first' 'second' 'third' 'fourth' 'fifth' 'sixth' 'seventh' ...
            'eighth' 'ninth' 'tenth' 'eleventh' 'twelfth' 'thirteenth' ...
            'fourteenth' 'fifteenth' 'sixteenth' 'seventeenth' ...
            'eighteenth' 'nineteenth' 'twentieth'};
  
  string = table1{number};
  
else
  table2 = {'th' 'st' 'nd' 'rd' 'th' 'th' 'th' 'th' 'th' 'th'};
  ones_digit = rem(number, 10);
  string = sprintf('%d%s',number,table2{ones_digit + 1});
end
