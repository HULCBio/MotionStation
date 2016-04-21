function Panel = getLinearizationInspector(this)
%getLinearizationInspector  

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.

%% Get the Jacobian data
%% Get the index of the selected model
dialog_inter = this.Dialog;
if isempty(dialog_inter)
    J = this.ModelJacobian(1);
else
    J = this.ModelJacobian(dialog_inter.getSelectedModelIndex);
end

%% Create an empty block list
BlockNameList = cell(size(J.Mi.BlockHandles));

A = J.A;
B = J.B;
C = J.C;
D = J.D;

BlockHandles = J.Mi.BlockHandles;
ForwardMark = J.Mi.ForwardMark;
BackwardMark = J.Mi.BackwardMark;
InputIdx = [J.Mi.InputIdx+1;size(B,2)+1];
OutputIdx = [J.Mi.OutputIdx+1;size(C,1)+1];
StateIdx = [J.Mi.StateIdx+1; length(A)+1];
SampleTimes = J.Ts(1:length(A));

HiddenBuffers = [];

for ct = 1:length(BlockNameList)
    try
        BlockNameList{ct} = ...
            [regexprep(get_param(J.Mi.BlockHandles(ct),'Parent'),'\n',' '),'/',...
                regexprep(get_param(J.Mi.BlockHandles(ct),'Name'),'\n',' ')];
    catch
        HiddenBuffers = [HiddenBuffers;ct];        
    end
end

%% Remove references to hidden buffers
BlockNameList(HiddenBuffers) = [];
BlockHandles(HiddenBuffers) = [];
ForwardMark(HiddenBuffers) = [];
BackwardMark(HiddenBuffers) = [];
InputIdx(HiddenBuffers) = [];
OutputIdx(HiddenBuffers) = [];
StateIdx(HiddenBuffers) = [];

%% Sort the block list
[BlockNameList,ind] = sort(BlockNameList);

%% Create empty objects for the tree structure
System = GenericLinearizationNodes.SubsystemMarker;
Block = GenericLinearizationNodes.BlockInspectorLinearization;

%% Tree Creation: Find the unique subsystem parents
UniqueParents = unique(regexprep(get_param(BlockHandles,'Parent'),'\n',' '));
Parents = regexprep(get_param(BlockHandles,'Parent'),'\n',' ');
BlockList = regexprep(get_param(BlockHandles,'Name'),'\n',' ');

%% Tree Creation: Create their node objects
root = [];
for ct = 1:length(UniqueParents)
    root = [root; System.copy];
        
    %% Find its direct parent
    if (ct == 1)
        ParentInd = 1;
        root(ct).Label = UniqueParents{ct};
    else
        for ct2 = (ct-1):-1:1
            if ~isempty(regexp(UniqueParents{ct},UniqueParents{ct2}));
                ParentInd = ct2;
                root(ct).Label = regexprep(UniqueParents{ct},[UniqueParents{ct2},'/'],'');
                break;
            end
        end
        connect(root(ct), root(ParentInd), 'up');
    end    
    
    %% Find the blocks that are direct children
    ind = find(strcmp(Parents,UniqueParents{ct}));
    
    %% Diagnostic
    if 0
        disp(sprintf('Subsystem %s has the blocks \n',root(ct).Name))
        disp(sprintf('And has a parent: %s \n',root(ParentInd).Name))
        disp(sprintf('%s \n',BlockList{ind}))
    end
    %% Create objects to be parented to the subsystem 
    ChildBlocks = [];
    for ct2 = 1:length(ind)
        ChildBlocks = [ChildBlocks; Block.copy];
%         ChildBlocks(ct2).Block = BlockList{ind(ct2)};
        %% Store the blocks in the subsystem node
        root(ct).Blocks = ChildBlocks;
        
        if (StateIdx(ind(ct2)) ~= StateIdx(ind(ct2)+1))
            indx = [StateIdx(ind(ct2)):(StateIdx(ind(ct2)+1)-1)];
        else
            indx = [];
        end
        if (InputIdx(ind(ct2)) ~= InputIdx(ind(ct2)+1))
            indu = [InputIdx(ind(ct2)):(InputIdx(ind(ct2)+1)-1)];
        else
            indu = [];
        end
        if (OutputIdx(ind(ct2)) ~= OutputIdx(ind(ct2)+1))
            indy = [OutputIdx(ind(ct2)):(OutputIdx(ind(ct2)+1)-1)];
        else
            indy = [];
        end
        ChildBlocks(ct2).A = full(A(indx,indx));
        ChildBlocks(ct2).B = full(B(indx,indu));
        ChildBlocks(ct2).C = full(C(indy,indx));
        ChildBlocks(ct2).D = full(D(indy,indu));
        ChildBlocks(ct2).SampleTimes = SampleTimes(indx); 
        ChildBlocks(ct2).InLinearizationPath = ForwardMark(ind(ct2)) && BackwardMark(ind(ct2));
        ChildBlocks(ct2).FullBlockName = [Parents{ind(ct2)},'/',BlockList{ind(ct2)}];
    end
end

%% Create the panel
import com.mathworks.toolbox.control.explorer.*
Panel = ExplorerPanel(root(1));

% root(1).IsRoot = 1;
this.Inspector = root(1);
