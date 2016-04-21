function str = sphelpstr(tag,fig)
%SPHELPSTR Help for Spectrum Viewer

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.11 $

    str{1,1} = 'Spectrum Viewer';
    str{1,2} = {['No help for this object (' tag ')']};

% ****                       WARNING!                       ****
% ****                                                      ****
% ****  All help text between the SWITCH TAG and OTHERWISE  ****
% ****  statements is automatically generated.  To change   ****
% ****  the help text, edit SPHELP.H and use HWHELPER to    ****
% ****  insert the changes into this file.                  ****

switch tag
case {'help','helptopicsmenu'}
str{1,1} = 'SPECTRUM VIEWER';
str{1,2} = {
'This window is a Spectrum Viewer.  It allows you to view and modify '
'spectra created in the SPTool.  This window always displays what is '
'currently selected in the ''Spectra'' column of the SPTool.'
' '
'The Spectrum Viewer consists of four essential areas:'
'  1) a parameters frame on the left for viewing and altering the '
'     parameters or method of the currently selected spectrum.'
'  2) a main display area for viewing spectra graphically.'
'  3) zoom controls in the toolbar for getting a closer look at '
'     spectral features.'
'  4) "Markers" for making spectral measurements and comparisons.'
' '
'CONTEXT MENU'
' '
'Right- or control-click the main axes to open a context menu showing a '
'list of the currently visible spectra in the Spectrum Viewer.  You '
'can change the name, sampling frequency of the associated signal '
'and spectrum, and line properties, through submenus of this context '
'menu.'
' '
'GETTING HELP'
' '
'To get help at any time, click once on the ''Help'' button, OR select'
'"What''s This" under the Help menu.  The mouse pointer becomes an '
'arrow with a question mark symbol.  You can then click on anything '
'in the Spectrum Viewer (or select a menu) to find out what it '
'is and how to use it.'
};

case 'whatsthismenu'
str{1,1} = 'GETTING HELP';
str{1,2} = {
' '
'To get help at any time, click once on the ''Help'' button, OR select'
'"What''s This" under the Help menu.  The mouse pointer becomes an '
'arrow with a question mark symbol.  You can then click on anything '
'in the Spectrum Viewer (or select a menu) to find out what it '
'is and how to use it.'
};

case 'toolbar'
str{1,1} = 'TOOLBAR';
str{1,2} = {
' '
'You have clicked in the "Toolbar" of the Spectrum Viewer.'
' '
'The Toolbar contains three areas: the "Zoom Group" consisting of the six '
'buttons on the left, the "Help Button", and the "Legend Area" on the right.'
' '
'To get help on any of these items, click once on the "Help" button, then '
'click on the button for which you want help.'
};

case 'spzoom:mousezoom'
str{1,1} = 'MOUSE ZOOM';
str{1,2} = {
' '
'Clicking this button puts you in "Mouse Zoom" mode. In this mode, the '
'mouse pointer becomes a cross when it is inside the main axes area.  You '
'can click and drag a rectangle in the main axes, and the main axes display '
'will zoom in to that region.  If you click with the left button at a point '
'in the main axes, the main axes display will zoom in to that point for a '
'more detailed look at the data there.  Similarly, you can click with the '
'right mouse button (shift click on the Mac) at a point in the main axes to '
'zoom out from that point for a wider view of the data.  In each case, the '
'panner is updated to highlight the region of data displayed in the main '
'axes.'
' '
'To get out of mouse zoom mode without zooming in or out, click on the '
'Mouse Zoom button again.'
' '
'ZOOM PERSISTENCE'
' '
'Normally you leave zoom mode as soon as you zoom in or out once.  In order '
'to zoom in or out again, the Mouse Zoom button must be clicked again.  '
'However, the mouse zoom mode will remain enabled after a zoom if in the '
'Preferences of the SPTool, under the Spectrum Viewer section, the box '
'marked ''Stay in Zoom-Mode after Zoom'' is checked.'
};

case 'spzoom:zoomout'
str{1,1} = 'FULL VIEW';
str{1,2} = {
'Clicking this button restores the data limits of the main axes to show all '
'of the data selected.'
};

