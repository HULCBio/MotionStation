function str = fdhelpstr(tag,fig,h)
%FDHELPSTR Help for Filter Designer.
% Inputs:
%   tag - string identifying the object clicked on
%   fig - figure handle of GUI
%   h - handle of the clicked object

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.12 $

    str{1,1} = 'Filter Designer';
    str{1,2} = {['No help for this object (' tag ')']};

% ****                       WARNING!                       ****
% ****                                                      ****
% ****  All help text between the SWITCH TAG and OTHERWISE  ****
% ****  statements is automatically generated.  To change   ****
% ****  the help text, edit FDHELP.HLP and use HWHELPER to  ****
% ****  insert the changes into this file.                  ****

switch tag
case {'help','filtdes','axFrame','tb2Frame','helptopicsmenu'}
str{1,1} = 'FILTER DESIGNER';
str{1,2} = {
' '
'This window is a Filter Designer.  It allows you to create FIR and IIR '
'digital filters of various lengths and types using design functions in the '
'Signal Processing Toolbox.  Also, you can manipulate the zeros and poles of '
'a filter directly with the "Pole/Zero Editor" option.'
' '
'To create a new filter, click the "New Design" button in the SPTool, or '
'import one into the SPTool using the "File/Import..." menu option.  To edit '
'an existing or imported filter, click on it in the SPTool and click the '
'"Edit Design" button.'
' '
'The main axes displays the frequency response of the current filter.  '
'The current type of filter is determined by the "Algorithm" popup-menu'
'in the center of the window, just above the main axes.  This menu'
'decides the type of filter (FIR or IIR) and the error minimization'
'scheme employed to design the filter, as well as characteristics'
'of each filter type.  For details about any of the algorithms, click'
'on the Help Button again and then click on the Algorithm menu itself.'
' '
'The toolbar across the top of the window allows you to zoom into and '
'out of the frequency response, overlay a spectrum plot on top of the '
'filter''s response, and obtain help on any of the tool''s components.  '
'Just below the toolbar are three controls from left to right:'
'  - a popup menu that allows you to select different filters,'
'  - an editable text box that displays and allows you to change'
'    the filter''s sampling frequency, and'
'  - the "Algorithm" popup menu.'
' '
'On the lower left of the window are the "AutoDesign" check box, and the'
'revert and apply buttons; to get help on these, click Help and then'
'click on any of these buttons.'
' '
'The rest of the Filter Designer is made up of three areas: SPECIFICATIONS, '
'MAIN AXES, and MEASUREMENTS.  Select any of these under "Topics"'
'for more information.'
};

str{2,1} = 'SPECIFICATIONS';
str{2,2} = {
'On the left of the window are filter "Specifications".  Modify these'
'parameters to change the filter band configuration (lowpass, highpass,'
'bandpass, bandstop), whether you desire a minimum order filter, and other'
'band edges or parameters depending on the algorithm.  If "AutoDesign"'
'is checked, then every time you change a specification, the filter '
'redesigns.  If "AutoDesign" is not checked, changing a specification will'
'not design the filter until you hit the "Apply" button.'
' '
'In the Pole/Zero Editor, the controls in the specifications area allow you'
'to set the gain, magnitude, and angle of the selected pole or zero (or'
'conjugate pair).'
' '
'To get help on a specification, click the help button and then click on the '
'specification.'
};

str{3,1} = 'MAIN AXES';
str{3,2} = {
'The main axes area consists of a display of the current filter''s frequency'
'response, and other lines which are used to either manipulate or measure'
'the filter.  When moving the mouse over these lines, you will see the mouse'
'pointer change to indicate you can perform some action by clicking and'
'dragging the line, usually up and down or back and forth.'
' '
'GREEN LINES are specification lines, and dragging them causes the filter'
'to be redesigned.  If "AutoDesign" is checked, the filter will redesign'
'as you drag the mouse - this is recommended only for the fastest machines.'
'If "AutoDesign" is not checked, the filter will be designed when you'
'release the mouse button (after you are done dragging the line to its'
'desired location).  The Filter Designer will do its best to meet the '
'specifications, but in the case of REMEZ and KAISER, the response will'
'sometimes exceed the green lines.'
' '
'RED LINES are measurement lines, and dragging them does not cause the'
'filter to be redesigned.  As you drag these lines, some measurements on'
'the right will change to reflect the changed position of the line.'
' '
'You can also drag the FREQUENCY RESPONSE LINE.  In this case, when you'
'are zoomed-in, dragging this line allows you to see other parts of the'
'response which are off the screen.  When you release the mouse button, the'
'only thing that changes are the axes limits.'
' '
'To get help on a line (to see what it represents and how to drag it), click the '
'help button and then click on the line.'
};

str{4,1} = 'MEASUREMENTS';
str{4,2} = {
'The right side of the window contains some labelled numeric quantities '
'called "Measurements".'
' '
'Most measurements are read-only quantities.  They reflect some quantity of '
'interest about the current filter.  Some measurements are interactive, for '
'example, they let you ask questions such as "what is the value of the '
'stopband ripple at x Hz?" or "at what frequency do I attain a passband '
'ripple of .1 dB or less?".'
' '
'To get help on a measurement, click the help button and then click on the '
'measurement.'
};

str{5,1} = 'PZ EDITOR';
str{5,2} = {
'The Pole/Zero Editor'
' '
'The Filter Designer also includes the ability to edit the poles and zeros '
'of a filter in the Z-plane.  To use the Pole/Zero Editor, simply set the '
'"Algorithm" popup-menu to "Pole/Zero Editor".  Also, when you import a'
'filter in the SPTool, and click "Edit Design," the filter will be opened in '
'the Pole/Zero Editor.'
' '
'In this mode, the Z-plane is depicted with the zeros of the filter '
'designated by ''o''s, and the poles by ''x''s.  You can select a pole or zero '
'by clicking on it with the mouse.  If the filter is real, the poles and '
'zeros will be grouped in complex conjugate pairs, and when you click on a '
'pole or zero, both the one you clicked on AND its conjugate will be '
'selected.'
' '
'You can move a pole or zero by typing its coordinates in the appropriate '
'boxes on the left (either Mag, Angle or X,Y), or by dragging the pole or '
'zero.  If the Filter Viewer is open, you can see how the response of the '
'filter changes in "real-time" in the Filter Viewer as you drag a pole or '
'zero.'
};

str{6,1} = 'MORE HELP';
str{6,2} = {
'To get help at any time, click once on the ''Help'' button, OR select'
'"What''s This" under the Help menu.  The mouse pointer becomes an '
'arrow with a question mark symbol.  You can then click on anything '
'in the Filter Designer (or select a menu) to find out what it '
'is and how to use it.'
};

case 'whatsthismenu'
str{1,1} = 'GETTING HELP';
str{1,2} = {
' '
'To get help at any time, click once on the ''Help'' button, OR select'
'"What''s This" under the Help menu.  The mouse pointer becomes an '
'arrow with a question mark symbol.  You can then click on anything '
'in the Filter Designer (or select a menu) to find out what it '
'is and how to use it.'
};

case 'fdremez'
str{1,1} = 'Remez';
str{1,2} = {
'Equiripple FIR'
' '
'FIR filter design using the Chebyshev error criterion and the Remez '
'exchange algorithm.  The maximum error between the desired frequency '
'response and the actual filter response over the desired bands is minimized '
'(hence the name "minimax" which is sometimes used for these filters as '
'well).  Filter exhibits the "equiripple" property in which the response '
'oscillates a fixed amount above and below the ideal "brickwall" response in '
'the passband and stopband.'
' '
'MINIMUM ORDER MODE'
'The minimum order for an Equiripple FIR is an approximation based on'
'heuristic measurements (see the function REMEZORD).  The actual'
'filter may not meet the desired specifications.  If this is the case,'
'just change to non-minimum order mode, and increase the order'
'until you achieve the desired specifications.'
' '
'DESIGN PARAMETERS IN NON-MINIMUM ORDER MODE'
'The filter parameters for this type of filter are the filter order,'
'the frequency band edges, and the passband and stopband error'
'weights (w1 and w2).  The error in the passband will be '
'w2/w1 times the error in the stopband. '
' '
'Uses REMEZ.M.'
};

case 'fdfirls'
str{1,1} = 'Firls';
str{1,2} = {
'Least Squares FIR'
' '
'FIR filter design using the weighted least squares (L_2) error criterion '
'with transition band(s).  The square of the integral of the error between '
'the desired frequency response and the actual filter response over the '
'desired bands is minimized (hence the name "least squares").  Filter '
'exhibits smaller ripple over most of the band than that of the equiripple '
'filter, but near the band edges the error is worse.'
' '
'MINIMUM ORDER MODE'
'There is no minimum order mode for a FIR least-squares filters as there is'
'no formula to estimate the order.'
' '
'DESIGN PARAMETERS IN NON-MINIMUM ORDER MODE'
'The filter parameters for this type of filter are the same as that of the '
'equiripple filter: filter order, the frequency band edges, and the passband '
'and stopband error weights (w1 and w2).  '
' '
'Uses FIRLS.M.'
' '
};

case 'fdkaiser'
str{1,1} = 'Kaiser';
str{1,2} = {
'Kaiser Window FIR'
' '
'FIR filter design using a least squares error criterion without transition '
'band, along with a Kaiser Window to provide a smoother truncation of the '
'ideal impulse response.  Specifically, the impulse response is obtained as '
'the inverse Fourier Transform of the ideal brickwall filter with cut-off '
'frequency Fc (or Fc1 and Fc2), and then pointwise multiplied by the Kaiser '
'window.'
' '
'MINIMUM ORDER MODE'
'The minimum order for the Kaiser window FIR is an approximation based on'
'heuristic measurements (see the function KAISERORD).  The actual'
'filter may not meet the desired specifications.  If this is the case,'
'just change to non-minimum order mode, and increase the order'
'until you achieve the desired specifications.'
' '
'DESIGN PARAMETERS IN NON-MINIMUM ORDER MODE'
'The filter parameters for this type of filter are the filter order, the '
'transition frequency (or frequencies for bandpass and bandstop) of the '
'brickwall filter, and the Beta parameter for the Kaiser window.'
' '
'Uses KAISER.M and FIR1.M.'
};

case 'fdbutter'
str{1,1} = 'Butterworth';
str{1,2} = {
'Butterworth'
' '
'IIR filter design using a maximally flat (Taylor series) approximation to '
'the desired frequency response at 0 and Fs/2, where Fs is the sampling '
'frequency.  The response is smoothly varying in both the pass and '
'stopbands (no ripples).'
' '
'Compared with Chebyshev Types I and II and Elliptic IIR filters, to achieve '
'a given set of specifications, Butterworth requires the largest filter '
'order.'
' '
'DESIGN PARAMETERS IN NON-MINIMUM ORDER MODE'
'The filter parameters for this type of filter are the filter order and the '
'3dB frequency (or frequencies for bandpass and bandstop filters).  The 3dB '
'frequency is that frequency where the filter''s magnitude response is -3dB.'
' '
'Uses BUTTER.M.'
};

case 'fdcheby1'
str{1,1} = 'Chebyshev I';
str{1,2} = {
'Chebyshev Type I'
' '
'IIR filter design using a Chebyshev (equiripple) approximation to the '
'desired frequency response in the passband and a maximally flat '
'approximation at Fs/2.  The response has ripples in the passband, but not '
'the stopband. '
' '
'Compared with Butterworth, Chebyshev Type II and Elliptic IIR filters, to'
'achieve a given set of specifications, Chebyshev Type I and II require an'
'intermediate filter order, less than Butterworth but more than Elliptic.'
' '
'DESIGN PARAMETERS IN NON-MINIMUM ORDER MODE'
'The filter parameters for this type of filter are the filter order, the '
'passband ripple Rp, and the passband frequency (or frequencies for bandpass '
'and bandstop filters).  The passband frequency is that frequency where the '
'filter''s magnitude response is -Rp dB.'
' '
'Uses CHEBY1.M.'
};

