function [result] = get(xpcObj, propertyName)
% GET Implements the get method for the xPC object.
%
%   GET(XPCOBJ, 'PROPERTYNAME') gets the value of the propery PROPERTYNAME
%   from the target represented by XPCOBJ. Not all properties are
%   user-readable: just type XPCOBJ to get a list of the readable properties,
%   along with their present values.
%
%   PROPERTYNAME may be a one-dimensional cell array of property names, in
%   which case a cell array of property values is returned.
%
%   XPCOBJ must be a scalar.
%
%   See also SET, and the SET/GET builtin functions

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.11 $ $Date: 2002/03/25 04:16:35 $

if ~isa(xpcObj, 'xPC')
  error('First argument MUST be a xPC object');
end

if (length(xpcObj) < prod(size(xpcObj)))
  error('Vectors of xPC objects cannot be used in GET');
end

try, xpcObj = sync(xpcObj); catch, error(xpcgate('xpcerrorhandler')); end

propname = xpcObj.prop.propname;

if (nargin == 1)
  result = [];
  return
end

% Is it a cell array of properties?
if isa(propertyName, 'cell')
  % make it a row vector before processing, reshape back when done.
  flag = 0;
  for tmpPropName =  reshape(propertyName, 1, prod(size(propertyName)));
    [tmpPropName] = deal(tmpPropName{:}); % Convert from cell
    try
      returnValue   = get(xpcObj, tmpPropName);
    catch
      error(xpcgate('xpcerrorhandler'));
    end

    if (flag)                           % result is ~empty
      result{end + 1} = returnValue;
    else
      result{1}       = returnValue;
      flag            = ~flag;
    end
  end
  result = reshape(result, size(propertyName));
  return
end % if isa(propertyName, 'cell')

if isempty(propertyName)
  error(['Invalid property []']);
end

if ((lower(propertyName(1)) == 'p') & ~isempty(str2num(propertyName(2:end))))
  try
    if (str2num(propertyName(2:end)) < str2num(xpcObj.NumParameters))
      result = xpcgate('getpar', str2num(propertyName(2 : end)));
    else
      error([propertyName, ' is not a valid parameter.']);
    end
  catch
    error(xpcgate('xpcerrorhandler'));
  end
elseif ((lower(propertyName(1)) == 's') & ~isempty(str2num(propertyName(2:end))))
  try
    if (str2num(propertyName(2:end)) < str2num(xpcObj.NumSignals))
      result = xpcgate('getmonsignals', str2num(propertyName(2 : end)));
    else
      error([propertyName, ' is not a valid signal.']);
    end
  catch
    error(xpcgate('xpcerrorhandler'));
  end
else
  index = strmatch(lower(propertyName), lower(propname));
  if isempty(index)
    error(['Invalid property: ', propertyName]);
  end
  if (length(index) > 1)
    error(['Ambiguous property: ', propertyName]);
  end

  % propertyName is valid and unambiguous: see if it is readable.
  if ~isempty(strmatch(lower(propertyName), lower(xpcObj.prop.propWriteOnly)))
    error(['Property ', propname{index}, ' is not user-readable']);
  end
  try
    result = get_value(xpcObj, index);
  catch
    error(xpcgate('xpcerrorhandler'));
  end
end % if ((lower(propertyName(1) == 'p') & ...
%% end get()


% Function: get_value() ===================================================
% Abstract: Does the actual job of fetching the parameter values.
function [result] = get_value(xpcObj, index)

propname = xpcObj.prop.propname;
result   = [];
switch index

 case {6,7}                             % StopTime, SampleTime
  result=str2num(eval(['xpcObj.', propname{index}]));

 case 19                                % TimeLog
  result = xpcgate('gettime');

 case 20                                % StateLog
  result = xpcgate('getstate');

 case 21                                % OutputLog
  result = xpcgate('getoutp');

 case 22                                % TETLog
  result = xpcgate('gettet');

 otherwise
  result = xpcObj.(propname{index});
end % switch index
%% end get_value()

%% EOF get.m