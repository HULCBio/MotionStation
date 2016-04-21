function resize(Constr, action, SelectedMarkerIndex)
%RESIZE   Keeps track of Phase Margin Constraint while resizing.

%   Author(s): N. Hickey, Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/10 05:09:50 $

% Persistent data
persistent PhaseOrigin index MouseEditData

% Handle info
PlotAxes = Constr.Parent;
XUnits   = Constr.PhaseUnits;
YUnits   = Constr.MagnitudeUnits;
EventMgr = Constr.EventManager;

% Process event
switch action
 case 'init'
  % Initialize RESIZE
  MouseEditData = ctrluis.dataevent(EventMgr, 'MouseEdit', []);
  
  % Phase margin origin (in deg)
  PhaseOrigin  = unitconv(Constr.OriginPha, 'deg', XUnits);
  
  % Marker index: -1 if left marker moved, 1 otherwise
  index = 2 * SelectedMarkerIndex - 3;
  
  % Initialize axes expand
  moveptr(PlotAxes, 'init');
  
 case 'acquire'    
  % Track mouse location
  CP  = PlotAxes.CurrentPoint;
  CPX = index * (unitconv(CP(1,1), XUnits, 'deg') - PhaseOrigin);
  % Phase margin should be between [eps,180] degrees.
  CPX = max(min(CPX,180), 0.01*(diff(PlotAxes.Xlim)));
  
  % Update the constraint X data properties
  Constr.MarginPha = CPX;
  MarginPhase = unitconv(Constr.MarginPha, 'deg', XUnits);

  % Update graphics and notify observers
  update(Constr)
  
  % Adjust axis limits if moved constraint gets out of focus
  % Issue MouseEdit event and attach updated extent of resized objects
  % (for axes rescale)
  Extent = Constr.extent;
  MouseEditData.Data = struct('XExtent', Extent(1:2), ...
			      'YExtent', PlotAxes.Ylim, ...
			      'X', CP(1,1), 'Y', CP(1,2));
  EventMgr.send('MouseEdit', MouseEditData)
  
  % Update status bar with gradient of constraint line
  Status = sprintf('Phase margin constraint: %0.3g %s at %0.3g %s.', ...
		   MarginPhase, XUnits, PhaseOrigin, XUnits);
  EventMgr.poststatus(sprintf('%s', Status));
  
 case 'finish'
  % Clean up
  MouseEditData = [];
  
  % Update status
  EventMgr.newstatus(Constr.status('resize'));
end
