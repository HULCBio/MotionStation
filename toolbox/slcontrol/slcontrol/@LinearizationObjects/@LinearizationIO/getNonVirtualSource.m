function blockinfo = getNonVirtualSource(this);
%% Get the non-virual source blocks and their indicies.  
%%
%% Returns a cell array with the following entries
%% { Source Block, Source Block Output Port Index, 
%%      Output Port Signal Index, Source PortHandle, Original Signal Index }
%% All values returned are in Matlab indicies not C indicies.
%%
%% IMPORTANT NOTE: This method assumes that the model is compiled!

%% ToDo: None

%%  Author(s): John Glass
%%  Copyright 1986-2003 The MathWorks, Inc.

%% Get the block that the linearization point is at
block = get_param(this.Block,'Object');
%% Initialize the port number
portnumber = this.PortNumber;
%% Get the model name
FullName = block.getFullName;
ind = regexp(FullName,'/');
model =  FullName(1:ind(1)-1);
%% Get the port that the linearization point is at
port = get_param(block.PortHandles.Outport(portnumber),'Object');
%% Get the dimension of the linearization signal
signalwidth = port.CompiledPortWidth;
%% Create an empty block information cell array
blockinfo = cell(signalwidth,5);

%% Major loop over all signals in the linearization
for ct = 1:signalwidth
    srcblock = block;
    srcportnumber = portnumber;
    ind = ct;
    %% Initialize bus signal name to empty 
    busname = '';
    %% Initialize bus signal index to NaN
    busindex = NaN;
    while (isa(srcblock,'Simulink.Demux') || isa(srcblock,'Simulink.Mux') || ...
               isa(srcblock,'Simulink.SubSystem') || ...
               (isa(srcblock,'Simulink.Inport') && ~strcmp(srcblock.Parent,model)) || ...
               isa(srcblock,'Simulink.BusSelector')  || ...
               isa(srcblock,'Simulink.BusCreator') || ...
               isa(srcblock,'Simulink.Selector') || ...
               isa(srcblock,'Simulink.From')) 
        %% Deal with the Demux case
        if isa(srcblock,'Simulink.Demux')
            [srcblock,srcportnumber,ind] = LocalGetDemuxSource(srcblock,srcportnumber,ind);
        elseif isa(srcblock,'Simulink.Mux')
            [srcblock,srcportnumber,ind] = LocalGetMuxSource(srcblock,srcportnumber,ind); 
        elseif isa(srcblock,'Simulink.SubSystem')
            [srcblock,srcportnumber,ind] = LocalGetSubSystemSource(srcblock,srcportnumber,ind); 
        elseif (isa(srcblock,'Simulink.Inport') && ~strcmp(srcblock.Parent,model))    
            [srcblock,srcportnumber,ind] = LocalGetSubSystemInportSource(srcblock,srcportnumber,ind); 
        elseif isa(srcblock,'Simulink.BusSelector')
            [srcblock,srcportnumber,ind,busname,busindex] = LocalGetBusSelectorSource(srcblock,...
                srcportnumber,ind,busname,busindex);
        elseif isa(srcblock,'Simulink.BusCreator')
            [srcblock,srcportnumber,ind,busname,busindex] = LocalGetBusCreatorSource(srcblock,...
                srcportnumber,ind,busname,busindex);
        elseif isa(srcblock,'Simulink.From')
            [srcblock,srcportnumber,ind] = LocalGetFromSource(srcblock,srcportnumber,ind);
        elseif isa(srcblock,'Simulink.Selector')
            [srcblock,srcportnumber,ind] = LocalGetSelectorSource(srcblock,srcportnumber,ind);
        end
       %% Test Code
       %% disp({ct,srcblock,srcportnumber,ind,busname,busindex})
    end
    blockinfo{ct,1} = [srcblock.Parent,'/',srcblock.Name];
    blockinfo{ct,2} = srcportnumber;
    blockinfo{ct,3} = ind;
    blockinfo{ct,4} = srcblock.PortHandles.Outport(srcportnumber);
    blockinfo{ct,5} = ct;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Demux case
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sourceblock,portnumber,ind] = LocalGetDemuxSource(block,portnumber,ind);
%%
%%                                                     ^
%%      ----           |-|----- signal dimension (3)   |
%%      |  |-----------| |----- signal dimension (2) ---- (Linearized Signal)
%%      ----           |-|----- signal dimension (4)
%%
%%  Source Block   Demux Block
%%
%% In this code we need to find the source block and it's output port.  
%% Also we need to find out which elements that the linearized signal are 
%% contained at the output of the source block.   

