%MFILENAME Name of currently executing M-file.
%   MFILENAME returns a string containing the name of the most
%   recently invoked M-file. When called from within an M-file, it
%   returns the name of that M-file, allowing an M-file to 
%   determine its name, even if the filename has been changed.
%
%   P = MFILENAME('fullpath') returns the full path and name of the
%   M-file in which the call occurs, without the extension. 
%
%   C = MFILENAME('class') in a method returns the class of the method
%   (not including the "@").  If called from a non-method, it yields
%   the empty string.
%
%   If MFILENAME is called with any argument other than the above two,
%   it behaves as if it were called with no argument.
%
%   When called from the command line, MFILENAME returns 
%   an empty string.
%
%   To get the names of the callers of an M-file use DBSTACK with 
%   an output argument.
%
%   See also DBSTACK, FUNCTION, NARGIN, NARGOUT, INPUTNAME.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $

%   Built-in function
