function simulinkPortControl(parentBlock, action, varargin)
%   simulinkPortControl
%
%   A set of utilities for controlling the configuration of a Masked Simulink
%   Subsystem's inports and outports, using Mask Initialisation code.   If a block is
%   written using these utilities, it is possible for the mask to contain checkbox 
%   parameters that control whether particular inports / outports are 'enabled' 
%   (functioning as valid input / output ports) or 'disabled' (grounded / terminated).
%
%   This is particularly useful for creating blocks with configurable
%   inports and outports, such as "Pass-through" driver blocks for Embedded
%   Targets.
%
%   The implementation of controlling ports in this way relies upon four
%   Simulink blocks that are required on each input / output signal of the
%   subsystem.   The blocks allow the desired port numbers to be maintained
%   while ports are selectively enabled / disabled.
%
%   These blocks are:
%
%   Non-Configurable Inport Control
%   Non-Configurable Outport Control
%   Configurable Inport Control
%   Configurable Outport Control
%
%   The Non-Configurable Control blocks should be placed on input / output
%   signals, whose ports are not configurable.   This block specifies the
%   desired port number of the attached port when all ports are enabled.
%
%   The Configurable Control blocks work much the same as the
%   Non-Configurable Control blocks, and the function of the port number
%   parameter is precisely the same.   The Configurable Control blocks also
%   specify a Port Name, which can be used by this function (simulinkPortControl)
%   to enable / disable ports within the subsystem.
%
% Syntax: simulinkPortControl(parentBlock, action, varargin)
% 
% --- Arguments ---
%
%   parentBlock - handle of the masked subsystem that contains the
%   configurable inports / outports
%
%   action   -  
%
%   'enable'
%
%   --------------------------------------------------------------------
%
%   Usage:
%
%   simulinkPortControl(parentBlock, 'enable', blockref, state)
%
%   Called to enable / disable a particular port in the masked subsystem (parentBlock).   
%   This should be called from Mask Initialisation code to manipulate an inport or outport.
%
%   Note, a call to simulinkPortControl(parentBlock, 'enable',...) implicitly
%   calls an internal function that performs various consistency checks on
%   the subsystem before the update (enable / disable) is applied.
%   
%   Blockref is either the handle to the appropriate Inport / Outport
%   Control Block block, or the (unique) Port Name of Control Block.
%   NOTE: supplying the handle to the Control Block is likely to be only
%   used when debugging.  It is strongly recommended that Configurable
%   Control Blocks are referenced by Port Names.
%
%   For example, a typical application would be to call simulinkPortControl
%   from mask initialisation code (ie. can process a users check box selections for example).   
%   The code placed in the initialisation code would look something
%   like:
%
%   simulinkPortControl(gcbh, 'enable', 'MyPort', MyParameter);
%
%   Where 'MyPort' is a valid Port Name specified in the mask of a
%   Configurable Control Block, and MyParameter is a mask parameter of
%   the masked subsystem whose ports are being manipulated.
%
%   'state' (either 'on' (or 1) or 'off' (or 1)) is the new status of the connected port.
%
%   If 'state' is 'on', then for an inport type, the block attached to blockref 
%   is replaced with an INPORT that has similar properties (eg. Name, position etc.)   
%   If 'state' is 'off' then the block is replaced with a GROUND.
%   
%   Outport types are treated similarly, except blocks are replaced by outports or
%   terminators depending on the value of the 'state' input.
%
%   ----------------------------------------------------------------------

%
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $
%   $Date: 2004/04/19 01:22:30 $

