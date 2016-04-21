function adjustview(cv,cd,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(cVIEW,cDATA,'prelim') hides HG objects that might interfer  
%  with limit picking.  rDATA contains the data of the parent response.
%
%  ADJUSTVIEW(cVIEW,cDATA,'postlimit') adjusts the HG object extent once  
%  the axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:07 $

if strcmp(Event,'postlim')
  % Position dot and lines given finalized axes limits
  rData = cd.Parent;
  AxGrid = cv.AxesGrid;
  Xauto = strcmp(AxGrid.XlimMode,'auto');
  [s1,s2] = size(cv.Points);
  for ct=1:prod(size(cv.Points))
    ax = get(cv.Points(ct),'Parent');
    xlim = get(ax,'XLim');
    ylim = get(ax,'YLim');
    
    point = cd.PeakResponse(ct);
    point_freq = cd.Frequency(ct);
    

    
    if Xauto(ceil(ct/s1)) & (real(point) < xlim(1) | real(point) > xlim(2) | imag(point) < ylim(1) | imag(point) > ylim(2))
      response = rData.Response(:,ct);
      frequency = rData.Frequency;
      %% Find all points inside the axes
      ind = find(real(response) > xlim(1) & real(response) < xlim(2) & imag(response) > ylim(1) & imag(response) < ylim(2));
      %% Protect against the case where there is no data inside the
      %% axes
      if ~isempty(ind)
	resp_inside = response(ind);
	freq_inside = frequency(ind);
	
	%% Find the point inside the axes which is nearest in frequency to the peak
	[d,ind_inside] = min(abs(point_freq-freq_inside));
	pin = resp_inside(ind_inside);
	
	if freq_inside(ind_inside) < point_freq,
	  pout = response(ind(ind_inside)+1);
	else
	  pout = response(ind(ind_inside)-1);
	end
	
	%% Find the unit vector between the two points
	v = (pout - pin)/abs(pout - pin);
	
	%% Compute the norm of the line length
	s = warning('off','MATLAB:divideByZero');
	[d,ind_min] = min(abs([
	    (0.9999*xlim(2) - real(pin))/real(v);...
	    (0.9999*xlim(1) - real(pin))/real(v);...
	    (0.9999*ylim(2) - imag(pin))/imag(v);...
	    (0.9999*ylim(1) - imag(pin))/imag(v)]));
	warning(s)
	
	%% Get intersection point
	point = d*v+pin;
      else
	point = NaN+j*NaN;
      end
      Color = get(ax,'Color');
    else
      Color = get(cv.Points(ct),'Color');
    end
    % Position objects
    set(double(cv.Points(ct)),'XData',real(point),'YData',imag(point),'MarkerFaceColor',Color)
    if ~isnan(point)
      set(double(cv.Lines(ct)),'XData',[0,real(point)],'YData',[0,imag(point)])    
    else
      set(double(cv.Lines(ct)),'XData',[NaN NaN],'YData',[NaN NaN])  
    end
  end
end
