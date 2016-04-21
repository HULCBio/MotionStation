function dummy = display(r)
%DISPLAY Display a Typedef object.
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2003/11/30 23:13:58 $

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
