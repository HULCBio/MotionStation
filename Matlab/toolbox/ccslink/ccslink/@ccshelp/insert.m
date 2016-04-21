function insert(cc,fileadd,linetype,type)
%INSERT Adds a debug point into Code Composer Studio(R)
%   INSERT(CC,ADDR,TYPE) places a debug point at the provided address
%   of the DSP.  The CC handle defines the DSP target that will 
%   receive the new debug point. The debug point location is 
%   defined by ADDR, the desired memory address.  Code Composer 
%   provides several types of debug points. Refer to the Code 
%   Composer help documentation for information on their respective 
%   behavior. The following debug TYPE options are supported:
%    'break' or '' - Breakpoint (default)
%    'probe'  - Probe Point
%    'profile' - Profile Point
%
%   INSERT(CC,ADDR) same as above, except the debug point defaults to
%   a breakpoint.
%
%   INSERT(CC,FILE,LINE,TYPE) places a debug point at the specified line
%   in a source file of Code Composer.  The FILE parameter gives the
%   name of the source file, while LINE defines the line number to
%   receive the breakpoint.   Code Composer provides several
%   types of debug points.  Refer to Code Composer documentation for
%   information on their respective behavior. Refer to the previous list
%   of supported point types.
%
%   INSERT(CC,FILE,LINE) same as above, except the debug point defaults to
%   a breakpoint.
%
%   See also DELETE, ADDRESS, RUN.

% Copyright 2004 The MathWorks, Inc.
