function remove(cc,filename)
%REMOVE removes a file from the current Code Composer IDE
%   REMOVE(CC,FILE) - Use this command to remove
%   a) a file from the current Code Composer project.  The file specified
%   must exist in the Code Composer project.
%   b) a GEL file from the current Code Composer IDE.
%
%   See also ADD, OPEN, CD. 

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.2.4.3 $ $Date: 2004/04/01 16:02:45 $

error(nargchk(2,2,nargin));
p_errorif_ccarray(cc);

if ~ishandle(cc),
    error('First Parameter must be a CCSDSP Handle.');
end

if ~ischar(filename),
    error('FILE parameter should be a char array.');
elseif isempty(filename),
    error('FILE parameter is empty.');
end

if isGel(filename)
    close(cc,filename,'unloadgel');
else
    callSwitchyard(cc.ccsversion,[40,cc.boardnum,cc.procnum,0,0],filename);
end

%----------------------------------------
function resp = isGel(filename)
[fpath,fname,fext] = fileparts(filename);
fext = p_deblank(fext);
if strcmpi(fext,'.gel')
    resp = 1;
else 
    resp = 0;
end

% [EOF] remove.m
