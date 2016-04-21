function xfocus = getfocus(this,xunits)
%GETFOCUS  Computes optimal X limits for Bode plots.
% 
%   XFOCUS = GETFOCUS(PLOT) merges the frequency ranges of all 
%   visible responses and returns the frequency focus in the current
%   frequency units (X-focus).  XFOCUS controls which portion of the
%   frequency response is displayed when the x-axis is in auto-range
%   mode.
%
%   XFOCUS = GETFOCUS(PLOT,XUNITS) returns the X-focus in the 
%   frequency units XUNITS.


%  Author(s): P. Gahinet, B. Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:21 $

if nargin==1
   xunits = this.AxesGrid.XUnits;
end

if isempty(this.FreqFocus)
   % No user-defined focus.
   % Collect individual focus for all visible MIMO responses
   xfocus     = cell(0,1);
   softfocus  = logical(zeros(0,1));
   sampletime = zeros(0,1);
   for r = this.Responses'
      % For each visible response...
      if r.isvisible
         idxvis = find(strcmp(get(r.View,'Visible'),'on'));
         [xf,sf,ts] = LocalGetFocus(r.Data(idxvis));
         xfocus = [xfocus ; xf];
         softfocus  = [softfocus ; sf];
         sampletime = [sampletime ; ts];
      end
   end
   
   % Merge into single focus (in rad/sec)
   xfocus = mrgfocus(xfocus,softfocus);
   
   % Extend focus to nyquist frequency for discrete systems if focus is empty
   if isempty(xfocus)
      if any(sampletime > 0)
         xfocus = [0.1 1] * pi / max(sampletime(sampletime>0));
      else
         xfocus = [1 10];
      end
   end
   
   % Unit conversion
   xfocus = unitconv(xfocus,'rad/sec',xunits);
   
   % Round up x-bounds to entire decades
   if ~isempty(xfocus)
      lxf = log10(xfocus);
      lxfint = [floor(lxf(1)),ceil(lxf(2))];
      %  RE: scheme below may clip out Nyquist frequency
      %    if lxfint(2)-lxfint(1)>3  % more than 3 decades
      %       % Shrink range when focus far from end points
      %       lxfint(1) = lxfint(1) + (lxf(1)>lxfint(1)+0.7);
      %       lxfint(2) = lxfint(2) - (lxf(2)<lxfint(2)-0.7);
      %    end
      xfocus = 10.^lxfint;
   end
else
   xfocus = unitconv(this.FreqFocus,'rad/sec',xunits);
end

%-------------------Local Functions ------------------------

function [xf,sf,ts] = LocalGetFocus(data)
n = length(data);
xf = cell(n,1);
sf = false(n,1);
ts = zeros(n,1);
for ct=1:n
   xf{ct} = unitconv(data(ct).Focus,data(ct).FreqUnits,'rad/sec');
   sf(ct) = data(ct).SoftFocus;
   ts(ct) = abs(data(ct).Ts);
end
