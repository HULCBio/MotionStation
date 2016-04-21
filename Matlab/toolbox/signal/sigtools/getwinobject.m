function hObj = getwinobject(name)
%GETWINOBJECT   Returns the window object given the name

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:31:56 $

% Generate a list with all windows
[w,lw] = findallwinclasses('nonuserdefined');
w{end+1} = 'functiondefined';
lw{end+1} = 'User Defined';

indx = find(strcmp(name, w));

if isempty(indx),
    
    % Match the current window and find the class name
    indx = find(strcmpi(name,lw));
    if isempty(indx),
        error(generatemsgid('UnknownWindow'), '%s is not a valid window name.', name);
    end
    winclassname = w{indx};
else
    winclassname = name;
end

hObj = feval(['sigwin.' winclassname]);

% [EOF]
