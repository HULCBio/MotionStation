function [hc, h] = addfreqcsmenu(hObj, hlbl, enab)
%ADDFREQCSMENU Add a cs menu to switch between linear and normalized frequency
%   ADDFREQCSMENU(hOBJ, HLBL) Add a cs menu to switch between linear and 
%   normalized frequency.  hOBJ is a handle object which has the GETFS.  It
%   must also have a property 'FigureHandle' and 'FreqDisplayMode'.  The
%   'FreqDisplayMode' must have the 'Normalized' and 'Linear' options.
%
%   The GETFS method must return:
%       A double representing the sampling frequency.
%       A string representing the modifier for the sampling frequency (Hz)
%       A double representing the conversion factor for the first output
%
%   see @siggui/@fvtool/getfs.m for an explicit example

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/11/21 15:36:00 $ 

error(nargchk(2,3,nargin));
if nargin < 3, enab = {'On', 'On'}; end

sep = {'Off', 'Off'};
[hc, sep{1}] = addcsmenu(hlbl); 

% Create the default aspects of the menu items
tags = {'normalized','hz'};

% Set up the labels for a frequency based axes
lbls = {xlate('Normalized Frequency'), ...
        xlate('Linear Frequency')};

% Generate the menus
for i = 1:length(tags)
    h(i) = uimenu(hc, 'Label', lbls{i}, ...
        'Callback', {@update_displaymode, hObj}, ...
        'Tag', tags{i}, ...
        'Enable', enab{i}, ...
        'Separator', sep{i});
end

% Make sure that the correct menu is checked
hm   = findall(h, 'Enable', 'On');
if length(hm) == 1,
    set(hm, 'Checked', 'On');
else,
    mode = get(hObj, 'FreqDisplayMode');
    set(findall(hm, 'tag', lower(mode)), 'Checked', 'On');
end


%-------------------------------------------------------------------
function update_displaymode(hcbo, eventStruct, hObj)

set(get(get(hcbo, 'Parent'), 'Children'), 'Checked', 'Off');
set(hcbo, 'Checked', 'On');

set(hObj, 'FreqDisplayMode', get(hcbo, 'tag'));

% [EOF]
