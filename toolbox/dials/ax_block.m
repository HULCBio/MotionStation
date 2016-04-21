function varargout=ax_block(Action, varargin)
%AX_BLOCK Callback file for Dials & Gauges' ActiveX Control block


%   Copyright 1998-2004 The MathWorks, Inc.
%   $Revision: 1.40.4.5 $  $Date: 2004/03/02 02:59:58 $

if nargin < 2
    TheBlock = gcbh;
else
    TheBlock = varargin{1};
end

switch Action,
    case 'ActiveXMaskInit',
        [varargout{1:5}] = localActiveXMaskInit(varargin{:});
        
    case 'FindActiveXBlock',
        % (TheBlock is actually hActX in this instance)
        [varargout{1}]=localFindActiveXBlock( TheBlock );  

    case 'DeleteBlock',
        axblkUd = get_param(TheBlock,'UserData');
        hActX = axblkUd.hActx;  
        if ~isempty(hActX)
            localSaveBlockControl( TheBlock ); 
            localDeleteBlock( TheBlock );   
        end

    case 'DeleteControl', % ParentCloseFcn
        localSaveBlockControl( TheBlock ); % Save copy for Undo
        localDeleteControl( TheBlock );    % Now delete the control

    case 'ModelClosing',
        localModelClosing( TheBlock );

    case 'SaveBlockControl',
        
     %if block is an off block nothing to save
     if strcmpi(get_param(TheBlock,'inblock'),'off')
         return
     end
     % Save control w/copy next to mdl file, too
     parSys=get_param(TheBlock,'Parent');
     sys=get_param(bdroot(TheBlock),'Name');
     if ~strcmp(parSys,sys)
        if strcmp(get_param(parSys,'BlockType'),'SubSystem')
             isOpen=strcmpi(get_param(parSys,'Open'),'on');
             if isOpen
                 localSaveBlockControl( TheBlock, 'FullSave' ); 
             end
        end
     else
         localSaveBlockControl( TheBlock, 'FullSave' ); 
     end
        
    case 'MoveBlockControl',
        %hActx = get_param( TheBlock, 'UserData' );
        axblkUd = get_param(TheBlock,'UserData');
        hActx = axblkUd.hActx;
        
        if localIsActX(hActx) & strcmp( get_param( TheBlock, 'inblock'), 'on' ),
          % only try to move confirmed in-block controls
          localMoveBlockControl(TheBlock, hActx); 
        end

    case 'CopyFcn',
        % Only if there is data to clear
        %hActX = get_param( TheBlock, 'UserData');
        axblkUd = get_param(TheBlock,'UserData');
        hActX = axblkUd.hActx;        
        
        if ~isempty( hActX )
          % Wrap this in a try-catch. During Cut-n-paste, the hActX handle
          % may be stale and invalid. If it is invalid, the save will
          % fail and we should just recreate the control using the
          % default copy.
          try
            %localSaveBlockControl( TheBlock ); % Saves old ctrl under new name
            hActx=localGetSavedBlockControl( TheBlock, hActX );
          end
          % New control will be created in the Mask Initialization code
        end
             
    case 'Dirty',
        localDirtySet (TheBlock);
        
    case 'OpenFcn',
        localOpenFcn( TheBlock );

    case 'UndeleteBlock',
        %localUndeleteBlock( TheBlock );

    case 'InBlockCallback',
        localInBlockCallback( TheBlock );
    
    case {'LoadFcn', 'CopyTemp'}
        % PC only
        if( strcmp( computer, 'PCWIN' ) )    
            bd = get_param(bdroot(TheBlock),'handle');
            mdlFileVer  = get_param(bd,'VersionLoaded');
            if (mdlFileVer < 6)
             localCopyTemp( TheBlock, 'load' );
            end

            persistent bdsWarned;

            
            if isempty(find(bd == bdsWarned)),
              
              mdlFileType = get_param(bd,'BlockDiagramType');
              if (mdlFileVer < 5) && strcmp(mdlFileType,'model'),
                warning( ...
                  ['The  ''on'' value output by Dials and Gauges Blockset '...
                   'buttons and switches has changed from -1 before '...
                   'Release 13 to 1 in Release 13.  If you use ActiveX '...
                   'controls other than those supplied by The MathWorks, '...
                   'this change also affects any property of '...
                   'Boolean data type.  For details, see the Release Notes.']);
              end
              bdsWarned(end+1) = bd;
            end

        end

    case 'PreSaveFcn'
     SetParentList(TheBlock,'');
     SetUpdateParamVal(TheBlock,0);
     %if block is an off block nothing to save
     if strcmp(get_param(TheBlock,'inblock'),'off')
         return
     end
     parSys=get_param(TheBlock,'Parent');
     sys=get_param(bdroot(TheBlock),'Name');
     if ~strcmp(parSys,sys)
        if strcmp(get_param(parSys,'BlockType'),'SubSystem')
             isOpen=strcmpi(get_param(parSys,'Open'),'on');
             if isOpen
                 localPreSaveblk(TheBlock);
             end
        end
     else
         localPreSaveblk(TheBlock);
     end
     
    case 'ClearBlockData'
        ax_block('CopyFcn'); % convert to new call ( don't include above as a cell array case
                             % because it slows down access to subsequent cases

    case 'dial_set'
      %
      % Force any parents (typically of offblock controls) to update.
      %
      % offblock dials will silently fail.
      % There is currently no reliable link from the offblock control back to
      % the parent block and as such the change of value on the offblock control
      % cannot be reflected on the parent block for the general case.
      %
      
    case 'NameBlockChange'
      % G174244 Need to reset the Blockpath property stored in hActx to
      % reflect the new renamed block. Called by the Namechangefcn callback
            
        axblkUd = get_param(TheBlock,'UserData');
        hActx = axblkUd.hActx;        
        origblkPath=get(hActx,'BlockPath');
        hActx.BlockPath=TheBlock;
        
    case 'checkmskp'
        if strcmp(get_param(TheBlock,'inblock'),'off') ...
                & strcmp(get_param(TheBlock,'connect'),'output')
            warndlg('Off-block Control currently does not support output connection to dials')
        end

        
    otherwise,
        error('Invalid Action for AX_BLOCK.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% DELETE_EXTENSION %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ext = DELETE_EXTENSION
ext = '.deleted';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% TEMP_EXTENSION %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ext = TEMP_EXTENSION
ext = '.temp';

function out = localIsActX(hActx),
    out = ~isempty(findstr(class(hActx), 'COM.'));

function out = localHasPropertyPage(hActx),
    out = ismethod(hActx,'ShowPropertyPage');

%
%   Only inblock controls, created by this file, have the 'BlockPath'
%   property added to the object.  It gets added when going through
%   this ax_block funnel to create the control.  If the 'BlockPath'
%   property does not exist, then we assume that it is an off block control
%   (created without going through this ax_block funnel code).
%   somewhere else).
% 
function inBlockCtrl = IsInBlockControl(hActx),
    inBlockCtrl = isprop(hActx,'BlockPath');

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% localActiveXMaskInit %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hActx,inputprops,outputprops,inblock,dialOut]=localActiveXMaskInit(sys,blk)
% Note that this function is called from the Mask Initialization of the block.
% Mask Initiaization is called for each block with the library unlocked (if
% that block lives in a library). This means that we can call set_param
% here without worrying that the library will be locked.

