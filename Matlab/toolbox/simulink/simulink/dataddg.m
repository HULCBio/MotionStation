function dlgstruct = dataddg(h, name, type)

  %------------------------------------------------------------------------
  % Row One contains a panel with:
  % - Common widgets (minimum, maximum, units and associated labels)
  % - Parameter widets (Value, DataType, Dimensions and Complexity) -or- 
  % - Signal widgets (DataType, Dimensions, Complexity, SampleTime and SampleMode)
  %------------------------------------------------------------------------
  pnlObj.Type            = 'panel';
  pnlObj.RowSpan         = [1 1];
  pnlObj.ColSpan         = [1 2];


  
  minimumLbl.Name        = 'Minimum:';
  minimumLbl.Type        = 'text';
    
  minimum.Name           = '';
  minimum.Type           = 'edit';
  minimum.ObjectProperty = 'Min';
  minimum.Tag            = 'Minimum';
  
  maximumLbl.Name        = 'Maximum:';
  maximumLbl.Type        = 'text';
  
  maximum.Name           = '';
  maximum.Type           = 'edit';
  maximum.ObjectProperty = 'Max';
  maximum.Tag            = 'Maximum';
  
  unitsLbl.Name          = 'Units:';
  unitsLbl.Type          = 'text';
  
  units.Name             = '';
  units.Type             = 'edit';
  units.Tag              = 'DocUnits';
  units.ObjectProperty   = 'DocUnits';
  
  % Universal Simulink help, specific classes may override this below.
  helpTopicKey = 'slhelp';
  
  %-------------------------------------------------------------------------
  %                     Parameter specific
  %-------------------------------------------------------------------------
  
  if (~strcmp(type,'signal') == 1)       

    helpTopicKey = 'simulink_parameter';
    
    valueEditLbl.Name           = 'Value:';
    valueEditLbl.Type           = 'text';
    valueEditLbl.RowSpan        = [1 1];
    valueEditLbl.ColSpan        = [1 1];
    
    valueEdit.Name              = '';
    valueEdit.RowSpan           = [1 1];
    valueEdit.ColSpan           = [2 4];
    valueEdit.Type              = 'edit';
    valueEdit.Tag               = 'valueEdit';
    valueEdit.ObjectProperty    = 'Value';
    


    % Subordinate widgets to valueEdit BEGIN ------------
    dataTypeLbl.Name            = 'Data type:';
    dataTypeLbl.Type            = 'text';
    dataTypeLbl.RowSpan         = [2 2];
    dataTypeLbl.ColSpan         = [1 1];
    
    dataType.Name               = '';
    dataType.RowSpan            = [2 2];
    dataType.ColSpan            = [2 2];
    dataType.Type               = 'edit';
    dataType.Tag                = 'dataType';
    dataType.Enabled            = 0;
    dataType.ObjectProperty     = 'DataType';
    dataType.Bold               = 1;
    
    % These widgets are defined in the common section above
    unitsLbl.RowSpan            = [2 2];
    unitsLbl.ColSpan            = [3 3];
    
    units.RowSpan               = [2 2];
    units.ColSpan               = [4 4];

    dataDimensionsLbl.Name      = 'Dimensions:';
    dataDimensionsLbl.Type      = 'text';
    dataDimensionsLbl.RowSpan   = [3 3];
    dataDimensionsLbl.ColSpan   = [1 1];
    
    dataDimensions.Name         = '';
    dataDimensions.RowSpan      = [3 3];
    dataDimensions.ColSpan      = [2 2];
    dataDimensions.Type         = 'edit';
    dataDimensions.Tag          = 'dataDimensions';
    dataDimensions.Enabled      = 0;
    dataDimensions.ObjectProperty = 'Dimensions';
    dataDimensions.Bold         = 1;

    dataComplexityLbl.Name      = 'Complexity:';
    dataComplexityLbl.Type      = 'text';
    dataComplexityLbl.RowSpan   = [3 3];
    dataComplexityLbl.ColSpan   = [3 3];
    
    dataComplexity.Name         = '';
    dataComplexity.RowSpan      = [3 3];
    dataComplexity.ColSpan      = [4 4];
    dataComplexity.Type         = 'edit';
    dataComplexity.Tag          = 'dataComplexity';
    dataComplexity.Enabled      = 0;
    dataComplexity.Bold         = 1;
    dataComplexity.ObjectProperty = 'Complexity';
    
    % Subordinate widgets to valueEdit END --------------

    % These widgets are defined in the common section above
    minimumLbl.RowSpan          = [4 4];
    minimumLbl.ColSpan          = [1 1];
    
    minimum.RowSpan             = [4 4];
    minimum.ColSpan             = [2 2];

    maximumLbl.RowSpan          = [4 4];
    maximumLbl.ColSpan          = [3 3];
    
    maximum.RowSpan             = [4 4];
    maximum.ColSpan             = [4 4];

    % Construct the panel widget
    pnlObj.LayoutGrid           = [4 4];
    pnlObj.ColStretch           = [0 1 0 1];
    pnlObj.Items                = {valueEditLbl, valueEdit,...
                                   dataTypeLbl, dataType, ... 
                                   dataDimensionsLbl, dataDimensions, ... 
                                   dataComplexityLbl, dataComplexity,...
                                   minimumLbl, minimum, ...
                                   maximumLbl, maximum, ...
                                   unitsLbl, units};
    
  else                          
    %-------------------------------------------------------------------------
    %                     Signal specific
    %-------------------------------------------------------------------------

    helpTopicKey = 'simulink_signal';
    
    % Data type
    SdataTypeLbl.Name           = 'Data type:';
    SdataTypeLbl.Type           = 'text';
    SdataTypeLbl.RowSpan        = [1 1];
    SdataTypeLbl.ColSpan        = [1 1];
    
    SdataType.Name              = '';
    SdataType.Type              = 'combobox';
    SdataType.Entries           = {'auto','double','single','int8','uint8',...
                                   'int16','uint16','int32','uint32','boolean'};
    SdataType.RowSpan           = [1 1];
    SdataType.ColSpan           = [2 2];
    SdataType.Tag               = 'SdataType';
    SdataType.Editable          = 1; 
    SdataType.ObjectProperty    = 'DataType';

    % These widgets are defined in the common section above
    unitsLbl.RowSpan            = [1 1];
    unitsLbl.ColSpan            = [3 3];
    
    units.RowSpan               = [1 1];
    units.ColSpan               = [4 4];

    % Dimensions
    SdimensionsLbl.Name         = 'Dimensions:';
    SdimensionsLbl.Type         = 'text';
    SdimensionsLbl.RowSpan      = [2 2];
    SdimensionsLbl.ColSpan      = [1 1];
    
    Sdimensions.Name            = '';
    Sdimensions.Type            = 'edit';
    Sdimensions.RowSpan         = [2 2];
    Sdimensions.ColSpan         = [2 2];
    Sdimensions.ObjectProperty  = 'Dimensions';
    Sdimensions.Tag             = 'Sdimensions';
    
    % Complexity
    ScomplexityLbl.Name         = 'Complexity:';
    ScomplexityLbl.Type         = 'text'; 
    ScomplexityLbl.RowSpan      = [2 2];
    ScomplexityLbl.ColSpan      = [3 3];
    
    Scomplexity.Name            = '';
    Scomplexity.Type            = 'combobox';
    Scomplexity.Entries         = set(h,'Complexity')';
    Scomplexity.ObjectProperty  = 'Complexity';
    Scomplexity.RowSpan         = [2 2];
    Scomplexity.ColSpan         = [4 4];
    Scomplexity.Tag             = 'Scomplexity';

    % Sample time
    SsampletimeLbl.Name         = 'Sample time:';
    SsampletimeLbl.Type         = 'text'; 
    SsampletimeLbl.RowSpan      = [3 3];
    SsampletimeLbl.ColSpan      = [1 1];
    
    Ssampletime.Name            = '';
    Ssampletime.Type            = 'edit';
    Ssampletime.RowSpan         = [3 3];
    Ssampletime.ColSpan         = [2 2];
    Ssampletime.ObjectProperty  = 'SampleTime';
    Ssampletime.Tag             = 'Ssampletime';
 
    % Sample mode
    SsamplemodeLbl.Name         = 'Sample mode:';
    SsamplemodeLbl.Type         = 'text'; 
    SsamplemodeLbl.RowSpan      = [3 3];
    SsamplemodeLbl.ColSpan      = [3 3];
    
    Ssamplemode.Name            = '';
    Ssamplemode.Type            = 'combobox';
    Ssamplemode.Entries         = set(h,'SamplingMode')';
    Ssamplemode.ObjectProperty  = 'SamplingMode';
    Ssamplemode.RowSpan         = [3 3];
    Ssamplemode.ColSpan         = [4 4];
    Ssamplemode.Tag             = 'Ssamplemode';

    % These widgets are defined in the common section above
    minimumLbl.RowSpan          = [4 4];
    minimumLbl.ColSpan          = [1 1];
    
    minimum.RowSpan             = [4 4];
    minimum.ColSpan             = [2 2];

    maximumLbl.RowSpan          = [4 4];
    maximumLbl.ColSpan          = [3 3];
    
    maximum.RowSpan             = [4 4];
    maximum.ColSpan             = [4 4];
    
    pnlObj.LayoutGrid           = [4 4];
    pblObj.ColStretch           = [0 1 0 1]; 
    pnlObj.Items                = {SdataTypeLbl,SdataType, ...
		    ScomplexityLbl, Scomplexity,...
		    SdimensionsLbl, Sdimensions,...
		    SsampletimeLbl, Ssampletime, ...
		    SsamplemodeLbl, Ssamplemode,...
		    minimumLbl, minimum, ...
		    maximumLbl, maximum, ... 
		    unitsLbl, units};
  end

  %-------------------------------------------------------------------------
  % Row Two contains:
  % - Groupbox with code generation options 
  %-------------------------------------------------------------------------
  grpCodeGen.Items = {};
  rtwInfo = h.RTWInfo;
  hRTWInfoClass = classhandle(rtwInfo);
  storageClass = get(rtwInfo, 'StorageClass');
  props = get(hRTWInfoClass, 'Properties');
  numItems = 1;

  % StorageClass
  wid = [];
  wid.RowSpan = [numItems numItems];
  wid.ColSpan = [1 2];
  wid.ObjectProperty = 'StorageClass';
  wid.Entries = getPropAllowedValues(h, 'StorageClass')';
  wid.Tag = 'storageClass';
  wid.Type = 'combobox';
  wid.Name = 'StorageClass';  
  wid.Mode  = true;
  wid.Source = h;
  wid.DialogRefresh = true;
  wid.MatlabMethod = 'dataddg_cb';
  wid.MatlabArgs = {0, 'refresh_me_cb', h};
    
  grpCodeGen.Items{numItems} = wid;
  numItems = numItems+1;
  
  % Add group for CustomAttributes (if necessary)
  if (strcmp(storageClass, 'Custom'))
    % Now add the Custom Attributes group
    csAttribsProp = findprop(hRTWInfoClass, 'CustomAttributes');
    wid = populate_widget_based_on_property(rtwInfo, csAttribsProp);
    wid.Name = 'Custom attributes';

    % Add the StorageClass property
    wid.RowSpan = [numItems numItems];
    wid.ColSpan = [1 2];

    if (isfield(wid, 'Items') & length(wid.Items) > 0)
      wid.Items = alignNames(wid.Items);
      wid.LayoutGrid = [length(wid.Items) 2];
      grpCodeGen.Items{numItems} = wid;
      numItems = numItems+1;
    end
   
  end

  % Add all the other RTWInfo properties
  for i = 1:length(props)
    % Properties to skip.
    if ((strcmp(props(i).Name, 'StorageClass')) || ...
        (strcmp(props(i).Name, 'CustomStorageClass')) || ...
        (strcmp(props(i).Name, 'CustomAttributes')) || ...
        (strcmp(props(i).Name, 'TypeQualifier')))
      continue;
    end

    wid = populate_widget_based_on_property(rtwInfo, props(i));
    if (strcmp(wid.Type,'unknown') == 1)
      continue;
    end;
   
    wid.MatlabMethod = 'dataddg_cb';
    wid.MatlabArgs = {0, 'refresh_me_cb', h};
