function bodemag(varargin)
%BODEMAG  Bode magnitude plot for LTI models.
%
%   BODEMAG(SYS) plots the magnitude of the frequency response of the
%   LTI model SYS (Bode plot without the phase diagram).  The frequency 
%   range and number of points are chosen automatically.
%
%   BODEMAG(SYS,{WMIN,WMAX}) draws the magnitude plot for frequencies
%   between WMIN and WMAX (in radians/second).
%
%   BODEMAG(SYS,W) uses the user-supplied vector W of frequencies, in
%   radian/second, at which the frequency response is to be evaluated.  
%
%   BODEMAG(SYS1,SYS2,...,W) shows the frequency response magnitude of
%   several LTI models SYS1,SYS2,... on a single plot.  The frequency 
%   vector W is optional.  You can also specify a color, line style,  
%   and marker for each model, as in  
%      bodemag(sys1,'r',sys2,'y--',sys3,'gx').
%
%   See also BODE, LTIVIEW, LTIMODELS.

%   Authors: P. Gahinet  8-14-96
%   Revised: A. DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.14.4.2 $  $Date: 2004/04/08 20:48:30 $

ni = nargin;
if ni==0,
   error('Not enough input arguments.')
end

% Parse input list
try
   for ct = ni:-1:1
      ArgNames(ct,1) = {inputname(ct)};
   end
   [sys,SystemName,InputName,OutputName,PlotStyle,ExtraArgs] = ...
      rfinputs('bodemag',ArgNames,varargin{:});
catch
   rethrow(lasterror)
end
w = ExtraArgs{1};
nsys = length(sys);

% Bode response plot
try
   h = ltiplot(gca,'bode',InputName,OutputName,cstprefs.tbxprefs);
catch
   rethrow(lasterror)
end
h.PhaseVisible = 'off';

% Set global frequency focus for user-defined range/vector (specifies preferred limits)
if iscell(w)
   h.setfocus([w{:}],'rad/sec')
elseif ~isempty(w)
   w = unique(w); % (g212788)
   h.setfocus([w(1) w(end)],'rad/sec')
end

% Create responses
for ct=1:nsys
   src = resppack.ltisource(sys{ct},'Name',SystemName{ct});
   r = h.addresponse(src);
   r.DataFcn = {'magphaseresp' src 'bode' r w};
   % Styles and preferences
   initsysresp(r,'bode',h.Preferences,PlotStyle{ct})
end

% Draw now
if strcmp(h.AxesGrid.NextPlot,'replace')
   h.Visible = 'on';  % new plot crated with Visible='off'
else
   draw(h);  % hold mode
end

% Right-click menus
m = ltiplotmenu(h,'bode');
lticharmenu(h,m.Characteristics,'bode');

% Make GCA one of the visible axes (to ensure YLABEL, AXIS,... work properly)
ax = getaxes(h,'2d');
if ~any(handle(gca)==ax(1:2:end))
   set(ax(1).Parent,'CurrentAxes',ax(end-1))
end