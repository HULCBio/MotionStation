function str = sbhelpstr(tag,fig)
%SBHELPSTR  Display Help for Signal Browser

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.11 $

    str{1,1} = 'Signal Browser';
    str{1,2} = {['No help for this object (' tag ')']};

% ****                       WARNING!                       ****
% ****                                                      ****
% ****  All help text between the SWITCH TAG and OTHERWISE  ****
% ****  statements is automatically generated.  To change   ****
% ****  the help text, edit SBHELP.H and use HWHELPER to    ****
% ****  insert the changes into this file.                  ****

switch tag
case 'arraysigs'
str{1,1} = 'ARRAY SIGNALS';
str{1,2} = {
' '
'This toolbar button is enabled any time you have selected an "array signal" '
'in the SPTool.  An "array signal" is simply an SPTool Signal object that'
'has a matrix (not just a vector) as data.  The different columns of the'
'matrix are treated as separate signals.'
' '
'Click on this button to bring up a window which allows you to enter a '
'column index vector for one of the currently selected array signals.  Valid '
'index vectors are of the form ''1'' or ''1:3'' or ''[1 3 5]''.  '
' '
'All array signals start out with only the first column displayed.'
};

case 'sbzoom:mousezoom'
str{1,1} = 'MOUSE ZOOM';
str{1,2} = {
' '
'Clicking this button puts you in "Mouse Zoom" mode. In this mode, the '
'mouse pointer becomes a cross when it is inside the main axes area.  You '
'can click and drag a rectangle in the main axes, and the main axes display '
'will zoom in to that region.  If you click with the left button at a point '
'in the main axes, the main axes display will zoom in to that point for a '
'more detailed look at the data at that point.  Similarly, you can click '
'with the right mouse button (shift click on the Mac) at a point in the '
'main axes to zoom out from that point for a wider view of the data.  In '
'each case, the panner is updated to highlight the region of data displayed '
'in the main axes.'
' '
'To get out of mouse zoom mode without zooming in or out, click on the '
'Mouse Zoom button again.'
};

case 'sbzoom:zoomout'
str{1,1} = 'FULL VIEW';
str{1,2} = {
' '
'Clicking this button restores the axes limits of the plot so that all '
'signals displayed are fully viewed. '
};

case 'sbzoom:zoominy'
str{1,1} = 'ZOOM IN Y';
str{1,2} = {
' '
'Clicking this button zooms in on the signals, cutting the vertical range '
'of the main axes in half.  The x-limits (horizontal scaling) of the main '
'axes are not changed.'
};

case 'sbzoom:zoomouty'
str{1,1} = 'ZOOM OUT Y';
str{1,2} = {
' '
'Clicking this button zooms out from the signals, expanding the vertical '
'range of the main axes by a factor of two.  The x-limits (horizontal '
'scaling) of the main axes are not changed.'
};

case 'sbzoom:zoominx'
str{1,1} = 'ZOOM IN X';
str{1,2} = {
' '
'Clicking this button zooms in on the signals, cutting the horizontal range '
'of the main axes in half.  The y-limits (vertical scaling) of the main '
'axes are not changed.'
};

case 'sbzoom:zoomoutx'
str{1,1} = 'ZOOM OUT X';
str{1,2} = {
' '
'Clicking this button zooms out from the signals, expanding the horizontal '
'range of the main axes by a factor of two.  The y-limits (vertical '
'scaling) of the main axes are not changed.'
};

case {'help',' helptopicsmenu'}
str{1,1} = 'SIGNAL BROWSER';
str{1,2} = {
' '
'This window is a Signal Browser.  It provides a graphical view of the '
'Signal objects currently selected in the SPTool.  To view a signal, just '
'click on it in the SPTool, and it is displayed here.'
' '
'The Signal Browser consists of three essential tools:'
'  1) zoom controls for getting a closer look at signal'
'     features.'
'  2) a "Panner" for seeing what part of the signal is'
'     currently being displayed, and quickly moving the'
'     view to other signal features.'
'  3) "Markers" for making signal measurements and'
'     comparisons.'
' '
'CONTEXT MENU'
' '
'Right click, or click while holding the CONTROL key, on the main axes '
'in this window, in order to open a context menu for the signal browser.'
'The context menu has a list of the currently selected Signals in the'
'SPTool and provides choices that allow you to change'
'   1) the name of a signal,'
'   2) a signal''s sampling frequency, '
'   3) how to display complex signals (if any of the currently'
'      selected signals in the SPTool is complex), and'
'   4) which columns of a signal are to be displayed (if the'
'      signal is an array signal).'
};

