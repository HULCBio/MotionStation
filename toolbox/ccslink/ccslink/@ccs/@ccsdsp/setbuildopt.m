function setbuildopt(cc,tool,opt)
%SETBUILDOPT Sets the build options of the active build configuration
%   
%   SETBUILDOPT(CC,TOOL,OSTR) configures the build options to equal
%   the passed OSTR on the specified the build TOOL.  In effect this
%   replaces the switch setting which are applied when the command
%   line TOOL is called.  For example, a build tool could be a 
%   compiler, linker or assembler.  To be sure the TOOL name is
%   defined correctly, use the GETBUILDOPT command to read a list
%   of define build tools.  Note, if OSTR is not recognized by Code
%   Composer, the effect is to clear all switch settings to
%   default values for that specified build tool.  
%   
%   See also GETBULDOPT, SETACTIVE.  

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.2.4.3 $ $Date: 2004/04/01 16:02:52 $

error(nargchk(3,3,nargin));
p_errorif_ccarray(cc);

if ~ishandle(cc),
    error('First Parameter must be a CCSDSP Handle');
end
callSwitchyard(cc.ccsversion,[44,cc.boardnum,cc.procnum,0,0],tool,opt);

% [EOF] setbuildopt.m
