function passThroughOutputChecker(passThroughOutputBlock, driverBlock, targetSubsystem, verbose)
%   passThroughOutputChecker
%
%   A utility to check that Pass-Through Outputs are connected
%   appropriately.   Pass-Through Outputs must be connected only to Virtual
%   Blocks within the Target Subsystem (eg. Subsystems) or routed to
%   Outports at the Target Subsystem level.
%
%   When provided with the reference to a Pass-Through Output block, and a
%   reference to the subsystem that the 'closest' Target block resides in,
%   this utility follows the signal line from the Pass-Through Output to
%   check that it is connected correctly.
%
%   Syntax: passThroughOutputChecker(passThroughOutputBlock, targetSubsystem, verbose)
% 
%
% --- Arguments ---
%
%   passThroughOutputBlock - reference to the Pass-Through Output block
%
%   targetSubsystem - reference to the subsystem containing the Target block
%
%   verbose - verbose flag (0 or 1) to change the level of comments output

%
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $
%   $Date: 2004/04/19 01:22:02 $

% create a structure of variables we may require, and pass this around with
% the recursive calls to i_followPath
varStruct.passThroughOutputBlock = passThroughOutputBlock;
varStruct.driverBlock = driverBlock;
varStruct.targetSubsystem = targetSubsystem;
varStruct.verbose = verbose;

% get the UDD object for the passThroughOutputBlock
block_UDD = get_param(passThroughOutputBlock, 'UDDObject');
% get the outport handle
outPort_UDD = get_param(block_UDD.PortHandles.Outport, 'UDDObject');
i_followPath(outPort_UDD, varStruct);

return;
    
% recursive function to follow a signal from a source block
% and make sure it terminates on a outport at the appropriate 
% subsystem level in the model
% note: if failure occurs an error will be thrown while deep in the
% recursion
function i_followPath(udd_obj, varStruct, varargin)
    % Path display code
    if (varStruct.verbose == 1)
        if (length(varargin) == 1)
            portnum = varargin{1};
            disp([class(udd_obj) ' Handle=' sprintf('%f',udd_obj.handle) ' Port=' portnum]);
        else
            disp([class(udd_obj) ' Handle=' sprintf('%f',udd_obj.handle)]);
        end;
    end;
    
    % behave differently depending on the class of the UDD object that we have obtained. 
    switch class(udd_obj)
        % Simulink.Port is the port on the block itself - ie. this is
        % different from the Simulink.Inport / Simulink.Outport which are
        % the objects found inside the subsystem
        case 'Simulink.Port'
            i_Port(udd_obj, varStruct);
        % Simulink.Segment is a Simulink line segment
        case 'Simulink.Segment'
            i_Segment(udd_obj, varStruct);
        % Simulink.Subsystem is a Simulink Subsystem
        % note, we pass a port number around so that we can locate the
        % correct path once inside the subsystem
        case 'Simulink.SubSystem'
            % can we retrieve a port number from varagin?
            if (length(varargin) == 1)
                portnum = varargin{1};
            else
                % we don't expect to get here
                i_displayError(udd_obj, 'noPortNum', varStruct);
            end;    
            i_Subsystem(udd_obj, varStruct, portnum);
        % Simulink.Inport is the Inport block found inside Subsystems
        case 'Simulink.Inport'
            i_Inport(udd_obj, varStruct);
        % Simulink.Outport is the Outport block found inside Subsystems
        case 'Simulink.Outport'
            i_Outport(udd_obj, varStruct);
        % Simulink.Terminator is an acceptable end point for a Pass-Through
        % Output
        case 'Simulink.Terminator'
            % Terminator ---> successful
        % Handle Mux and Bus Creators identically
        case {'Simulink.Mux' , 'Simulink.BusCreator' }
            i_Mux(udd_obj, varStruct);
        % Handle Demux and Bus Selectors identically
        case { 'Simulink.Demux' , 'Simulink.BusSelector' }
            i_Demux(udd_obj, varStruct);
        % Handle all other types of UDD Object we may find
        otherwise
            % Unknown block type - check library block for 
            % pass through override stored in the block Tag
            % If the block is an ok end point for the pass through
            % out then the string "PassThroughFriendly" will be found
            % in the Tag parameter
            libBlock = udd_obj.ReferenceBlock;
            if isempty(libBlock)            
                % not a library linked block ---> error
                i_displayError(udd_obj, 'InvalidBlock', varStruct);
            else 
                % follow link and check tag in library
                % checking the library tag protects us from
                % users altering the tag param.
                tag = get_param(libBlock, 'Tag');
                if ~strcmp(tag, 'PassThroughFriendly')
                    % fail if the block is not PassThroughFriendly
                    i_displayError(udd_obj, 'InvalidBlock', varStruct);
                end;
            end;
    end;
return;

