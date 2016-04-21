function bn = addblock(this,blocktype)
%ADDBLOCK  Method to add a time based linearization block for @TimeEvent class

%  Author(s): John Glass
%  Copyright 1986-2003 The MathWorks, Inc.

%% Find a unique name
NewBlockName = sprintf('Simulink Control\n Design Snapshot');

%% Make sure there are no other blocks with this name
AllBlocks = get_param(this.Model,'Blocks');
IndMatch = find(strcmpi(NewBlockName,AllBlocks));
if ~isempty(IndMatch),
    MatchNames = strvcat(AllBlocks{IndMatch});
    strVals = real(MatchNames(:,lenN+1:end));
    strVals(find(strVals(:,1)<48 | strVals(:,1)>57),:)=[];
    MatchNums = zeros(size(strVals,1),1);
    for ctR=1:size(strVals,1),
        MatchNums(ctR,1) = str2double(char(strVals(ctR,:)));
    end
    if ~isnan(MatchNums),
        NextInd = setdiff(1:max(MatchNums)+1,MatchNums);
        NextInd = NextInd(1);
    else
        NextInd=1;
    end

    NewBlockName=[char(NewBlockName),num2str(NextInd)];
else
    NewBlockName=char(NewBlockName);
end

%% Create the block name
bn = sprintf('%s/%s',this.Model,NewBlockName);

%% Add the block
switch blocktype
    case 'opsnapshot'
        add_block('slctrlextras/Operating Point Snapshot',bn, ...
            'SnapshotTimes', mat2str(this.Times), ...
            'Position', [25 15 85 48]);        
end

%% Store the block name 
this.Block = bn;