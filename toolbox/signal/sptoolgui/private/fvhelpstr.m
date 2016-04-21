function str = fvhelpstr(tag,fig)
%FVHELPSTR  Help for Filter Viewer

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.11 $

    str{1,1} = 'Filter Viewer';
    str{1,2} = ['No help for this object (' tag ')'];

% ****                       WARNING!                       ****
% ****                                                      ****
% ****  All help text between the SWITCH TAG and OTHERWISE  ****
% ****  statements is automatically generated.  To change   ****
% ****  the help text, edit FVHELP.H and use HWHELPER to    ****
% ****  insert the changes into this file.                  ****

switch tag
case {'help','helptopicsmenu'}
str{1,1} = 'FILTER VIEWER';
str{1,2} = {
' '
'This window is a Filter Viewer.  It allows you to view several characteristics '
'of a filter which can be loaded or designed via the SPTool. You can view any '
'combination of the magnitude and phase responses, the group delay, the '
'pole-zero plot, and the impulse and step responses of the filter. Through the '
'Preferences menu item, accessible from the File menu in SPTool, you can customize '
'the layout of the 6 subplots in the Filter Viewer.'
' '
'The Filter Viewer provides some information about the filter, such as the'
'variable name where the filter is stored (Filter) and the sampling'
'frequency (Fs).  You can change Filter names, Sampling Frequency, and'
'Line Properties by right- or control-clicking on the filter''s response'
'(right-click either directly on any line or trace, or right-click on or '
'inside any subplot).'
' '
'The Toolbar has the following items:'
'  - seven zoom buttons that allow you to zoom in and out of each subplot,'
'  - a line selection menu to choose, from the multiple selected filters '
'    of the SPTool, which one filter has the Marker focus,'
'  - a line properties button to change the selected filter''s line color and'
'    line style, and'
'  - a help button which enables you to obtain detailed help on the rest '
'    of the Filter Viewer.'
' '
'To get help at any time, click once on the ''Help'' button, OR select'
'"What''s This" under the Help menu.  The mouse pointer becomes an '
'arrow with a question mark symbol.  You can then click on anything '
'in the Filter Viewer (or select a menu) to find out what it '
'is and how to use it.'
};

case 'whatsthismenu'
str{1,1} = 'GETTING HELP';
str{1,2} = {
' '
'To get help at any time, click once on the ''Help'' button, OR select'
'"What''s This" under the Help menu.  The mouse pointer becomes an '
'arrow with a question mark symbol.  You can then click on anything '
'in the Filter Viewer (or select a menu) to find out what it '
'is and how to use it.'
};

case 'closemenu'
str{1,1} = 'CLOSE MENU OPTION';
str{1,2} = {
' '
'Select this menu option to close the Filter Viewer.'
};

case 'mainframe'
str{1,1} = 'MAIN FRAME';
str{1,2} = {
' '
'In this region of the Filter Viewer, you can select which subplots to'
'display in the main window, set the scaling of various subplot axes, and'
'set the sampling frequency.'
};

case {'plotframe','plottext'}
str{1,1} = 'PLOTS FRAME';
str{1,2} = {
' '
'This frame indicates which subplots are currently displayed in the main'
'window to the right.  You can enable some or all of the plots.  Simply'
'check the corresponding box to enable a plot.  You can choose from:'
'magnitude response, phase response, group delay, pole-zero plot, impulse'
'response, and step response.'
};

case 'magcheck'
str{1,1} = 'MAGNITUDE';
str{1,2} = {
' '
'Check this box to enable the magnitude response subplot.  '
};

case {'maglist','magframe'}
str{1,1} = 'MAG SCALING';
str{1,2} = {
' '
'You can choose a scaling for the magnitude plot (linear, log, or decibels)'
'by choosing from the Magnitude popup menu.'
};

case 'phasecheck'
str{1,1} = 'PHASE';
str{1,2} = {
' '
'Check this box to enable the phase response subplot.'
};

