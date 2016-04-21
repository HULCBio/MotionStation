function resize(Constr, action, SelectedMarkerIndex)
%RESIZE   Keeps track of Gain Margin Constraint while resizing.

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/10 05:11:18 $

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
  
  % Phase origin (in deg)
  PhaseOrigin  = unitconv(Constr.OriginPha, 'deg', XUnits);
  
  % Marker index: 1 if top marker moved, -1 otherwise
  index = 3 - 2 * SelectedMarkerIndex;
  
  % Initialize axes expand
  moveptr(PlotAxes, 'init');
  
 case 'acquire'    
  % Track mouse location
  CP = PlotAxes.CurrentPoint;
  CPY = index * unitconv(CP(1,2), YUnits, 'dB');
  
  % Protect against very small gain margin values
  CPY = max(CPY, 0.01*(diff(PlotAxes.YLim)));
  
  % Update the constraint X data properties
  Constr.MarginGain = CPY;
  MarginGain = unitconv(Constr.MarginGain, 'dB', YUnits);
  
  % Update graphics and notify observers
  update(Constr)
  
  % Adjust axis limits if moved constraint gets out of focus
  % Issue MouseEdit event and attach updated extent of resized objects (for axes rescale)
  Extent = Constr.extent;
  MouseEditData.Data = struct('XExtent', PlotAxes.Xlim, ...
			      'YExtent', Extent(3:4), ...
			      'X', CP(1,1), 'Y', CP(1,2));
  EventMgr.send('MouseEdit',MouseEditData)
  
  % Update status bar with gradient of constraint line
  Status = sprintf('Gain margin constraint: %0.3g %s at %0.3g %s.', ...
		   MarginGain, YUnits, PhaseOrigin, XUnits);
  EventMgr.poststatus(sprintf('%s', Status));
  
 case 'finish'
  % Clean up
  MouseEditData = [];
  
  % Update status
  EventMgr.newstatus(Constr.status('resize'));
end
