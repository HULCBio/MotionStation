function display(opaque_array)
%DISPLAY Display a Java object.

%   Chip Nylander, May 1998
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/15 04:14:22 $

if strcmp(get(0, 'FormatSpacing'), 'loose')
    loose = 1;
else
    loose = 0;
end;

%
% Name or ans
%
if loose ~= 0
    disp(' ');
end;

if isempty(inputname(1))
    disp('ans =');
else
    disp([inputname(1) ' =']);
end;

if loose ~= 0
    disp(' ');
end;

try
    disp(opaque_array);
catch
    builtin('disp', opaque_array);
end