str{2,1} = 'GETTING HELP';
str{2,2} = {
'To get help at any time, click once on the ''Help'' button.  The mouse '
'pointer becomes an arrow with a question mark symbol.  You can then click '
'on anything in the Signal Browser, including the options under the menu '
'items, to find out what it is and how to use it.'
};

case 'whatsthismenu'
str{1,1} = 'GETTING HELP';
str{1,2} = {
' '
'To get help at any time, click once on the ''Help'' button, OR select'
'"What''s This" under the Help menu.  The mouse pointer becomes an '
'arrow with a question mark symbol.  You can then click on anything '
'in the Signal Browser, including the options under the menu items, '
'to find out what it is and how to use it.'
};

case 'complex_selection'
str{1,1} = 'COMPLEX DISPLAY';
str{1,2} = {
' '
'The Signal Browser plots either the real, imaginary, magnitude, or angle '
'of complex signals.  When any of the variables selected in the SPTool is '
'complex, this toolbar button becomes enabled. '
' '
'The Complex Display mode affects ALL of the variables in the current '
'selection - even those that are just real.  This mode can also be'
'set by right- or control-clicking on a signal, and selecting the'
'desired mode from the resultant context menu.'
};

case 'mainaxes'
str{1,1} = 'MAIN AXES';
str{1,2} = {
'You have clicked in the main axes of the Signal Browser.  This area '
'displays all of the signals currently selected in the SPTool.'
' '
'CONTEXT MENU'
' '
'Right click, or click while holding the CONTROL key, on this main axes,'
'in order to open a context menu for the signal browser.'
'The context menu has a list of the currently selected Signals in the'
'SPTool and provides choices that allow you to change'
'   1) the name of a signal,'
'   2) a signal''s sampling frequency, '
'   3) how to display complex signals (if any of the currently'
'      selected signals in the SPTool is complex), and'
'   4) which columns of a signal are to be displayed (if the'
'      signal is an array signal).'
};

case 'mainaxestitle'
str{1,1} = 'MAIN AXES TITLE';
str{1,2} = {
'You have clicked on the main axes title of the Signal Browser.  '
'This title displays the names of all of the signals currently '
'selected in the SPTool.  '
' '
'If just a single signal is selected, the title includes the '
'signal''s size, sampling frequency, and whether the signal'
'is real or complex.'
};

case 'mainaxesylabel'
str{1,1} = 'Y-LABEL';
str{1,2} = {
' '
'You can change the Y-Label in the Preferences for SPTool window, by '
'choosing Preferences under the File menu in SPTool and then selecting '
'Signal Browser.'
};

case 'mainaxesxlabel'
str{1,1} = 'X-LABEL';
str{1,2} = {
' '
'You can change X-Label in the Preferences for SPTool window, by choosing '
'Preferences under the File menu in SPTool and then selecting Signal '
'Browser.'
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
'You have clicked on Marker 1.  Drag this indicator with the mouse to '
'measure features of your selected data.  The value of the Marker is shown '
'textually in the Marker area on the bottom of the Signal Browser window.'
};

case 'ruler2line'
str{1,1} = 'Marker 2';
str{1,2} = {
' '
'You have clicked on Marker 2.  Drag this indicator with the mouse to '
'measure features of your selected data.  The value of the Marker is shown '
'textually in the Marker area on the bottom of the Signal Browser window.'
};

case 'slopeline'
str{1,1} = 'SLOPE';
str{1,2} = {
' '
'You have clicked on the Slope Line of the Markers.  This line goes through '
'the points (x1,y1) and (x2,y2) defined by Marker 1 and Marker 2 '
'respectively.  Its slope is labeled as ''Slope''.  As you drag either Marker 1 or '
'Marker 2 left and right, the Slope Line is updated.'
};

