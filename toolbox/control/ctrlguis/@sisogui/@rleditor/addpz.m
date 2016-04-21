function addpz(Editor,varargin)
%ADDPZ  Adds pole or zero graphically.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.21 $  $Date: 2002/04/10 04:57:34 $

% Pointers
Ts = Editor.EditedObject.Ts;
PlotAxes = getaxes(Editor.Axes);
EventMgr = Editor.EventManager;

% Gather info about added root
AddInfo =  Editor.EditModeData;  % {Type,ID}

% Acquire new pole/zero position 
% RE: Adjust position based on pole/zero type
CP = get(PlotAxes,'CurrentPoint');
[Zeros,Poles,GroupType,Status,Action] = ...
    LocalGetRootValue(CP(1,1),CP(1,2),AddInfo.Group,AddInfo.Root,Ts,'C');
   
% Start transaction
T = ctrluis.transaction(Editor.LoopData,'Name',Action,...
    'OperationStore','on','InverseOperationStore','on');

% Add new pole/zero group to database
Editor.EditedObject.addpz(GroupType,Zeros,Poles);

% Register transaction 
EventMgr.record(T);

% Notify peers of data change
Editor.LoopData.dataevent('all');

% Confirm operation in status bar and update history
EventMgr.newstatus(Status);
EventMgr.recordtxt('history',Status);


%----------------- Local functions -----------------

%%%%%%%%%%%%%%%%%%%%%
% LocalGetRootValue %
%%%%%%%%%%%%%%%%%%%%%
function [Zeros,Poles,GroupType,Status,Action] = LocalGetRootValue(X,Y,GroupType,PZType,Ts,CompID)
% Infers specified root value from mouse location

if Ts
    DomainVar = 'z';
else
    DomainVar = 's';
end
CompID = sprintf('%s(%s)',CompID,DomainVar);

switch GroupType
case 'Real'
    % Real pole/zero
    if strcmpi(PZType,'Zero')
        Zeros = X;  Poles = zeros(0,1);
    else
        Poles = X;  Zeros = zeros(0,1);
    end
    Status = sprintf('Added real %s to %s at %s = %.3g',lower(PZType),CompID,DomainVar,X);
    Action = sprintf('Add %s',PZType);
    
case 'Complex'
    % Complex pole/zero
    Y = abs(Y);
    if strcmpi(PZType,'Zero')
        Zeros = [X + i*Y ; X - i*Y];  Poles = zeros(0,1);
    else
        Poles = [X + i*Y ; X - i*Y];  Zeros = zeros(0,1);
    end
    Status = sprintf('Added complex pair of %ss to %s at %s = %.3g %s %.3gi',lower(PZType),CompID,DomainVar,X,char(177),Y);
    Action = sprintf('Add %s',PZType);
    
case {'Lead','Lag'}
    % Lead or lag network (s+tau1)/(s+tau2) 
    % Compute factor F such that the frequencies of the added pole and
    % its companion are Wn and F*Wn
    F = 1.5^(-1+2*strcmpi(GroupType,'Lag'));
    
    % Enforce stability and separate pair to facilitate adjustments
    if Ts
        % Natural frequency constrained to [1e-3,pi/Ts]
        wmin = 1.01 * exp(-pi);
        wmax = exp(-0.001*Ts);
        X = max(wmin,min(X,wmax));
        Poles = X;   Zeros = max(wmin,X^F);
    else
        X = min(X,-0.001);
        Poles = X;   Zeros = F*X;
    end
    Status = sprintf('Added %s network to %s with zero at %s = %.3g and pole at %s = %.3g',...
        lower(GroupType),CompID,DomainVar,Zeros,DomainVar,Poles);
    Action = sprintf('Add %s',GroupType);
    
    % Set @pzgroup type
    GroupType = 'LeadLag';
    
case 'Notch'
    % Notch filter. Mouse position is the pole position. Place the zero to 
    % achieve 20 dB drop
    r2 = X + i * abs(Y);      % pole position
    [Wn,Z2] = damp(r2,Ts);    % corresponding damping and natural freq
    Z1 = 0.1 * Z2;            % zero damping
    if Ts
        r1 = exp(Ts * Wn * (-Z1 + 1i * sqrt(1-Z1^2)));
    else
        r1 = Wn * (-Z1 + 1i * sqrt(1-Z1^2));
    end
    Zeros = [r1;conj(r1)];
    Poles = [r2;conj(r2)];
    
    Status = sprintf('Added notch filter to %s with zeros at %s = %.3g %s %.3gi and poles at %s = %.3g %s %.3gi',...
        CompID,DomainVar,real(r1),char(177),abs(imag(r1)),DomainVar,real(r2),char(177),abs(imag(r2)));
    Action = 'Add Notch';
end
