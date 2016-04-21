function dlgstruct = genericddg(h)

% Copyright 2003-2004 The MathWorks, Inc.
  
  grpMain.Items = {};
  props =  get(classhandle(h), 'Properties');
  numItems = 1;
  for i = 1:length(props)
    if (strcmp(props(i).AccessFlags.PublicGet , 'off') == 1)
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
    grpMain.Items{numItems}    = wid;
    numItems = numItems+1;
  end
  
  grpMain.Name       = '';
  grpMain.Type       = 'group';
  grpMain.RowSpan    = [7 7];
  grpMain.ColSpan    = [1 10];
  grpMain.Tag        = strcat('sfCoderoptsdlg_', grpMain.Name);
  %%%%%%%%%%%%%%%%%%%%%%%
  % Main dialog
  %%%%%%%%%%%%%%%%%%%%%%%
 
    dlgstruct.DialogTitle = h.getFullName;
    dlgstruct.Items = {grpMain};  
  % Do the rest of assignments for this dialog
  dlgstruct.SmartApply = 0;
  %dlgstruct.LayoutGrid = [7 10];
  %dlgstruct.PreApplyCallback = 'dataddg_preapply_callback';
  %dlgstruct.PreApplyArgs     = {h, '%dialog'};
%----------------------------------------------------------------------------
%-----------------------------------------------------------------------------
function wid = populate_widget_based_on_property(h, prop)
  
  wid.Name = prop.Name;
  % Put visible and enable back in 
  % when Adas things are in aslrtw
  %wid.Visible = is_property_visible(prop);
  %wid.Enabled = is_property_enabled(prop);
  wid.Type = get_data_type_from_property(h, prop);
  if (strcmp(wid.Type, 'combobox') == 1)
    wid.Entries = set(h, prop.Name )';
    wid.ObjectProperty = prop.Name;
    wid.Mode = 1;
    wid.DialogRefresh = 1;
  elseif (strcmp(wid.Type, 'group') == 1)
    newHandle = get(h, prop.Name);
    wid.Source = newHandle;
    props = get(classhandle(newHandle), 'Properties');
    numItems = 1;
    for i = 1:length(props)
       if (strcmp(props(i).AccessFlags.PublicGet , 'off') == 1)
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
    wid.Mode = 1;
    wid.DialogRefresh = 1;
    wid.ObjectProperty = prop.Name;
  end;
%-----------------------------------------------------------------------------
function type = get_data_type_from_property(h, prop)
  
  % If it's a cell array this is simply a combobox
  try 
    vals = set(h, prop.Name);
    if (iscell(vals))
      if (length(vals) > 1)  
        type = 'combobox';
        return;
      end;
    end;  
  catch 
  end
  
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
%-------------------------------------------------------------------------------
function result = is_property_enabled(property)
  result = 1;
  try
    accessFlags = get(property,'AccessFlags');
    if (strcmp(accessFlags.PublicGet,'on') & strcmp(accessFlags.PublicSet,'off'))
      result = 0;
    end
  catch,
    disp('Nothing to do if the property is not enabled')
  end;  
%-------------------------------------------------------------------------------
function result = is_property_visible(property)
  result = 1;
  try
    accessFlags = get(property,'AccessFlags');
    if (strcmp(accessFlags.PublicGet,'off'))
      result = 0;
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
  isUdd = strcmp(prop.Data, 'handle');
%---------------------------------------------------------------------------------