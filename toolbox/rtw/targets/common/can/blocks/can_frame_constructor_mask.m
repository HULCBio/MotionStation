function varargout =  can_frame_constructor_mask(action, varargin)
% CAN_FRAME_CONSTRUCTOR_MASK
%
% Syntax: varargout =  can_frame_constructor_mask(action, varargin)
% 
% --- Arguments ---
%
%   action   -  'reset' | 'callback' | 'init'

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.19.4.7 $
%   $Date: 2004/04/29 03:39:57 $

   import('com.mathworks.toolbox.ecoder.canlib.CanDB.*');

   block = varargin{1};
   switch action
   case 'reset'
      % Use this operation to initialize the library block
      set_param(block,'initfcn','');
      % need the copy fcn to reset the lock and clone the java object.
      set_param(block,'copyfcn','can_frame_constructor_mask(''copyfcn'',gcbh)');
      mskinit = 'message = can_frame_constructor_mask(''init'',gcbh);';
      mskinit = strvcat(mskinit, ...
                 'can_frame_constructor_mask(''updatemaskdisplay'',gcbh);');

      set_param(block,'MaskInitialization',mskinit);
      set_param(block,'UserDataPersistent','on');
      set_param(block,'OpenFcn', ...
            'can_frame_constructor_mask(''callback'',gcbh);');
      set_param(block,'PreSaveFcn',...
            'can_frame_constructor_mask(''safeclosesavedelete'',gcbh);');
      set_param(block,'ModelCloseFcn',...
            'can_frame_constructor_mask(''safeclosesavedelete'',gcbh);');
      set_param(block,'DeleteFcn',...
            'can_frame_constructor_mask(''safeclosesavedelete'',gcbh);');
      set_param(block,'MaskSelfmodifiable','on');
      
      % only set the message object if necessary
      ud = get_param(block, 'UserData');
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
      set_param(block, 'UserData',ud);
   case 'callback'
      % do not open in the library
      if (strcmp(get_param(bdroot(block),'BlockDiagramType'),'library'))
          warning('The CAN Message Packing (CANdb) block mask will not open while inside a library.');
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
      for i=1:length(block_name)
          % carriage return
          if (block_name(i) == char(10))
              % replace with space.
              block_name(i) = char(32);
          end;
      end;
      
      % get the library block name
      library_block_name = get_param(block,'ReferenceBlock');     
      % strip the library name - NB. will break if there is ever more than 1 library layer...
      [throw_away keep] = strtok(library_block_name,'/');
      library_block_name = keep(2:length(keep));
      
      % remove carriage returns
      for i=1:length(library_block_name)
          % carriage return
          if (library_block_name(i) == char(10))
              % replace with space.
              library_block_name(i) = char(32);
          end;
      end;
      
      % pre process message in order to resolve $MATLABROOT$ token if
      % necessary
      processedMsg = can_frame_packing_utils('preprocessmessage', ud.message);
      
      f = FrameBuilderMask(parentframe,0, processedMsg , pwd, library_block_name,'Packs input data signals into a CAN message');
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

% The callback to the actions the mask can invoke
function i_action_callback(source, event, block, mask_handle)
   import('com.mathworks.toolbox.ecoder.canlib.CanDB.*');
   import('javax.swing.*');

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
         helpview([docroot '/toolbox/can_blocks/can_blocks.map'], 'CANdb_msg_construct');  
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
   can_frame_constructor_mask('updatemaskdisplay',block);

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
        lbl = signal.name;
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
        lbl = [ lbl num2str(signal.length) ];
        % only display offset if it is non 0
        if (signal.offset ~= 0) 
            lbl = [ lbl ' -' num2str(signal.offset)];
        end;
        % only display factor if it is not 1
        if (signal.factor ~= 1) 
            lbl = [lbl ' /' num2str(signal.factor)];
        end;
        pl = ['port_label(''input'',' num2str(i) ',''' lbl ''');'];
        str = strvcat(str,pl);
    end
    str = strvcat(str,'port_label(''output'',1,''Msg'')');
else 
  str = 'disp(''No signals!'')';
end;


