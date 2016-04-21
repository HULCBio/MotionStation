% update_assert_sys
%   This function update pre-packed assertion blocks based on the values of mask parameters.
%


%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.10.2.3 $  $Date: 2004/04/15 00:32:47 $
function update_assert_sys(block,resolution_length)
if (local_is_checker(block))
  type=get_param(block, 'masktype');
  
  local_update_enables(block, type);
  local_update_description(block, type);
  local_update_outport(block);
  local_update_assert(block, type);
  local_update_icon(block);
  
  switch (type)
   case 'Checks_Gradient'
    local_update_gradient(block, type);
   case 'Checks_Resolution'
    local_update_resolution(block, type,resolution_length);
   case { ...
       'Checks_SMin', 'Checks_SMax', 'Checks_SRange', 'Checks_SGap', ...
       'Checks_DMin', 'Checks_DMax', 'Checks_DRange', 'Checks_DGap'...
	}
    local_update_boundary(block, type);
   otherwise
  end;
else
  error('Unknown block type!');
end;


%%
%% local helper functions 
%%

%
% Return 1 if the block is a valid pre-packed assertion block.
%
function bool = local_is_checker(block)  
  bool=0;
  types = { ...
      'Checks_SMin', ...
      'Checks_SMax', ...
      'Checks_SGap', ...
      'Checks_SRange', ...
      'Checks_DMin', ...
      'Checks_DMax', ...
      'Checks_DGap', ...
      'Checks_DRange', ...
      'Checks_Gradient', ...
      'Checks_Resolution' ...
	  };
  type = get_param(block, 'masktype');
  for i=1:length(types),
    if (strcmp(type, types{i})) bool=1; end;  
  end;
  
%
% disable/enable a particular mask input
%
function local_disable_dialog(block, item, disabled)
  names = get_param(block, 'MaskNames');
  enableStatus = get_param(block, 'MaskEnables');
  for i = 1:length(names)
    if strcmp(names{i}, item)
      if (disabled)
	enableStatus{i} = 'off';
      else
	enableStatus{i} = 'on';
      end
    end
  end
  set_param(block, 'MaskEnables', enableStatus);

function relop=local_relop(mode)
  if (strcmp(mode, 'on'))
    relop = '<=';
  else
    relop = '<';
  end;

function local_delete_output(block)
  ph=get_param(block, 'porthandles');
  line=get_param(ph.Outport(1), 'line');
  delete_line(line);
  
%%
%% General purpose update functions
%%

%
% Update blocks based on enabled status
% 

function local_update_enables(block, type)
  
  % get the disable/enable status of the block
  switch (get_param(bdroot, 'AssertionControl'))
   case 'EnableAll'
    disabled = 0;
    local_disable_dialog(block, 'enabled', 1);
    local_disable_dialog(block, 'callback', 0);
   case 'DisableAll'
    disabled = 1;
    local_disable_dialog(block, 'enabled', 1);
    local_disable_dialog(block, 'callback', 1);
   case 'UseLocalSettings'
    disabled = strcmp(get_param(block, 'enabled'), 'off');
    local_disable_dialog(block, 'enabled', 0);
    local_disable_dialog(block, 'callback', disabled);
  end;
 
  userdata = get_param(block, 'UserData');
  if (disabled)
      userdata.enabled = 0;
  else
      userdata.enabled = 1;
  end
  set_param(block, 'UserData', userdata);
  
