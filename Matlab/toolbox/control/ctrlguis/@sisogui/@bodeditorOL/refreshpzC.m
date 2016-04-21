function refreshpzC(Editor,event,varargin)
%REFRESHPZC  Refreshes plot during dynamic edit of C's poles and zeros.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.28 $  $Date: 2002/04/10 05:03:01 $

%RE: Do not use persistent variables here (several rleditor's
%    might track gain changes in parallel).

% Process events
switch event 
case 'init'
   % Initialization for dynamic gain update (drag).
   PZGroup = varargin{1};     % Modified PZGROUP
   
   % Find related PZVIEW objects
   ig = find(Editor.EditedObject.PZGroup==PZGroup); 
   PZView = Editor.EditedPZ(ig,:);
   
   % Switch editor's RefreshMode to quick
   Editor.RefreshMode = 'quick';
   
   % Save initial data (units = rad/sec,abs,deg)
   InitData = struct(...
      'PZGroup',get(PZGroup),...
      'Frequency',Editor.Frequency,...
      'Magnitude',Editor.Magnitude,...
      'Phase',Editor.Phase);
   
   % Install listener on PZGROUP data and store listener reference 
   % in EditModeData property
   L = handle.listener(PZGroup,'PZDataChanged',...
      {@LocalUpdatePlot Editor InitData PZView});
   L.CallbackTarget = PZGroup;
   Editor.EditModeData = L;
   
case 'finish'
   % Clean up after dynamic gain update (drag)
   % Return editor's RefreshMode to normal
   Editor.RefreshMode = 'normal';
   
   % Delete gain listener
   delete(Editor.EditModeData);
   Editor.EditModeData = [];
end


%-------------------------Local Functions-------------------------

%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdatePlot %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdatePlot(PZGroup,event,Editor,InitData,PZView)
% Update plot

% RE:  * PZGroup: current PZGROUP data
%      * Working units are (rad/sec,abs,deg)

Ts = Editor.LoopData.Ts;

% Natural and peaking frequencies for new pole/zero locations (in rad/sec)
[W0,Zeta] = damp([PZGroup.Zero;PZGroup.Pole],Ts);
if Ts,
   % Keep root freq. below Nyquist freq.
   W0 = min(W0,pi/Ts);
end
t = W0.^2 .* (1 - 2 * Zeta.^2);
Wpeak = sqrt(t(t>0,:));

% Update mag and phase data
% RE: Update editor properties (used by INTERPY and REFRESHMARGIN)
Wxtra = [Wpeak;W0];
InitMag = [InitData.Magnitude ; ...
      Editor.interpmag(InitData.Frequency,InitData.Magnitude,Wxtra)];
InitPhase = [InitData.Phase ; ...
      interp1(InitData.Frequency,InitData.Phase,Wxtra)];
[W,iu] = LocalUniqueWithinTol([InitData.Frequency;Wxtra],1e3*eps);  % sort + unique

[Mag, Pha] = subspz(Editor, W, InitMag(iu), InitPhase(iu), ...
   InitData.PZGroup, PZGroup);
Editor.Magnitude = Mag;
Editor.Phase     = Pha;
Editor.Frequency = W;

% Update the open-loop plot
Editor.redrawpz(PZGroup,PZView,W0);

% Update stability margins (using interpolation)
Editor.refreshmargin;


%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUniqueWithinTol %
%%%%%%%%%%%%%%%%%%%%%%%%
function [w,iu] = LocalUniqueWithinTol(w,rtol)
% Eliminates duplicates within RTOL (relative tolerance)
% Helps prevent reintroducing duplicates during unit conversions

% Sort W
[w,iu] = sort(w);

% Eliminate duplicates
lw = length(w);
dupes = find(w(2:lw)-w(1:lw-1)<=rtol*w(2:lw));
w(dupes,:) = [];
iu(dupes,:) = [];
