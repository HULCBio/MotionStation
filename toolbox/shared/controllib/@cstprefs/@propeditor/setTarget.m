function setTarget(this,NewTarget)
%SETTARGET  (Re)targets the Property Editor.

%   Author(s): A. DiVergilio, P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:15:43 $

if ~isequal(this.Target,NewTarget)
   % Unselect old target's axes
   if ~isempty(this.Target) & ~this.Target.isBeingDestroyed
      set(getaxes(this.Target),'Selected','off')
   end
   % Update property
   this.Target = NewTarget;
   % Listener management
   if isempty(NewTarget)
      % Delete target-dependent listeners
      this.TargetListeners = [];
      set(cat(1,this.Tabs.Contents),'TargetListeners',[])
   else
      % Listen for Target destruction
      L = handle.listener(NewTarget,'ObjectBeingDestroyed',@close);
      L.CallbackTarget = this;
      this.TargetListeners = L;
      
      % Populate tabs and sync data with new target
      NewTarget.edit(this)
      
      % Pack frame
      this.Java.Frame.pack;
      
      % Show which plot is selected
      set(getaxes(NewTarget),'Selected','on')
   end
end

% Dialog visibility
f = this.Java.Frame;
if isempty(NewTarget)
   % If clearing Target, hide GUI
   f.setVisible(0)
else
   % Raise GUI
   f.setVisible(1)
   f.toFront
   %set(this.Java.Frame,'Minimized','off','Visible','off','Visible','on');
end