case {'phaselist','phaseframe'}
str{1,1} = 'PHASE UNITS';
str{1,2} = {
' '
'You can choose the units for the phase (degrees or radians) by choosing'
'from the Phase popup menu.'
};

case 'groupdelay'
str{1,1} = 'GROUP DELAY';
str{1,2} = {
' '
'Check this box to enable the group delay subplot.  The group delay is'
'defined as the derivative of the phase response.'
};

case 'polezero'
str{1,1} = 'POLE-ZERO';
str{1,2} = {
' '
'Check this box to enable the pole-zero subplot.  This displays the poles'
'and zeros of the transfer function and their proximity to the unit circle.'
};

case 'impresp'
str{1,1} = 'IMPULSE RESP.';
str{1,2} = {
' '
'Check this box to enable the impulse response subplot.  This displays the'
'result of applying the filter to a discrete-time unit-height impulse at 0.'
};

case 'stepresp'
str{1,1} = 'STEP RESPONSE';
str{1,2} = {
' '
'Check this box to enable the step response subplot.  This displays the'
'result of applying the filter to a discrete-time unit-height step at 0.'
};

case {'freqframe','freqtext'}
str{1,1} = 'FREQUENCY AXIS';
str{1,2} = {
' '
'In this frame, you can set the scaling and range of the frequency axis.'
};

case {'freqsframe','freqscale','freqstext'}
str{1,1} = 'FREQ. SCALING';
str{1,2} = {
' '
'You can choose the scaling for the frequency axis (linear or log) by'
'selecting the appropriate option from this popup menu.'
};

case {'freqrframe','freqrange','freqrtext'}
str{1,1} = 'FREQ. RANGE';
str{1,2} = {
' '
'You can choose the range for the frequency axis by selecting an option from'
'this popup menu.  The options are [0, Fs/2], [0, Fs], and [-Fs/2, Fs/2],'
'where Fs in the sampling frequency displayed in the upper left-hand corner'
'of the Filter Viewer in the Toolbar.'
};

case {'filterLabel','filtlabelframe','fsbox'}
str{1,1} = 'FILTER AND Fs';
str{1,2} = {
' '
'These two variables, Filter and Fs, contain the filter name and its sampling'
'frequency, respectively, of the filter design currently selected. You can'
'change these using the edit menu of the SPTool, or using the context menu'
'options provided when you right- or control-click on any filter''s response'
'in the Filter Viewer.'
' '
'When viewing multiple filters which don''t all have the same sampling frequency,'
'the largest sampling frequency will be shown.  Also, when viewing multiple '
'filters where the names of all the selected filters do not fit in the allowed '
'space, the number of filters selected will be displayed instead of the names of '
'the individual filters selected.'
};

case 'lineprop_pushtool'
str{1,1} = 'COLORS';
str{1,2} = {
' '
'Click on this button to change the Selected filter''s line color and / or '
'line Style.'
' '
'You can also change the line color and/or line style for ANY filter'
'currently selected in the SPTool by right- or control-clicking on'
'any filter''s response, and choosing the "Line Properties..."'
'submenu for the desired filter.'
};

case 'select_pushtool'
str{1,1} = 'SELECTION';
str{1,2} = {
' '
'Click on this button to choose, from the multiple selected filters of the '
'SPTool, which one filter has the Marker focus.  The Marker measurements '
'in track and slope mode, and peaks and valleys, apply to the selected signal.'
' '
'You can also change the selected filter by clicking on its waveform in the '
'main axes.'
' '
'USEABILITY TIP:  Sometimes you might have many filters displayed and'
'it is not clear which filter you have selected (so you can''t tell'
'which filter the Marker is measuring).  In that case, move the mouse'
'over to this button, but don''t click; a small window will pop up near'
'the mouse and display the current selected signal''s name.'
};

