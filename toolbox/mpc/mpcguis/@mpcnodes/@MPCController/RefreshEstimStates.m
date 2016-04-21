function RefreshEstimStates(this)

% Update the displays on the estimation panels based on the info
% stored in the MPCController properties

%	Copyright 1986-2004 The MathWorks, Inc.
%	$Revision: 1.1.6.3 $  $Date: 2004/04/10 23:35:45 $
%   Author:  Larry Ricker

global MPC_ESTIM_REFRESH_ENABLED

import com.mathworks.toolbox.mpc.*;
import com.mathworks.mwswing.*;
import javax.swing.*;
import java.awt.*;

if ~MPC_ESTIM_REFRESH_ENABLED
    % Prevents refresh when flag is set by setDefaultEstimator method
    return
end

if this.DefaultEstimator
    Status = 'Estimation parameters:  MPC defaults  ';
else
    Status = 'Estimation parameters:  user-specified';
end
SwingUtilities.invokeLater(MLthread(this.Handles.StatusMessage, ...
    'setText', {java.lang.String(Status)}));
for Index = 1:3
    Handles = this.Handles.eHandles(Index);
    ModelUsed = this.EstimData(Index).ModelUsed;
    ModelName = this.EstimData(Index).ModelName;
    SwingUtilities.invokeLater(MLthread(Handles.TextField, 'setText', ...
        {java.lang.String(ModelName)}));
    if ModelUsed
        CurrentView = java.lang.String('Model');        
    else
        CurrentView = java.lang.String('Signal');
    end
    SwingUtilities.invokeLater(MLthread(Handles.GraphLayout,'show', ...
        {Handles.GraphLayers, CurrentView}))
    setJavaLogical(Handles.rbSignal,'setSelected',~ModelUsed)
    setJavaLogical(Handles.UDD.Table,'setVisible',~ModelUsed);
    setJavaLogical(Handles.TextField,'setEnabled',ModelUsed);
    setJavaLogical(Handles.Button,'setEnabled',ModelUsed);
end
