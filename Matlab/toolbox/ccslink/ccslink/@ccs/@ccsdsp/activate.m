function activate(cc,name,type)
%ACTIVATE  Make files/objects active in Code Composer Studio(R)
%   ACTIVATE(CC,NAME,TYPE) forces the specified file or object
%   to be the active one in the Code Composer IDE.  The type
%   of entity is specified by the TYPE parameter.  
%
%   ACTIVATE(CC,'my.pjt','project')  - Make specified project active
%   ACTIVATE(CC,'text.cpp','text') - Give focus to specified text file 
%   ACTIVATE(CC,'xdebug' ,'buildcfg') - Make specified build config active
%
%   See also NEW, REMOVE.

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.2.4.4 $ $Date: 2004/04/06 01:04:37 $

error(nargchk(3,3,nargin));
p_errorif_ccarray(cc);

if ~ishandle(cc),
    error('First Parameter must be a CCSDSP Handle');
end 
if strcmpi(type,'project') | strcmpi(type,'text'),
    try 
        name = cc.fileparamparser(name);
    catch
         % Try anyway
    end
end
callSwitchyard(cc.ccsversion,[49,cc.boardnum,cc.procnum,0,0],name,type);

% [EOF] activate.m
