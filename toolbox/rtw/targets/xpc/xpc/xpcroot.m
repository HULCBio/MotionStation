function path=xpcroot(unix)

% XPCROOT - xPC Target Root Path
%    XPCROOT returns the path to the root directory of your 
%    xPC Target installation.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/03/25 04:23:05 $

path=[matlabroot,'\toolbox\rtw\targets\xpc'];

if nargin==1
   path=strrep(path,'\','/');
end


