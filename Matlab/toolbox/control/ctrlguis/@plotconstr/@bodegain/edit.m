function s = edit(Constr,Container)
%EDIT  Builds Bode gain constraint parameter editor.

%   Authors: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $ $Date: 2002/04/10 05:07:58 $

import com.mathworks.mwt.*;

% Definitions
Prefs = cstprefs.tbxprefs;
GL_31 = java.awt.GridLayout(3,1,0,3);
LEFT  = MWLabel.LEFT;
CENTER = MWLabel.CENTER;
BWEST = MWBorderLayout.WEST;
BCENTER = MWBorderLayout.CENTER;
BEAST = MWBorderLayout.EAST;

% Labels
P1 = MWPanel(GL_31); 
Container.add(P1,BWEST);
L = cell(3,1);
Text = {'Frequency';'Magnitude';'Slope (dB/decade)'};
for ct=1:3
    Label = MWLabel(sprintf('%s:',Text{ct}),LEFT); 
    P1.add(Label);  
    Label.setFont(Prefs.JavaFontP);
    L{ct} = Label;
end
    
 % Text fields
P6 = MWPanel(MWBorderLayout(0,0)); 
Container.add(P6,BCENTER);
P2 = MWPanel(MWBorderLayout(7,0)); 
P6.add(P2,BWEST);
T = cell(3,3);
% Column #1
P3 = MWPanel(GL_31);  P2.add(P3,BWEST);
W = MWTextField(10); 
P3.add(W);   W.setFont(Prefs.JavaFontP);  T{1,1} = W;
W = MWTextField(10); 
P3.add(W);   W.setFont(Prefs.JavaFontP);  T{2,1} = W;
W = MWTextField(10); 
P3.add(W);   W.setFont(Prefs.JavaFontP);  T{3,1} = W;
% Column #2
P4 = MWPanel(GL_31);   P2.add(P4,BCENTER);
W = MWLabel(sprintf('%s','to'),CENTER); 
P4.add(W);   W.setFont(Prefs.JavaFontP);  T{1,2} = W;
W = MWLabel(sprintf('%s','to'),CENTER); 
P4.add(W);   W.setFont(Prefs.JavaFontP);  T{2,2} = W;
% Column #3
P5 = MWPanel(GL_31);   P2.add(P5,BEAST);
W = MWTextField(10); 
P5.add(W);   W.setFont(Prefs.JavaFontP);  T{1,3} = W;
W = MWTextField(10); 
P5.add(W);   W.setFont(Prefs.JavaFontP);  T{2,3} = W;

% Callbacks
Callback = {@LocalEditFrequency Constr T 1};
set(T{1,1},'ActionPerformedCallback',Callback,'FocusLostCallback',Callback)
Callback = {@LocalEditMagnitude Constr T 1};
set(T{2,1},'ActionPerformedCallback',Callback,'FocusLostCallback',Callback)
Callback = {@LocalEditSlope Constr T};
set(T{3,1},'ActionPerformedCallback',Callback,'FocusLostCallback',Callback)
Callback = {@LocalEditFrequency Constr T 2};
set(T{1,3},'ActionPerformedCallback',Callback,'FocusLostCallback',Callback)
Callback = {@LocalEditMagnitude Constr T 2};
set(T{2,3},'ActionPerformedCallback',Callback,'FocusLostCallback',Callback)

% Initialize text field values
LocalUpdateText([],[],Constr,T);

% Update listeners (track changes in constraint data)
props = [Constr.findprop('Frequency');...
      Constr.findprop('Magnitude');...
      Constr.findprop('FrequencyUnits');...
      Constr.findprop('MagnitudeUnits')];
Listener = handle.listener(Constr,props,'PropertyPostSet',{@LocalUpdateText Constr T});

% Save other handles
s = struct('Panels',{{P1;P2;P3;P4;P5;P6}},'Handles',{[L ; T(:)]},'Listeners',Listener);


