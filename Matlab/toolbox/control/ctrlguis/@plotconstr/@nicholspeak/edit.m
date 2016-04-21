function s = edit(Constr, Container)
%EDIT  Builds Nichols closed-loop peak gain constraint parameter editor.

%   Authors: Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $ $Date: 2002/04/10 05:11:35 $

import com.mathworks.mwt.*;

% Definitions
Prefs = cstprefs.tbxprefs;
GL_21 = java.awt.GridLayout(2,1,0,3);
LEFT    = MWLabel.LEFT;
CENTER  = MWLabel.CENTER;
BWEST   = MWBorderLayout.WEST;
BCENTER = MWBorderLayout.CENTER;
BEAST   = MWBorderLayout.EAST;

% Modified Labels and TextFields
L = cell(2,2); % Info and units
T = cell(2,1); % Data input

% Main Panel in the Center of the Container (Frame)
P1 = MWPanel(MWBorderLayout(0,0)); 
Container.add(P1, BCENTER);

% Dialog information labels
P2 = MWPanel(GL_21);
W = MWLabel(sprintf('%s', 'Closed-Loop Peak Gain < '), LEFT);
P2.add(W);  W.setFont(Prefs.JavaFontP);  L{1,1} = W;
W = MWLabel(sprintf('%s', 'Located at'), LEFT);
P2.add(W);  W.setFont(Prefs.JavaFontP);  L{2,1} = W;
P1.add(P2, BWEST);

% Dialog data input
P3 = MWPanel(GL_21);
W = MWTextField(8);
P3.add(W);  W.setFont(Prefs.JavaFontP);  T{1,1} = W;
W = MWTextField(8); 
P3.add(W);   W.setFont(Prefs.JavaFontP);  T{2,1} = W;
P1.add(P3, BCENTER);
 
% Initialize text field values
LocalUpdateText([], [], Constr, T);

% Callbacks
Callback = {@LocalEditGain Constr T};
set(T{1,1}, 'ActionPerformedCallback', Callback, 'FocusLostCallback', Callback)

Callback = {@LocalEditOrigin Constr T};
set(T{2,1}, 'ActionPerformedCallback', Callback,'FocusLostCallback', Callback)

% Update listeners (track changes in constraint data)
props = [Constr.findprop('PeakGain'); ...
	 Constr.findprop('OriginPha'); ...
	 Constr.findprop('PhaseUnits'); ...
	 Constr.findprop('MagnitudeUnits')];
Listener = handle.listener(Constr, props, 'PropertyPostSet', ...
			   {@LocalUpdateText Constr T});

% Save other handles
s = struct('Panels', {{P1;P2;P3}}, 'Handles', {{L;T}}, 'Listeners', Listener);


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Function: LocalUpdateText
% Updates text fields from constraint data
% ----------------------------------------------------------------------------%
function LocalUpdateText(eventsrc, eventdata, Constr, T)
XUnits = Constr.PhaseUnits;
YUnits = Constr.MagnitudeUnits;
Gain   = unitconv(Constr.PeakGain,  'dB',  YUnits);
Origin = unitconv(Constr.OriginPha, 'deg', XUnits);

set(T{1,1}, 'Text', sprintf('%.3g', Gain));
set(T{2,1}, 'Text', sprintf('%.3g', Origin));


% ----------------------------------------------------------------------------%
% Callback Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Function: LocalEvaluate
% Update constraint value
% ----------------------------------------------------------------------------%
function v = LocalEvaluate(TextField)
s = get(TextField, 'Text');
if isempty(s)
  v = [];
else
  v = evalin('base', s, '[]');
  if ~isequal(size(v), [1 1]) | ~isreal(v)
    v = [];
  end
end


% ----------------------------------------------------------------------------%
% Function: LocalEditGain
% Update closed-loop peak gain constraint
% ----------------------------------------------------------------------------%
function LocalEditGain(TextField, eventData, Constr, T)
v = unitconv(LocalEvaluate(TextField), Constr.MAgnitudeUnits, 'dB');
vabs = unitconv(v, Constr.MagnitudeUnits, 'abs');
if ~isempty(v) & (vabs>0)
  % Update phase margin (in dB)
  R = Constr.recordon;
  Constr.PeakGain = v;
  Constr.recordoff(R);
  
  % Update display and notify observers
  update(Constr)
else
  LocalUpdateText([],[],Constr,T);
end


% ----------------------------------------------------------------------------%
% Function: LocalEditOrigin
% Update phase margin origin
% ----------------------------------------------------------------------------%
function LocalEditOrigin(TextField, eventData, Constr, T)
v = unitconv(LocalEvaluate(TextField), Constr.MagnitudeUnits, 'deg');
if ~isempty(v)
  % Phase margin origin should sit at -180 + 360k (in deg) for some k,
  % so that the initial phase margin origin is closest to the mouse position.
  sgnPhaOrig = (v >= 0) - (v < 0);
  
  % Update phase margin origin (in deg)
  R = Constr.recordon;
  Constr.OriginPha = sgnPhaOrig * (abs(v) + 180 - rem(abs(v),360));
  Constr.recordoff(R);

  % Update display and notify observers
  update(Constr)
end

% Listener not triggered if no change in value
LocalUpdateText([],[],Constr,T);
