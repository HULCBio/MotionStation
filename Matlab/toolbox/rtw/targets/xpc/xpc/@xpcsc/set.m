function [xpcScopeObjRet] = set(varargin)
% SET Implements the set method for the xpcsc object.
%
%   SET(XPCSCOPEOBJ, 'PROPERTYNAME', PROPERTYVALUE....) sets the properties of
%   the scope represented by XPCSCOPEOBJ. Not all properties are
%   user-writable: type SET(XPCSCOPEOBJ) to get a list of the writable
%   properties, along with the possible values (for a finite set of
%   possibilities). Properties must be entered in pairs of the form shown
%   above. The alternate syntax set(XPCSCOPEOBJ, PROPERTYNAME, PROPERTYVALUE)
%   may also be used, where PROPERTYNAME and PROPERTYVALUE are one-dimensional
%   cell arrays of the same size (this means they have to both be row vectors
%   or both column vectors), and the corresponding values for properties in
%   PROPERTYNAME are stored in PROPERTYVALUE. SET typically does not return a
%   value; however, if called with an explicit return argument, e.g.  A =
%   SET(XPCSCOPEOBJ, PROPERTYNAME, PROPERTYVALUE), it returns XPCSCOPEOBJ
%   after the indicated settings have been made. This form has no effect for
%   the case A = SET(XPCSCOPEOBJ).
%
%   XPCSCOPEOBJ may be a vector of xpcsc objects.
%
%
%   See also GET, and the SET/GET builtin functions

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.12 $ $Date: 2002/03/25 04:24:18 $

if ~isa(varargin{1}, 'xpcsc')
  error('First argument MUST be a xpcsc object');
end

tmpProp  = initprop;
propname = tmpProp.propname;

if (nargin == 1)
  try
    show_possible_settings(tmpProp);
  catch
    error(xpcgate('xpcerrorhandler'));
  end
  return
end

xpcScopeObj = varargin{1};

if ~rem(nargin, 2)
  error(['Input arguments following the object name must be pairs', ...
         'of the form PropertyName, Property Value']);
end

if (prod(size(varargin{1})) > 1)        % Vector of scope objects
  flag = 0;
  for scopeElement = reshape(varargin{1}, 1, prod(size(varargin{1})))
    try
      scopeElement = set(scopeElement, varargin{2:end});
    catch
      error(xpcgate('xpcerrorhandler'));
    end
    % begin reassignment for the return value
    if (flag)                           % xpcScopeObj exists
      xpcScopeObj = [xpcScopeObj scopeElement];
    else                                % no elements assigned yet
      xpcScopeObj = scopeElement;
      flag = ~flag;
    end % if (flag)
  end % for scopeElement = ....
  xpcScopeObj = reshape(xpcScopeObj, size(varargin{1}));
  if (nargout == 0)
    if ~isempty(inputname(1))
      assignin('caller', inputname(1), xpcScopeObj);
    end
  else                                  % nargout == 1
    xpcScopeObjRet = xpcScopeObj;
  end
  return
end % if (prod(size(varargin{1})) > 1)

% Whatever follows this point is for scalar varargin{1}
xpcScopeObj = varargin{1};

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
  flag = 0;
  propertyName  = reshape([propertyName; propertyValue], ...
                          1, 2 * length(propertyValue));
  try
    xpcScopeObjRet = set(xpcScopeObj, propertyName{:});
  catch
    error(xpcgate('xpcerrorhandler'));
  end
  return
end % if isa(varargin{1}, 'cell')

for i = [1 : (nargin - 1) / 2]
  propertyName = varargin{i * 2};
  propIndex    = strmatch(lower(propertyName), lower(propname));

  if isempty(propIndex)
    error(['Invalid Scope property: ', propertyName]);
  end
  if (length(propIndex) > 1)
    error(['Ambiguous Scope property: ', propertyName]);
  end
  % Check whether the property is read-only (know it is unamiguous)
  if isempty(strmatch(lower(propertyName), lower(tmpProp.propWritable)))
    error(['Property ', propname{propIndex}, ' is read-only.']);
  end

  try
    xpcScopeObj = set_new_value(xpcScopeObj, ...
                                propIndex, varargin{i * 2 + 1});
    catch
      error(xpcgate('xpcerrorhandler'));
    end
end

try
  xpcScopeObj = sync(xpcScopeObj);
catch
  error(xpcgate('xpcerrorhandler'));
end

if ((nargout == 0) & ~isempty(inputname(1)) & (length(xpcScopeObj) == 1))
  assignin('caller', inputname(1), xpcScopeObj);
  return
end

if (nargout == 1), xpcScopeObjRet = xpcScopeObj; end

%% end set()


% Function: set_new_value() ================================================
% Abstract: Actually sets the new property value; takes as arguments the
%           xpcscope object, the index in the 'prop' substructure, and
%           the property value.
function [xpcScopeObj] = set_new_value(xpcScopeObj, propIndex, propValue)

propValue = lower(propValue);
tmpProp   = xpcScopeObj.prop;