case 'peakline'
str{1,1} = 'PEAK';
str{1,2} = {
' '
'You have clicked on a peak of the currently selected signal.  To measure '
'this peak, move one of the Markers on top of it in "track" mode.'
};

case 'valleyline'
str{1,1} = 'VALLEY';
str{1,2} = {
' '
'You have clicked on a peak of the currently selected signal. To measure '
'this valley, move one of the Markers on top of it in "track" mode. '
};

case 'ruler1button'
str{1,1} = 'FIND Marker 1';
str{1,2} = {
' '
'Click on this button to bring Marker 1 to the center of the main axes.  '
'This button is only visible when Marker 1 is "off the screen", that is, '
'when Marker 1 is not visible in the main axes.'
};

case 'ruler2button'
str{1,1} = 'FIND Marker 2';
str{1,2} = {
' '
'Click on this button to bring Marker 2 to the center of the main axes.  '
'This button is only visible when Marker 2 is "off the screen", that is, '
'when Marker 2 is not visible in the main axes.'
};

case {'ruleraxes','rulerlabel','rulerframe'}
str{1,1} = 'MARKERS';
str{1,2} = {
' '
'This area of the Signal Browser allows you to read and control the values '
'of the Markers in the main axes.  Use the Markers to make measurements on '
'signals, such as distances between features, heights of peaks, and slope '
'information.'
};

case {'ruler:vertical','vertical'}
str{1,1} = 'VERTICAL';
str{1,2} = {
' '
'Click this button to change the Markers to Vertical mode.  In Vertical '
'mode, you can change the Markers'' x-values (i.e., horizontal position) by '
'either'
'  - dragging them left and right with the mouse, or'
'  - entering their values in the x1 and x2 edit boxes.'
' '
'The difference x2-x1 is displayed as dx.'
};

case {'ruler:horizontal','horizontal'}
str{1,1} = 'HORIZONTAL';
str{1,2} = {
' '
'Click this button to change the Markers to Horizontal mode.  In Horizontal '
'mode, you can change the Markers'' y-values (i.e., vertical position) by '
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
'Click this button to change the Markers to Track mode.  This mode is just '
'like Vertical mode, in which you can change the Markers'' x-values (i.e., '
'horizontal position) by either'
'  - dragging them left and right with the mouse, or'
'  - entering their values in the y1 and y2 edit boxes.'
' '
'In Track mode, the Markers also "track" a signal, so that you can see the '
'y-values of the signal at the x-values of the Markers.  The value dy is '
'equal to y2-y1.  You can change which signal is tracked by clicking on a '
'signal in the main axes, or by pushing the ''Select Trace'' button in'
'the toolbar to pick the desired signal from a list of those signals'
'currently selected in the SPTool.'
};

case {'ruler:slope','slope'}
str{1,1} = 'SLOPE';
str{1,2} = {
' '
'Click this button to change the Markers to Slope mode.  This mode is just '
'like Track mode, in which you can change the Markers'' x-values (i.e., '
'horizontal position) by either'
'  - dragging them left and right with the mouse, or'
'  - entering their values in the y1 and y2 edit boxes.'
' '
'In Slope mode, the Markers "track" a signal, so that you can see the '
'y-values of the signal at the x-values of the Markers.  The value dy is '
'equal to y2-y1.  The line connecting (x1,y1) and (x2,y2) is included in '
'the main plot, so you can approximate derivatives and slopes of the '
'signal.  The value ''Slope'' is equal to dy/dx.'
' '
'You can change which signal is tracked by clicking on a '
'signal in the main axes, or by pushing the ''Select Trace'' button in'
'the toolbar to pick the desired signal from a list of those signals'
'currently selected in the SPTool.'
};

case 'x1label'
str{1,1} = 'X1';
str{1,2} = {
' '
'This is the X value of Marker 1.  Change this value by dragging Marker 1 '
'back and forth with the mouse, or clicking in the box labeled "X" and '
'typing in a number.'
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
'When you drag Marker 1 with the mouse, the value in this box changes '
'correspondingly.'
};