%    wid.DialogRefresh = true;    
    wid.RowSpan = [numItems numItems];
    wid.ColSpan = [1 2];

    % If you are not going to show this because type in unknown
    % issue a warning here
    grpCodeGen.Items{numItems} = wid;
    numItems = numItems+1;
  end

  grpCodeGen.Items      = alignNames(grpCodeGen.Items);
  grpCodeGen.LayoutGrid = [numItems 2];

  grpCodeGen.Name       = 'Code generation options';
  grpCodeGen.Type       = 'group';
  grpCodeGen.RowSpan    = [2 2];
  grpCodeGen.ColSpan    = [1 2];
  grpCodeGen.Source     = h.RTWInfo;

  %-------------------------------------------------------------------------
  %                     Generic wrapup widgets
  %-------------------------------------------------------------------------
  % description widget
  description.Name = 'Description:';
  description.Type = 'editarea';
  description.RowSpan = [3 3];
  description.ColSpan = [1 2];
  description.ObjectProperty = 'Description';


  %-------------------------------------------------------------------------
  % The dialog items cell array will consist of either:
  % - A tab container with two tabs (tab1, tab2)
  %    - The first tab will contain Signal/Parameter widgets, codegen widgets,
  %      description and document link widgets
  %    - The second tab will contain additional parameters not in the
  %       Signal/Parameter objects
  %                         -OR-
  % - Just the items listed for tab1 above.   
  %-------------------------------------------------------------------------

  %-------------------------------------------------------------------------
  % tab1 contains:
  % - Panel of Signal/Parameter widgets
  % - Code Generation groupbox
  % - Description editarea
  % - Document link and label
  %-------------------------------------------------------------------------
  tab1.Name = 'Standard attributes';
  tab1.LayoutGrid = [3 2];
  tab1.RowStretch = [0 0 1];
  tab1.ColStretch = [0 1];
  tab1.Source = h;
  tab1.Items = {pnlObj,...
                grpCodeGen,...
                description}; 
  
  %-----------------------------------------------------------------------
  % tab2 contains:
  %  - Additional properties groupbox
  %  - spacer widget to take up all remaining space
  %-----------------------------------------------------------------------

  % Create a groupbox to hold all properties that do no exist in the 
  % basic Simulink Signal or Simulink Parameter object

  grpAdditional.Name       = 'Additional properties';
  grpAdditional.Type       = 'panel';
  grpAdditional.RowSpan    = [1 1];
  grpAdditional.ColSpan    = [1 1];
  grpAdditional.Tag        = strcat('sfCoderoptsdlg_', grpAdditional.Name);
  grpAdditional.Items      = {};
  
  % populate the items list for grpAdditional
  props = find_reduced_set_of_properties(h);
  numItems = 1;
  for i = 1:length(props)
    if (~is_property_visible(props(i)))
      continue;
    end
    type2 = get_data_type_from_property(h, props(i));
    % If the type is unknown do not include this widget in this group
    if (strcmp(type2,'unknown') == 1)
      continue;
    end;
    wid = populate_widget_based_on_property(h, props(i));
    wid.RowSpan = [numItems numItems];
    wid.ColSpan = [1 2];
    grpAdditional.Items{numItems}    = wid;
    numItems = numItems+1;
  end
  grpAdditional.LayoutGrid = [numItems 2];
  grpAdditional.Items = alignNames(grpAdditional.Items);
  
  spacer.Type = 'panel';
  spacer.RowSpan = [2 2];
  spacer.ColSpan = [1 1];
  
  tab2.Name = 'Additional attributes';
  tab2.Items = {grpAdditional, spacer};
  tab2.LayoutGrid = [2 1];
  tab2.RowStretch = [0 1];
    
  %-----------------------------------------------------------------------
  % Assemble main dialog struct
  %-----------------------------------------------------------------------  
  if (strcmp(type,'signal') == 1 || strcmp(type, 'data') == 1)
    dlgstruct.DialogTitle = ['Simulink.', ...
            get(classhandle(h), 'Name'), ': ', name];   
  else
    dlgstruct.DialogTitle = ['Data properties:', name];
  end

  % Determine whether to create tab container based on whether grpAdditional has
  % any items to show
  noGrpItems = length(grpAdditional.Items);
  if (noGrpItems > 0)    
    % Create the tab container
    tabcont.Type = 'tab';
    tabcont.Tabs = {tab1 tab2};  
    dlgstruct.Items = {tabcont};
  else
    dlgstruct.Items      = tab1.Items;
    dlgstruct.LayoutGrid = tab1.LayoutGrid;
    dlgstruct.RowStretch = tab1.RowStretch;
    dlgstruct.ColStretch = tab1.ColStretch;
  end;

  % Do the rest of assignments for this dialog
  dlgstruct.SmartApply = 0;
  dlgstruct.PreApplyCallback = 'dataddg_cb';
  dlgstruct.PreApplyArgs     = {'%dialog', 'preapply_cb'};
  dlgstruct.MinimalApply = true;
  dlgstruct.HelpMethod = 'helpview';
  dlgstruct.HelpArgs   = {[docroot, '/mapfiles/simulink.map'], helpTopicKey};

