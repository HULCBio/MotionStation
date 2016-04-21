function display(r)
%DISPLAY Display a Code Composer Studio(R) IDE object.
%   DISPLAY(CC) displays information about the STACK object. 

% Copyright 2001-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2003/11/30 23:12:44 $

% Suppress 'ans' display (UDD limitation, for now)
if 0,
    name = inputname(1);
    if isempty(name)
        name = 'ans';
    end
end

isloose = strcmp(get(0,'FormatSpacing'),'loose');
if isloose,
   newline=sprintf('\n');
else
   newline=sprintf('');
end

fprintf(newline);
disp(r);
fprintf(newline)

% [EOF] display.m