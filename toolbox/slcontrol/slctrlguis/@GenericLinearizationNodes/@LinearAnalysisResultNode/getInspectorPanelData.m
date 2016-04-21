function rootnode = getInspectorPanelData(this);
%GETINSPECTORPANELDATA

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2004/04/11 00:35:40 $

import javax.swing.*;

%% Get the Jacobian data.  It is assumed and is the case that the Jacobian
%% structure will always be the same.  Only A,B,C,D will be different.
J = this.ModelJacobian;
J1 = J(1);

%% Create an empty block list
BlockNameList = cell(size(J1.Mi.BlockHandles));

%% Get the block handles and the other information such as sample time.
BlockHandles = J1.Mi.BlockHandles;
ForwardMark = J1.Mi.ForwardMark;
BackwardMark = J1.Mi.BackwardMark;
InputIdx = [J1.Mi.InputIdx+1;size(J1.B,2)+1];
OutputIdx = [J1.Mi.OutputIdx+1;size(J1.C,1)+1];
StateIdx = [J1.Mi.StateIdx+1; length(J1.A)+1];
SampleTimes = J1.Ts(1:length(J1.A));

%% Find the hidden buffers and remove carriage
HiddenBuffers = [];
for ct = 1:length(BlockNameList)
    try
        BlockNameList{ct} = regexprep(getfullname(J1.Mi.BlockHandles(ct)),'\n',' ');
    catch
        HiddenBuffers = [HiddenBuffers;ct];
    end
end

%% Remove references to hidden buffers
BlockNameList(HiddenBuffers) = [];
BlockHandles(HiddenBuffers) = [];
ForwardMark(HiddenBuffers) = [];
BackwardMark(HiddenBuffers) = [];

%% Sort the block list
[BlockNameList,ind] = sort(BlockNameList);

%% Create empty objects for the tree structure
Block = GenericLinearizationNodes.BlockInspectorLinearization;

%% Tree Creation: Find the unique subsystem parents
UniqueParents = unique(regexprep(find_system(this.Model,...
    'FollowLinks','on','LookUnderMasks','all',...
    'BlockType','SubSystem'),'\n',' '));
UniqueParents = {this.model,UniqueParents{:}};
Parents = regexprep(get_param(BlockHandles,'Parent'),'\n',' ');
BlockList = regexprep(get_param(BlockHandles,'Name'),'\n',' ');

%% Tree Creation: Create their node objects
root = [];
for ct = 1:length(UniqueParents)
    if ct == 1;
        root = GenericLinearizationNodes.SubsystemMarker('root');
    else
        root = [root; GenericLinearizationNodes.SubsystemMarker('sdaf')];
    end

    %% Find its direct parent
    if (ct == 1)
        ParentInd = 1;
        root(ct).Label = UniqueParents{ct};
    else
        %% Get the subsystem's parent
        SSParent = regexprep(get_param(UniqueParents{ct},'Parent'),'\n',' ');
        ParentInd = find(strcmp(SSParent,UniqueParents));
        %% Get the label
        root(ct).Label = get_param(UniqueParents{ct},'Name');
        %% Connect the subsystem to its parent
        connect(root(ct), root(ParentInd), 'up');
    end

    %% Find the blocks that are direct children
    ind = find(strcmp(Parents,UniqueParents{ct}));

    %% Create objects to be parented to the subsystem
    ChildBlocks = [];
    for ct2 = 1:length(ind)
        ChildBlocks = [ChildBlocks; Block.copy];

        %% Find the index in the original list
        ind_original = find(J1.Mi.BlockHandles == BlockHandles(ind(ct2)));

        if (StateIdx(ind_original) ~= StateIdx(ind_original+1))
            indx = [StateIdx(ind_original):(StateIdx(ind_original+1)-1)];
        else
            indx = [];
        end
        if (InputIdx(ind_original) ~= InputIdx(ind_original+1))
            indu = [InputIdx(ind_original):(InputIdx(ind_original+1)-1)];
        else
            indu = [];
        end
        if (OutputIdx(ind_original) ~= OutputIdx(ind_original+1))
            indy = [OutputIdx(ind_original):(OutputIdx(ind_original+1)-1)];
        else
            indy = [];
        end
        
        %% Store the sample times
        ChildBlocks(ct2).DiscardUpdate = false;
        ChildBlocks(ct2).SampleTimes = SampleTimes(indx);
        if ForwardMark(ind(ct2)) && BackwardMark(ind(ct2))
            ChildBlocks(ct2).InLinearizationPath = 'Yes';
            %% Store each of the block's linearizations
            ChildBlocks(ct2).setAllABCD(J,indx,indu,indy);
        else
            ChildBlocks(ct2).InLinearizationPath = 'No';
        end
        ChildBlocks(ct2).FullBlockName = getfullname(BlockHandles(ind(ct2)));
        ChildBlocks(ct2).DiscardUpdate = true;
    end
    %% Create an empty default list model
    ListObject = DefaultListModel;

    %% Store the blocks in the subsystem node
    root(ct).Blocks = ChildBlocks;

    %% Add all blocks to the list
    for ct3 = 1:length(ChildBlocks)
        ListObject.addElement(get_param(ChildBlocks(ct3).FullBlockName,'Name'));
    end
    root(ct).BlockList = ListObject;
end

%% Set the panel information
this.InspectorNode = root(1);