% Provide default information for non-PC platforms
if( strcmp( computer, 'PCWIN' ) )    
	
	% PC defaults
	hActx       = [];
	inputprops  = [];
	outputprops = [];
	inblock     = get_param(blk, 'inblock');
	dialOut     = 1;

    % Check for things that look like a control withon a subsystem from a user library
    if strcmp( get_param( blk, 'LinkStatus' ), 'implicit' );
        return; % all we would do is (re)create a control without a handle
                % because we cannot store it in userdata
    end
            
	% Perform regular analysis on PC platforms
	if strcmp( inblock, 'on' )
        % Control is in the block. Get it.
        %if get_param(sys,'Version') >= 6
        if ~isempty(get_param(blk,'UserData'))
            hActx = localInitializeInBlockControl(sys, blk);
        else
            %Here we call the old in Block Init routine for backward
            %compatability
            hActx = localInitializeInBlockControlBack(sys,blk);
        end
        
	else
       % Control may be somewhere else
        initcmd  = get_param(blk, 'init_fcn');
		if( ~isempty(initcmd) )
            if ~isempty(get_param(blk,'UserData'))
                hActx = localInitializeOffBlockControl( blk, initcmd );
            else
                axblkUd.hActx=hActx;
                axblkUd.axDataFile=[];
                set_param(blk,'UserDataPersistent','On');
                set_param(blk,'Userdata',axblkUd);                
            end
        end
	end
	
	% Process input and output strings and set the output param if we
	% have an activex control by now.
    if localIsActX(hActx),
		inputprops   = localString2Props(get_param(blk, 'input'));  % user requested input prop(s)
		outputprops  = localString2Props(get_param(blk, 'output')); % user requested output prop(s)
		dialOut      = zeros( length( outputprops ), 1 );           % Initialize value matrix.
		Connectivity = get_param( blk, 'connect' );                 % specified connection type:
                                                                    % both, input, output, neither
		% Preprocess and error check only values needed by the
        % specified connection
		if Connectivity(1) ~= 'n',                                  % not 'neither' => i/o
          PVPairs       = get (hActx);                              % get property:value struct
          PropertyNames = fieldnames (PVPairs);                     % extract property names
          PVPairs       = {};                                       % reset for use later
          % INPUTS
          if( Connectivity(1) ~= 'o' ),                             % not 'output' => input used
			dialErr = zeros (size (inputprops));                    % Init error flags to false.
			for i = 1 : length (inputprops),                        % Iterate through input props
              if inputprops{i}(1) ~= '%'                            % Skip already commented props
                if ~any (strcmpi (inputprops{i}, PropertyNames))    % Be sure the property exists
                  dialErr(i) = 1;                                   % Err=No matching ActX property
                end % if
              end % if
            end % for
            % INPUT Error handling
            if any (dialErr)                                        % Now look for any errors
              localDeliverMessage( blk, 'BadInput', PropertyNames, ...
                            inputprops( find(dialErr) ) );          % Make useful error message
			  for i = find (dialErr),                              % Iterate thru errors
                  inputprops{i} = ['%' inputprops{i}];              % comment out property now
              end    
              p2 = sprintf( '%s, ', inputprops{:} );                % create a string from the cell
              PVPairs = { PVPairs{:}, 'input', p2(1:end-2) };       % log; to be set later
            end
          end % INPUTS
          
          % OUTPUTS
          if Connectivity(1) ~= 'i',                                % not 'input' => output used
			dialErr = ones (size (dialOut));                        % Init error flags to true.
			for i = 1 : length (outputprops),                       % Iterate through output props
              if outputprops{i}(1) == '%'                           % Check for commented props
                  dialErr(i) = 0;                                   % Commented props are not errors
              else
                if any (strcmpi (outputprops{i}, PropertyNames))     % Be sure the property exists
                  try
                    dialOut(i) = get (hActx, outputprops{i});       % Fill dialOut from ActX ctrl
                    dialErr(i) = 0;                                 % Only now mark valid
                  end % try
                end % if
              end % if/else
            end % for
            % OUTPUT Error handling
            if any (dialErr)                                        % Now look for any errors
                localDeliverMessage (blk, 'BadOutput', PropertyNames, ...
                            outputprops( find(dialErr) ) );         % Make useful error message
			    for i = find (dialErr),                             % Iterate thru errors
                    outputprops{i} = ['%' outputprops{i}];          % comment out property now
                end
                p2 = sprintf ('%s, ', outputprops{:});              % create a string from the cell
                PVPairs = { PVPairs{:}, 'output', p2(1:end-2) };    % log; to be set later
            end % if any (dialErr)
          end % if Connectivity(1) ~= 'i'   (OUTPUTS)

          % Set all changed params at once
          if ~isempty( PVPairs )
              set_param( blk, PVPairs{:} );
          end
        end % if Connectivity(1) ~= 'n',
	end % if isa( hActx, 'activex' )
else
    % Create a resonable dummy solution for non-PC platforms
    [hActx,inputprops,outputprops,inblock,dialOut]=localActiveXNonPCInit(sys,blk);    
end

%
% Error out if update string is not valid matlab name.
%
updateStr = get_param(blk,'update');
if ~isempty(updateStr) & ~exist(updateStr,'file'),
  error( ...
    ['Update string must be the name of a function taking two '...
     'arguments (e.g., foo(hActXCtrl, u))']);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% localActiveXNonPCInit %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hActx,inputprops,outputprops,inblock,dialOut]=localActiveXNonPCInit(sys,blk)
%LOCALACTIVEXNONPCINIT Provides default parameters for non-PC systems
%   The parameters returned should enable the ActiveX block to work
%   on non-PC systems.