case 'fdcheby2'
str{1,1} = 'Chebyshev 2';
str{1,2} = {
'Chebyshev Type II (inverse Chebyshev)'
' '
'IIR filter design using a maximally flat approximation to the desired '
'frequency response at 0 and a Chebyshev (equiripple) approximation in the '
'stopband.  The response has ripples in the stopband, but not the passband.'
' '
'Compared with Butterworth, Chebyshev Type I and Elliptic IIR filters, to '
'achieve a given set of specifications, Chebyshev Type II and I require an '
'intermediate filter order, less than Butterworth but more than Elliptic.'
' '
'DESIGN PARAMETERS IN NON-MINIMUM ORDER MODE'
'The filter parameters for this type of filter are the filter order, the '
'stopband ripple Rs, and the stopband frequency (or frequencies for bandpass '
'and bandstop filters).  The stopband frequency is that frequency where the '
'filter''s magnitude response is -Rs dB.'
' '
'Uses CHEBY2.M.'
};

case 'fdellip'
str{1,1} = 'Elliptic';
str{1,2} = {
'Elliptic'
' '
'IIR filter design using a Chebyshev error criterion in both the passband '
'and stopband.  The response has ripples in both the pass and stop bands.'
' '
'Compared with Butterworth, Chebyshev Type I and II IIR filters, to '
'achieve a given set of specifications, Elliptic filters require the '
'smallest filter order.'
' '
'DESIGN PARAMETERS IN NON-MINIMUM ORDER MODE'
'The filter parameters for this type of filter are the filter order, the '
'passband and stopband ripples Rp and Rs, and the passband frequency (or '
'frequencies for bandpass and bandstop filters).  The passband frequency is '
'that frequency where the filter''s magnitude response is -Rp dB.'
' '
'Uses ELLIP.M.'
};

case 'fdpzedit'
str{1,1} = 'The Pole/Zero Editor';
str{1,2} = {
' '
'The Filter Designer includes the ability to edit the poles and zeros of a '
'filter in the Z-plane.  To use the Pole/Zero Editor, simply set the '
'"Algorithm" popup-menu to "Pole/Zero Editor".  Also, when you import a '
'filter in the SPTool, and click "Edit Design," the filter will be opened in '
'the Pole/Zero Editor.'
' '
'In this mode, the Z-plane is depicted with the zeros of the filter '
'designated by ''o''s, and the poles by ''x''s.  You can select a pole or zero '
'by clicking on it with the mouse.  If the filter is real, the poles and '
'zeros will be grouped in complex conjugate pairs, and when you click on a '
'pole or zero, both the one you clicked on AND its conjugate will be '
'selected.'
' '
'You can move a pole or zero by typing its coordinates in the appropriate '
'boxes on the left (either Mag, Angle or X,Y), or by dragging the pole or '
'zero.  If the Filter Viewer is open, you can see how the response of the '
'filter changes in "real-time" in the Filter Viewer as you drag a pole or '
'zero.'
};

case 'AutoDesign'
str{1,1} = 'AutoDesign';
str{1,2} = {
' '
'AutoDesign Checkbox'
' '
'This checkbox allows you to control how often the filter is redesigned '
'based on your inputs.  It has two different effects based on changes to '
'Specifications controls on the left, and based on dragging Specifications '
'Lines in the main axes area.  Basically, if you have a slower machine, or '
'your filter order is very large, you will want to leave AutoDesign '
'unchecked.'
' '
'When AutoDesign is checked, every time you change a Specification and every '
'time the mouse moves while dragging a Specification Line, the filter is '
'designed.'
' '
'When AutoDesign is not checked, the filter is designed only when you press '
'the "Apply" button, or when you release the mouse after dragging a '
'Specification Line.'
' '
'Note: for the Pole/Zero Editor, the AutoDesign checkbox is always checked.'
};

case 'filtmenu'
str{1,1} = 'Filter Menu';
str{1,2} = {
' '
'This popup menu allows you to select a filter to design, from the'
'list of selected filters in the SPTool.'
};

case 'specFrame'
str{1,1} = 'SPECIFICATIONS';
str{1,2} = {
' '
'On the left of the window are filter "Specifications".  Modify these'
'parameters to change the filter band configuration (lowpass, highpass,'
'bandpass, bandstop), whether you desire a minimum order filter, and other'
'band edges or parameters depending on the algorithm.  If "AutoDesign"'
'is checked, then every time you change a specification, the filter '
'redesigns.  If "AutoDesign" is not checked, changing a specification will'
'not design the filter until you hit the "Apply Button".'
' '
'In the Pole/Zero Editor, the controls in the specifications area allow you'
'to set the gain, magnitude, and angle of the selected pole or zero (or'
'conjugate pair).'
' '
'To get help on a specification, click the help button and then click on the '
'specification.'
' '
};

case 'measFrame'
str{1,1} = 'MEASUREMENTS';
str{1,2} = {
' '
'The right side of the window contains some labelled numeric quantities '
'called "Measurements".'
' '
'Most measurements are read-only quantities.  They reflect some quantity of '
'interest about the current filter.  Some measurements are interactive, for '
'example, they let you ask questions such as "what is the value of the '
'stopband ripple at x Hz?" or "at what frequency do I attain a passband '
'ripple of .1 dB or less?".'
' '
'To get help on a measurement, click the help button and then click on the '
'measurement.'
' '
};

case 'revert'
str{1,1} = 'REVERT';
str{1,2} = {
' '
'Click this button to restore all of the Specifications to their values at '
'the time the filter was last designed, and re-enable the Measurements and '
'Specifications Lines for the currently designed filter.'
' '
'This button becomes enabled when you change a Specification and '
'"AutoDesign" is not checked.'
' '
};

case 'apply'
str{1,1} = 'APPLY';
str{1,2} = {
' '
'Click this button to accept all of the Specifications you have entered and'
'design the filter according to those specifications.'
' '
'This button becomes enabled when you change a Specification and '
'"AutoDesign" is not checked.'
' '
};

case 'toolbar'
str{1,1} = 'TOOLBAR';
str{1,2} = {
'You have clicked in the "Toolbar" of the Filter Designer.'
' '
'FILTER MENU'
'The Toolbar contains a "Filter Menu" on the left of the window.  This '
'popupmenu displays the name of the filter which you are currently editing.'
'If there are multiple filters selected in the SPTool, this popupmenu'
'lists them all; the currently selected filter is the one which the '
'Filter Designer is currently editing or working on.'
' '
'ZOOM GROUP, HELP BUTTON'
'The Toolbar also contains two "Button Groups": the "Zoom Group" consisting of '
'the seven buttons on the left, and the "Help Group" consisting of the '
'one button on the right.'
' '
'To get help on any of the buttons, click once on the "Help" button, then '
'click on the button for which you want help.'
};

case 'fdzoom:mousezoom'
str{1,1} = 'MOUSE ZOOM';
str{1,2} = {
' '
'Clicking this button puts you in "Mouse Zoom" mode.  In this mode, the '
'mouse pointer becomes a cross when it is inside the main axes area.  You '
'can click and drag a rectangle in the main axes, and the main axes display '
'will zoom in to that region.  If you click with the left button at a point '
'in the main axes, the main axes display will zoom in to that point for a '
'more detailed look at the response there.  Similarly, you can click with '
'the right mouse button (shift click on the Mac) at a point in the main axes '
'to zoom out from that point for a wider view of the response.'
' '
'To get out of mouse zoom mode without zooming in or out, click on the '
'Mouse Zoom button again.'
' '
'ZOOM PERSISTENCE'
' '
'Normally you leave zoom mode as soon as you zoom in or out once.  In order '
'to zoom in or out again, the Mouse Zoom button must be clicked again. '
'However, the mouse zoom mode will remain enabled after a zoom if the box '
'labeled ''Stay in Zoom-Mode after Zoom'' is checked in the Preferences for '
'SPTool window in the Filter Designer category.  The Preferences for SPTool '
'window can be opened by selecting Preferences under the File menu in '
'SPTool.'
};

case 'fdzoom:zoomout'
str{1,1} = 'FULL VIEW';
str{1,2} = {
'Clicking this button restores the data limits of the main axes to show all '
'of the filter''s response (or all of the poles and zeros in the Pole/Zero'
'Editor).'
};

case 'fdzoom:zoominy'
str{1,1} = 'ZOOM IN Y';
str{1,2} = {
'Clicking this button zooms in on the response, cutting the vertical range '
'of the main axes in half.  The x-limits (horizontal scaling) of the main '
'axes are not changed.'
' '
'Note: in the Pole/Zero Editor, both X- and Y-directions are zoomed-in'
'since the aspect ratio of the Z-plane axes is 1:1.'
};

case 'fdzoom:zoomouty'
str{1,1} = 'ZOOM OUT Y';
str{1,2} = {
'Clicking this button zooms out from the response, expanding the vertical '
'range of the main axes by a factor of two.  The x-limits (horizontal '
'scaling) of the main axes are not changed.'
' '
'Note: in the Pole/Zero Editor, both X- and Y-directions are zoomed-out'
'since the aspect ratio of the Z-plane axes is 1:1.'
};

case 'fdzoom:zoominx'
str{1,1} = 'ZOOM IN X';
str{1,2} = {
'Clicking this button zooms in on the response, cutting the horizontal '
'range of the main axes in half.  The y-limits (vertical scaling) of the '
'main axes are not changed.'
' '
'Note: in the Pole/Zero Editor, both X- and Y-directions are zoomed-in'
'since the aspect ratio of the Z-plane axes is 1:1.'
};

case 'fdzoom:zoomoutx'
str{1,1} = 'ZOOM OUT X';
str{1,2} = {
'Clicking this button zooms out from the response, expanding the horizontal '
'range of the main axes by a factor of two.  The y-limits (vertical '
'scaling) of the main axes are not changed.'
' '
'Note: in the Pole/Zero Editor, both X- and Y-directions are zoomed-out'
'since the aspect ratio of the Z-plane axes is 1:1.'
};

case 'fdzoom:passband'
str{1,1} = 'PASSBAND ZOOM';
str{1,2} = {
'Clicking this button zooms in on the passband of the response.  Both the '
'x- and y-limits of the main axes are changed so that the passband fills '
'the main axes.  There is only one level of detail in the passband zoom; '
'that is, you cannot zoom in to the passband further by clicking the '
'Passband Zoom button multiple times.'
' '
'There is no stopband zoom button because by hitting Full View you are only '
'one mouse zoom away from viewing the stopband.'
' '
'In the Pole/Zero Editor, this button has no effect (since there is no'
'"passband" in the pole/zero plot).'
};

case 'Fs'
str{1,1} = 'SAMPLING FREQ.';
str{1,2} = {
' '
'This displays the sampling frequency.  To change this filter''s sampling '
'frequency, enter a value in this box, or use the Edit/Sampling Frequency'
'menu of the SPTool.  '
' '
'Measurements corresponding to the edges and widths of the passband and '
'stopband change accordingly when you change Fs.'
};

case 'close'
str{1,1} = 'CLOSE';
str{1,2} = {
' '
'Select this menu option to close the Filter Designer.  Any settings you '
'changed and saved with the Preferences window will be retained the next '
'time you open a Filter Designer.'
' '
};

case 'overlay'
str{1,1} = 'OVERLAY';
str{1,2} = {
' '
'Click on this button to select a spectrum, from the list of '
'spectra in the SPTool, which will be superimposed on the filter''s'
'response.  This superimposed spectrum will remain until you click'
'"Overlay Spectrum" again and select "<none>".'
' '
'This feature is useful if you would like to design a filter to'
'pass or stop a certain range of frequencies designated by the'
'frequency content of a signal.'
};

case 'bandpop1'
str{1,1} = 'BAND TYPE';
str{1,2} = {
'BAND CONFIGURATION POPUP-MENU'
' '
'This menu allows you to set the band configuration of the filter: either '
'lowpass, highpass, bandpass or bandstop.'
' '
'If "Minimum Order" is checked, the frequency band edge specifications will '
'have the following relationships:'
'    ''lowpass''      0 <  Fp <  Fs < Fsamp/2'
'    ''highpass''     0 <  Fs <  Fp < Fsamp/2'
'    ''bandpass''     0 < Fs1 < Fp1 < Fp2 < Fs2 < Fsamp/2'
'    ''bandstop''     0 < Fp1 < Fs1 < Fs2 < Fp2 < Fsamp/2'
'where Fsamp is the sampling frequency of the filter.'
' '
'Refer to the figure entitled "Band Configurations" for a graphic '
'description of the specifications for minimum order filters.'
' '
'The specifications will vary with the band configuration in different ways '
'depending on the Filter Design Algorithm and whether "Minimum Order" is '
'checked.'
};

