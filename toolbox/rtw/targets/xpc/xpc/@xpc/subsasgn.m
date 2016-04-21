function [xpcObj] = subsasgn(xpcObj, Subs, value)
% SUBSASGN Assign into xPC target object
%
%   This can be done only for the '.' syntax, i.e. the statement
%   SET(XPCOBJ, 'StopTime', 1000) may be replaced by
%   XPCOBJ.StopTime = 1000. Vectors or cell arrays of xPC objects
%   cannot be set in this fashion.
%   
%   This is a private function and is not to be called directly.
%
%   See also SUBSREF.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2002/03/25 04:17:27 $


if ((length(Subs) == 1) & (Subs.type == '.' ))
  try
    xpcObj = set(xpcObj, Subs.subs, value);
  catch
    error(xpcgate('xpcerrorhandler'));
  end
else
  error(sprintf(['Vectors or cell arrays cannot be initialized\n', ...
		  'as a whole, call the assignment statement', ...
		  'individually for each object']));
end

if (nargout == 0)
  if ~isempty(isempty(1))
    assignin('caller', inputname(1), xpcObj);
  end
end

%% EOF subsasgn.m