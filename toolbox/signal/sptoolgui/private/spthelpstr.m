function str = spthelpstr(tag,fig)
%SPTHELPSTR  Display Help for SPTOOL

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.10 $

    str{1,1} = 'SPTool';
    str{1,2} = {['No help for this object (' tag ')']};

% ****                       WARNING!                       ****
% ****                                                      ****
% ****  All help text between the SWITCH TAG and OTHERWISE  ****
% ****  statements is automatically generated.  To change   ****
% ****  the help text, edit SPTHELP.H and use HWHELPER to   ****
% ****  insert the changes into this file.                  ****

switch tag
case 'list1'
str{1,1} = 'SIGNALS';
str{1,2} = {
' '
'This list box itemizes the session signals.'
' '
'Click on an unselected signal to select that signal alone.  To add or '
'remove a single signal to or from the selection, Control click (Command '
'click on the Mac) on that signal.   To add or remove a range of signals to '
'the selection, Shift click.'
' '
'Click the "View" button to open the Signal Browser for graphical analysis '
'of your signal data.'
};

str{2,1} = 'SIGNAL TYPES';
str{2,2} = {
'The signal type is either [vector] or [array].  This simply distinguishes '
'whether the signal has one column or more than one column.'
};

case 'list2'
str{1,1} = 'FILTERS';
str{1,2} = {
'This list box itemizes the session filters.'
' '
'Click on a selected filter to select that filter. The Filter Visualization Tool '
'and The Filter Designer both focus on the selected filters if they are open.  '
' '
'To analyze a filter (frequency response, phase, group delay, zeros and '
'poles, impulse and step responses), click the ''View'' button.'
' '
'To create a new filter, either select ''Import...'' from the file menu, or '
'hit the ''New Design'' button.  Press the ''Edit Design'' button to open the '
'Filter Designer focused on the current filter.'
' '
'For help about the different types of filters ([imported] and [design]),'
'select ''FILTER TYPES'' under ''Topics''.'
};

str{2,1} = 'FILTER TYPES';
str{2,2} = {
'The filter type is either [imported] or [design].  '
' '
'[imported]  This is a filter that has been imported from the MATLAB '
'workspace or a file, or is edited by the Pole/Zero Editor in the Filter '
'Designer. '
' '
'[design]  In the Filter Designer, this filter has some other Algorithm '
'besides ''Pole/Zero Editor'', such as ''Equiripple FIR''.  When you click ''New '
'Design'', the filter that is created starts out as type [design].'
};

case 'list3'
str{1,1} = 'SPECTRA';
str{1,2} = {
' '
'This list box itemizes the session spectra.'
' '
'Click on an unselected spectrum to select that spectrum alone.  To add or '
'remove a single spectrum to or from the selection, Control click (Command '
'click on the Mac) on that spectrum.   To add or remove a range of spectra '
'to the selection, Shift click.'
};

str{2,1} = 'SPECTRUM TYPES';
str{2,2} = {
'There is only one type of spectrum: [auto].  This is in reference to the '
'source for the spectrum being only one signal, making it the auto-spectrum '
'(as opposed to the cross-spectrum of two channels of data).'
};

case 'sigbrowse:view'
str{1,1} = 'VIEW SIGNALS';
str{1,2} = {
' '
'This button activates the Signal Browser.'
};

case 'filtview:view'
str{1,1} = 'VIEW FILTER';
str{1,2} = {
' '
'This button launches the Filter Visualization Tool.'
};

case 'filtdes:create'
str{1,1} = 'NEW DESIGN';
str{1,2} = {
' '
'This button creates a new filter and activates the Filter Designer.'
' '
};

case 'filtdes:change'
str{1,1} = 'EDIT DESIGN';
str{1,2} = {
' '
'This button activates the Filter Designer to edit the currently selected '
'filter.'
};

case 'applyfilt:apply'
str{1,1} = 'APPLY FILTER';
str{1,2} = {
' '
'This button applies the selected filter to the selected signal to create a '
'new signal.  A dialog box appears where you can select the filtering '
'algorithm and type in the name for the new signal.'
};

case 'spectview:view'
str{1,1} = 'VIEW SPECTRA';
str{1,2} = {
' '
'This button activates the Spectrum Viewer.'
};

case 'spectview:create'
str{1,1} = 'CREATE SPECTRUM';
str{1,2} = {
' '
'This button creates a new Spectrum and activates the Spectrum Viewer.  '
'Once in the Spectrum Viewer, hit the "Apply" button to compute the '
'spectrum when you are satisfied with the parameters for the spectrum.'
' '
'This button is enabled when exactly one signal is selected.'
};

case 'spectview:update'
str{1,1} = 'UPDATE SPECTRUM';
str{1,2} = {
' '
'This button updates the selected spectrum''s signal to the currently '
'selected signal.   The spectrum''s spectral data is removed and the '
'Spectrum Viewer is activated, so that you need to hit "Apply" in the '
'Spectrum Viewer to complete the update.'
};

case 'filemenu'
str{1,1} = 'FILE';
str{1,2} = {
' '
'Data management choices.'
};