case 'spzoom:zoominy'
str{1,1} = 'ZOOM IN Y';
str{1,2} = {
'Clicking this button zooms in on the spectra, cutting the vertical range '
'of the main axes in half.  The x-limits (horizontal scaling) of the main '
'axes are not changed.'
};

case 'spzoom:zoomouty'
str{1,1} = 'ZOOM OUT Y';
str{1,2} = {
'Clicking this button zooms out from the spectra, expanding the vertical '
'range of the main axes by a factor of two.  The x-limits (horizontal '
'scaling) of the main axes are not changed.'
};

case 'spzoom:zoominx'
str{1,1} = 'ZOOM IN X';
str{1,2} = {
'Clicking this button zooms in on the spectra, cutting the horizontal range '
'of the main axes in half.  The y-limits (vertical scaling) of the main '
'axes are not changed.'
};

case 'spzoom:zoomoutx'
str{1,1} = 'ZOOM OUT X';
str{1,2} = {
'Clicking this button zooms out from the spectra, expanding the horizontal '
'range of the main axes by a factor of two.  The y-limits (vertical '
'scaling) of the main axes are not changed.'
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
'You have clicked on Marker 1.  Drag this indicator with the mouse to '
'measure features of your selected data.  The value of the Marker is shown '
'textually in the Marker area on the bottom of the Spectrum Viewer '
'window.'
};

case 'ruler2line'
str{1,1} = 'Marker 2';
str{1,2} = {
'You have clicked on Marker 2.  Drag this indicator with the mouse to '
'measure features of your selected data.  The value of the Marker is show '
'textually in the Marker area on the bottom of the Spectrum Viewer '
'window.'
};

case 'slopeline'
str{1,1} = 'SLOPE LINE';
str{1,2} = {
'You have clicked on the Slope Line of the Markers.  This line goes through '
'the points (x1,y1) and (x2,y2) defined by Marker 1 and Marker 2 '
'respectively.  Its slope is labeled as ''Slope''.  As you drag either Marker 1 or '
'Marker 2 left and right, the Slope Line is updated.'
};

case 'ruler1button'
str{1,1} = 'FIND Marker 1';
str{1,2} = {
'Click on this button to bring Marker 1 to the center of the main axes.  '
'This button is only visible when Marker 1 is "off the screen", that is, '
'when Marker 1 is not visible in the main axes.'
};

case 'ruler2button'
str{1,1} = 'FIND Marker 2';
str{1,2} = {
'Click on this button to bring Marker 2 to the center of the main axes.  '
'This button is only visible when Marker 2 is "off the screen", that is, '
'when Marker 2 is not visible in the main axes.'
};

case {'ruleraxes','rulerlabel','rulerframe'}
str{1,1} = 'MARKERS';
str{1,2} = {
'This area of the Spectrum Viewer allows you to read and control the values '
'of the Markers in the main axes.  Use the Markers to make measurements on '
'spectra, such as distances between features, heights of peaks, and slope '
'information.'
};

case {'ruler:vertical','vertical'}
str{1,1} = 'VERTICAL';
str{1,2} = {
'Click this button to change the Markers to Vertical mode.  In Vertical '
'mode, you can change the Markers'' x-values (i.e., horizontal position) by '
'either'
'  - dragging them back and forth with the mouse, or'
'  - entering their values in the x1 and x2 edit boxes.'
' '
'The difference x2-x1 is displayed as dx.'
};

case {'ruler:horizontal','horizontal'}
str{1,1} = 'HORIZONTAL';
str{1,2} = {
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
'Click this button to change the Markers to Track mode.  This mode is just '
'like Vertical mode, in which you can change the Markers'' x-values (i.e., '
'horizontal position) by either'
'  - dragging them left and right with the mouse, or'
'  - entering their values in the y1 and y2 edit boxes.'
' '
'In Track mode, the Markers also "track" a spectrum, so that you can see the '
'y-values of the spectrum at the x-values of the Markers.  The value dy is '
'equal to y2-y1.  You can change which spectrum is tracked by clicking on a '
'spectrum in the main axes, or by selecting a new one in the menu obtained'
'by the "Selection" button of the toolbar.'
' '
};

