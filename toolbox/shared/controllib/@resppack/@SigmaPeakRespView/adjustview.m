function adjustview(cv,cd,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%   ADJUSTVIEW(cVIEW,cDATA,'prelim') hides HG objects that might interfer  
%   with limit picking.  rDATA contains the data of the parent response.
%
%   ADJUSTVIEW(cVIEW,cDATA,'postlimit') adjusts the HG object extent once  
%   the axes limits have been finalized (invoked in response, e.g., to a 
%   'LimitChanged' event).

%   Author(s): J. Glass, P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:28 $

if strcmp(Event,'postlim')
    % Position dot and lines given finalized axes limits
    AxGrid = cv.AxesGrid;
    Xauto = strcmp(AxGrid.XlimMode,'auto');
    rData = cd.Parent;
    FreqFactor = unitconv(1,rData.FreqUnits,AxGrid.XUnits);
    Freq = FreqFactor * rData.Frequency;
    XDot = FreqFactor * cd.Frequency;
    
    % Position dot and lines given finalized axes limits
    % Parent axes and limits
    ax = cv.Points.Parent;
    Xlim = get(ax,'Xlim');
    Ylim = get(ax,'Ylim');
    % Find unique frequencies
    [Freq,i,j] = unique(Freq);
    % Adjust dot position based on the X limits
    if Xauto & (XDot>Xlim(2)|XDot<Xlim(1)) & length(Freq)>1   
        XDot = max(Xlim(1),min(Xlim(2),XDot));
        if strcmp(AxGrid.XScale,'log')
            YDot = interp1(log(Freq), ...
                unitconv(rData.SingularValues(i,1),rData.MagUnits,AxGrid.YUnits), log(XDot));
        else
            YDot = interp1(Freq, ...
                unitconv(rData.SingularValues(i,1),rData.MagUnits,AxGrid.YUnits), XDot);
        end
        Color = get(ax,'Color');
        set(double([cv.HLines,cv.VLines]),'XData',[NaN NaN])     
    else
        if isfinite(cd.PeakGain)
            YDot = unitconv(cd.PeakGain,rData.MagUnits,AxGrid.YUnits);
        else
            YDot = cd.PeakGain;
        end
        Color = get(cv.Points,'Color');
        if ~isnan(XDot)
            set(double(cv.HLines),'XData',[rData.Frequency(1),XDot],'YData',[YDot,YDot])     
            set(double(cv.VLines),'XData',[XDot XDot],'YData',[Ylim(1), YDot])
        else
            set(double([cv.HLines; cv.VLines]),'XData', [NaN NaN])
        end
    end
    % Position objects
    set(double(cv.Points),'XData',XDot,'YData',YDot,'MarkerFaceColor',Color)
end