case 'loadmenu'
str{1,1} = 'LOAD';
str{1,2} = {
' '
'Loads a session file with the extension ".spt".'
};

case 'importmenu'
str{1,1} = 'IMPORT';
str{1,2} = {
'Imports a signal, filter, or spectrum from the workspace or a file.'
};

case 'exportmenu'
str{1,1} = 'EXPORT';
str{1,2} = {
' '
'Exports signal(s), filter(s), and/or spectra to the MATLAB workspace as '
'structure variables.'
};

case 'savemenu'
str{1,1} = 'SAVE MENU';
str{1,2} = {
' '
'Saves the current session, overwriting the existing session file.'
};

case 'saveasmenu'
str{1,1} = 'SAVE AS';
str{1,2} = {
' '
'Saves the current session by a name you specify.'
};

case 'prefmenu'
str{1,1} = 'PREFERENCES';
str{1,2} = {
' '
'Allows you to specify your preferences for the behavior of all the Signal '
'Processing GUI tools.'
};

case 'closemenu'
str{1,1} = 'CLOSE';
str{1,2} = {
' '
'Closes SPTool and all other Signal Processing tools.  SPTool will prompt '
'you if you have not saved the current session.'
};

case 'editmenu'
str{1,1} = 'EDIT';
str{1,2} = {
' '
'Change various characteristics of the selected objects.'
};

case 'dupemenu'
str{1,1} = 'DUPLICATE';
str{1,2} = {
' '
'Duplicates selected object. The new object appears at the bottom of the '
'list and becomes the selected object. Its name has copy appended to the '
'name of the copied object (or copy1, copy2,...) so that the new name is '
'unique.'
};

case 'clearmenu'
str{1,1} = 'CLEAR';
str{1,2} = {
' '
'Removes the selected object from the list of objects.'
};

case 'newnamemenu'
str{1,1} = 'EDIT NAME';
str{1,2} = {
' '
'Allows you to give the selected object a new name of your choice.  The new '
'name must be unique among all objects in the SPTool.'
};

case 'freqmenu'
str{1,1} = 'EDIT Fs';
str{1,2} = {
' '
'Allows you to supply a sampling frequency for the selected signal or '
'filter.'
' '
'Sampling frequency examples are numbers, such as 1, .001, 1/5000, or '
'expressions using a MATLAB workspace variable, such as 1/Fs, Ts, or '
'function.'
};

case 'helpmenu'
str{1,1} = 'HELP MENU';
str{1,2} = {
' '
'Gives help for the controls in SPTool'
};

case 'helpmouse'
str{1,1} = 'MOUSE HELP';
str{1,2} = {
' '
'Context sensitive help on a specific control in SPTool.'
' '
'To get help at any time, select "What''s This" under the Help menu.  '
'The mouse pointer becomes an  arrow with a question mark symbol.  '
'You can then click on anything in the SPTool (or select a menu) to find '
'out what it is and how to use it.'
};

case 'winmenu'
str{1,1} = 'EDIT MENU';
str{1,2} = {
' '
'Displays all open windows. Selecting a particular item makes the '
'corresponding figure current.'
};

case {'overview','helpoverview'}
str{1,1} = 'OVERVIEW';
str{1,2} = {
' '
'General Help for SPTool '
' '
'SPTool is the data management tool central to all of the Signal Processing '
'GUI Tools.'
' '
'Using SPTool you can:'
' o Load a new Session.'
' o Import a signal, filter, or spectrum.'
' o Save Sessions.'
' o Activate the Signal Browser, Filter Viewer or Designer, or the'
'   Spectrum Viewer.'
' o Duplicate or clear a signal, filter, or spectrum.'
' o Change the name of any of these objects.'
' o Change the Sampling Frequency of signals and filters.'
' o Use the Window menu to change the current figure to any open figure.'
' '
'For help on a specific control, choose the Context Sensitive menu item off '
'the Help menu.  The mouse pointer becomes an arrow with a question mark '
'symbol.  You can then click on anything in the SPTool, including selecting '
'menu items, to find out what it is and how to use it.'
};

str{2,1} = 'GETTING STARTED';
str{2,2} = {
' '
'To get started, pick "Import..." from the File menu.'
' '
'Inside the import window, click on From Disk, then enter the file name '
'"mtlb.mat" and hit enter.  Click on mtlb in the File Contents list, and '
'the arrow left of the Data field.  Click on Fs in the File Contents list '
'and the arrow left of the Sampling Freq. field.  Then click the "OK" '
'button.  You have successfully imported a signal named "sig1" into the '
'SPTool.  From there, click the "View" button under Signals to look at this '
'signal in the Signal Browser.'
' '
'By clicking "Create" under Spectra you can look at the frequency content '
'of the signal in the Spectrum Viewer.  Once the Spectrum Viewer is open, '
'hit the "Apply" button to compute the spectrum.'
' '
};


otherwise
str{1,1} = 'SPTOOL';
str{1,2} = {
['Object with tag ' tag '.']
};

end
