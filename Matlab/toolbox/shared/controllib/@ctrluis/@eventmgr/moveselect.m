function Status = moveselect(this,action)
%MOVESELECT  Moves selected objects with the mouse

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:17:51 $

% RE: Each selectable object must implement EXTENT and MOVE methods

persistent X0 Y0 MouseEditData

Nselect = length(this.SelectedObjects);
PlotAxes = this.SelectedContainer;  % hg.axes handle

% Process event
switch action
case 'init'
   % Initialize MOVE for selected objects
   this.MouseEditMode = 'on';
   MouseEditData = ctrluis.dataevent(this,'MouseEdit',[]);
   
   % Current position
   CP = PlotAxes.CurrentPoint;
   X0 = CP(1,1);   Y0 = CP(1,2);
   for ct=1:Nselect,
      % RE: To avoid distorsions due to patch thickness, mouse-selected constraint 
      %     may adjust (X0,Y0) and move pointer onto its edge
      [X0,Y0] = move(this.SelectedObjects(ct),'init',X0,Y0);
   end
   
   % Initialize axes rescale
   moveptr(PlotAxes,'init');
   Status = '';
   
case 'track'   
   % Track mouse location
   CP = PlotAxes.CurrentPoint;
   X = CP(1,1);   Y = CP(1,2);
   
   % Restrict actual displacement by projecting (X,Y) onto reachable set for
   % each constraint
   for ct=1:Nselect,
      [X,Y] = move(this.SelectedObjects(ct),'restrict',X,Y,X0,Y0);
   end
   
   % Recast displacement (X0,Y0)->(X,Y) as relative parameter change 
   % and apply change to each constraint
   for ct=1:Nselect
      Status = move(this.SelectedObjects(ct),'update',X,Y,X0,Y0);
   end
   
   % Issue MouseEdit event and attach updated extent of moved objects (for axes rescale)
   Extent = LocalGetExtent(this.SelectedObjects);
   MouseEditData.Data = ...
      struct('XExtent',Extent(1:2),'YExtent',Extent(3:4),'X',X,'Y',Y);
   this.send('MouseEdit',MouseEditData)
   
   % Set status
   if Nselect>1 | isempty(Status),
      Status = sprintf('Move selected objects to desired location and release the mouse.');
   end
   
case 'finish'
   % Clean up
   this.MouseEditMode = 'off';
   MouseEditData = [];
   
   % Set status
   Status = sprintf('Moved selected objects to specified location.');
   if Nselect==1
      try
         Status = this.SelectedObjects.status('move');
      end
   end
   
end


%------------------ Local Functions ---------


function Extent = LocalGetExtent(SelectedObjects)
% Gets overall bounding rectangle for selected objects
Extent = SelectedObjects(1).extent;
for ct=2:length(SelectedObjects)
   xt = SelectedObjects(ct).extent;
   Extent([1 3]) = min(Extent([1 3]),xt([1 3]));
   Extent([2 4]) = max(Extent([2 4]),xt([2 4]));
end