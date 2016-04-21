function [sysp,sysc] = getlinplant(block,op,varargin);
%GETLINPLANT Compute open loop plant model from Simulink diagram.
%
%  [SYSP,SYSC] = GETLINPLANT(BLOCK,OP) Computes the open loop plant seen
%  by a Simulink block labeled BLOCK.  The plant model, SYSP, and linearized 
%  block, SYSC, returned is linearized at an operating point OP.
%
%  SLSISODESIGN(BLOCK,OP,OPTIONS) Computes the open loop plant seen
%  by a Simulink block labeled BLOCK.  The linearizations are computed
%  using the options specified in OPTIONS.
%  
%  See also OPERPOINT, OPERSPEC, FINDOP, LINOPTIONS

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/19 01:32:10 $

%% Parse the input arguements
nargchk(2,3,nargin);

%% Get the UDD block handle
bh = get_param(block,'Object');

%% Create the input points
for ct = length(bh.PortHandles.Outport):-1:1
    hin(ct) = linio(getfullname(bh.handle),ct,'in');
end

%% Get the source block ports
for ct = length(bh.PortHandles.Inport):-1:1
    SourceBlock = getfullname(get_param(bh.PortConnectivity(ct).SrcBlock,'Handle'));
    hout(ct) = linio(SourceBlock,bh.PortConnectivity(ct).SrcPort + 1,'out','on');
end

%% Compute the open loop plant model
sysp = linearize(op.Model,op,[hin,hout]);

%% Now set the IO Names for the outputs to match that of the ports
OutputNames = sysp.OutputNames;

for ct = length(bh.PortHandles.Inport):-1:1
    SourceBlock = getfullname(get_param(bh.PortConnectivity(ct).SrcBlock,'Handle'));
    %% Remove carriage returns
    SourceBlock = regexprep(SourceBlock,'\n',' ');
    SourcePort = bh.PortConnectivity(ct).SrcPort+1;
    %% Handle the single channel case first
    SourcePortName = sprintf('%s (%d)',SourceBlock,SourcePort);
    ind = find(strncmp(SourcePortName,OutputNames,length(SourcePortName)));
    if isempty(ind)
        %% If the port is multiple channels get the indecies
        SourcePortName = sprintf('%s (pout %d)',SourceBlock,SourcePort);
        ind = find(strncmp(SourcePortName,OutputNames,length(SourcePortName)));
    end
    BlockName = regexprep(bh.Name,'\n',' ');
    OutputNames{ind} = sprintf('%s (%d)',BlockName,ct);
end
sysp.OutputNames = OutputNames;

%% Compute the controller linearization
sysc = linearize(op.Model,op,block);