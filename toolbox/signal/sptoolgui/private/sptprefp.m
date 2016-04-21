function p = sptprefp
% SPTPREFP  SPTool Preference Registry - Private directory.
% To register alternative preferences for the sptool, create
% a function named 'sptpref' which will be on the path, which
% takes and returns a preference structure array (where the
% structure fields are defined as in this function).

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.17 $

% Author: T. Krauss

%   Rulers  ---------------------------------------------------------------
rulerPrefs.panelName = 'ruler';
rulerPrefs.panelDescription = sprintf('Markers');
rulerPrefs.clientList = {'sigbrowse' 'spectview'};
rulerPrefs.panelHelp = {
 'These preferences apply to all clients that use markers, namely'
 'the Signal Browser, the Spectrum Viewer and the Filter Viewer.'
 };
 
% controls cell array.  Columns are:
%  Name  Description  type  radiogroup  number_of_lines popup_string ...
%      factory_value  help_string
c = get(0,'defaultaxescolor');
if isstr(c)  % might be 'none'
    c = get(0,'defaultfigurecolor');
end
if c*[1 1 1]' > 1.5  %  light background
    factoryRulerColor = '[1 0 1]';
else  % dark background
    factoryRulerColor = '[1 0 0]';
end
rulerPrefs.controls = {
  'rulerColor' 'Marker Color' 'edit' '' 1 ...
       {} ...
       factoryRulerColor ...
       {'This is the color used for the markers.'
        'The color can be an rgb triple, e.g. [1 0 1], or any of the'
        'following color specs:'
        '       ''y''     yellow'   
        '       ''m''     magenta ' 
        '       ''c''     cyan '    
        '       ''r''     red '     
        '       ''g''     green  '  
        '       ''b''     blue '    
        '       ''w''     white '   
        '       ''k''     black  '  
       }
  'rulerMarker' 'Marker Style' 'popupmenu' '' 1 ...
       { '+' 'o' '*' '.' 'x' ...
         'square' 'diamond' 'v' '^' '>' '<' 'pentagram' 'hexagram'}' ...
       2 ...
       {'This is the markerstyle used for the markers in track and'
        'slope modes.  Here are the descriptions of the values:'
        '           +     plus  '              
        '           o     circle   '         
        '           *     star'
        '           .     point    '         
        '           x     x-mark '            
        '                 square'
        '                 diamond'
        '           v     triangle (down)'
         '          ^     triangle (up)'
        '           >     triangle (right)'
        '           <     triangle (left)'
        '                 pentagram '          
        '                 hexagram  '      
       }
  'markerSize' 'Marker Size' 'edit' '' 1 ...
       {} ...
       '8' ...
       {'This is the markersize used for the marker shape in track and slope'
        'modes.'
        }
  'initialType' 'Initial Type' 'popupmenu' '' 1 ...
       {'vertical' 'horizontal' 'track' 'slope'}' ...
       3 ...
       {'When a tool such as the Signal Browser or Spectrum Viewer is '
        'opened, this is the initial type for the markers.'}
};

rulerPrefs.currentValue = rulerPrefs.controls(:,7);


%   Colors ---------------------------------------------------------------
colorPrefs.panelName = 'color';
colorPrefs.panelDescription = 'Colors';
colorPrefs.clientList = {'sigbrowse' 'spectview'};
colorPrefs.panelHelp = {
 'These preferences apply to all windows that display multiple data sets'
 'simultaneously, namely the Signal Browser, the Spectrum Viewer and the'
 'Filter Viewer.'
 ' '
 'Colors and linestyles are assigned to new data according to'
 'these settings, starting from the time the tool is opened.'
 'If you close a tool and reopen it, it will start at the top of the'
 'color and linestyle orders.'
 };
