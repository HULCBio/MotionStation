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

% Author(s): K. Subbarao, B. Eryilmaz
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:23:14 $

if nargin==1
   xunits = this.AxesGrid.XUnits;
end

if isempty(this.FreqFocus)
   % No user-defined focus.
   % Collect individual focus for all visible MIMO responses
   xfocus = cell(0,1);
   softfocus = logical(zeros(0,1));
   sampletime = zeros(0,1);
   for r=this.Responses'
      % For each visible response...
      if r.isvisible
         idxvis = find(strcmp(get(r.View,'Visible'),'on'));
         xfocus = [xfocus ; get(r.Data(idxvis),{'Focus'})];
         ts = get(r.Data(idxvis),{'Ts'});
         sf = get(r.Data(idxvis),{'SoftFocus'});
         sampletime = [sampletime ; abs(cat(1,ts{:}))];
         softfocus = [softfocus ; cat(1,sf{:})];
      end
   end
   
   % Merge into single focus
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
      xfocus = 10.^lxfint;
   end
else
   xfocus = unitconv(this.FreqFocus,'rad/sec',xunits);
end
