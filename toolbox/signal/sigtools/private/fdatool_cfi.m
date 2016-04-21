function varargout = fdatool_cfi(hFDA)
%CFI Install the Current Filter Information
%   CFI(hFDA) Install the Current Filter Information for the session
%   of FDATool associated with hFDA.

% The CFI can be installed on any figure using its methods directly

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.42.4.5 $  $Date: 2004/04/13 00:32:27 $

error(nargchk(1,1,nargin));

hFig = get(hFDA,'FigureHandle');

sz  = fdatool_gui_sizes(hFDA);
pos = [sz.fx1 sz.fy1 sz.fw1 sz.fh1];

% Instantiate the object
hCFI = siggui.cfi;

% Render the CFI
render(hCFI,hFig,pos);
setunits(hCFI,'normalized');

% set(hCFI,'Visible','On');

% Set up the Filter Listener for automatic updating
addlistener(hFDA, 'FilterUpdated', @filterupdated_eventcb, hCFI);
addlistener(hFDA, 'FastFilterUpdated', @fastfilterupdated_eventcb, hCFI);

% Add the Current Filter Information as a component to FDATool
addcomponent(hFDA, hCFI);

install_menus(hFDA, hCFI);

% Only output if an output is requested
if nargout, varargout{1} = hCFI; end


% -----------------------------------------------------------------------
function install_menus(hFDA, hCFI)

cbs = menus_cbs(hFDA);

lbls = {xlate('Convert Structure ...'), ...
    xlate('Convert to Second-Order Sections ...'), ...
    xlate('Reorder Second-Order Sections ...'), ...
    xlate('Convert to Single Section'), ...
    xlate('Show Filter Structure')};
cbs  = {cbs.convertstruct, ...
    cbs.convert2sos, ...
    cbs.reordersos, ...
    {@convert2ss, hFDA}, ...
    {@showstructure_cb, hFDA}};
tags = {'convertstructure', ...
    'convert2sos', ...
    'reordersos', ...
    'convert2ss', ...
    'showstructure'};
seps = {'on','off', 'off', 'off', 'on'};

h  = handles2vector(hCFI);
hc = get(h(1), 'uicontextmenu');

hold = findobj(hc, 'Label', 'What''s This?');
set(hold, 'Separator', 'On');

hFig = get(hCFI, 'FigureHandle');
hEdit = findobj(hFig, 'Type', 'Uimenu', 'Tag', 'edit');
hHelp = findobj(hFig, 'Type', 'Uimenu', 'tag', 'help');

hm = [];

for i = 1:4,
    hm(end+1) = uimenu(hEdit, ...
        'Label', lbls{i}, ...
        'Callback', cbs{i}, ...
        'Tag', tags{i}, ...
        'Position', 2+i, ...
        'Separator', seps{i});
end

hm(end+1) = uimenu(hHelp, ...
    'Label', lbls{4}, ...
    'Callback', cbs{4}, ...
    'Tag', tags{4}, ...
    'Position', 3, ...
    'Separator', 'On');

seps{1} = 'Off';

for i = 1:length(lbls),
    hm(end+1) = uimenu(hc, ...
        'Label', lbls{i}, ...
        'Callback', cbs{i}, ...
        'Tag', tags{i}, ...
        'Separator', seps{i}, ...
        'Position', i);
end

setappdata(hFDA, 'ConvertMenuHandles', hm);

% -----------------------------------------------------------------------
function fastfilterupdated_eventcb(hCFI, eventData)

set(hCFI,'isStable',isstable(getfilter(eventData.Source)));


% -----------------------------------------------------------------------
function filterupdated_eventcb(hCFI, eventData)
%FILTERUPDATED_EVENTCB

hFDA = get(eventData,'Source');

updatecfi(hFDA, hCFI);
updatemenus(hFDA);


% -------------------------------------------------------------------------
function updatemenus(hFDA)

