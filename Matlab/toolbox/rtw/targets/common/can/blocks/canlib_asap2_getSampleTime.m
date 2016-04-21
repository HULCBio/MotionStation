function varargout = canlib_asap2_getSampleTime(SIGNAL_ID, SYSTEM, UPDATE, VERBOSE)
% canlib_asap2_getSampleTime
%
% Calculate SAMPLE TIME for the given SIGNAL_ID within a Simulink SYSTEM
% 
% Parameters
%   SIGNAL_ID   -   name of the desired signal
%   SYSTEM      -   Simulink SYSTEM name to look for SIGNAL_ID within
%   UPDATE      -   perform an initial update on the root level system
%   VERBOSE     -   output the back traversed path that was followed 
%
% Returns
%     varargout{1}  -  sample time associated with SIGNAL_ID
%     varargout{2}  -  UDD Object of block that defines the sample time
%
% Example
%
%     [sampleTime, block] = SigId2SampleTime('TEST_SIGNAL', gcs, 1, 1)

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $
%   $Date: 2004/04/19 01:19:11 $

    % NOTE: for this function to work correctly, the 
    % model should have been updated (ie. Ctrl-d)
    % this calcualtes the CompiledSampleTime parameter correctly
    if (UPDATE == 1) 
        set_param(strtok(SYSTEM,'/'),'SimulationCommand','update'); 
    end

    %first find the segment of the signal
    segment_handle = find_system(SYSTEM,'findall','on','lookundermasks','all','followlinks','on','type','line','name',SIGNAL_ID);
    % make sure we found a signal
    if (size(segment_handle,1) == 0) 
        error('Signal was not found in the model');    
    end
    
    % get the UDD object for our segment handle
    % in the case of multiple segments - cycle through until we find the
    % one with SegmentType == trunk
    trunk_segment_found = 0;
    for i=1:size(segment_handle,1)
        segment_UDD = get_param(segment_handle(i),'UDDObject');
        if (strcmp(segment_UDD.SegmentType, 'trunk')==1) 
            % we found a trunk - we are done
            trunk_segment_found = 1;
            break;
        end;
    end;
    
    if (trunk_segment_found == 0) 
         error('No trunk segment corresponding to this signal could be found!');    
    end;
    
    % recursively traverse backwards from this signal line 
    % looking for a Block that specifies CompiledSampleTime
    [sampleTimeBlock code] = i_findRootBlock(segment_UDD, VERBOSE);
    
    switch (code)
    case 'CompiledSampleTime'
        % note: CompiledSampleTime of Inf means the signal
        % is driven by a constant block.
        varargout{1} = sampleTimeBlock.CompiledSampleTime(1);
    otherwise
        % error case
        disp(['ERROR ' code]);
        varargout{1} = '-2';
    end
    varargout{2} = sampleTimeBlock;    
    return;

% Simulink.Port - follow a Line if it is exists
function [block, code] = i_Port(udd_obj, VERBOSE)
    % check there is a line field
    if (udd_obj.Line == -1)
        block = udd_obj;
        code = 'Unconnected inport in Subsystem.';
        return;
    end
    [block code] = i_findRootBlock(get_param(udd_obj.Line,'UDDObject'), VERBOSE);
    return;
    
% Simulink.Segment - 
%
% check Segment is connected
% check for triggered subsystem and follow trigger path
% follow srcBlockHandle
function [block, code] = i_Segment(udd_obj, VERBOSE)
    % check this segment is connected
    if (udd_obj.srcPortHandle == -1) 
        block = udd_obj;
        code = 'Unconnected line segment.';
        return;
    end;

    % check to see if we are in a triggered subsystem
    % if so, the trigger is the path to follow to get the sample time
    % get the parent
    parent = get_param(udd_obj.parent,'UDDObject');
    fields = get(parent);
    if (isfield(fields,'PortHandles') == 1)
        if (isfield(fields.PortHandles,'Trigger') == 1) 
            if (isempty(fields.PortHandles.Trigger) == 0)
                [block code] = i_findRootBlock(get_param(parent.PortHandles.Trigger,'UDDObject'), VERBOSE);            
                return;            
            end;
        end;
    end;

    % get the port handle so we know how to map to the Simulink.Outport
    % this line segment is connected to
    portObj = get_param(udd_obj.srcPortHandle, 'UDDObject');
    [block code] = i_findRootBlock(get_param(udd_obj.srcBlockHandle, 'UDDObject'), VERBOSE, portObj.PortNumber);
    return;

% Simulink.Subsystem - 
%
% Find the correct Simulink.Outport and traverse
function [block, code] = i_Subsystem(udd_obj, VERBOSE, portnum)
    % have to find the Simulink.Outport block within the subsystem
    % note: there must be one otherwise we wouldn't have ended up in
    % the subsystem
    outport_handle = find_system(udd_obj.Handle,'findall','on','LookUnderMasks','all','FollowLinks','on', 'SearchDepth', 1, 'blocktype', 'Outport', 'Port', num2str(portnum));
    if (size(outport_handle, 1) ~= 1) 
        error('Could not find outport handle');
    end;
    [block code] = i_findRootBlock(get_param(outport_handle,'UDDObject'), VERBOSE);

% Simulink.XXXXX
%
% Generic block including Simulink.Inport and Simulink.Outport
% Return the CompiledSampleTime
function [block, code] = i_genericBlock(udd_obj, VERBOSE)
    % note: we include Simulink.Inport in this clause!
    % note: we inlcude Simulink.Outport in this clause!
    
    % we have a "real" Simulink block
    fields = get(udd_obj);
    % check for a CompiledSampleTime field
    if (isfield(fields,'CompiledSampleTime') == 1)
        block = udd_obj;
        code = 'CompiledSampleTime';
        return;
    end;

% Recursive function to traverse the block diagram backwards from the original 
% Simulink.Segment and find a Simulink.XXXXX that has a compiledSampleTime
function [block, code] = i_findRootBlock(udd_obj, VERBOSE, varargin) 
    % Path display code
    if (VERBOSE == 1)
        if (length(varargin) == 1)
            portnum = varargin{1};
            disp([class(udd_obj) ' Handle=' num2str(udd_obj.handle) ' Port=' num2str(portnum)]);
        else
            disp([class(udd_obj) ' Handle=' num2str(udd_obj.handle)]);
        end
    end
        
    switch class(udd_obj)
    case 'Simulink.Port'
        [block, code] = i_Port(udd_obj, VERBOSE);
    case 'Simulink.Segment'
        [block, code] = i_Segment(udd_obj, VERBOSE);        
    case 'Simulink.SubSystem'
        % can we retrieve a port number from varagin?
        if (length(varargin) == 1)
            portnum = varargin{1};
        else
            block = udd_obj;
            code = 'No port number supplied by the Simulink.Segment!';
            return;
        end;    
        [block, code] = i_Subsystem(udd_obj, VERBOSE, varargin{1});
    otherwise
        [block, code] = i_genericBlock(udd_obj, VERBOSE);
    end