case 'fvzoom:mousezoom'
str{1,1} = 'MOUSE ZOOM';
str{1,2} = {
' '
'Clicking this button puts you in "Mouse Zoom" mode. In this mode, the mouse'
'pointer becomes a cross when it is inside any of the six subplot areas.'
'You can click and drag a rectangle in a subplot, and the axes display will'
'zoom in to that region.  If you click with the left button at a point in a'
'subplot, the axes display will zoom in to that point for a more detailed'
'look at the data at that point.  Similarly, you can click with the right'
'mouse button (shift click on a Mac) at a point in a subplot to zoom out'
'from that point for a wider view of the data.  '
' '
'To get out of the mouse zoom mode without zooming in or out, click on the'
'Mouse Zoom button again.'
' '
'Note that Zooming in on a plot with the mouse SELECTS that plot; the'
'plot is highlighted in red and the Markers move to that plot.  You can'
'zoom in and out of the selected plot with the Full View, Zoom-in Y, Zoom-out Y, '
'Zoom-in X and Zoom-out X buttons.'
' '
'ZOOM PERSISTENCE'
' '
'Normally you leave zoom mode as soon as you zoom in or out once.  In order'
'to zoom in or out again, the Mouse Zoom button must be clicked again.'
'However, the mouse zoom mode will remain enabled after a zoom if the box'
'labeled ''Stay in Zoom Mode after Zoom'' is checked in the Preferences for'
'SPTool window.  The Preferences for SPTool window can be opened by'
'selecting Preferences under the File menu in SPTool.'
};

case 'fvzoom:zoomoutall'
str{1,1} = 'FULL VIEW - ALL';
str{1,2} = {
' '
'Clicking this button restores the axes limits of ALL of the subplots.'
};

case 'fvzoom:zoomout'
str{1,1} = 'FULL VIEW';
str{1,2} = {
' '
'Clicking this button restores the axes limits of the currently selected'
'subplot ONLY.  The currently selected subplot is highlighted in red, and '
'if the "Markers" are enabled, contains the Marker lines.'
};

case 'fvzoom:zoominy'
str{1,1} = 'ZOOM IN Y';
str{1,2} = {
' '
'Clicking this toolbar button zooms in on the filter''s response, cutting '
'the vertical range of the "main axes" in half.  The x-limits (horizontal '
'scaling) of the "main axes" are not changed.  '
' '
'The "main axes" is the subplot which currently has the Markers in it,'
'and is highlighted red. '
' '
'Note: in the Pole/Zero subplot, both X- and Y-directions are zoomed-in'
'since the aspect ratio of the Z-plane axes is 1:1.'
};

case 'fvzoom:zoomouty'
str{1,1} = 'ZOOM OUT Y';
str{1,2} = {
' '
'Clicking this toolbar button zooms out from the filter''s response, '
'expanding the vertical range of the "main axes" by a factor of two.  '
'The x-limits (horizontal scaling) of the "main axes" are not changed.'
' '
'The "main axes" is the subplot which currently has the Markers in it,'
'and is highlighted in red.'
' '
'Note: in the Pole/Zero subplot, both X- and Y-directions are zoomed-out'
'since the aspect ratio of the Z-plane axes is 1:1.'
};

case 'fvzoom:zoominx'
str{1,1} = 'ZOOM IN X';
str{1,2} = {
' '
'Clicking this toolbar button zooms in on the filter''s response, cutting the '
'horizontal range of the "main axes" in half.  The y-limits (vertical '
'scaling) of the "main axes" are not changed.'
' '
'The "main axes" is the subplot which currently has the Markers in it,'
'and is highlighted in red.'
' '
'Note: in the Pole/Zero subplot, both X- and Y-directions are zoomed-in'
'since the aspect ratio of the Z-plane axes is 1:1.'
};

