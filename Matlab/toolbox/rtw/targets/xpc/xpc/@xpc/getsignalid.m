function [index] = getsignalid(xpcObj, signal, format)
% GETSIGNALID Get the index in the signal list
%
%   GETSIGNALID(XPCOBJ, 'SIGNAL', 'FORMAT') returns the id of a signal from
%   the signal list, based on the path to the signal name. The names must be
%   entered in full and in the proper case.
%
%   The last argument, FORMAT, is an optional string which may be either
%   'property' or 'numeric'. Specifying 'property' (which is equivalent to not
%   specifying FORMAT) returns a string of the form 'S12' (for signal 12),
%   while specifying 'numeric' returns the number 12. The returned value 'S12'
%   is suitable for use in GET, i.e.
%
%     GET(XPCOBJ, GETSIGNALID(XPCOBJ, 'SIGNAL'))
%
%   would return the appropriate signal value.
%
%   See also GETPARAMID, GET.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.8 $ $Date: 2002/03/25 04:17:15 $

try
  if (nargin < 2)
    error('Insufficient number of arguments.');
  end

  if (nargin == 3)
    formatOption = strmatch(lower(format), {'property', 'numeric'}, 'exact');
    if (isempty(formatOption))
      error('FORMAT must be either ''property'' or ''numeric''');
    end
  else
    formatOption = 1;
  end

  index = xpcgate('getsigindex', signal);
  if (formatOption == 1)
    index = ['S', num2str(index)];
  end
catch
  error(xpcgate('xpcerrorhandler'));
end

%% EOF getsignalid.m