% controls cell array.  Columns are:
%  Name  Description  type  radiogroup  number_of_lines popup_string ...
%      factory_value  help_string
colorPrefs.controls = {
  'colorOrder' 'Color Order' 'edit' '' 3 ...
      {} ...
      'get(0,''defaultaxescolororder'')' ...
      {'Enter in an expression here which defines the Line Color Order.'
       'The string you enter should evaluate to either' 
       '   - a color designation, such as ''r'','
       '   - a n-by-3 matrix of n colors, such as [1 0 1] or jet(16), or'
       '   - a cell array column of such objects, such as'
       '        {get(0,''defaultaxescolororder''); ''k''; [0 1 0]; jet(16)}'
      }
  'linestyleOrder' 'Line Style Order' 'edit' '' 3 ...
      {} ...
      'get(0,''defaultaxeslinestyleorder'')' ...
      {
      'The string you enter should evaluate to either'
      '   - a line style designation string, such as '':'', ''-'', ''--'', or ''-.'','
      '   - a string matrix of the above, or'
      '   - a cell array column of such objects, such as'
      '           {get(0,''defaultaxeslinestyleorder''); ''--''}'
       }
};

colorPrefs.currentValue = colorPrefs.controls(:,7);


%   Signal Browser --------------------------------------------------------
sigbrowsePrefs.panelName = 'sigbrowse';
sigbrowsePrefs.panelDescription = 'Signal Browser';
sigbrowsePrefs.clientList = {'sigbrowse'};
sigbrowsePrefs.panelHelp = {
 'These are the preferences for the Signal Browser.'
 };
% controls cell array.  Columns are:
%  Name  Description  type  radiogroup  number_of_lines popup_string ...
%      factory_value  help_string
sigbrowsePrefs.controls = {
  'xlabel' 'X Label' 'edit' '' 1 ...
      {} ...
      'Time' ...
      {'This is the string used to label the x-axes (usually Time) of the'
       'Signal Browser.'}
  'ylabel' 'Y Label' 'edit' '' 1 ...
      {} ...
      '' ...
      {'This is the string used to label the y-axes  of the Signal Browser.'}
  'rulerEnable' 'Markers' 'checkbox' '' 1 ...
      {} ...
      1 ...
      {'Check this box to use the Markers in the Signal Browser.'
       ' '
       'If this box is not checked, the Markers will be absent.'}
  'pannerEnable' 'Panner' 'checkbox' '' 1 ...
      {} ...
      1 ...
      {'Check this box to use the Panner in the Signal Browser.'
       ' '
       'If this box is not checked, the Panner will be absent.'}
  'zoomFlag' 'Stay in zoom mode after zoom' 'checkbox' '' 1 ...
      {} ...
      0 ...
      {'This checkbox determines whether you stay in zoom mode after'
       'the first zoom or not.  '
       ' '
       'If the checkbox is unchecked, when you click on the Mouse Zoom'
       'button in the Signal Browser, you zoom in one time (by clicking or'
       'clicking and dragging the mouse in the main axes area).'
       ' '
       'If the checkbox is checked, you can zoom repeatedly without having'
       'to click the Mouse Zoom button again.'}
};

sigbrowsePrefs.currentValue = sigbrowsePrefs.controls(:,7);


%   Spectrum Viewer --------------------------------------------------------
spectviewPrefs.panelName = 'spectview';
spectviewPrefs.panelDescription = 'Spectrum Viewer';
spectviewPrefs.clientList = {'spectview'};
spectviewPrefs.panelHelp = {
 'These are the preferences for the Spectrum Viewer.'
 };
