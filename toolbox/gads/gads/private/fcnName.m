function name = fcnName(h)
%Convert a function handle into a string.
%   fcnName(h) is a string containind the display name of the funciton
%   handle h;
%
%   MATLAB does not provide any mechanism for converting a function handle to
%   a string one can display, so here we use a hack of capturing the output
%   from display and pulling the name out of that.
%
%   This is used in the code generation tool.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2004/01/16 16:49:58 $

if(isempty(h))
    name = '''''';
else
    name = evalc('display(h)');
    start = find(name == '@');
    name = name(start:end);
    last = find(name == 10) - 1;
    name = name(1:last);
end