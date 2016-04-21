function ports = addOutputPorts(block,portNames,position)
%ADDOUTPUTPORTS
%   Ensure that the block has the required
%   output ports. 
%
%   (1) If a port of the same name exists
%       then it is left but move to the
%       correct port number
%
%   (2) If a port does not exist then it
%       is added in.
%
%   (3) If a port exists and is not on the
%       required list then it is deleted.
%
%   The logic behind all this is to ensure
%   that when reconfiguring the internals
%   of a block the external port connections
%   are still maintained.

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $
%   $Date: 2004/04/19 01:22:26 $

    block = [ get_param(block,'parent') '/' get_param(block,'Name') ]; 

    outportSrc =    'built-in/Outport';

    outportsPaths  = find_system(block,'LookUnderMasks','all','blocktype','Outport');
    outportsHandles  = get_param(outportsPaths,'handle');
    outportsHandles  = [outportsHandles{:}]';
    outportsNames    = get_param(outportsPaths,'name');

    outportsHandlesToDelete = outportsHandles;

    for i=1:length(portNames)
        istr = int2str(i);
        destName = portNames{i};

        % If there is an existing port with the same name
        idx = find(strcmp(destName,outportsNames));
        if(~isempty(idx))
            %   use this port and give it the correct port number 
            dest = outportsHandles(idx(1));
            set_param(dest,'Port',int2str(i));
            outportsHandlesToDelete = setdiff(outportsHandlesToDelete,outportsHandles(idx));
        else
            %   create a new port
            dest = [ block '/' destName ];
            add_block(outportSrc,dest);
            set_param(dest,'Port',int2str(i));
        end
        simUtil_setPosition(dest,position,[0 50],i);
     
    end

    deleteBlocks(outportsHandlesToDelete);
