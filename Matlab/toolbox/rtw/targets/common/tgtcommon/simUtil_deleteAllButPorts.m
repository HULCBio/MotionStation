function deleteAllExceptPorts(block)
%DELETEALLEXCEPTPORTS
%   Delete all blocks in a subsystem except the inport and outport

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $
%   $Date: 2004/04/19 01:22:27 $

    %------------------------------
    % Delete all the lines
    % in the subsystem
    % -----------------------------
    toDelete = find_system(block,'LookUnderMasks','all','findall','on','type','line');
    if ~isempty(toDelete) 
        delete_line(toDelete);
    end
    % -------------------------------
    % We want to remove everything
    % except the inports and outports
    % of the system
    % --------------------------------

    % Get all variants of inport names and handles
    inportsPaths  = find_system(block,'LookUnderMasks','all','blocktype','Inport');
    inportsHandles  = get_param(inportsPaths,'handle');
    inportsHandles  = [inportsHandles{:}]';
    inportsNames    = get_param(inportsPaths,'name');

    % Get all variants of outport names and handles
    outportsPaths = find_system(block,'LookUnderMasks','all','blocktype','Outport');
    outportsHandles = get_param(outportsPaths,'handle');
    outportsHandles = [outportsHandles{:}]';
    outportsNames    = get_param(outportsPaths,'name');

    % Get all the blocks in the sub system
    toDelete = find_system(block,'LookUnderMasks','all','findall','on','type','block');

    % Remove from this list all the input and output ports
    toDelete = setdiff(toDelete,[inportsHandles ; outportsHandles]);

    % Delete all remaining blocks in the list
    if ~isempty(toDelete) & length(toDelete)>1
        deleteBlocks(toDelete(2:end));
    end

