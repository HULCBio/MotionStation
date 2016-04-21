function [index] = getparamid(xpcObj, blockpath, paramname, format)
% GETPARAMID Get the index in the parameter list
%
%   GETPARAMID(XPCOBJ, 'BLOCKPATH', 'PARAMNAME', FORMAT) returns the index of
%   a parameter in the parameter list, based on the block path and parameter
%   names; i.e. it is used to find the index of a parameter from its name.
%   The names must be entered in full and in the proper case.
%
%   The last argument, FORMAT, is an optional string which may be either
%   'property' or 'numeric'. Specifying 'property' (which is equivalent to not
%   specifying FORMAT) returns a string of the form 'P12' (for parameter 12),
%   while specifying 'numeric' returns the number 12. The returned value
%   'P12' is suitable for use in SET and GET, i.e.
%
%     GET(XPCOBJ, GETPARAMID(XPCOBJ, 'BLOCKPATH', 'PARAMNAME'))
%
%   would return the appropriate parameter value.
%
%   See also GETSIGNALID, GET, SET.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.8 $ $Date: 2002/03/25 04:17:09 $

try
  if (nargin < 3)
    error('Insufficient number of arguments.');
  end

  if (nargin == 4)
    formatOption = strmatch(lower(format), {'property', 'numeric'}, 'exact');
    if (isempty(formatOption))
      error('FORMAT must be either ''property'' or ''numeric''');
    end
  else
    formatOption = 1;
  end

  modelname = xpcgate('getname');
  index = xpcgate('getparindex', blockpath, paramname);
  if (length(index) == 1)
    index = [];
    return
  end
  if (formatOption == 2)                % numeric
    index = str2num(index(2 : end));
  end
catch
  error(xpcgate('xpcerrorhandler'));
end

%% EOF getparamid.m