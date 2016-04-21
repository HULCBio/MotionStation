function newio = getblocklinio(model,block)
% GETBLOCKLINIO Computes the linearization IO for a block specified by a
% user.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/03/24 21:09:55 $

%% Get the new IO for block linearization
newio = [];
%% Get ready to create the I/O required for linearization
hio = LinearizationObjects.LinearizationIO;
%% Set the Block and PortNumber properties
hio.Type = 'out';
%% Get the full block name
ph = block.PortHandles;
%% Block must either have an inport of outport
ph = [ph.Inport ph.Outport];
if isempty(ph)
    error('slcontrol:InvalidBlocktoLinearize', ...
        sprintf('The block %s must have either an input or output data port',...
                    getfullname(block.handle)))
end
hio.Block = get_param(ph(1),'Parent');
%% Set the openloop property to be on
hio.OpenLoop = 'on';
%% Loop over each outport
for ct = 1:length(block.PortHandles.Outport)
    hio.PortNumber = ct;
    hio.Description = sprintf('%d',ct);
    newio = [newio;hio.copy];
end
%% Get the source block
hio.Type = 'in';
%% Loop over each input
for ct = 1:length(block.PortHandles.Inport)
    SourceBlock = get_param(block.PortConnectivity(ct).SrcBlock,'Object');
    SourcePort = block.PortConnectivity(ct).SrcPort + 1;
    if (SourcePort <= length(SourceBlock.PortHandles.Outport))
        hio.Block = get_param(SourceBlock.PortHandles.Outport(SourcePort),'Parent');
    else
        error('slcontrol:InvalidBlocktoLinearizeDrivenbyStatePort', ...
        sprintf('The block %s must must only be driven by data ports to be linearized.',...
                    getfullname(block.handle)))                
    end
    %% Get the source port
    hio.PortNumber = SourcePort;
    hio.Description = sprintf('%d',ct);
    newio = [newio;hio.copy];
end