%% Get the index of the signal in the source block corresponding to the 
%% linearized signal.
offset = 0;
for ct = 1:portnumber-1
    %% Get the ct'th port width and add it to the offset
    offset = offset + get_param(block.PortHandles.Outport(ct),'CompiledPortWidth');
end

%% Get the source block
sourceblock = get_param(block.PortConnectivity(1).SrcBlock,'Object');
%% Get the port number of the source block 
portnumber = block.PortConnectivity(1).SrcPort+1;
%% Get the offset indecies
ind = ind + offset;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Mux case
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sourceblock,portnumber,ind] = LocalGetMuxSource(block,portnumber,ind);
%%
%%                                                  ^
%%  block 1 |-|----- signal dimension (3) -----|-|  |
%%  block 2 |-|----- signal dimension (2) -----| |---- (Linearized Signal)
%%  block 3 |-|----- signal dimension (4) -----|-|
%%
%%       Source Block                        Mux Block
%%
%% In this code we need to find the source block and it's output port.  
%% Also we need to find out which elements that the linearized signal are 
%% contained at the output of the source block.   

%% Get the index of the signal in the source block corresponding to the 
%% linearized signal.
offset = 0;
for ct = 1:length(block.PortHandles.Inport)
    %% Get the ct'th port width and add it to the offset
    offset = offset + get_param(block.PortHandles.Inport(ct),'CompiledPortWidth');
    if offset >= ind
        ind = ind - (offset - get_param(block.PortHandles.Inport(ct),'CompiledPortWidth'));
        inputport = ct;
        break
    end
end

%% Get the source block
sourceblock = get_param(block.PortConnectivity(ct).SrcBlock,'Object');
%% Get the port number of the source block 
portnumber = block.PortConnectivity(ct).SrcPort+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Subsystem case
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sourceblock,portnumber,ind] = LocalGetSubSystemSource(block,portnumber,ind);
%%
%%       |--------------------------------|   ^
%%   ----|  -------------      ---------  |   |
%%       |  |sourceblock|------|Outport|  |------  Linearized signal
%%   ----|  -------------      ---------  |
%%       |--------------------------------|
%%
%%                  SubSystem                        
%%
%% In this code we need to find the source block and it's output port.  
%% Also we need to find out which elements that the linearized signal are 
%% contained at the output of the source block.  This will require that 
%% we drill into the subsystem to follow the output port to find the first
%% nonvirtual block in its path. 

%% Find the output ports in the subsystem and get the handle to the block
%% that represents the output of the subsystem.
outport = find_system([block.Parent,'/',block.Name],...
                'SearchDepth',1,...
                'FollowLinks','on',...
                'LookUnderMasks','all',...
                'BlockType','Outport',...
                'Port',num2str(portnumber));
outport = get_param(outport,'object');

%% Get the block connected to the outport
%% Get the source block
sourceblock = get_param(outport{1}.PortConnectivity(1).SrcBlock,'Object');
%% Get the port number of the source block 
portnumber = outport{1}.PortConnectivity(1).SrcPort+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Subsystem inport case
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sourceblock,portnumber,ind] = LocalGetSubSystemInportSource(block,portnumber,ind);
%%
%% ------------    |---------------------------|   ^
%% sourceblock|----|  --------      ---------  |   |
%% ------------    |  |Inport|------|Outport|  |------  Linearized signal
%%             ----|  --------      ---------  |
%%                 |---------------------------|
%%
%%                           SubSystem                        
%%
%% In this code we need to find the source block and it's output port.  
%% Also we need to find out which elements that the linearized signal are 
%% contained at the output of the source block.  This will require that 
%% we drill out of the subsystem to follow the output port to find the first
%% nonvirtual block in its path.  

%% Find the output ports in the subsystem and get the handle to the block
%% that represents the output of the subsystem.
subsystemblock = get_param(block.Parent,'Object');
subsystemblockpn = str2num(block.Port);

%% Get the block connected to the outport
%% Get the source block
sourceblock = get_param(subsystemblock.PortConnectivity(subsystemblockpn).SrcBlock,'Object');
%% Get the port number of the source block 
portnumber = subsystemblock.PortConnectivity(subsystemblockpn).SrcPort+1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BusSelctor case
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sourceblock,portnumber,ind,busname,busindex] = LocalGetBusSelectorSource(...
                            block,portnumber,ind,busname,busindex);
%%
%%                                                     ^
%%      ----           |-|----- signal dimension (3)   |
%%      |  |-----------| |----- signal dimension (2) ---- (Linearized Signal)
%%      ----           |-|----- signal dimension (4)
%%
%%  Source Block   BusSelector Block
%%
%% In this code we need to find the source block and it's output port.  
%% Also we need to find out which elements that the linearized signal are 
%% contained at the output of the source block. Another aspect to this design 
%% is that the order of the signals may be changed.  