case 'fvzoom:zoomoutx'
str{1,1} = 'ZOOM OUT X';
str{1,2} = {
' '
'Clicking this toolbar button zooms out from the filter''s response, expanding the '
'horizontal range of the main axes by a factor of two.  The y-limits (vertical '
'scaling) of the "main axes" are not changed.'
' '
'The "main axes" is the subplot which currently has the Markers in it,'
'and is highlighted in red.'
' '
'Note: in the Pole/Zero subplot, both X- and Y-directions are zoomed-out'
'since the aspect ratio of the Z-plane axes is 1:1.'
};

case 'magaxes'
str{1,1} = 'MAGNITUDE';
str{1,2} = {
' '
'This axes displays the magnitude of the frequency response of the currently'
'selected filters.'
' '
'Right- or control-click this plot for a menu of filters currently'
'displayed in the Filter Viewer.  This menu provides submenus for'
'changing any of these filter''s name, sampling frequency, or line style.'
};

case 'phaseaxes'
str{1,1} = 'PHASE';
str{1,2} = {
' '
'This axes displays the phase of the frequency response of the currently'
'selected filters.'
' '
'Right- or control-click this plot for a menu of filters currently'
'displayed in the Filter Viewer.  This menu provides submenus for'
'changing any of these filter''s name, sampling frequency, or line style.'
};

case 'delayaxes'
str{1,1} = 'GROUP DELAY';
str{1,2} = {
' '
'This axes displays the group delay (defined as the derivative of the phase'
'of the frequency response) of the currently selected filters.'
' '
'Right- or control-click this plot for a menu of filters currently'
'displayed in the Filter Viewer.  This menu provides submenus for'
'changing any of these filter''s name, sampling frequency, or line style.'
};

case 'pzaxes'
str{1,1} = 'POLE-ZERO';
str{1,2} = {
' '
'This axes displays the poles and zeros of the transfer function of the'
'currently selected filters in relationship to the unit circle.'
' '
'Right- or control-click this plot for a menu of filters currently'
'displayed in the Filter Viewer.  This menu provides submenus for'
'changing any of these filter''s name, sampling frequency, or line style.'
};

case 'impaxes'
str{1,1} = 'IMPULSE RESPONSE';
str{1,2} = {
' '
'This axes displays the response of the currently selected filters to a'
'discrete-time unit-height impulse at 0.'
' '
'Right- or control-click this plot for a menu of filters currently'
'displayed in the Filter Viewer.  This menu provides submenus for'
'changing any of these filter''s name, sampling frequency, or line style.'
};

case 'stepaxes'
str{1,1} = 'STEP RESPONSE';
str{1,2} = {
' '
'This axes displays the response of the currently selected filters to a'
'discrete-time unit-height step function.'
' '
'Right- or control-click this plot for a menu of filters currently'
'displayed in the Filter Viewer.  This menu provides submenus for'
'changing any of these filter''s name, sampling frequency, or line style.'
};

case 'magline'
str{1,1} = 'MAGNITUDE RESP.';
str{1,2} = {
' '
'This line is the magnitude of the frequency response of one of the'
'currently selected filters.  When not in mouse zoom mode, you can click and'
'drag on the response to move it around this subplot.'
' '
'Click on this line to select this filter, and this subplot.  When'
'this filter and subplot are selected, the subplot is highlighted'
'in red, and the Markers move to the subplot.'
' '
'Right- or control-click this line for a menu of filters currently'
'displayed in the Filter Viewer.  This menu provides submenus for'
'changing any of these filter''s name, sampling frequency, or line style.'
};

case 'phaseline'
str{1,1} = 'PHASE RESPONSE';
str{1,2} = {
' '
'This line is the phase of the frequency response of one of the currently'
'selected filters.  When not in mouse zoom mode, you can click and drag on'
'the response to move it around this subplot.'
' '
'Click on this line to select this filter, and this subplot.  When'
'this filter and subplot are selected, the subplot is highlighted'
'in red, and the Markers move to the subplot.'
' '
'Right- or control-click this line for a menu of filters currently'
'displayed in the Filter Viewer.  This menu provides submenus for'
'changing any of these filter''s name, sampling frequency, or line style.'
' '
};

