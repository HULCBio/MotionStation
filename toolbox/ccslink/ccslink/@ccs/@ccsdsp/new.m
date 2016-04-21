function new(cc,name,type)
%NEW  Create a new project, text file or build configuration.
%  NEW(CC,NAME,TYPE) will produce a new project, 
%  text file or build configuration in Code Composer Studio(R) IDE.  
%  The NAME parameter is a string that designates the new entity.  
%  For text and project types, the NAME parameter is a filename
%  and can include a full path designation.  Conversely, a build
%  configuration always resides within a project and therefore
%  only needs a unique name to differentiate it from other build 
%  configurations within the same project.  If Code Composer has 
%  multiple active projects, the new build configuration is
%  generated within the active project.  The TYPE parameter 
%  explicitly accepts a string to define which entity to create.
%  
%   TYPE - Supported options:
%    'project'   - Code Composer executable project
%    'projlib'   - Code Composer library project
%    'projext'   - Code Composer external make project
%    'text'      - Empty Text file in Code Composer
%    'buildcfg'  - Build configuration in the active project
%
%  NEW(CC,NAME) or  
%  NEW(CC,NAME,[]) if the NAME option has a file extension of '.pjt',
%  this command creates an executable project file.
%
%  For Example
%   cc = ccsdsp;
%   new(cc,'myproj.pjt','project');
%
%   See also ACTIVATE, CLOSE, SAVE.

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.7.4.4 $ $Date: 2004/04/01 16:02:36 $

error(nargchk(2,3,nargin));
p_errorif_ccarray(cc);

if ~ishandle(cc),
    error(['MATLAB:CCSDSP:InvalidHandle'],'First Parameter must be a CCSDSP Handle');
end

if ~ischar(name),
    error('NAME parameter should be a char array');
elseif isempty(name),    
    error('NAME parameter is empty');
end
if nargin == 3 & ~isempty(type),
    if strcmpi(type,'buildcfg') 
        callSwitchyard(cc.ccsversion,[38,cc.boardnum,cc.procnum,0,0],name,type);
    else         
        if isempty(findstr(name,':')),   % Windows only, Full path given?
            name = fullfile(cc.cd,name);
        end
        callSwitchyard(cc.ccsversion,[38,cc.boardnum,cc.procnum,0,0],name,type);
    end
else  % Check extension
    [fpath,fname,fext] = fileparts(name);
    if ~strcmpi(fext,'.pjt'),
        error('The only automatic extension is ''.pjt'', please specify the TYPE');
    end
    if isempty(findstr(name,':')),   % Windows only, Full path given?
        name = fullfile(cc.cd,name);
    end
    callSwitchyard(cc.ccsversion,[38,cc.boardnum,cc.procnum,0,0],name,'project');
end

% [EOF] new.m