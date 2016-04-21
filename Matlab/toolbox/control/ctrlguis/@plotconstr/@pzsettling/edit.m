function s = edit(Constr,Container)
%EDIT  Builds constraint parameter editor.

%   Authors: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $ $Date: 2002/04/10 05:08:34 $

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
L = MWLabel(sprintf('Settling Time  <'),LEFT); 
P1.add(L);  
L.setFont(Prefs.JavaFontP);

% Parameters
P2 = MWPanel(MWBorderLayout(0,0)); 
Container.add(P2,BCENTER);
% Settling time bound
T = MWTextField(8); 
P2.add(T,BCENTER);   
T.setFont(Prefs.JavaFontP);  
Callback = {@LocalEditSettling Constr T};
set(T,'ActionPerformedCallback',Callback,'FocusLostCallback',Callback)

% Units
P3 = MWPanel(MWBorderLayout(0,0)); 
Container.add(P3,BEAST);
L2 = MWLabel(sprintf('%s','sec'),LEFT); 
P3.add(L2,BWEST);  
L2.setFont(Prefs.JavaFontP);

% Initialize text field values
LocalUpdate([],[],Constr,T);

% Update listeners (track changes in constraint data)
Listeners = handle.listener(Constr,Constr.findprop('SettlingTime'),...
   'PropertyPostSet',{@LocalUpdate Constr T});

% Save other handles
s = struct('Panels',{{P1;P2;P3}},'Handles',{{L;T;L2}},'Listeners',Listeners);


%%%%%%%%%%%%%%%
% LocalUpdate %
%%%%%%%%%%%%%%%
function LocalUpdate(eventsrc,eventdata,Constr,T)
% Updates text fields from contraint data
set(T,'Text',sprintf('%.3g',Constr.SettlingTime))


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
   Constr.SettlingTime = v;
   Constr.recordoff(T);
   
   % Update display and notify observers
   update(Constr)
end