case 'delayline'
str{1,1} = 'GROUP DELAY';
str{1,2} = {
' '
'This line is the group delay (defined as the derivative of the phase of the'
'frequency response) of one of the currently selected filters.  When not in '
'mouse zoom mode, you can click and drag on the line to move it around this'
'subplot.'
' '
'Click on this line to select this filter, and this subplot.  When'
'this filter and subplot are selected, the subplot is highlighted'
'in red, and the Markers move to the subplot.'
' '
'Right- or control-click this line for a menu of filters currently'
'displayed in the Filter Viewer.  This menu provides submenus for'
'changing any of these filter''s name, sampling frequency, or line style.'
};

case {'implinedots','implinestem'}
str{1,1} = 'IMPULSE RESP.';
str{1,2} = {
' '
'This stem plot is the response of the currently selected filters to a'
'discrete-time unit-height impulse at 0.  When not in mouse zoom mode, you'
'can click and drag on the response to move it around this subplot.'
' '
'Click on this line to select this filter, and this subplot.  When'
'this filter and subplot are selected, the subplot is highlighted'
'in red, and the Markers move to the subplot.'
' '
'Right- or control-click this line for a menu of filters currently'
'displayed in the Filter Viewer.  This menu provides submenus for'
'changing any of these filter''s name, sampling frequency, or line style.'
};

case {'steplinedots','steplinestem'}
str{1,1} = 'STEP RESPONSE';
str{1,2} = {
' '
'This stem plot is the response of the currently selected filters to a'
'discrete-time unit-height step function.  When not in mouse zoom mode, you'
'can click and drag on the response to move it around this subplot.'
' '
'Click on this line to select this filter, and this subplot.  When'
'this filter and subplot are selected, the subplot is highlighted'
'in red, and the Markers move to the subplot.'
' '
'Right- or control-click this line for a menu of filters currently'
'displayed in the Filter Viewer.  This menu provides submenus for'
'changing any of these filter''s name, sampling frequency, or line style.'
};

case 'polesline'
str{1,1} = 'POLE';
str{1,2} = {
' '
'This ''x'' represents a pole of the transfer function of the current'
'filter.'
' '
'Click on this ''x'' to select this filter, and this subplot.  When'
'this filter and subplot are selected, the subplot is highlighted'
'in red, and the Markers move to the subplot.  '
' '
'Right- or control-click this ''x'' for a menu of filters currently'
'displayed in the Filter Viewer.  This menu provides submenus for'
'changing any of these filter''s name, sampling frequency, or line style.'
};

case 'zerosline'
str{1,1} = 'ZERO';
str{1,2} = {
' '
'This ''o'' represents a zero of the transfer function of one of the currently'
'selected filters.'
' '
'Click on this ''o'' to select this filter, and this subplot.  When'
'this filter and subplot are selected, the subplot is highlighted'
'in red, and the Markers move to the subplot.'
' '
'Right- or control-click this ''o'' for a menu of filters currently'
'displayed in the Filter Viewer.  This menu provides submenus for'
'changing any of these filter''s name, sampling frequency, or line style.'
};

case 'unitcircle'
str{1,1} = 'UNIT CIRCLE';
str{1,2} = {
' '
'This dotted line is the unit circle.  Depending on the type of filter,'
'the proximity of the poles and zeros to the unit circle may yield'
'information about the frequency response.'
};

case 'rulertoggle'
str{1,1} = 'MARKERS';
str{1,2} = {
' '
'Click this button to toggle the Markers on and off.'
'The Markers are for making measurements and comparisons of'
'the displayed traces.  Readouts appear at the bottom of the screen'
'when they are on, and two "Marker Lines" will appear'
'in the selected subplot.  '
' '
'Sometimes the markers will disappear off the screen (when zooming'
'in for example).  To bring them into view, click the small box with a '
'"1" or "2" that appears on the upper right corner of the selected'
'subplot; this centers the desired marker in the selected plot.'
'You can also enter a new Marker value in the Marker edit boxes'
'beneath the plot to bring the markers within the current plot limits.'
};

