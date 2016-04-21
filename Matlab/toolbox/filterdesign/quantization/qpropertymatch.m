function [name,errmsg] = qpropertymatch(name,validnames)
%QPROPERTYMATCH  Match property names against valid list.
%   [NAME, ERRMSG] = PROPERTYMATCH(NAME, VALIDNAMES) matches string NAME against
%   strings in cell array VALIDNAMES, and does completion if NAME uniquely
%   matches one of the VALIDNAMES.  An error message is returned in string
%   ERRMSG.  If no errors, then ERRMSG is empty.

%   Thomas A. Bryan, 6 October 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/14 15:36:17 $

errmsg = '';
if ~ischar(name)
  errmsg = 'Option should be a string.';
  return
end
if ~iscell(validnames)
  errmsg = 'Internal error: VALIDNAMES should be a cell array.';
  return
end
name = lower(name);
ind = strmatch(name,validnames);
if isempty(ind)
  errmsg = 'Invalid string option specified.';
  return
end
if length(ind)==1
  name = validnames{ind};
end
switch name
  case validnames
  otherwise
    completions = sprintf('%s ',validnames{ind});
    errmsg = sprintf([name,' is ambiguous.  Valid completions:\n',completions]);
end