%-------------------------- End of main function ----------------------------


%-----------------------------------------------------------------------------
function wid = populate_widget_based_on_property(h, prop)

  wid.Name = prop.Name;
  if (~is_property_visible(prop))
    wid.Visible = 0;
  elseif (~is_property_enabled(prop))
    wid.Enabled = 0;
  end

  wid.Type = get_data_type_from_property(h, prop);
  if (strcmp(wid.Type, 'combobox') == 1)
    wid.Entries = set(h, prop.Name )';
    wid.ObjectProperty = prop.Name;
    wid.Mode = 1;
    wid.DialogRefresh = 1;
    wid.Tag = prop.Name;
    
  elseif (strcmp(wid.Type, 'group') == 1)
    newHandle = get(h, prop.Name);
    wid.Source = newHandle;
    props = get(classhandle(newHandle), 'Properties');
    numItems = 1;
    for i = 1:length(props)
      if (~is_property_visible(props(i)))
        continue;
      end
      type = get_data_type_from_property(newHandle, props(i));
      % If the type is unknown do not include this widget in this group
      if (strcmp(type,'unknown') == 1)
        continue;
      end;
      wid2 = populate_widget_based_on_property(newHandle, props(i));
      % If the type is unknown do not include this widget in this group
      wid2.RowSpan = [numItems numItems];
      wid2.ColSpan = [1 2];
      wid.Items{numItems}    = wid2;
      numItems = numItems+1;
    end;
  else
    wid.Tag = prop.Name;
    wid.Mode = 1;
    wid.DialogRefresh = 1;
    wid.ObjectProperty = prop.Name;
  end;

