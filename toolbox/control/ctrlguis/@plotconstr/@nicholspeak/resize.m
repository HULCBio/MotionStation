function resize(Constr, action, SelectedMarkerIndex)
%RESIZE   Keeps track of Closed-loop Peak Gain while resizing.

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/10 05:11:52 $

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
  
  % Marker index: 1 if left marker moved, -1 otherwise
  index = 3 - 2 * SelectedMarkerIndex;
  
  % Initialize axes expand
  moveptr(PlotAxes, 'init');
  
 case 'acquire'    
  % Track mouse location
  CP = PlotAxes.CurrentPoint;
  CPX = unitconv(CP(1,1), XUnits, 'rad');
  CPY = unitconv(CP(1,2), YUnits, 'abs');
  
  % Open-loop position
  G = CPY * exp(j*CPX);
  
  % Update the constraint X data properties in dB.
  Constr.PeakGain = 20*log10(abs(G / (1+G)));
  PeakGain = unitconv(Constr.PeakGain, 'dB', YUnits);
  
  % Update graphics and notify observers
  update(Constr)

  % Adjust axis limits if moved constraint gets out of focus
  % Issue MouseEdit event and attach updated extent of resized objects
  % (for axes rescale)
  Extent = Constr.extent;;
  MouseEditData.Data = struct('XExtent', Extent(1:2), ...
			      'YExtent', Extent(3:4), ...
			      'X', CP(1,1), 'Y', CP(1,2));
  EventMgr.send('MouseEdit', MouseEditData)
  
  % Update status bar with gradient of constraint line
  Status = sprintf('Closed-loop peak gain constraint: %0.3g %s at %0.3g %s.', ...
		   PeakGain, YUnits, PhaseOrigin, XUnits);
  EventMgr.poststatus(sprintf('%s', Status));
  
 case 'finish'
  % Clean up
  MouseEditData = [];
  
  % Update status
  EventMgr.newstatus(Constr.status('resize'));
end