hm   = getappdata(hFDA, 'ConvertMenuHandles');
filt = getfilter(hFDA);

% Check the structures for those that we support converting to SOS.
if getflags(hFDA,'calledby','dspblks') & ~isa(filt, 'dfilt.df2t') | ...
        ~any(strcmpi(lclgetclass(filt), {'df1','df2','df1t','df2t','df1sos','df2sos','df1tsos','df2tsos'})),
    enabState = 'Off';
else
    enabState = 'On';
end

if isa(filt, 'dfilt.abstractsos'),
    str = xlate('Order and Scale SOS');
else,
    str = xlate('Convert to Second-Order Sections');
end

set(getcomponent(hFDA, 'siggui.sos'), 'Enable', enabState);
set(findobj(hm, 'tag', 'convert2sos'), 'Enable', enabState, 'Label', str);

% If the filter is multisections enable the option
% STRCMP is faster than isa when the object hasnt been instantiated.
if isa(filt, 'dfilt.multisection') || isa(filt, 'dfilt.abstractsos'),
    enabState = 'On';
else,
    enabState = 'Off';
end
set(findobj(hm, 'tag', 'convert2ss'), 'Enable', enabState);

if isa(filt, 'dfilt.abstractsos'),
    enabState = 'On';
else,
    enabState = 'Off';
end
set(findobj(hm, 'tag', 'reordersos'), 'Enable', enabState);


% -------------------------------------------------------------------------
function updatecfi(hFDA, hCFI)

filt = getfilter(hFDA);
nsecs = nsections(filt);
source = get(hFDA, 'FilterMadeBy');
fname = get(filt, 'FilterStructure');

try,
    set(hCFI,'Order',order(filt));
    set(hCFI,'Sections',nsecs);
    set(hCFI,'Source',source);
    set(hCFI,'isStable',isstable(filt));
    set(hCFI,'FilterStructure',fname);
catch
    senderror(hCFI);
end

% -------------------------------------------------------------------------
function showstructure_cb(hcbo, eventStruct, hFDA)

filtobj = getfilter(hFDA);

helpview(fullfile(docroot, 'toolbox', 'signal', [class(filtobj), '.html']));

% -------------------------------------------------------------------------
function convert2ss(hcbo, eventStruct, hFDA)
%CONVERT2SS Convert to single section

% xxx This code needs to be a method.

filt = getfilter(hFDA);

str = { ...
    '% Get the transfer function values.', ...
    '[b, a] = tf(Hd);', ...
    '', ...
    '% Convert to a singleton filter.'};

[b, a] = tf(filt);

if isa(filt, 'dfilt.abstractsos'),

    fstruct = class(filt);
    filt = feval(str2func(fstruct(1:end-3)), b, a);
    str = { ...
        str{:}, ...
        sprintf('Hd = %s(b, a);', fstruct(1:end-3)), ...
        };
else

    s = filt.Section(1);

    % If they are all fir we cast to the first nonscalar section
    if isfir(filt),
        indx = 2;
        while isscalar(s),
            s = filt.Section(indx);
            indx = indx + 1;
        end
        filt = feval(str2func(class(s)), b/a);
        str = { ...
            str{:}, ...
            sprintf('Hd = %s(b/a);', class(s)), ...
            };
    else

        % If one is not FIR we cast to the first non FIR filter
        indx = 2;
        while isfir(s),
            s = filt.Section(indx);
            indx = indx + 1;
        end
        filt = feval(str2func(class(s)), b, a);
        str = { ...
            str{:}, ...
            sprintf('Hd = %s(b, a);', class(s)), ...
            };
    end
end

startrecording(hFDA, 'Convert to single section');

str = sprintf('%s\n', str{:}); str(end) = [];
opts.mcode = str;

hFDA.setfilter(filt, opts);

stoprecording(hFDA);

% --------------------------------------------------------------------------
function c = lclgetclass(filtobj)

c = class(filtobj);
c = c(7:end);

% [EOF]