switch propIndex
 case {5, 6, 8, 9, 11, 21}
  % NumSamples, Decimation, TriggerSignal, TriggerLevel, TriggerScope,
  % NumPrePostSamples
  eval(['xpcScopeObj.', tmpProp.propname{propIndex}, ...
        '= num2str(propValue);']);
  xpcScopeObj.execqueue  = [xpcScopeObj.execqueue, propIndex];
 case 22
  % TriggerSample
  xpcScopeObj.(tmpProp.propname{propIndex}) = propValue;
  xpcScopeObj.execqueue  = [xpcScopeObj.execqueue, propIndex];
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 case 7                                 % TriggerMode
  index1 = strmatch(propValue, {'freerun', 'software', 'signal', 'scope', 'endscope'});
  if isempty(index1)
    error(['Invalid value ', propValue, ' for property: TriggerMode']);
  end
  if (length(index1) > 1)
    error(['Ambiguous value ', propValue, ' for property: TriggerMode']);
  end
  switch index1
   case 1
    xpcScopeObj.TriggerMode = 'FreeRun';
   case 2
    xpcScopeObj.TriggerMode = 'Software';
   case 3
    xpcScopeObj.TriggerMode = 'Signal';
   case 4
    xpcScopeObj.TriggerMode = 'Scope';
   case 5
    xpcScopeObj.TriggerMode = 'EndScope';
  end
  xpcScopeObj.execqueue = [xpcScopeObj.execqueue, propIndex];
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 case 10                                % TriggerSlope
  index1 = strmatch(propValue, {'either', 'rising', 'falling'});
  if isempty(index1)
    error(['Invalid value ' propValue, ' for property: TriggerSlope']);
  end
  if (length(index1) > 1)
    error(['Ambiguous value ' propValue, ' for property: TriggerSlope']);
  end
  switch index1
   case 1
    xpcScopeObj.TriggerSlope = 'Either';
   case 2
    xpcScopeObj.TriggerSlope = 'Rising';
   case 3
    xpcScopeObj.TriggerSlope = 'Falling';
  end
  xpcScopeObj.execqueue = [xpcScopeObj.execqueue,propIndex];
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 case {13, 18}                          % Signals, Ylimit
  eval(['xpcScopeObj.', tmpProp.propname{propIndex}, ' = propValue;']);
  xpcScopeObj.execqueue = [xpcScopeObj.execqueue, propIndex];
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 case 15                                % Command
   index1 = strmatch(propValue,{'start', 'stop', 'trigger'});
   if isempty(index1)
     error(['Invalid value ', propValue, ' for property: Command']);
   end
   if (length(index1) > 1)
     error(['Ambiguous value ', propValue, ' for property: Command']);
   end

   switch index1
    case 1
     xpcScopeObj.Command = 'Start';
    case 2
     xpcScopeObj.Command = 'Stop';
    case 3
     xpcScopeObj.Command = 'Trigger';
   end
   xpcScopeObj.execqueue = [xpcScopeObj.execqueue, propIndex];
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 case 17                                % Mode
  if strcmp(xpcScopeObj.Type,'Target')
    index1 = strmatch(propValue,{'numerical', 'redraw (graphical)', ...
                    'sliding (graphical)', 'rolling (graphical)'});
    if isempty(index1)
      error(['Invalid value ', propValue, ' for property: Mode']);
    end
    if (length(index1) > 1)
      error(['Ambiguous value ', propValue, ' for property: Mode']);
      return
    end;
    switch index1
     case 1
      xpcScopeObj.Mode    = 'Numerical';
     case 2
      xpcScopeObj.Mode    = 'Redraw (Graphical)';
     case 3
      xpcScopeObj.Mode    = 'Sliding (Graphical)';
     case 4
      xpcScopeObj.Mode    = 'Rolling (Graphical)';
    end
    xpcScopeObj.execqueue = [xpcScopeObj.execqueue,propIndex];
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 case 19                                % Grid
  if strcmp(xpcScopeObj.Type, 'Target')
    index1 = strmatch(propValue,{'on', 'off'});
    if isempty(index1)
      error(['Invalid value ', propValue, ' for property: Grid']);
    end
    if (length(index1) > 1)
      error(['Ambiguous value ', propValue, ' for property: Grid']);
    end
    switch index1
     case 1
      xpcScopeObj.Grid    = 'On';
     case 2
      xpcScopeObj.Grid    = 'Off';
    end
    xpcScopeObj.execqueue = [xpcScopeObj.execqueue, propIndex];
  end
end % switch propIndex
%% end set_new_value()

% Function: show_possible_settings() =======================================
% Abstract: show all user-modifiable settings for xPC object
function show_possible_settings(tmpProp)
propWritable = tmpProp.propWritable;

fprintf(1, 'xPC Scope Object:\n\tWritable Properties\n\n');
for propIndex = [1 :  size(propWritable, 1)]
  if isempty(strmatch(propWritable{propIndex, 1}, tmpProp.propWriteOnly))
    % property is Writable and not WriteOnly
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