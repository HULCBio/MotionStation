function f = getValidBlocks(this);
%getValidBlocks

%  Author(s): John Glass
%  Copyright 1986-2003 The MathWorks, Inc.

%% TODO: Need to check also for SISO blocks
import java.lang.* java.awt.* javax.swing.*;

%% Find all LTI blocks in the Simulink model
ValidBlocksLTI = find_system(this.Model,'MaskType','LTI Block');
ValidBlocksTF = find_system(this.Model,'BlockType','TransferFcn');
ValidBlocksSS = find_system(this.Model,'BlockType','StateSpace');

ValidBlocks = [ValidBlocksLTI;ValidBlocksTF;ValidBlocksSS];

%% Store references to the valid blocks for later
ValidBlockStorage = cell(length(ValidBlocks),2);
ValidBlockStorage(:,1) = get_param(ValidBlocks,'Handle');
this.ValidBlocks = ValidBlockStorage;

MaskValueString = get_param(ValidBlocks,'MaskValueString');

if length(ValidBlocks) > 0
    f = javaArray('java.lang.Object',length(ValidBlocks),2);
    
    for ct = 1:length(ValidBlocks)
        f(ct,1) = java.lang.Boolean(0);
        f(ct,2) = String(regexprep(ValidBlocks{ct},'\n',' '));
    end
else
    f = javaArray('java.lang.Object',1,2);
    f(1,1) = java.lang.Boolean(0);
    f(1,2) = String('There are no valid blocks in the model');
end