case 'passframe'
str{1,1} = 'PASSBAND SPECS';
str{1,2} = {
'This frame contains the passband specifications.'
};

case 'stopframe'
str{1,1} = 'STOPBAND SPECS';
str{1,2} = {
'This frame contains the stopband specifications.'
};

case 'minordcheckbox1'
str{1,1} = 'MINIMUM ORDER';
str{1,2} = {
'Check this box to design the filter of smallest order which achieves a set '
'of desired pass and stopband specifications.  This checkbox determines if '
'you are performing a "high level" design based on desired specifications, '
'or a "low level" design where you specify the filter order and other '
'algorithm specific parameters directly.'
' '
'The desired ("high level") specifications for minimum order filters are'
'    - frequency band edges (Fp, Fs  or  Fp1, Fp2, Fs1, Fs2),'
'    - maximum allowable ripple in the passband Rp, in decibels, and'
'    - minimum allowable attenuation in the stopband Rs, in decibels.'
' '
'Refer to the figure entitled "Band Configurations" for a graphic '
'description of the specifications for minimum order filters. '
' '
'For non minimum order filters, the specifications depend on the filter '
'algorithm.  To find out what they are, uncheck this box and then get help '
'on any of the specifications which appear.  You can also get help on the '
'"Algorithm" popup-menu to find out more about the different algorithms.'
};

case 'order'
str{1,1} = 'ORDER';
str{1,2} = {
'Enter the filter order in this box.  For IIR bandpass and bandstop filters, '
'the true filter order is twice this number.'
};

case 'passframe1'
str{1,1} = 'PASSBAND';
str{1,2} = {
'This frame contains the passband measurements.'
};

case 'stopframe1'
str{1,1} = 'STOPBAND';
str{1,2} = {
'This frame contains the stopband measurements.'
};

case 'order1'
str{1,1} = 'ORDER';
str{1,2} = {
'This is the filter order of the current filter design.  For IIR bandpass '
'and bandstop filters, the true filter order is twice this number.'
' '
'If you would like to change this order, uncheck the "Minimum Order" box '
'under "Specifications".'
' '
' '
};

case {'pb1:fdremez:min:1','pb1:fdfirls:min:1','pb1:fdkaiser:min:1','pb1:fdbutter:min:1','pb1:fdcheby1:min:1','pb1:fdcheby2:min:1','pb1:fdellip:min:1'}
str{1,1} = 'Fp';
str{1,2} = {
'This is the passband edge frequency Fp.'
};

case {'pb1:fdremez:min:2','pb1:fdfirls:min:2','pb1:fdkaiser:min:2','pb1:fdbutter:min:2','pb1:fdcheby1:min:2','pb1:fdcheby2:min:2','pb1:fdellip:min:2'}
str{1,1} = 'Fp';
str{1,2} = {
'This is the passband edge frequency Fp.'
};

case {'pb1:fdremez:min:3','pb1:fdfirls:min:3','pb1:fdkaiser:min:3','pb1:fdbutter:min:3','pb1:fdcheby1:min:3','pb1:fdcheby2:min:3','pb1:fdellip:min:3'}
str{1,1} = 'Fp1';
str{1,2} = {
'This is the lower passband edge frequency Fp1.'
};

case {'pb1:fdremez:min:4','pb1:fdfirls:min:4','pb1:fdkaiser:min:4','pb1:fdbutter:min:4','pb1:fdcheby1:min:4','pb1:fdcheby2:min:4','pb1:fdellip:min:4'}
str{1,1} = 'Fp1';
str{1,2} = {
'This is the lower passband edge frequency Fp1.'
};

case {'pb1:fdremez:set:1','pb1:fdfirls:set:1','pb1:fdcheby1:set:1','pb1:fdcheby2:set:1','pb1:fdellip:set:1'}
str{1,1} = 'Fp';
str{1,2} = {
'This is the passband edge frequency Fp.'
};

case {'pb1:fdkaiser:set:1','pb1:fdkaiser:set:2'}
str{1,1} = 'Fc';
str{1,2} = {
'This is the cut-off frequency Fc of the ideal brickwall filter.'
};

case {'pb1:fdbutter:set:1','pb1:fdbutter:set:2'}
str{1,1} = 'F3db';
str{1,2} = {
'This is the 3dB frequency F3db, which characterizes the Butterworth filter.'
'The magnitude of the filter''s response at F3db is 1/sqrt(2), or '
'approximately -3 dB.'
};

case {'pb1:fdremez:set:2','pb1:fdfirls:set:2','pb1:fdcheby1:set:2','pb1:fdcheby2:set:2','pb1:fdellip:set:2'}
str{1,1} = 'Fp';
str{1,2} = {
'This is the passband edge frequency Fp.'
};

case {'pb1:fdremez:set:3','pb1:fdfirls:set:3','pb1:fdcheby1:set:3','pb1:fdcheby2:set:3','pb1:fdellip:set:3'}
str{1,1} = 'Fp1';
str{1,2} = {
'This is the lower passband edge frequency Fp1.'
};

case {'pb1:fdkaiser:set:3','pb1:fdkaiser:set:4'}
str{1,1} = 'Fc1';
str{1,2} = {
'This is the lower cut-off frequency Fc1 of the ideal brickwall filter.'
};

case {'pb1:fdbutter:set:3','pb1:fdbutter:set:4'}
str{1,1} = 'F3db1';
str{1,2} = {
'This is the lower 3dB frequency F3db1, which characterizes the Butterworth '
'filter along with F3db2.  The magnitude of the filter''s response at F3db1 '
'is 1/sqrt(2), or approximately -3 dB.'
};

case {'pb1:fdremez:set:4','pb1:fdfirls:set:4','pb1:fdcheby1:set:4','pb1:fdcheby2:set:4','pb1:fdellip:set:4'}
str{1,1} = 'Fp1';
str{1,2} = {
'This is the lower passband edge frequency Fp1.'
' '
};

case {'pb2:fdremez:min:3','pb2:fdfirls:min:3','pb2:fdkaiser:min:3','pb2:fdbutter:min:3','pb2:fdcheby1:min:3','pb2:fdcheby2:min:3','pb2:fdellip:min:3'}
str{1,1} = 'Fp2';
str{1,2} = {
'This is the upper passband edge frequency Fp2.'
};

case {'pb2:fdremez:min:4','pb2:fdfirls:min:4','pb2:fdkaiser:min:4','pb2:fdbutter:min:4','pb2:fdcheby1:min:4','pb2:fdcheby2:min:4','pb2:fdellip:min:4'}
str{1,1} = 'Fp2';
str{1,2} = {
'This is the upper passband edge frequency Fp2.'
};

case {'pb2:fdremez:set:3','pb2:fdfirls:set:3','pb2:fdcheby1:set:3','pb2:fdcheby2:set:3','pb2:fdellip:set:3'}
str{1,1} = 'Fp2';
str{1,2} = {
'This is the upper passband edge frequency Fp2.'
};

case {'pb2:fdkaiser:set:3','pb2:fdkaiser:set:4'}
str{1,1} = 'Fc2';
str{1,2} = {
'This is the upper cut-off frequency Fc2 of the ideal brickwall filter.'
};

case {'pb2:fdbutter:set:3','pb2:fdbutter:set:4'}
str{1,1} = 'F3db2';
str{1,2} = {
'This is the upper 3dB frequency F3db2, which characterizes the Butterworth '
'filter along with F3db1.  The magnitude of the filter''s response at F3db2 '
'is 1/sqrt(2), or approximately -3 dB.'
};

case {'pb2:fdremez:set:4','pb2:fdfirls:set:4','pb2:fdcheby1:set:4','pb2:fdcheby2:set:4','pb2:fdellip:set:4'}
str{1,1} = 'Fp2';
str{1,2} = {
'This is the upper passband edge frequency Fp2.'
' '
' '
};

case {'pb3:fdremez:min:1','pb3:fdfirls:min:1','pb3:fdkaiser:min:1','pb3:fdbutter:min:1','pb3:fdcheby1:min:1','pb3:fdcheby2:min:1','pb3:fdellip:min:1'}
str{1,1} = 'Rp';
str{1,2} = {
'This is the desired passband ripple Rp, in decibels.  Enter the maximum '
'amount of ripple you desire in the passband.'
' '
'The maximum value of the filter''s magnitude response (in dB) minus the '
'minimum value will not exceed Rp across the entire passband, except in some '
'cases with Equiripple and Kaiser Window FIR designs.  The measurement '
'"Actual Rp" displays the ripple that the filter actually achieves for these '
'designs.'
' '
'You can also change Rp by dragging the passband specification line up and '
'down in the main axes.'
};

case {'pb3:fdremez:min:2','pb3:fdfirls:min:2','pb3:fdkaiser:min:2','pb3:fdbutter:min:2','pb3:fdcheby1:min:2','pb3:fdcheby2:min:2','pb3:fdellip:min:2'}
str{1,1} = 'Rp';
str{1,2} = {
'This is the desired passband ripple Rp, in decibels.  Enter the maximum '
'amount of ripple you desire in the passband.'
' '
'The maximum value of the filter''s magnitude response (in dB) minus the '
'minimum value will not exceed Rp across the entire passband, except in some '
'cases with Equiripple and Kaiser Window FIR designs.  The measurement '
'"Actual Rp" displays the ripple that the filter actually achieves for these '
'designs.'
' '
'You can also change Rp by dragging the passband specification line up and '
'down in the main axes.'
};

case {'pb3:fdremez:min:3','pb3:fdfirls:min:3','pb3:fdkaiser:min:3','pb3:fdbutter:min:3','pb3:fdcheby1:min:3','pb3:fdcheby2:min:3','pb3:fdellip:min:3'}
str{1,1} = 'Rp';
str{1,2} = {
'This is the desired passband ripple Rp, in decibels.  Enter the maximum '
'amount of ripple you desire in the passband.'
' '
'The maximum value of the filter''s magnitude response (in dB) minus the '
'minimum value will not exceed Rp across the entire passband, except in some '
'cases with Equiripple and Kaiser Window FIR designs.  The measurement '
'"Actual Rp" displays the ripple that the filter actually achieves for these '
'designs.'
' '
'You can also change Rp by dragging the passband specification line up and '
'down in the main axes.'
};

case {'pb3:fdremez:min:4','pb3:fdfirls:min:4','pb3:fdkaiser:min:4','pb3:fdbutter:min:4','pb3:fdcheby1:min:4','pb3:fdcheby2:min:4','pb3:fdellip:min:4'}
str{1,1} = 'Rp';
str{1,2} = {
'This is the desired passband ripple Rp, in decibels.  Enter the maximum '
'amount of ripple you desire in the passband.'
' '
'The maximum value of the filter''s magnitude response (in dB) minus the '
'minimum value will not exceed Rp across the entire passband, except in some '
'cases with Equiripple and Kaiser Window FIR designs.  The measurement '
'"Actual Rp" displays the ripple that the filter actually achieves for these '
'designs.'
' '
'You can also change Rp by dragging the passband specification line up and '
'down in the main axes.'
};

case {'pb3:fdremez:set:1','pb3:fdremez:set:2','pb3:fdremez:set:3','pb3:fdremez:set:4'}
str{1,1} = 'Weight';
str{1,2} = {
'Passband Weight'
' '
'Enter a positive real number here and hit enter to change the passband '
'weight for the Remez algorithm.  '
' '
'Use the passband weight and stopband weight to minimize the error more or '
'less in one band relative to the other, according to the formula:'
' '
' (max. error in passband)*(passband weight) = '
'                  (max. error in stopband)*(stopband weight)'
' '
'For example, make this number larger to decrease "Actual Rp" at the expense '
'of increasing "Actual Rs".'
' '
'You can also change the ratio of the passband and stopband weights by '
'dragging the passband or stopband specifications lines up and down in the '
'main axes.  This will set the weights to approximately obtain the amount of '
'ripple Rp or Rs of the line you are dragging.'
};

