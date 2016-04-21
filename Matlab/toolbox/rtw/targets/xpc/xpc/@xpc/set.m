function [xpcObjRet] = set(varargin)
% SET Implements the set method for the xPC object.
%
%   SET(XPCOBJ, 'PROPERTYNAME', PROPERTYVALUE....) sets the properties of
%   the target represented by XPCOBJ. Not all properties are user-writable:
%   type SET(XPCOBJ) to get a list of the writable properties, along with
%   the possible values (for a finite set of possibilities). Properties
%   must be entered in pairs of the form shown above. The alternate syntax
%   set(XPCOBJ, PROPERTYNAME, PROPERTYVALUE) may also be used, where
%   PROPERTYNAME and PROPERTYVALUE are one-dimensional cell arrays of the
%   same size (this means they have to both be row vectors or both column
%   vectors), and the corresponding values for properties in PROPERTYNAME
%   are stored in PROPERTYVALUE. SET typically does not return a value;
%   however, if called with an explicit return argument,  e.g.
%   A = SET(XPCOBJ, PROPERTYNAME, PROPERTYVALUE), it returns the
%   value of XPCOBJ after the indicated settings have been made. This form
%   has no effect for the case A = SET(XPCOBJ).
%
%   XPCOBJ must be a scalar.
%
%   See also GET, and the SET/GET builtin functions.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.11 $ $Date: 2002/03/25 04:16:47 $

if ~isa(varargin{1}, 'xPC')
  error('First argument MUST be a xPC object');
end

if (length(varargin{1}) < prod(size(varargin{1})))
  error('Vectors of xPC objects cannot be used in SET');
end

xpcObj  = varargin{1};
tmpProp = xpcObj.prop;

if (nargin == 1)
  try
    show_possible_settings(tmpProp);
  catch
    error(xpcgate('xpcerrorhandler'));
  end
  if (nargout == 1), xpcObjRet = []; end
  return;
end

if ~rem(nargin, 2)
   error(['Input arguments following the object name must be pairs', ...
          ' of the form PropertyName, Property Value']);
end

propname = tmpProp.propname;

% Is it a cell array of properties?
if (isa(varargin{2}, 'cell') & (nargin == 3))
  propertyName  = varargin{2};
  propertyValue = varargin{3};
  if ~all(size(propertyName) == size(propertyValue))
    error(['Property Name and Property Value cell arrays must be of' ...
           ' same size!']);
  end
  if (length(propertyName) < prod(size(propertyName)))
    warning(sprintf([ ...
        'Property Name must be a single string or a ONE dimensional\n',...
        'cell array of strings. The result will be reshaped to 1-d.']));
  end
  % Now know it's 1-d: make it a row vector
  propertyName  = reshape(propertyName,  1, prod(size(propertyName)));
  propertyValue = reshape(propertyValue, 1, prod(size(propertyValue)));
  flag          = 0;
  propertyName = reshape([propertyName; propertyValue], ...
                         1, 2 * length(propertyValue));
  try
    xpcObjRet = set(xpcObj, propertyName{:});
  catch
    error(xpcgate('xpcerrorhandler'));
  end

  if (nargout == 0)
    if ~isempty(inputname(1)), assignin('caller', inputname(1), xpcObjRet); end
    clear xpcObjRet
    return
  end
  return
end % if isa(varargin{1}, 'cell')

for i = [1 : (nargin - 1) / 2]
  propertyName = varargin{ i * 2};
  if ((lower(propertyName(1)) == 'p') & ...
      ~isempty(str2num(propertyName(2:end)))) % p0, p1, etc.
    try
      xpcObj = set_new_value(xpcObj, 25,  propertyName);      % TunParamIndex
      xpcObj = set_new_value(xpcObj, 26, varargin{i * 2 + 1});% ParameterValue
    catch
      error(xpcgate('xpcerrorhandler'));
    end
  elseif ((lower(propertyName(1)) == 's') & ...
      ~isempty(str2num(propertyName(2:end)))) % s0, s1, etc.
    error('Signal Properties are read-only');
  else
    propIndex = strmatch(lower(propertyName), lower(propname));
    if isempty(propIndex)
      error(['Invalid property: ',   propertyName]);
    end
    if (length(propIndex) > 1)
      error(['Ambiguous property: ', propertyName]);
    end
    % Now that we have determined the property is valid, we check if it is
    % read-only or not
    if (isempty(strmatch(lower(propertyName), lower(tmpProp.propWritable))))
      error(['Property ', propname{propIndex}, ' is read-only.']);
    end
    try
      xpcObj = set_new_value(xpcObj, propIndex, varargin{i * 2 + 1});
    catch
      error(xpcgate('xpcerrorhandler'));
    end
  end
end

try, xpcObj = sync(xpcObj); catch, error(xpcgate('xpcerrorhandler')); end