%-----------------------------------------------------------------------------
function type = get_data_type_from_property(h, prop)

% If you a cell array this is simply a combobox
  vals = set(h, prop.Name);
  if (iscell(vals))
    if (length(vals) > 1)
      type = 'combobox';
      return;
    end;
  end;

  %If have a udd object you have a group
  if (is_udd_object(h, prop))
    type = 'group';
    return;
  end;

  % Switch from here if you have gotten out yet
  switch(prop.DataType)
   case {'bool', 'on/off'}
    type = 'checkbox';
   case {'enumeration'}
    type = 'combobox';
   case {'MATLAB array', 'int8', 'int16', 'int32', 'int64', 'single', 'double'...
         ,'uint8', 'uint16', 'uint32', 'uint64', 'string'}
    type = 'edit';
   case {'RTWInfo'}
    type = 'group';
   case {'handle'}
    newHandle = get(h, prop.Name);
    if (isempty(newHandle))
      type = 'unknown';
    else
      type = 'group';
    end
   otherwise
    type = 'edit';
  end

%-----------------------------------------------------------------------------
function props = find_reduced_set_of_properties(h)

  if ( isa(h, 'Simulink.Parameter'))
    basicObj = Simulink.Parameter;
  else
    basicObj = Simulink.Signal;
  end;

  basicProps = get(classhandle(basicObj), 'Properties');
  advancedProps =  get(classhandle(h), 'Properties');

  % If length of the advanced and basic props
  % are the same simply return empty
  if (length(basicProps) == length(advancedProps))
    props = [];
    return;
  end;

  % Here try to find a pruned list of properties
  j = 1;
  for i = 1:length(advancedProps)
    % Only append to the list if not a basic Property of the
    % simulink Parameter (basic object)
    if (is_basic_property(h, advancedProps(i)) == 0 )
      props(j) = advancedProps(i);
      j = j+1;
    end;
  end

