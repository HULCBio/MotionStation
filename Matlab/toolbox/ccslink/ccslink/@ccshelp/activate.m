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

% Copyright 2004 The MathWorks, Inc.
