function HiliteBlocksInLinearization(this);

% Copyright 2003 The MathWorks, Inc.

J = this.ModelJacobian(1);

%% Create an empty block list
BlockNameList = cell(size(J.Mi.BlockHandles));

BlockHandles = J.Mi.BlockHandles;
ForwardMark = J.Mi.ForwardMark;
BackwardMark = J.Mi.BackwardMark;
HiddenBuffers = [];

%% Remove blocks that are no longer in the model
for ct = 1:length(BlockNameList)
    try
        BlockNameList{ct} = ...
            [regexprep(get_param(J.Mi.BlockHandles(ct),'Parent'),'\n',' '),'/',...
                regexprep(get_param(J.Mi.BlockHandles(ct),'Name'),'\n',' ')];
    catch
        HiddenBuffers = [HiddenBuffers;ct];        
    end
end

%% Get the list of blocks that are in the model
BlockHandles(HiddenBuffers) = [];
ForwardMark(HiddenBuffers) = [];
BackwardMark(HiddenBuffers) = [];

%% Find the blocks that are in the linearization path
BlockHandles = BlockHandles(find((BackwardMark & ForwardMark) == 1));

%% Get all the blocks in the model and turn them to fade
all_blocks = find_system(this.Model);
%% Get the double handle version of the list of blocks and convert it to a
%% matrix
all_blocks_double_cell = get_param(all_blocks,'handle');
all_blocks_double = [all_blocks_double_cell{:}];

% for ct = 1:length(all_blocks)
%     set_param(all_blocks{ct},'HiliteAncestors','fade');
% end

%% Hilite the blocks in the linearization
% size(BlockHandles)
% for ct = 1:length(BlockHandles)
%     set_param(BlockHandles(ct),'HiliteAncestors','none');
% end

for ct = 1:length(BlockHandles)
    ind = find(BlockHandles(ct) == all_blocks_double);
    all_blocks_double(ind) = [];
end

%hilite_system(all_blocks_double,'fade')
hilite_system(BlockHandles,'find');
%% Fade all the blocks not in the linearization
% for ct = 1:length(all_blocks_double)
%     set_param(all_blocks_double(ct),'HiliteAncestors','fade');
% end
% 
% for ct = 1:length(BlockHandles)
%     set_param(BlockHandles(ct),'HiliteAncestors','none');
% end
% 
% 
% 
