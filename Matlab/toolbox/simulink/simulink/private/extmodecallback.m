function varargout = extmodecallback(varargin)
%EXTMODECALLBACK External mode callback function for system target files.
%
%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $

  action = lower(varargin{1});

  switch(action),

   case 'extmode_checkbox_callback',
    
    DialogFig = varargin{2};
   
    %
    % Get the value of the extmode checkbox from the Simulation
    % Parameters dialog.
    %
    obj0Tag = 'External mode_CheckboxTag';
    obj0 = findobj(DialogFig,'Tag',obj0Tag);
    val0 = get(obj0,'Value');

    %
    % Find all objects on the external mode options page.
    %
    obj1Tag = 'Transport_PopupFieldTag';
    obj2Tag = 'Static memory allocation_CheckboxTag';
    obj3Tag = 'Static memory buffer size_EditFieldTag';
    obj1 = findobj(DialogFig,'Tag',obj1Tag);
    obj2 = findobj(DialogFig,'Tag',obj2Tag);
    obj3 = findobj(DialogFig,'Tag',obj3Tag);

    %
    % Enable/Disable all controls on the external mode
    % options page
    %
    if val0 == 1;
      
      %
      % If the extmode checkbox is checked, the transport and
      % static memory allocation checkbox are enabled.
      %
      set(obj1, 'Enable', sl('onoff', val0));
      set(obj2, 'Enable', sl('onoff', val0));
      
      %
      % The static memory size edit box is only enabled when
      % the extmode checkbox and the static memory allocation
      % checkbox are both checked.
      %
      val2 = get(obj2,'Value');
      set(obj3, 'Enable', sl('onoff', val2));
    else;
      
      %
      % If the extmode checkbox is unchecked, all other controls
      % on the external mode options page are disabled.
      %
      set(obj1, 'Enable', sl('onoff', val0));
      set(obj2, 'Enable', sl('onoff', val0));
      set(obj3, 'Enable', sl('onoff', val0));
    end;

    
   case 'staticmem_checkbox_opencallback',
    
    DialogFig = varargin{2};
   
    %
    % Get the value of the extmode checkbox from the Simulation
    % Parameters dialog.
    %
    obj0Tag = 'External mode_CheckboxTag';
    obj0 = findobj(DialogFig,'Tag',obj0Tag);
    val0 = get(obj0,'Value');

    %
    % Get the handle to the extmode static memory allocation
    % checkbox from the Simulation Parameters dialog.
    %
    obj1Tag = 'Static memory allocation_CheckboxTag';
    obj1 = findobj(DialogFig,'Tag',obj1Tag);
    
    set(obj1, 'Enable', sl('onoff', val0));

   
   case 'staticmem_checkbox_callback',
    
    DialogFig = varargin{2};
   
    %
    % Get the value of the static memory allocation checkbox from
    % the Simulation Parameters dialog.
    %
    obj0Tag = 'Static memory allocation_CheckboxTag';
    obj0 = findobj(DialogFig,'Tag',obj0Tag);
    val0 = get(obj0,'Value');

    %
    % Get the handle to the Static memory buffer size edit box
    % from the Simulation Parameters dialog.
    %
    obj1Tag = 'Static memory buffer size_EditFieldTag';
    obj1 = findobj(DialogFig,'Tag',obj1Tag);
    
    set(obj1, 'Enable', sl('onoff', val0));

   
   case 'staticmemsize_edit_opencallback',
    
    DialogFig = varargin{2};
   
    %
    % Get the value of the static memory allocation checkbox from
    % the Simulation Parameters dialog.
    %
    obj0Tag = 'Static memory allocation_CheckboxTag';
    obj0 = findobj(DialogFig,'Tag',obj0Tag);
    val0 = get(obj0,'Value');

    %
    % Get the handle to the Static memory buffer size edit box
    % from the Simulation Parameters dialog.
    %
    obj1Tag = 'Static memory buffer size_EditFieldTag';
    obj1 = findobj(DialogFig,'Tag',obj1Tag);
    
    set(obj1, 'Enable', sl('onoff', val0));

   
   case 'transport_popup_opencallback',

    model     = varargin{2};
    DialogFig = varargin{3};
    ud        = varargin{4};
    table     = varargin{5};

    %
    % Get the value of the extmode checkbox from the Simulation
    % Parameters dialog.
    %
    obj0Tag = 'External mode_CheckboxTag';
    obj0 = findobj(DialogFig,'Tag',obj0Tag);
    val0 = get(obj0,'Value');

    %
    % Get the value of the extmode transport popup field from the
    % Simulation Parameters dialog.
    %
    obj1Tag = 'Transport_PopupFieldTag';
    obj1 = findobj(DialogFig,'Tag',obj1Tag);
    val1 = get(obj1,'Value');

    %
    % If the checkbox is set, the popup field should be enabled.
    % If the checkbox is unset, the popup field should be disabled.
    %
    set(obj1, 'Enable', sl('onoff', val0));

    %
    % Each row of table is a supported transport.
    %
    [rows cols] = size(table);
    numTransports = rows;

    %
    % Get the current mexfile.
    %
    mexfile = get_param(model,'ExtModeMexFile');
    
    %
    % Find which transport from the table the user selected via the
    % extmode transport popup field.
    for extidx = 1:numTransports;
      if val1 == extidx;
	%
	% Save the current transport selection as the previous selection.
	% When the user changes the selection some time later, this current
	% selection becomes the previous selection.
	%
	ud.ExtModeMex.transport = table{extidx,1};

	%
	% Make sure the current selection corresponds with the current mexfile.
	% If a discrepancy is found, set the mexfile to the correct value and
	% clear out the mexfile arguments.  The only way this discrepancy
	% should ever happen is when the transport names in the popup field are
	% changed by the user.
	%
	if ~strcmp(mexfile,table{extidx,2});
	  set_param(model,'ExtModeMexFile',table{extidx,2});
	  set_param(model,'ExtModeMexArgs','');
	end;
      end;
    end;
    
    varargout{1} = ud;

	     
   case 'transport_popup_closecallback',

    model     = varargin{2};
    DialogFig = varargin{3};
    ud        = varargin{4};
    table     = varargin{5};

    %
    % Get the value of the extmode checkbox from the Simulation
    % Parameters dialog.
    %
    obj0Tag = 'External mode_CheckboxTag';
    obj0 = findobj(DialogFig,'Tag',obj0Tag);
    val0 = get(obj0,'Value');

    %
    % Get the value of the extmode transport popup field from the
    % Simulation Parameters dialog.
    %
    obj1Tag = 'Transport_PopupFieldTag';
    obj1 = findobj(DialogFig,'Tag',obj1Tag);
    val1 = get(obj1,'Value');

    %
    % If the checkbox is set, the popup field should be enabled.
    % If the checkbox is unset, the popup field should be disabled.
    %
    set(obj1, 'Enable', sl('onoff', val0));

    %
    % Each row of table is a supported transport.
    %
    [rows cols] = size(table);
    numTransports = rows;

    %
    % Get the current mexfile arguments.
    %
    mexargs = get_param(model,'ExtModeMexArgs');

    %
    % Find which transport from the table had been selected previous to the
    % user changing the selection in the extmode transport popup field.
    %
    for extidx = 1:numTransports;
      if strcmp(ud.ExtModeMex.transport,table{extidx,1});
	%
	% Save the mexfile arguments with the previous transport.  If the user
	% chooses to go back to the previous transport, the mexfile arguments
	% will be restored.
	%
	eval(['ud.ExtModeMex.' table{extidx,1} ' = mexargs;']);
      end;
    end;
    
    mexargs = '';
    
    %
    % Find which transport from the table the user selected via the
    % extmode transport popup field.
    %
    for extidx = 1:numTransports;
      if val1 == extidx;
	%
	% Save the proper mexfile name corresponding to the chosen transport.
	%
	mexfile = table{extidx,2};
	
	%
	% Record this new transport selection as the previous selection.  When
	% the user changes the selection some time later, this current selection
	% becomes the previous selection.
	%
	ud.ExtModeMex.transport = table{extidx,1};
	
	%
	% Get the saved mexfile arguments for the corresponding transport.
	% mexargs has been initialized to an empty string in case no arguments
	% have been saved for this transport yet.
	%
	if isfield(ud.ExtModeMex,table{extidx,1});
	  mexargs = eval(['ud.ExtModeMex.' table{extidx,1} ';']);
	end;
      end;
    end;

    %
    % These set_params are the source for the External Mode Control Panel
    % Target Interface button fields.
    %
    set_param(model,'ExtModeMexFile',mexfile);
    set_param(model,'ExtModeMexArgs',mexargs);

    %
    % Send an update to the External Mode Control Panel so it will pick up the
    % new mexfile and mexargs fields when that dialog is already opened.
    %
    h = get_param(model,'ExtModeLogCtrlPanelDlg');
    if (h ~= -1);
      logctrlpanel('update',h);
    end;

    varargout{1} = ud;

    
   case 'noextcomm',

    model = varargin{2};

    set_param(model,'ExtModeMexFile','no_ext_comm');
    set_param(model,'ExtModeMexArgs','');
  
    %
    % Send an update to the External Mode Control Panel so it will pick up the
    % new mexfile and mexargs fields when that dialog is already opened.
    %
    h = get_param(model,'ExtModeLogCtrlPanelDlg');
    if (h ~= -1);
      logctrlpanel('update',h);
    end;

    varargout{1} = -1;

    
   otherwise,
    error(sprintf('Assertion: Unrecognized action in main entry point.'));

  end %action switch


% end extmodecallback
