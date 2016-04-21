function addController(this,Name,MPCobj)

% addController(this,Name,MPCobj)
%
% Add a new controller node.  "this" is the MPCControllers node.
% If Name and MPCobj are specified, new controller is to be
% created with specified name and properties of the specified
% mpc object.

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.10 $ $Date: 2004/04/10 23:35:57 $

global MPC_ESTIM_REFRESH_ENABLED

S = this.up;  % Points to the MPCGUI node

if nargin == 1
    Name = 'MPC1';
    Num = 2;
    Controllers = this.getChildren;
    while ~isempty(Controllers.find('Label',Name))
        Name = sprintf('MPC%i', Num);
        Num = Num + 1;
    end
else
    if nargin == 3 && S.ModelImported
        % Make sure the MPCobj size is compatible
        NumIn = length(MPCobj.Model.Plant.InputName);
        NumOut = length(MPCobj.Model.Plant.OutputName);
        if NumIn ~= S.Sizes(6) || NumOut ~= S.Sizes(7)
            Msg = sprintf(['Controllers designed or imported', ...
                ' previously use %i plant input(s) and', ...
                ' %i plant output(s).\n\n', ...
                'Controller "%s" is designed for %i plant ', ...
                'input(s) and %i plant output(s).', ...
                '\n\nImport of controller "%s" aborted.'], ...
                S.Sizes(6), S.Sizes(7), Name, NumIn, NumOut,  Name);
            uiwait(errordlg(Msg, 'MPC Controller Size Conflict', 'modal'));
            LocalUpdateStatus(S, '');
            return
        end
    end
    % Make sure the name is unique
    Children = this.getChildren;
    if ~isempty(Children)
        isValid = false;
        while ~isValid
            ExistingController = Children.find('Label',Name);
            if ~isempty(ExistingController)
                Message = sprintf(['Name "%s" is ', ...
                    'already in use.  Choose another.\n'], Name);
                OldName = Name;
                Name = char(inputdlg({Message}, 'MPC Input', 1, {Name}));
                if isempty(Name) || length(Name) <= 0
                    % User cancelled, so return
                    LocalUpdateStatus(S, '');
                    LocalUpdateText(S, sprintf('Import of "%s" cancelled', ...
                        OldName));
                    return
                end
            else
                isValid = true;
            end
        end
    end
end

% If we get here, a valid name was assigned.  Create the node.
LocalUpdateStatus(S, sprintf('Adding "%s" to the explorer tree', Name));
this.addNode(mpcnodes.MPCController(Name));
LocalUpdateText(S, sprintf('Controller "%s" added to task "%s"', ...
    Name, S.Label));
New = this.getChildren.find('Label', Name);
New.setIOdata(S);
MPCModels = S.getMPCModels;
if nargin < 3
    % If no MPCobj has been supplied ...
    % Default to first model in list
    New.ModelName = MPCModels.Labels{1};
    New.Model = MPCModels.Models(1);
    LocalUpdateStatus(S, 'Initializing controller settings');
    New.getDialogInterface(S.TreeManager);