case {'pb3:fdfirls:set:1','pb3:fdfirls:set:2','pb3:fdfirls:set:3','pb3:fdfirls:set:4'}
str{1,1} = 'Weight';
str{1,2} = {
'Passband Weight'
' '
'Enter a positive real number here and hit enter to change the passband '
'weight for the least squares design algorithm.'
' '
'Use the passband weight and stopband weight to minimize the error more or '
'less in one band relative to the other.  The larger the weight in a band, '
'the smaller the error (and ripple) will be in that band.  For example, make '
'this number larger to decrease "Actual Rp" at the expense of increasing '
'"Actual Rs".'
' '
'You can also change the ratio of the passband and stopband weights by '
'dragging the passband or stopband specifications lines up and down in the '
'main axes.  This will set the weights to approximately obtain the amount of '
'ripple Rp or Rs of the line you are dragging.   However, since there is no '
'exact formula for the weights for a given Rp and Rs, the actual Rp and Rs '
'after dragging the bands may be different.'
};

case {'pb3:fdkaiser:set:1','pb3:fdkaiser:set:2','pb3:fdkaiser:set:3','pb3:fdkaiser:set:4'}
str{1,1} = 'Beta';
str{1,2} = {
'Beta of Kaiser Window'
' '
'Enter a positive real number in this field to set the Beta parameter of the '
'Kaiser window used in the design of the FIR filter.'
' '
'A Beta of 0 is a rectangular window which has high sidelobes but a narrow '
'peak in the frequency domain, while a large value of Beta widens the peak '
'but lowers the sidelobes significantly.  The filter''s response generally '
'has less ripple as Beta increases, but the transition band (between the '
'pass and stopbands) widens.'
};

case {'pb3:fdcheby1:set:1','pb3:fdellip:set:1','pb3:fdcheby1:set:2','pb3:fdellip:set:2','pb3:fdcheby1:set:3','pb3:fdellip:set:3','pb3:fdcheby1:set:4','pb3:fdellip:set:4'}
str{1,1} = 'Rp';
str{1,2} = {
'This is the desired passband ripple Rp, in decibels.  Enter the maximum '
'amount of ripple you desire in the passband.'
' '
'The maximum value of the filter''s magnitude response (in dB) minus the '
'minimum value will not exceed Rp across the entire passband, except in some '
'cases with Equiripple and Kaiser Window FIR designs.  The measurement '
'"Actual Rp" displays the ripple that the filter actually achieves for these '
'designs.'
' '
'You can also change Rp by dragging the passband specification line up and '
'down in the main axes.'
' '
' '
' '
' '
};

case {'sb1:fdremez:min:1','sb1:fdfirls:min:1','sb1:fdkaiser:min:1','sb1:fdbutter:min:1','sb1:fdcheby1:min:1','sb1:fdcheby2:min:1','sb1:fdellip:min:1'}
str{1,1} = 'Fs';
str{1,2} = {
'This is the stopband edge frequency Fs.'
};

case {'sb1:fdremez:min:2','sb1:fdfirls:min:2','sb1:fdkaiser:min:2','sb1:fdbutter:min:2','sb1:fdcheby1:min:2','sb1:fdcheby2:min:2','sb1:fdellip:min:2'}
str{1,1} = 'Fs';
str{1,2} = {
'This is the stopband edge frequency Fs.'
};

case {'sb1:fdremez:min:3','sb1:fdfirls:min:3','sb1:fdkaiser:min:3','sb1:fdbutter:min:3','sb1:fdcheby1:min:3','sb1:fdcheby2:min:3','sb1:fdellip:min:3'}
str{1,1} = 'Fs1';
str{1,2} = {
'This is the lower stopband edge frequency Fs1.'
};

case {'sb1:fdremez:min:4','sb1:fdfirls:min:4','sb1:fdkaiser:min:4','sb1:fdbutter:min:4','sb1:fdcheby1:min:4','sb1:fdcheby2:min:4','sb1:fdellip:min:4'}
str{1,1} = 'Fs1';
str{1,2} = {
'This is the lower stopband edge frequency Fs1.'
};

case {'sb1:fdremez:set:1','sb1:fdfirls:set:1','sb1:fdcheby1:set:1','sb1:fdcheby2:set:1','sb1:fdellip:set:1'}
str{1,1} = 'Fs';
str{1,2} = {
'This is the stopband edge frequency Fs.'
};

case {'sb1:fdremez:set:2','sb1:fdfirls:set:2','sb1:fdcheby1:set:2','sb1:fdcheby2:set:2','sb1:fdellip:set:2'}
str{1,1} = 'Fs';
str{1,2} = {
'This is the stopband edge frequency Fs.'
};

case {'sb1:fdremez:set:3','sb1:fdfirls:set:3','sb1:fdcheby1:set:3','sb1:fdcheby2:set:3','sb1:fdellip:set:3'}
str{1,1} = 'Fs1';
str{1,2} = {
'This is the lower stopband edge frequency Fs1.'
};

case {'sb1:fdremez:set:4','sb1:fdfirls:set:4','sb1:fdcheby1:set:4','sb1:fdcheby2:set:4','sb1:fdellip:set:4'}
str{1,1} = 'Fs1';
str{1,2} = {
'This is the lower stopband edge frequency Fs1.'
' '
};

case {'sb2:fdremez:min:3','sb2:fdfirls:min:3','sb2:fdkaiser:min:3','sb2:fdbutter:min:3','sb2:fdcheby1:min:3','sb2:fdcheby2:min:3','sb2:fdellip:min:3'}
str{1,1} = 'Fs2';
str{1,2} = {
'This is the upper stopband edge frequency Fs2.'
};

case {'sb2:fdremez:min:4','sb2:fdfirls:min:4','sb2:fdkaiser:min:4','sb2:fdbutter:min:4','sb2:fdcheby1:min:4','sb2:fdcheby2:min:4','sb2:fdellip:min:4'}
str{1,1} = 'Fs2';
str{1,2} = {
'This is the upper stopband edge frequency Fs2.'
};

case {'sb2:fdremez:set:3','sb2:fdfirls:set:3','sb2:fdcheby1:set:3','sb2:fdcheby2:set:3','sb2:fdellip:set:3'}
str{1,1} = 'Fs2';
str{1,2} = {
'This is the upper stopband edge frequency Fs2.'
};

case {'sb2:fdremez:set:4','sb2:fdfirls:set:4','sb2:fdcheby1:set:4','sb2:fdcheby2:set:4','sb2:fdellip:set:4'}
str{1,1} = 'Fs2';
str{1,2} = {
'This is the upper stopband edge frequency Fs2.'
' '
' '
};

case {'sb3:fdremez:min:1','sb3:fdfirls:min:1','sb3:fdkaiser:min:1','sb3:fdbutter:min:1','sb3:fdcheby1:min:1','sb3:fdcheby2:min:1','sb3:fdellip:min:1'}
str{1,1} = 'Rs';
str{1,2} = {
'This is the desired stopband attenuation Rs, in decibels.  Enter the minimum '
'amount of attenuation you desire in the stopband.'
' '
'The maximum value of the filter''s magnitude response (in dB) will not '
'exceed -Rs across the entire stopband, except in some cases with Equiripple '
'and Kaiser Window FIR designs.  The measurement "Actual Rs" displays the '
'attenuation that the filter actually achieves for these designs.'
' '
'You can also change Rs by dragging the stopband specification line up and '
'down in the main axes.'
};

case {'sb3:fdremez:min:2','sb3:fdfirls:min:2','sb3:fdkaiser:min:2','sb3:fdbutter:min:2','sb3:fdcheby1:min:2','sb3:fdcheby2:min:2','sb3:fdellip:min:2'}
str{1,1} = 'Rs';
str{1,2} = {
'This is the desired stopband attenuation Rs, in decibels.  Enter the minimum '
'amount of attenuation you desire in the stopband.'
' '
'The maximum value of the filter''s magnitude response (in dB) will not '
'exceed -Rs across the entire stopband, except in some cases with Equiripple '
'and Kaiser Window FIR designs.  The measurement "Actual Rs" displays the '
'attenuation that the filter actually achieves for these designs.'
' '
'You can also change Rs by dragging the stopband specification line up and '
'down in the main axes.'
};

case {'sb3:fdremez:min:3','sb3:fdfirls:min:3','sb3:fdkaiser:min:3','sb3:fdbutter:min:3','sb3:fdcheby1:min:3','sb3:fdcheby2:min:3','sb3:fdellip:min:3'}
str{1,1} = 'Rs';
str{1,2} = {
'This is the desired stopband attenuation Rs, in decibels.  Enter the minimum '
'amount of attenuation you desire in the stopband.'
' '
'The maximum value of the filter''s magnitude response (in dB) will not '
'exceed -Rs across the entire stopband, except in some cases with Equiripple '
'and Kaiser Window FIR designs.  The measurement "Actual Rs" displays the '
'attenuation that the filter actually achieves for these designs.'
' '
'You can also change Rs by dragging the stopband specification line up and '
'down in the main axes.'
};

case {'sb3:fdremez:min:4','sb3:fdfirls:min:4','sb3:fdkaiser:min:4','sb3:fdbutter:min:4','sb3:fdcheby1:min:4','sb3:fdcheby2:min:4','sb3:fdellip:min:4'}
str{1,1} = 'Rs';
str{1,2} = {
'This is the desired stopband attenuation Rs, in decibels.  Enter the minimum '
'amount of attenuation you desire in the stopband.'
' '
'The maximum value of the filter''s magnitude response (in dB) will not '
'exceed -Rs across the entire stopband, except in some cases with Equiripple '
'and Kaiser Window FIR designs.  The measurement "Actual Rs" displays the '
'attenuation that the filter actually achieves for these designs.'
' '
'You can also change Rs by dragging the stopband specification line up and '
'down in the main axes.'
};

case {'sb3:fdremez:set:1','sb3:fdremez:set:2','sb3:fdremez:set:3','sb3:fdremez:set:4'}
str{1,1} = 'Weight';
str{1,2} = {
'Stopband Weight'
' '
'Enter a positive real number here and hit enter to change the stopband '
'weight for the Remez algorithm.  '
' '
'Use the stopband  weight and passband weight to minimize the error more or '
'less in one band relative to the other, according to the formula:'
' '
' (max. error in passband)*(passband weight) = '
'                  (max. error in stopband)*(stopband weight)'
' '
'For example, make this number larger to lower "Actual Rs" at the expense '
'of increasing "Actual Rp".'
' '
'You can also change the ratio of the passband and stopband weights by '
'dragging the passband or stopband specifications lines up and down in the '
'main axes.  This will set the weights to approximately obtain the amount of '
'ripple Rp or Rs of the line you are dragging.'
};

case {'sb3:fdfirls:set:1','sb3:fdfirls:set:2','sb3:fdfirls:set:3','sb3:fdfirls:set:4'}
str{1,1} = 'Weight';
str{1,2} = {
'Stopband Weight'
' '
'Enter a positive real number here and hit enter to change the stopband '
'weight for the least squares design algorithm.'
' '
'Use the passband weight and stopband weight to minimize the error more or '
'less in one band relative to the other.  The larger the weight in a band, '
'the smaller the error (and ripple) will be in that band.  For example, make '
'this number larger to lower "Actual Rs" at the expense of increasing '
'"Actual Rp".'
' '
'You can also change the ratio of the passband and stopband weights by '
'dragging the passband or stopband specifications lines up and down in the '
'main axes.  This will set the weights to approximately obtain the amount of '
'ripple Rp or Rs of the line you are dragging.   However, since there is no '
'exact formula for the weights for a given Rp and Rs, the actual Rp and Rs '
'after dragging the bands may be different.'
};

case {'sb3:fdcheby1:set:1','sb3:fdellip:set:1','sb3:fdcheby1:set:2','sb3:fdellip:set:2','sb3:fdcheby1:set:3','sb3:fdellip:set:3','sb3:fdcheby1:set:4','sb3:fdellip:set:4'}
str{1,1} = 'Rs';
str{1,2} = {
'This is the desired stopband attenuation Rs, in decibels.  Enter the minimum '
'amount of attenuation you desire in the stopband.'
' '
'The maximum value of the filter''s magnitude response (in dB) will not '
'exceed -Rs across the entire stopband, except in some cases with Equiripple '
'and Kaiser Window FIR designs.  The measurement "Actual Rs" displays the '
'attenuation that the filter actually achieves for these designs.'
' '
'You can also change Rs by dragging the stopband specification line up and '
'down in the main axes.'
' '
' '
};