% protection against strange Stateflow initialisation in libraries
% if we are in library we will not throw errors
try
    % main switch block to handle different actions
    switch lower(action)
        case 'enable'
            % ALWAYS check the subsystem to begin with!
            i_checkSystem(parentBlock);
        
            % block to manipulate
            block_ref = varargin{1};
            % enable or disable
            state = varargin{2};

            % get control block handle
            [handle, type] = i_getBlockHandle(parentBlock, block_ref);
            % check state - accept 0, 1, 'off', 'on'
            switch state
                    case 0
                        % disable this port
                        i_disablePort(handle, type);
                    case 'off'
                        % disable this port
                        i_disablePort(handle, type);                                
                    case 1
                        % enable this port
                        i_enablePort(parentBlock, handle, type);                
                    case 'on'
                        % enable this port
                        i_enablePort(parentBlock, handle, type);                
                    otherwise
                        i_handle_error('Unrecognised state');
            end;                    
        otherwise
            error('Unrecognised action!');
    end;
catch
    if (~strcmp(get_param(bdroot(parentBlock),'BlockDiagramType'),'library'))
        % reissue the error if we are not in a library
        rethrow(lasterror);
    end;
end;
return;

function i_checkSystem(parentBlock)
    % this function checks that:
    %   all Inports are connected to Control Blocks
    %   all Outports are connected to Control Blocks
    %   Control blocks are connected correctly, and updates their
    %   state (eg. Enabled / Disabled)
    %   portNames are unique within the subsystem
    %   portNumbers are unique within the subsystem
    %   reorders ports to make sure they are numbered correctly
    
    % make sure all inports / outports are connected to control blocks
    i_checkInports(parentBlock);
    i_checkOutports(parentBlock);
    % do checks on the control blocks
    i_checkControlBlocks(parentBlock);    
    
    % THEN we reorder ports if necessary...
    i_updatePortNumbersForType(parentBlock, 'inport');
    i_updatePortNumbersForType(parentBlock, 'outport');
return;

% find all inports in the system and check that they are connected to
% either a Non-Configurable Inport Control Block or a Configurable Inport
% Control block
function i_checkInports(parentBlock)
    % get handles to all inports
    handles = i_getInports(parentBlock);
    for i=1:length(handles)
        i_checkPort(parentBlock, handles(i), 'inport');
    end;
return;

% find all outports in the system and check that they are connected to
% either a Non-Configurable Outport Control Block or a Configurable Outport
% Control Block
function i_checkOutports(parentBlock)
    % get handles to all outports
    handles = i_getOutports(parentBlock);
    for i=1:length(handles)
        i_checkPort(parentBlock, handles(i), 'outport');
    end;
return;

% verify Inports / Outports are connected to Control Blocks
function i_checkPort(parentBlock, block, type)
    % get the port handles for this block
    hPorts = get_param(block, 'PortHandles');
    switch lower(type)
        case 'inport'
            % follow the output
            hOutputLine = get_param(hPorts.Outport, 'Line');
            if (hOutputLine == -1)
                % not connected to anything!
                i_handle_error('Inport is not connected!');
            end;
            controlHandle = get_param(hOutputLine, 'DstBlockHandle');
            if (controlHandle == -1)
                % not connected to anything!
                i_handle_error('Inport is not connected!');
            end;
            if (length(controlHandle)~=1)
                i_handle_error('Ports may only be connected to a single Control Block');
            end;
            % check that controlHandle is an inport control
            [blockhandle, type] = i_getBlockHandle(parentBlock, controlHandle);
            switch type
                case 'inport'
                    % desired case - no action
                otherwise
                    i_handle_error('Inports must be connected to Inport Control Blocks.');
            end;
        case 'outport'
            % follow the input
            hInputLine = get_param(hPorts.Inport, 'Line');
            if (hInputLine == -1)
                % not connected to anything!
                i_handle_error('Outport port is not connected!');
            end;
            controlHandle = get_param(hInputLine, 'SrcBlockHandle');
            if (controlHandle == -1)
                % not connected to anything!
                i_handle_error('Outport port is not connected!');
            end;
            if (length(controlHandle)~=1)
                i_handle_error('Ports may only be connected to a single Control Block');
            end;
            % check that controlHandle is an outport control
            [blockhandle, type] = i_getBlockHandle(parentBlock, controlHandle);
            switch type
                case 'outport'
                    % desired case - no action
                otherwise
                    i_handle_error('Outports must be connected to Outport Control Blocks.');
            end;
    end;