if (nargout == 0)
  if ~isempty(inputname(1)), assignin('caller', inputname(1), xpcObj); end
  return
end
xpcObjRet = xpcObj;                     % nargout == 1
return
%% end set()


% Function: set_new_value() ================================================
% Abstract: Actually sets the new property value; takes as arguments the
%           xPC object, the index in the 'prop' substructure, and
%           the property value.
function [xpcObj] = set_new_value(xpcObj, propIndex, propValue)

propValue  = lower(propValue);
tmpProp    = xpcObj.prop;

switch propIndex
 case {6,7}                             % StopTime, SampleTime
  if propIndex==6
      if propValue == inf
          propValue = -1;
      end
  end 
  eval(['xpcObj.', tmpProp.propname{propIndex}, ' =  num2str(propValue);']);
  xpcObj.execqueue = [xpcObj.execqueue, propIndex];
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 case 10                                % Command
  index1 = strmatch(propValue, {'start', 'stop', 'boot', 'remove'});
  if isempty(index1)
    error(['Invalid value ', propValue, ' for property: Command']);
    return
  end
  if (length(index1) > 1)
    error(['Ambiguous value ', propValue, ' for property: Command']);
    return
  end
  switch index1
   case 1
    xpcObj.Command = 'Start';
   case 2
    xpcObj.Command = 'Stop';
   case 3
    xpcObj.Command = 'Boot';
   case 4
    xpcObj.Command = 'Remove';
  end % switch index1
  xpcObj.execqueue = [xpcObj.execqueue, propIndex];
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 case 11                                % ViewMode
  if ischar(propValue)
    if strmatch(lower(propValue), 'all')
      xpcObj.ViewMode = 'All';
    else
      error([propValue, ': Unknown value for property ViewMode']);
    end
  elseif isa(propValue, 'double')
    if (length(propValue) > 1)
      error('Only one scope can be selected');
    end
    if any(find(propValue == xpcgate('getscopes')))
      xpcObj.ViewMode = propValue;
    else
      error([num2str(propValue), ': No such scope']);
    end
  else % if ischar(propValue)    i.e. neither char == 'normal' or double
    error(['ViewMode must be either a scalar scopeId,'...
          'or the string ''normal''']);
  end
  % if we have survived so far, it's a legal value
  xpcObj.execqueue = [xpcObj.execqueue, propIndex];
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 case 17                                % LogMode
  if ischar(propValue)
    if strmatch(lower(propValue), 'normal')
      xpcObj.LogMode   = 0;
      xpcObj.execqueue = [xpcObj.execqueue, propIndex];
    else
      error([propValue, ': Unknown value for property LogMode']);
    end
  elseif isa(propValue, 'double')
    if (propValue >= 0)
      xpcObj.LogMode   = propValue;
      xpcObj.execqueue = [xpcObj.execqueue, propIndex];
    else
      error('Increment for value-equidistant logging must be positive');
    end
  else
    error('LogMode must be either ''normal'' or a positive increment');
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 case {23, 28}
  % ShowParameters, ShowSignals
  index1 = strmatch(propValue,{'on', 'off'});
  if isempty(index1)
    error(['Invalid value ', propValue, ' for property: ', ...
           tmpProp.propname{propIndex}]);
    return;
  end
  if (length(index1) > 1)
    error(['Ambiguous value ', propValue, ' for property: ', ...
           tmpProp.propname{propIndex}]);
    return
  end
  switch index1
   case 1
    eval(['xpcObj.', tmpProp.propname{propIndex} ' = ''On'';']);
   case 2
    eval(['xpcObj.', tmpProp.propname{propIndex} ' = ''Off'';']);
  end % switch index1
  xpcObj.execqueue      = [xpcObj.execqueue, propIndex];
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 case 25                                % TunParamIndex
  xpcObj.TunParamIndex(end + 1)  = str2num(propValue(2:end));
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 case 26                                % ParameterValue
  xpcObj.ParameterValue{end + 1} = propValue;
  xpcObj.execqueue               = [xpcObj.execqueue, propIndex];
end % switch propindex
%% end set_new_value()

% Function: show_possible_settings() =======================================
% Abstract: show all user-modifiable settings for xPC object
function show_possible_settings(tmpProp)
propWritable = tmpProp.propWritable;

fprintf(1, 'xPC Target Object:\n\tWritable Properties\n\n');
for propIndex = [1 :  size(propWritable, 1)]
  if isempty(strmatch(propWritable{propIndex, 1}, tmpProp.propWriteOnly))
    fprintf(1, '\t%-20s', propWritable{propIndex, 1});
    if ~isempty(propWritable{propIndex, 2})
      fprintf(1, ': %s\n', propWritable{propIndex, 2});
    else
      fprintf(1, '\n');
    end
  end
end
%% end show_possible_settings

%% EOF set.m