%% Case 1 - Unknown bus signal name.  First time on a bus.
if isempty(busname)
    %% Case A - If the bus selector is not muxed
    if strcmp(block.MuxedOutput,'off')
        %% Find out which element of the bus that the signal is in.
        busname = block.OutputSignalNames{portnumber};
        %% Remove the < >'s
        busname = busname(2:end-1);
        %% Get the input signal names
        inputnames = block.InputSignals;
        %% Find the index into the signal bus
        busindex = find(strcmp(inputnames,busname));        
    %% Case B - If the bus selector is muxed    
    else
        numberofsignals = block.CompiledPortDimensions.Outport(2);
        offset = 0;
        for ct = 1:numberofsignals
            width = block.CompiledPortDimensions.Outport(2*ct+2);
            offset = offset + width;
            if offset >= ind
                busindex = ct;
                ind = ind - (offset - width);
                break
            end
        end
        %% Parse the block.OutputSignals to find the commas
        commaind = regexp(block.OutputSignals,',');
        if busindex == 1
            busname = block.OutputSignals(1:commaind(1)-1);
        elseif busindex == numberofsignals
            busname = block.OutputSignals(commaind(end)+1:end);
        else
            busname = block.OutputSignals(commaind(busindex-1)+1:commaind(busindex)-1);
        end
        %% Find the bus index related to the input
        busindex = find(strcmp(busname,block.InputSignals));
        if isempty(busindex)
            error('no bus index')
        end
    end   
else
    %% Find the bus index related to the input
    busindex = find(strcmp(busname,block.InputSignals));
end    

%% Get the source block
sourceblock = get_param(block.PortConnectivity(1).SrcBlock,'Object');
%% Get the port number of the source block 
portnumber = block.PortConnectivity(1).SrcPort+1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BusCreator case
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sourceblock,portnumber,ind,busname,busindex] = LocalGetBusCreatorSource(...
                        block,portnumber,ind,busname,busindex);
%%
%%                                                     
%%                                                  ^
%%  block 1 |-|----- signal dimension (3) -----|-|  |
%%  block 2 |-|----- signal dimension (2) -----| |---- (Linearized Signal)
%%  block 3 |-|----- signal dimension (4) -----|-|
%%
%%       Source Blocks                    BusCreator Block
%%
%% In this code we need to find the source block and it's output port.  
%% Also we need to find out which elements that the linearized signal are 
%% contained at the output of the source block. 

%% Case 1 - Unknown bus signal name.  First time on a bus.
if isempty(busname)
    %% Get the number of signals in the bus
    numberofsignals = block.CompiledPortDimensions.Outport(2);
    %% Get the index of the signal in the source block corresponding to the 
    %% linearized signal.
    offset = 0;
    for ct = 1:length(block.PortHandles.Inport)
        %% Get the ct'th port width and add it to the offset
        offset = offset + get_param(block.PortHandles.Inport(ct),'CompiledPortWidth');
        if offset >= ind
            ind = ind - (offset - get_param(block.PortHandles.Inport(ct),'CompiledPortWidth'));
            inputport = ct;
            break
        end
    end
    %% Get the source block
    sourceblock = get_param(block.PortConnectivity(inputport).SrcBlock,'Object');
    %% Get the port number of the source block 
    portnumber = block.PortConnectivity(inputport).SrcPort+1;
else
    %% Get the source block
    sourceblock = get_param(block.PortConnectivity(busindex).SrcBlock,'Object');
    %% Get the port number of the source block 
    portnumber = block.PortConnectivity(busindex).SrcPort+1;
end    

%% Assume that the sources are non-bus signals.  If they are the logic will
%% take care of finding the signal names.
busname = '';
busindex = NaN;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% From block case
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sourceblock,portnumber,ind] = LocalGetFromSource(block,portnumber,ind);
%%
%% In this code we need to find the source block and it's output port.

%% Find the goto block 
gotoblock = get_param(block.GotoBlock.name,'object');
%% Find the source port
sourceblock = get_param(gotoblock.PortConnectivity.SrcBlock,'Object');
portnumber = gotoblock.PortConnectivity.SrcPort + 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Selector block case
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sourceblock,portnumber,ind] = LocalGetSelectorSource(block,portnumber,ind);
%%
%% In this code we need to find the source block and it's output port.

%% Find the new index 
elements = str2num(block.elements);
ind = elements(ind);
%% Find the source port
sourceblock = get_param(block.PortConnectivity(1).SrcBlock,'Object');
portnumber = block.PortConnectivity(1).SrcPort + 1;