% error handler for all errors
% this will make it easy to maintain
function i_displayError(udd_obj, type, varStruct)
    errormsg = ['A driver block, ''' varStruct.driverBlock ''', with a pass-through output was incorrectly routed to block, ''' [udd_obj.parent '/' udd_obj.name] '''. '...
                'During code generation, pass-through outputs will be eliminated, '...
                'so they may only be routed via Virtual Blocks (eg. Subsystems) in the Target Subsystem, or outside the Target '...
                'Subsystem by connecting to outports at the Target Subsystem level.   To fix this error, please make '...
                'sure your driver block pass-through output signals are connected as described above. '...
                'Then try updating the model again.'];
    switch (lower(type))
        case 'invalidblock'
            hilite_system(udd_obj.handle);
            error(errormsg);
        case 'subsystem'
            % We do not expect this error
            error('Correct Inport could not be found in the subsystem');
        case 'noportnum'
            % do not expect this error
            error('No port number supplied by the Simulink.Segment call');
        otherwise
            error('Unknown error type.');
    end;
return;

% Mux + Bus Creator - check the outport is connected, and then 
% follow the path - we don't do anything special - 
% which means we have simple code, but we are being
% over protective
function i_Mux(udd_obj, varStruct)
    if (udd_obj.LineHandles.Outport == -1)
        % ok for blocks to be unconnected
        return;
    end;
    i_followPath(get_param(udd_obj.LineHandles.Outport, 'UDDObject'), varStruct);
return;

% Demux + Bus Selector - follow each connected demux branch.
% We don't do anything special - we follow every path.  This gives simple
% code but we are being over protective
function i_Demux(udd_obj, varStruct)
    % follow each demux branch
    for i=1:length(udd_obj.LineHandles.Outport)
        if (udd_obj.LineHandles.Outport(i) == -1)
            % ok for blocks to be unconnected
            % skip to next output
            continue;
        end;
        i_followPath(get_param(udd_obj.LineHandles.Outport(i), 'UDDObject'), varStruct);
    end;
return;

% Simulink.Outport processing.  
% If we find an outport before we have reached the target subsystem level
% then we keep on going by following the appropriate Simulink.Port of the
% parent subsystem.
% If we are at the target subsystem level then we have a valid
% configuration.
% The only way to get to a higher level system than the target subsystem
% would be to go via an Outport, therefore we will stop before this point
% always.
function i_Outport(udd_obj, varStruct)
    % check to see if we are at the target subsystem level
    if (strcmp(udd_obj.Parent, varStruct.targetSubsystem))
        % we're done - stop following the path
        return;
    else
        % keep on going
        % now continue from this port of the parent subsystem
        % need to grab the port number
        portnum = sscanf(udd_obj.Port, '%d');
        
        parent = get_param(udd_obj.Parent, 'UDDObject');
        % Note: the Outport is a Simulink.Port and this will always exist
        % --> no need to check for connected state
        i_followPath(get_param(parent.PortHandles.Outport(portnum), 'UDDObject'), varStruct);
    end;
return;

% Simulink.Inport processing.
% we have arrived inside a subsystem at an inport,
% and need to follow the inport (note, we check that it is connected)
function i_Inport(udd_obj, varStruct)
    % check there is a line connected to the inport
    if (udd_obj.LineHandles.Outport == -1)
        % ok for blocks to be unconnected
        return;
    end;
    i_followPath(get_param(udd_obj.LineHandles.Outport, 'UDDObject'), varStruct);
return;

% Simulink.Port, the port of a subsystem that connects to a line Segment.
% Note: this is different from Simulink.Inport and Outport which live
% inside the Subsystem.   We make sure it is connected, and then follow the
% Segment.
function i_Port(udd_obj, varStruct)
    % check there is a line field
    if (udd_obj.Line == -1)
        % ok for blocks to be unconnected
        return;
    end;
    i_followPath(get_param(udd_obj.Line,'UDDObject'), varStruct);
return;

% Simulink.Segment - a signal line segment
% Check to see if the line is split - if it is, follow each section
% recursively, otherwise, jump to the destination of the segment.
% Note: we record the destination port number, so that in the case of a
% subsystem we can proceed along the correct Inport line once inside
function i_Segment(udd_obj, varStruct)
    % is this line connected directly to something, or does it split into
    % child lines further along?
    if (isempty(udd_obj.LineChildren))
        % check the segment is connected
        if (udd_obj.dstPortHandle == -1)
            % ok for blocks to be unconnected
            return;
        end;
        % get the port handle so we know how to map to the Simulink.Inport
        % this line segment is connected to
        portObj = get_param(udd_obj.dstPortHandle, 'UDDObject');
        i_followPath(get_param(udd_obj.dstBlockHandle, 'UDDObject'), varStruct, sprintf('%d',portObj.PortNumber));  
    else
        % may be ok to have a signal that is split, so long as ALL branches
        % behave ok - follow them all
        for i=1:length(udd_obj.LineChildren)
            i_followPath(get_param(udd_obj.LineChildren(i), 'UDDObject'), varStruct);
        end;
    end;
return;

% Simulink.Subsystem - we need to dive inside the subsystem and start
% following the appropriate Inport path - note we are provided with the
% correct Port Number to proceed along.
function i_Subsystem(udd_obj, varStruct, portnum)
    % have to find the Simulink.Inport block within the subsystem
    % note: there must be one otherwise we wouldn't have ended up in
    % the subsystem
    inport_handle = find_system(udd_obj.Handle,'findall','on',...
                                               'LookUnderMasks','all',...
                                               'FollowLinks','on',...
                                               'SearchDepth', 1, ...
                                               'blocktype', 'Inport',...
                                               'Port', portnum);
    if (size(inport_handle, 1) ~= 1)
        i_displayError(udd_obj, 'Subsystem', varStruct);
    end;
    i_followPath(get_param(inport_handle,'UDDObject'), varStruct);
return;
