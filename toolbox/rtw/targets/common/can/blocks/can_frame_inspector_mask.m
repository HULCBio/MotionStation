function varargout =  can_frame_inspector_mask(action, varargin)
%CAN_FRAME_INSPECTOR_MASK
%
% Syntax: varargout = can_frame_inspector_mask(action, varargin)
% 
% --- Arguments ---
%
%   action   -  'reset' | 'callback' | 'init'

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.18.4.7 $
%   $Date: 2004/04/29 03:39:58 $

   import('com.mathworks.toolbox.ecoder.canlib.CanDB.*');

   block = varargin{1};
   switch action
   case 'librarySetup_CANMessageUnpacking'
      % Use this action to initialise the 
      % CAN Message Unpacking template subsystem (block)
      
      % Set up the CAN Message Unpacking template subsystem
      i_setupTemplateSubsystem(block);      
   case 'librarySetup_CANMessageUnpacking_CANdb'
      % Use this action to initialise the 
      % CAN Message Unpacking (CANdb) template subsystem (block)
      % NOTE: this automatically sets up the underlying actual CANdb too
      
      % Set up the CAN Message Unpacking (CANdb) template subsystem
      i_setupTemplateSubsystem(block);
      
      % Set up the actual CAN Message Unpacking (CANdb) block
      i_setupActualCANdbBlock(block);
   case 'callback'
      % do not open in the library
      if (strcmp(get_param(bdroot(block),'BlockDiagramType'),'library'))
          warning('The CAN Message Unpacking (CANdb) block mask will not open while inside a library.');
          return;
      end;

      % Use this operation to open the mask
      ud = get_param(block,'UserData');
      
      if (~isempty(ud.javahandle)) 
          ud.javahandle.toFront;
          return;
      end;
      
      % must initialise a parent frame so we can set the icon.
      parentframe = javax.swing.JFrame;
      % set the icon to be the MATLAB icon.
      parentframe.setIconImage(com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame.getIconImage);
      
      % get block name
      block_name = ['Block Parameters: ' get_param(block,'Name')];
      % remove carriage returns
      block_name = regexprep(block_name,'\n|\r',' ');
     
       
      % get the library block name
      library_block_name = get_param(block,'ReferenceBlock');     
      % Extract just the block name
      library_block_name = regexprep(library_block_name,'^.*/','');
      % remove carriage returns
      library_block_name = regexprep(library_block_name,'\n|\r',' ');
      
      % pre process message in order to resolve $MATLABROOT$ token if
      % necessary
      clonedMessage = can_frame_packing_utils('preprocessmessage', ud.message);
      
      f = FrameBuilderMask(parentframe,0,clonedMessage, pwd, library_block_name,'Unpacks a CAN message into output data signals');
      f.setTitle(block_name);
      f.pack;
      f.setSize(650,700);
      
       % -- Layout the dialog in the center of the screen ---
      screen_size = java.awt.Toolkit.getDefaultToolkit.getScreenSize;
      dialog_size = f.getSize;
      new_pos = java.awt.Dimension((screen_size.width-dialog_size.width)/2, ...
        (screen_size.height-dialog_size.height)/2);
      f.setLocation(new_pos.width, new_pos.height);
      
      f.show;
      
      % get the handle to the java object
      javahandle = handle(f,'callbackproperties');
      % setup the ActionPeformed callback
      l = handle.listener(javahandle,'ActionPerformed',{@i_action_callback block javahandle});
      % make listener persistent
      javahandle.connect(l,'down');
      % store the javahandle in the user data
      ud.javahandle = javahandle;
      set_param(block,'UserData',ud);
      
   case 'init'
      % init callback is for updating the message
      % from the database file at model update time
      % message is returned to the block so the s-function can
      % update it's ports

      try 
        % Use this operation to retrieve the matlab parameter data
        ud = get_param(block,'UserData');
        % pre process the message to resolve special tokens
        ud.message = can_frame_packing_utils('preprocessmessage', ud.message);
        % try reloading the processed message 
        ud.message.reload();
        % post process the message to restore special tokens
        ud.message = can_frame_packing_utils('postprocessmessage', ud.message);
        % save the message back to the userdata and commit the changes
        set_param(block,'UserData',ud);
      catch
         warning(['CANdb message for block, ''' ...
                  strrep([get_param(block, 'Parent') '/' get_param(block, 'Name')], sprintf('\n'),' ') ...
                  ''', could not be reloaded because: ' lasterr]);
      end
      % get the possibly updated message
      ud = get_param(block,'UserData');
      varargout{1} = i_convert_jmessage_2_matlab(ud.message);
      
   case 'updatemaskdisplay'
      ud = get_param(block,'UserData');
      message = i_convert_jmessage_2_matlab(ud.message);
      str = i_build_display_string(message);
      set_param(block,'MaskDisplay',str);
   case 'copyfcn'
      ud = get_param(block,'UserData');
      % clone the java object, otherwise the blocks would share the same reference.
      clonemessage = ud.message.clone;
      ud.message = clonemessage;
      % remove the handle to the other block
      ud.javahandle = [];
      % remove any old message data
      if (isfield(ud,'messageOLD')==1)
        ud = rmfield(ud,'messageOLD');
      end;
      set_param(block,'UserData',ud);
   case 'safeclosesavedelete'
      ud = get_param(block,'UserData');
      if (~isempty(ud.javahandle))         
          % must clear the handle as MATLAB will 
          % attempt to serialize it!
          i_dispose_mask(block,ud.javahandle);
      end;
   otherwise
      error([ 'Invalid action : ' action ] );
   end

% this function is called to setup the actual CANdb Unpacking block
% the argument is the block reference of the template subsystem
function i_setupActualCANdbBlock(subsystemBlock)   
      %
      % Get the reference to the actual block
      %
      actualBlock = find_system(subsystemBlock, 'LookUnderMasks', 'on', ...
        'FollowLinks', 'on', ...
        'SearchDepth', 1, ...
        'BlockType', 'S-Function');
      actualBlock = actualBlock(1);
      
      % init fcn
      set_param(actualBlock, 'initfcn', '');
      % open fcn
      set_param(actualBlock, 'OpenFcn', 'can_frame_inspector_mask(''callback'',gcb);');
      % copy fcn
      set_param(actualBlock, 'CopyFcn', 'can_frame_inspector_mask(''copyfcn'',gcb);');
      
      mskinit = 'message = can_frame_inspector_mask(''init'',gcbh);';
      mskinit = strvcat(mskinit, ...
                 'can_frame_inspector_mask(''updatemaskdisplay'',gcbh);');
      
      set_param(actualBlock, 'MaskInitialization',mskinit);
      set_param(actualBlock, 'UserDataPersistent','on');
      set_param(actualBlock, 'MaskSelfmodifiable','on');
      
      set_param(actualBlock,'PreSaveFcn',...
            'can_frame_inspector_mask(''safeclosesavedelete'',gcbh);');
      set_param(actualBlock,'ModelCloseFcn',...
            'can_frame_inspector_mask(''safeclosesavedelete'',gcbh);');
      set_param(actualBlock,'DeleteFcn',...
            'can_frame_inspector_mask(''safeclosesavedelete'',gcbh);');
      
      % only set the message object if necessary
      ud = get_param(actualBlock, 'UserData');
      if (isfield(ud, 'message') & isfield(ud,'javahandle'))
        if (isempty(ud.message))
            ud.message = Message;
        end; 
        ud.javahandle = [];
      else
        ud.message = com.mathworks.toolbox.ecoder.canlib.CanDB.Message;
        % the handle to the Java object
        ud.javahandle = [];
      end;
      set_param(actualBlock, 'UserData',ud);
return;
   
% This function initialises both of the CAN Message Unpacking 
% Template subsystems
% This is called by each of the setup routines for the two
% different Unpacking blocks (Standard and CANdb)
function i_setupTemplateSubsystem(subsystemBlock)
    % Set the template subsystem's OpenFcn:
    set_param(subsystemBlock,'OpenFcn', 'open_system(gcb, ''force'');');
    
    % Set the template subsystem's CopyFcn:
    % - Break subsystem's link
    % - Re-establish link to underlying block
    % - Remove CopyFcn
    cpStr = ['hNewBlk = find_system(gcbh, ''LookUnderMasks'', ''on'', ', ...
            '''FollowLinks'', ''on'', ''SearchDepth'', 1, ''BlockType'', ''S-Function'');', ...
            'refBlkName = get_param(hNewBlk, ''ReferenceBlock'');', ...
            'set_param(gcbh, ''LinkStatus'', ''none''); ', ...
            'set_param(hNewBlk, ''ReferenceBlock'', refBlkName); ', ...
            'set_param(gcbh,''CopyFcn'','''');'];
    set_param(subsystemBlock,'CopyFcn',cpStr);
return;
   
   
% The callback to the actions the mask can invoke
function i_action_callback(source, event, block, mask_handle)
   import('com.mathworks.toolbox.ecoder.canlib.CanDB.*');
   import('javax.swing.*');

   data = get(mask_handle,'ActionPerformedCallbackData');
   switch char(event.JavaEvent.getActionCommand)
      case  char(FrameBuilderMask.OK_ACTION) 
         i_apply_message(block,mask_handle);
         % now remove any saved data also...
         ud = get_param(block,'UserData');
         if (isfield(ud,'messageOLD')==1)
             ud = rmfield(ud,'messageOLD');
         end;
         set_param(block,'UserData',ud);
         i_dispose_mask(block,mask_handle);
         % set the dirty bit on the model for OK or APPLY
         % this is not quite correct, but better then before!
         set_param(bdroot,'dirty','on');
      case char(FrameBuilderMask.HELP_ACTION )
         helpview([docroot '/toolbox/can_blocks/can_blocks.map'], 'CANdb_msg_unpack');
      case char( FrameBuilderMask.APPLY_ACTION)
         i_apply_message(block,mask_handle);
         % set the dirty bit on the model for OK or APPLY
         % this is not quite correct, but better then before!
         set_param(bdroot,'dirty','on');
      case char( FrameBuilderMask.CANCEL_ACTION )
         % swap back to old message if it is exists and tidy up.
         ud = get_param(block,'UserData');
         if (isfield(ud,'messageOLD')==1)
            ud.message = ud.messageOLD;
            ud = rmfield(ud,'messageOLD');
         end;  
         set_param(block,'UserData',ud);
         i_dispose_mask(block,mask_handle);
      otherwise 
         error([' Invalid action : ' data.actionCommand ] );
   end
   % update the mask to reflect any changes that may have been made.
   can_frame_inspector_mask('updatemaskdisplay',block);

% Save the java data
function i_apply_message(block,mask_handle)
      ud = get_param(block,'UserData');
      %save the old value of message - NB. only save once!
      if (isfield(ud,'messageOLD')==0)
        ud.messageOLD = ud.message;
      end;
      %write the new value...
      ud.message = mask_handle.getMessage.clone;
      % post process the message in case we need to
      % restore $MATLABROOT$ token for example
      ud.message = can_frame_packing_utils('postprocessmessage', ud.message);
      set_param(block,'UserData',ud);

% Dispose of the GUI
function i_dispose_mask(block,mask_handle)
      mask_handle.mCloseDialog;
      ud = get_param(block,'UserData');
      ud.javahandle = [];
      set_param(block,'UserData',ud);

function str = i_build_display_string(message)
   if (isempty(message.signals)==0)
    nSigs = length(message.signals.signal);
    str = [];
    for i=1:nSigs
        signal = message.signals.signal(i);
        lbl = '';
        switch signal.dataType
        case 0
            lbl = [ lbl ' S' ];
        case 1
            lbl = [ lbl ' U'];
        case 2    
            lbl = [ lbl ' F'];
        case 3
            lbl = [ lbl ' D'];
        otherwise
            error('Unsupported signal datatype.');
        end
        lbl = [ lbl num2str(signal.length)];
        % only display factor if !=1
        if (signal.factor ~= 1) 
            lbl = [ lbl ' *' num2str(signal.factor)];
        end;
        % only display offset if != 0
        if (signal.offset ~= 0) 
            lbl = [lbl ' +' num2str(signal.offset)];
        end;
        lbl = [lbl ' ' signal.name];
        pl = ['port_label(''output'',' num2str(i) ',''' lbl ''');'];
        str = strvcat(str,pl);
    end
    str = strvcat(str,'port_label(''input'',1,''Msg'')');
  else
   str = 'disp(''No signals!'')';
  end;