case {'pbm1:fdremez:min:1','pbm1:fdremez:min:2','pbm1:fdremez:min:3','pbm1:fdremez:min:4','pbm1:fdremez:set:1','pbm1:fdremez:set:2','pbm1:fdremez:set:3','pbm1:fdremez:set:4'}
str{1,1} = 'Actual Rp';
str{1,2} = {
'Actual Passband Ripple'
' '
'This is the actual passband ripple Rp, in decibels, of the designed '
'filter.  '
};

case {'pbm1:fdfirls:min:1','pbm1:fdfirls:min:2','pbm1:fdfirls:min:3','pbm1:fdfirls:min:4','pbm1:fdfirls:set:1','pbm1:fdfirls:set:2','pbm1:fdfirls:set:3','pbm1:fdfirls:set:4'}
str{1,1} = 'Actual Rp';
str{1,2} = {
'Actual Passband Ripple'
' '
'This is the actual passband ripple Rp, in decibels, of the designed '
'filter.  '
};

case {'pbm1:fdkaiser:min:1','pbm1:fdkaiser:min:2'}
str{1,1} = 'Fc';
str{1,2} = {
'Cut-off frequency Fc'
' '
'This is the frequency half way between Fp and Fs, used to define the ideal '
'"brickwall" filter which defines the filter coefficients prior to applying '
'the Kaiser window.'
};

case {'pbm1:fdkaiser:min:3','pbm1:fdkaiser:min:4'}
str{1,1} = 'Fc1';
str{1,2} = {
'Lower cut-off frequency Fc1'
' '
'This is the frequency half way between Fp1 and Fs1, used together with Fc2 '
'to define the ideal "brickwall" filter which defines the filter '
'coefficients prior to applying the Kaiser window..'
};

case {'pbm1:fdbutter:min:1','pbm1:fdbutter:min:2','pbm1:fdbutter:min:3','pbm1:fdbutter:min:4'}
str{1,1} = 'Actual Rp';
str{1,2} = {
'Actual Passband Ripple'
' '
'This is the actual passband ripple Rp, in decibels, of the designed filter.  '
'This number is often smaller than the desired passband ripple Rp under '
'"Specifications" because Butterworth filters meet the stopband '
'specification exactly and exceed the passband specification.'
};

case {'pbm1:fdkaiser:set:1','pbm1:fdkaiser:set:2','pbm1:fdbutter:set:1','pbm1:fdbutter:set:2','pbm1:fdcheby2:set:1','pbm1:fdcheby2:set:2'}
str{1,1} = 'Fp';
str{1,2} = {
'Passband Edge Frequency Fp (Interactive)'
' '
'This is the passband edge frequency Fp.  Enter a frequency here and Rp '
'changes to reflect how much ripple is in the passband given the passband '
'edge which you entered.'
' '
'Fp and Rp define an "interactive passband measurement" which allows you to '
'ask questions such as, "if the lower passband edge is at 50 Hz (for '
'instance), what is the ripple Rp in the passband?".  If you change either '
'Fp or Rp, the other measurement changes to reflect the passband given the '
'parameter you entered.  You can also drag the passband measurement line in '
'the main axes area, either up and down to change Rp, or back and forth to '
'change Fp.'
};

case {'pbm1:fdkaiser:set:3','pbm1:fdkaiser:set:4','pbm1:fdbutter:set:3','pbm1:fdbutter:set:4','pbm1:fdcheby2:set:3','pbm1:fdcheby2:set:4'}
str{1,1} = 'Fp1';
str{1,2} = {
'Lower Passband Edge Frequency Fp1 (Interactive)'
' '
'This is the lower passband edge frequency Fp1.  Enter a frequency here and '
'Rp changes to reflect how much ripple is in the passband at the passband '
'edge which you entered.  Fp2 also changes to reflect how far the passband '
'extends given the new ripple Rp.'
' '
'Fp1, Fp2, and Rp define an "interactive passband measurement" which allows '
'you to ask questions such as, "if the lower passband edge is at 50 Hz (for '
'instance), what is the ripple Rp in the passband?".  If you change any of'
'Fp1, Fp2 or Rp, the other two measurements change to reflect the passband '
'given the parameter you entered.  You can also drag the passband measurement'
'line in the main axes area, either up and down to change Rp, or back and '
'forth to change Fp1 or Fp2.'
};

case {'pbm2:fdremez:min:1','pbm2:fdremez:min:2','pbm2:fdremez:min:3','pbm2:fdremez:min:4'}
str{1,1} = 'Weight';
str{1,2} = {
'Passband Weight'
' '
'This positive real number is the passband weight for the Remez algorithm.'
' '
'The passband weight and stopband weight minimize the error more or '
'less in one band relative to the other, according to the formula:'
' '
' (max. error in passband)*(passband weight) = '
'                  (max. error in stopband)*(stopband weight)'
' '
'For minimum order filters, the passband and stopband weights are determined '
'by the desired Rp and Rs specifications.  Rp and Rs are converted to linear '
'scale to determine the quantities delta_p and delta_s, the desired maximum '
'error versus the ideal passband and stopband responses, respectively:'
'    delta_p = (10^(Rp/20)-1)/(10^(Rp/20)+1)'
'    delta_s = 10^(-Rs/20)'
' '
'The passband and stopband weight are then determined by'
'    passband weight = 1/delta_p * max([delta_p, delta_s])'
'    stopband weight = 1/delta_s * max([delta_p, delta_s])'
};

case {'pbm2:fdkaiser:min:3','pbm2:fdkaiser:min:4'}
str{1,1} = 'Fc2';
str{1,2} = {
'Upper cut-off frequency Fc2'
' '
'This is the frequency half way between Fp2 and Fs2, used together with Fc1 '
'to define the ideal "brickwall" filter which defines the filter '
'coefficients prior to applying the Kaiser window..'
};

case {'pbm2:fdkaiser:set:3','pbm2:fdkaiser:set:4','pbm2:fdbutter:set:3','pbm2:fdbutter:set:4','pbm2:fdcheby2:set:3','pbm2:fdcheby2:set:4'}
str{1,1} = 'Fp2';
str{1,2} = {
'Lower Passband Edge Frequency Fp2 (Interactive)'
' '
'This is the upper passband edge frequency Fp2.  Enter a frequency here and '
'Rp changes to reflect how much ripple is in the passband at the passband '
'edge which you entered.  Fp1 also changes to reflect how far the passband '
'extends given the new ripple Rp.'
' '
'Fp1, Fp2, and Rp define an "interactive passband measurement" which allows '
'you to ask questions such as, "if the upper passband edge is at 50 Hz (for '
'instance), what is the ripple Rp in the passband?".  If you change any of'
'Fp1, Fp2 or Rp, the other two measurements change to reflect the passband '
'given the parameter you entered.  You can also drag the passband measurement'
'line in the main axes area, either up and down to change Rp, or back and '
'forth to change Fp1 or Fp2.'
' '
};

case {'pbm3:fdkaiser:min:1','pbm3:fdkaiser:min:2','pbm3:fdkaiser:min:3','pbm3:fdkaiser:min:4'}
str{1,1} = 'Beta';
str{1,2} = {
'Beta of Kaiser Window'
' '
'This is the Beta parameter chosen in attempt to meet the desired pass and '
'stopband specifications.  See the function KAISERORD for more details.'
};

case {'pbm3:fdkaiser:set:1','pbm3:fdkaiser:set:2','pbm3:fdbutter:set:1','pbm3:fdbutter:set:2','pbm3:fdcheby2:set:1','pbm3:fdcheby2:set:2'}
str{1,1} = 'Rp';
str{1,2} = {
'Passband Ripple Rp (Interactive)'
' '
'This is the passband ripple Rp, in decibels.  Enter a number here and Fp '
'changes to reflect how far the passband extends given the new ripple that '
'you have entered.'
' '
'Fp and Rp define an "interactive passband measurement" which allows you to '
'ask questions such as, "if the upper passband edge is at 50 Hz (for '
'instance), what is the ripple Rp in the passband?".  If you change either '
'Fp or Rp, the other measurement changes to reflect the passband given the '
'parameter you entered.  You can also drag the passband measurement line in '
'the main axes area, either up and down to change Rp, or back and forth to '
'change Fp.'
};

case {'pbm3:fdkaiser:set:3','pbm3:fdkaiser:set:4','pbm3:fdbutter:set:3','pbm3:fdbutter:set:4','pbm3:fdcheby2:set:3','pbm3:fdcheby2:set:4'}
str{1,1} = 'Rp';
str{1,2} = {
'Passband Ripple Rp (Interactive)'
' '
'This is the passband ripple Rp, in decibels.  Enter a number here and Fp1 '
'and Fp2 change to reflect how far the passband extends given the new ripple '
'that you have entered.'
' '
'Fp1, Fp2, and Rp define an "interactive passband measurement" which allows '
'you to ask questions such as, "if the upper passband edge is at 50 Hz (for '
'instance), what is the ripple Rp in the passband?".  If you change any of'
'Fp1, Fp2 or Rp, the other two measurements change to reflect the passband '
'given the parameter you entered.  You can also drag the passband measurement'
'line in the main axes area, either up and down to change Rp, or back and '
'forth to change Fp1 or Fp2.'
' '
' '
' '
};

case {'sbm1:fdremez:min:1','sbm1:fdremez:min:2','sbm1:fdremez:min:3','sbm1:fdremez:min:4','sbm1:fdremez:set:1','sbm1:fdremez:set:2','sbm1:fdremez:set:3','sbm1:fdremez:set:4'}
str{1,1} = 'Actual Rs';
str{1,2} = {
'Actual Stopband Attenuation'
' '
'This is the actual stopband attenuation Rs, in decibels, of the designed '
'filter.  '
};

case {'sbm1:fdfirls:min:1','sbm1:fdfirls:min:2','sbm1:fdfirls:min:3','sbm1:fdfirls:min:4','sbm1:fdfirls:set:1','sbm1:fdfirls:set:2','sbm1:fdfirls:set:3','sbm1:fdfirls:set:4'}
str{1,1} = 'Actual Rs';
str{1,2} = {
'Actual Stopband Attenuation'
' '
'This is the actual stopband attenuation Rs, in decibels, of the designed '
'filter.  '
};

case {'sbm1:fdkaiser:min:1','sbm1:fdkaiser:min:2','sbm1:fdkaiser:min:3','sbm1:fdkaiser:min:4'}
str{1,1} = 'Actual Rp';
str{1,2} = {
'Actual Passband Ripple'
' '
'This is the actual passband ripple Rp, in decibels, of the designed '
'filter.  '
};

case {'sbm1:fdbutter:min:1','sbm1:fdbutter:min:2'}
str{1,1} = 'F3dB';
str{1,2} = {
'3 dB Frequency F3dB'
' '
'This is the frequency where the Butterworth filter''s magnitude response '
'equals 1/sqrt(2), or approximately -3 decibels.  '
' '
'For typical filters (in which Rp < 3 and Rs > 3), this frequency will be '
'between Fp and Fs.'
'  For lowpass: Fp < F3dB < Fs'
'  For highpass: Fs < F3dB < Fp                '
};

case 'sbm1:fdbutter:min:3'
str{1,1} = 'F3dB 1';
str{1,2} = {
'Lower 3 dB Frequency F3dB 1'
' '
'This is the lower frequency where the Butterworth filter''s magnitude '
'response equals 1/sqrt(2), or approximately -3 decibels.'
' '
'For typical filters (in which Rp < 3 and Rs > 3), this frequency will be '
'between Fp1 and Fs1, i.e.'
'  Fs1 < F3dB 1 < Fp1 < Fp2 < F3dB 2 < Fs2'
};