% controls cell array.  Columns are:
%  Name  Description  type  radiogroup  number_of_lines popup_string ...
%      factory_value  help_string
spectviewPrefs.controls = {
  'magscale' 'Magnitude Axis Scaling' 'popupmenu' '' 1 ...
      {'decibels' 'linear'} ...
      1 ...
      {'Scaling of Magnitude (vertical) axis in the Spectrum Viewer.'
      ' '
      'In ''decibels'' mode, 10*log10 of the spectra is plotted.'
      ' '}
  'freqscale' 'Frequency Axis Scaling' 'popupmenu' '' 1 ...
      {'linear' 'log'} ...
      1 ...
      {'Scaling of Frequency (horizontal) axis in the Spectrum Viewer.'
      ' '
      'In log mode, the frequency axis range cannot be negative.'}
  'freqrange' 'Frequency Axis Range' 'popupmenu' '' 1 ...
      {'[0,Fs/2]' '[0,Fs]' '[-Fs/2,Fs/2]'} ...
      1 ...
      {'Range of Frequency (horizontal) axis in the Spectrum Viewer.'
      ' '
      'Fs is the sampling frequency.'
      ' '
      'The range cannot be negative if frequency axis scaling is ''log''.' }
  'rulerEnable' 'Markers' 'checkbox' '' 1 ...
      {} ...
      1 ...
      {'Check this box to use the Markers in the Spectrum Viewer.'
       ' '
       'If this box is not checked, the Markers will be absent.'}
  'zoomFlag' 'Stay in zoom mode after zoom' 'checkbox' '' 1 ...
      {} ...
      0 ...
      {'This checkbox determines whether you stay in zoom mode after'
       'the first zoom or not.  '
       ' '
       'If the checkbox is unchecked, when you click on the Mouse Zoom'
       'button in the Spectrum Viewer, you zoom in one time (by clicking or'
       'clicking and dragging the mouse in the main axes area).'
       ' '
       'If the checkbox is checked, you can zoom repeatedly without having'
       'to click the Mouse Zoom button again.'}
};

spectviewPrefs.currentValue = spectviewPrefs.controls(:,7);

%   Filter Designer --------------------------------------------------------
filtdesPrefs.panelName = 'filtdes';
filtdesPrefs.panelDescription = 'Filter Designer';
filtdesPrefs.clientList = {'filtdes'};
filtdesPrefs.panelHelp = {
 'These are the preferences for the Filter Designer.'
 };

% controls cell array.  Columns are:
%  Name  Description  type  radiogroup  number_of_lines popup_string ...
%      factory_value  help_string
filtdesPrefs.controls = {
  'nfft' 'FFT Length' 'edit' '' 1 ...
      {} ...
      '4096' ...
      {'Length of FFT used to compute frequency responses.  For efficiency'
      'it is best to use a power of 2.'}
  'grid' 'Display grid lines' 'checkbox' '' 1 ...
      {} ...
      1 ...
      {'Check this box to display horizontal and vertical grid lines'
       'on the Filter Designer plots.'}
  'AutoDesignInit' 'Auto Design' 'checkbox' '' 1 ...
      {} ...
      0 ...
      {'This specifies the value for Auto Design whenever the Filter'
       'Designer is first opened.' 
       ' '
       'When Auto Design is checked, every time you change a Specification'
       'and every time the mouse moves while dragging a Specification Line, the'
       'filter is designed.'
       ' '
       'When Auto Design is not checked, the filter is designed only when'
       'you press the ''Apply'' button, or when you release the mouse after'
       'dragging a Specification Line.'}
  'zoomFlag' 'Stay in zoom mode after zoom' 'checkbox' '' 1 ...
      {} ...
      0 ...
      {'This checkbox determines whether you stay in zoom mode after'
       'the first zoom or not.  '
       ' '
       'If the checkbox is unchecked, when you click on the Mouse Zoom'
       'button in the Filter Designer, you zoom in one time (by clicking or'
       'clicking and dragging the mouse in the main axes area).'
       ' '
       'If the checkbox is checked, you can zoom repeatedly without having'
       'to click the Mouse Zoom button again.'}
};
%   'gridflag' 'Snap to Grid when dragging bands.' 'checkbox' '' 1 ...
%       {} ...
%       1 ...
%       {'Check this box to snap to a grid when dragging bands or band edges.'}
%   'fgrid' 'Frequency Grid Spacing' 'edit' '' 1 ...
%       {} ...
%       '.001' ...
%       {'When dragging band edges, edges are constrained to multiples of this ' ...
%          'number.'}
%   'mgrid' 'Magnitude Grid Spacing' 'edit' '' 1 ...
%       {} ...
%       '.001' ...
%       {'When dragging bands up and down, values are constrained to multiples '...
%         ' of this number.'}