%-------------------------------------------------------------------------------
function result = is_property_enabled(property)
  result = 0;
  try
    accessFlags = get(property, 'AccessFlags');
    if (is_property_visible(property) && ...
        strcmp(accessFlags.PublicSet,'on'))
      result = 1;
    end
  catch,
    disp('Nothing to do if the property is not enabled')
  end;

%-------------------------------------------------------------------------------
function result = is_property_visible(property)
  result = 0;
  try
    accessFlags = get(property, 'AccessFlags');
    if (strcmp(property.Visible,'on') && ...
        strcmp(accessFlags.PublicGet,'on'))
      result = 1;
    end
  catch,
    disp('Nothing to do if the property is not visible')
  end;

%-------------------------------------------------------------------------------
function result = is_basic_property(h, property)
  if ( isa(h, 'Simulink.Parameter'))
    basicObj = Simulink.Parameter;
  else
    basicObj = Simulink.Signal;
  end
  basicProps = get(classhandle(basicObj), 'Properties');
  if ( isa(h, 'Simulink.Parameter'))
    basicObject = Simulink.Parameter;
  else
    basicObject = Simulink.Signal;
  end;result = 0;
  for i = 1:length(basicProps)
    if (strcmp(basicProps(i).Name, property.Name))
      result = 1;
      break;
    end;
  end