case 'sbm1:fdbutter:min:4'
str{1,1} = 'F3dB 1';
str{1,2} = {
'Lower 3 dB Frequency F3dB 1'
' '
'This is the lower frequency where the Butterworth filter''s magnitude '
'response equals 1/sqrt(2), or approximately -3 decibels.'
' '
'For typical filters (in which Rp < 3 and Rs > 3), this frequency will be '
'between Fp1 and Fs1, i.e.'
'  Fp1 < F3dB 1 < Fs1 < Fs2 < F3dB 2 < Fp2'
' '
};

case {'sbm1:fdcheby1:min:1','sbm1:fdcheby1:min:2','sbm1:fdcheby2:min:1','sbm1:fdcheby2:min:2','sbm1:fdellip:min:1','sbm1:fdellip:min:2'}
str{1,1} = 'Actual Fs';
str{1,2} = {
'Actual Stopband Edge Fs'
' '
'For this type of filter, the actual stopband is usually wider than the '
'desired stopband as specified by Fs under "Specifications".  This '
'measurement records the actual stopband edge Fs for this filter.'
};

case {'sbm1:fdcheby1:min:3','sbm1:fdcheby1:min:4','sbm1:fdcheby2:min:3','sbm1:fdcheby2:min:4','sbm1:fdellip:min:3','sbm1:fdellip:min:4'}
str{1,1} = 'Actual Fs1';
str{1,2} = {
'Actual Lower Stopband Edge Fs1'
' '
'For this type of filter, the actual stopband is usually wider than the '
'desired stopband as specified by Fs1 and Fs2 under "Specifications".  This '
'measurement records the actual lower stopband edge Fs1 for this filter.'
};

case {'sbm2:fdellip:set:1','sbm2:fdellip:set:2'}
str{1,1} = 'Fs';
str{1,2} = {
'Stopband Edge Fs'
' '
'For Elliptic filters, you specify the passband edge Fp, and the transition '
'width is minimized for a given filter order.  This measurement records the '
'actual stopband edge Fs for this filter.'
};

case {'sbm1:fdellip:set:3','sbm1:fdellip:set:4'}
str{1,1} = 'Fs1';
str{1,2} = {
'Lower Stopband Edge Fs1'
' '
'For Elliptic filters, you specify the passband edges Fp1 and Fp2, and the '
'transition width is minimized for a given filter order.  This measurement '
'records the actual lower stopband edge Fs1 for this filter.'
};

case {'sbm1:fdkaiser:set:1','sbm1:fdkaiser:set:2','sbm1:fdbutter:set:1','sbm1:fdbutter:set:2','sbm1:fdcheby1:set:1','sbm1:fdcheby1:set:2'}
str{1,1} = 'Fs';
str{1,2} = {
'Stopband Edge Frequency Fs (Interactive)'
' '
'This is the stopband edge frequency Fs.  Enter a frequency here and Rs '
'changes to reflect how much attenuation is achieved in the stopband given '
'the stopband edge which you entered.'
' '
'Fs and Rs define an "interactive stopband measurement" which allows you to '
'ask questions such as, "if the stopband edge is at 50 Hz (for instance), '
'what is the attenuation Rs in the stopband?".  If you change either Fs or '
'Rs, the other stopband measurement changes to reflect the stopband given '
'the parameter you entered.  You can also drag the stopband measurement line '
'in the main axes area, either up and down to change Rs, or back and forth '
'to change Fs.'
};

case {'sbm1:fdkaiser:set:3','sbm1:fdkaiser:set:4','sbm1:fdbutter:set:4','sbm1:fdbutter:set:4','sbm1:fdcheby1:set:3','sbm1:fdcheby1:set:4'}
str{1,1} = 'Fs1';
str{1,2} = {
'Lower Stopband Edge Frequency Fs1 (Interactive)'
' '
'This is the lower stopband edge frequency Fs1.  Enter a frequency here and Rs '
'changes to reflect how much attenuation is achieved in the stopband given '
'the stopband edge which you entered.  Fs2 also changes to reflect how far '
'the passband extends given the new attenuation Rs.'
' '
'Fs1, Fs2 and Rs define an "interactive stopband measurement" which allows '
'you to ask questions such as, "if the lower stopband edge is at 50 Hz (for '
'instance), what is the attenuation Rs in the stopband?".  If you change any '
'of Fs1, Fs2 or Rs, the other two stopband measurements change to reflect '
'the stopband given the parameter you entered.  You can also drag the '
'stopband measurement line in the main axes area, either up and down to '
'change Rs, or back and forth to change Fs1 or Fs2.'
' '
};

case {'sbm2:fdremez:min:1','sbm2:fdremez:min:2','sbm2:fdremez:min:3','sbm2:fdremez:min:4'}
str{1,1} = 'Weight';
str{1,2} = {
'Stopband Weight'
' '
'This positive real number is the stopband weight for the Remez algorithm.'
' '
'The passband weight and stopband weight minimize the error more or '
'less in one band relative to the other, according to the formula:'
' '
' (max. error in passband)*(passband weight) = '
'                  (max. error in stopband)*(stopband weight)'
' '
'For minimum order filters, the passband and stopband weights are determined '
'by the desired Rp and Rs specifications.  Rp and Rs are converted to linear '
'scale to determine the quantities delta_p and delta_s, the desired maximum '
'error versus the ideal passband and stopband responses, respectively:'
'    delta_p = (10^(Rp/20)-1)/(10^(Rp/20)+1)'
'    delta_s = 10^(-Rs/20)'
' '
'The passband and stopband weight are then determined by'
'    passband weight = 1/delta_p * max([delta_p, delta_s])'
'    stopband weight = 1/delta_s * max([delta_p, delta_s])'
};

case {'sbm2:fdkaiser:min:1','sbm2:fdkaiser:min:2','sbm2:fdkaiser:min:3','sbm2:fdkaiser:min:4'}
str{1,1} = 'Actual Rs';
str{1,2} = {
'Actual Stopband Attenuation'
' '
'This is the actual stopband attenution Rs, in decibels, of the designed '
'filter.  '
};

case 'sbm2:fdbutter:min:3'
str{1,1} = 'F3dB 2';
str{1,2} = {
'Upper 3 dB Frequency F3dB 2'
' '
'This is the upper frequency where the Butterworth filter''s magnitude '
'response equals 1/sqrt(2), or approximately -3 decibels.'
' '
'For typical filters (in which Rp < 3 and Rs > 3), this frequency will be '
'between Fp2 and Fs2, i.e.'
'  Fs1 < F3dB 1 < Fp1 < Fp2 < F3dB 2 < Fs2'
};

case 'sbm2:fdbutter:min:4'
str{1,1} = 'F3dB 2';
str{1,2} = {
'Upper 3 dB Frequency F3dB 2'
' '
'This is the upper frequency where the Butterworth filter''s magnitude '
'response equals 1/sqrt(2), or approximately -3 decibels.'
' '
'For typical filters (in which Rp < 3 and Rs > 3), this frequency will be '
'between Fp2 and Fs2, i.e.'
'  Fp1 < F3dB 1 < Fs1 < Fs2 < F3dB 2 < Fp2'
};

case {'sbm2:fdcheby1:min:3','sbm2:fdcheby1:min:4','sbm2:fdcheby2:min:3','sbm2:fdcheby2:min:4','sbm2:fdellip:min:3','sbm2:fdellip:min:4'}
str{1,1} = 'Actual Fs2';
str{1,2} = {
'Actual Upper Stopband Edge Fs2'
' '
'For this type of filter, the actual stopband is usually wider than the '
'desired stopband as specified by Fs1 and Fs2 under "Specifications".  This '
'measurement records the actual upper stopband edge Fs2 for this filter.'
};

case {'sbm2:fdellip:set:3','sbm2:fdellip:set:4'}
str{1,1} = 'Fs2';
str{1,2} = {
'Upper Stopband Edge Fs2'
' '
'For Elliptic filters, you specify the passband edges Fp1 and Fp2, and the '
'transition width is minimized for a given filter order.'
' '
'This measurement records the upper stopband edge Fs2 for this filter.'
' '
};

case {'sbm2:fdkaiser:set:3','sbm2:fdkaiser:set:4','sbm2:fdbutter:set:4','sbm2:fdbutter:set:4','sbm2:fdcheby1:set:3','sbm2:fdcheby1:set:4'}
str{1,1} = 'Fs2';
str{1,2} = {
'Upper Stopband Edge Frequency Fs2 (Interactive)'
' '
'This is the upper stopband edge frequency Fs2.  Enter a frequency here and '
'Rs changes to reflect how much attenuation is achieved in the stopband '
'given the stopband edge which you entered.  Fs1 also changes to reflect how '
'far the passband extends given the new attenuation Rs.'
' '
'Fs1, Fs2 and Rs define an "interactive stopband measurement" which allows '
'you to ask questions such as, "if the lower stopband edge is at 50 Hz (for '
'instance), what is the attenuation Rs in the stopband?".  If you change any '
'of Fs1, Fs2 or Rs, the other two stopband measurements change to reflect '
'the stopband given the parameter you entered.  You can also drag the '
'stopband measurement line in the main axes area, either up and down to '
'change Rs, or back and forth to change Fs1 or Fs2.'
' '
};

case {'sbm3:fdkaiser:set:1','sbm3:fdkaiser:set:2','sbm3:fdbutter:set:1','sbm3:fdbutter:set:2','sbm3:fdcheby1:set:1','sbm3:fdcheby1:set:2'}
str{1,1} = 'Rs';
str{1,2} = {
'Stopband Attenuation Rs (Interactive)'
' '
'This is the stopband attenuation Rs, in decibels.  Enter a number here and '
'Fs changes to reflect how far the stopband extends given the new '
'attenuation that you have entered.'
' '
'Fs and Rs define an "interactive stopband measurement" which allows you to '
'ask questions such as, "if the stopband edge is at 50 Hz (for instance), '
'what is the attenuation Rs in the stopband?".  If you change either Fs or '
'Rs, the other measurement changes to reflect the stopband given the '
'parameter you entered.  You can also drag the stopband measurement line in '
'the main axes area, either up and down to change Rs, or back and forth to '
'change Fs.'
};

case {'sbm3:fdkaiser:set:3','sbm3:fdkaiser:set:4','sbm3:fdbutter:set:3','sbm3:fdbutter:set:4','sbm3:fdcheby1:set:3','sbm3:fdcheby1:set:4'}
str{1,1} = 'Rs';
str{1,2} = {
'Stopband Attenuation Rs (Interactive)'
' '
'This is the stopband attenuation Rs, in decibels.  Enter a number here and '
'Fs1 and Fs2 change to reflect how far the stopband extends given the new '
'attenuation that you have entered.'
' '
'Fs1, Fs2, and Rs define an "interactive stopband measurement" which allows '
'you to ask questions such as, "if the upper stopband edge is at 50 Hz (for '
'instance), what is the attenuation Rs in the stopband?".  If you change any of'
'Fs1, Fs2 or Rs, the other two measurements change to reflect the stopband '
'given the parameter you entered.  You can also drag the stopband measurement'
'line in the main axes area, either up and down to change Rs, or back and '
'forth to change Fs1 or Fs2.'
' '
' '
};

case 'ax'
str{1,1} = 'MAIN AXES';
str{1,2} = {
'Main Axes'
' '
'The main axes consists of a display of the current filter''s frequency '
'response, and other lines which are used to either manipulate or measure '
'the filter.  When moving the mouse over these lines, you will see the mouse '
'pointer change to indicate you can perform some action by clicking and '
'dragging the line, usually up and down or back and forth.'
' '
'GREEN LINES are specification lines, and dragging them causes the filter'
'to be redesigned.  If "AutoDesign" is checked, the filter will redesign'
'as you drag the mouse - this is recommended only for the fastest machines.'
'If "AutoDesign" is not checked, the filter will be designed when you'
'release the mouse button (after you are done dragging the line to its'
'desired location).  The Filter Designer will do its best to meet the '
'specifications, but in the case of REMEZ and KAISER, the response will'
'sometimes exceed the green lines.'
' '
'RED LINES are measurement lines, and dragging them does not cause the'
'filter to be redesigned.  As you drag these lines, some measurements on'
'the right will change to reflect the changed position of the line.'
' '
'You can also drag the FREQUENCY RESPONSE LINE.  In this case, when you'
'are zoomed-in, dragging this line allows you to see other parts of the'
'response which are off the screen.  When you release the mouse button, the'
'only thing that changes are the axes limits.'
' '
'To get help on a line (to see what it represents and how to drag it), click the '
'help button and then click on the line.'
' '
};