filtdesPrefs.currentValue = filtdesPrefs.controls(:,7);

%   Default Session File ---------------------------------------------------
defsesPrefs.panelName = 'defsession';
defsesPrefs.panelDescription = 'Default Session';
defsesPrefs.clientList = {};
defsesPrefs.panelHelp = {
 'Preferences for loading default session'
 ' '
 };

% controls cell array.  Columns are:
%  Name  Description  type  radiogroup  number_of_lines popup_string ...
%      factory_value  help_string
defsesPrefs.controls = {
  'defaultSession' 'Load default session file (startup.spt) when starting SPTool.' 'checkbox' '' 1 ...
      {} ...
      1 ...
      {'Checking this box automatically loads a default SPTool session when'
      'SPTool is launched.  The default file, startup.spt, is stored in the'
      '$MATLAB/toolbox/signal/ directory.'
       ' '
       'When the box is unchecked SPTool will not load a session upon starting;'
       'it will start with a clean session.'}
};

defsesPrefs.currentValue = defsesPrefs.controls(:,7);

%   Export Dialog Window ---------------------------------------------------
exportPrefs.panelName = 'export';
exportPrefs.panelDescription = 'Exporting Components';
exportPrefs.clientList = {};
exportPrefs.panelHelp = {
 'Preferences for exporting Components'
 ' '
 };

% controls cell array.  Columns are:
%  Name  Description  type  radiogroup  number_of_lines popup_string ...
%      factory_value  help_string
exportPrefs.controls = {
  'export' 'Export Filters as TF objects (to be used in Control Toolbox)' 'checkbox' '' 1 ...
      {} ...
      0 ...
      {'Checking this box will indicate that filters should be exported, to disk (MAT-file)'
       'or workspace, as TF objects (to be used by the Controls Toolbox).'
       ' '
       'When the box is unchecked SPTool will export filters as structures.'}
};

exportPrefs.currentValue = exportPrefs.controls(:,7);

%   Plug Ins --------------------------------------------------------
plugPrefs.panelName = 'plugins';
plugPrefs.panelDescription = 'plug-ins';
plugPrefs.clientList = {};
plugPrefs.panelHelp = {
 'It is possible to create add-on columns to the SPTool and new buttons'
 'underneath the columns.  Also, new spectral methods can be added to the'
 'Spectrum Viewer, and new preferences to the SPTool.'
 ' '
 'You won''t need to check this box unless you are writing extensions'
 'to the SPTool or are using another Toolbox besides the Signal Processing'
 'Toolbox which plugs into the SPTool.'
 ' '
 'To use the SPTool with any extensions added, you must close the SPTool'
 'and restart it after checking the "Search for plug-ins at start-up" box.'
 };

% controls cell array.  Columns are:
%  Name  Description  type  radiogroup  number_of_lines popup_string ...
%      factory_value  help_string
plugPrefs.controls = {
  'plugFlag' 'Search for plug-ins at start-up' 'checkbox' '' 1 ...
      {} ...
      0 ...
      plugPrefs.panelHelp
};

plugPrefs.currentValue = plugPrefs.controls(:,7);

% Now arrange in array:
if ~isempty(which('tf/tf')); 
    % Control Toolbox exists add preference for TF objects
    p = [rulerPrefs; colorPrefs; sigbrowsePrefs; spectviewPrefs;...
            filtdesPrefs; defsesPrefs;...
            exportPrefs; plugPrefs];
else
    p = [rulerPrefs; colorPrefs; sigbrowsePrefs; spectviewPrefs;...
            filtdesPrefs; defsesPrefs;...
            plugPrefs];
end