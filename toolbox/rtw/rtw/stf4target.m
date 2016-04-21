function stf4target(nameStr, hObj)
% STF4TARGET  converting rtwoptions in system target file to properties in 
%             an object; Note that this is called during object creation.
%             You should not set value to properties that have init access.
%             Things that are setup during this routine:
%             1) Instance specific property
%             2) Default value and the enable status of those properties
%             3) Register those properties in the prop list
%             4) Setup derivation structure
%             5) Setup UI items
%             6) Property preset listener
%             7) Tlc options and make options markup string

% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.17 $
  
  if ~isa(hObj, 'Simulink.STFCustomTargetCC')
    error(['stf4target is an internal utility function.  It cannot be called', ...
           'directly.  Error: unsupported class type.']);
    return;
  end

  if isempty(nameStr)
    error(['empty file name']);
    return;
  end
  
  % If rtw not installed or available
  if ~(exist('rtwprivate')==2 | exist('rtwprivate')==6)
    error(['The required Real-Time Workshop components are not available.']);
    return;
  end

  try 
    [fullSTFName,fid, prevfpos] = rtwprivate('getstf', [], nameStr);
    stfapp = strrep(fullSTFName, matlabroot, '');
    stfapp = strrep(stfapp, '.tlc', '_');
    stfapp = strrep(stfapp, '/', '_');
    stfapp = strrep(stfapp, ':', '_');
    stfapp = strrep(stfapp, '\', '_');
    stfapp = strrep(stfapp, '.', '');
    
    if (fid == -1)
      error(['File "' nameStr '" not found']);
      return;
    end
    
    [rtwoptions, gensettings] = rtwprivate('tfile_optarr', fid);
    
    closestf(fid, prevfpos);
    
    dlgData = [];
    props   = [];
    tag = 'Tag_ConfigSet_RTW_STFTarget_';
    
    % whether system target file is updated to support dynamic dialog call back
    if isfield(gensettings, 'Version') 
      if ischar(gensettings.Version) && str2num(gensettings.Version) >= 1
        supportCB = true;
      else
        supportCB = false;
        warning(['Incorrect Version setting in system target file: ', fullSTFName '.']);
      end
    else
      supportCB = false;
    end
    
    % initial setup for dynamic dialog
    if ~isempty(rtwoptions)
      index         = 0;
      categoryIndex = 0;
      dlgData.tabs.Name = 'tabs';
      dlgData.tabs.Type = 'tab';
      dlgData.tabs.Tag = [tag 'tab'];
      dlgData.supportCB = supportCB;
    end
    
    % If this target is derived from another target; we want to 
    % 1) Attach the parent target as a component of the current target;
    % 2) Transfer default values of the common target options from parent target
    %    to this target;
    if isfield(gensettings, 'DerivedFrom') && ~isempty(gensettings.DerivedFrom)
      parentSTF = gensettings.DerivedFrom;    
      hParentSTF = [];
      try
        hParentSTF = stf2target(gensettings.DerivedFrom);
      end
      
      if isempty(hParentSTF)
        errmsg = ['Cannot instantiate target defined in "', parentSTF, '".  ', ...
                  'It is required for instantiation of the target defined in "', fullSTFName, '".'];
        error(errmsg);
      end
      
      loc_AddParentTarget(hObj, hParentSTF);
    end
    
    % store activate callback in object
    if isfield(gensettings, 'ActivateCallback') && ~isempty(gensettings.ActivateCallback)
      set(hObj, 'ActivateCallback', gensettings.ActivateCallback);
    end
    
    % store post apply callback in object
    if isfield(gensettings, 'PostApplyCallback') && ~isempty(gensettings.PostApplyCallback)
      set(hObj, 'PostApplyCallback', gensettings.PostApplyCallback);
    end
    
    % An empty widget in case a group has no content
    emptyWidget.Name = 'Empty';
    emptyWidget.Type = 'text';
    emptyWidget.Visible = false;
  
    % Add properties for each rtwoption and create make option string on the fly
    makeoption = '';
    tlcoption = '';
    enumReg = [];
    setFunctions = [];
    getFunctions = [];
    hasCallback = false;
    widgetID_index = 0;
    
    % First, go through all the options to see if we need to automatically
    % attach an ERT target
    for i = 1:length(rtwoptions)
      thisOption        = rtwoptions(i);
      thisOptionName    = thisOption.tlcvariable;
      thisOptionMakeVar = thisOption.makevariable;
      if isempty(thisOptionName) && ~isempty(thisOptionMakeVar)
        thisOptionName = thisOptionMakeVar;
      end
      
      uiOnly(i) = false;
      optionIgnored(i) = false;
      
      if ~isempty(thisOptionName)
        switch thisOptionName
         case {'RollThreshold',
               'InlineInvariantSignals',
               'BufferReuse',
               'EnforceIntegerDowncase'
               'FoldNonRolledExpr',
               'LocalBlockOutputs',
               'RTWExpressionDepthLimit',
               'MaxRTWIdLen',
               'IncHierarchyInIds',
               'GenerateComments',
               'ForceParamTrailComments',
               'ShowEliminatedStatement',
               'IgnoreCustomStorageClasses',
               'IncDataTypeInIds', 
               'PrefixModelToSubsysFcnNames', 
               'InlinedPrmAccess',
               'GenerateReport',
               'RTWVerbose'}
          % Ignore options that we have moved to other components
          optionIgnored(i) = true;
          
         case {'LogVarNameModifier', 
               'MatFileLogging', 
               'GenFloatMathFcnCalls'}
          % those properties are promoted to base target, we only
          % present the ui not register property
          uiOnly(i) = true;
          
         case {'ZeroInternalMemoryAtStartup',
               'ZeroExternalMemoryAtStartup',
               'InsertBlockDesc',
               'InitFltsAndDblsToZero'}
          % Ignore ert options that we have moved to other components
          
          if strcmp(get(hObj, 'IsERTTarget'), 'off')
            set(hObj, 'IsERTTarget', 'on');
            
            if isempty(hObj.getComponent('Target'))
              hParentTarget = Simulink.ERTTargetCC;
              
              loc_AddParentTarget(hObj, hParentTarget);
              set(hObj, 'ForcedBaseTarget', 'on');
            else
              hParentTarget = hObj.getComponent('Target');
              if strcmp(get(hParentTarget, 'IsERTTarget'), 'off')
                errmsg = sprintf(['Option "', thisOptionName, ...
                                  '" is available to ERT based target only.  ', ...
                                  'Current target is derived from a non-ERT based target.',...
                                  '  This option is ignored.']);
                warning(errmsg);
              end
            end
          end
          optionIgnored(i) = true;
          
         case {'IncludeMdlTerminateFcn',
               'ERTCustomFileBanners',
               'CombineOutputUpdateFcns',
               'SuppressErrorStatus',
               'GenerateSampleERTMain', 
               'MultiInstanceERTCode', 
               'PurelyIntegerCode', 
               'GenerateErtSFunction'}
          % ERT options will be defined by the base target and thus are UI only.
          uiOnly(i) = true;
          if strcmp(get(hObj, 'IsERTTarget'), 'off')
            set(hObj, 'IsERTTarget', 'on');
            
            if isempty(hObj.getComponent('Target'))
              hParentTarget = Simulink.ERTTargetCC;
              
              loc_AddParentTarget(hObj, hParentTarget);
              set(hObj, 'ForcedBaseTarget', 'on');
              
            else
              hParentTarget = hObj.getComponent('Target');
              if strcmp(get(hParentTarget, 'IsERTTarget'), 'off')
                errmsg = sprintf(['Option "', thisOptionName, ...
                                  '" is available to ERT based target only.  ', ...
                                  'Current target is derived from a non-ERT based target.',...
                                  '  This option is ignored.']);
                warning(errmsg);
              end
            end
          end
        
         otherwise
        end
      end
    end
    
    isERTTarget = strcmp(get(hObj, 'IsERTTarget'), 'on');
    hasForcedBase = strcmp(get(hObj, 'ForcedBaseTarget'), 'on');
    
    for i = 1:length(rtwoptions)
      thisOption        = rtwoptions(i);
      thisOptionName    = thisOption.tlcvariable;
      thisOptionType    = thisOption.type;
      thisOptionDefault = thisOption.default;
      thisOptionMakeVar = thisOption.makevariable;
      thisOptionPrompt  = thisOption.prompt;
      thisOptionEnable  = thisOption.enable;
      if ischar(thisOption.tooltip)
        thisOptionTooltip = thisOption.tooltip;
      else
        thisOptionTooltip = '';
      end
      if supportCB & isfield(thisOption, 'callback') & ~isempty(thisOption.callback)
        thisOptionCallback = thisOption.callback;
      else
        thisOptionCallback = '';
      end    
      if (isfield(thisOption, 'callback') & ~isempty(thisOption.callback)) | ...
            (isfield(thisOption, 'opencallback') & ~isempty(thisOption.opencallback)) | ...
            (isfield(thisOption, 'closecallback') & ~isempty(thisOption.closecallback))
        hasCallback = true;
      end
      
      if isempty(thisOptionName) 
        if ~isempty(thisOptionMakeVar)
          thisOptionName = thisOptionMakeVar;
        else
          thisOptionName = '';
        end
      end
    
      thisUIOnly = uiOnly(i);
      
      % skip this option if it is ignored (move to other component)
      if optionIgnored(i)
        continue;
      end
      
      % Now that we know if we have a forced base ERT target or not, we can remove
      % options that are already declared by the base target
      if ~isempty(thisOptionName) && isERTTarget && hasForcedBase
        switch thisOptionName
         case {'GenerateASAP2',
               'ExtMode', 
               'ExtModeTesting',
               'InlinedParameterPlacement',
               'TargetOS', 
               'MultiInstanceErrorCode', 
               'GenFloatMathFcnCalls', 
               'ERTSrcFileBannerTemplate',
               'ERTHdrFileBannerTemplate',
               'ERTCustomFileTemplate'
              }
          thisUIOnly = true;
        end      
      end
      
      % initialize value
      uiType           = '';
      uiName           = '';
      uiObjectProperty = '';
      uiEntries        = [];
      uiValues         = [];
      propType         = [];
      
      if ~isempty(thisOptionType)
        % Select property type based on thisOptionType
        switch thisOptionType
         case 'Checkbox'
          propType         = 'slbool';
          uiType           = 'checkbox';
          uiName           = thisOptionPrompt;
          uiObjectProperty = thisOptionName;
          
         case 'Popup'        
          if thisUIOnly && hasProp(hObj, thisOptionName)
            % UIOnly ==> this option is defined in internally
            % We need to get its internal definition 
            hOwner = getPropOwner(hObj, thisOptionName);
            hProp = findprop(hOwner, thisOptionName);
            hType = findtype(hProp.DataType);
            if isprop(hType, 'Strings')
              enumStrings = hType.Strings;
            else
              enumStrings = thisOption.popupstrings;
              enumStrings = eval(['{''', strrep(enumStrings, '|', '''; '''), '''}']);
            end
            if isprop(hType, 'Values')
              enumValues = hType.Values;
            else
              enumValues = [0:length(enumStrings)-1];
            end
          else
            propType = ['RTWOptions_EnumType_', stfapp, thisOptionName];
            if isempty(findtype(propType))
              enumStrings = thisOption.popupstrings;
              enumStrings = eval(['{''', strrep(enumStrings, '|', '''; '''), '''}']);
              if isfield(thisOption, 'value') && ~isempty(thisOption.value)
                startVal = thisOption.value;
                endVal   = thisOption.value+length(enumStrings)-1;
                enumValues = [startVal(1) : endVal(1)];
              else
                enumValues = [0:length(enumStrings)-1];
              end
              schema.EnumType(propType, enumStrings, enumValues);
            else
              type = findtype(propType);
              enumStrings = type.Strings;
              enumValues  = type.Values;
              %      else
              %        warning(sprintf('A type named ''%s'' already exists.', propType));
            end
            if isempty(enumReg)
              enumReg.Name = propType;
              enumReg.Strings = enumStrings;
              enumReg.Values = enumValues;
            else
              enumReg(end+1).Name = propType;
              enumReg(end).Strings = enumStrings;
              enumReg(end).Values = enumValues;
            end
          end
          uiType           = 'combobox';
          uiName           = thisOptionPrompt;
          uiObjectProperty = thisOptionName;
          uiEntries        = enumStrings';
          uiValues         = enumValues;
         case 'Edit'
          num = str2num(thisOptionDefault);
          str = num2str(num);
          if strcmp(str, thisOptionDefault) & ~isempty(thisOptionDefault)
            propType = 'int32';
            thisOptionDefault = num;
          else
            propType = 'string';
          end
          uiType = 'edit';
          uiName = thisOptionPrompt;
          uiObjectProperty = thisOptionName;
          
         case 'NonUI'
          if (strcmp(thisOptionDefault, '0') | strcmp(thisOptionDefault, '1'))
            propType = 'slbool';
            thisOptionDefault = str2num(thisOptionDefault);
          elseif isempty(thisOptionDefault)
            propType = 'string';
            thisOptionDefault = '';
          else
            num = str2num(thisOptionDefault);
            str = num2str(num);
            if strcmp(thisOptionDefault, str)
              propType = 'int32';
              thisOptionDefault = num;
            else
            propType = 'string';
            end
          end
          
         case 'Category'
          categoryIndex = categoryIndex + 1;
          index = 0;
          dlgData.tabs.Tabs{categoryIndex}.Name = thisOptionPrompt;
          dlgData.tabs.Tabs{categoryIndex}.Items{1}.Name = '';
          dlgData.tabs.Tabs{categoryIndex}.Items{1}.Type = 'group';
          dlgData.tabs.Tabs{categoryIndex}.Items{1}.Items = {emptyWidget};
          continue;
          
         case 'Pushbutton'
          if supportCB
            uiType = 'pushbutton';
            uiName = thisOptionPrompt;
          else
            continue;
          end
         otherwise
          disp(sprintf('Warning: Unsupported RTWOption type: %s', thisOptionType));
          continue;
        end
        
        % make sure that what we declare UI only has been registered/used by
        % base target
        if ~isempty(propType) && thisUIOnly && ~isempty(thisOptionName) && ...
              ~hObj.hasProp(thisOptionName)
          error(['Internal error: ' thisOptionName ' has been removed from ', ...
                 ' base target definition.']);
        end
      
        % Create property      
        if ~isempty(propType) && ~thisUIOnly && ~isempty(thisOptionName)
          if hObj.hasProp(thisOptionName)
            if hObj.getPropOwner(thisOptionName) == hObj
              warning(['Duplicate definition of "', thisOptionName, '" in ', fullSTFName]);
              continue;
            else
              if supportCB
                warning(['RTWOption ''', thisOptionName, ...
                         ''' declared in system target file ''', ...
                         fullSTFName, ''' conflicts with an option in ', ...
                         'the base target. Please choose a different name.']);
              else
                warning(['RTWOption ''', thisOptionName, ...
                         ''' declared in system target file ''', ...
                         fullSTFName, ''' conflicts with a reserved name.', ...
                         '  Please choose a different name.']);
              end
              continue;
            end
          end
          hThisProp = schema.prop(hObj, thisOptionName, propType);
          hObj.registerPropList('UseParent', 'Only', thisOptionName);
          % cache property handles in a props handle vector
          if isempty(props)
            props = hThisProp;
          else
            props = [props hThisProp];
          end
          
          % setup tlc option string
          if ~isempty(thisOptionName)
            if ~isempty(tlcoption)
              tlcoption = [tlcoption ' '];
            end
            tlcoption = [tlcoption '-a' thisOptionName '='];
            switch propType
             case {'slbool', 'int32'}
              valrep = ['/' thisOptionName '/'];
             case 'string'
              valrep = ['"/' thisOptionName '/"'];
             otherwise
              % enum type
              if isfield(thisOption, 'value') & ~isempty(thisOption.value)
                valrep = ['/' thisOptionName '/'];
              else
                valrep = ['"/' thisOptionName '/"'];
              end
            end
            tlcoption = [tlcoption valrep];
          end
          
          % setup the make option string
          if ~isempty(thisOptionMakeVar)
            if ~isempty(makeoption)
              makeoption = [makeoption ' '];
            end
            makeoption = [makeoption thisOptionMakeVar '='];
            switch propType
             case {'slbool', 'int32'}
              valrep = ['/' thisOptionName '/'];
             case 'string'
              valrep = ['"/' thisOptionName '/"'];
             otherwise
              % this is enum type
              if isfield(thisOption, 'value') & ~isempty(thisOption.value)
                valrep = ['/' thisOptionName '/'];
              else
                valrep = ['"/' thisOptionName '/"'];
              end
            end
            makeoption = [makeoption valrep];
          end
          
          % setup get and set function if any
          if isfield(thisOption, 'setfunction') & ~isempty(thisOption.setfunction)
            if isempty(setFunctions)
              setFunctions.prop = thisOptionName;
              setFunctions.fcn  = thisOption.setfunction;
            else
              setFunctions(end+1).prop = thisOptionName;
              setFunctions(end).fcn    = thisOption.setfunction;
            end
          end
          if isfield(thisOption, 'getfunction') & ~isempty(thisOption.getfunction)
            if isempty(getFunctions)
              getFunctions.prop = thisOptionName;
              getFunctions.fcn  = thisOption.getfunction;
            else
              getFunctions(end+1).prop = thisOptionName;
              getFunctions(end).fcn    = thisOption.getfunction;
            end
          end
        end
        
        % Set up ui item
        if ~isempty(uiType)
          widget = [];
          widget.Name = uiName;
          widget.Type = uiType;
          if ~isempty(uiObjectProperty)
            widget.ObjectProperty = uiObjectProperty;
            widgetID = widget.ObjectProperty;
          else
            widgetID_index = widgetID_index + 1;
            widgetID = sprintf('%s%d', uiType, widgetID_index);
          end
          if thisUIOnly && ~isempty(hObj.Components)
            % redirect the source of this ui to its parent since there will be
            % where get_param and set_param get value from
            propOwner = hObj.Components(1).getPropOwner(uiObjectProperty);
            if ~isempty(propOwner)
              widget.Source = propOwner;
            else
              widget.Source = hObj.Components(1);
            end
          end
          if ~isempty(uiEntries)
            widget.Entries        = uiEntries;
          end
          if ~isempty(uiValues)
            widget.Values         = uiValues;
          end
          widget.ToolTip        = thisOptionTooltip;
          if ~isempty(thisOptionCallback)
            widget.MatlabMethod = 'slprivate';
            widget.Mode = 1;
            widget.DialogRefresh = 1;
            if strcmp(uiType, 'pushbutton')
              widget.MatlabArgs = {'stfTargetDlgCallback', '%source', ...
                                  '%dialog', '', '', thisOptionCallback, uiName};
            else
              widget.MatlabArgs   = {'stfTargetDlgCallback', '%source', ...
                                  '%dialog', widgetID, ...
                                  '%value', thisOptionCallback, uiName};
            end
          end
          index = index + 1;
          widget.RowSpan = [index index];        
          widget.Tag = [tag widgetID];
          dlgData.tabs.Tabs{categoryIndex}.Items{1}.Items{index} = widget;
          dlgData.tabs.Tabs{categoryIndex}.Source = hObj;
        end
        
        % set up default value
        if isempty(thisOptionDefault)
          % No default specified
        elseif hObj.hasProp(thisOptionName)
          currentVal = get_param(hObj, thisOptionName);
          if isnumeric(currentVal) & ischar(thisOptionDefault)
            set_param(hObj, thisOptionName, str2num(thisOptionDefault));
          else
            set_param(hObj, thisOptionName, thisOptionDefault);
          end
        end
        
        % set up enable status
        if ~isempty(thisOptionEnable) & strcmp(thisOptionEnable, 'off') & ...
              hObj.hasProp(thisOptionName)
          setPropEnabled(hObj, thisOptionName, 0);
        end
        
      end % if ~isempty(thisOptionType)
    end % for i = 1:length(rtwoptions)
    
    if ~isempty(dlgData)
      dlgData.tabs.nTabs = length(dlgData.tabs.Tabs);
      dlgData.hasCallback = hasCallback;
    end

    set(hObj, 'EnumDefinition', enumReg);
    set(hObj, 'MakeOptionString', makeoption);
    set(hObj, 'TLCOptionString', tlcoption);
    set(hObj, 'DialogData', dlgData);
    set(hObj, 'SetFunction', setFunctions);
    set(hObj, 'GetFunction', getFunctions);
    
    % setup preset listener
    rtwprivate('stfTargetSetListener', hObj, props);
  catch
    if isempty(fullSTFName)
      name = nameStr;
    else
      name = fullSTFName;
    end
    errmsg = sprintf(['Error while reading system target file %s:\n%s'], ...
                      name, lasterr);
    error(errmsg);
  end
  
function loc_AddParentTarget(hTarget, hParentTarget)
  
  % Keep the old values for the following options:
  % SystemTargetFile
  oldSTFName = get(hTarget, 'SystemTargetFile');
  hTarget.assignFrom(hParentTarget, true);
  set(hTarget, 'SystemTargetFile', oldSTFName);
  attachComponent(hTarget, hParentTarget);
    
  % Set the target to be ERT derived if parent target is
  if isequal(get_param(hParentTarget, 'IsERTTarget'), 'on')
    set(hTarget, 'IsERTTarget', 'on');
  end
    
  % ModelReferenceCompliant is off by default
  set_param(hTarget, 'ModelReferenceCompliant', 'off');
  
% EOF