%
% update the description of a block
%
function local_update_description(block, type)
  switch (type)
   case 'Checks_SMin'
    min = get_param(block, 'min');
    min_included = get_param(block, 'min_included');
    description = sprintf('%s %s u', min, local_relop(min_included));
   case 'Checks_SMax'
    max = get_param(block, 'max');
    max_included = get_param(block, 'max_included');
    description = sprintf('u %s %s', local_relop(max_included), max);
   case 'Checks_SGap'
    min = get_param(block, 'min');
    min_included = get_param(block, 'min_included');
    max = get_param(block, 'max');
    max_included = get_param(block, 'max_included');
    description = sprintf('u %s %s || %s %s u', local_relop(min_included), min, max, local_relop(max_included));
   case 'Checks_SRange'
    min = get_param(block, 'min');
    min_included = get_param(block, 'min_included');
    max = get_param(block, 'max');
    max_included = get_param(block, 'max_included');
    description = sprintf('%s %s u %s %s', min, local_relop(min_included), local_relop(max_included), max);
   case 'Checks_DMin'
    min_included = 'off'; % get_param(block, 'min_included');
    description = sprintf('min %s sig', local_relop(min_included));
   case 'Checks_DMax'
    max_included = 'off'; % get_param(block, 'max_included');
    description = sprintf('sig %s max', local_relop(max_included));
   case 'Checks_DGap'
    min_included = 'off'; % get_param(block, 'min_included');
    max_included = 'off'; % get_param(block, 'max_included');
    description = sprintf('sig %s min || max %s sig', local_relop(min_included), local_relop(max_included));
   case 'Checks_DRange'
    min_included = 'off'; % get_param(block, 'min_included');
    max_included = 'off'; % get_param(block, 'max_included');
    description = sprintf('min %s sig %s max', local_relop(min_included), local_relop(max_included));
   case 'Checks_Gradient'
    gradient = get_param(block, 'gradient');
    description = sprintf('| du / dt | < %s', gradient);
   otherwise
    description = '-Inf < u < +Inf';
  end; % switch type
  set_param(block, 'description', description);
  
  
%
% update the outport of a block
%
function local_update_outport(block)
  export=get_param(block, 'export');
  if (strcmp(export, 'on'))
    blocktype='Outport';
  else
    blocktype='Terminator';
  end;
  
  outblock=[getfullname(block), '/out'];
  if (~strcmp(get_param(outblock, 'blocktype'), blocktype))
    p=get_param(outblock, 'position');
    delete_block(outblock);
    add_block(['built-in/', blocktype], outblock, 'position', p);
  end;
  
  
%
% update the boundary of a block
%
function local_update_boundary(block, type)
  relop_min = '';
  relop_max = '';
  switch (type)
   case 'Checks_SMin'
    min_included = get_param(block, 'min_included');
    relop_min = local_relop(min_included);
   case 'Checks_SMax'
    max_included = get_param(block, 'max_included');
    relop_max = local_relop(max_included);
   case 'Checks_SGap'
    min_included = get_param(block, 'min_included');
    max_included = get_param(block, 'max_included');
    relop_min = local_relop(min_included);
    relop_max = local_relop(max_included);
   case 'Checks_SRange'
    min_included = get_param(block, 'min_included');
    max_included = get_param(block, 'max_included');
    relop_min = local_relop(min_included);
    relop_max = local_relop(max_included);
   case 'Checks_DMin'
    min_included = 'off'; % get_param(block, 'min_included');
    relop_min = local_relop(min_included);
   case 'Checks_DMax'
    max_included = 'off'; % get_param(block, 'max_included');
    relop_max = local_relop(max_included);
   case 'Checks_DGap'
    min_included = 'off'; % get_param(block, 'min_included');
    max_included = 'off'; % get_param(block, 'max_included');
    relop_min = local_relop(min_included);
    relop_max = local_relop(max_included);
   case 'Checks_DRange'
    min_included = 'off'; % get_param(block, 'min_included');
    max_included = 'off'; % get_param(block, 'max_included');
    relop_min = local_relop(min_included);
    relop_max = local_relop(max_included);
   otherwise
    error('invalid type!');
  end; % switch type

  if (~isempty(relop_min))
    set_param([getfullname(block), '/min_relop'], 'Operator', relop_min);
  end;
  if (~isempty(relop_max))
    set_param([getfullname(block), '/max_relop'], 'Operator', relop_max);
  end;

