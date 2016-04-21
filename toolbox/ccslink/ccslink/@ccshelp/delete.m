function delete(cc,fileadd,linetype,type)
%DELETE  Remove a debug point from Code Composer Studio(R)
%   DELETE(CC,ADDR,TYPE) removes a debug point at the specified address
%   of the DSP.  The CC handle defines the DSP target that will 
%   have it's debug point deleted. The debug point location is 
%   defined by it's memory address: ADDR.  Code Composer provides
%   several types of debug points. Refer to the Code Composer 
%   help documentation for information on their respective 
%   behavior. The following debug TYPE options are supported:
%    'break' or '' - Breakpoint (default)
%    'probe'  - Probe Point
%    'profile' - Profile Point
%
%   DELETE(CC,ADDR) same as above, except the debug types defaults to
%   a breakpoint.
%
%   DELETE(CC,FILE,LINE,TYPE) removes a debug point at the specified line
%   in a source file of Code Composer.  The FILE parameter gives the
%   name of the source file, while LINE defines the line number of
%   the breakpoint to be removed.  The supported debug point types 
%   are the same as listed above.
%
%   DELETE(CC,FILE,LINE) same as above, except the debug point defaults to
%   a breakpoint.
%
%   See also INSERT, ADDRESS, RUN.

% Copyright 2004 The MathWorks, Inc.
