function [PhaseOut,gain] = ngrid(s)
%NGRID  Generates grid lines for a Nichols plot.
%   NGRID plots the Nichols chart grid over an existing Nichols plot
%   generated with NICHOLS.  The Nichols chart relates the complex
%   numbers H and H/(1+H), and consists of lines where H/(1+H) has
%   constant magnitude and phase (as H varies in the complex plane).
%
%   NGRID('new') clears the current axes first and sets HOLD ON.
%
%   NGRID generates a grid over the region -40 db to 40 db in
%   magnitude and -360 degrees to 0 degrees in phase when no plot
%   is contained in the current axis.
%
%   NGRID can only be used for SISO systems.
%
%   See also NICHOLS.

%   J.N. Little 2-23-88
%   Revised: CMT 7-12-90, ACWG 6-21-92, Wes W 8-17-92, AFP 6-1-94, PG/KDG 10-23-96, ADV 10-7-99
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.28 $  $Date: 2002/04/10 06:24:51 $

%---Quick exit for syntax [mag,phase]=ngrid or [mag,phase]=ngrid('new')
if nargout
   %---Ngrid defaults (in deg/dB)
   Pmin = -360;
   Pmax = 0;
   Gmin = -40;
   Gmax = 40;
   [PhaseOut,gain] = nicchart(Pmin,Pmax,Gmin);
   return
end

%---If 'NEW' is specified, clear axes and set HOLD ON
ni = nargin;
NewFlag = (ni==1);
if NewFlag
   cla
   hold on
end
ax = gca;

RespPlot = gcr(ax);
if ~isempty(RespPlot)
   %---If axes is part of a Response Plot, just turn on the 'Grid' property
   if ~isa(RespPlot,'resppack.nicholsplot')
      %---Only draw grid if the response object is a 'pzmap' or 'rlocus' plot
      error('Nichols chart not available for this type of response.')
   end
   set(RespPlot.AxesGrid,'Grid','on')
   
else
   %---Otherwise, draw grid lines on standard plot
   %---Remove existing grid lines/text
   delete(findall(ax,'Tag','CSTgridLines'));
   
   GridOptions = gridopts('nichols');
   if NewFlag
      % Make grid lines visible to limit picker for new grids
      GridOptions.LimInclude = 'on';
   end
   
   % Build grid
   [GridHandles,TextHandles] = nicchart(ax,GridOptions);
   
   %---Box on
   set(ax,'Box','on')
   
end