return;

% verify Control Blocks are connected correctly, and that their parameters
% are consistent with each other.
function i_checkControlBlocks(parentBlock)
    % build up these arrays to check for uniqueness
    portNameCell = {};   
    inportNumArray = [];
    outportNumArray = [];
    
    % get set of non configurable inport control blocks
    a = i_getNonConfigurableInportBlocks(parentBlock);
    % get set of configurable inport control blocks
    b = i_getConfigurableInportBlocks(parentBlock);
    % get set of non configurable outport control blocks
    c = i_getNonConfigurableOutportBlocks(parentBlock);
    % get set of configurable outport control blocks
    d = i_getConfigurableOutportBlocks(parentBlock);
    % combine the double arrays to get all
    % control blocks
    controlBlocks = [a; b; c; d];
    
    % process each and make sure it is connected appropriately
    for i=1:length(controlBlocks)
        % derive state of control block from whatever we are connected to
        % and perform various checks
        if sscanf(get_param(controlBlocks(i),'isInport'), '%d')
            %%
            %% INPORT PROCESSING
            %%
            % add the Port Number to the array
            inportNumArray(length(inportNumArray)+1) = sscanf(get_param(controlBlocks(i),'portNum'), '%d');
            % get the port handle
            portHandle = i_getHandleOfBlockToManipulate(controlBlocks(i), 'inport');
            if sscanf(get_param(controlBlocks(i),'isConfigurable'), '%d')
                %%
                %% CONFIGURABLE INPORT
                %%
                switch get_param(portHandle, 'BlockType')
                    case 'Ground'
                        % this control block is disabled
                        i_setControlBlockEnabled(controlBlocks(i),'off');
                    case 'Inport'
                        % this control block is enabled
                        i_setControlBlockEnabled(controlBlocks(i),'on');
                    otherwise
                        % this control block is connected to an invalid block type!
                        i_handle_error('Inport Control blocks must be connected to either Ground or Inport blocks.');
                end;       
            else
                %%
                %% NON CONFIGURABLE INPORT
                %%
                switch get_param(portHandle, 'BlockType')
                    case 'Inport'
                        % this is the expected case - do nothing    
                    otherwise
                        i_handle_error('Non-Configurable Inport Control Blocks must be connected to Inports.');            
                end;
            end;
        else
            %%
            %% OUTPORT PROCESSING
            %%
            % add the Port Number to the array
            outportNumArray(length(outportNumArray)+1) = sscanf(get_param(controlBlocks(i),'portNum'), '%d');
            % get the port handle
            portHandle = i_getHandleOfBlockToManipulate(controlBlocks(i), 'outport');
            if sscanf(get_param(controlBlocks(i),'isConfigurable'), '%d')
                %%
                %% CONFIGURABLE OUTPORT
                %%
                switch get_param(portHandle, 'BlockType')
                    case 'Terminator'
                        % this control block is disabled
                        i_setControlBlockEnabled(controlBlocks(i),'off');
                    case 'Outport'
                        % this control block is enabled
                        i_setControlBlockEnabled(controlBlocks(i),'on');
                    otherwise
                        % this control block is connected to an invalid block type!
                        i_handle_error('Outport Control blocks must be connected to either Terminator or Outport blocks.');
                end;              
            else
                %%
                %% NON CONFIGURABLE OUTPORT
                %%
                switch get_param(portHandle, 'BlockType')
                    case 'Outport'
                        % this is the expected case - do nothing    
                    otherwise
                        i_handle_error('Non-Configurable Outport Control Blocks must be connected to Outports.');            
                end;    
            end;
        end;
        
        % store the portName whether inport or outport!
        if sscanf(get_param(controlBlocks(i),'isConfigurable'), '%d')
            portNameCell{length(portNameCell)+1} = get_param(controlBlocks(i),'portName');
        end;
    end;
    % verify Inport Numbers are unique
    if (length(inportNumArray)~=length(unique(inportNumArray)))
        i_handle_error('Inport Numbers in the subsystem are not unique.');
    end;
    % check range of inport numbers - must go up 1 by 1 from 1
    if ((min(inportNumArray) ~= 1) | (max(inportNumArray) ~= length(inportNumArray)))  
        i_handle_error('Inport Control blocks must be numbered consecutively from 1');
    end;
    % verify Outport Numbers are unique
    if (length(outportNumArray)~=length(unique(outportNumArray)))
        i_handle_error('Outport Numbers in the subsystem are not unique.');
    end;
    % check range of outport numbers - must go up 1 by 1 from 1
    if ((min(outportNumArray) ~= 1) | (max(outportNumArray) ~= length(outportNumArray)))  
        i_handle_error('Outport Control blocks must be numbered consecutively from 1');
    end;
    % verify portNames are unqiue
    if (length(portNameCell)~=length(unique(portNameCell)))
        i_handle_error('Port Names in the subsysem are not unique.');
    end;