case {'y1label','y1text'}
str{1,1} = 'Y1';
str{1,2} = {
' '
'This is the Y value of Marker 1.  '
' '
'In Track and Slope Marker modes, y1 is the value of the signal in the main '
'axes that is being tracked by Marker 1 (designated by (line) "Selection").'
' '
'In Horizontal Marker mode, you can enter a value in the box labeled "Y" to '
'change the position of the Marker.'
};

case 'x2label'
str{1,1} = 'X2';
str{1,2} = {
' '
'This is the X value of Marker 2.  Change this value by dragging Marker 2 '
'left and right with the mouse, or clicking in the box labeled "X" and '
'typing in a number.'
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
'When you drag Marker 2 with the mouse, the value in this box changes '
'correspondingly.'
};

case {'y2label','y2text'}
str{1,1} = 'Y2';
str{1,2} = {
' '
'This is the Y2 value of Marker 2.  '
' '
'In Track and Slope Marker modes, y2 is the value of the signal in the main '
'axes that is being tracked by Marker 2 (designated by (line) "Selection").'
' '
'In Horizontal Marker mode, you can enter a value in the box labeled "Y" to '
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
'Click on this button to see all the local maxima of the currently selected '
'signal.  Change which signal is selected by clicking on its waveform in '
'the main axes, or by selecting it in the menu obtained by the "Selection" '
'button of the toolbar.'
' '
'In track and slope mode, the Markers are constrained to the peaks in this '
'mode.  In vertical mode, the peaks are only visual and do not affect the '
'behavior of the Markers.'
' '
'It is possible to display both the peaks and valleys at the same time.'
};

case {'ruler:valleys','valleys'}
str{1,1} = 'VALLEYS';
str{1,2} = {
' '
'Click on this button to see all the local minima of the currently selected '
'signal.  Change which signal is selected by clicking on its waveform in '
'the main axes, or by selecting it in the menu obtained by the "Selection" '
'button of the toolbar.'
' '
'In track and slope mode, the Markers are constrained to the valleys in this '
'mode.  In vertical mode, the valleys are only visual and do not affect the '
'behavior of the Markers.'
' '
'It is possible to display both the peaks and valleys at the same time.'
};

case 'saverulerbutton'
str{1,1} = 'SAVE MARKERS';
str{1,2} = {
' '
'Clicking this button displays a dialogue box which allows you to enter a '
'variable name to save a structure in the MATLAB workspace with the fields '
'x1, y1, x2, y2, dx, dy, dydx, peaks, and valleys.'
' '
'Any undefined values will be set to NaN.'
};

case {'panaxes','pannerxlabel','pandown:0'}
str{1,1} = 'PANNER';
str{1,2} = {
' '
'This small, skinny axes is used to give a panoramic view of the signals '
'displayed in the main axes above it.  When you zoom in on the main axes, '
'the patch in the Panner highlights the section of the plot that is '
'currently in view in the main axes.  You can then drag this patch with the '
'mouse to pan across your signal data dynamically.'
};

case 'closemenu'
str{1,1} = 'CLOSE';
str{1,2} = {
' '
'Select this menu item to close the Signal Browser.  All signal selections '
'and Marker information will be lost.  Any settings you changed and saved '
'with the Preferences for SPTool window will be retained the next time you '
'open a Signal Browser.'
};

case 'playmenu'
str{1,1} = 'PLAY SOUND';
str{1,2} = {
' '
'Select this menu to play the current line Selection in its entirety '
'through your computer''s speakers (provided you have sound output '
'capabilities).  The Sample Interval of the Signal Browser is obeyed, as '
'long as it is no less than 50 Hz.  If it is less than 50 Hz, the platform '
'default is used to play the sound.'
};

case 'playbutton'
str{1,1} = 'PLAY SOUND';
str{1,2} = {
' '
'Click this toolbar button to play the current line Selection in its entirety '
'through your computer''s speakers (provided you have sound output '
'capabilities).  The Sample Interval of the Signal Browser is obeyed, as '
'long as it is no less than 50 Hz.  If it is less than 50 Hz, the platform '
'default is used to play the sound.'
};

case 'lineprop_pushtool'
str{1,1} = 'COLORS';
str{1,2} = {
' '
'Click on this button to change the Selected signal''s line color and / or '
'line Style.'
' '
'You can also change the line color and/or line style for ANY signal'
'currently selected in the SPTool by right- or control-clicking on'
'any signal in the main axes, and choosing the "Line Properties..." '
'submenu for the desired signal.'
};