case 'response'
str{1,1} = 'Response';
str{1,2} = {
'Frequency Response'
' '
'This line plots the magnitude of the filter''s frequency response, in '
'decibels (20*log10(magnitude)). '
' '
'When you are zoomed-in, dragging this line allows you to see other parts of '
'the response which are off the screen.  When you release the mouse button, '
'the only thing that changes are the axes limits.'
' '
'The resolution of this line is controlled by the Nfft parameter, which you '
'can change under the "Filter Designer" category of the Preferences option '
'of the SPTool.  The line plots the magnitude at Nfft evenly spaced '
'frequencies between 0 and Fsamp/2.'
' '
};

case 'overlayline'
str{1,1} = 'Overlaid Spectrum';
str{1,2} = {
'Overlaid Spectrum Plot'
' '
'This line corresponds to a spectrum plot.  To change or remove this line,'
'click the "Overlay Spectrum" button.'
' '
'This feature is useful if you would like to design a filter to'
'pass or stop a certain range of frequencies designated by the'
'frequency content of a signal.'
' '
'The spectrum and filter may have different sampling frequencies, in which '
'case the spectrum''s frequency extent will not match the filter''s.'
' '
};

case {'passband:min','passband:fdcheby1:set','passband:fdellip:set'}
str{1,1} = 'Passband Line';
str{1,2} = {
'Passband Specifications Line'
' '
'This line consists of upper and lower horizontal segments which denote the '
'maximum and minimum desired values for the frequency response across the '
'passband.'
' '
'As you move the mouse over these line segments, the cursor changes to '
'indicate that you can drag the line, either back and forth, or up and down, '
'depending on if you are over the end of a line segment, or over the center '
'of the line segment.  '
' '
'BACK AND FORTH DRAGGING'
'When the cursor indicates two arrows facing left and right, you can click '
'and drag the band edge back and forth.  As you do so, the line follows the '
'mouse and the associated frequency changes under "Specifications".  When '
'you let go of the mouse button, the filter is redesigned.'
' '
'UP AND DOWN DRAGGING'
'When the cursor indicates two arrows facing up and down, you can click and '
'drag the passband ripple up and down.  As you do so, the line follows the '
'mouse and Rp, the desired passband ripple, changes under "Specifications".  '
'When you let go of the mouse button, the filter is redesigned.'
' '
'Note that if "AutoDesign" is clicked, the filter will redesign every time '
'you move the mouse during a drag operation.'
' '
};

case {'stopband:min','stopband:fdcheby2:set','stopband:fdellip:set'}
str{1,1} = 'Stopband Line';
str{1,2} = {
'Stopband Specifications Line'
' '
'This line denotes the maximum desired value for the frequency response '
'across the stopband.'
' '
'As you move the mouse over this line, the cursor changes to indicate that '
'you can drag the line, either back and forth, or up and down, depending on '
'if you are over the end of the line, or over the center of the line.'
' '
'BACK AND FORTH DRAGGING'
'When the cursor indicates two arrows facing left and right, you can click '
'and drag the band edge back and forth.  As you do so, the line follows the '
'mouse and the associated frequency changes under "Specifications".  When '
'you let go of the mouse button, the filter is redesigned.'
' '
'UP AND DOWN DRAGGING'
'When the cursor indicates two arrows facing up and down, you can click and '
'drag the stopband ripple up and down.  As you do so, the line follows the '
'mouse and Rs, the desired stopband attenuation, changes under '
'"Specifications".  When you let go of the mouse button, the filter is '
'redesigned.'
' '
'Note that if "AutoDesign" is clicked, the filter will redesign every time '
'you move the mouse during a drag operation.'
' '
' '
};

case {'passband:fdremez:set','passband:fdfirls:set'}
str{1,1} = 'Passband Line';
str{1,2} = {
'Passband Specifications Line'
' '
'This line shows the maximum and minimum ACTUAL values for the frequency '
'response across the passband.'
' '
'BACK AND FORTH DRAGGING'
'Drag the bandedges back and forth to change the passband specifications '
'frequencies.  You may notice that as you change band edges, the amount of '
'ripple changes since for a fixed filter order, smaller transition band '
'width means a larger error across the pass and stopbands.'
' '
'UP AND DOWN DRAGGING'
'Dragging up and down in this non-minimum order mode sets the passband AND '
'stopband weights to approximately obtain the amount of ripple Rp to that of '
'the line you are dragging.'
' '
'You can also change the passband and stopband weights by entering a '
'positive real number in the Weight field under Passband or Stopband '
'Specifications.'
};

case {'stopband:fdremez:set','stopband:fdfirls:set'}
str{1,1} = 'Stopband Line';
str{1,2} = {
'Stopband Specifications Line'
' '
'This line shows the maximum ACTUAL values for the frequency '
'response across the stopband.'
' '
'BACK AND FORTH DRAGGING'
'Drag the bandedges back and forth to change the stopband specifications '
'frequencies.  You may notice that as you change band edges, the amount of '
'ripple changes since for a fixed filter order, smaller transition band '
'width means a larger error across the pass and stopbands.'
' '
'UP AND DOWN DRAGGING'
'Dragging up and down in this non-minimum order mode sets the passband AND '
'stopband weights to approximately obtain the amount of attenuation Rs to '
'that of the line you are dragging.'
' '
'You can also change the passband and stopband weights by entering a '
'positive real number in the Weight field under Passband or Stopband '
'Specifications.'
};

case {'passband:fdkaiser:set','passband:fdbutter:set','passband:fdcheby2:set'}
str{1,1} = 'Passband Line';
str{1,2} = {
'Passband Measurement Line (Interactive)'
' '
'Drag this Measurement line to make interactive measurements of the current '
'filter''s passband response.  '
' '
'As you drag an edge left or right, the passband ripple Rp under "Passband" '
'measurements on the right of the window changes to reflect how much ripple '
'there is across the passband given the new band edge.'
' '
'As you drag the line up and down to set Rp, the frequency band edge Fp (or '
'edges Fp1 and Fp2 for bandpass and bandstop filters) changes to reflect how '
'wide the passband would have to be to achieve the desired Rp.'
' '
'You can also enter Rp and Fp (or Fp1 and Fp2 for bandpass and bandstop '
'filters) directly in the passband measurements area.'
' '
};

case {'stopband:fdkaiser:set','stopband:fdbutter:set','stopband:fdcheby1:set'}
str{1,1} = 'Stopband Line';
str{1,2} = {
'Stopband Measurement Line (Interactive)'
' '
'Drag this Measurement line to make interactive measurements of the current '
'filter''s stopband response.'
' '
'As you drag an edge left or right, the stopband attenuation Rs under '
'"Stopband" measurements on the right of the window changes to reflect how '
'much attenuation there is across the stopband given the new band edge.'
' '
'As you drag the line up and down to set Rs, the frequency band edge Fs (or '
'edges Fs1 and Fs2 for bandpass and bandstop filters) changes to reflect how '
'wide the stopband would have to be to achieve the desired Rs.'
' '
'You can also enter Rs and Fs (or Fs1 and Fs2 for bandpass and bandstop '
'filters) directly in the stopband measurements area.'
' '
};

case 'L3_1:fdkaiser:one'
str{1,1} = 'Fc Line';
str{1,2} = {
'Fc Line'
' '
'Drag this line back and forth to change Fc, the filter''s cut-off frequency.'
};

case 'L3_1:fdkaiser:two'
str{1,1} = 'Fc1 Line';
str{1,2} = {
'Fc1 Line'
' '
'Drag this line back and forth to change Fc1, the filter''s lower cut-off '
'frequency.'
' '
};

case 'L3_2:fdkaiser:two'
str{1,1} = 'Fc2 Line';
str{1,2} = {
'Fc2 Line'
' '
'Drag this line back and forth to change Fc2, the filter''s upper cut-off '
'frequency.'
};

case 'L3_1:fdbutter:one'
str{1,1} = 'F3db Line';
str{1,2} = {
'F3db Line'
' '
'Drag this line back and forth to change F3db, the filter''s 3dB frequency.'
};

case 'L3_1:fdbutter:two'
str{1,1} = 'F3db1 Line';
str{1,2} = {
'F3db1 Line'
' '
'Drag this line back and forth to change F3db1, the filter''s lower 3dB '
'frequency.'
' '
};

case 'L3_2:fdbutter:two'
str{1,1} = 'F3db2 Line';
str{1,2} = {
'F3db2 Line'
' '
'Drag this line back and forth to change F3db2, the filter''s upper 3dB '
'frequency.'
' '
};

case {'L3_1:fdcheby1:one','L3_1:fdellip:one'}
str{1,1} = 'Fp Line';
str{1,2} = {
'Fp Line'
' '
'Drag this line back and forth to change Fp, the filter''s passband edge '
'frequency.'
};

case {'L3_1:fdcheby1:two','L3_1:fdellip:two'}
str{1,1} = 'Fp1 Line';
str{1,2} = {
'Fp1 Line'
' '
'Drag this line back and forth to change Fp1, the filter''s lower passband '
'edge frequency.'
' '
};

case {'L3_2:fdcheby1:two','L3_2:fdellip:two'}
str{1,1} = 'Fp2 Line';
str{1,2} = {
'Fp2 Line'
' '
'Drag this line back and forth to change Fp2, the filter''s upper passband '
'edge frequency.'
' '
};

case 'L3_1:fdcheby2:one'
str{1,1} = 'Fs Line';
str{1,2} = {
'Fs Line'
' '
'Drag this line back and forth to change Fs, the filter''s stopband edge '
'frequency.'
};

case 'L3_1:fdcheby2:two'
str{1,1} = 'Fs1 Line';
str{1,2} = {
'Fs1 Line'
' '
'Drag this line back and forth to change Fs1, the filter''s lower stopband '
'edge frequency.'
' '
};

case 'L3_2:fdcheby2:two'
str{1,1} = 'Fs2 Line';
str{1,2} = {
'Fs2 Line'
' '
'Drag this line back and forth to change Fs2, the filter''s upper stopband '
'edge frequency.'
' '
};

case 'c1'
str{1,1} = 'X/Mag';
str{1,2} = {
'X or Mag coordinate'
' '
'Depending on whether the Coordinate Selector is ''Rectangular'' or ''Polar'', '
'this is the X- or Mag-coordinate respectively of the currently selected zero '
'or pole.  '
' '
'In rectangular coordinates, X is the real-part of the zero or pole.'
' '
'In polar coordinates, Mag is the magnitude or distance from the origin of the '
'zero or pole.'
' '
'Type in a value for this number to change it, or click and drag the '
'selected zero or pole.'
};

case 'c2'
str{1,1} = 'Y/Angle';
str{1,2} = {
'Y or Angle coordinate'
' '
'Depending on whether the Coordinate Selector is ''Rectangular'' or ''Polar'', '
'this is the Y- or Angle-coordinate respectively of the currently selected zero '
'or pole.  '
' '
'In rectangular coordinates, Y is the imaginary-part of the zero or pole.'
' '
'In polar coordinates, Angle is the angle relative to the positive X-axis,'
'in radians, of the zero or pole.'
' '
'Type in a value for this number to change it, or click and drag the '
'selected zero or pole.'
};

case 'cpop'
str{1,1} = 'Rect/Polar';
str{1,2} = {
'Rectangular / Polar Coordinate Selector'
' '
'Select from this popup-menu to view the coordinates of the currently '
'selected zero or pole in either Rectangular or Polar form.'
' '
'RECTANGULAR'
'  Coordinates are X (real-part) and Y (imaginary-part) of the selected zero '
'  or pole.'
'  '
'POLAR   '
'  Coordinates are Mag (magnitude or distance from the origin) and Angle (angle '
'  relative to the positive X-axis, in radians) of the selected zero or '
'  pole.'
' '
};

