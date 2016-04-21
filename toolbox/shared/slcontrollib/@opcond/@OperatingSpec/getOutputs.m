function y = getOutputs(this,x,u,varargin);
%% GETOUTPUTS Gets the outputs to the Simulink model including the outputs.  
%%
%% Usage:
%% y = getOutputs(this,x,u);
%%
%% IMPORTANT NOTE: This method assumes that the model is compiled!

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.

%% Get the outputs handle vector.
Outputs = this.Outputs;
y = [];

%% Call the model outputs (This needs to be done so that the proper outputs
%% are computed.  If the model is in Simulation, the outputs are already
%% computed.
if ((nargin == 3) || (~strcmp(varargin{1},'SimulationMode')))
    y_outport = feval(this.model, this.Time, x, u, 'outputs');
end

if ~isempty(Outputs)
    %% Get the output signal UDD block handles
    BlockHandles = get_param(get(Outputs,{'Block'}),'Object');
    PortNumbers = get(Outputs,{'PortNumber'});
    bt = get([BlockHandles{:}],'BlockType');
    
    %% Find the Output Ports
    isOutport = strcmpi(bt,'Outport');
    %% Get their indecies
    Outports = find(isOutport);
    
    %% Compute the outputs
    if ((nargin > 3) && (strcmp(varargin{1},'SimulationMode')))
        y_outport = [];
        outports = find_system(this.model,'SearchDepth',1,'BlockType','Outport');
        for ct = 1:length(outports)
            obj = get_param(outports{ct},'RunTimeObject');
            portdata = obj.InputPort(1);
            y_outport = [y_outport; portdata.Data];
        end
    end
    
    %% Get the blocks that are output ports
    OutportHandles = BlockHandles(Outports);
    OutportNumbersChar = get([OutportHandles{:}],{'Port'});
    
    %% Convert the strings to numbers
    OutportNumbers = ones(size(OutportNumbersChar));
    for ct = 1:length(OutportNumbersChar)
        OutportNumbers(ct) = str2num(OutportNumbersChar{ct});
    end
    
    %% Sort the outports
    [SortedOutportNumbers,OutportRefInd] = sort(OutportNumbers);
    
    %% Create OutputVectorInd which will give an offset for each outport in the
    %% Simulink model.
    OutputVectorOffsetInd = ones(size(OutportNumbersChar));
    for ct = 2:length(SortedOutportNumbers)
        portwidth = this.Outputs(Outports(OutportRefInd(ct-1))).PortWidth;
        OutputVectorOffsetInd(ct) = OutputVectorOffsetInd(ct-1) + portwidth;
    end
    
    %% Loop over each output 
    OutportCount = 1;
    
    for ct1 = 1:length(isOutport)
        if isOutport(ct1)
            %% Compute the offset into the output vector
            offset = OutputVectorOffsetInd(find(OutportCount==OutportRefInd));
            y = [y; y_outport(offset:offset+Outputs(ct1).PortWidth-1)];
            OutportCount = OutportCount + 1;
        else
            %% Get the block and port object handles
            block = get_param(Outputs(ct1).Block,'object');
            port = get_param(block.PortHandles.Outport(Outputs(ct1).PortNumber),'object');
            %% Toggle the engine interface feature setting to be on, save
            %% the previous state.
            old_engine_interface = feature('EngineInterface');
            feature('EngineInterface',1001);
            %% Compute the output and tack it to the end of the outputs.
            blockoutput = port.getOutput;
            if (nargin == 4)
                y = [y; blockoutput.Values];
            else
                y = [y; blockoutput];
            end
            %% Restore the engine interface setting.
            feature('EngineInterface',old_engine_interface);
        end
    end
end