case 'select_pushtool'
str{1,1} = 'SELECTION';
str{1,2} = {
' '
'Click on this button to choose, from the multiple selected signals of the '
'SPTool, which one signal has the Marker focus.  The Marker measurements '
'in track and slope mode, and peaks and valleys, apply to the selected signal.'
'Also, the "Play" button will play the selected signal on the computer''s'
'speaker.'
' '
'Array signals are listed in this menu as well allowing you to specify '
'which column of the array signal is the current one.  '
' '
'You can also change the selected signal by clicking on its waveform in the '
'main axes.'
' '
'USEABILITY TIP:  Sometimes you might have many signals displayed and'
'it is not clear which signal you have selected (so you can''t tell'
'which signal the Marker is measuring).  In that case, move the mouse'
'over to this button, but don''t click; a small window will pop up near'
'the mouse and display the current selected signal''s name.'
};

case 'print'
str{1,1} = 'PRINT';
str{1,2} = {
'Click this button to bring up a dialog box that enables you to'
'print the Signal Browser. '
};

case 'printpreview'
str{1,1} = 'PRINT PREVIEW';
str{1,2} = {
'Click this button to bring up a Print Preview window.  This '
'window gives you a visual preview of what the Signal Browser '
'will look like when you print it out.  '
' '
'The Print Preview window has two buttons:'
'  PRINT - proceeds to the Print window'
'and'
'  CLOSE - gives you a chance to dismiss the the Print Preview'
'  window WITHOUT printing the Signal Browser.'
};

case 'prnt'
str{1,1} = 'PRINT';
str{1,2} = {
'Select this menu to bring up a dialog box that enables you to'
'print the Signal Browser. '
};

case 'printprev'
str{1,1} = 'PRINT PREVIEW';
str{1,2} = {
'Select this menu to bring up a Print Preview window.  This '
'window gives you a visual preview of what the Signal Browser '
'will look like when you print it out.  '
' '
'The Print Preview window has two buttons:'
'  PRINT - proceeds to the Print window'
'and'
'  CLOSE - gives you a chance to dismiss the the Print Preview'
'  window WITHOUT printing the Signal Browser.'
};

case 'pagepos'
str{1,1} = 'PAGE SETUP';
str{1,2} = {
'Select this menu to open the Page Setup window.  This window'
'allows you to change certain settings relevant to printing'
'the Signal Browser, such as the paper orientation and how the'
'plot fills the page.'
};


otherwise
    %  this is a line object with tag corresponding to the
    %  variable in the workspace that it is plotting, or appended
    %  with _panner.
if ~isempty(findstr(tag,'_panner'))
tag = tag(1:end-7);
str{1,1} = 'LINE IN PANNER';
str{1,2} = {
    'You have clicked on a line in the panner.  The line you clicked'
    'corresponds to the SPTool signal'
    ['   ''' tag ''''] 
    '(or one if its columns if it is an array signal). '
    ' '
};
else
str{1,1} = 'LINE IN MAIN AXES';
str{1,2} = {
    'You have clicked on a line in the main axes.  The line you clicked'
    'corresponds to the SPTool signal'
    ['  ''' tag '''']
    '(or one if its columns if it is an array signal).'
    ' '
    'CLICK-AND-DRAG PANNING'
    ' '
    'If you click on a line in the main axes and hold down the button, you'
    'can pan around the main axes display using the clicked point as a center'
    'simply by dragging the mouse.  Note that this feature is not enabled in'
    'mouse zoom mode.'
    ' '
    'CONTEXT MENU'
    ' '
    'Right click, or click while holding the CONTROL key, on this or any' 
    'other signal, in order to open a context menu for the signal browser.'
    'The context menu has a list of the currently selected Signals in the'
    'SPTool and provides choices that allow you to change'
    '   1) the name of a signal,'
    '   2) a signal''s sampling frequency, '
    '   3) how to display complex signals (if any of the currently'
    '      selected signals in the SPTool is complex), and'
    '   4) which columns of a signal are to be displayed (if the'
    '      signal is an array signal).'
};
end

end


