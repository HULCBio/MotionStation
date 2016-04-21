function [P,H,F,C] = checkdata(LoopData,P,H,F,C)
%CHECKDATA  Check validity of imported data.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/10 04:54:02 $

% P,H,F,C are structures with fields Name and Model

FirstImport = isempty(LoopData.Plant.Model); % 1 if no data in yet

% Set defaults for empty inputs
if isempty(P) % P unchanged
    if FirstImport
        P = struct('Name','untitledP','Model',zpk(1));
    else
        P = LoopData.Plant.save;
    end
else
    % Check validity of modified component
    P = LocalCheckModelData(P,'plant');
end

if isempty(H) % H unchanged
    if FirstImport
        H = struct('Name','untitledH','Model',zpk(1));
    else
        H = LoopData.Sensor.save;
    end
else
    H = LocalCheckModelData(H,'sensor');
end

if isempty(F) % F unchanged
    if FirstImport
        F = struct('Name','untitledF','Model',zpk(1));
    else
        F = LoopData.Filter.save;
    end
else
    F = LocalCheckModelData(F,'prefilter');
end

if isempty(C) % C unchanged
    if FirstImport
        C = struct('Name','untitledC','Model',zpk(1));
    else
        C = LoopData.Compensator.save;
    end
else
    C = LocalCheckModelData(C,'compensator');
end


% Check sample time consistency
% RE: May affect "unchanged" components
[P,H,F,C] = LocalCheckSampleTime(P,H,F,C,LoopData);



%----------------- Local functions -----------------

%%%%%%%%%%%%%%%%%%%%%%%
% LocalCheckModelData %
%%%%%%%%%%%%%%%%%%%%%%%
function Data = LocalCheckModelData(Data,Component)
% Checks model data for plant, sensor, prefilter, and compensator.

% Check model class
if isa(Data.Model,'frd') | isa(Data.Model,'idfrd')
    error(sprintf('The %s must be a TF, ZPK, or SS model, or a scalar.',Component))
elseif ~isreal(Data.Model)
    error(sprintf('The %s model must have real coefficients.',Component))
elseif isa(Data.Model,'idmodel')
    % IDMODEL support 
    % Check the number of inputs to the model
    nu = size(Data.Model,'nu');
    if nu > 0
        % If the model is not a time series extract the
        % model from the input channels to output channels.
        Data.Model = zpk(Data.Model('measure'));
    else 
        % If the model is a time series model error out.
        error(sprintf('The %s model is a time series model',Component))
    end    
else
    % Double or LTI
    Data.Model = zpk(Data.Model);
end

% Check dimensions
[z,p,k,Ts] = zpkdata(Data.Model,'v');
sizes = size(k);
if ~k & ~strcmp(Component,'compensator'),
    error(sprintf('The SISO Tool does not accept %s models with zero gain.',Component))
elseif prod(sizes(1:2))~=1,
    error(sprintf('The %s model must be single input, single output.',Component))
elseif prod(sizes(3:end))~=1
    error('The SISO Tool cannot be used with arrays of models.')
end

% Check for delays
if hasdelay(Data.Model),
    if Ts,
        % Map delay times to poles at z=0 in discrete-time case
        Data.Model = delay2z(Data.Model);
    else
        line1 = sprintf('Cannot handle continuous-time %s models with delays.',Component);
        line2 = 'Use PADE to approximate the time delays.';
        error(sprintf('%s\n%s',line1,line2))
    end      
end


%%%%%%%%%%%%%%%%%%%%%%%%
% LocalCheckSampleTime %
%%%%%%%%%%%%%%%%%%%%%%%%
function [P,H,F,C] = LocalCheckSampleTime(P,H,F,C,LoopData)
% Checks sample time consistency

% Reconcile plant/sensor/prefilter/compensator sample times
% RE: The overall sample time is stored as LoopData.Compensator.Ts
AllTs = [get(P.Model,'Ts') ; get(H.Model,'Ts') ; get(F.Model,'Ts') ; get(C.Model,'Ts')];
Ts = abs(AllTs(4));

if any(AllTs~=Ts),
    % Sample time discrepancy
    StaticFlags = [isstatic(P.Model) ; isstatic(H.Model) ; isstatic(F.Model) ; isstatic(C.Model)];
    DefTs = AllTs(~StaticFlags);  % Unambiguous sample times
    
    if isempty(DefTs)
        % All models are static
        Ts = max(AllTs);
    elseif ~any(diff(DefTs,[],1))
        % Unambiguous sample times match
        Ts = DefTs(1);
    else
        % Resolve mismatch
        if any(~DefTs)
            % Mix continuous/discrete
            error('The feedback loop components F,C,P,H must be either all continuous or all discrete.')
        elseif any(diff(DefTs(DefTs>0,:),[],1))
            % Positive sample time mismatch
            error('The feedback loop components F,C,P,H must share the same sample time.')
        else
            Ts = max(DefTs);
        end
    end
    
    % Equalize sample times
    % RE: Make sure sample time is positive
    Ts = abs(Ts);
    P.Model.Ts = Ts;
    H.Model.Ts = Ts;
    F.Model.Ts = Ts;
    C.Model.Ts = Ts;
end