case 'conjpairCheckBox'
str{1,1} = 'Conj. Pair';
str{1,2} = {
'Conjugate Pair Checkbox'
' '
'If this checkbox is checked, then the current selection is a conjugate pair '
'of two zeros (o) or poles (x).  If this checkbox is NOT checked, then the '
'current selection is a single zero (o) or pole (x).'
' '
'When you move or change a zero or pole and this box is checked, the '
'conjugate of the root you are moving also moves.'
' '
'UNCHECK THIS BOX...'
'...to ungroup the conjugate pair, leaving both zeros (or poles) in the '
'filter but allowing you to now treat them as separate entities.  Doing so '
'leaves the filter unchanged.'
' '
'CHECK THIS BOX...'
'...to add a new zero or pole to the filter at the conjugate of the '
'currently selected zero or pole.  Note that if there already exists'
'a zero or pole at the exact conjugate location, then that zero or '
'pole will be grouped with the selected one.  Hence checking this box '
'usually changes the filter (by adding a zero or pole) but sometimes will'
'not.'
' '
};

case 'sendToBack'
str{1,1} = 'SEND BACK';
str{1,2} = {
'Send To Back Button'
' '
'Sometimes you might have two or more poles and zeros on top of each other.  '
'If one of them is selected, it is impossible to select the other with the '
'mouse.  When this happens, hit this button and you will be able to click on '
'the pole that is underneath to select it.'
};

case 'cleanslate'
str{1,1} = 'DELETE ALL';
str{1,2} = {
'Delete All Button'
' '
'Hit this button to remove ALL of the poles and zeros of the current filter.'
'Use this button with caution, since you can''t undo this operation!'
'The resulting "trivial filter" is simply a gain given by the Gain '
'edit box, i.e.'
'     B(z)/A(z) = g'
};

case 'defMode'
str{1,1} = 'DRAG MODE';
str{1,2} = {
'Drag Poles / Zeros'
' '
'Hit this button to go into "Drag" or "Select" mode.'
'In this mode, you can click on a pole or zero to select'
'it (and its conjugate if it has one).  You can also'
'move poles and zeros by dragging them.'
};

case 'newz'
str{1,1} = 'ADD ZERO';
str{1,2} = {
'Add Zero Mode'
' '
'Hit this button to go into "Add Zero" mode.'
' '
'In this mode, when you click in the main axes area, '
'a zero (or pair of zeros) is added to the filter.  If the '
'Conjugate Pair checkbox is checked, a pair of zeros will '
'be added; if not, a single zero will be added.  '
' '
'When adding a zero, a coordinate readout appears on '
'the right in the "Measurements" area so you can place '
'the zero precisely.'
' '
'Once you have added the zero, it will be "selected" '
'(appearing slightly larger and in a different color '
'than the other zeros).  You can move the new zero by dragging '
'it with the mouse, or typing in new values for its '
'coordinates.'
' '
'ADDING MULTIPLE ZEROS'
'After adding a zero, normally you go back to "Drag" or'
'"Select" mode.  To stay in "Add Zero" mode and add'
'more zeros, click with the right mouse button (or'
'hold the shift or control key while clicking).'
' '
};

case 'newp'
str{1,1} = 'ADD POLE';
str{1,2} = {
'Add Pole Mode'
' '
'Hit this button to go into "Add Pole" mode.'
' '
'In this mode, when you click in the main axes area, '
'a pole (or pair of poles) is added to the filter.  If the '
'Conjugate Pair checkbox is checked, a pair of poles will '
'be added; if not, a single pole will be added.'
' '
'When adding a pole, a coordinate readout appears on '
'the right in the "Measurements" area so you can place '
'the pole precisely.'
' '
'Once you have added the pole, it will be "selected" '
'(appearing slightly larger and in a different color '
'than the other poles).  You can move the new pole by dragging '
'it with the mouse, or typing in new values for its '
'coordinates.'
' '
'ADDING MULTIPLE POLES'
'After adding a pole, normally you go back to "Drag" or'
'"Select" mode.  To stay in "Add Pole" mode and add'
'more poles, click with the right mouse button (or'
'hold the shift or control key while clicking).'
' '
};

case 'eraseMode'
str{1,1} = 'ERASE MODE';
str{1,2} = {
'Erase Poles / Zeros'
' '
'Hit this button to go into "Erase" mode.'
' '
'When in Erase mode, you can delete any pole or zero by'
'simply clicking on it.  Click on the root with the upper'
'left corner of the eraser pointer (where the eraser comes to'
'a point).  '
' '
'Note that if a pole or zero has a conjugate pole or zero,'
'both the root AND ITS CONJUGATE will be removed.'
' '
'ERASING MULTIPLE ROOTS'
'After deleting a root, normally you go back to "Drag" or'
'"Select" mode.  To stay in "Erase" mode and erase'
'more roots, click with the right mouse button (or'
'hold the shift or control key while clicking).'
};

case 'Gain'
str{1,1} = 'GAIN';
str{1,2} = {
'Filter Gain'
' '
'This scalar quantity is the filter''s ''gain''.  It may be complex.  '
' '
'Changing this value will not change any of the filter''s zero or pole '
'positions.'
};

case 'Lz'
str{1,1} = 'ZERO';
str{1,2} = {
'Zero of Filter'
' '
'You have clicked on a zero of the filter.'
' '
'SELECTION'
'To "select" this zero, click on it and it will appear slightly larger, '
'thicker, and in a different color than the other zeros.  Also, its exact '
'coordinates will appear in the edit boxes on the left of the window.'
' '
'PLACEMENT'
'To move this zero, drag it with the mouse.  (You must be in'
'"Drag" or "Select" mode to do this).  As you do so, the coordinates '
'will be shown on the left.  Also, if the Filter Viewer is open, the Filter '
'Viewer plots will update automatically as you drag the zero.'
' '
'CONSTRAINED PLACEMENT'
'To change only one of this zero''s coordinates and hold the other one fixed, '
'hold the shift key down and click and drag the zero in the direction of the '
'coordinate you would like to change.  This works in both Rectangular and '
'Polar coordinate modes.'
' '
'MULTIPLE ZEROS'
'If there are zeros at the same location, the number of zeros at that '
'location is indicated by a number to the right of the zeros.  The '
'multiplicity indicator appears to the left of poles.'
};

case 'Lp'
str{1,1} = 'POLE';
str{1,2} = {
'Pole of Filter'
' '
'You have clicked on a pole of the filter.'
' '
'SELECTION'
'To "select" this pole, click on it and it will appear slightly larger, '
'thicker, and in a different color than the other poles.  Also, its exact '
'coordinates will appear in the edit boxes on the left of the window.'
' '
'PLACEMENT'
'To move this pole, drag it with the mouse.  (You must be in'
'"Drag" or "Select" mode to do this).  As you do so, the coordinates '
'will be shown on the left.  Also, if the Filter Viewer is open, the Filter '
'Viewer plots will update automatically as you drag the pole.'
' '
'CONSTRAINED PLACEMENT'
'To change only one of this pole''s coordinates and hold the other one fixed, '
'hold the shift key down and click and drag the pole in the direction of the '
'coordinate you would like to change.  This works in both Rectangular and '
'Polar coordinate modes.'
' '
'MULTIPLE POLES'
'If there are poles at the same location, the number of poles at that '
'location is indicated by a number to the left of the poles.  The '
'multiplicity indicator appears to the right of zeros.'
};

case 'unitCircle'
str{1,1} = 'UNIT CIRCLE';
str{1,2} = {
'Unit Circle'
' '
'This is the circle of magnitude 1 on the Z-plane.  It is drawn here for '
'you to reference so you can easily tell which poles and zeros are inside, '
'on, and outside the unit circle. '
};

case 'pzax'
str{1,1} = 'Z-PLANE';
str{1,2} = {
'Z-plane'
' '
'This axis represents the Z-plane.  Poles of the filter are represented'
'by ''x''s and zeros of the filter are represented by ''o''s.  The unit circle'
'is drawn here for reference.'
};

case 'numZeros'
str{1,1} = 'NUM. ZEROS';
str{1,2} = {
'Number of Zeros'
' '
'This is the number of zeros, or the numerator order, of the filter.'
};

case 'numPoles'
str{1,1} = 'NUM. POLES';
str{1,2} = {
'Number of Poles'
' '
'This is the number of poles, or the denominator order, of the filter.'
};

case 'stabflag'
str{1,1} = 'STABILITY';
str{1,2} = {
'Stability Indicator'
' '
'If this filter has any poles outside or on the unit circle, the filter '
'is unstable and this indicator appears in red.  If all the poles are inside '
'the unit circle, the filter is considered stable.'
' '
'Minimum / Maximum Phase Indicator'
' '
'If this filter has all of its zeros as well as poles on or inside the '
'unit  circle, the filter is "Minimum Phase".  If all the zeros and'
'poles are strictly inside the unit circle, the filter is "Strictly'
'Minimum Phase".'
' '
'If the filter has all of its zeros and poles on or OUTSIDE the '
'unit circle, it is "Maximum Phase".  If all the zeros and'
'poles are strictly outside the unit circle, the filter is "Strictly'
'Maximum Phase".'
' '
};

case 'phaseflag'
str{1,1} = 'PHASE';
str{1,2} = {
'Minimum / Maximum Phase Indicator'
' '
'If this filter has all of its zeros as well as poles on or inside the '
'unit  circle, the filter is "Minimum Phase".  If all the zeros and'
'poles are strictly inside the unit circle, the filter is "Strictly'
'Minimum Phase".'
' '
'If the filter has all of its zeros and poles on or OUTSIDE the '
'unit circle, it is "Maximum Phase".  If all the zeros and'
'poles are strictly outside the unit circle, the filter is "Strictly'
'Maximum Phase".'
' '
};


otherwise
    if nargin<3
        return
    end
    
    % if given handle has a userdata structure with a .help field, assume
    % this is an fdspec, fdax, fdmeas, or fdline and return the contents of that
    % field, then call the function
    % if, however, .help field is not a cell array but just a string, use
    % the string as a helpstr function, i.e., str = feval(obj.help,module,tag,fig,h)
    objud = get(h,'userdata');
    if ishandle(objud)  % is this a label of a spec or meas?
        objud = get(objud,'userdata');  % trace to original spec or meas if so
    end
    if isstruct(objud) & isfield(objud,'help')
        if iscell(objud.help)
            str{1,1} = 'Filtdes Object Help';
            str{1,2} = objud.help;
        elseif isempty(objud.help)
            str{1,1} = 'Filtdes Object Help';
            str{1,2} = sprintf('No help for this %s object',get(h,'type'));
        else
            ud = get(fig,'userdata');
            str = feval(objud.help,ud.currentModule,tag,fig,h);
            if ~isempty(ud.defaultModeObject)
                ud.defaultModeObject.value = 1;
            end
        end
        return
    end
    
    ud = get(fig,'userdata');
    switch h
    case {ud.ht.modulePopup,ud.ht.moduleLabel}
        moduleStr = cell(length(ud.modules)+1,1);
        moduleStr{1} = sprintf( ... 
             '%16s     %s','FUNCTION','DESCRIPTION');
        popStr = get(ud.ht.modulePopup,'string');
        for i = 1:length(ud.modules)
            moduleStr{i+1} = sprintf( ...
             '%16s   %s',ud.modules{i},popStr{i});
        end
        
        str{1,1} = 'Module Selection';
        str{1,2} = { 
'This popup-menu decides the type of filter (FIR or IIR) and the error'
'minimization scheme employed to design the filter, as well as'
'other characteristics specific to each filter type.'
 ' '
 'The currently available design algorithms are:'};
        str{1,2} = {str{1,2}{:}, moduleStr{:}}';
        str{1,2}{end+1} = ' ';
        str{1,2}{end+1} = ...
 'To get a description of one of these methods, select it under ''Topics''.';
        str{1,2}{end+1} = ' ';
        str{1,2}{end+1} = ...
 'For more detailed information, see the Reference section of the User''s Manual.';
        for i = 1:length(ud.modules)
            str{1+i,1} = ud.modules{i};
            str{1+i,2} = feval(ud.modules{i},'help');
        end    
    end
    
end

if nargin < 2
    fig = gcbf;
end
ud = get(fig,'userdata');
if ~isempty(ud.defaultModeObject)
    ud.defaultModeObject.value = 1;
end
