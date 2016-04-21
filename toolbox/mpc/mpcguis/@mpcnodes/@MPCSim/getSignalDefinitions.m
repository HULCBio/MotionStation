function Scenario = getSignalDefinitions(this)

% Operates on a MPCSim object to create a simulation scenario.
% This gets saved in the object so it can be re-used until
% one or more defining parameters is modified.

%  Author:  Larry Ricker
%  Copyright 1986-2003 The MathWorks, Inc.
%  $Revision: 1.1.8.4 $ $Date: 2004/04/10 23:36:51 $

if this.HasUpdated
    % Something has changed.  We need to update.
    % Get the tabular data.
    
    Setpoints = this.Handles.Setpoints.CellData;
    UnMeasDist = this.Handles.UnMeasDist.CellData;
    
    % Compute number of steps
    
    Tend = evalin('base', this.Tend);
    N = fix(Tend/this.Ts) + 1;
    Scenario.T = N;
    
    S = this.getMPCStructure;
    [NumMV, NumMD, NumUD, NumMO, NumUO, NumIn, NumOut] = getMPCsizes(S);
    
    t = this.Ts*[0:N-1]';
    Scenario.r = signalDefinition(t, Setpoints);
    if NumMD > 0
        MeasDist = this.Handles.MeasDist.CellData;
        Scenario.v = signalDefinition(t, MeasDist);
    else
        Scenario.v = [];
    end
    Scenario.xp0 = [];              
    UMDtab = signalDefinition(t, UnMeasDist);
    if NumUD > 0
        Scenario.d = UMDtab(:,1:NumUD);   
    else
        Scenario.d = [];
    end
    Scenario.Noise.Y = UMDtab(:,NumUD+1:NumUD+NumMO);
    Scenario.Noise.U = UMDtab(:,NumUD+NumMO+1:end);

    this.Scenario = Scenario;
    this.HasUpdated = 0;
else
    % Nothing has changed since scenario was last calculated,
    % so retrieve it.
    Scenario = this.Scenario;
end

% ---------------------------------------------------------

function x = signalDefinition(t, Data)

% Signal definition utility
x0 = ZeroDefault(Data(:,4));
Mag = ZeroDefault(Data(:,5));
t0 = ZeroDefault(Data(:,6));
Period = ZeroDefault(Data(:,7));
x=zeros(length(t),length(x0));

Nvar = length(x0);
for i=1:Nvar
    x(:,i) = x0(i,1);
	ix = find(t >= t0(i));
    if ~isempty(ix)
        switch Data{i,3}
            case 'Constant'
            case 'Step'
                x(ix,i) = x0(i) + Mag(i);
            case 'Ramp'
                x(ix,i) = Mag(i)*(t(ix) - t0(i)) + x0(i);
            case 'Sine'
                x(ix,i) = Mag(i)*sin(2*pi*(t(ix) - t0(i))/Period(i)) + x0(i);
            case 'Pulse'
                ix = find(t >= t0(i) & t < t0(i) + Period(i));
                x(ix,i) = x0(i) + Mag(i);
            case 'Gaussian'
                % Use a near-random starting point
                randn('state',sum(100*clock));
                x(ix,i) = Mag(i)*randn(size(ix(:))) + x0(i);
            otherwise
                errordlg(sprintf(['Unexpected signal type "%s".', ...
                    '\nSimulation aborted.'],Type))
                error('Simulation aborted.')
        end
    end
end

% --------------------------------------------------------------

function Value = ZeroDefault(Strings)

% Utility function converts each string to a number, assigning zero
% when the string is empty
for i=1:length(Strings)
    String = char(Strings{i});
    if isempty(String)
        Value(i,1) = 0;
    else
        try
            Value(i,1) = evalin('base', String);
            if isnan(Value(i,1))
                Value(i,1) = 0;
            end
        catch
            Value(i,1) = 0;
        end
    end
end
