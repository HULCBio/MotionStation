function s = edit(Constr,Container)
%EDIT  Builds constraint parameter editor.

%   Authors: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $ $Date: 2002/04/10 05:10:32 $

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
if strcmpi(Constr.Format,'damping')
    L = MWLabel(sprintf('Damping Ratio  >'),LEFT); 
else
    L = MWLabel(sprintf('Percent Overshoot  <'),LEFT); 
end
P1.add(L);  
L.setFont(Prefs.JavaFontP);

% Parameters
P2 = MWPanel(MWBorderLayout(0,0)); 
Container.add(P2,BCENTER);
% Bound value
T = MWTextField(8); 
P2.add(T,BCENTER);   
T.setFont(Prefs.JavaFontP);  
Callback = {@LocalEdit Constr T};
set(T,'ActionPerformedCallback',Callback,'FocusLostCallback',Callback)

% Initialize text field values
LocalUpdate([],[],Constr,T);

% Update listeners (track changes in constraint data)
Listeners = handle.listener(Constr,Constr.findprop('Damping'),...
    'PropertyPostSet',{@LocalUpdate Constr T});

% Save other handles
s = struct('Panels',{{P1;P2}},'Handles',{{L;T}},'Listeners',Listeners);


%%%%%%%%%%%%%%%
% LocalUpdate %
%%%%%%%%%%%%%%%
function LocalUpdate(eventsrc,eventdata,Constr,T)
% Updates text fields from contraint data
if strcmpi(Constr.Format,'damping')
    set(T,'Text',sprintf('%.3g',Constr.Damping))
else
    set(T,'Text',sprintf('%.3g',Constr.overshoot))
end

%%%%%%%%%%%%%
% LocalEdit %
%%%%%%%%%%%%%
function LocalEdit(TextField,eventData,Constr,T)
% Update settling value
s = get(TextField,'Text');
DampFormat = strcmpi(Constr.Format,'damping');
if isempty(s)
    v = [];
else
    v = evalin('base',s,'[]');
    if ~isequal(size(v),[1 1]) | ~isreal(v) | v<0 | ...
            (DampFormat & v>1)
        v = [];
    end
end
if ~isempty(v)
  % Update damping/overshoot
  if ~DampFormat
    t = (log(v/100)/pi)^2;
    v = sqrt(t/(1+t));
  end
  T = Constr.recordon;
  Constr.Damping = v;
  Constr.recordoff(T);
  
   % Update display and notify observers
   update(Constr)
end
