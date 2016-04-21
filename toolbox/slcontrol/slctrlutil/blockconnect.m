function [SrcBlocks,DstBlocks,hiddenbuff] = blockconnect(block,J,varargin);
%% BLOCKCONNECT Display the block connectivity for linear analysis.
%%
%% [src,dst] = BLOCKCONNECT(J) Utility function to display Display the block  
%% connectivity for linear analysis.  The input arguement is the return
%% arguement from the linearize method:
%%
%%                      [sys,J] = linearize(op,io);
%% 


%% Display the block connectivity for linear analysis

%%  Author(s): John Glass
%%  Copyright 1986-2002 The MathWorks, Inc.

%% Initialize hidden buffer flag.  Will return 1 if a hidden buffer is
%% found.
hiddenbuff = 0;

%% Determine whether or not to display
if (nargin == 3)
    display = 1;
else 
    display = 0;
end

%% Convert to a block handle if needed
if ischar(block)
    block = get_param(block,'Handle');
end

%% Initialize Variables
BlockHandles = J.Mi.BlockHandles;

%% Find the block index in the list
ind = find(block == J.Mi.BlockHandles);

%% Compute the number of inputs and outputs
nu = size(J.D,2);
ny = size(J.D,1);

%% Compute the input and output index vectors
InputIdx = [J.Mi.InputIdx+1;nu+1];
OutputIdx = [J.Mi.OutputIdx+1;ny+1];

%% Construct the input to block list
InputList = [];
for ct = 1:(length(InputIdx)-1)
    if (InputIdx(ct) ~= InputIdx(ct+1))
        InputList = [InputList;BlockHandles(ct)*ones(InputIdx(ct+1)-InputIdx(ct),1)];        
    end
end

%% Construct the output to block list
OutputList = [];
for ct = 1:(length(OutputIdx)-1)
    if (OutputIdx(ct) ~= OutputIdx(ct+1))
        OutputList = [OutputList;BlockHandles(ct)*ones(OutputIdx(ct+1)-OutputIdx(ct),1)];        
    end
end
    
%% Start with the inputs
InputStart = InputIdx(ind);
InputEnd   = InputIdx(ind+1);

%% Use the E matrix to find the sources
SrcBlocks = [];
if (InputStart ~= InputEnd)
    for ct1 = InputStart:(InputEnd-1)
        for ct2 = 1:size(J.Mi.E,2)
            if J.Mi.E(ct1,ct2)
                %% Make sure that block handle is valid
                try
                    parent = get_param(OutputList(ct2),'Parent');     
                    SrcBlocks = [SrcBlocks;OutputList(ct2)];
                catch
                    hiddenbuff = 1;
                end                
            end
        end
    end
end
    
%% Display the results
if display
    disp(sprintf('\n The block %s',get_param(block,'Name')))
    disp(sprintf('Sources: '));
    blocks = get_param(SrcBlocks,'Name');
    
    if isempty(SrcBlocks)
        disp(sprintf('  - No Sources\n'));
    elseif iscell(blocks)
        disp(sprintf('  - %s\n',blocks{:}))
    else
        disp(sprintf('  - %s\n',blocks))
    end
end

OutputStart = OutputIdx(ind);
OutputEnd   = OutputIdx(ind+1);

%% Use the E matrix to find the sources
DstBlocks = [];
if (OutputStart ~= OutputEnd)
    for ct1 = OutputStart:(OutputEnd-1)
        for ct2 = 1:size(J.Mi.E,1)
            if J.Mi.E(ct2,ct1)
                %% Make sure that block handle is valid
                try
                    parent = get_param(InputList(ct2),'Parent');     
                    DstBlocks = [DstBlocks;InputList(ct2)];
                catch
                    hiddenbuff = 1;
                end   
            end
        end
    end
end

%% Next the outputs
if display
    OutputStart = OutputIdx(ind);
    OutputEnd   = OutputIdx(ind+1);
    disp(sprintf('Destinations: '));
    blocks = get_param(DstBlocks,'Name');
    
    if isempty(DstBlocks)
        disp(sprintf('  - No Destinations\n'));
    elseif iscell(blocks)
        disp(sprintf('  - %s\n',blocks{:}))
    else
        disp(sprintf('  - %s\n',blocks))
    end
end