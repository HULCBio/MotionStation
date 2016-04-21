function endBlk = tblpresrc(startBlk, startInportIdx)
%TBLPRESRC Find PreLook-Up block connected to block port
%   PRE = TBLPRESRC(GCB,1) is the PreLook-Up Index Search
%   block connected to the first input port of Simulink block
%   GCB.  The search is graphical, so it is not necessary  to 
%   have a compilable model to get the answer.
%
%   The connection can be a direct connection, or a connection
%   through any chain of inport/outport, subsystem, mux,
%   bus selector, and goto/from blocks.  Some mux/demux cases 
%   are handled as well.
%
%   If a PreLook-Up Index Search block is not found in the 
%   chain of connections, the empty matrix, [], is quietly
%   returned.  This includes the case of an unconnected line
%   or port.
%
%   This function will find correct connections even if the 
%   block diagram does not run or even compile, but this is a
%   subset of the total number of combinations handled.
%
%   Limitations:
%   The first non-virtual algorithmic block encountered on a 
%   nonmuxed path stops the search. This means that the algorithm 
%   will not find PreLook-Up Index Search blocks whose outputs 
%   are modified by further calculations.
%   

%   roa, 2001-Feb-06
%   $Revision: 1.5 $  $Date: 2002/06/17 13:14:22 $
%   Copyright 1990-2002 The MathWorks, Inc.

allPorts = get_param(startBlk,'PortHandles');
if startInportIdx>length(allPorts.Inport)
    error('simulink:tblpresrc:InvalidIndex',...
        'Invalid input port index (%i) specified for block "%s", which has %i input ports.  Tip: port numbering goes 1,2,3...',...
        startInportIdx,startBlk,length(allPorts.Inport));
else
    endBlk = [];
end
inportH  = allPorts.Inport(startInportIdx);
lineH    = get_param(inportH,'Line');
if ishandle(lineH)
    tracedPort = get_param(lineH,'NonVirtualSrcPorts');
    if length(tracedPort)>0
        tracedPort = tracedPort(1);
    else
        return;
    end
    if ishandle(tracedPort)
        endBlk = get_param(tracedPort,'Parent');
        if ~(strcmp(get_param(endBlk,'BlockType'),'S-Function') && ...
                strcmp(get_param(endBlk,'FunctionName'),'sfun_idxsearch'))
            %source is not a prelookup block
            endBlk = [];
        end
    end
end