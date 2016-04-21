function display(obj)
%DISPLAY   DISPLAY for CDFEPOCH object.

%   binky
%   Copyright 2001-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:57:34 $

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

if isempty(todatenum(obj))
    disp('     Empty cdfepoch object');
    return;
elseif isequal(size(obj), [1 1])
    disp('     cdfepoch object:');
end

disp(obj);