%
% update the assertion block in the pre-packed blocks
%
function local_update_assert(block, type)
  switch (type)
   case 'Checks_Gradient'
      assertblk = [getfullname(block) '/Assertion'];
   otherwise
      assertblk = [getfullname(block) '/Assertion'];
  end;
  
  % Call the vnv_assert_mgr to determine if we should overide
  % we don't need to worry about it here.  
  try,
      isOveride = vnv_assert_mgr('asBlkIsOveride',block);
  catch
      isOveride = 0;
  end
  
  enabled = get_param(block, 'enabled');
  set_param(assertblk, 'enabled', enabled);
  
  if isOveride
      set_param(assertblk, 'Overide', 'on');
  else
      set_param(assertblk, 'Overide', 'off');
  end
  
  set_param(assertblk, 'AssertionFailFcn', get_param(block, 'callback'));
  
  % We should switch this to use an unsaved double handle
  set_param(assertblk, 'ShadowObject', block);
  
  set_param(assertblk, 'StopWhenAssertionFail', get_param(block, 'stopWhenAssertionFail'));
 
  
%
% update icons
%
function local_update_icon(block)

  type = get_param(block, 'masktype');
  try,
      isOveride = vnv_assert_mgr('asBlkIsOveride',block);
  catch
      isOveride = 0;
  end

  if (strcmp(type, 'Checks_Resolution'))
    mode = 'graphic';
  else
    mode = get_param(block, 'icon');
  end;
  
  switch ( lower(mode) )
   case 'graphic'
    local_set_graphic_icon(block);
   case 'text'
    local_set_text_icon(block);
   otherwise
    error(sprintf('Wrong argument ''%s'' in ''switch_icon''!', mode));
  end
  
  userData = get_param(block, 'UserData');
  if (~userData.enabled)  && ~isOveride
      str = get_param(block,'MaskDisplay');
      str = [str, 'plot([0 1], [0 1]);', sprintf('\n'), 'plot([0 1],[1 0]);'];
      set_param(block, 'MaskDisplay', str);
  end
      
  if (~userData.enabled) && isOveride
      position = get_param(block, 'position');
      width = position(3)-position(1);
      xPos = max([0.5 - (20/width),0]);
      xPosStr = sprintf('%.2f',xPos);
      str = get_param(block,'MaskDisplay');
      str = [str, 'text(' xPosStr ',0.9,''Override'');'];
      set_param(block, 'MaskDisplay', str);
  end

%
% set the graphical icon
%
function icon=local_set_graphic_icon(block)
  
  position = get_param(block, 'position');
  size     = [position(3)-position(1), position(4)-position(2)];
  fontsize = get_param(block, 'FontSize');
  if (fontsize == -1)
    fontsize = get_param(bdroot, 'DefaultBlockFontSize');
  end;
  
  type = get_param(block, 'masktype');
  switch (type(8:end))
   case { 'SMin', 'SMax', 'SRange', 'SGap', 'Gradient', 'Resolution' }
    if (any(size<30))
      icon = local_mini_icon(type(8:end));
    else
      icon = ['image(imread(''', type, '.bmp'',''bmp''),''center'')'];
    end;
   case { 'DMin', 'DMax', 'DRange', 'DGap' }
    if (size(2) < fontsize*3 | size(1) < fontsize*3/0.4)
      icon = local_mini_icon(type(8:end));
    else  
      iNote = [local_icon_part(type)];
      icon = [iNote, ...
              'image(imread(''', type, '.bmp'',''bmp''),''center'')'];
    end;
   otherwise
    icon = '';
  end
  
  if (~isempty(icon))
    set_param(block, 'MaskDisplay', sprintf(icon));
  end;
  