hActx       = [];
inputprops  = []; % default
outputprops = []; % default
dialOut     = 1;  % default (if no eval'able output properties)
inblock     = 'on';
connect     = get_param( blk, 'connect');

% Try to find a reasonable input value if this is a throughput block
% (not needed for input blocks because input will be ignored)
if( strcmp( connect, 'both' ) )
    % See if the input params are a meaningful expression/value
    instr = get_param( blk, 'input' );
    if( ~isempty( instr ) )
        % Convert to value from base workspace
        evalin( 'base', ...
		['inputprops = [' instr '];'], ...
		['inputprops = ones(length(findstr(''' instr ''','',''))+1,1);']);
    end
end

% Get the output values from the control if needed.
if any( strcmp( connect, {'both','output'} ) )
    % See if the output params are a meaningful expression/value
    instr = get_param( blk, 'output' );
    if( ~isempty( instr ) )
        % Eval this to get the result into dialOut.
        dialOut = eval(['[' instr '];'], ...
		       ['ones(length(findstr(instr,'',''))+1,1)']);
	dialOut(:);  % Make column if not already.
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% localAddNewEvents %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = localAddNewEvents( blk, newEvts, newAct, oldEvts, allEvts )
% % newEvts = cell array of event names
% % newAct = string to eval upon event action
% % oldEvts = cell array of already assigned events (may be empty cell)
% % allEvts = cell array of events that can be assigned (empty cell => any event)
% % newEvts will only be added in not in the oldEvts list.
% % newEvts will be added only once. the first one in the list gets added.
% % events = concatinated event list
% % modEvts = (optional) newEvts list with errors commented out

% Initialize outputs
varargout{1} = oldEvts;
if nargout == 2,         varargout{2} = {};  end;
if isempty (newEvts),   return;             end;

% Initialize internal data
NumEvents  = length (newEvts);        events     = oldEvts; 
changed    = zeros  (1, NumEvents);   lowNewEvts = lower (newEvts);     % save processing later
allEvts    = lower  (allEvts);        NoCheck    = isempty (allEvts);

% make sure we have plural Actions
if isstr (newAct),
    [newActs{1:NumEvents}] = deal (newAct);
else
    newActs = newAct;
end

% Look for opportunities to change:
%   new event must be in list of all events
%   but cannot already be in existing list of already assigned events
for (idx = 1 : NumEvents)
    % Use strcmp because it is built in and simpler syntax--though close in speed to strmatch
    NewEvent = lowNewEvts{idx};
    if (NewEvent(1) == '%')                                  %% Ignore commeted events 
        changed(idx) = 2112;                                 %% Flag commented events 2112         
    else
      if (NoCheck | any (strcmp (NewEvent, allEvts)))        %% Validity Check
        if ~any (strcmp (NewEvent, lower(events)))           %% Uniqueness test
           %events = cat( 1, events, {newEvts{idx}, newActs{idx}} ); %% Use real event, not lowercase
            events = cat( 1, events, {NewEvent, newActs{idx}} ); %% why not?
            changed(idx) = 1;                                %% Flag valid events +1
        end
      else
        changed(idx) = -1;                                   %% Flag invalid events -1
      end
    end
end
% Provide feedback, listing each and every bad event
if ~all( changed > 0 )
    % Process bad events
    BadEventIndices = find( changed == -1 );
	if ~isempty( BadEventIndices ),
        % Provide immediate feedback
        BadEvents = sprintf( '\n     "%s"', newEvts{ BadEventIndices } );
        localDeliverMessage( blk, 'MissingEvents', allEvts, BadEvents );
        % Mark the property
        for (i = BadEventIndices)
            newEvts{i} = ['%' newEvts{i}];
        end
	end
    % Process repeat (non unique) events
%     BadEventIndices = find( changed == -1 );
% 	if ~isempty( BadEventIndices ),
        % Provide NO immediate feedback
        % (our mouse-click events could be here)
        % Just mark the property
        for (i = find( changed == 0 ))
            newEvts{i} = ['%REPEAT%' newEvts{i}];
        end
% 	end
end
% Provide additional output if requested
varargout{1} = events;
if (nargout == 2) & (~all (changed > 0))
    varargout{2} = newEvts;
end

%%%%%%%%%%%%%%%%%%%%%%%%%
%     localCopyTemp     %
%%%%%%%%%%%%%%%%%%%%%%%%%
function localCopyTemp( blk, varargin)

% Get root name of ActiveX file
FileName      = localGetAxFileNameBack( blk );

% Define fully qualified file name in the temp directory
TempFileName  = fullfile( tempdir, [ FileName, TEMP_EXTENSION ] );

% Define fully qualified file name in the model's directory
% (gcs returns the system to which the block is being copied)
FullFileName  = fullfile( fileparts( get_param( bdroot(blk), 'FileName' ) ), FileName );

% Update tempfile or model file based on input param
if nargin == 1
    % Copy temp file to data file
    if( exist( TempFileName, 'file' ) == 2 )
        copyfile( TempFileName, FullFileName );
    end
elseif strcmp(varargin{1}, 'load')
    % if file not where expected, look everywhere
    if( ~exist( FullFileName ) )
        % See if the block was deleted, but not saved that way
        if( exist( [ FullFileName DELETE_EXTENSION ] ) )
            % Restore to undeleted name
            copyfile( [ FullFileName DELETE_EXTENSION ], FullFileName );
            delete( [ FullFileName DELETE_EXTENSION ] );
        else
            % Look everywhere
            FullFileName = which( FileName );
        end
    end
    % if we have a file, copy it to the temp file
    if ~isempty( FullFileName ) 
        copyfile( FullFileName, TempFileName );
    end
        
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% localDeleteBlock %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localDeleteBlock( blk )
% Takes care of deleting the block
% This is called in two cases:
% 1) User deletes the block
% 2) User closes the model, and Simulink deletes the block.
% The state is recorded by the location of the .ax file.
% If there is a .ax.temp file, the user is deleting the block
% (but may undelete it later--so we cannot trash all info).
% Otherwise, the ModelClosing function has deleted the .ax.temp 
% file so we should do nothing here.
% Also, the model may have been saved with the block in it,
% (in which case there should be an .ax file next to the model,
% as well as a temp file with the latest changes)
% or it may not (in which case there is only a temp file)

% First, save the current state of the control (for Undo)
localSaveBlockControl( blk );
% Delete the control
localDeleteControl( blk );


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     localDirtyCheck     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ChangedParams = localDirtyCheck( blk )
% Checks block for changes to key parameters
% by comparing the values in maskwsvariables and maskvalues
% The change flags are in an array ordered as followed
%   1. ProgramID *
%   2. Initialization command **
%   3. Event on which to output
%   4. Other events and handlers
%   5. ActX Handle function (Off-block control only)

% First check current dirty flag
% aquire old (processed) and new (being edited) values 
originals = get_param (blk, 'maskwsvariables');
current   = get_param (blk, 'maskvalues');

% only look at params that may cause us to want a rebuild:
%   1 = ProgramID *
%   5 = Event on which to output
%   6 = Initialization command **
%   7 = Other events and handlers
%   8 = ActX Handle function (Off-block control only)
KeyParams = [1 6 5 7 8]; % note order! Two unique changes are listed first

% See which ones have different values than they did before
ChangedParams = ~strcmpi( current(KeyParams), {originals(KeyParams).Value}' )';

%%%%%%%%%%%%%%%%%%%%%%%%%
%     localDirtySet     %
%%%%%%%%%%%%%%%%%%%%%%%%%
function localDirtySet( blk )
% Sets the appropriate dirty flags based on chaged parameters
% The dirty flag is stored in the block's TAG 
% as a string representation of a bitfield
%
% See also: localDirtyCheck

% check for changed params and the current state
ChangedParams = localDirtyCheck (blk);

% Check for changes
if any (ChangedParams)
	% Change of the ProgramID requires full rebuild! 
	% (Will break serialization otherwise...)
	local_setFullRebuild (blk, ChangedParams(1));
	% Changes to the initialization command
	local_setReinitializeBuild (blk, ChangedParams(2)); 
	% Changes to any other of the commands
	local_setPartialRebuild (blk, any (ChangedParams(3:end)));
elseif ~local_isRebuildComplete( blk )
    % changes are gone. unset dirty flag
    % (also useful for initializing blocks from old models)
    local_setRebuildComplete (blk);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% localDeleteControl %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localDeleteControl( blk )
% Deletes the control and removes the handle from the userdata
% Takes special care with locked libraries
%
axblkUd = get_param(blk,'UserData');
hActx = axblkUd.hActx;
if( ~isempty(axblkUd.hActx) )
    try
        if localIsActX(hActx),
            delete(axblkUd.hActx);
            axblkUd.hActx=[];
        end

        % Empty the user data
        % We must be careful here about locked libraries. If the control lives
        % in a locked library, then we turn off the lock before clearing the
        % UserData. The UserData must be cleared here as a signal to other
        % callbacks during model closing. This prevents the other callbacks from
        % attempting to delete the ActiveX control a second time.
        if strcmp(get_param(bdroot(blk), 'Lock'), 'on')
            set_param(bdroot(blk), 'lock', 'off');
            set_param(blk, 'UserData', axblkUd);
            set_param(bdroot(blk), 'lock', 'on');
        else
            axblkUd.hActx=[];
            %axblkUd.pvPair=[];
            set_param(blk, 'UserData', axblkUd);
            % save
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% localDeliverMessage %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localDeliverMessage( blk, msg_id, ValidEvents, CustomText )
% Tells the user that they messed up their events
% Provides list of good events if cell array of same is passed in

% Returns the name of the block and its parent with CR/LF removed
BlockName = get_param(blk,'name');
BlockPath = get_param(blk,'parent');
BlockName( BlockName == sprintf('\n') ) = ' ';
BlockPath( BlockPath == sprintf('\n') ) = ' ';

% Always the same beginning
msg = sprintf( '\n  In block "%s/%s"', BlockPath, BlockName );
%default title segment
title = 'Warning! Bad Event on block: ';
switch (msg_id)
case 'BadFormatEvents'
    % Bad "Other events and handlers" format
    title = 'Warning! Bad Custom Event on block: ';
    msg =  sprintf( '%s\n  %s\n  %s\n     %s\n  %s\n     %s\n  %s\n  %s\n', msg, ...
               'The list of "Other events and handlers" was poorly formatted.',...
               'Expecting nx2 cell array of strings, e.g.', ...
               '{''event1'' ''handle1''; ''event2'' ''handle2''}',...
               'found', CustomText,...
               'User specified "Other events and handlers" have been ignored.' );
           
case 'BrokenEvents'
    % Case broken event callbacks
	msg =  sprintf( '%s\n  %s\n  %s\n\n', msg, ...
           'Unable to process event callback data from the dialog.',...
           'Some or all events and handlers may have been ignored.' );
       
case 'MissingEvents'
    % Missing events
	msg = sprintf( '%s\n  %s %s %s\n  %s\n\n', msg,...
                'The following event(s)',...
                'do not occur on the ActiveX Control:', ...
                CustomText, 'and will be ignored.' );
case 'BadOutput'
    % Bad output property
    BadProperties = sprintf( '\n     "%s"', CustomText{:} ); % Make nice list
    title = 'Warning! Bad Output property on block: ';
	msg = sprintf( '%s\n  the parameter values: %s\n  %s\n  %s\n  %s\n  %s\n\n', ...
                    msg, BadProperties, ...
                    'entered into the "Output property" field ',...
                    'cannot be read from the ActiveX Control and have', ...
                    'been commented out. (Commented properties output',...
                    'a value of zero during simulation).' );
case 'BadInput'
    % Bad output property
    BadProperties = sprintf( '\n     "%s"', CustomText{:} ); % Make nice list
    title = 'Warning! Bad Input property on block: ';
	msg = sprintf( '%s\n  the parameter values: %s\n  %s\n  %s\n  %s\n  %s\n\n', ...
                    msg, BadProperties, ...
                    'entered into the "Input property" field ',...
                    'do not exist on the ActiveX Control and have', ...
                    'been commented out. (Commented properties output',...
                    'will be ignored during simulation).' );
end
        
% Append list of good events to the message if possible
if ~isempty(ValidEvents)
    % Reformat cell array of events/properties to be strings of equal length
    strEvts = strvcat(ValidEvents); % pad with spaces
    for i=1:size(ValidEvents,1), ValidEvents{i} = strEvts(i,:); end % Back to cell (*not* deblanked)
    % Compile a three-column list for the command window
    CmdMsg = sprintf( '%s  Note: values that *are* valid for this block''s control include:%s\n%s\n', ...
                   msg(1:end-1), sprintf( '\n     %s   %s   %s   %s', ValidEvents{:} ), ...
                   '------------------------------------------------------------------------------' );
    %% Show event list on dialog if it is a possible it will fit on 600x800 screen
    msg = sprintf( '%s  See the MATLAB Command Window for a list of valid values.\n\n', msg(1:end) );
else
    % just use the message as it stands if there is nothing more to say
    CmdMsg = msg;
end

% Print To command line
disp( ['- Warning: -------------------------------------------------------------------' CmdMsg] );
% Print To dialog (*Must* replace old dialogs, or you will have 10 of them before you know it!)
warndlg( msg, [title BlockName], 'replace' );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% localFindActiveXBlock %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function blk = localFindActiveXBlock( hActx )
% Returns the handle to the block that contains the given ActiveX control

% Assume data is in the userdata

blk = []; %assume
if isprop(hActx,'BlockPath'),
  blkPath = get(hActx,'BlockPath');
  try,
    blk = get_param(blkPath,'Handle');
  catch,
    blk = [];
  end    
end

if isempty(blk),
	% Now search every block in every system to find the one with
	% the ActiveX control that called this function
	blks = find_system('masktype','ActiveX Block');
	sz = size(blks,1);
	found = 0;
	
	for i = 1:sz
      %hBlkActx = get_param(char(blks(i)), 'UserData');
      blkudata=get_param(char(blks(i)), 'UserData');
      hBlkActx=blkudata.hActx;
      if localIsActX(hActx),
        if hActx.Handle == hBlkActx.Handle
          found = 1;
          break;
        end
      end
	end
	
	if found == 1
      blk = get_param( blks(i), 'handle' );
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% localGetAxFileName %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function FileName = localGetAxFileName( blk )
%LOCALGETAXFILENAME Creates the filename expected 
%   for an AxtiveX control living on the
%   block given by the fully qualified
%   block name BLOCKNAME (i.e. name given by gcb)

% version 1 used gcb instead of gcbh, so when we
% concatinate the name we need to escape the '/' chars
% like gcb would have done for us
FileName = strrep( get_param(blk,'name'), '/', '//' );
FileName = [get_param(blk,'parent') '@' FileName ];

% Replace filesystem-unfriendly characters
FileName = strrep(FileName,'\','_');
FileName = strrep(FileName,'/','@');
FileName = strrep(FileName,':','.');
FileName = strrep(FileName,'?','(huh)');
FileName = strrep(FileName,'*','#');
FileName = strrep(FileName,'>','}');
FileName = strrep(FileName,'<','{');
FileName = strrep(FileName,' ','_');
FileName = strrep(FileName,sprintf('\n'),'_');
FileName = [FileName  '.ax'];
FileName = [tempdir,FileName];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% localGetAxPosition %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pos = localGetAxPosition(blk, sys)
% BLK = ActiveX block for which the position is desired
% SYS = The parent (sub)system of BLK (by handle or by name)
% POS = [ x,y,w,h] for the ActiveX control (measured in pixels 
%        from the bottom left corner of the viewing area of SYS)
%        so that it sits correctly onb top of BLK

% Position constants used by everyone but the ActiveX control itself:
% 1 = X top left corner
% 2 = Y top left corner
% 3 = X btm right corner
% 4 = Y btm right corner

% ScreenCsys is the same scale as the DrawingCsys (units = pixel coordinates) but different origin
% ViewCsys is the clipped drawing area
% ModelCsys is fixed for the model, but changes scaling with respect to pixels 
%  (ScreenCsys or DrawingCsys) when the model zooms

syspos = get_param(sys, 'Location');           % [ x0 y0 x1 y1 ] where 0 = top left, 1 = btm right of drawing area in ScreenCsys
ht     = syspos(4) - syspos(2);                % height of drawing area in Simulink window (no title bars, etc.) in pixels
pos    = get_param(blk,'Position');            % [ x0 y0 x1 y1 ] where 0 = top left, 1 = btm right of block in ModelCsys
zf     = get_param(sys,'ZoomFactor');          % 100 = 1:1 zoom (DrawingCsys:ModelCsys   scaling factor)
if ~strcmp( zf, '100' )
    % OK. Now we have to do extra work
    pos = round( pos * eval(zf) / 100 );
    % NOTE: eval is faster than str2num for this simple integer number
end
% Now we have [ x0 y0 x1 y1 ] Position of block in DrawingCsys

offset = get_param(sys, 'ScrollbarOffset'); % [X Y] of top left of viewable drawing area(ViewCsys), in DrawingCsys (i.e. clipping)

if strcmp( get_param( blk, 'border' ), 'on'),
  bw = 10; % Not scaled with zoom!!!
else
  bw = 0;
end

pos(3) = pos(3) - pos(1) + 1 - 2 * bw; % width of block in ViewCsys
pos(4) = pos(4) - pos(2) + 1 - 2 * bw; % height of block in ViewCsys

pos(2) = ht - pos(2) - pos(4) - bw + offset(2); % Y coord of bottom edge of ActiveX control from bottom edge of drawing area
% => pos(2) = ht - ( pos(2) + bw - offset(2) + pos(4) ); 

pos(1) = pos(1) + bw - offset(1);      % X coord of left side of ActiveX control in DrawingCsys

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% localGetDialOutEvents %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function events = localGetDialOutEvents( blk )
% If dialOutEvent param is empty, get a default from a table for GMS blocks
% This is a backward compatibility mode for loading R11.1 models into
% R12.  Only forces it if connection is 'both' or 'output'
events = get_param (blk,'dialOutEvent');
Locked = strcmp (get_param (bdroot (blk), 'Lock'), 'on');

if isempty(events)
    connect = get_param (blk, 'connect'); 
    if connect(1) == 'o' | connect(1) == 'b',  % 'both' or 'output'
        [isGMS,events] = localGetGMSInfo (get_param (blk, 'progid'));
        if isGMS & ~Locked, 
            set_param (blk, 'dialOutEvent', events);  % Set it for future
        end                                           %   model loading.
    end
end
events = localString2Props (events);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% localInBlockCallback %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localInBlockCallback( blk )

on_off = get_param(blk, 'inblock');

if strcmp(on_off, 'on')
  % Check to see if there is a ProgID set in the dialog. If so, then
  % recreate a new control based on that ID.
  if ~isempty(get_param(blk,'progid'))
   % localUndeleteBlock(blk);
  end

  % Set the mask visibilities for the new mode (in block)
  s = {'on'
       'on'
       'on'
       'on'
       'on'
       'on'
       'on'
       'off'
       'on'
       'on'
       'on'
       'off'
       'off'
       'off'};

elseif strcmp(on_off, 'off')
  % Check to see if there is a handle in the
  % userdata. This means that there is a control on the block icon. If so,
  % then delete this and the control that goes with it.
  
  %hActx = get_param(blk,'userdata');
  
  axblkUd = get_param(blk,'UserData');
  hActx = axblkUd.hActx;
  
  if localIsActX(hActx) & IsInBlockControl(hActx),
    localDeleteBlock(blk);
  end
  
  % Set the mask visibilities for the new mode (off block)
  s = {'off'
       'on'
       'on'
       'on'
       'off'
       'off'
       'off'
       'on'
       'off'
       'on'
       'off'
       'off'
       'off'
       'off'};

end

% Do the actual setting of the new MaskVisibilities
set_param(blk, 'MaskVisibilities', s);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    localInitializeInBlockControl     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hActx = localInitializeInBlockControl(sys, blk)
% Returns the handle of the activeX block (HACTX) if it exists or can be
% created.

% Check for existing control before creating new one
[copyfile,blkpath,axblkUd] = isBlklocalCopy(blk,get_param(blk,'UserData'));
hActx=axblkUd.hActx;

% spend a little time finding if we are dealing with dialog updates
% rather than runtime updates (which we want to be FAST)
if ~local_isRebuildComplete( blk )
    % Some dirty flag has been set
    % We don't want to react until the user hits OK or Apply, though
    % So see if params have been changed
    % (The dirty flag says they should be, so if they are not,
    %  the changes have been applied and we must update the ActiveX control)
	if ~any( localDirtyCheck( blk ) ), 
		% Look for full or partial rebuilds first, as they
		% require a new control be built before initialization can run
		if local_isPartialRebuild( blk )
             localSaveBlockControl( blk ); % Back up current state
             localDeleteControl( blk );    % Clear just the control   
             hActx = []; % forces creation of new control
		elseif local_isFullRebuild (blk)
           %  localDeleteBlock (blk);  % Full destroy--renames temp files
           %  hActx = []; % forces creation of new control
		end
		% If we still have an active x contol handle 
		% it probably just needed to be reinitialized
		% (that is why it appearted dirty)

          if localIsActX(hActx) & local_isReinitializeBuild (blk),     
              localRunInitialization (blk, hActx);    
          end
	end
end
% If we have a control, check to make sure it has not been zoomed, then we are done.
if localIsActX(hActx),
    localMoveBlockControl( blk, hActx );
    return;
end

% Also do nothing if missing the minimum data needed to make a control
progid = get_param(blk, 'progid');
if( isempty( progid ) ),        return;     end

%----------------------------------------------------------
% Make a new control...
%----------------------------------------------------------
%----------------------------------------------------------
% Get desired position and parent for the control
%----------------------------------------------------------
pos  = localGetAxPosition( blk, sys );
hSys = get_param(sys, 'Handle');
%----------------------------------------------------------
% Assemble list of events to add to the control
% Attempt to create with all events
%   If that fails, create without events, and mark for inspection
%     If that fails, bail
% If needs inspection, attempt to add events selectively
%   1. User events
%   2. Dial events
%   3. click/double-click events
%----------------------------------------------------------
MakeNew     = 0;  % Be positive. Assume it will work.
msg         = ''; % Logs error messages 
events      = {}; % Master list of events and handlers for the control
NewPVPairs  = {}; % Stores any modifications to the block parameters
[isGMS,skip,clickFlag] = localGetGMSInfo (progid);
%----------------------------------------------------------
% Start by compiling all events
%----------------------------------------------------------
% Arbitrary Events + Actions specified by the user in the block params
UserEventString = get_param (blk, 'eventstr');
if ~isempty (UserEventString)
    eval( ['UserEvents=' UserEventString ';'], 'UserEvents={};MakeNew=1;'); % Should create cell array of event name strings
else
    UserEvents = {};
end
% Check for: failed eval (|) non-cell array (|) misshaped cell array
if( MakeNew == 1 | ~iscell( UserEvents ) | ( ~isempty(UserEvents) & size(UserEvents,2) ~= 2 ) )
     % Failure mode. Let em know (in cmd line and in window)
     % (but only if we've never failed here before, as given by the leading "%" char
     if( UserEventString(1) ~= '%' )
         localDeliverMessage( blk, 'BadFormatEvents', [], UserEventString );
         % Comment out parameter so user can see it, and we won't next time
         NewPVPairs = {NewPVPairs{:}, 'eventstr', ['%' UserEventString]};
     end
     UserEvents = {}; % Don't mess with these again in this function!
end    % % % This one goes away and is replaced by the one below:

    % We made the first hurdle; lets see if we can work with the data now 
    % Start compiled list
    events = UserEvents;

    % Collect events specified by the user to initiate DialOutput changes
    DialEvents = localGetDialOutEvents (blk);
    try
        events = localAddNewEvents( blk, DialEvents, 'dng_dial_set', events, {} );
    catch
        localDeliverMessage( blk, 'BrokenEvents', [], [] );
    end
 
% % % % Append click and double-click events
% % % % for any third party control, or for a gms control we know has these events
% % % -- Waiting for geck 86705, where we can try/catch creating a bad control without
% % % -- resulting in an orphaned control sitting over out block
% % %     if ~isGMS | ( (isGMS) & (clickFlag == 1) )
% % %         events = localAddNewEvents( blk, {'MouseUp'}, 'ax_block_click', events, {} );
% % %         events = localAddNewEvents( blk, {'DblClick'}, 'ax_block_dclk', events, {} );
% % %     end
% % % %----------------------------------------------------------
% % % % Now, attempt to create the control!
% % % %----------------------------------------------------------
% % % -- Waiting for geck 86705, where we can try/catch creating a bad control without
% % % -- resulting in an orphaned control sitting over out block
% % % try
% % %     hActx = actxcontrol( progid, pos, hSys, events );
% % %     
% % % catch
% % % someone goofed.
    MakeNew = 3;
    % see if we can do it without events
    try
        hActx = actxcontrol( progid, pos, hSys, '', '' );
    catch        
        hActx = []; % control creation failed
        return;     % BAIL!!!! 
    end
% % % -- Waiting for geck 86705, where we can try/catch creating a bad control without
% % % -- resulting in an orphaned control sitting over out block
% % %    end % try
% % % end % if

%---------------------------------------------------------
% Set up our own event handling for the control as needed
%---------------------------------------------------------
if (MakeNew > 0) % % % Note: This will always be true until geck 86705 is fixed
    % Start empty
    events     = {}; % starter list
    MakeNew    = 0;  % creation flag
    AllEvents = fieldnames (send (hActx));  % List of all event names
    
    % Check user events
    if ~isempty (UserEvents),
        MakeNew = 1;
        [events, Mods] = localAddNewEvents( blk, UserEvents(:,1), UserEvents(:,2), events, AllEvents );
        if ~isempty (Mods)
            % Prepare to modify entry with comments
            Mods = cat( 1, {Mods{:}}, UserEvents(:,2)' );      % assemble & orient column-wise
            NewValue   = sprintf( '''%s'', ''%s''; ', Mods{:} ); % print out pairs
            NewValue   = ['{' NewValue(1:end-2) '}'];
            NewPVPairs = { NewPVPairs{:}, 'eventstr', NewValue };
        end
    end

    % Check dial events
    if ~isempty( DialEvents );
        MakeNew = 1;
        [events, Mods] = localAddNewEvents( blk, DialEvents, 'dng_dial_set', events, AllEvents );
        if ~isempty (Mods)
           % Prepare to modify entry with comments
           UserEvents = UserEvents'; % orient columns correctly
           NewValue   = sprintf( '%s, ', Mods{:} ); % print out pairs
           NewPVPairs = {NewPVPairs{:}, 'dialOutEvent', NewValue(1:end-2)};
        end
    end
    %---------------------------------------------------------
    % Add double-click  to the list if available and if it 
    % has not already been specified
    % (for use with std open-block-param-dialog)
    %---------------------------------------------------------
    if ~isempty( strmatch('dblclick', lower(AllEvents), 'exact') ) & ...
            isempty( strmatch('dblclick', lower(events), 'exact') )
        events = cat( 1, events, {'DblClick', 'ax_block_dclk'} );
        MakeNew = 1;
    end

    %---------------------------------------------------------
    % Add mouseup to the list if available and if it has not 
    % already been specified
    % (for use with contextual menu)
    %---------------------------------------------------------
    if ~isempty( strmatch('mouseup', lower(AllEvents), 'exact') ) & ...
            isempty( strmatch('mouseup', lower(events), 'exact') )
        events = cat(1,events,{'MouseUp'  'ax_block_click'});
        MakeNew = 1;
        SafeToAccessRightClick = 1;
    else
        SafeToAccessRightClick = 0;
    end
    %---------------------------------------------------------
    % For built-in GMS controls, there is no way to get to the
    % SL param panel except throught right-click, so if that event
    % is not available, then the it is not 'safe' to create the
    % control--i.e. the user cannot easily fix any mistakes,
    % so if there is any trouble with the current params--don't
    % create the control!
    %---------------------------------------------------------
    
    %--------------------------------------------------------------
    % If we've added events and such, we must recreate the control
    %--------------------------------------------------------------
    if MakeNew
        delete(hActx);
        if ~( ~isempty( msg ) & ~SafeToAccessRightClick )
            % We've not sent an error message, so make a new control 
            hActx = actxcontrol( progid, pos, hSys, events, '' );
            % Note: if we failed to add the right-click,        
        end
    end
    %--------------------------------------------------------------
    % If we've modified (i.e. added comments to) any params, set them
    %--------------------------------------------------------------
    if ~isempty (NewPVPairs)
        set_param( blk, NewPVPairs{:} );
    end
end
%To do: Need to make this generic for Control with MouseDown Event
% if ~isGMS | ( (isGMS) & (clickFlag == 1) )
%         registerevent(hActx,{'MouseDown' 'dng_block_mousedown'})
% end   
%-----------------------------------------------------------
% Finally, Store the control handle on block and vice versa
% Do not store the block handle as library instantiation
% causes these handles to become obsolete.
%-----------------------------------------------------------

if copyfile
    %save state of src block
    if isempty(findstr(blkpath,'dng_gmslib'))
        FullName = localGetAxFileName(blkpath);
        srcblkAxdata=get_param(blkpath,'UserData');
        srchActx = srcblkAxdata.hActx;
        save(srchActx,FullName)

        %store in src blk Userdata
        fid=fopen(FullName,'r');
        axdata=fread(fid);
        fclose(fid);
        srcblkAxdata.axDataFile=axdata;
        set_param(blkpath,'UserData',srcblkAxdata)
        axblkUd.hActx=hActx;
        axblkUd.axDataFile=axdata;
        set_param(blk,'UserData',axblkUd)
        load(axblkUd.hActx,FullName)
       % evalstr=['dos(''','del ',FullName,''');'];
        
        eval(['dos(''','del ',FullName,''');'])%call dos command
        % axblkUd.axDataFile=[];
        set_param(blk,'UserData',axblkUd)
    elseif (findstr(blkpath,'dng_gmslib') == 1)
        axblkUd.hActx=hActx;
        axblkUd.axDataFile=[];
    end

end

if ~isprop(hActx,'BlockPath'),
  schema.prop(hActx,'BlockPath','string');
    schema.prop(hActx,'InvalidPropVal','double');
  end
  set(hActx, ...
  'BlockPath',      blk, ...
    'InvalidPropVal', 0);

axblkUd.hActx=hActx;
    

if isempty(axblkUd.axDataFile)
    %create ax file to read ax binrary data and store into UD
    FullName = localGetAxFileName( blk );
    save(hActx,FullName)
    
    %store ax file in blk userdata
    fid=fopen(FullName,'r');
    axdata=fread(fid);
    fclose(fid);
    axblkUd.axDataFile=axdata;
    set_param(blk,'UserData',axblkUd)
    eval(['dos(''','del ',FullName,''');'])
    localRunInitialization (blk, hActx);
    return
end


%--------------------------------------------------
% Load saved data and run initialization commands
%--------------------------------------------------

if ~isempty(axblkUd.axDataFile)
    %if copyfile
        FullName = localGetAxFileName(blk);
        fid=fopen(FullName,'w');
        fwrite(fid,axblkUd.axDataFile);
        fclose(fid);   
        %FullName = localGetAxFileNameax(blkpath);
        load(axblkUd.hActx,FullName)
        eval(['dos(''','del ',FullName,''');'])        
        %sys=get_param(bdroot(blk),'Name')
        if findstr(sys,'dng_gmslib')
            localRunInitialization (blk, hActx);
        end
    %end
        
end

set_param( blk, 'UserData', axblkUd);
% Set dirty flag
local_setRebuildComplete (blk);
%-------------------------------------------------
% Done
%-------------------------------------------------
% end % Move old or make new

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     localInitializeOffBlockControl     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hActx = localInitializeOffBlockControl( blk, initcmd )
%=====================================================
% This whole section is only for off-block controls
%=====================================================
hActx = [];

%-----------------------
% user feedback strings
%-----------------------
crlf     = sprintf('\n'); % Used in verbose warning messages
% Start a verbose error message...
theError = sprintf('Check the "Handle Location" parameter of the ActiveX block:  \n"%s%s%s".\n', ...
    get_param(blk,'parent'), '/', get_param(blk,'name') );

%-----------------------------------------------------
% Check to see if this is a fully qualified block name
% e.g. vdp/Fcn
[sys, r] = strtok(initcmd,'/');
if isempty(r)
    %------------------------------------------------------------
	% OK, it does not look like a block name. Must be a function
	% Check ourselves first to see if we've already evaluated this
	% and stored the handle
	%hActx = get_param(blk, 'UserData'); 
    axblkUd = get_param(blk, 'UserData'); 
    
    hActx=axblkUd.hActx;
    
	if isempty(hActx)
		theError = [theError 'The initialization command failed to evaluate.'...
					crlf 'Please execute it from the command line to verify it works.' ...
					crlf 'The command string entered in the dialog is:' crlf initcmd ];
					hActx = eval(initcmd,'warning(theError)');
                    axblkUd.hActx=hActx;
					set_param(blk, 'UserData', axblkUd);
	end % if isempty(hActx)
    %-------------------------------------------------------------
else
    %-------------------------------------------------------------------
	% We presumably have a block name, so lets see what models are open
    %-------------------------------------------------------------------
	mdls = find_system('type','block_diagram');
	% Now see if the one we want is open (assume not, and that there will be errors)
	modelOpen = 0;
	
	for( idx = 1:length( mdls ) )
		if( strcmp( mdls{idx}, sys ) )
			modelOpen = 1;
			break;
		end % if
	end %for
    %-------------------------------------------------------
    % If the model is not open, see if we can open it
    %-------------------------------------------------------
	if( modelOpen == 0 )
		if( exist( sys ) == 4 ) % Then it is a model on the path
			modelOpen = 1;
			eval(sys,'modelOpen = 0;');
			% Error check and error message update
			if( modelOpen == 0 )
				theError = [theError...
							'An error occured when attempting to open the model:'...
							crlf '"' sys '".']
			end % if( modelOpen == 0 )
		else                    
			% Error check and error message update
			theError = [theError 'Model "' sys ...
						'" could not be opened, so the handle on the ActiveX block:' ...
						crlf ' "' initcmd '"' crlf 'could not be retieved.'];
		end % if exist...
	end % if( modelOpen == 0 )
    %-------------------------------------------------------
	% If the model is finally open, we can now get the block
    %-------------------------------------------------------
	if( modelOpen == 1 )
		theBlock = [];
		modelOpen = 0; % revert this. We'll use it as a success flag.
		
		% Make sure the block exists
		try
			theBlock = find_system( initcmd );
            theBlock = theBlock{1}; % convert cell array to a non-cell array
		catch
			theError = [theError 'The specified block:' crlf ' "' initcmd ...
						'"' crlf 'does not exist.'];
		end % try
		
		% Make sure it is an activeX block
		if( ~isempty( theBlock ) )
			try
				if( strcmp( get_param( theBlock, 'MaskType' ), 'ActiveX Block' ) )
					%hActx = get_param( theBlock, 'UserData' );
                    axblkUd = get_param( theBlock, 'UserData' );
                    hActx=axblkUd.hActx;
					modelOpen = 1;
				end % if
			end % try
			
			% Update Error if required
			if( modelOpen == 0 )
				theError = [ theError 'The specified block:' crlf ' "' initcmd ...
                              '"' crlf 'is not a Dials & Gauges ActiveX block.'];
			end % if
		end % if
	end % if( modelOpen == 1 )
    %-------------------------------------------------------
	% OK. We've done what we can to get the handle
	% Throw the error now if there were any problems
    %-------------------------------------------------------
	if( modelOpen == 0 )
          warning( theError );
	else,
          %
          % set up link back to parent
          %
          parentList = GetParentList(theBlock);

          parentList{end+1} = getfullname(blk);
          parentList        = unique(parentList);

            
          %
          % Make sure all parents exist.
          %
          for i=1:length(parentList),
            try,
              get_param(parentList{i},'tag');
            catch,
              %parent block no longer exists.
              parentList{i} = '';
            end                
          end

          parentList(strcmp(parentList,''))=[]; %prune the list
          SetParentList(theBlock,parentList);
        end

        

end % if isempty(r) -- does this refer to a block? Or a function?


%
%
%
function parentList = GetParentList(blk),
  unitialized = 0; 
    
  parentListTokStr = get_param(blk,'parentList');
  if (parentListTokStr == unitialized),
    parentListTokStr = '';
  end
  
  %
  % Convert comma seperated list to cell array.  Do strtok instead of
  % some kind of eval approach so that we can handle strings (block
  % names) with embedded new lines
  %
  r          = parentListTokStr;
  parentList = {};
  while ~isempty(r),
    [t r] = strtok(r,',');
    parentList{end+1} = t;
  end
%endfunction


%
%
%
function parentList = SetParentList(blk,parentList),
  bd     = bdroot(blk);
  dirty  = get_param(bd,'dirty');
  try,
    parentListStr = '';
    for i=1:length(parentList),
      parentListStr =  [parentListStr parentList{i} ','];   
    end
    if ~isempty(parentListStr),
      parentListStr(end) = []; %remove trailing comma
    end  
    set_param(blk,'parentList',parentListStr);
  catch,
    warning('Error setting offblock control parent.');
  end
  set_param(bd,'dirty',dirty);
%endfunction


%
%
%
function ForceBlockEval(blk),
  SetUpdateParamVal(blk,rand),
%endfunction

%
%
%
function SetUpdateParamVal(blk,val),
  bd     = bdroot(blk);
  dirty  = get_param(bd,'dirty');
  try,
    set_param(blk, ...
      'DisableBlockRedraw', 'on', ...
      'updateParam',        num2str(val));
  catch,
    warning('Error linking offblock control modification to parent.');
  end
  set_param(bd,'dirty',dirty);

%endfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     localModelClosing     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localModelClosing(blk);
% Removes the control & any temp files

% Delete the control -- don't bother saving first. There will be no undo!
localDeleteControl( blk );

% Get root name of ActiveX file
FileName = localGetAxFileName( blk );
% Delete temp files for this block
%FullTempName = fullfile( tempdir, [ localGetAxFileName( blk ), TEMP_EXTENSION ]);
%if( exist( FullTempName, 'file' ) == 2 )
%    delete( FullTempName );
%end

% Now delete any temp files related to delete/undeleted blocks in the model
%delete( fullfile( tempdir, [ get_param(bdroot(blk),'name') '*.ax' TEMP_EXTENSION, DELETE_EXTENSION ]) );
%if( strcmp( get_param( bdroot(blk), 'dirty' ), 'off' ) )
    % Everything is saved as desired. Delete cruft.
%    delete( fullfile( fileparts( get_param( bdroot(blk), 'FileName' ) ), ...
%                  [ get_param(bdroot(blk),'name') '*.ax' , DELETE_EXTENSION ]) );
%end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% localMoveBlockControl %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localMoveBlockControl( theBlock, hActx )
% assumes a valid on-block control

Bounds = localGetAxPosition( theBlock, get_param( theBlock, 'Parent' ) ); % [x,y,w,h] from btm-left corner of window
% Compare current block bounds to current bounds of control (get via "move" method?? whatever) 
if ~isequal( Bounds, move( hActx ) )
    move( hActx, Bounds );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% localOpenFcn %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localOpenFcn( theBlock )
% See if it is a GMS block
gms = localGetGMSInfo( get_param( theBlock, 'progid') );

if (gms)
  gms=0; % reset flag asa error check for following procedures
  % Set the block and system as current.
  lock = get_param(bdroot(theBlock), 'lock');

   % Open the ActiveX property sheet for this control.
   %hActx = get_param(theBlock, 'UserData');
   axblkUd = get_param(theBlock,'UserData');
   hActx = axblkUd.hActx;
   %get_param( theBlock, 'UserData' );
   
   if ~isempty(hActx),
      if localHasPropertyPage(hActx),
        if strcmp(lock, 'off')
          set_param(bdroot(theBlock), 'dirty', 'on'); % if not in a library,
		                                       % set model dirty.
        end
          
        propedit(hActx) % Open the property edit sheet for this control.
        gms = 1; % It worked! set gms flag back to original state
     end
  end
end
% if anything failed, open the regular dialog
if( ~gms )
    open_system( theBlock, 'mask' );      
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     localRunInitialization     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localRunInitialization( blk, hActx )
% runs the initialization command, if any, and resets the initialization flag

initcmd  = get_param(blk, 'init'); % ActX Initialization parameter

if ~isempty(initcmd)
    bname = [get_param(blk,'parent'), '/', get_param(blk,'name')];
    eval(initcmd,'fprintf(''\nInitialization command for block\n%s\nfailed due to evaluation error\n%s'',bname,lasterr)'); %absorbs any errors
end

% Unset the flag
local_setReinitializeBuild( blk, boolean(0) );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% localSaveBlockControl %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localSaveBlockControl( blk, FullSaveToken )
% Saves the activeX control to the temp dir
% if a FullSaveToken is provided, a copy of the newly
% saved file is placed in the model directory, too
if( strcmp(get_param(bdroot(blk), 'Lock'), 'on') )
    return;  % We are not saving locked libraries
end
%FullSave = (nargin == 2);
axblkUd = get_param(blk,'UserData');
hActx=axblkUd.hActx;
if ~isempty(axblkUd.hActx)
    FullName = localGetAxFileName(blk);
    save(axblkUd.hActx,FullName)
    %store ax file in blk userdata
    fid=fopen(FullName,'r');
    axdata=fread(fid);
    fclose(fid);
    axblkUd.axDataFile=axdata;
    % axblkUd.hActx=[];
    set_param(blk,'UserData',axblkUd)
    eval(['dos(''','del ',FullName,''');'])
else
    %%%Don't mess with the the library blks userdata
    if ~isempty(findstr(gcb,'dnglibv1')) | findstr(gcb,'dng_gmslib')
        return
    end
    %varName = localGetAxVarName(blk);
    varName = axblkUd.varName;
    axblkUd.hActx=evalin('base',varName);
    set_param(blk,'UserData',axblkUd)
    evalin('base',['clear ',varName])
end

     
%--------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% localString2Props %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function props = localString2Props(r)
% Creates a cell array of strings from the given string
% {};, ' characters will all be stripped from the original string
% so the input may be partially or fully formatted to begin with
props = {};
while( ~isempty(r) ),
    [t,r]=strtok(r,' ,;''{}');
    if( ~isempty( t ) ) % Don't be tricked by trailing tokens!
            props = { props{:}, t };
    end    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     localGetGMSInfo     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [isGMS, dialOutEvent, clickFlag] = localGetGMSInfo(progID);
% Internal function that returns whether or not the progID passed in
% is from a GMS control shipped with Dials & Gauges Blockset, and, if
% it is, returns the event that fires data output from the block.
persistent GMS_TABLE
% Table of GMS program IDs and desired output events.
if isempty (GMS_TABLE)
    %    progid                     dial event    click
    %                                             events
    GMS_TABLE = {
        'ad.adctrl.1',              '',             1         
        'air.airctrl.1',            '',             1     
        'joystick.joystickctrl.1',  'JoyMove',      0
        'mmap.mmapctrl.1',          '',             1    
        'mwagauge.agaugectrl.1',    '',             1
        'mwknob.knobctrl.1',        'Turn Click',   1 
        'mwled.ledctrl.1',          '',             1   
        'mwlgauge.lgaugectrl.1',    '',             1
        'mwnumled.numledctrl.1',    '',             1
        'mwodometer.odometerctrl.1','',             1
        'mwpercent.percentctrl.1',  '',             1
        'mwselector.selectorctrl.1','Change',       1
        'mwslider.sliderctrl.1',    'Slide Change', 1  
        'mwstrip.stripctrl.1',      '',             1
        'mwtoggle.togglectrl.1',    'Click',        1
		  };
end
% Find the right entry if it exists (ignore case).
result = find( strcmpi( progID, GMS_TABLE(:,1) ) );

% Output isGMS if progID matches anything.
isGMS = ~isempty(result);

% Output dialoutEvent for matched string.
if (nargout > 1),
	dialOutEvent = '';
	if isGMS,
      dialOutEvent = GMS_TABLE{result,2};
	end
  
	if (nargout > 2) & isGMS,
		clickFlag = GMS_TABLE{result,3};
    else
        clickFlag = -1;
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% local_getRebuildState %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function State = local_getRebuildState( blk )
% Gets the current rebuild state from the block's tag
State = get_param (blk, 'tag');
if (size (State, 2) ~= 3)
    State = '000';
end

%%%%%%%%%%%%%%%%%%%%%%%%
%     FULL_REBUILD     %
%%%%%%%%%%%%%%%%%%%%%%%%
function local_setFullRebuild( blk, flag )
% sets state to Full rebuild:
%  '1xx'
CurrentState = local_getRebuildState( blk );
if flag
    if CurrentState(1) ~= '1';
        CurrentState(1) = '1';
        set_param (blk, 'tag', CurrentState);
    end    
elseif CurrentState(1) ~= '0';
        CurrentState(1) = '0';
        set_param (blk, 'tag', CurrentState);
end

%----------------------------------------------
function b = local_isFullRebuild( blk )
% returns 1 if full rebuild is pending, 0 otherwise:
CurrentState = local_getRebuildState( blk );
b = (CurrentState(1) == '1');

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     PARTIAL_REBUILD     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function local_setPartialRebuild( blk, flag )
% sets state to partial rebuild:
%  'x1x'
CurrentState = local_getRebuildState( blk );
if flag
    if CurrentState(2) ~= '1';
        CurrentState(2) = '1';
        set_param (blk, 'tag', CurrentState);
    end    
elseif CurrentState(2) ~= '0';
        CurrentState(2) = '0';
        set_param (blk, 'tag', CurrentState);
end

%----------------------------------------------
function b = local_isPartialRebuild( blk )
% returns 1 if full rebuild is pending, 0 otherwise:
CurrentState = local_getRebuildState( blk );
b = (CurrentState(2) == '1');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     REINITIALIZATION     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function local_setReinitializeBuild( blk, flag )
% sets state to just reinitialize, not rebuild:
%  'xx1'
CurrentState = local_getRebuildState( blk );
if flag
    if CurrentState(3) ~= '1';
        CurrentState(3) = '1';
        set_param (blk, 'tag', CurrentState);
    end    
elseif CurrentState(3) ~= '0';
        CurrentState(3) = '0';
        set_param (blk, 'tag', CurrentState);
end

%----------------------------------------------
function b = local_isReinitializeBuild( blk )
% returns 1 if reinitialization pending, 0 otherwise:
CurrentState = local_getRebuildState( blk );
b = (CurrentState(3) == '1');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     REBUILD COMPLETE     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function local_setRebuildComplete( blk )
% sets state to fully complete:
%  '000'
if ~local_isRebuildComplete(blk)
    set_param (blk, 'tag', '000');
end

%----------------------------------------------
function b = local_isRebuildComplete( blk )
% returns 1 if rebuild is done, 0 otherwise:
CurrentState = local_getRebuildState( blk );
b = strcmp(CurrentState, '000');

%----------------------------------------------
function varName = localGetAxVarName(blk)
%blkName=get_param(blk,'Name')
varName = localGetAxFileName(blk);
varName = strrep(varName,'.','_');
varName = strrep(varName,'@','_');
varName = strrep(varName,' ','_');
      
%----------------------------------------------
function localGetSavedBlockControl( blk, hActx )

%Serialize Control here
FullName = localGetAxFileName( blk );
fid=fopen(FullName,'w');
fwrite(fid,axblkUd);
fclose(fid);
load(hActx,FullName);
eval(['dos(''','del ',FullName,''');']);

%----------------------------------------------
function localPreSaveblk(TheBlock)
persistent count
if isempty(count)
    count=0;
end
count = count + 1;

axblkUd=get_param(TheBlock,'UserData');
localSaveBlockControl( TheBlock, 'FullSave' );
axblkUd=get_param(TheBlock,'UserData');
varName = ['dng_ax_temp_',sprintf('%d',count)];
assignin('base',varName,axblkUd.hActx);
axblkUd.hActx=[];
axblkUd.varName=varName;
set_param(TheBlock,'UserData',axblkUd);
%----------------------------------------------
function [blkCopy,blkpath,axblkUd] = isBlklocalCopy(blk,axblkUd)
blkpath=[];
blkCopy=[];
if isempty(axblkUd.hActx)
    %axblkUd=axblkUd;
    return
end
if ~strcmp(blk,axblkUd.hActx.blockpath)
    blkpath=axblkUd.hActx.blockpath;
    axblkUd.hActx=[];
    blkCopy=1;
end
%----------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    localInitializeInBlockControl     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hActx = localInitializeInBlockControlBack(sys, blk)
% Returns the handle of the activeX block (HACTX) if it exists or can be
% created.

% Check for existing control before creating new one
hActx = get_param( blk, 'UserData' );

% spend a little time finding if we are dealing with dialog updates
% rather than runtime updates (which we want to be FAST)
if ~local_isRebuildComplete( blk )
    % Some dirty flag has been set
    % We don't want to react until the user hits OK or Apply, though
    % So see if params have been changed
    % (The dirty flag says they should be, so if they are not,
    %  the changes have been applied and we must update the ActiveX control)
	if ~any( localDirtyCheck( blk ) ), 
		% Look for full or partial rebuilds first, as they
		% require a new control be built before initialization can run
		if local_isPartialRebuild( blk )
             localSaveBlockControl( blk ); % Back up current state
             localDeleteControl( blk );    % Clear just the control   
             hActx = []; % forces creation of new control
		elseif local_isFullRebuild (blk)
             localDeleteBlock (blk);  % Full destroy--renames temp files
             hActx = []; % forces creation of new control
		end
		% If we still have an active x contol handle 
		% it probably just needed to be reinitialized
		% (that is why it appearted dirty)

          if localIsActX(hActx) & local_isReinitializeBuild (blk),     
              localRunInitialization (blk, hActx);    
          end
	end
end
% If we have a control, check to make sure it has not been zoomed, then we are done.
if localIsActX(hActx),
    localMoveBlockControl( blk, hActx );
    return;
end

% Also do nothing if missing the minimum data needed to make a control
progid = get_param(blk, 'progid');
if( isempty( progid ) ),        return;     end

%----------------------------------------------------------
% Make a new control...
%----------------------------------------------------------
%----------------------------------------------------------
% Get desired position and parent for the control
%----------------------------------------------------------
pos  = localGetAxPosition( blk, sys );
hSys = get_param(sys, 'Handle');
%----------------------------------------------------------
% Assemble list of events to add to the control
% Attempt to create with all events
%   If that fails, create without events, and mark for inspection
%     If that fails, bail
% If needs inspection, attempt to add events selectively
%   1. User events
%   2. Dial events
%   3. click/double-click events
%----------------------------------------------------------
MakeNew     = 0;  % Be positive. Assume it will work.
msg         = ''; % Logs error messages 
events      = {}; % Master list of events and handlers for the control
NewPVPairs  = {}; % Stores any modifications to the block parameters
[isGMS,skip,clickFlag] = localGetGMSInfo (progid);
%----------------------------------------------------------
% Start by compiling all events
%----------------------------------------------------------
% Arbitrary Events + Actions specified by the user in the block params
UserEventString = get_param (blk, 'eventstr');
if ~isempty (UserEventString)
    eval( ['UserEvents=' UserEventString ';'], 'UserEvents={};MakeNew=1;'); % Should create cell array of event name strings
else
    UserEvents = {};
end
% Check for: failed eval (|) non-cell array (|) misshaped cell array
if( MakeNew == 1 | ~iscell( UserEvents ) | ( ~isempty(UserEvents) & size(UserEvents,2) ~= 2 ) )
     % Failure mode. Let em know (in cmd line and in window)
     % (but only if we've never failed here before, as given by the leading "%" char
     if( UserEventString(1) ~= '%' )
         localDeliverMessage( blk, 'BadFormatEvents', [], UserEventString );
         % Comment out parameter so user can see it, and we won't next time
         NewPVPairs = {NewPVPairs{:}, 'eventstr', ['%' UserEventString]};
     end
     UserEvents = {}; % Don't mess with these again in this function!
end    % % % This one goes away and is replaced by the one below:

    % We made the first hurdle; lets see if we can work with the data now 
    % Start compiled list
    events = UserEvents;

    % Collect events specified by the user to initiate DialOutput changes
    DialEvents = localGetDialOutEvents (blk);
    try
        events = localAddNewEvents( blk, DialEvents, 'dng_dial_set', events, {} );
    catch
        localDeliverMessage( blk, 'BrokenEvents', [], [] );
    end
% % % % Append click and double-click events
% % % % for any third party control, or for a gms control we know has these events
% % % -- Waiting for geck 86705, where we can try/catch creating a bad control without
% % % -- resulting in an orphaned control sitting over out block
% % %     if ~isGMS | ( (isGMS) & (clickFlag == 1) )
% % %         events = localAddNewEvents( blk, {'MouseUp'}, 'ax_block_click', events, {} );
% % %         events = localAddNewEvents( blk, {'DblClick'}, 'ax_block_dclk', events, {} );
% % %     end
% % % %----------------------------------------------------------
% % % % Now, attempt to create the control!
% % % %----------------------------------------------------------
% % % -- Waiting for geck 86705, where we can try/catch creating a bad control without
% % % -- resulting in an orphaned control sitting over out block
% % % try
% % %     hActx = actxcontrol( progid, pos, hSys, events );
% % %     
% % % catch
% % % someone goofed.
    MakeNew = 3;
    % see if we can do it without events
    try
        hActx = actxcontrol( progid, pos, hSys, '', '' );
    catch        
        hActx = []; % control creation failed
        return;     % BAIL!!!! 
    end
% % % -- Waiting for geck 86705, where we can try/catch creating a bad control without
% % % -- resulting in an orphaned control sitting over out block
% % %    end % try
% % % end % if

%---------------------------------------------------------
% Set up our own event handling for the control as needed
%---------------------------------------------------------
if (MakeNew > 0) % % % Note: This will always be true until geck 86705 is fixed
    % Start empty
    events     = {}; % starter list
    MakeNew    = 0;  % creation flag
    AllEvents = fieldnames (send (hActx));  % List of all event names
    
    % Check user events
    if ~isempty (UserEvents),
        MakeNew = 1;
        [events, Mods] = localAddNewEvents( blk, UserEvents(:,1), UserEvents(:,2), events, AllEvents );
        if ~isempty (Mods)
            % Prepare to modify entry with comments
            Mods = cat( 1, {Mods{:}}, UserEvents(:,2)' );      % assemble & orient column-wise
            NewValue   = sprintf( '''%s'', ''%s''; ', Mods{:} ); % print out pairs
            NewValue   = ['{' NewValue(1:end-2) '}'];
            NewPVPairs = { NewPVPairs{:}, 'eventstr', NewValue };
        end
    end

    % Check dial events
    if ~isempty( DialEvents );
        MakeNew = 1;
        [events, Mods] = localAddNewEvents( blk, DialEvents, 'dng_dial_set', events, AllEvents );
        if ~isempty (Mods)
           % Prepare to modify entry with comments
           UserEvents = UserEvents'; % orient columns correctly
           NewValue   = sprintf( '%s, ', Mods{:} ); % print out pairs
           NewPVPairs = {NewPVPairs{:}, 'dialOutEvent', NewValue(1:end-2)};
        end
    end
    %---------------------------------------------------------
    % Add double-click  to the list if available and if it 
    % has not already been specified
    % (for use with std open-block-param-dialog)
    %---------------------------------------------------------
    if ~isempty( strmatch('dblclick', lower(AllEvents), 'exact') ) & ...
            isempty( strmatch('dblclick', lower(events), 'exact') )
        events = cat( 1, events, {'DblClick', 'ax_block_dclk'} );
        MakeNew = 1;
    end

    %---------------------------------------------------------
    % Add mouseup to the list if available and if it has not 
    % already been specified
    % (for use with contextual menu)
    %---------------------------------------------------------
    if ~isempty( strmatch('mouseup', lower(AllEvents), 'exact') ) & ...
            isempty( strmatch('mouseup', lower(events), 'exact') )
        events = cat(1,events,{'MouseUp'  'ax_block_click'});
        MakeNew = 1;
        SafeToAccessRightClick = 1;
    else
        SafeToAccessRightClick = 0;
    end
    %---------------------------------------------------------
    % For built-in GMS controls, there is no way to get to the
    % SL param panel except throught right-click, so if that event
    % is not available, then the it is not 'safe' to create the
    % control--i.e. the user cannot easily fix any mistakes,
    % so if there is any trouble with the current params--don't
    % create the control!
    %---------------------------------------------------------
    
    %--------------------------------------------------------------
    % If we've added events and such, we must recreate the control
    %--------------------------------------------------------------
    if MakeNew
        delete(hActx);
        if ~( ~isempty( msg ) & ~SafeToAccessRightClick )
            % We've not sent an error message, so make a new control 
            hActx = actxcontrol( progid, pos, hSys, events, '' );
            % Note: if we failed to add the right-click,        
        end
    end
    %--------------------------------------------------------------
    % If we've modified (i.e. added comments to) any params, set them
    %--------------------------------------------------------------
    if ~isempty (NewPVPairs)
        set_param( blk, NewPVPairs{:} );
    end
end

%-----------------------------------------------------------
% Finally, Store the control handle on block and vice versa
% Do not store the block handle as library instantiation
% causes these handles to become obsolete.
%-----------------------------------------------------------
set_param( blk, 'UserData', hActx );
if ~isprop(hActx,'BlockPath'),
  schema.prop(hActx,'BlockPath','string');
    schema.prop(hActx,'InvalidPropVal','double');
  end
  set(hActx, ...
  'BlockPath',      blk, ...
    'InvalidPropVal', 0);

%--------------------------------------------------
% Load saved data and run initialization commands
%--------------------------------------------------
TempFileName = fullfile( tempdir, [ localGetAxFileNameBack(blk), TEMP_EXTENSION ] );

% Load saved data, if it exists
if (exist (TempFileName, 'file') == 2)
  try,
    load( hActx, TempFileName );
  catch    
    warning(['Load of activeX control data failed: ' lasterr]);      
    localRunInitialization (blk, hActx);
  end    
end

% Run initialization and (re)save the control as needed
if (local_isReinitializeBuild( blk ) | ~(exist (TempFileName, 'file') == 2))
    localRunInitialization (blk, hActx);
    % Saving temp files is a big speed hit. Bypass our libraries, where it is not needed
    if ~strcmp( bdroot(blk), 'dng_gmslib')
        save(  hActx, TempFileName );
    end
end

% Set dirty flag
local_setRebuildComplete (blk);

axblkUd.hActx=hActx;
axblkUd.axDataFile=[];
set_param(blk,'UserDataPersistent','On');
set_param(blk,'Userdata',axblkUd);
localSaveBlockControl( blk, 'FullSave' );

%-------------------------------------------------
% Done
%-------------------------------------------------
% end % Move old or make new


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% localGetAxFileName %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function FileName = localGetAxFileNameBack( blk )
%LOCALGETAXFILENAME Creates the filename expected 
%   for an AxtiveX control living on the
%   block given by the fully qualified
%   block name BLOCKNAME (i.e. name given by gcb)

% version 1 used gcb instead of gcbh, so when we
% concatinate the name we need to escape the '/' chars
% like gcb would have done for us
FileName = strrep( get_param(blk,'name'), '/', '//' );
FileName = [get_param(blk,'parent') '@' FileName ];

% Replace filesystem-unfriendly characters
FileName = strrep(FileName,'\','_');
FileName = strrep(FileName,'/','@');
FileName = strrep(FileName,':','.');
FileName = strrep(FileName,'?','(huh)');
FileName = strrep(FileName,'*','#');
FileName = strrep(FileName,'>','}');
FileName = strrep(FileName,'<','{');
FileName = strrep(FileName,' ','_');
FileName = strrep(FileName,sprintf('\n'),'_');
FileName = [FileName  '.ax'];