%%%%%%%%%%%%%%%%%%%
% LocalUpdateText %
%%%%%%%%%%%%%%%%%%%
function LocalUpdateText(eventsrc,eventdata,Constr,T)
% Updates text fields from contraint data
f = unitconv(Constr.Frequency,'rad/sec',Constr.FrequencyUnits);
mag = Constr.Magnitude;
mag(abs(mag)<1e-3) = 0;
mag = unitconv(mag,'dB',Constr.MagnitudeUnits);
set(T{1,1},'Text',sprintf('%.3g',f(1)))
set(T{1,3},'Text',sprintf('%.3g',f(2)))
set(T{2,1},'Text',sprintf('%.3g',mag(1)))
set(T{2,3},'Text',sprintf('%.3g',mag(2)))
set(T{3,1},'Text',sprintf('%d',Constr.slope))


%%%%%%%%%%%%%%%%%
% LocalEvaluate %
%%%%%%%%%%%%%%%%%
function v = LocalEvaluate(TextField)
% Evaluate text field content
s = get(TextField,'Text');
if isempty(s)
   v = [];
else
   v = evalin('base',s,'[]');
   if ~isequal(size(v),[1 1]) | ~isreal(v),
      v = [];
   end
end


%%%%%%%%%%%%%%%%%%%%%%
% LocalEditFrequency %
%%%%%%%%%%%%%%%%%%%%%%
function LocalEditFrequency(TextField,eventData,Constr,T,jx)
% Update min or max frequency
v = unitconv(LocalEvaluate(TextField),Constr.FrequencyUnits,'rad/sec');
s = Constr.slope;  % grab current slope before changes

% Get new frequency range 
FRange = Constr.Frequency;
if ~isempty(v) & v>0
   if (jx==1 & v>=FRange(2))
      FRange(2) = v*FRange(2)/FRange(1);  % Adjust upper freq, preserving decade extent
   elseif (jx==2 & v<=FRange(1))
      FRange(1) = v*FRange(1)/FRange(2);
   end
   FRange(jx) = v;
   % Keep left of Nyquist freq
   if Constr.Ts,
      FRange = min([FRange ; (pi/Constr.Ts)*[0.9 1]]);
   end
end

% Update frequency data
if isequal(Constr.Frequency,FRange)
   % No change: resync text
   LocalUpdateText([],[],Constr,T);
else
   T = Constr.recordon;
   Constr.Frequency = FRange;
   % Update magnitude (first mag is fixed)
   Constr.Magnitude = Constr.Magnitude(1) + ...
      [0,s*log10(FRange(2)/FRange(1))];
   Constr.recordoff(T);
   % Update display and notify observers
   update(Constr)
end


%%%%%%%%%%%%%%%%%%%%%%
% LocalEditMagnitude %
%%%%%%%%%%%%%%%%%%%%%%
function LocalEditMagnitude(TextField,eventData,Constr,T,jx)
% Update start and end magnitudes
v = LocalEvaluate(TextField);
vabs = unitconv(v,Constr.MagnitudeUnits,'abs');
if ~isempty(v) & vabs>0,
   v = unitconv(v,Constr.MagnitudeUnits,'dB');  % mag in dB
   % Round other mag to nearest feasible value
   jxc = 3-jx;  % complement
   df = log10(Constr.Frequency(jxc)/Constr.Frequency(jx));
   slope = 20*round((Constr.Magnitude(jxc)-v)/df/20);
   NewMag(1,[jxc jx]) = [v+slope*df,v];
   % Update constraint data
   T = Constr.recordon;
   Constr.Magnitude = NewMag;
   Constr.recordoff(T);
   
   % Update display and notify observers
   update(Constr)
else
   LocalUpdateText([],[],Constr,T);
end


%%%%%%%%%%%%%%%%%%
% LocalEditSlope %
%%%%%%%%%%%%%%%%%%
function LocalEditSlope(TextField,eventData,Constr,T)
% Update start and end magnitudes
v0 = LocalEvaluate(TextField);
if ~isempty(v0)
   v = 20*round(v0/20);
   if v~=v0
      set(T{3,1},'Text',sprintf('%d',v))  % listener not triggered if no change in rounded slope
   end
   % Update max mag.
   df = log10(Constr.Frequency(2)/Constr.Frequency(1));
   T = Constr.recordon;
   Constr.Magnitude = Constr.Magnitude(1) + [0,v*df];
   Constr.recordoff(T);
   
   % Update display and notify observers
   update(Constr)
else
   LocalUpdateText([],[],Constr,T);
end