%  
% set the text icon
%
function icon=local_set_text_icon(block)
  
  position = get_param(block, 'position');
  size     = [position(3)-position(1), position(4)-position(2)];
  fontsize = get_param(block, 'FontSize');
  if (fontsize == -1)
    fontsize = get_param(bdroot, 'DefaultBlockFontSize');
  end;

  type = get_param(block, 'masktype');
  switch (type(8:end))
   case { 'SMin', 'SMax', 'SRange', 'SGap', 'Gradient' }
    if (size(2) < fontsize*2 | ...
        size(1) * 0.8 < fontsize*length(get_param(block, 'description'))/2)
      icon = local_mini_icon(type(8:end));
    else
      icon = [ 'disp(get_param(gcbh, ''description''))'];
    end;
   
   case { 'DMin', 'DMax', 'DRange', 'DGap' }
    if (size(2) < fontsize*3 | ...
        size(1) < fontsize*(length(get_param(block, 'description'))+6)/1.8)
      icon = local_mini_icon(type(8:end));
    else
      switch(type(8:end))
       case 'DMin'
	icon = [ 'port_label(''input'', 1, ''min'');\n' ...
	    'port_label(''input'', 2, ''sig'');\n' ...
	    'disp(get_param(gcbh, ''description''))' ...
	       ];
	
       case 'DMax'
	icon = [ 'port_label(''input'', 1, ''max'');\n' ...
	    'port_label(''input'', 2, ''sig'');\n' ...
	    'disp(get_param(gcbh, ''description''))' ...
	       ];
	
       case 'DRange'
	icon = [ ...
	    'port_label(''input'', 1, ''max'');\n' ...
	    'port_label(''input'', 2, ''min'');\n' ...
	    'port_label(''input'', 3, ''sig'');\n' ...
	    'disp(get_param(gcbh, ''description''))' ...
	       ];
	
       case 'DGap'
	icon = [ ...
	    'port_label(''input'', 1, ''max'');\n' ...
	    'port_label(''input'', 2, ''min'');\n' ...
	    'port_label(''input'', 3, ''sig'');\n' ...
	    'disp(get_param(gcbh, ''description''))' ...
	       ];
      end;
    end;
   otherwise
    icon = '';
  end
  
  if (~isempty(icon))
    set_param(block, 'MaskDisplay', sprintf(icon));
  end;
  
%
% icon parts for graphical icon
%
function str = local_icon_part(name)
  switch (name)
   case 'Checks_DMin'
    str = ['port_label(''input'', 1,''min'');\n'...
           'port_label(''input'', 2, ''sig'');\n'];

   case 'Checks_DMax'
     str = ['port_label(''input'', 1,''max'');\n'...
           'port_label(''input'', 2, ''sig'');\n'];

   case 'Checks_DRange'
     str = ['port_label(''input'', 1,''max'');\n'...
           'port_label(''input'', 2, ''min'');\n'...
           'port_label(''input'', 3, ''sig'');\n'];

   case 'Checks_DGap'
     str = ['port_label(''input'', 1, ''max'');\n'...
           'port_label(''input'', 2, ''min'');\n'...
           'port_label(''input'', 3, ''sig'');\n'];
     
   otherwise
     str = '';
end

%
% set the mini icon
%
function icon = local_mini_icon(name)
  icon = ['disp(''!' name ''')'];

%% 
%% Block specific update functions
%%

%
% update function for gradient block
%
function local_update_gradient(block, type)
  switch (type)
   case 'Checks_Gradient'
    model=get_param(bdroot(block), 'handle');
    solver=get_param(model, 'solver');
    if (~strcmp(solver, 'FixedStepDiscrete'))
      error('Requires fixed-step discrete solver');
    end;
   otherwise
    error('invalid type!');
  end;
  
%
% update function for resolution block
%
function local_update_resolution(block, type,resolution_length)
  switch (type)
   case 'Checks_Resolution'
    
    base=getfullname(block);
    local_delete_output([base, '/u']);
    local_delete_output([base, '/resolution_type']);
    local_delete_output([base, '/dead_u']);
    local_delete_output([base, '/dead_resolution']);
    local_delete_output([base, '/fixed']);
    local_delete_output([base, '/steps']);
    
    if (resolution_length == 1)
      add_line(base, 'u/1', 'steps/1');
      add_line(base, 'resolution_type/1', 'steps/2');
      add_line(base, 'steps/1', 'Assertion/1');
      add_line(base, 'steps/1', 'out/1');
      add_line(base, 'dead_u/1', 'fixed/1');
      add_line(base, 'dead_resolution/1', 'fixed/2');
      add_line(base, 'fixed/1', 'dead_out/1');
    else
      add_line(base, 'u/1', 'fixed/1');
      add_line(base, 'resolution_type/1', 'fixed/2');
      add_line(base, 'fixed/1', 'Assertion/1');
      add_line(base, 'fixed/1', 'out/1');
      add_line(base, 'dead_u/1', 'steps/1');
      add_line(base, 'dead_resolution/1', 'steps/2');
      add_line(base, 'steps/1', 'dead_out/1');
    end;
   otherwise
    error('invalid type!');
  end;
  

  