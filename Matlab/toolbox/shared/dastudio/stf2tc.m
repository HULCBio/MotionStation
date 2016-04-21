function hObj = stf2tc(fullClassName)
%STF2TC  Generic object constructor function for dynamic target components
%   based on the rtwoptions structure in an RTW system target file.

%   Call syntax:
%     hObject = stf2tc(fullClassName);
%
%   where:
%     fullClassName = 'DAStudio.RTW_%<baseSTFName>OptionsTC'

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:32:23 $

% Define constant strings:
% - className = %<classNamePrefix>%<baseSTFName>%<classNameSuffix>
classNamePrefix = 'RTW_';
classNameSuffix = 'OptionsTC';
% - componentName = 'RTW System Target File Options'
componentNameSyntax = 'RTW System Target File Options';
% (Alternative) - componentName = 'RTW %<baseSTFName> Options'
%                 componentNameSyntax = 'RTW %s Options';

% Get class name
[packageName, className] = strtok(fullClassName, '.');
if ~isempty(className)
  % Remove '.' from beginning of className
  className(1) = '';
end

% Extract the system target file name from the className
if length(className) > (length(classNamePrefix)+length(classNameSuffix))
  if ((strcmp(className(1:length(classNamePrefix)), classNamePrefix)) & ...
      (strcmp(className((end+1-length(classNameSuffix)):end), classNameSuffix)))
    % Extract the system target file name
    baseSTFName = className((length(classNamePrefix)+1):(end-length(classNameSuffix)));
  else
    disp(warnTextForInvalidClassName(fullClassName));
    hObj = [];
    return;
  end
else
  disp(warnTextForInvalidClassName(fullClassName));
  hObj = [];
  return;
end

% Compile componentName from baseSTFName
componentName = sprintf(componentNameSyntax, baseSTFName);

% Check if this class already exists
hCreateInPackage = findpackage(packageName);
if isempty(hCreateInPackage)
  disp(sprintf('Warning: Could not find package ''%s''', packageName));
  hObj = [];
  return;
end
hThisClass = findclass(hCreateInPackage, className);

% Create class from system target file if it doesn't already exist
if isempty(hThisClass)
  % If rtw not installed or available
  if ~(exist('rtwprivate')==2 | exist('rtwprivate')==6)
    disp(['Warning: Unable to create dynamic target component from ', ...
          'system target file. The required Real-Time Workshop ', ...
          'components are not available.']);
    hObj = [];
    return;
  end

  % Get rtwoptions structure for the specified system target file
  stfName = [baseSTFName, '.tlc'];
  [fullSTFName,fid] = rtwprivate('getstf', [], stfName);
  if (fid == -1)
    if strcmp(stfName, 'ert.tlc') & ~ecoderinstalled(modelName)
      warnTxt = ['Warning: You must install Real-Time Workshop Embedded ', ...
                 'Coder to generate Embedded C code.'];
    else
      warnTxt = ['Warning: Unable to locate system target file: ', stfName];
    end
    disp(warnTxt);
    hObj = [];
    return;
  end
  
  rtwoptions = rtwprivate('tfile_optarr', fid);
  
  % Create the class
  hDeriveFromPackage = findpackage('DAStudio');
  hDeriveFromClass   = findclass(hDeriveFromPackage, 'DynamicTCfromSTF');
  hThisClass = schema.class(hCreateInPackage, className, hDeriveFromClass);
  
  % Add properties for each rtwoption
  for i = 1:length(rtwoptions)
    thisOption = rtwoptions(i);
    thisOptionName = thisOption.tlcvariable;
    thisOptionType = thisOption.type;
    thisOptionDefault = thisOption.default;
    
    % Select property type based on thisOptionType
    switch thisOptionType
    case 'Checkbox'
      propType = 'on/off';
    case 'Popup'
      propType = [className, '_EnumType_', thisOptionName];
      if isempty(findtype(propType))
        enumStrings = thisOption.popupstrings;
        enumStrings = eval(['{''', strrep(enumStrings, '|', '''; '''), '''}']);
        schema.EnumType(propType, enumStrings);
      else
        warning(sprintf('A type named ''%s'' already exists.', propType));
      end
    case {'Edit', 'NonUI'}
      propType = 'string';
    case {'Category', 'Pushbutton'}
      % Skip these options
      continue;
    otherwise
      disp(sprintf('Warning: Unsupported RTWOption type: %s', thisOptionType));
      hObj = [];
      return;
    end
    
    % Create property
    hThisProp = schema.prop(hThisClass, thisOptionName, propType);
    if isempty(thisOptionDefault)
      % No default specified
    else
      hThisProp.AccessFlags.Init = 'on';
      hThisProp.FactoryValue = thisOptionDefault;
    end
  
    % Add pre-set listener for this property
    hPreSetListener = handle.listener(hThisClass, hThisProp, 'PropertyPreSet', ...
                                       @preSetFcn_PropFromSTF);
    schema.prop(hThisProp, 'PreSetListener', 'handle');
    hThisProp.PreSetListener = hPreSetListener;
  end
end

% Instantiate the target component object
if isempty(hThisClass)
  hObj = [];
else
  hObj = eval(fullClassName);
  if isa(hObj, 'DAStudio.DynamicTargetComponent')
    hObj.setName(componentName);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function warnTxt = warnTextForInvalidClassName(fullClassName)
warnTxt = sprintf(['Warning: Invalid class name for dynamic target ', ...
                   'component from system target file: %s'], fullClassName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function preSetFcn_PropFromSTF(hProp, eventData)
% Set this property in the RTWOptions string
hTC = eventData.AffectedObject;
thisProp = hProp.Name;
newVal = eventData.NewVal;

prmVal = setRTWOptionsVal(hTC, thisProp, newVal);

if ~isequal(prmVal, newVal)
  disp(sprintf('Warning: Unable to synchronize RTWOption: %s', thisProp));
end

% EOF
