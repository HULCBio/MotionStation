function [xpcScopeObj] = getscope(xpcObj, id)
% GETSCOPE Get a xPC scope object
%
%   GETSCOPE(XPCOBJ, ID) returns the xPC scope object with id ID
%   from the target represented by XPCOBJ. It is an error to access a
%   nonexistant scope. The list of existing scopes may be retrieved via
%   GET(XPCOBJ, 'SCOPES'). ID may be a vector; in that case ALL the id's
%   have to exist.
%
%   See also ADDSCOPE, REMSCOPE

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.11 $ $Date: 2002/03/25 04:17:12 $

if ~isa(xpcObj, 'xpc')
  error('First argument MUST be a xPC object');
end

xpcObj = sync(xpcObj);
if strcmp(xpcObj.Application, 'loader')
  error('No application running');
end

if (nargin == 1)
  try
    id = xpcgate('getscopes');
  catch
    error(xpcgate('xpcerrorhandler'));
  end

end

if isempty(id), xpcScopeObj = []; return; end
% either no scopes given, or no scopes defined

try
  if ~isempty(setdiff(id, xpcgate('getscopes'))) % see if all members of id
                                                 % exist
    error(sprintf('Nonexistant scope(s): %s', ...
                  setdiff(id, xpcgate('getscopes'))));
  end
catch
  error(xpcgate('xpcerrorhandler'));
end

flag      = 0;
modelName = xpcgate('getname');
for index = reshape(id , 1, prod(size(id)))
  try
    if ~flag                              % xpcScopeObj Empty
      xpcScopeObj = xpcsc(index, modelName);
      flag = ~flag;
    else
      xpcScopeObj = [xpcScopeObj; xpcsc(index, modelName)];
    end
  catch
    error(xpcgate('xpcerrorhandler'));
  end %try
end % for index = reshape(id ....

%% EOF xpcScopeObj.m
