function refreshpzC(Editor, event, varargin)
%REFRESHPZC  Refreshes plot during dynamic edit of C's poles and zeros.

%   Author(s): Bora Eryilmaz
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/10 05:05:08 $

%RE: Do not use persistent variables here (several NicholsEditors
%    might track gain changes in parallel).

% Process events
switch event 
case 'init'
   % Initialization for dynamic gain update (drag).
   PZGroup = varargin{1};  % Modified PZGROUP
   
   % Find related PZVIEW objects
   ig = find(Editor.EditedObject.PZGroup == PZGroup); 
   PZView = Editor.EditedPZ(ig);
   
   % Switch editor's RefreshMode to quick
   Editor.RefreshMode = 'quick';
   
   % Save initial data (units = rad/sec, abs, deg)
   InitData = struct(...
      'PZGroup', get(PZGroup), ...
      'Frequency', Editor.Frequency, ...
      'Magnitude', Editor.Magnitude, ...
      'Phase',     Editor.Phase);
   
   % Install listener on PZGROUP data and store listener reference
   % in EditModeData property
   L = handle.listener(PZGroup, 'PZDataChanged', ...
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


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Function: LocalUpdatePlot
% Updates plot
% ----------------------------------------------------------------------------%
function LocalUpdatePlot(PZGroup, event, Editor, InitData, PZView)
% RE:  PZGroup: current PZGROUP data
%      Working units are (rad/sec, abs, deg)

Ts = Editor.LoopData.Ts;

% Natural and peaking frequencies for new pole/zero locations (in rad/sec)
[W0, Zeta] = damp([PZGroup.Zero ; PZGroup.Pole], Ts);
if Ts
   % Keep root freq. below Nyquist freq.
   W0 = min(W0, pi/Ts);
end
t = W0.^2 .* (1 - 2 * Zeta.^2);
Wpeak = sqrt(t(t>0, :));

% Update mag and phase data
% RE: Update editor properties (used by INTERPXY and REFRESHMARGIN)
Wxtra = [Wpeak; W0];
InitMag = [InitData.Magnitude ; ...
      Editor.interpmag(InitData.Frequency, InitData.Magnitude, Wxtra)];
InitPhase = [InitData.Phase ; ...
      interp1(InitData.Frequency, InitData.Phase, Wxtra)];
[W, iu] = LocalUniqueWithinTol([InitData.Frequency; Wxtra], 1e3*eps);
% sort + unique

[Mag, Pha] = subspz(Editor, W, InitMag(iu), InitPhase(iu), ...
   InitData.PZGroup, PZGroup);
Editor.Magnitude = Mag;
Editor.Phase     = Pha;
Editor.Frequency = W;

Editor.Frequency = W;

% Update the open-loop plot
LocalRedrawpz(Editor, PZGroup, PZView, W0);

% Update stability margins (using interpolation)
Editor.refreshmargin;


% ----------------------------------------------------------------------------%
% Function: LocalUniqueWithinTol
% Eliminates duplicates within RTOL (relative tolerance).
% Helps prevent reintroducing duplicates during unit conversions.
% ----------------------------------------------------------------------------%
function [w, iu] = LocalUniqueWithinTol(w, rtol)
% Sort W
[w, iu] = sort(w);

% Eliminate duplicates
lw = length(w);
dupes = find(w(2:lw) - w(1:lw-1) <= rtol*w(2:lw));
w(dupes,:) = [];
iu(dupes,:) = [];

% ----------------------------------------------------------------------------%
% Function: LocalRedrawpz
% Refreshes edited Nichols plot during move pole/zero.
% ----------------------------------------------------------------------------%
function LocalRedrawpz(Editor, PZGroup, PZView, W0)
%   EDITOR.REDRAWPZ(PZGroup,PZView,W0) refreshes the Nichols plot 
%   associated with the moved poles and zeros (equivalently, EDITOR's
%   edited object). The @pzgroup instance PZGROUP specifes the new 
%   pole/zero locations and the vector W0 contains the frequencies 
%   of the new poles and zeros.

% Get handle
HG = Editor.HG;

% Update primary plot using data in current units
[Gain, Magnitude, Phase, Frequency] = nicholsdata(Editor);

% Update Nichols plot
Zdata = Editor.zlevel('curve', [length(Editor.Frequency) 1]);
set(HG.NicholsPlot, 'Xdata', Phase, 'Ydata', Magnitude, 'Zdata', Zdata)

% Update X and Y location of moved roots
PZMagPha = [PZView.Zero ; PZView.Pole];

for ct = 1:length(W0)
  set(PZMagPha(ct), 'UserData', W0(ct))
end

% Update location of notch width markers
if strcmp(PZGroup.Type, 'Notch')
  Wm = notchwidth(PZGroup, Editor.LoopData.Ts);

  % Markers
  Extras = PZView.Extra;
  set(Extras(1), 'UserData', Wm(1))
  set(Extras(2), 'UserData', Wm(2))
end

% Interpolate X and Y values
Editor.interpxy(Magnitude, Phase);
