function obj = loadobj(B)
%LOADOBJ Load filter for timer objects.
%
%   OBJ = LOADOBJ(B) is called by LOAD when a timer object is 
%   loaded from a .MAT file. The return value, OBJ, is subsequently 
%   used by LOAD to populate the workspace.  
%
%   LOADOBJ will be separately invoked for each object in the .MAT file.
%

%    RDD 12-9-2001
%    Copyright 2001-2002 The MathWorks, Inc. 
%    $Revision: 1.1 $  $Date: 2002/02/19 19:55:41 $

% Warn if java is not running.

if ~usejava('jvm')
    state = warning('backtrace','off');
    warning('MATLAB:timer:nojvm',timererror('MATLAB:timer:nojvm'));
    warning(state);
    return; % not setting obj is OK.
end

if isvalid(B)
    obj = timer(B);
    ud = B.ud; % bring the userdata up to the top level - MATLAB doesn't save it right in userdata.
    set(obj,'Userdata',ud);
else
    obj = B;
end
