function addGoalSelectors(this,hConstr,hTrack)
% Links check boxes/menus activating cost and contraints.

%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:44:38 $
%   Copyright 1986-2004 The MathWorks, Inc.

% Fixed listener to this.Constraint
L = struct('Fixed',...
   handle.listener(this,this.findprop('Constraint'),...
   'PropertyPostSet',@(x,y) localSetTarget(this,hConstr,hTrack)),...
   'Constraint',[]);

% Add callbacks
set(hConstr,'Callback',{@localSetConstrEnable this hConstr},...
   'UserData',L)
set(hTrack,'Callback',{@localSetCostEnable this hTrack})

% Add listeners (Constraint dependent)
localSetTarget(this,hConstr,hTrack);


%------ Local Functions --------------------

function localSetTarget(this,hConstr,hTrack)
% Reacts to change in edited constraint, e.g., when reloading project
C = this.Constraint;
% Update widget state
localSetState(hConstr,C.ConstrEnable)
localSetState(hTrack,C.CostEnable)
% Redefine listeners to constraint properties
L = get(hConstr,'UserData');
L.Constraint = [...
   handle.listener(C,C.findprop('ConstrEnable'),...
   'PropertyPostSet',@(x,y) localSetState(hConstr,y.NewValue)) ; ...
   handle.listener(C,C.findprop('CostEnable'),...
   'PropertyPostSet',@(x,y) localSetState(hTrack,y.NewValue))];
set(hConstr,'UserData',L)


function localSetConstrEnable(eventsrc,eventdata,this,hConstr)
% Enable/disable constraint
this.Constraint.ConstrEnable = localGetState(hConstr);


function localSetCostEnable(eventsrc,eventdata,this,hTrack)
% Enable/disable ref tracking
this.Constraint.CostEnable = localGetState(hTrack);


function NewState = localGetState(h)
% Get widget's state after clicking on it
switch get(h,'Type')
   case 'uicontrol'
      if get(h,'Value')==1
         NewState = 'on';
      else
         NewState = 'off';
      end
   case 'uimenu'
      if strcmp(get(h,'Checked'),'off')
         NewState = 'on';
      else
         NewState = 'off';
      end
end


function localSetState(h,State)
% Sets widget's state
switch get(h,'Type')
   case 'uicontrol'
      set(h,'Value',strcmp(State,'on'))
   case 'uimenu'
      set(h,'Checked',State)
end