%---------------------------------------------------------------------------------
function isUdd = is_udd_object(h, prop)
  if (strcmp(prop.AccessFlags.PublicGet , 'off') == 1)
    isUdd = logical(0);
    return;
  end
  try
    newHandle = get(h, prop.Name);
  catch
    isUdd = logical(0);
    return;
  end
  isUdd = logical(1);
  try
    classhandle(newHandle);
  catch
    isUdd = logical(0);
  end

%--------------------------------------------------------------------------------------
% This function takes a prompt like 'StorageClass' and converts it into 'Storage class'
function out = beautifyPrompt(prompt)
  
  out = [prompt(1), lower(regexprep(prompt(2:end), '([A-Z])', ' $1'))];
  
%-------------------------------------------------------------------------------------
function out = alignNames(itemsArray)
% align labels & widgets by making separate text widgets for labels
  try
    lblArray = cell(0);

    lbl.Name = '';
    lbl.Type = 'text';
    lbl.RowSpan = [];
    lbl.ColSpan = [];

    for i = 1:length(itemsArray)
      if (strcmp(itemsArray{i}.Type, 'edit') | strcmp(itemsArray{i}.Type, 'combobox'))
        lblArray{end+1} = lbl;
        lblArray{end}.Name = [beautifyPrompt(itemsArray{i}.Name) ':'];
        lblArray{end}.Tag = lblArray{end}.Name;
        lblArray{end}.RowSpan = itemsArray{i}.RowSpan;
        lblArray{end}.ColSpan = [itemsArray{i}.ColSpan(1) itemsArray{i}.ColSpan(1)];

        itemsArray{i}.Name = '';
        itemsArray{i}.ColSpan = [itemsArray{i}.ColSpan(1)+1 itemsArray{i}.ColSpan(2)];
      end
    end

    out = [itemsArray lblArray];
  catch
    out = in;
  end
  