return;

% handle errors gracefully if required
% this may be expanded to handle errors more gracefully.
function i_handle_error(comment)
    error(comment);
return;

% reassign port numbers of ports of the type "desiredPortType", either
% 'inport' or 'outport', according to the desired port numbers stored as
% parameters in the Control Blocks.
function i_updatePortNumbersForType(parentBlock, desiredPortType)
    % initialise the portCounter to 1
    portCounter = 1;
    
    % find all of the Control blocks of the appropriate type
    switch desiredPortType
        case 'inport'
            nonConfig = i_getNonConfigurableInportBlocks(parentBlock);
            Config = i_getConfigurableInportBlocks(parentBlock);
            
        case 'outport'
            nonConfig = i_getNonConfigurableOutportBlocks(parentBlock);
            Config = i_getConfigurableOutportBlocks(parentBlock);
    end;
    
    % combine the double arrays to get all
    % control blocks of a given type
    controlBlocks = [nonConfig; Config];
    
    portNums = [];
    for i=1:length(controlBlocks)
        % build the array of portNums so that we can sort it.
        portNums(length(portNums) + 1) = get_param(controlBlocks(i), 'portNum');
    end;
        
    % now sort by portNum parameter to get the indices
    [sortedPortNums, indices] = sort(portNums);
    
    % step through the sorted list of handles
    for i=1:length(indices)
        index = indices(i);
        block = controlBlocks(index);
        port = i_getHandleOfBlockToManipulate(controlBlocks(index), desiredPortType);
        % note: non-configurable ports are always enabled!       
        if (i_isControlBlockEnabled(block))
            % port is enabled so set the port number
            % and then increment the counter
            set_param(port, 'Port', sprintf('%d',portCounter));
            portCounter = portCounter + 1;
        end;
    end;
return;

% enable (either inport, or outport) the port associated with 'block' in
% subsystem parentBlock
function i_enablePort(parentBlock, block, type)
    % do the replacement, storing props of the replacement block
    i_replaceBlock(block, 'enable', type);
    % register that the block is in an enabled state.
    i_setControlBlockEnabled(block, 'on')
    % must update the port numbers for all inports or all outports.
    i_updatePortNumbersForType(parentBlock, type);
return;

% disable (either ground, or terminate) the port associated with 'block' in
% subsystem parentBlock
function i_disablePort(block, type)    
    % do the replacement
    i_replaceBlock(block, 'disable', type);
    % register that the block is in a disabled state
    i_setControlBlockEnabled(block, 'off');
    % no need to update port numbers here as we only disabled ports
return;

% set the state of the given block
% enabled ('on')
% disabled ('off')
function i_setControlBlockEnabled(block, enabled)
    % record state
    switch (enabled)
        case 'on'
            set_param(block, 'isEnabled', '1');        
        case 'off'
            set_param(block, 'isEnabled', '0');    
        otherwise 
            i_handle_error('State must be "on" or "off"');
    end;
