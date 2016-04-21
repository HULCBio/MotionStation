function [result] = get(xpcScopeObj, propertyName)
% GET Get properties for a xpcsc object.
%
%   GET(XPCSCOPEOBJ, 'PROPERTYNAME') gets the value of the property
%   PROPERTYNAME from the scope object represented by XPCSCOPEOBJ.
%   XPCSCOPEOBJ may be a vector of scope objects, or even a matrix.
%   In this case, a matrix of the same shape is returned. Each
%   entry of the returned matrix is the property value for the
%   property PROPERTYNAME of the corresponding entry of XPCSCOPEOBJ.
%
%   PROPERTYNAME must be a one-dimensional cell array of property
%   names. The return value is a cell array of the same dimensions
%   as the XPCSCOPEOBJ matrix, but with one extra dimension along which
%   the property values are stored.
%
%   Note that for an M x 1 (column vector) XPCSCOPEOBJ and a 1 x N
%   PROPERTYNAME, the result is an M x N cell array. However, for a
%   1 x M (row vector) XPCSCOPEOBJ, the result is 1 x M x N cell array.
%   In other words, the properties corresponding to PROPERTYNAME are
%   stored along the last dimension; if the size of that dimension is
%   1, the dimension is replaced by the properties, or else (if it is
%   not 1) an extra dimension is added.
%
%   See also SET, and the SET/GET builtin functions.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.12 $ $Date: 2002/03/25 04:24:27 $

if ~isa(xpcScopeObj, 'xpcsc')
  error('First argument MUST be a xpcsc object');
end

if (nargin == 1)
  result = [];
  return;
end

if (prod(size(xpcScopeObj)) > 1)        % Vector of scope objects
  flag = 0;
  for scopeElement = reshape(xpcScopeObj, 1, prod(size(xpcScopeObj)))
    try
      returnValue = get(scopeElement, propertyName);
    catch
      error(xpcgate('xpcerrorhandler'));
    end

    % begin reassignment for the return value
    if (flag)                           % xpcTmpScopeObj exists
      if isa(returnValue, 'cell')
        [result{end + 1, 1 : length(returnValue)}] = deal(returnValue{:});
      else
        result{end + 1} = returnValue;
      end
      xpcTmpScopeObj     = [xpcTmpScopeObj scopeElement];
    else                                % no elements assigned yet
      if isa(returnValue, 'cell')
        [result{1, 1 : length(returnValue)}] = deal(returnValue{:});
      else
        result{1}   = returnValue;
      end
      xpcTmpScopeObj = scopeElement;
      flag          = ~flag;
    end % if (flag)
  end % for scopeElement = ....
  xpcScopeObj = reshape(xpcTmpScopeObj, size(xpcScopeObj));
  veclength  = size(xpcScopeObj);
  if (size(xpcScopeObj, ndims(xpcScopeObj)) == 1)
    veclength = size(xpcScopeObj);
    veclength = veclength(1 : end - 1);
  end
  if isa(propertyName, 'cell')
    result   = reshape(result, [veclength, size(result, 2)]);
  else
    result   = reshape(result, size(xpcScopeObj));
  end
  return
end % if (prod(size(xpcScopeObj)) > 1)

% Whatever follows this point is for scalar xpcScopeObj
try
  xpcScopeObj = sync(xpcScopeObj);
catch
  error(xpcgate('xpcerrorhandler'));
end

propname    = xpcScopeObj.prop.propname;

% Is it a cell array of properties?
if isa(propertyName, 'cell')
  if (length(propertyName) < prod(size(propertyName)))
    warning(sprintf([ ...
        'Property Name must be a single string or a ONE dimenstional\n',...
        'cell array of strings. The result will be reshaped to 1-d.']));
  end
  % Now know it's 1-d: make it a row vector
  propertyName = reshape(propertyName, 1, prod(size(propertyName)));
  flag = 0;
  for tmpPropName = propertyName
    [tmpPropName] = deal(tmpPropName{:}); % Convert from cell
    try
      returnValue   = get(xpcScopeObj, tmpPropName);
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
  return
end % if isa(propertyName, 'cell')

% Start actually identifying the property and getting the value
index      = strmatch(lower(propertyName), lower(propname));
if isempty(index)
  error(['Invalid property: ', propertyName]);
end

if (length(index) > 1)
  error(['Ambiguous property: ', propertyName]);
end

% propertyName is valid and unambiguous: see if it is readable.
if ~isempty(strmatch(lower(propertyName), ...
                     lower(xpcScopeObj.prop.propWriteOnly)))
  error(['Property ', propname{index}, ' is not user-readable']);
end

try
  result = get_value(xpcScopeObj, index);
catch
  error(xpcgate('xpcerrorhandler'));
end

return
%% end get()

% Function: get_value() ===================================================
% Abstract: Does the actual job of fetching the parameter values.
%
function [result] = get_value(xpcScopeObj, index)
result   = [];
propName = xpcScopeObj.prop.propname;

switch index
 case {1, 2, 5, 6, 8, 9, 11, 12, 21}
  % Version, ScopeId, NumSample, Decimation, TriggerSignal, TriggerLevel,
  % TriggerScope, StartTime, NumPrePostSamples
  if index==12
    if strcmpi(xpcScopeObj.Type, 'Target')
      error(sprintf('Scope # %s is of type ''Target''! Property StartTime is not accessible.', ...
        xpcScopeObj.ScopeId));
    end
  end
  eval(['result = str2num(xpcScopeObj.', propName{index}, ');']);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 case {3, 4, 7, 10, 13, 16, 22}
  % Status, Type, TriggerMode, TriggerSlope, Signals, Application,
  % TriggerSample
  eval(['result = xpcScopeObj.', propName{index}, ';']);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 14                                 % Data
  if strcmpi(xpcScopeObj.Type, 'Target')
    error(sprintf('Scope # %s is of type ''Target''! Property Data is not accessible.', ...
      xpcScopeObj.ScopeId));
  end
  if (strcmpi(xpcScopeObj.Status, 'Finished') | ...
      strcmpi(xpcScopeObj.Status, 'Interrupted'))
    result = xpcgate('getscdata', str2num(xpcScopeObj.ScopeId));
  else
    error(sprintf('Scope # %s is running! Stop it first.', ...
                  xpcScopeObj.ScopeId));
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 case {17, 18, 19}                      % Mode, YLimit, Grid
  if strcmp(xpcScopeObj.Type, 'Target')
    eval(['result = xpcScopeObj.', propName{index}, ';']);
  else
    result=[];
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 20                                % Time
  if strcmpi(xpcScopeObj.Type, 'Target')
    error(sprintf('Scope # %s is of type ''Target''! Property Time is not accessible.', ...
      xpcScopeObj.ScopeId));
  end
  if (strcmpi(xpcScopeObj.Status, 'Finished') | ...
      strcmpi(xpcScopeObj.Status, 'Interrupted'))
    startTime  = xpcgate('getscstarttime', str2num(xpcScopeObj.ScopeId));
    sampleTime = xpcgate('getts');
    result    = [0 : str2num(xpcScopeObj.NumSamples) - 1] * ...
        str2num(xpcScopeObj.Decimation) * ...
        sampleTime + startTime;
  else
    error(sprintf('Scope # %s is running! Stop it first.', ...
                  xpcScopeObj.ScopeId));
  end

end % switch index
%% end get_value()

%% EOF get.m