else
    % MPCobj has been supplied.  Use its properties to initialize
    % the node.
    MPC_ESTIM_REFRESH_ENABLED = false;
    New.MPCobject = MPCobj;
    New.ModelName = [Name,'_Plant'];
    Struc.name = New.ModelName;
    LocalUpdateText(S, sprintf('Adding "%s" to plant models list', ...
        New.ModelName));
    New.getMPCModels.addModelToList(Struc, MPCobj.Model.Plant);
    New.Model = mpcnodes.MPCModel(New.ModelName, MPCobj.Model.Plant);
    LocalUpdateStatus(S, 'Initializing controller settings');
    Panel = New.getDialogInterface(this.up.TreeManager);
    New.Dialog = Panel;
    Nominal = MPCobj.Model.Nominal;
    if ~isempty(Nominal)
        if ~isempty(Nominal.U)
            S.InUDD.CellData(:,5) = cellstr(num2str(Nominal.U(:)));
        end
        if ~isempty(Nominal.Y)
            S.OutUDD.CellData(:,5) = cellstr(num2str(Nominal.Y(:)));
        end
    end
    
    New.Ts = num2str(MPCobj.Ts);
    New.P = num2str(MPCobj.PredictionHorizon);
    if length(MPCobj.ControlHorizon) > 1
        New.Blocking = 1;
        New.M = int2str(length(MPCobj.ControlHorizon));
        New.BlockMoves = New.M;
        New.BlockAllocation = 'Custom';
        New.CustomAllocation = ['[ ',num2str(MPCobj.ControlHorizon),' ]'];
    else
        New.Blocking = 0;
        New.M = num2str(MPCobj.ControlHorizon);
        New.BlockMoves = '3';
        New.BlockAllocation = 'Beginning';
        New.CustomAllocation = '[ 2 3 5 ]';
    end
    
    ULimits = New.Handles.ULimits.CellData;
    [NumMV,x] = size(ULimits);
    YLimits = New.Handles.YLimits.CellData;
    [NumOV,x] = size(YLimits);
    Uwts = New.Handles.Uwts.CellData;
    Ywts = New.Handles.Ywts.CellData;
    Usoft = New.Handles.Usoft.CellData;
    Ysoft = New.Handles.Ysoft.CellData;
    ODspecs = New.Handles.eHandles(1).UDD.CellData;
    IDspecs = New.Handles.eHandles(2).UDD.CellData;
    Nspecs = New.Handles.eHandles(3).UDD.CellData;
    estimdata = New.estimdata;
    
    New.Handles.TrackingUDD.Value = 0.8;
    MaxWt = max([max(MPCobj.Weights.ManipulatedVariables), ...
            max(MPCobj.Weights.ManipulatedVariablesRate), ...
            max(MPCobj.Weights.OutputVariables)]);
    New.Handles.HardnessUDD.Value = (3/28)*(log10(MPCobj.Weights.ECR/MaxWt) + 2);
    New.Handles.GainUDD.Value = 0.5;
        
    DefaultEstimator = true;
    Task = this.getRoot.Label;
    MPCdata=getmpcdata(MPCobj);
    UserModelFlag=MPCdata.OutDistFlag;
    if UserModelFlag
        estimdata(1).ModelUsed = 1;
        New.Handles.eHandles(1).rbModel.setSelected(true);
        estimdata(1).Model = MPCdata.OutDistModel;
        estimdata(1).ModelName = ['From:  ', Task];
        DefaultEstimator = false;
    else
        estimdata(1).ModelUsed = 0;
    end
    
    NumUD = size(IDspecs, 1);
    if NumUD > 0
        if isempty(MPCobj.Model.Disturbance)
            estimdata(2).ModelUsed = 0;
        else
            estimdata(2).ModelUsed = 1;
            New.Handles.eHandles(2).rbModel.setSelected(true);
            estimdata(2).Model = MPCobj.Model.Disturbance;
            estimdata(2).ModelName = ['From:  ', Task];
            DefaultEstimator = false;
        end
    end
    if ~isempty(MPCobj.Model.Noise)
        estimdata(3).ModelUsed = 1;
        New.Handles.eHandles(3).rbModel.setSelected(true);
        estimdata(3).Model = MPCobj.Model.Noise;
        estimdata(3).ModelName = ['From:  ', Task];
        DefaultEstimator = false;
    else
        estimdata(3).ModelUsed = 0;
    end
    for i = 1:NumMV
        ULimits{i,3} = num2str(MPCobj.ManipulatedVariables(i).Min(1,1));
        ULimits{i,4} = num2str(MPCobj.ManipulatedVariables(i).Max(1,1));
        ULimits{i,5} = num2str(MPCobj.ManipulatedVariables(i).RateMin(1,1));
        ULimits{i,6} = num2str(MPCobj.ManipulatedVariables(i).RateMax(1,1));
        Usoft{i,4} = num2str(MPCobj.ManipulatedVariables(i).MinECR(1,1));
        Usoft{i,6} = num2str(MPCobj.ManipulatedVariables(i).MaxECR(1,1));
        Usoft{i,8} = num2str(MPCobj.ManipulatedVariables(i).RateMinECR(1,1));
        Usoft{i,10} = num2str(MPCobj.ManipulatedVariables(i).RateMaxECR(1,1));
        Uwts{i,4} = WeightValue(MPCobj.Weights.ManipulatedVariables(1,i));
        Uwts{i,5} = WeightValue(MPCobj.Weights.ManipulatedVariablesRate(1,i));
    end
    for i = 1:NumOV
        YLimits{i,3} = num2str(MPCobj.OutputVariables(i).Min(1,1));
        YLimits{i,4} = num2str(MPCobj.OutputVariables(i).Max(1,1));
        Ysoft{i,4} = num2str(MPCobj.OutputVariables(i).MinECR(1,1));
        Ysoft{i,6} = num2str(MPCobj.OutputVariables(i).MaxECR(1,1));
        Ywts{i,4} = WeightValue(MPCobj.Weights.OutputVariables(1,i));
    end    
    New.Notes = char(MPCobj.Notes);
    New.Handles.ULimits.setCellData(ULimits);
    New.Handles.YLimits.setCellData(YLimits);
    New.Handles.Uwts.setCellData(Uwts);
    New.Handles.Ywts.setCellData(Ywts);
    New.Handles.Usoft.setCellData(Usoft);
    New.Handles.Ysoft.setCellData(Ysoft);
    New.estimdata = estimdata;
    New.HasUpdated = 0;
    New.DefaultEstimator = DefaultEstimator;
    if DefaultEstimator        
        New.setDefaultEstimator;
    else
        ODspecs(:,3) = {'White'};
        ODspecs(:,4) = {'0.0'};
        Nspecs(:,3) = {'White'};
        Nspecs(:,4) = {'1.0'};
        New.Handles.eHandles(1).UDD.setCellData(ODspecs);
        New.Handles.eHandles(3).UDD.setCellData(Nspecs);
        if NumUD > 0
            IDspecs(:,3) = {'White'};
            IDspecs(:,4) = {'0.0'};
            New.Handles.eHandles(2).UDD.setCellData(IDspecs);
        end
        MPC_ESTIM_REFRESH_ENABLED = true;
        New.RefreshEstimStates;
    end
end
LocalUpdateStatus(S, '');
New.ExportNeeded = 0;
this.RefreshControllerList;
this.Handles.UDDtable.SelectedRow = length(this.Controllers);

% ========================================================================

function WtVal = WeightValue(Weight)
if (Weight <= 0)
    WtVal = '0';
else
    WtVal = num2str(Weight);
end

% --------------------------------------------------------------------

function LocalUpdateStatus(Root, Message)

if isa(Root, 'mpcnodes.MPCGUI')
    if isempty(Message) || ~ischar(Message)
        Root.Frame.clearStatus;
    else
        Root.Frame.postStatus(Message);
    end
end

% --------------------------------------------------------------------

function LocalUpdateText(Root, Message)

if isa(Root, 'mpcnodes.MPCGUI')
    if isempty(Message) || ~ischar(Message)
        Root.Frame.clearText;
    else
        Root.Frame.postText(Message);
    end
end