return;

% return whether the given block is enabled(1) or disabled(0)
% NOTE: here we return the numeric value, 0 or 1 as it is useful in
% conditions.  This is in contrast to i_setControlBlockEnabled where we
% accept only 'on' or 'off' as the argument.
function enabled = i_isControlBlockEnabled(block)
    % read the block state from the user data
    enabled = sscanf(get_param(block, 'isEnabled'), '%d');
return;

% given a block handle and type, work out the handle of the associated block that we
% wish to manipulate (portHandle)
function portHandle = i_getHandleOfBlockToManipulate(block, type)
    % get the port handles for this block
    hPorts = get_param(block, 'PortHandles');
    switch lower(type)
        case 'inport'
            % follow the input
            hInputLine = get_param(hPorts.Inport, 'Line');
            if (hInputLine == -1)
                % not connected to anything!
                i_handle_error('Input port is not connected!');
            end;
            portHandle = get_param(hInputLine, 'SrcBlockHandle');
            if (portHandle == -1)
                % not connected to anything!
                i_handle_error('Input port is not connected!');
            end;
        case 'outport'
            % follow the output
            hOutputLine = get_param(hPorts.Outport, 'Line');
            if (hOutputLine == -1)
                % not connected to anything!
                i_handle_error('Output port is not connected!');
            end;
            portHandle = get_param(hOutputLine, 'DstBlockHandle');
            if (portHandle == -1)
                % not connected to anything!
                i_handle_error('Output port is not connected!');
            end;
    end;
    if (length(portHandle)~=1)
        i_handle_error('Control Blocks may only be connected to a single port');
    end;
return;