case {'ruler:slope','slope'}
str{1,1} = 'SLOPE';
str{1,2} = {
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
'You can change which spectrum is tracked by clicking on a spectrum in the'
'main axes, or by selecting a new one in the menu obtained'
'by the "Selection" button of the toolbar.'
};

case 'x1label'
str{1,1} = 'X1';
str{1,2} = {
'This is the X value of Marker 1.  Change this value by dragging Marker 1 '
'back and forth with the mouse, or clicking in the box labeled "X" and '
'typing in a number.'
};

case 'rulerbox1'
str{1,1} = 'Marker 1';
str{1,2} = {
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
'This is the Y value of Marker 1.  '
' '
'In Track and Slope Marker modes, y1 is the value of the spectrum in the '
'main axes that is being tracked by Marker 1.'
' '
'In Horizontal Marker mode, you can enter a value in the box labeled "Y" to '
'change the position of the Marker.'
};

case 'x2label'
str{1,1} = 'X2';
str{1,2} = {
'This is the X value of Marker 2.  Change this value by dragging Marker 2 '
'back and forth with the mouse, or clicking in the box labeled "X" and '
'typing in a number.'
};

case 'rulerbox2'
str{1,1} = 'Marker 2';
str{1,2} = {
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
'This is the Y2 value of Marker 2.  '
' '
'In Track and Slope Marker modes, y2 is the value of the spectrum in the '
'main axes that is being tracked by Marker 2.'
' '
'In Horizontal Marker mode, you can enter a value in the box labeled "Y" to '
'change the position of the Marker.'
};

case {'dxlabel','dxtext'}
str{1,1} = 'DX';
str{1,2} = {
'Delta X value.  This is the value of x2 - x1.'
};

case {'dylabel','dytext'}
str{1,1} = 'DY';
str{1,2} = {
'Delta Y value.  This is the value of y2 - y1.'
};

case {'dydxtext','dydxlabel'}
str{1,1} = 'SLOPE';
str{1,2} = {
'Delta Y / Delta X value.  This is the value of dy / dx,'
'i.e. (y2 - y1) / (x2 - x1).'
};

