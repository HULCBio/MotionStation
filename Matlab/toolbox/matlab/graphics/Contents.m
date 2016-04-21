% Handle Graphics.
% 
% Figure window creation and control.
%   figure     	  - Create figure window.
%   gcf        	  - Get handle to current figure.
%   clf        	  - Clear current figure.
%   shg        	  - Show graph window.
%   close      	  - Close figure.
%   refresh    	  - Refresh figure.
%   refreshdata   - Refresh data plotted in figure.
%   openfig       - Open new copy or raise existing copy of saved figure.
% 
% Axis creation and control.
%   subplot    	  - Create axes in tiled positions.
%   axes       	  - Create axes in arbitrary positions.
%   gca        	  - Get handle to current axes.
%   cla        	  - Clear current axes.
%   axis       	  - Control axis scaling and appearance.
%   box        	  - Axis box.
%   caxis      	  - Control pseudocolor axis scaling.
%   hold       	  - Hold current graph.
%   ishold     	  - Return hold state.
%
% Handle Graphics objects.
%   figure     	  - Create figure window.
%   axes       	  - Create axes.
%   line       	  - Create line.
%   text       	  - Create text.
%   patch      	  - Create patch.
%   rectangle     - Create rectangle, rounded-rectangle, or ellipse.
%   surface    	  - Create surface.
%   image      	  - Create image.
%   light      	  - Create light.
%   uicontrol  	  - Create user interface control.
%   uimenu     	  - Create user interface menu.
%   uicontextmenu - Create user interface context menu.
%
% Handle Graphics operations.
%   set        	  - Set object properties.
%   get        	  - Get object properties.
%   reset      	  - Reset object properties.
%   delete     	  - Delete object.
%   gco        	  - Get handle to current object.
%   gcbo       	  - Get handle to current callback object.
%   gcbf       	  - Get handle to current callback figure.
%   drawnow    	  - Flush pending graphics events.
%   findobj    	  - Find objects with specified property values.
%   copyobj    	  - Make copy of graphics object and its children.
%   isappdata     - Check if application-defined data exists.
%   getappdata    - Get value of application-defined data.
%   setappdata    - Set application-defined data.
%   rmappdata     - Remove application-defined data.
%
% Hardcopy and printing.
%   print      	  - Print graph or Simulink system; or save graph to M-file.
%   printopt   	  - Printer defaults.
%   orient     	  - Set paper orientation. 
%
% Utilities.
%   closereq   	  - Figure close request function.
%   newplot    	  - M-file preamble for NextPlot property.
%   ishandle   	  - True for graphics handles.
%
% ActiveX Client Functions (PC Only).
%   actxcontrol   - Create an ActiveX control.
%   actxserver    - Create an ActiveX server.
%
% See also GRAPH2D, GRAPH3D, SPECGRAPH, WINFUN.

% Printing utilities.
%   bwcontr       - Contrasting black or white color.
%   hardcopy      - Save figure window to file.
%   nodither      - Modify figure to avoid dithered lines.
%   savtoner      - Modify figure to save printer toner.
%   noanimate     - Modify figure to make object have normal erasemode.
%
% I/O utilities.
%   handle2struct - Convert Handle Graphics hierarchy to structure array.
%   struct2handle - Create Handle Graphics hierarchy from structure.
%
% Other utilities.
%   parseparams   - Finds first string argument.
%   datachildren  - Handles to figure children that contain data.
%   opengl        - Change OpenGL mode.
%
% Obsolete
%   clg           - Clear Figure (graph window).

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.34.4.1 $  $Date: 2003/10/30 18:42:21 $
