function AbortFlag = exportdata(Editor)
%EXPORTDATA  Export pole/zero data from Editor to main database.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.17 $  $Date: 2002/04/10 04:55:40 $

% RE: There may be more rows of edit boxes than actual pole and zeros 
%     (because of added blank boxes)

LoopData = Editor.LoopData;
EventMgr = Editor.Parent.EventManager;
HG = Editor.HG;
AbortFlag = 0;

% Get new gain
CompGain = get(HG.TopHandles(3),'UserData');

% Get internal P/Z groups
% RE: IsSimple=1 for the mixed groups (LeadLag/Notch)
[Groups,isSimple,Delz,Delp] = LocalScreenGroups(Editor.PZGroup,HG);

% Check integrity of mixed groups
Format = Editor.Format;
for ct=find(~isSimple)'
    [Groups,AbortFlag] = ...
        LocalCheckMixedGroups(Groups,ct,Delz(ct),Delp(ct),Format,LoopData.Ts);
    if AbortFlag
        % Abort export operation to give users a chance to fix the problem
        return
    end
end

% Start transaction
T = ctrluis.transaction(LoopData,'Name','Edit Compensator',...
    'OperationStore','on','InverseOperationStore','on');

% Export modified pole/zero
Target = Editor.EditedObject; 
if length(Target.PZGroup)
    % Delete existing groups
    delete(Target.PZGroup);
end
if isempty(Groups)
    Target.PZGroup = zeros(0,1);
else
    Target.PZGroup = copy(Groups);
end

% Export gain
Target.Gain = ...
    struct('Sign',sign(CompGain)+(~CompGain),'Magnitude',abs(CompGain));

% Register transaction
EventMgr.record(T);

% Trigger update
LoopData.dataevent('all');

% Notify host status and history
EventMgr.newstatus(sprintf('The compensator %s has been updated.',Editor.EditedObject.Identifier));
EventMgr.recordtxt('history',sprintf('Modified the compensator %s pole/zero data.',Editor.EditedObject.Identifier));


%----------------- Local functions -----------------


%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalScreenGroups %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function [Groups,IsSimple,Delz,Delp] = LocalScreenGroups(Groups,HG)
% Returns valid simple and mixed groups

% Mark simple groups
Types = get(Groups,{'Type'});
IsSimple = strcmp(Types(:),'Real') | strcmp(Types(:),'Complex');  % 0-by-1 when Groups is empty

% Mark groups with deleted zeros
Delz = zeros(size(Groups));
idxz = find(~cellfun('isempty',get(Groups,{'Zero'})));  % groups appearing in Zero column
v = get(HG.ZeroEdit(:,1),{'Value'});
Delz(idxz) = cat(1,v{:});

% Mark groups with deleted poles
Delp = zeros(size(Groups));
idxp = find(~cellfun('isempty',get(Groups,{'Pole'})));  % groups appearing in Pole column
v = get(HG.PoleEdit(:,1),{'Value'});
Delp(idxp) = cat(1,v{:});

% Scan simple groups for NaN values
for ct=find(IsSimple)'
    Delz(ct) = Delz(ct) | (~all(isfinite(get(Groups(ct),'Zero'))));
    Delp(ct) = Delp(ct) | (~all(isfinite(get(Groups(ct),'Pole'))));
end

% Delete bad groups
Delg = (Delz & Delp) | (IsSimple & (Delz | Delp));  % groups to be deleted
if any(Delg)
    delete(Groups(Delg,:));
end

% Return valid groups
idx = find(~Delg);
Groups = Groups(idx);
IsSimple = IsSimple(idx);
Delz = Delz(idx);
Delp = Delp(idx);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalCheckMixedGroups %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Groups,AbortFlag] = ...
    LocalCheckMixedGroups(Groups,ct,Delz,Delp,Format,Ts)

AbortFlag = 0;
g = Groups(ct);

switch g.Type
case 'LeadLag'
    % Lead or lag group
    if xor(Delz,Delp),
        % Turn into real 
        g.Type = 'Real';
        if Delz,
            g.Zero = zeros(0,1);
        else
            g.Pole = zeros(0,1);
        end
    else
        % Look for inconsistent data (violating Zeta>0)
        [Wz,Zz] = damp(g.Zero,Ts);
        [Wp,Zp] = damp(g.Pole,Ts);
        if Zz<=0 | Zp<=0
            % Split into two real roots
            gnew = copy(g);
            set(g,'Type','Real','Zero',zeros(0,1));
            set(gnew,'Type','Real','Pole',zeros(0,1));
            Groups(end+1,:) = gnew;
        end
    end
    
case 'Notch'
    % Notch groug
    if xor(Delz,Delp),
        % Half deleted
        qdlgtxt = LocalNotchWarning('orphan',g.Zero,g.Pole,Ts,Format);
        if strcmp(questdlg(qdlgtxt,'Edit Warning','OK','Cancel','Cancel'),'Cancel')
            % Abort
            AbortFlag = 1;  
        else
            % Turn into complex pair
            g.Type = 'Complex';
            if Delz,
                g.Zero = zeros(0,1);
            else
                g.Pole = zeros(0,1);
            end
        end
    else
        % Look for inconsistent data (violating constraints Wn(Zero)=Wn(Pole) and 
        % |Damping(Zero)|<=|Damping(Pole)|)
        [Wz,Zz] = damp(g.Zero(1),Ts);
        [Wp,Zp] = damp(g.Pole(1),Ts);
        if abs(Wz-Wp)>5e-3*(Wz+Wp) | abs(Zz)>abs(Zp),
            qdlgtxt = LocalNotchWarning('data',g.Zero,g.Pole,Ts,Format);
            if strcmp(questdlg(qdlgtxt,'Edit Warning','OK','Cancel','Cancel'),'Cancel')
                % Abort
                AbortFlag = 1;  
            else
                % Split into two complex pairs
                gnew = copy(g);
                set(g,'Type','Complex','Zero',zeros(0,1));
                set(gnew,'Type','Complex','Pole',zeros(0,1));
                Groups(end+1,:) = gnew;
            end
        else
            % Equalize natural freq. for remaining notches
            W = sqrt(Wz*Wp);
            if Ts
                set(g,'Zero',g.Zero.^(Ts * W/Wz),'Pole',g.Pole.^(Ts * W/Wp));
            else
                set(g,'Zero',g.Zero*W/Wz,'Pole',g.Pole*W/Wp);
            end           
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalNotchWarning %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function WarnTxt = LocalNotchWarning(Issue,Z,P,Ts,Format)

switch Issue
case 'data'
    WarnTxt = {'The following notch has incompatible pole/zero data' ; 
        'and will be split into independent complex pairs:'; ' '};
case 'orphan'
    WarnTxt = {'Only half of the following notch is being deleted:'; ' '};
end   

% Display notch data
Z = Z(1);
P = P(1);
switch Format
case 'RealImag'
    % Real/imag format is active
    Z = sprintf('   Zero = %.3g %s %.3g',real(Z),char(177),abs(imag(Z)));
    P = sprintf('   Pole = %.3g %s %.3g',real(P),char(177),abs(imag(P)));
case 'Damping'
    [Wz,Zz] = damp(Z,Ts);
    [Wp,Zp] = damp(P,Ts);
    Z = sprintf('   Zero:  Damping=%.3g,  Frequency=%.3g',Zz,Wz);
    P = sprintf('   Pole:  Damping=%.3g,  Frequency=%.3g',Zp,Wp);
end

WarnTxt = [WarnTxt ; {Z;P;' '}];    
    




