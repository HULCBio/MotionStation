function setDefaultEstimator(this)

% Get an MPC object containing the default estimator and set the
% estimator gui displays accordingly.

%	Copyright 1986-2004 The MathWorks, Inc.
%	$Revision: 1.1.6.3 $  $Date: 2004/04/10 23:35:52 $
%   Author:  Larry Ricker

global MPC_ESTIM_REFRESH_ENABLED

MPC_ESTIM_REFRESH_ENABLED = false;
S = this.getRoot;
Frame = S.Frame;
mpcCursor(Frame, 'wait'); 
ODsize = this.Handles.eHandles(1).UDD.CellData;
Nsize = this.Handles.eHandles(3).UDD.CellData;

[NumMV, NumMD, NumUD, NumMO, NumUO, NumIn, NumOut] = getMPCsizes(S);
if ~ this.DefaultEstimator
    this.HasUpdated = true;
    this.DefaultEstimator = true;
end
Obj = this.getController;
Slider = this.Handles.GainUDD;
Slider.Value = 0.5;
Nsize(:,3) = {'White'}; 
Nsize(:,4) = {'1.0'};
if isempty(Obj)
    % Possible that no mpc object could be created for given plant model
    Channels = [];
else
    [OutDist, Channels] = getoutdist(Obj);
end

for i = 1:NumOut
    if any(i == S.iMO)
        % Output is measured
        if any(i == Channels)
            ODsize{i,3} = 'Steps';
            ODsize{i,4} = '1.0';
        else
            ODsize{i,3} = 'White';
            ODsize{i,4} = '0.0';
        end
    else
        % Output is unmeasured.  Don't allow an output disturbance.
        if any(i == Channels)
            error('mpctool:controller:unexpected integrator', ...
                sprintf('Unexpected integrator on unmeasured output "%i"', ...
                i));
        else
            ODsize{i,3} = 'White';
            ODsize{i,4} = '0.0';
        end
    end
end

this.Handles.eHandles(1).UDD.setCellData(ODsize);
this.Handles.eHandles(3).UDD.setCellData(Nsize);

if NumUD > 0
    IDsize = this.Handles.eHandles(2).UDD.CellData;
    if isempty(Obj)
        % if object couldn't be created
        Den = cell(NumUD,NumUD);
    else
        InDist = getindist(Obj);
        Den = InDist.den;
    end
    for i = 1:NumUD
        if length(Den{i,i}) == 2
            IDsize{i,3} = 'Steps';
            IDsize{i,4} = '1.0';
        else
            IDsize{i,3} = 'White';
            IDsize{i,4} = '0.0';
        end
    end
    this.Handles.eHandles(2).UDD.setCellData(IDsize);
end

% Reset to signal-by-signal mode, and remove model references
for Index = 1:3
    Handles = this.Handles.eHandles(Index);
    this.EstimData(Index).ModelUsed = false;
end
mpcCursor(Frame, 'default');
this.DefaultEstimator = true;
MPC_ESTIM_REFRESH_ENABLED = true;
this.RefreshEstimStates;

