function dummy = display(r)
%DISPLAY Display an RDTX(tm) object.
%   DISPLAY(R) displays an RTDX object by calling DISP, which formats the 
%   channel properties of the object R.

% Copyright 2000-2003 The MathWorks, Inc.
% $Revision: 1.14.4.2 $ $Date: 2004/04/08 20:46:51 $

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
% disp([name, ' = ']);
disp(r);
fprintf(newline)

% [EOF] display.m
