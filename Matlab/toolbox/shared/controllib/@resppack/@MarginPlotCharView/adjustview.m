function adjustview(cv,cd,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(cVIEW,cDATA,'prelim') hides HG objects that might
%  interfer with limit picking.  rDATA contains the data of the parent
%  response.
%
%  ADJUSTVIEW(cVIEW,cDATA,'postlimit') adjusts the HG object extent
%  once the axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:18:49 $

if strcmp(Event,'postlim')
  % Parent axes and limits
  rData = cd.Parent;
  AxGrid = cv.AxesGrid;
  ax = cv.MagVLine.Parent;
  XlimMag = get(ax,'Xlim');
  YlimMag = get(ax,'Ylim');
  
  % Gain Margin
  XDotMag = unitconv(cd.GMFrequency,'rad/sec',AxGrid.XUnits);
  YDotMag = unitconv(1/cd.GainMargin,'abs',AxGrid.YUnits{1});
  ZeroDB = unitconv(1,'abs',AxGrid.YUnits{1});
  
  % Position gain margin objects
  set(double(cv.MagVLine),'XData',XDotMag([1 1]),'YData',[ZeroDB, YDotMag]) 
  % Revisit: If the plot is in abs mode, offset the lower limit by eps to ensure
  % that the limit picker is not broken when the axis scale is put in log
  % mode.
  if strcmpi('abs',AxGrid.YUnits{1})
    set(double(cv.MagAxVLine),'XData',XDotMag([1 1]),'YData',[YlimMag(1)+eps, ZeroDB])
  else
    set(double(cv.MagAxVLine),'XData',XDotMag([1 1]),'YData',[YlimMag(1), ZeroDB])
  end
  set(double(cv.ZeroDBLine),'XData',XlimMag,'YData',ZeroDB([1 1]))    
  
  % Parent axes and limits
  ax = cv.PhaseVLine.Parent;
  XlimPhase = get(ax,'Xlim');
  YlimPhase = get(ax,'Ylim');
  
  % Phase Margin
  XDotPhase = unitconv(cd.PMFrequency,'rad/sec',AxGrid.XUnits);
  PhaseFactor = unitconv(1,'deg',AxGrid.YUnits{2});
  YDotPhase = PhaseFactor * cd.PhaseMargin;
  
  % Compute the phase cross over line
  Freq = unitconv(rData.Frequency,rData.FreqUnits,AxGrid.XUnits);
  Phase = unitconv(rData.Phase,rData.PhaseUnits,AxGrid.YUnits{2});
  if  ~isempty(Phase) & ~isnan(XDotPhase)
    if strcmp(AxGrid.XScale,'log')
      s = warning('off');
      PmPlot = interp1(log(Freq),Phase,log(XDotPhase));  
      warning(s);
    else
      PmPlot = interp1(Freq,Phase,XDotPhase);  
    end 
    PmLine = PhaseFactor * 180 * round((PmPlot-YDotPhase)/PhaseFactor/180);
  else
    PmLine = NaN;
  end
  % Position phase margin objects
  set(double(cv.PhaseCrossLine),'XData',XlimPhase,'YData',[PmLine PmLine])     
  set(double(cv.PhaseVLine),'XData',XDotPhase([1 1]),'YData',[PmLine PmLine+YDotPhase])    
  set(double(cv.PhaseAxVLine),'XData',XDotPhase([1 1]),'YData',[PmLine YlimPhase(2)])
  
  % Set the lines connecting the 0DB and phase crossover to the axes 
  
  set(double(cv.Phase0DBVLine),'XData',XDotMag([1 1]),'YData',[PmLine YlimPhase(2)])
  % Revisit: If the plot is in abs mode, offset the lower limit by eps to ensure
  % that the limit picker is not broken when the axis scale is put in log
  % mode.
  if strcmpi('abs',AxGrid.YUnits{1})
    set(double(cv.Mag180VLine),'XData',XDotPhase([1 1]),'YData',[YlimMag(1)+eps, ZeroDB])   
  else
    set(double(cv.Mag180VLine),'XData',XDotPhase([1 1]),'YData',[YlimMag(1)+eps, ZeroDB])  
  end
  % Build title 
  %---Gain text
  YDotMag = unitconv(cd.GainMargin,'abs',AxGrid.YUnits{1});   
  MagUnits = AxGrid.YUnits{1};
  if strcmp(MagUnits,'abs')
    MagUnits = '';
  end
  if ~isnan(XDotMag) & ~isnan(YDotMag)
    MagTxt = sprintf('Gm = %0.3g %s (at %0.3g %s)',YDotMag,MagUnits,XDotMag,AxGrid.XUnits);
  else
    MagTxt = 'Gm = Inf';
  end
  
  %---Phase text    
  if ~isnan(XDotPhase) & ~isnan(YDotPhase)
    PhaseTxt = sprintf('Pm = %0.3g %s (at %0.3g %s)',...
		       YDotPhase,AxGrid.YUnits{2},XDotPhase,AxGrid.XUnits);
  else
    PhaseTxt = 'Pm = Inf';
  end
  
  %% Revisit axesgrid.Title property does not take a cell array
  AxGrid.Title = sprintf('Bode Diagram\n%s ,  %s',MagTxt,PhaseTxt);
end