case 'showmarkersmenu'
str{1,1} = 'MARKERS';
str{1,2} = {
' '
'Select this menu item to toggle the Markers on and off.'
'The Markers are for making measurements and comparisons of'
'the displayed traces.  Readouts appear at the bottom of the screen'
'when they are on, and two "Marker Lines" will appear'
'in the selected subplot.  '
' '
'Sometimes the markers will disappear off the screen (when zooming'
'in for example).  To bring them into view, click the small box with a '
'"1" or "2" that appears on the upper right corner of the selected'
'subplot; this centers the desired marker in the selected plot.'
'You can also enter a new Marker value in the Marker edit boxes'
'beneath the plot to bring the markers within the current plot limits.'
};

case {'markerlabel1','markerlabel2'}
str{1,1} = 'MARKERS';
str{1,2} = {
' '
'This is the read-out area for the Markers.  Marker 1 is on'
'the left of the read-out area, and is represented by a solid'
'line in the subplot.  Marker 2 is on the right of the read-out'
'area and is represented by a dashed line in the subplot.'
' '
'Click the Marker On/Off switch in the toolbar to toggle the '
'Markers on and off. The Markers are for making measurements and '
'comparisons of the displayed traces.  Read-outs appear at the '
'bottom of the screen when they are on, and two "Marker Lines" will '
'appear in the selected subplot.  '
};

case 'ruler1line'
str{1,1} = 'Marker 1';
str{1,2} = {
' '
'You have clicked on Marker 1.  Drag this indicator with the mouse to measure'
'features of your selected data.  The value of the Marker is shown textually'
'in the Marker area on the bottom of the Filter Viewer window.'
};

case 'ruler2line'
str{1,1} = 'Marker 2';
str{1,2} = {
' '
'You have clicked on Marker 2.  Drag this indicator with the mouse to measure'
'features of your selected data.  The value of the Marker is shown textually'
'in the Marker area on the bottom of the Filter Viewer window.'
};

case 'slopeline'
str{1,1} = 'SLOPE';
str{1,2} = {
' '
'You have clicked on the Slope Line of the Markers.  This line goes through'
'the points (x1,y1) and (x2,y2) defined by Marker 1 and Marker 2 respectively.'
'Its slope is labeled as ''Slope''.  As you drag either Marker 1 or Marker 2 left'
'and right, the Slope Line is updated.'
};

case 'peakline'
str{1,1} = 'PEAK';
str{1,2} = {
' '
'You have clicked on a peak of the currently selected filter.  To measure'
'this peak, move one of the Markers on top of it in "track" mode.'
};

case 'valleyline'
str{1,1} = 'VALLEY';
str{1,2} = {
' '
'You have clicked on a peak of the currently selected filter. To measure'
'this valley, move one of the Markers on top of it in "track" mode.'
};

case 'ruler1button'
str{1,1} = 'FIND Marker 1';
str{1,2} = {
' '
'Click on this button to bring Marker 1 to the center of the main axes.  This'
'button is only visible when Marker 1 is "off the screen", that is, when'
'Marker 1 is not visible in the main axes.'
};

case 'ruler2button'
str{1,1} = 'FIND Marker 2';
str{1,2} = {
' '
'Click on this button to bring Marker 2 to the center of the main axes.  This'
'button is only visible when Marker 2 is "off the screen", that is, when'
'Marker 2 is not visible in the main axes.'
};

case {'ruleraxes','rulerlabel','rulerframe'}
str{1,1} = 'MARKERS';
str{1,2} = {
' '
'This area of the Filter Viewer allows you to read and control the values of'
'the Markers in the main axes.  Use the Markers to make measurements on'
'filters, such as distances between features, heights of peaks, and slope'
'information.'
};

