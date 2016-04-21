function setBlockingEnabledState(this)

%  setBlockingEnabledState(this)
%
% Set certain MPCController dialog elements to enabled/disabled state, depending
% on whether or not blocking is on.

%	Copyright 1986-2003 The MathWorks, Inc. 
%	$Revision: 1.1.8.3 $  $Date: 2004/04/19 01:16:25 $
%   Author:  Larry Ricker

import com.mathworks.toolbox.mpc.*;
import javax.swing.*;

BlockingOn = this.Handles.Buttons.blockingCB.isSelected;
yesBlocks = this.Handles.Buttons.yesBlocks;
noBlocks = this.Handles.Buttons.noBlocks;
for i=1:length(noBlocks)
    SwingUtilities.invokeLater(MLthread(noBlocks(i),'setEnabled', ...
        {~BlockingOn},'boolean'));
end

% Dialog state also depends on whether or not custom allocation is selected
if BlockingOn
    if this.Handles.Buttons.blkCombo.getSelectedIndex == 3
        % Custom allocation.
        j_no = [1 2];
        j_yes = [3 4 5 6];
    else
        % Not custom
        j_no = [5 6];
        j_yes = [1 2 3 4];
    end
    for i=j_no
        SwingUtilities.invokeLater(MLthread(yesBlocks(i),'setEnabled', ...
            {~BlockingOn},'boolean'));
    end
    for i=j_yes
        SwingUtilities.invokeLater(MLthread(yesBlocks(i),'setEnabled', ...
            {BlockingOn},'boolean'));
    end
else
    % Turn off all the blocking entries
    for i=1:length(yesBlocks)
        SwingUtilities.invokeLater(MLthread(yesBlocks(i),'setEnabled', ...
            {BlockingOn},'boolean'));
    end
end
this.Blocking = BlockingOn;