case {'ruler:peaks','peaks'}
str{1,1} = 'PEAKS';
str{1,2} = {
' '
'Click on this button to see all the local maxima of the currently selected'
'spectrum.  Change which spectrum is selected by clicking on its waveform in'
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
'Click on this button to see all the local minima of the currently selected'
'spectrum.  Change which spectrum is selected by clicking on its waveform in'
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

case 'closemenu'
str{1,1} = 'CLOSE MENU';
str{1,2} = {
'Select this menu to close the Spectrum Viewer.  All spectrum selection and '
'Marker information will be lost.  Any Settings you changed and saved with '
'the Preferences window of the SPTool will be retained the next time you '
'open a Spectrum Viewer.'
};

case {'signalLabel','siginfo1Label','siginfo2Label','signalFrame'}
str{1,1} = 'SIGNAL INFO';
str{1,2} = {
' '
'This frame displays information about the signal linked to the currently '
'selected spectrum.  The information includes the signal''s name, size, real '
'or complex, and sampling frequency.  To change any of these signal '
'properties, use the SPTool.  '
' '
'To assign a completely new signal to this spectrum, click on a signal in '
'the SPTool and click the "Update" button under Spectra.'
};

case 'propFrame'
str{1,1} = 'SPECTRUM PROPERTIES';
str{1,2} = {
' '
'The controls in this frame allow you to modify the properties of a '
'spectrum.'
};

case 'revertButton'
str{1,1} = 'REVERT';
str{1,2} = {
' '
'Press this button to restore the properties of the current spectrum to '
'what they were the last time the Apply button was pressed.'
};

case 'applyButton'
str{1,1} = 'APPLY';
str{1,2} = {
' '
'Press this button to compute the spectrum of the current object using the '
'parameters set above.'
};

case {'dbMag','linearMag'}
str{1,1} = 'MAG SCALING';
str{1,2} = {
' '
'You can choose a scaling for the magnitude plot (linear, log, or decibels) '
'by choosing from this menu.'
};

case {'half','whole','negative'}
str{1,1} = 'RANGE';
str{1,2} = {
'You can choose the range for the frequency axis by selecting this menu.  '
'The options are [0, Fs/2], [0, Fs], and [-Fs/2, Fs/2], where Fs in the '
'sampling frequency.  '
' '
'If multiple spectra are displayed, Fs is chosen as the maximum of all the '
'sampling frequencies.  '
' '
'Fs is not defined for the case of a spectrum whos signal is ''<None>''; a '
'value of twice the highest magnitude frequency in the spectrum''s frequency '
'vector is chosen in this case.'
' '
'The frequency range cannot be negative if you choose logarithmic frequency '
'axis scaling.'
};

case {'linearFreq','logFreq'}
str{1,1} = 'FREQ. SCALING';
str{1,2} = {
'You can choose the scaling for the frequency axis (linear or log) by '
'selecting the appropriate option from this popup menu.'
' '
'The frequency range cannot be negative if you choose logarithmic frequency '
'axis scaling.'
};

case {'mainaxes','mainaxesxlabel','mainaxestitle'}
str{1,1} = 'MAIN AXES';
str{1,2} = {
' '
'This is the main axes of the Spectrum Viewer.  The spectral data of all '
'the spectra selected in the list of Spectra in the SPTool are displayed '
'here graphically.  Note that some spectra might not show up because you '
'need to hit the "Apply" button to recompute the spectral data.'
' '
'You can display the spectra in dB or linear scales by choosing the '
'"Options" menu and then selecting the desired scaling under the'
'"Magnitude Scaling" submenu.  Similar options are available for the'
'Frequency axis scaling and range under the "Options" menu.'
' '
'CONTEXT MENU'
' '
'Right- or control-click this axes to open a context menu showing a '
'list of the currently visible spectra in the Spectrum Viewer.  You '
'can change the name, sampling frequency of the associated signal '
'and spectrum, and line properties, through submenus of this context '
'menu.'
};

case {'paramLabel','paramFrame'}
str{1,1} = 'PARAMETERS';
str{1,2} = {
' '
'Change the parameters for the spectrum in this frame.'
};

case 'inheritPopup'
str{1,1} = 'INHERIT';
str{1,2} = {
' '
'By choosing a spectrum from this menu, you can inherit the parameters (not '
'including the signal) from another spectrum in the SPTool.'
};

case {'confidenceEdit','confidenceCheckbox'}
str{1,1} = 'CONFIDENCE';
str{1,2} = {
' '
'Click this checkbox to obtain a confidence interval for the spectrum. '
'Enter a number between 0 and 1 for the confidence interval in this box. '
'Confidence intervals are a method dependent computation.  '
};

case 'lineprop_pushtool'
str{1,1} = 'COLORS';
str{1,2} = {
' '
'Click on this button to change the Selected Spectrum''s line color and / or '
'line Style.'
' '
'You can also change the line color and/or line style for ANY spectrum'
'currently selected in the SPTool by right- or control-clicking on'
'any spectrum in the main axes, and choosing the "Line Properties..." '
'submenu for the desired spectrum.'
};

case 'select_pushtool'
str{1,1} = 'SELECTION';
str{1,2} = {
' '
'Click on this button to choose, from the multiple selected Spectra of the '
'SPTool, which one spectrum has the Marker focus.  The Marker measurements '
'in track and slope mode, and peaks and valleys, apply to the selected spectrum.'
' '
'You can also change the selected Spectrum by clicking on its waveform in the '
'main axes.'
' '
'USEABILITY TIP:  Sometimes you might have many Spectra displayed and'
'it is not clear which Spectrum you have selected (so you can''t tell'
'which Spectrum the Marker is measuring).  In that case, move the mouse'
'over to this button, but don''t click; a small window will pop up near'
'the mouse and display the current selected Spectrum''s name.'
};

case 'print'
str{1,1} = 'PRINT';
str{1,2} = {
'Click this button to bring up a dialog box that enables you to'
'print the Spectrum Viewer. '
};

case 'printpreview'
str{1,1} = 'PRINT PREVIEW';
str{1,2} = {
'Click this button to bring up a Print Preview window.  This '
'window gives you a visual preview of what the Spectrum Viewer'
'will look like when you print it out.  '
' '
'The Print Preview window has two buttons:'
'  PRINT - proceeds to the Print window'
'and'
'  CLOSE - gives you a chance to dismiss the the Print Preview'
'  window WITHOUT printing the Spectrum Viewer.'
};

case 'prnt'
str{1,1} = 'PRINT';
str{1,2} = {
'Select this menu to bring up a dialog box that enables you to'
'print the Spectrum Viewer. '
};

case 'printprev'
str{1,1} = 'PRINT PREVIEW';
str{1,2} = {
'Select this menu to bring up a Print Preview window.  This '
'window gives you a visual preview of what the Spectrum Viewer'
'will look like when you print it out.  '
' '
'The Print Preview window has two buttons:'
'  PRINT - proceeds to the Print window'
'and'
'  CLOSE - gives you a chance to dismiss the the Print Preview'
'  window WITHOUT printing the Spectrum Viewer.'
};

case 'pagepos'
str{1,1} = 'PAGE SETUP';
str{1,2} = {
'Select this menu to open the Page Setup window.  This window'
'allows you to change certain settings relevant to printing'
'the Spectrum Viewer, such as the paper orientation and how the'
'plot fills the page.'
' '
};


otherwise
    i = NaN;
    if strncmp(tag,'uicontrol',9)
        i = str2double(tag(10:end));
    elseif strncmp(tag,'label',5)
        i = str2double(tag(6:end));
    end
    ud = get(fig,'userdata');
    if ~isnan(i)
    % display help for this uicontrol
        methodNum = get(ud.hand.methodPopup,'value');
        N = length(ud.methods(methodNum).subordinates);
        subVal = [];
        for j=1:N
            subs = ud.methods(methodNum).subordinates{j};
            if ~isempty(subs) & ~isempty(find(subs==i))
                subVal = [subVal get(ud.hand.uicontrol(j),'value')];
            end
        end
        if isempty(subVal)
            introStr = ['You have clicked on the "' ...
                      ud.methods(methodNum).label{i} ...
                      '" parameter of the "' ...
                      ud.methods(methodNum).methodName '" method.'];
            str{1,2} = {introStr ' ' ...
                        ud.methods(methodNum).helpString{i}{:}};
        else
            introStr = ['You have clicked on the "' ...
                      ud.methods(methodNum).label{i}{subVal(1)} ...
                      '" parameter of the "' ...
                      ud.methods(methodNum).methodName '" method.'];
            str{1,2} = {introStr ' ' ...
                        ud.methods(methodNum).helpString{i}{subVal(1)}{:}};
        end
    elseif strcmp(tag,'methodLabel') | strcmp(tag,'methodPopup')
        methodStr = strcat({ud.methods.methodName},',	');
        methodStr = [methodStr{:}];
        methodStr(end-1:end) = [];
        str{1,1} = 'Method Selection';
        str{1,2} = {
 'Select a method for the current Spectrum with this popup menu.'
 ' '
 'The currently available methods are:'
 methodStr
 ' '
 'To get a brief description of one of these methods, select it under ''Topics''.'
 ' '
 'For more detailed information, see the Reference section of the User''s Manual.'
  };
        for i = 1:length(ud.methods)
            str{1+i,1} = ud.methods(i).methodName;
            str{1+i,2} = ud.methods(i).methodHelp;
        end
    else % must be the spectrum
    
        str{1,1} = 'SPECTRUM DATA';
        str{1,2} = {
    'You have clicked on a line in the main axes.  The line you clicked'
    'corresponds to the SPTool spectrum'
    ['  ''' tag '''']
    ' '
    'You can change the parameters of this spectrum by clicking on it.'
    ' '
    'CLICK-AND-DRAG PANNING'
    ' '
    'If you click on a line in the main axes and hold down the button,'
    'you can pan around the main axes display using the clicked point'
    'as a center simply by dragging the mouse.  Note that this feature'
    'is not enabled in mouse zoom mode.'
    ' '
    'CONTEXT MENU'
    ' '
    'Right- or control-click this or any other trace in the Spectrum'
    'Viewer to open a context menu showing a list of the currently'
    'visible spectra in the Spectrum Viewer.  You can change the name,'
    'sampling frequency of the associated signal and spectrum, and'
    'line properties, through submenus of this context menu.' 
     };
   
    end
    
end
