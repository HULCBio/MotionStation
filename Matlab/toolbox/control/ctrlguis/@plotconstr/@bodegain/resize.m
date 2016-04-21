function resize(Constr,action,SelectedMarkerIndex)
%RESIZE  Keeps track of gain constraint whilst resizing.

%   Author(s): N. Hickey
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/10 05:07:49 $

persistent Yinit Xinit sty mve Slope X0
persistent AxesLims Xlin Ylinabs MouseEditData

MagAxes = Constr.Parent;
XUnits = Constr.FrequencyUnits;
YUnits = Constr.MagnitudeUnits;
EventMgr = Constr.EventManager;

% Process event
switch action
case 'init'
   % Initialize RESIZE
   MouseEditData = ctrluis.dataevent(EventMgr,'MouseEdit',[]);
   
   % Convert the constraint line Y into dB
   Yinit  = Constr.Magnitude;
   Xinit  = Constr.Frequency;
   X0 = Xinit;
   mve = SelectedMarkerIndex;      % 1 if left marker moved, 2 otherwise
   sty = 3 - SelectedMarkerIndex;
   
   % Axes data
   AxesLims = [get(MagAxes,'Xlim') , get(MagAxes,'Ylim')];
   Xlin = strcmp(get(MagAxes,'Xscale'),'linear');
   Ylinabs = strcmp(YUnits,'abs') & strcmp(get(MagAxes,'Yscale'),'linear');
   
   % Initialize axes expand
   moveptr(MagAxes,'init');
   
case 'acquire'    
   % Track mouse location
   CP = get(MagAxes,'CurrentPoint');
   if Xlin
      CPX = unitconv(max(CP(1,1),0.01*AxesLims(2)),XUnits,'rad/sec');;
   else
      CPX = unitconv(CP(1,1),XUnits,'rad/sec');
   end
   if Ylinabs
      % Protect against negative values
      CPY = unitconv(max(CP(1,2),0.01*AxesLims(4)),YUnits,'dB');
   else
      CPY = unitconv(CP(1,2),YUnits,'dB');
   end
   
   % Cannot go beyond Nyquist freq.
   if Constr.Ts
      nf = pi/Constr.Ts;
      CPX = min(CPX,(1-0.75*any(X0==nf))*nf);
   end
   
   % Calculate new slope of constraint line
   if Xinit(sty)==CPX
      Slope = 0;
   else
      Slope = (Yinit(sty) - CPY) / log10(Xinit(sty)/CPX);
   end
   
   % Update the constraint X and Y data properties
   Xinit(mve) = CPX;
   Yinit(mve) = CPY;
   LocalUpDate(Constr,Xinit,Yinit);
   
   % Update graphics and notify observers
   update(Constr)
   
   % Adjust axis limits if moved constraint gets out of focus
   % Issue MouseEdit event and attach updated extent of resized objects (for axes rescale)
   Freqs = unitconv(Constr.Frequency,'rad/sec',XUnits);
   Mags = unitconv(Constr.Magnitude,'dB',YUnits);
   MouseEditData.Data = ...
      struct('XExtent',Freqs,'YExtent',Mags,'X',CP(1,1),'Y',CP(1,2));
   EventMgr.send('MouseEdit',MouseEditData)
   
   % Update status bar with gradient of constraint line
   LocStr = sprintf('Location:  from %0.3g to %0.3g %s',Freqs(1),Freqs(2),XUnits);
   SlopeStr = sprintf('Slope:  %0.3g dB/decade',Slope);
   EventMgr.poststatus(sprintf('%s\n%s',LocStr,SlopeStr)); 
   
case 'finish'
   % Clean up
   MouseEditData = [];

   % Round the slope to the nearest 20dB per decade
   Slope = 20*round(Slope/20);
   
   % Update the constraint X and Y data properties
   Yinit(mve) = Yinit(sty) + Slope * log10(Xinit(mve)/Xinit(sty));
   LocalUpDate(Constr,Xinit,Yinit);
   
   % Update status
   EventMgr.newstatus(Constr.status('resize'));
   
end


%-------------------- Callback functions -------------------

%%%%%%%%%%%%%%%%%
%% LocalUpDate %%
%%%%%%%%%%%%%%%%%
function LocalUpDate(Constr,Xinit,Yinit)
% Calculate and update the constraint X and Y data properties
[Xinit,is] = sort(Xinit);
Constr.Frequency = Xinit;
Constr.Magnitude = Yinit(is);