case {'ruler:vertical','vertical'}
str{1,1} = 'VERTICAL';
str{1,2} = {
' '
'Click this button to change the Markers to Vertical mode.  In Vertical mode,'
'you can change the Markers'' x-values (i.e., horizontal position) by either'
'  - dragging them left and right with the mouse, or'
'  - entering their values in the x1 and x2 edit boxes.'
' '
'The difference x2-x1 is displayed as dx.'
};

case {'ruler:horizontal','horizontal'}
str{1,1} = 'HORIZONTAL';
str{1,2} = {
' '
'Click this button to change the Markers to Horizontal mode.  In Horizontal'
'mode, you can change the Markers'' y-values (i.e., vertical position) by'
'either'
'  - dragging them up and down with the mouse, or'
'  - entering their values in the y1 and y2 edit boxes.'
' '
'The difference y2-y1 is displayed as dy.'
};

case {'ruler:track','track'}
str{1,1} = 'TRACK';
str{1,2} = {
' '
'Click this button to change the Markers to Track mode.  This mode is just'
'like Vertical mode, in which you can change the Markers'' x-values (i.e.,'
'horizontal position) by either'
'  - dragging them left and right with the mouse, or'
'  - entering their values in the y1 and y2 edit boxes.'
' '
'In Track mode, the Markers also "track" a filter''s response, so that you can'
'see the y-values of the filter''s response at the x-values of the Markers.'
'The value dy is equal to y2-y1.  You can change which filter is tracked by'
'clicking on a filter in the main axes, or by clicking on the toolbar button'
'for "selection" (it looks like a little list with an arrow pointing to one'
'of the variable names).'
' '
'Track mode is not available in the pole-zero plot.'
};

case {'ruler:slope','slope'}
str{1,1} = 'SLOPE';
str{1,2} = {
' '
'Click this button to change the Markers to Slope mode.  This mode is just'
'like Track mode, in which you can change the Markers'' x-values (i.e.,'
'horizontal position) by either'
'  - dragging them left and right with the mouse, or'
'  - entering their values in the y1 and y2 edit boxes.'
' '
'In Slope mode, the Markers "track" a filter''s response, so that you can see'
'the y-values of the filter''s response at the x-values of the Markers.  The'
'value dy is equal to y2-y1.  The line connecting (x1,y1) and (x2,y2) is'
'included in the main plot, so you can approximate derivatives and slopes of'
'the filter''s response.  The value ''Slope'' is equal to dy/dx.'
' '
'You can change which filter is tracked by clicking on a filter response in'
'any axes, or by clicking on the toolbar button for "selection" (it looks '
'like a little list with an arrow pointing to one of the variable names).'
' '
'Slope mode is not available in the pole-zero plot.'
};

case 'x1label'
str{1,1} = 'X1';
str{1,2} = {
' '
'This is the X value of Marker 1.  Change this value by dragging Marker 1 back'
'and forth with the mouse, or clicking in the box labeled "X" and typing in a'
'number.'
};

case 'rulerbox1'
str{1,1} = 'Marker 1';
str{1,2} = {
' '
'For Vertical, Track and Slope modes:'
'  Change the value in this box to set the x-location of Marker 1.'
' '
'For Horizontal mode:'
'  Change the value in this box to set the y-location of Marker 1.'
' '
'When you drag Marker 1 with the mouse, the value in this box changes'
'correspondingly.'
};

case {'y1label','y1text'}
str{1,1} = 'Y1';
str{1,2} = {
' '
'This is the Y value of Marker 1.  '
' '
'In Track and Slope Marker modes, y1 is the value of the filter response axes'
'that is being tracked by Marker 1 (designated by Selection).'
' '
'In Horizontal Marker mode, you can enter a value in the box labeled "Y" to'
'change the position of the Marker.'
};

