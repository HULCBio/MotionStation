function runSimulation(this)

% Operates on an MPCSim scenario to generate a simulation.

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.7 $ $Date: 2004/04/10 23:36:54 $

% Get the controller.  May cause an MPC object update.

Controller = this.ControllerName;
MPCobj = this.getMPCControllers.getController(Controller);
if isempty(MPCobj)
    return
end
S = this.getRoot;

% Make sure the MPCobj.Ts and the scenario Ts agree.  
this.Ts = MPCobj.Ts;

% Get the scenario.  If nothing has changed, this gets the version
% already saved.

Scenario = this.getSignalDefinitions;

% Define simulation options
SimOpts = mpcsimopt(MPCobj);

% Get the plant model.

mpcCursor(S.Frame, 'wait');
PlantName = this.PlantName;
simModel.Plant = this.getMPCModels.getLTImodel(PlantName);
simModel.Nominal.U = MPCobj.Model.Nominal.U;
simModel.Nominal.Y = MPCobj.Model.Nominal.Y;
SimOpts.Model = simModel;

% Set simulation options

if this.ConstraintsEnforced
    SimOpts.Constraints = 'on';
else
    SimOpts.Constraints = 'off';
end

if this.ClosedLoop
    SimOpts.OpenLoop = 'off';
else
    SimOpts.OpenLoop = 'on';
    SimOpts.MVSignal = zeros(1,length(MPCobj.MV));
end

if this.rLookAhead
    SimOpts.RefLookAhead = 'on';
else
    SimOpts.RefLookAhead = 'off';
end
if this.vLookAhead
    SimOpts.MDLookAhead = 'on';
else
    SimOpts.MDLookAhead = 'off';
end

% Call the mpccontrol/sim method
SimOpts.StatusBar = 'on';
SimOpts.UnmeasuredDisturbance = Scenario.d;
SimOpts.InputNoise = Scenario.Noise.U;
SimOpts.OutputNoise = Scenario.Noise.Y;
if ~this.ClosedLoop
    MVSignal = simModel.Nominal.U(S.iMV);
    SimOpts.MVSignal = MVSignal(:)';
end
try
    [y, t, u]=sim(MPCobj, Scenario.T, Scenario.r, Scenario.v, SimOpts);
    y(:,S.iMO) = y(:,S.iMO) + Scenario.Noise.Y;
catch
    [Err, Id] = lasterr;
    if ~isempty(findstr(Id, 'feedthrough'))
        Message = sprintf(['Model "%s" in scenario "%s" has direct', ...
            ' feedthrough for at least one manipulated variable.', ...
            '  Simulation aborted.'], this.PlantName, this.Label);
    else
        Message = sprintf(['Simulation using "%s" will not run.', ...
            '  Diagnostic information follows:\n\n', ...
            'Error ID = %s\n\nMessage = %s'], ...
            this.Label, this.Label, Id, Err);
    end
    uiwait(errordlg(Message, 'MPC Error', 'modal'));
    this.Results = [];
    mpcCursor(S.Frame, 'default');
    return
end
Root = this.getRoot;
if this.ClosedLoop
    r = Scenario.r;
else
    r = [];
end
[Root.Hout, Root.Hin] = plot(MPCobj, t, y, r, u, ...
     Scenario.v, Scenario.d, Root.Hout, Root.Hin, this.Label);
Figi = Root.Hin.AxesGrid.Parent;
Figo = Root.Hout.AxesGrid.Parent;
set(Figo, 'NumberTitle', 'off', 'Tag', 'mpc',  ...
    'Name', [Root.Label, ':  Outputs'], 'HandleVisibility', 'callback');
set(Figi, 'NumberTitle', 'off', 'Tag', 'mpc', ...
    'Name', [Root.Label, ':  Inputs'], 'HandleVisibility', 'callback');
figure(double(Figi));
figure(double(Figo));
 
Inputs = struct('time', {t}, 'blockname', {this.Label});
Nin = S.Sizes(6);
Values = zeros(length(t), Nin);
Values(:, S.iMV) = u;
if ~isempty(S.iMD)
    Values(:, S.iMD) = Scenario.v;
end
if ~isempty(S.iUD)
    Values(:, S.iUD) = Scenario.d;
end
Inputs.signals = struct('values', {Values}, 'label', {S.InData(:,1)}, ...
    'dimensions', {Nin}, 'unit', {S.InData(:,4)}, ...
    'description', {S.InData(:,3)});
Outputs = struct('time', {t}, 'blockname', {this.Label});
Outputs.signals = struct('values', {y}, 'label', {S.OutData(:,1)}, ...
    'dimensions', {S.Sizes(7)}, 'unit', {S.OutData(:,4)}, ...
    'description', {S.OutData(:,3)}, 'setpoints', {Scenario.r});
this.Results = struct('Inputs', {Inputs}, 'Outputs', {Outputs});

mpcCursor(S.Frame, 'default');