% replace the block connected to "block", depending on the action (either
% enable or disable, and type ('inport' / 'outport')
% The replacement block handle is returned as an output argument.
function newBlockHandle = i_replaceBlock(block, action, type)
    % NOTE!
    % Can't use REPLACE_BLOCK because it doesn't work inside library links.
    
    % get the block handle of the block to replace
    hThisBlk = i_getHandleOfBlockToManipulate(block, type);
    
    % determine the new block type!
    switch lower(action)
        case 'enable'
            switch lower(type)
                case 'inport'
                    newBlkType = 'Inport';
                case 'outport'
                    newBlkType = 'Outport';
                otherwise
                    error('Unknown port type!');
            end;
        case 'disable'
            switch lower(type)
                case 'inport'
                    newBlkType = 'Ground';
                case 'outport'
                    newBlkType = 'Terminator';
                otherwise
                    error('Unknown port type!');
            end;
        otherwise
            error('Unknown action!');
    end;  
    
    % only replace the block if required!
    if (strcmp(get_param(hThisBlk,'BlockType'), newBlkType))
        % blocks are the same - do not replace or signal lines
        % will be disrupted!
        newBlockHandle = hThisBlk;
        return;
    end;
    
    % similar to P.Jackson's original code
    
    % store the old settings
    oldsettings.Sys      = get_param(hThisBlk, 'Parent');
    oldsettings.Name     = get_param(hThisBlk, 'Name');
    oldsettings.Pos      = get_param(hThisBlk, 'Position');
    oldsettings.Orient   = get_param(hThisBlk, 'Orientation');
    oldsettings.Place    = get_param(hThisBlk, 'NamePlacement');
    
    % remove the old block
    delete_block(hThisBlk);
    
    % create the new block
    newBlockHandle = add_block(['built-in/', newBlkType], [oldsettings.Sys, '/', oldsettings.Name], ...
        'Position', oldsettings.Pos, ...
        'Orientation', oldsettings.Orient, ...
        'NamePlacement', oldsettings.Place);
return;

% return the block handle (and type) of the the Control Block in the
% current system (parentBlock) that has the matching portName == blockref
function [blockhandle, type] = i_getControlBlockWithBlockRef(parentBlock, blockref)
    % check Configurable Inport Control Blocks
    inportControlBlock = find_system(parentBlock, 'FollowLinks', 'on',...
                            'SearchDepth',1,...
                            'LookUnderMasks', 'all',...
                            'MaskType', 'Configurable Inport Control',...
                            'portName', blockref);
    % check Configurable Outport Control Blocks
    outportControlBlock = find_system(parentBlock, 'FollowLinks', 'on',...
                            'SearchDepth',1,...
                            'LookUnderMasks', 'all',...
                            'MaskType', 'Configurable Outport Control',...
                            'portName', blockref);
                        
    if ((length(inportControlBlock) + length(outportControlBlock)) ~= 1)
        % if we made it to here then a single block could not be found!
        i_handle_error(['A single Control block with Port Name "' blockref '" must be in the subsystem!']);
    end;
    if (length(inportControlBlock)==1)
        % block is an inportControlBlock
        blockhandle = inportControlBlock;
        type = 'inport';
    else
        % outportControlBlock
        blockhandle = outportControlBlock;
        type = 'outport';
    end;
return;

% Given a blockref (either a handle to the block, or the "Port Name"
% parameter, return the handle to the block + type + whether it is 
% a configurable Control Block
function [blockhandle, type, configurable] = i_getBlockHandle(parentBlock, blockref)
    if ishandle(blockref)      
        % block ref is a block handle
        blockhandle = blockref;
        maskType = get_param(blockhandle, 'MaskType');
        switch (maskType)
            case 'Configurable Inport Control'
                type = 'inport';
                configurable = 1;
            case 'Configurable Outport Control'
                type = 'outport';
                configurable = 1;
            case 'Non-Configurable Inport Control'
                type = 'inport';
                configurable = 0;
            case 'Non-Configurable Outport Control'
                type = 'outport';
                configurable = 0;
            otherwise
                i_handle_error('Could not resolve the blockreference to a valid Control Block');
        end;
    elseif ischar(blockref)
        % block ref is a "Port Name" string
        % must search for the block in the current system
        [blockhandle, type] = i_getControlBlockWithBlockRef(parentBlock, blockref);
        configurable = 1;
        return;
    else
        i_handle_error('blockref must be a handle or Port Name string');
    end;
return;



%% Set of functions that do find_system calls to return a particular 
%% set of blocks in the masked subsystem, parentBlock.

function handles = i_getNonConfigurableInportBlocks(parentBlock)
    handles = find_system(parentBlock, 'FollowLinks', 'on',...
                'SearchDepth',1,...
                'LookUnderMasks', 'all',...    
                'MaskType', 'Non-Configurable Inport Control');
return;

function handles = i_getNonConfigurableOutportBlocks(parentBlock)
    handles = find_system(parentBlock, 'FollowLinks', 'on',...
                'SearchDepth',1,...
                'LookUnderMasks', 'all',...
                'MaskType', 'Non-Configurable Outport Control');
return;

function handles = i_getConfigurableInportBlocks(parentBlock)
    handles = find_system(parentBlock, 'FollowLinks', 'on',...
                'SearchDepth',1,...
                'LookUnderMasks', 'all',...
                'MaskType', 'Configurable Inport Control');
return;

function handles = i_getConfigurableOutportBlocks(parentBlock)
    handles = find_system(parentBlock, 'FollowLinks', 'on',...
                'SearchDepth',1,...
                'LookUnderMasks', 'all',...
                'MaskType', 'Configurable Outport Control');
return;

function handles = i_getInports(parentBlock)
    handles = find_system(parentBlock, 'FollowLinks', 'on',...
                'SearchDepth',1,...
                'LookUnderMasks', 'all',...
                'BlockType', 'Inport');
return;

function handles = i_getOutports(parentBlock)
    handles = find_system(parentBlock, 'FollowLinks', 'on',...
                'SearchDepth',1,...
                'LookUnderMasks', 'all',...
                'BlockType', 'Outport');
return;

