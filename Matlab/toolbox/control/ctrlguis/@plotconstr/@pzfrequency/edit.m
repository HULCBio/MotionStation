function s = edit(Constr,Container)
%EDIT  Builds constraint parameter editor.

%   Authors: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $ $Date: 2002/06/11 17:29:22 $

import com.mathworks.mwt.*;

% Definitions
Prefs = cstprefs.tbxprefs;
LEFT  = MWLabel.LEFT;
CENTER = MWLabel.CENTER;
BWEST = MWBorderLayout.WEST;
BCENTER = MWBorderLayout.CENTER;
BEAST = MWBorderLayout.EAST;

% Labels
P1 = MWPanel(MWBorderLayout(0,0)); 
Container.add(P1,BWEST);
L = MWLabel(sprintf('Natural Frequency:'),LEFT); 
P1.add(L);  
L.setFont(Prefs.JavaFontP);

% Parameters
P2 = MWPanel(MWBorderLayout(0,0)); 
Container.add(P2,BCENTER);

% Upper/lower
C = MWChoice;
P2.add(C,BWEST);
C.add(sprintf('at most')); C.add(sprintf('at least'));
C.setFont(Prefs.JavaFontP);
set(C,'ItemStateChangedCallback',{@LocalSetType Constr C});

% Frequency bound
T = MWTextField(8); 
P2.add(T,BCENTER);   
T.setFont(Prefs.JavaFontP);  
Callback = {@LocalEditSettling Constr T};
set(T,'ActionPerformedCallback',Callback,'FocusLostCallback',Callback)

% Initialize text field values
LocalUpdateText([],[],Constr,T);
LocalUpdatePopup([],[],Constr,C);

% Update listeners (track changes in constraint data)
p = [Constr.findprop('Frequency');Constr.findprop('FrequencyUnits')];
Listeners = [...
        handle.listener(Constr,p,'PropertyPostSet',{@LocalUpdateText Constr T});...
        handle.listener(Constr,Constr.findprop('Type'),'PropertyPostSet',{@LocalUpdatePopup Constr C})];

% Save other handles
s = struct('Panels',{{P1;P2}},'Handles',{{L;T;C}},'Listeners',Listeners);

%-----------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%
% LocalUpdateText %
%%%%%%%%%%%%%%%%%%%
function LocalUpdateText(eventsrc,eventdata,Constr,T)
% Updates text fields from contraint data
set(T,'Text',sprintf('%.3g',unitconv(Constr.Frequency,'rad/sec',Constr.FrequencyUnits)))

%%%%%%%%%%%%%%%%%%%%
% LocalUpdatePopup %
%%%%%%%%%%%%%%%%%%%%
function LocalUpdatePopup(eventsrc,eventdata,Constr,C)
% Updates popup
if strcmp(Constr.Type,'upper')
    C.select(0);
else
    C.select(1);
end

%%%%%%%%%%%%%%%%
% LocalSetType %
%%%%%%%%%%%%%%%%
function LocalSetType(eventsrc,eventdata,Constr,C)
% Switch constraint type
if C.getSelectedIndex==0,
   Constr.Type = 'upper';
else
   Constr.Type = 'lower';
end
% Update display and notify observers
update(Constr)

%%%%%%%%%%%%%%%%%%%%%
% LocalEditSettling %
%%%%%%%%%%%%%%%%%%%%%
function LocalEditSettling(TextField,eventData,Constr,T)
% Update settling value
s = get(TextField,'Text');
if isempty(s)
   v = [];
else
   v = evalin('base',s,'[]');
   if ~isequal(size(v),[1 1]) | ~isreal(v) | v<=0,
      v = [];
   end
end
if ~isempty(v)
   % Update settling time 
   T = Constr.recordon;
   Constr.Frequency = unitconv(v,Constr.FrequencyUnits,'rad/sec');
   Constr.recordoff(T);
   
   % Update display and notify observers
   update(Constr)
end
