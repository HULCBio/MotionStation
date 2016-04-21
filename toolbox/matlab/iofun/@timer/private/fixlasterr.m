function out = fixlasterr()
%fixlasterr modifies the lasterr to hide any java timer object references.
%
%    FIXLASTERR retrieves the last error message, replaces references
%    to the java timer object with more generic 'timer object', and returns
%    the new error as a cell array suitable to be passed into ERROR.
%
%    See Also: ERROR

%    RDD 1-18-2002
%    Copyright 2001-2003 The MathWorks, Inc. 
%    $Revision: 1.3.4.1 $  $Date: 2003/04/23 06:20:36 $

[lerr lid] = lasterr;

% look for the java object references in the text and replace the text with more generic version
lerr = strrep(lerr, 'javahandle.', '');
lerr = strrep(lerr, 'in the ''com.mathworks.timer.TimerTask'' class', 'for timer objects');
lerr = strrep(lerr, 'class com.mathworks.timer.TimerTask', 'timer objects');
lerr = strrep(lerr, 'com.mathworks.timer.TimerTask', 'timer objects');

% check for prepending trace lines.
while strncmp(lerr,'Error using ==>',15) == 1
    [firstline rem] = strtok(lerr,[10 13]);
    lerr = rem(2:length(rem));
end

lasterr(lerr,lid);

if (length(lid)>0)
    out = {lid lerr};
else
    out = {lerr};
end