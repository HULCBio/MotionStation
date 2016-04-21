function adjustview(cv,cd,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(cVIEW,cDATA,'prelim') hides HG objects that might interfer  
%  with limit picking.
%
%  ADJUSTVIEW(cVIEW,cDATA,'postlimit') adjusts the HG object extent once  
%  the axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:18:57 $

if strcmp(Event,'postlim')
    % Position dot given finalized axes limits
    rData = cd.Parent;
    AxGrid = cv.AxesGrid;
    Xauto = strcmp(AxGrid.XlimMode,'auto');
    [s1,s2] = size(cv.Points);
    
    for ct=1:s1*s2        
        ax = get(cv.Points(ct),'Parent');
        xlim = get(ax,'XLim');
        ylim = get(ax,'YLim');
        PhaseFactor = unitconv(1, rData.PhaseUnits, AxGrid.XUnits);
        
        point_freq = cd.Frequency(ct);
        PeakGain = unitconv(cd.PeakGain(ct), rData.MagUnits, AxGrid.YUnits);
        PeakPhase = PhaseFactor * cd.PeakPhase(ct);
        
        OutScope = Xauto(ceil(ct/s1)) & ...
            (PeakGain>ylim(2) | PeakGain<ylim(1) | PeakPhase>xlim(2) | PeakPhase<xlim(1));
        if OutScope   
            % Nichols curve data
            Frequency = rData.Frequency;
            Magnitude = unitconv(rData.Magnitude(:,ct), rData.MagUnits, AxGrid.YUnits);
            Phase = PhaseFactor * rData.Phase(:,ct);
            %% Find all points inside the axes
            ind = find(Phase>xlim(1) & Phase<xlim(2) & Magnitude>ylim(1) & Magnitude<ylim(2));
            %% Protect against the case where there is no data inside the
            %% axes
            if ~isempty(ind)
                Mag_inside = Magnitude(ind);
                Phase_inside = Phase(ind);
                freq_inside = Frequency(ind);
                
                %% Find the point inside the axes which is nearest in frequency to the peak
                [d,ind_inside] = min(abs(point_freq-freq_inside));
                magin = Mag_inside(ind_inside);
                pin = Phase_inside(ind_inside);
                
                if freq_inside(ind_inside) < point_freq,
                    mout = Magnitude(ind(ind_inside)+1);
                    pout = Phase(ind(ind_inside)+1);
                else
                    mout = Magnitude(ind(ind_inside)-1);
                    pout = Phase(ind(ind_inside)-1);
                end
                
                v = ((pout-pin)+j*(mout-magin))/abs((pout-pin)+j*(mout-magin));
                
                %% Compute the norm of the line length
                s = warning('off','MATLAB:divideByZero');
                [d,ind_min] = min(abs([
                    (0.9999*xlim(2) - pin)/real(v);...
                        (0.9999*xlim(1) - pin)/real(v);...
                        (0.9999*ylim(2) - magin)/imag(v);...
                        (0.9999*ylim(1) - magin)/imag(v)]));
                warning(s)
                
                %% Get intersection point
                point = d*v+(pin+j*magin);                
            else 
                point = NaN+j*NaN;
            end
            %% Get intersection point
            PeakGain = imag(point);
            PeakPhase = real(point);
            Color = get(ax,'Color');
        else
            Color = get(cv.Points(ct),'Color');
        end
        % Position objects
        set(double(cv.Points(ct)),'XData',PeakPhase,'YData',PeakGain,'MarkerFaceColor',Color)
    end
end