case 'x2label'
str{1,1} = 'X2';
str{1,2} = {
' '
'This is the X value of Marker 2.  Change this value by dragging Marker 2 left'
'and right with the mouse, or clicking in the box labeled "X" and typing in a'
'number.'
};

case 'rulerbox2'
str{1,1} = 'Marker 2';
str{1,2} = {
' '
'For Vertical, Track and Slope modes:'
'  Change the value in this box to set the x-location of Marker 2.'
' '
'For Horizontal mode:'
'  Change the value in this box to set the y-location of Marker 2.'
' '
'When you drag Marker 2 with the mouse, the value in this box changes'
'correspondingly.'
};

case {'y2label','y2text'}
str{1,1} = 'Y2';
str{1,2} = {
' '
'This is the Y2 value of Marker 2.  '
' '
'In Track and Slope Marker modes, y2 is the value of the filter''s response in'
'the main axes that is being tracked by Marker 2 (designated by Selection).'
' '
'In Horizontal Marker mode, you can enter a value in the box labeled "Y" to'
'change the position of the Marker.'
};

case {'dxlabel','dxtext'}
str{1,1} = 'DX';
str{1,2} = {
' '
'Delta X value.  This is the value of x2 - x1.'
};

case {'dylabel','dytext'}
str{1,1} = 'DY';
str{1,2} = {
' '
'Delta Y value.  This is the value of y2 - y1.'
};

case {'dydxtext','dydxlabel'}
str{1,1} = 'SLOPE';
str{1,2} = {
' '
'Delta Y / Delta X value.  This is the value of dy / dx,'
'i.e. (y2 - y1) / (x2 - x1).'
};

case {'ruler:peaks','peaks'}
str{1,1} = 'PEAKS';
str{1,2} = {
' '
'Click on this button to see all the local maxima of the currently selected'
'filter response.  Change which filter is selected by clicking on any filter'
'response in any axes, or by selecting it in the menu obtained by the "Selection" '
'button of the toolbar.'
' '
'In track and slope mode, the Markers are constrained to the peaks in this'
'mode.  In vertical mode, the peaks are only visual and do not affect the'
'behavior of the Markers.'
' '
'It is possible to display both the peaks and valleys at the same time.'
' '
'You can''t select peaks or valleys in the pole-zero plot.'
};

case {'ruler:valleys','valleys'}
str{1,1} = 'VALLEYS';
str{1,2} = {
' '
'Click on this button to see all the local minima of the currently selected'
'filter response.  Change which filter is selected by clicking on any filter'
'response in any axes, or by selecting it in the menu obtained by the "Selection" '
'button of the toolbar.'
' '
'In track and slope mode, the Markers are constrained to the valleys in this'
'mode.  In vertical mode, the valleys are only visual and do not affect the'
'behavior of the Markers.'
' '
'It is possible to display both the peaks and valleys at the same time.'
' '
'You can''t select peaks or valleys in the pole-zero plot.'
};

case 'saverulerbutton'
str{1,1} = 'SAVE MARKERS';
str{1,2} = {
' '
'Clicking this button displays a dialogue box which allows you to enter a'
'variable name to save a structure in the MATLAB workspace with the fields'
'x1, y1, x2, y2, dx, dy, dydx, peaks, and valleys.'
' '
'Any undefined values will be set to NaN.'
};

case 'rulerpopup'
str{1,1} = 'MarkerPOPUP';
str{1,2} = {
' '
'Click on this menu to choose which subplot, from the six possible subplots'
'containing filter responses, that you want the Markers to focus.  Selecting'
'a subplot that is not visible makes that subplot visible and moves the'
'Markers to that subplot.'
};


otherwise

%str{1} = {
%    'HELP for FILTVIEW'
%    ' '
%    'You have clicked on an object with tag'
%    ['   ''' tag ''''] 
%};

end

