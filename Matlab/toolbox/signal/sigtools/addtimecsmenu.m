function [hc, h] = addtimecsmenu(hObj, hlbl, enab)
%ADDTIMECSMENU Add a context sensitive menu to a time label.
%   ADDTIMECSMENU(hOBJ, HLBL) Add a cs menu to switch between linear and 
%   normalized frequency.  hOBJ is a handle object which has the GETFS method.
%   It must also have a property 'FigureHandle' and 'TimeDisplayMode'.  The
%   'TimeDisplayMode' must have the 'Samples' and 'Time' options.
%
%   The GETFS method must return:
%       A double representing the sampling time.
%       A string representing the modifier for the sampling time ('ms', 'us')
%       A double representing the conversion factor for the first output
%
%   The GETFS method must take:
%       The handle to the object
%       A string 'freq' or 'time' which indicates what domain to return
%       A boolean flag which tells the object to return what is specified 
%
%   see @siggui/@fvtool/getfs.m for an explicit example

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/11/21 15:36:03 $

error(nargchk(2,3,nargin));
if nargin < 3, enab = {'On', 'On'}; end

sep = {'Off', 'Off'};
[hc, sep{1}] = addcsmenu(hlbl);

% Create the default aspects of the menu items
tags = {'samples','seconds'};

% Set up the labels for a time based axes
lbls = {xlate('Samples'), ...
        xlate('Time')};

% Generate the menus
for i = 1:length(tags)
    h(i) = uimenu(hc, 'Label', lbls{i}, ...
        'Callback', {@update_displaymode, hObj}, ...
        'Enable', enab{i}, ...
        'Tag', tags{i}, ...
        'Separator', sep{i});
end

% Make sure that the correct menu is checked
hm   = findall(h, 'Enable', 'On');
if length(hm) == 1,
    set(hm, 'Checked', 'On');
else,
    mode = get(hObj, 'TimeDisplayMode');
    set(findall(hm, 'tag', lower(mode)), 'Checked', 'On');
end

%-------------------------------------------------------------------
function update_displaymode(hcbo, eventStruct, hObj)

set(get(get(hcbo, 'Parent'), 'Children'), 'Checked', 'Off');
set(hcbo, 'Checked', 'On');

set(hObj, 'TimeDisplayMode', get(hcbo, 'tag'));

% [EOF]
