function zgrid(zeta,wn,s)
%ZGRID  Generate z-plane grid lines for a root locus or pole-zero map.
%   ZGRID generates a grid over an existing discrete z-plane root
%   locus or pole-zero map.  Lines of constant damping factor (zeta)
%   and natural frequency (Wn) are drawn in within the unit Z-plane
%   circle.
%
%   ZGRID('new') clears the current axes first and sets HOLD ON.
%
%   ZGRID(Z,Wn) plots constant damping and frequency lines for the
%   damping ratios in the vector Z and the natural frequencies in the
%   vector Wn.
%
%   ZGRID(Z,Wn,'new') clears the current axes first and sets HOLD ON.
%
%   See also: RLOCUS, PZMAP, and SGRID.

%   Marc Ullman   May 27, 1987
%   Revised: JNL 7-10-87, CMT 7-13-90, ACWG 6-21-92
%   Revised: Adam DiVergilio, 12-99, P. Gahinet 1-2001
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.24 $  $Date: 2002/04/10 06:25:53 $

%---If 'NEW' is specified, clear axes and set HOLD ON
ni = nargin;
NewFlag = (ni==1) | (ni==3);
if NewFlag
   cla
   hold on
end
ax = gca;

RespPlot = gcr(ax);
if ~isempty(RespPlot)
   %---If axes is part of a Response Plot, just turn on the 'Grid' property
   if ~isa(RespPlot,'resppack.pzplot')
      %---Only draw grid if the response object is a 'pzmap' or 'rlocus' plot
      error('Z-plane grid not available for this type of response.')
   end
   if ni>1
      % User-defined values
      Options = RespPlot.AxesGrid.GridOptions;
      Options.Damping = zeta;
      Options.Frequency = wn;  % assumes Wn supplied in the plot units
      RespPlot.AxesGrid.GridOptions = Options;
      set(RespPlot.AxesGrid,'Grid','off','Grid','on')
   else
      set(RespPlot.AxesGrid,'Grid','on')
   end
   
else
   %---Otherwise, use ZPCHART to draw grid lines
   %---Remove existing grid lines/text
   delete(findobj(ax,'Tag','CSTgridLines'));
   
   GridOptions = gridopts('pzmap');
   if ni>1
      % User-supplied grid values
      GridOptions.Damping = zeta;
      GridOptions.Frequency = wn;
   end
   if NewFlag
      % Make grid lines visible to limit picker for new grids
      GridOptions.LimInclude = 'on';
   end
   
   % Build grid
   [GridHandles,TextHandles] = zpchart(ax,GridOptions);
   
   %---Make handles visible (so user can access grid)
   set([GridHandles(:);TextHandles(:)],'HandleVisibility','on');
   
   %---Box on
   set(ax,'Box','on')
   
end
