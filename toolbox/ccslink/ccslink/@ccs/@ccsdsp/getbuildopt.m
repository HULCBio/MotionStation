function opts = getbuildopt(cc,file)
%GETBUILDOPT  Generates structure of build tools and options
%   BT = GETBUILDOPT(CC) returns an array of structures with an entry for
%    each defined build tool.  This list is taken from the active project
%    and active build configuration. Included in the structure is a string
%    that describes the command line tool options. 
%   
%   BT(n).name = Build tool name
%   BT(n).optstring = Command line switches for build tool
%
%   CS = GETBUILDOPT(CC,FILE) returns a string of build options for the
%   source file which is called FILE.  The source file must exist in the
%   active project.  Furthermore, the resulting CS string is taken from the
%   active build configuration.  The type of source file will define the
%   build tool which is used by the CS string. 
%
%   See also SETBUILDOPT, ACTIVATE.

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.6.4.3 $ $Date: 2004/04/06 01:04:44 $

error(nargchk(1,2,nargin));
p_errorif_ccarray(cc);
if ~ishandle(cc) || isempty(cc),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a CCSDSP Handle');
end

if nargin == 2,
    opts = callSwitchyard(cc.ccsversion,[43,cc.boardnum,cc.procnum,0,0],file);
else
    opts = callSwitchyard(cc.ccsversion,[43,cc.boardnum,cc.procnum,0,0]);
end

% [EOF] getbuildopt.m