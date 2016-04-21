function response = sfsnr(varargin)
% sfsnr - Search And Replace
% Main function used to parse out calls to other functions.
% Parameters:
%   varargin    cell array of parameters.  First parameter indicates function name,
%               additional parameters are parameters to that funcion.

% Author: J Breslau
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.72.4.8 $  $Date: 2004/04/15 01:00:16 $



    % set the default response
    response = 1;

    try

        % with no arguments just revive the state machine
        if nargin==0
            sf_snr_inject_event('standAlone');
            return;
        end

        switch varargin{1},
        case 'init',
            init_l(varargin{2}, varargin{3}, varargin{4});
        case 'init_GUI',
            response = init_GUI_l;
        case 'search_string_empty',
            response = search_string_empty_l;
        case 'search',
            set_busy_l;
            response = search_l(varargin{2}, varargin{3}, varargin{4}, varargin{5});
        case 'inner_search',
            response = inner_search_l(varargin{2}, varargin{3}, varargin{4}, create_search_matrix_l, 0);
        case 'found_item',
            set_busy_l;
            response = found_item_l(varargin{2}, varargin{3}, varargin{4}, varargin{5});
        case 'replace',
            set_busy_l;
            response = replace_l(varargin{2}, varargin{3}, varargin{4}, varargin{5});
        case 'replace_all',
            set_busy_l;
            replace_all_l(varargin{2}, varargin{3}, varargin{4}, varargin{5});
        case 'replace_this',
            set_busy_l;
            replace_this_l(varargin{2}, varargin{3}, varargin{4});
        case 'inner_replace_this',
            % get the fields bitfield
            fields = get_fields_l(varargin{5}, varargin{2}, create_search_matrix_l);

            response = inner_replace_this_l(varargin{2}, varargin{3}, varargin{4}, fields, varargin{5}, [0 1 0 1]);
        case 'set_decide',
            set_decide_l;
        case 'set_idle',
            set_idle_l;
        case 'resize',
            resize_l;
        case 'slide_v',
            slide_v_l;
        case 'slide_h',
            slide_h_l;
        case 'over',
            response = over_l(varargin{2});
        case 'pop_menu',
            pop_menu_l;
        case 'is_open',
            response = strcmp(get(find_figure_l, 'SelectionType'), 'open');
        case 'is_alt',
            response = strcmp(get(find_figure_l, 'SelectionType'), 'alt');
        case 'drag',
            drag_l;
        case 'drag_stop',
            drag_l(1);
        case 'toggle_portal',
            toggle_portal_wrapper_l;
        case 'kill',
            sf_snr_inject_event('kill');
            fig = find_figure_l;
            if fig
                s = get(fig, 'UserData');
                if ~isempty(s) & check_handle_l(s.portal, 'portal')
                    sf('delete', s.portal);
                end
                set(0, 'CurrentFigure', fig)
                closereq;
                find_figure_l(0);
            end
        case 'cancel',
            sf_snr_inject_event('cancel');
            cancel_l;
        case 'help',
            help_l;
        case 'key_press',
            key_press_l;
        case 'warn',
            toss_warning_l(varargin{2}, varargin{3});
        case 'set_option',
            set_option_l;
        case 'fields_toggle',
            if (nargin == 2)
                fields_toggle_l(varargin{2});
            else
                fields_toggle_l;
            end
        case 'types_toggle',
            if (nargin == 2)
                types_toggle_l(varargin{2});
            else
                types_toggle_l;
            end
        case 'set_scope',
            set_scope_l;
        case 'is_viewable',
            response = is_viewable_l(varargin{2});
        case 'view_item',
            view_item_l(varargin{2});
        case 'yank_blanket',
            yank_blanket_l;
        otherwise,
            topId = varargin{1};
            if ~isnumeric(topId)
                topId = str2num(topId);
            end
            if isempty(topId)
                % unrecognized command
                response = 0;
                return;
            end
            activeId = sf('SnRActiveId');
            if topId == activeId
                % see if there already is a figure
                fig = find_figure_l;

                if fig
                    s = get(fig, 'UserData');
                    if ~check_handle_l(s.portal, 'portal')
                        s.portal = create_portal_l(fig, s.gp.portalVisible);
                        set(fig, 'UserData', s);
                        resize_l;
                    end
                    yank_blanket_l;
                    figure(fig);
                    return;
                end
            end
            sf('SnRActiveId', topId);
            sf_snr_inject_event('standAlone');
        end
    catch
        % deal with errors
        disp(lasterr);
        response = 0;
    end


%---------------------------------------------------------------------------------------
% Initializes any structures
% Parameters:
%   options         bitfield of search options
%   fields          bitfield of field types
%   types           bitfield of search types
%---------------------------------------------------------------------------------------
function init_l(options, fields, types)
    % get the figure
    fig = find_figure_l;

    % get the figure's user data
    s = get(fig, 'UserData');

    % get the active id
    id = sf('SnRActiveId');

    set_scope_l(id);

    % decompose the options
    options = pad_dec2bin_l(options, s.gp.numOptions);

    if options(1)
        set(s.hg.options.searchOption, 'Value', 1);
    elseif options(2)
        set(s.hg.options.searchOption, 'Value', 3);
    else
        set(s.hg.options.searchOption, 'Value', 2);
    end
    set(s.hg.options.matchCase,    'Value', options(3));
    set(s.hg.options.preserveCase, 'Value', options(4));

    % decompose the fields
    fields = pad_dec2bin_l(fields, s.gp.numFields);

    set(s.hg.fieldsShow.labels,       'Value', fields(1));
    set(s.hg.fieldsShow.names,        'Value', fields(2));
    set(s.hg.fieldsShow.descriptions, 'Value', fields(3));
    set(s.hg.fieldsShow.documents,    'Value', fields(4));
    set(s.hg.fieldsShow.customCode,   'Value', fields(5));

    % decompose the types
    types = pad_dec2bin_l(types, s.gp.numTypes);

    set(s.hg.typesShow.machine,     'Value', types(1));
    set(s.hg.typesShow.states,      'Value', types(2));
    set(s.hg.typesShow.charts,      'Value', types(3));
    set(s.hg.typesShow.junctions,   'Value', types(4));
    set(s.hg.typesShow.transitions, 'Value', types(5));
    set(s.hg.typesShow.data,        'Value', types(6));
    set(s.hg.typesShow.events,      'Value', types(7));
    set(s.hg.typesShow.targets,     'Value', types(8));


%---------------------------------------------------------------------------------------
% Tests the value of the search string.
% Returns:
%   true        if the search string is null
%---------------------------------------------------------------------------------------
function response = search_string_empty_l
    % get the figure
    fig = find_figure_l;

    % get the figure's user data
    s = get(fig, 'UserData');

    response = isempty(get(s.hg.searchString, 'String'));



%---------------------------------------------------------------------------------------
% Sets the current found item
% Parameters:
%   item            the object found
%   startIndex      the index of the character after which to start matching
%   options         bitfield of search options (see options_toggle_l)
%   fields          bitfield of field types to search (see fields_toggle_l)
% Returns:
%   the index of the first character the first match or zero if there is no match
%---------------------------------------------------------------------------------------
function response = found_item_l(item, startIndex, options, fields)
    % get the figure
    fig = find_figure_l;

    if isempty(sf('Private', 'filter_deleted_ids', item))
        toss_warning_l('warning', 'Search object not found');
        response = 0;
        return;
    end

    % get the figure's user data
    s = get(fig, 'UserData');

    % check for warnings
    if s.sp.warn | s.sp.info
        response = 0;
        return;
    end

    % decompose the options
    options = pad_dec2bin_l(options, s.gp.numOptions);

    % get the search expression
    i.searchExpr = search_options_l(get(s.hg.searchString, 'String'), options);

    % check to see if the search string has changed
    if ~strcmp(i.searchExpr, s.sp.searchExpr)
        % found item can't handle this case
        response = 0;
        return;
    end

    % try to advance to the next match from the last search
    under = get(s.hg.found.match, 'UserData');
    if ~isempty(under)
        lastMatchIndex = find(s.hg.found.activeHighlights==under);
        if lastMatchIndex < length(s.hg.found.activeHighlights)
            % there is another match in this object
            set(under, 'FaceColor', [.8 .8 .8]);
            under = s.hg.found.activeHighlights(lastMatchIndex+1);
            thisMatch = get(under, 'UserData');
            if ~isempty(thisMatch)
                set(s.hg.found.match, 'position', get(under, 'position'));
                set(under, 'FaceColor', [1 1 1]);
                force_row_l(s, thisMatch.row);
                force_column_l(s);
                set(fig, 'UserData', s);
                response = thisMatch.index;
            end
            set(s.hg.found.match, 'UserData', under);
        else
            response = 0;
        end
        return;
    end


    % initialize the possible return strings
    i.count = 0;
    i.offset = 0;
    i.startIndex = startIndex;
    i.found = 0;
    i.fieldStrings = {};
    i.row = 1;
    i.col = 1;
    i.parent = s.hg.found.propertiesAxes;
    i.properties = s.hg.found.properties;
    i.newHighlights = [];
    i.newRows = 0;
    i.readonly = 0;
    if options(3)
        i.matchCase = 'matchcase';
    else
        i.matchCase = 'ignorecase';
    end

    % get the user data from the axes
    pa = get(s.hg.found.propertiesAxes, 'UserData');

    % update the foundObject area on the GUI
    MACHINE = sf('get', 'default','machine.isa');
    CHART = sf('get', 'default','chart.isa');
    TARGET = sf('get', 'default','target.isa');
    STATE = sf('get', 'default','state.isa');
    DATA = sf('get', 'default','data.isa');
    EVENT = sf('get', 'default','event.isa');
    JUNCTION = sf('get', 'default','junction.isa');
    TRANSITION = sf('get', 'default','transition.isa');

    type = sf('get', item, '.isa');

    isTruthTable = is_truth_table_l(type, item);
    isEML = is_eml_l(type, item);

    switch type
    case MACHINE,
        title = '(machine) ';
        set(s.hg.found.icon, 'CData', s.id.machine);
    case CHART,
        title = '(chart) ';
        set(s.hg.found.icon, 'CData', s.id.chart);
    case TARGET,
        title = '(target) ';
        set(s.hg.found.icon, 'CData', s.id.target);
    case STATE,
        % sift states further by type
        subType = sf('get', item, '.type');
        isSubchart = (sf('get', item, '.superState')==2);
        switch subType,
        case {0, 1},
            title = '(state) ';
            if (isSubchart)
                set(s.hg.found.icon, 'CData', s.id.substate);
            else
                set(s.hg.found.icon, 'CData', s.id.state);
            end
        case 2,
            title = '(function) ';
            if (isSubchart)
                set(s.hg.found.icon, 'CData', s.id.subfunc);
            else
                set(s.hg.found.icon, 'CData', s.id.func);
            end
        case 3,
            % refine again for notes
            if (sf('get', item, '.isNoteBox') == 1)
                title = '(note) ';
                set(s.hg.found.icon, 'CData', s.id.note);
            else
                title = '(box) ';
                if (isSubchart)
                    set(s.hg.found.icon, 'CData', s.id.subbox);
                else
                    set(s.hg.found.icon, 'CData', s.id.box);
                end
            end
        end
    case DATA,
        title = '(data) ';
        set(s.hg.found.icon, 'CData', s.id.data);
    case EVENT,
        title = '(event) ';
        set(s.hg.found.icon, 'CData', s.id.event);
    case JUNCTION,
        title = '(junction) ';
        set(s.hg.found.icon, 'CData', s.id.junction);
    case TRANSITION,
        title = '(transition) ';
        set(s.hg.found.icon, 'CData', s.id.transition);
    end

    set(s.hg.found.icon, 'Visible', 'on');

    title = [title sf('FullNameOf', item, '.')];

    % set the name
    set(s.hg.found.name, 'String', title, 'UserData', title);

    % trim the name
    trim_name_l(s);

    % get the fields bitfield
    fields = get_fields_l(type, item, create_search_matrix_l(fields));
    fieldStrings = get_field_strings_l;
    fieldLabels = {'Label:' 'Name:' 'Description:' 'Document Link:' 'Custom Code:'};

    % check the fields
    for j = 1:length(fieldStrings)
        if fields(j)
            property = sf('get', item, fieldStrings{j});
            if property
                i = dismantle_property_l (property, fieldLabels{j}, i);
            end
        end
    end

    if isEML
        property = get_eml_script_l(item);
        if property
            i = dismantle_property_l (property, '', i);
        end
    end

    if isTruthTable
        set(s.hg.found.conditionsGreyArea, 'Visible', 'on');
        set(s.hg.found.actionsGreyArea, 'Visible', 'on');

        iterator = iterate_truth_table_l(item, 'next');

        [rows cols] = size(iterator.predicateArray);
        columnNames = {'Description', 'Condition'};
        numCols = length(columnNames);
        for col = numCols+1:cols
            columnNames{col} = ['T' int2str(col-numCols)];
        end

        conditionRow = i.row;
        [i iterator] = dismantle_table_l('Condition Table:', columnNames, i, iterator);

        % remove the label from the last row
        i.fieldStrings{i.row-1} = [];

        actionRow = i.row;
        columnNames = {'Description', 'Action'};
        [i iterator] = dismantle_table_l('Action Table:', columnNames, i, iterator);
    else
        conditionRow = 0;
        actionRow = 0;
    end

    if ~i.found
        response = 0;
        return;
    end

    s.hg.found.properties = i.properties;

    s.sp.totalRows = i.row-1;
    s.sp.offset = 0;

    pa = force_row_l(s, i.found);

    pa.width = 0;
    foundTextX = s.gp.foundFieldWidth+s.gp.buffer;

    if ~isempty(i.newHighlights) | i.newRows
        kids = get(i.parent, 'Child');
        for k = i.newHighlights
            kids(kids==k) = [];
        end
        kids(kids==s.hg.found.match) = [];
        kids = [s.hg.found.match; kids; i.newHighlights'];
        set(i.parent, 'Child', kids);
    end

    fieldStringIndex = 1;
    [propertyRows propertyCols] = size(s.hg.found.properties);
    if propertyRows > length(i.fieldStrings)
        i.fieldStrings{propertyRows} = [];
    end
    for row = 1:propertyRows
        if ~isempty(i.fieldStrings{row})
            if fieldStringIndex > length(s.hg.found.fields)
                s.hg.found.fields(fieldStringIndex) = text([0], [0], '',...
                                                           'Parent',               s.hg.found.propertiesAxes,...
                                                           'Interpreter',          'none',...
                                                           'VerticalAlignment',    'Top',...
                                                           'Clipping',             'on',...
                                                           'HorizontalAlignment',  'Right');
            end
            set(s.hg.found.fields(fieldStringIndex), 'Position', [s.gp.foundFieldWidth pa.height-(row-1)*s.gp.foundTextHeight],...
                                                     'String', i.fieldStrings{row});
            fieldStringIndex = fieldStringIndex + 1;
        end
    end
    columnXpos = foundTextX;
    highCells = cell(propertyCols, propertyRows);
    for propertyCol = 1:propertyCols
        for row = 1:propertyRows
            if s.hg.found.properties(row, propertyCol)
                set(s.hg.found.properties(row, propertyCol), 'Position', [columnXpos pa.height-(row-1)*s.gp.foundTextHeight]);
                lastEx = get(s.hg.found.properties(row, propertyCol), 'Extent');
                highlight = 0;
                highCol = 1;
                highCell = [];
                ud = get(s.hg.found.properties(row, propertyCol), 'UserData');
                fullString = '';
                for col = 1:length(ud.rowStrings)
                    fullString = [fullString strrep(ud.rowStrings{col}, char(9), '    ')];
                    set(s.hg.found.properties(row, propertyCol), 'String', fullString);
                    ex = get(s.hg.found.properties(row, propertyCol), 'Extent');
                    if highlight & ex(3) > 0
                        highEx(1) = lastEx(1)+lastEx(3)-.5;
                        highEx(2) = pa.height-row*s.gp.foundTextHeight;
                        highEx(3) = ex(3)-lastEx(3)+1;
                        highEx(4) = s.gp.foundTextHeight;
                        set(ud.highlights(highCol), 'position', highEx, 'Visible', 'on');
                        highCell = [highCell ud.highlights(highCol)];
                        if get(ud.highlights(highCol), 'FaceColor') == [1 1 1]
                            under = ud.highlights(highCol);
                            set(s.hg.found.match, 'position', highEx, 'Visible', 'on', 'UserData', under);
                        end
                        highCol = highCol + 1;
                    end
                    highlight = ~highlight;
                    pa.width = max(pa.width, ex(1)+ex(3));
                    lastEx = ex;
                end
                highCells{propertyCol, row} = highCell;
            end
        end
        columnXpos = pa.width + s.gp.buffer;
    end
    
    s.hg.found.activeHighlights = [highCells{:}];

    set(s.hg.found.propertiesAxes, 'UserData', pa);

    maxWidth = force_column_l(s);

    set(s.hg.found.conditionsGreyArea, 'Position', [0, pa.height-conditionRow*s.gp.foundTextHeight, maxWidth s.gp.foundTextHeight]);
    set(s.hg.found.actionsGreyArea, 'Position', [0, pa.height-actionRow*s.gp.foundTextHeight, maxWidth s.gp.foundTextHeight]);

    usePortal = 0;

    switch type
    case {MACHINE, TARGET, DATA, EVENT}
        set(s.hg.viewItem, 'Enable', 'off');
        set(s.hg.exploreItem, 'Enable', 'on');
    case {CHART, STATE}
        set(s.hg.viewItem, 'Enable', 'on');
        set(s.hg.exploreItem, 'Enable', 'on');
        usePortal = ~isTruthTable & ~isEML;
    case {JUNCTION, TRANSITION}
        set(s.hg.viewItem, 'Enable', 'on');
        set(s.hg.exploreItem, 'Enable', 'off');
        usePortal = 1;
    end

    if usePortal & s.gp.portalVisible
        sf('set', s.portal, '.viewObject', item);
    else
        sf('set', s.portal, '.viewObject', 0);
    end

    set(fig, 'UserData', s);

    thisMatch = get(under, 'UserData');
    response = thisMatch.index;



%---------------------------------------------------------------------------------------
% Forces the column of the match to be visible.
% Parameters:
%   s       The user data for the SNR figure
% Returns:
%   The maximum width of the display area.
%---------------------------------------------------------------------------------------
function maxWidth = force_column_l(s)
    axesPos = get(s.hg.found.propertiesAxes, 'Position');
    pa = get(s.hg.found.propertiesAxes, 'UserData');

    if pa.width > axesPos(3)
        forcePos = get(s.hg.found.match, 'Position');
        rightView = max(axesPos(3), forcePos(1)+forcePos(3));
        slideLength = pa.width-axesPos(3);
        set(s.hg.found.sliderH, 'Min',          axesPos(3),...
                                'Max',          pa.width,...
                                'Value',        rightView,...
                                'Enable',       'on',...
                                'SliderStep',   [min(s.gp.buffer,slideLength)/slideLength axesPos(3)/slideLength]);
        set(s.hg.found.propertiesAxes, 'XLim', [rightView-axesPos(3) rightView]);
        maxWidth = pa.width;
    else
        set(s.hg.found.sliderH, 'Enable',       'off');
        set(s.hg.found.propertiesAxes, 'XLim', [0 axesPos(3)]);
        maxWidth = axesPos(3);
    end

%---------------------------------------------------------------------------------------
% Forces the row of the match to be visible.
% Parameters:
%   s       The user data for the SNR figure
%   row     The row to force
% Returns:
%   The properties axes user data with height and offset set
%---------------------------------------------------------------------------------------
function pa = force_row_l(s, row)
    if s.sp.totalRows > s.gp.foundRows
        pa.height = s.sp.totalRows*s.gp.foundTextHeight;
        pa.offset = 0;
        bottomRow = min(max(s.gp.foundRows, row+(s.gp.foundRows/2)), s.sp.totalRows);
        slide = s.gp.foundRows + s.sp.totalRows - bottomRow;
        set(s.hg.found.sliderV, 'Min',          s.gp.foundRows,...
                                'Max',          s.sp.totalRows,...
                                'Value',        slide,...
                                'Enable',       'on',...
                                'SliderStep',   [1 s.gp.foundRows]/(s.sp.totalRows-s.gp.foundRows));
        set(s.hg.found.propertiesAxes, 'YLim', [slide*s.gp.foundTextHeight-s.gp.foundObjectHeight slide*s.gp.foundTextHeight]);
        set(s.hg.found.fieldsGreyArea, 'Position', [0, -1*s.gp.foundObjectHeight, s.gp.foundFieldWidth 2*s.gp.foundObjectHeight+pa.height]);
    else
        set(s.hg.found.sliderV, 'Enable',       'off');
        pa.height = s.gp.foundObjectHeight;
        pa.offset = s.gp.foundRows - s.sp.totalRows;
        set(s.hg.found.propertiesAxes, 'YLim', [0 s.gp.foundObjectHeight]);
    end

%---------------------------------------------------------------------------------------
% Adds all the fields of a table to the properties list
% Parameters:
%   tableName   the name of the table to dismantle
%   columnNames a cell array of strings to use as column headers
%   i           the structure of iterative data used by dismantle_property_l
% Returns:
%   i           the structure of iterative data incremented as necessary
%---------------------------------------------------------------------------------------
function [i, iterator] = dismantle_table_l (tableName, columnNames, i, iterator)
    i.readonly = 1;
    for col = 1:length(columnNames)
        i.col = col;
        i = dismantle_property_l (columnNames{col}, tableName, i);
        i.row = i.row - 1;
    end;
    i.row = i.row + 1;

    % enter all information
    [rows cols] = size(iterator.currentArray);
    rowIn = i.row;
    for row = 1:rows
        rowIn = i.row;
        rowOut = i.row;
        for col = 1:cols
            i.col = col;
            property = iterator.currentArray{row,col};
            if row == iterator.row & col == iterator.col
                i.readonly = 0;
                iterator = iterate_truth_table_l(iterator, 'next');
            else
                i.readonly = 1;
            end
            if ~isempty(property)
                i = dismantle_property_l (property, int2str(row), i);
            end
            rowOut = max(rowOut, i.row);
            i.row = rowIn;
        end
        i.row = rowOut;
    end

%---------------------------------------------------------------------------------------
% Breaks up a property string into a matrix of strings according to matches
% Parameters:
%   property    the string to dismantle
%   field       the label for this field
%   i           a structure of iterative data
% Returns:
%   i           the structure of iterative data incremented as necessary
%---------------------------------------------------------------------------------------
function i = dismantle_property_l (property, field, i)
    % get the number of lines in this propery
    lines = sum(property==10);

    if property(end) ~= 10
        lines = lines + 1;
    end

    i.fieldStrings{i.row} = field;


    dims = size(i.properties);

    % track the match by a local offset
    offset = 0;

    % initialize the remainder as the whole property
    remainder = property;

    % break up the property by lines
    row = i.row;
    while row <= i.row+lines-1
        [token remainder] = strtok(remainder, 10);

        % each row but the first gets one free newline
        if row > i.row
            offset = offset+1;
        end

        % create an empty ud to use for new strings
        ud.highlights = [];
        ud.rowStrings = {};

        % increment the row & offset for any additional newlines
        while (offset < length(property) & property(offset+1) == 10)
            offset = offset+1;
            if row > dims(1) | i.col > dims(2) | ~i.properties(row, i.col)
                i.properties(row, i.col) = text('String',             '',...
                                                'Parent',             i.parent,...
                                                'Interpreter',        'none',...
                                                'UserData',           ud,...
                                                'Clipping',           'on',...
                                                'VerticalAlignment',  'Top');
                i.newRows = 1;
            end
            if isempty(field)
                i.fieldStrings{row} = [sf_scalar2str(row-i.row+1) ':'];
            end
            row = row+1;
        end

        prev = 0;
        col = 1;
        highCol = 1;
        if row > dims(1) | i.col > dims(2) | ~i.properties(row, i.col)
            i.properties(row, i.col) = text('String',             '',...
                                            'Parent',             i.parent,...
                                            'Interpreter',        'none',...
                                            'UserData',           ud,...
                                            'Clipping',           'on',...
                                            'VerticalAlignment',  'Top');
            i.newRows = 1;
        end

        ud = get(i.properties(row, i.col), 'UserData');
        highLen = length(ud.highlights);

        if ~i.readonly
            % break up the line by matches
            [first last] = regexp(token, i.searchExpr, i.matchCase);
        else
            first = [];
        end

        for step = 1:length(first)
            ud.rowStrings{col} = token(prev+1:first(step)-1);
            col = col+1;

            fragment = token(first(step):last(step));
            highColor = [.8 .8 .8];
            thisMatch.index = i.offset + offset + first(step);
            thisMatch.row = row;
            thisMatch.textObject = i.properties(row, i.col);
            if ~i.found & i.startIndex < thisMatch.index
                highColor = 'white';
                i.found = row;
            end
            if highCol > highLen
                ud.highlights(highCol) = rectangle('Visible',   'off',...
                                                   'EdgeColor', 'none',...
                                                   'Clipping',  'on',...
                                                   'Parent',    i.parent);
                i.newHighlights = [i.newHighlights ud.highlights(highCol)];
            end
            set(ud.highlights(highCol), 'FaceColor', highColor,...
                                        'UserData',  thisMatch);
            ud.rowStrings{col} = token(first(step):last(step));
            highCol = highCol+1;
            col = col+1;
            prev = last(step);
        end

        % increment the count for each of the matches in this row
        i.count = i.count + length(first);

        % advance the offset to the beginning of the next match
        offset = offset + length(token);

        % append the end of the string
        ud.rowStrings{col} = token(prev+1:length(token));

        % set the strings aside for this row
        set(i.properties(row, i.col), 'UserData', ud);

        if isempty(field)
            i.fieldStrings{row} = [sf_scalar2str(row-i.row+1) ':'];
        end
        row = row + 1;
    end

    i.row = row;
    if ~i.readonly
        i.offset = i.offset+length(property);
    end


%---------------------------------------------------------------------------------------
% Searches the model for the next instance of the search string.
% Parameters:
%   start           the object to start searching from
%   options         bitfield of search options (see options_toggle_l)
%   fields          bitfield of field types to search (see fields_toggle_l)
%   types           bitfield of object types to search (see types_toggle_l)
% Returns:
%   the objectID in which the search string was found or 0
%---------------------------------------------------------------------------------------
function response = search_l(start, options, fields, types)
    % get the figure
    fig = find_figure_l;

    if start & isempty(sf('Private', 'filter_deleted_ids', start))
        toss_warning_l('warning', 'Search object not found');
        response = 0;
        return;
    end

    % get the figure's user data
    s = get(fig, 'UserData');

    % clear all of the highlights and strings
    clear_found_l(s);

    % check for warnings
    if s.sp.warn | s.sp.info
        response = 0;
        return;
    end

    % get the searchMatrix
    searchMatrix = create_search_matrix_l(fields, types);

    if ~sum(sum(searchMatrix))
        toss_warning_l('warning', 'Invalid option set');
        response = 0;
        return;
    end

    % decompose the options
    options = pad_dec2bin_l(options, s.gp.numOptions);

    % get the search expression
    searchExpr = search_options_l(get(s.hg.searchString, 'String'), options);

    % get the search scope
    topId = sf('SnRActiveId');

    if ~topId
        toss_warning_l('warning', 'There are no open machines to search');
        response = 0;
        return;
    end

    % check to see if the search conditions have changed
    if (~strcmp(searchExpr, s.sp.searchExpr) | topId ~= s.sp.topId) & start
        % start searching from the top
        start = 0;
        resetSearch = 1;
    else
        resetSearch = 0;
    end

    % save the search expression
    s.sp.searchExpr = searchExpr;
    s.sp.topId = topId;
    set(fig, 'UserData', s);

    if isempty(sf('Private', 'filter_deleted_ids', topId))
            toss_warning_l('warning', 'Search object not found');
            response = 0;
            return;
        end

    % call the inner function for the rest of the search
    response = inner_search_l(start, topId, searchExpr, searchMatrix, options(3));

    % check for a failed reset search
    if resetSearch & ~response
        response = -1;
    end

%---------------------------------------------------------------------------------------
% Inner Function for Search
% Parameters:
%   start           the object to start searching from
%   machine         the machine this object is in
%   charts          the list of charts in the scope
%   searchExpr      the expression to search for
%   searchMatrix    matrix of types and objects to search
%   caseSensitive   true to search sensitive to case
% Returns:
%   the objectID in which the search string was found or 0
%---------------------------------------------------------------------------------------
function response = inner_search_l(start, topId, searchExpr, searchMatrix, caseSensitive)

    MACHINE = sf('get', 'default','machine.isa');
    CHART = sf('get', 'default','chart.isa');
    TARGET = sf('get', 'default','target.isa');
    STATE = sf('get', 'default','state.isa');
    DATA = sf('get', 'default','data.isa');
    EVENT = sf('get', 'default','event.isa');
    JUNCTION = sf('get', 'default','junction.isa');
    TRANSITION = sf('get', 'default','transition.isa');

    beenThere = 0;

    topType = sf('get', topId, '.isa');
    if topType == MACHINE
        charts = sf('get', topId, '.charts');
        if isempty(charts)
            charts = 0;
        end
        machine = topId;
    else
        charts = topId;
        machine = sf('get', topId, '.machine');
    end

    if ~start
        if (topType == MACHINE)
            % search the machine
            found = search_objects_l(MACHINE, machine, 0, searchExpr, searchMatrix, caseSensitive);
            if found
                response = found;
                return;
            end

            % check this machine's targets
            found = search_objects_l(TARGET, sf('TargetsOf', machine), 0, searchExpr, searchMatrix, caseSensitive);
            if found
                response = found;
                return;
            end

            % check this machine's data
            found = search_objects_l(DATA, sf('DataOf', machine), 0, searchExpr, searchMatrix, caseSensitive);
            if found
                response = found;
                return;
            end

            % check this machine's events
            found = search_objects_l(EVENT, sf('EventsOf', machine), 0, searchExpr, searchMatrix, caseSensitive);
            if found
                response = found;
                return;
            end
        end
        current = charts(1);
    else

        type = sf('get', start, '.isa');

        switch type,
        case MACHINE,
            % check this machine's targets
            found = search_objects_l(TARGET, sf('TargetsOf', machine), 0, searchExpr, searchMatrix, caseSensitive);
            if found
                response = found;
                return;
            end

            % check this machine's data
            found = search_objects_l(DATA, sf('DataOf', machine), 0, searchExpr, searchMatrix, caseSensitive);
            if found
                response = found;
                return;
            end

            % check this machine's events
            found = search_objects_l(EVENT, sf('EventsOf', machine), 0, searchExpr, searchMatrix, caseSensitive);
            if found
                response = found;
                return;
            end

            % continue searching from the first chart
            current = charts(1);
        case TARGET,
            % search the remainder of the targets for the machine
            current = sf('get', start, '.linkNode.parent');
            found = search_objects_l(TARGET, sf('TargetsOf', current), start, searchExpr, searchMatrix, caseSensitive);
            if found
                response = found;
                return;
            end

            % check this machine's data
            found = search_objects_l(DATA, sf('DataOf', current), 0, searchExpr, searchMatrix, caseSensitive);
            if found
                response = found;
                return;
            end

            % check this machine's events
            found = search_objects_l(EVENT, sf('EventsOf', current), 0, searchExpr, searchMatrix, caseSensitive);
            if found
                response = found;
                return;
            end

            % continue searching from the first chart
            current = charts(1);
        case {STATE, CHART}
            current = start;

            % check this treeNode's data
            found = search_objects_l(DATA, sf('DataOf', current), 0, searchExpr, searchMatrix, caseSensitive);
            if found
                response = found;
                return;
            end

            % check this treeNode's events
            found = search_objects_l(EVENT, sf('EventsOf', current), 0, searchExpr, searchMatrix, caseSensitive);
            if found
                response = found;
                return;
            end

            % check this treeNode's transitions
            found = search_transitions_l(current, 0, searchExpr, searchMatrix, caseSensitive);
            if found
                response = found;
                return;
            end

            % check this treeNode's junctions
            found = search_objects_l(JUNCTION, children_of_l('JunctionsOf', current), 0, searchExpr, searchMatrix, caseSensitive);
            if found
                response = found;
                return;
            end

            % check this treeNode's children
            next = sf('get', current, '.treeNode.child');
            if next
                current = next;
            else
                beenThere = 1;
            end
        case DATA,
            % search the remainder of the data for the parent
            current = sf('get', start, '.linkNode.parent');
            found = search_objects_l(DATA, sf('DataOf', current), start, searchExpr, searchMatrix, caseSensitive);
            if found
                response = found;
                return;
            end

            % check this treeNode's events
            found = search_objects_l(EVENT, sf('EventsOf', current), 0, searchExpr, searchMatrix, caseSensitive);
            if found
                response = found;
                return;
            end

            % check to see if this treeNode is actually a machine
            if sf('get', current, '.isa') == MACHINE
                % continue searching from the first chart
                current = charts(1);
            else
                % check this treeNode's transitions
                found = search_transitions_l(current, 0, searchExpr, searchMatrix, caseSensitive);
                if found
                    response = found;
                    return;
                end

                % check this treeNode's junctions
                found = search_objects_l(JUNCTION, children_of_l('JunctionsOf', current), 0, searchExpr, searchMatrix, caseSensitive);
                if found
                    response = found;
                    return;
                end

                % check this treeNode's children
                next = sf('get', current, '.treeNode.child');
                if next
                    current = next;
                else
                    beenThere = 1;
                end
            end
        case EVENT,
            % search the remainder of the events for the parent
            current = sf('get', start, '.linkNode.parent');
            found = search_objects_l(EVENT, sf('EventsOf', current), start, searchExpr, searchMatrix, caseSensitive);
            if found
                response = found;
                return;
            end

            % check to see if this treeNode is actually a machine
            if sf('get', current, '.isa') == MACHINE
                % continue searching from the first chart
                current = charts(1);
            else
                % check this treeNode's transitions
                found = search_transitions_l(current, 0, searchExpr, searchMatrix, caseSensitive);
                if found
                    response = found;
                    return;
                end

                % check this treeNode's junctions
                found = search_objects_l(JUNCTION, children_of_l('JunctionsOf', current), 0, searchExpr, searchMatrix, caseSensitive);
                if found
                    response = found;
                    return;
                end

                % check this treeNode's children
                next = sf('get', current, '.treeNode.child');
                if next
                    current = next;
                else
                    beenThere = 1;
                end
            end
        case TRANSITION,
            % search the remainder of the transitions for the parent
            current = sf('get', start, '.linkNode.parent');
            found = search_transitions_l(current, start, searchExpr, searchMatrix, caseSensitive);
            if found
                response = found;
                return;
            end

            % check this treeNode's junctions
            found = search_objects_l(JUNCTION, children_of_l('JunctionsOf', current), 0, searchExpr, searchMatrix, caseSensitive);
            if found
                response = found;
                return;
            end

            % check this treeNode's children
            next = sf('get', current, '.treeNode.child');
            if next
                current = next;
            else
                beenThere = 1;
            end
        case JUNCTION,
            % search the remainder of the junctions for the parent
            current = sf('get', start, '.linkNode.parent');
            found = search_objects_l(JUNCTION, children_of_l('JunctionsOf', current), start, searchExpr, searchMatrix, caseSensitive);
            if found
                response = found;
                return;
            end

            % check this treeNode's children
            next = sf('get', current, '.treeNode.child');
            if next
                current = next;
            else
                beenThere = 1;
            end
        otherwise,
            error('Bad object type passed to sfsnr()');
        end
    end


    while (current)
        next = 0;
        if ~beenThere
            % check this treeNode
            found = search_objects_l(sf('get', current, '.isa'), current, 0, searchExpr, searchMatrix, caseSensitive);
            if found
                response = found;
                return;
            end

            % check this treeNode's data
            found = search_objects_l(DATA, sf('DataOf', current), 0, searchExpr, searchMatrix, caseSensitive);
            if found
                response = found;
                return;
            end

            % check this treeNode's events
            found = search_objects_l(EVENT, sf('EventsOf', current), 0, searchExpr, searchMatrix, caseSensitive);
            if found
                response = found;
                return;
            end

            % check this treeNode's transitions
            found = search_transitions_l(current, 0, searchExpr, searchMatrix, caseSensitive);
            if found
                response = found;
                return;
            end

            % check this treeNode's junctions
            found = search_objects_l(JUNCTION, children_of_l('JunctionsOf', current), 0, searchExpr, searchMatrix, caseSensitive);
            if found
                response = found;
                return;
            end

            % check this treeNode's children
            next = sf('get', current, '.treeNode.child');
        end % if ~beenThere
        beenThere = 0;
        if ~next
            % no more children, move to siblings
            next = sf('get', current, '.treeNode.next');
            if ~next
                % no more siblings move to parents
                next = sf('get', current, '.treeNode.parent');
                beenThere = 1;
                if ~next
                    % no more parents, move to, um... other charts (step-siblings?).
                    index = find(charts==current);
                    if index<length(charts)
                        next = charts(index+1);
                        beenThere = 0;
                    end
                end
            end
        end
        current = next;
    end

    % found nothing
    response = 0;



%---------------------------------------------------------------------------------------
% Searches the given objects for the next instance of the search string.
% Parameters:
%   type            the type of the objects being searched
%   objectList      vector of objects to search
%   start           the object in the list to start after
%   searchExpr      the expression to search for
%   searchMatrix    boolean matrix of fields and types to search
%   caseSensitive   true to search sensitive to case
% Returns:
%   the objectID in which the search string was found or 0
%---------------------------------------------------------------------------------------
function response = search_objects_l(type, objectList, start, searchExpr, searchMatrix, caseSensitive)
    % set up the default response
    response = 0;

    if isempty(objectList)
        return;
    else
        % get the fields to search for this type
        searchFields = get_fields_l(type, objectList(1), searchMatrix);
        fieldStrings = get_field_strings_l;

        % determine if this object should be searched at all
        if ~sum(searchFields)
            return;
        end
    end

    if caseSensitive
        matchCase = 'matchcase';
    else
        matchCase = 'ignorecase';
    end

    % filter out any autogenerated objects
    objectList = filter_autogenerated_l(type, objectList);

    index = 0;
    if ~isempty(objectList)
        index = find(objectList==start);
    end
    if index
        objectList(1:index) = [];
    end
    for j = 1:length(objectList)
        item = objectList(j);
        
        % check the fields
        for i = 1:length(fieldStrings)
            if searchFields(i)
                property = sf('get', item, fieldStrings{i});
                if property
                    if ~isempty(regexp(property, searchExpr, matchCase, 'once'));
                        response = item;
                        return;
                    end
                end
            end
        end

        if is_eml_l(type, item);
            property = get_eml_script_l(item);
            if property
                if ~isempty(regexp(property, searchExpr, matchCase, 'once'));
                    response = item;
                    return;
                end
            end
        end

        if is_truth_table_l(type, item);
            iterator = iterate_truth_table_l(item, 'next');
            while ~isempty(iterator.index)
                if iterator.value
                    if ~isempty(regexp(iterator.value, searchExpr, matchCase, 'once'));
                        response = item;
                        return;
                    end
                end
                iterator = iterate_truth_table_l(iterator, 'next');
            end
        end
    end  % foreach objectList



%---------------------------------------------------------------------------------------
% Filters the given list of any autogenerated objects.
% Parameters:
%   type            the type of the objects being filtered
%   objectList      vector of objects to filtered
% Returns:
%   the filtered list of objects
%---------------------------------------------------------------------------------------
function objectList = filter_autogenerated_l(type, objectList)
    STATE = sf('get', 'default','state.isa');
    DATA = sf('get', 'default','data.isa');
    JUNCTION = sf('get', 'default','junction.isa');
    TRANSITION = sf('get', 'default','transition.isa');

    switch type,
    case {STATE, DATA, JUNCTION, TRANSITION},
        % filter out any autogenerated objects
        objectList = sf('find', objectList, '.autogen.isAutoCreated', 0);
    end,



%---------------------------------------------------------------------------------------
% Wrapper function for transition searching so super transitions are blocked.
% Parameters:
%   current         the state or chart in which to search transitions
%   start           the object in the list to start after
%   searchExpr      the expression to search for
%   searchMatrix    boolean matrix of fields and types to search
%   caseSensitive   true to search sensitive to case
% Returns:
%   the objectID in which the search string was found or 0
%---------------------------------------------------------------------------------------
function found = search_transitions_l(current, start, searchExpr, searchMatrix, caseSensitive)
    TRANSITION = sf('get', 'default','transition.isa');
    SIMPLE_TRANNY_TYPE = 0;
    SUB_TRANNY_TYPE = 1;
    SUPER_TRANNY_TYPE = 2;

    % get the full set of transitions for this object
    trannies = children_of_l('TransitionsOf', current);

    if isempty(trannies)
        found = 0;
    else
        % get the type for each of those transitions
        trannyTypes = sf('get', trannies, '.type');

        % isolate the simple transitions
        simps = trannies(trannyTypes==SIMPLE_TRANNY_TYPE);

        % isolate the sub-transitions
        subs = trannies(trannyTypes==SUB_TRANNY_TYPE);

        if ~isempty(subs)
            % purify the sub-transitions to be only the ones who's super transition is in the same scope
            subs(sf('get', sf('get', subs, '.subLink.parent'), '.linkNode.parent') ~= current) = [];
        end

        % redefine the set of transitions to be just the simples and the purified subs
        trannies = [simps subs];

        % search based on the subset of transitions
        found = search_objects_l(TRANSITION, trannies, start, searchExpr, searchMatrix, caseSensitive);
    end

%---------------------------------------------------------------------------------------
% Replaces the current match with the replace string.
% Parameters:
%   item            the object found
%   matchIndex      the index of the first character of the match
%   options         bitfield of search options
%   fields          bitfield of field types to search (see fields_toggle_l)
% Returns:
%   the index of the first character to start searching for the next match
%---------------------------------------------------------------------------------------
function nextIndex = replace_l(item, matchIndex, options, fields)
    % get the figure
    fig = find_figure_l;

    if isempty(sf('Private', 'filter_deleted_ids', item))
        toss_warning_l('warning', 'Match object not found');
        nextIndex = 0;
        return;
    end

    if sf('IsIced', item)
        toss_warning_l('warning', 'Match object not currently editable');
        nextIndex = 0;
        return;
    end

    % get the figure's user data
    s = get(fig, 'UserData');

    % decompose the options
    options = pad_dec2bin_l(options, s.gp.numOptions);

    % get the search expression
    searchExpr = search_options_l(get(s.hg.searchString, 'String'), options);

    % check to see if the search string has changed
    if ~strcmp(searchExpr, s.sp.searchExpr)
        % replace can't handle this case
        toss_warning_l('warning', 'Search String Changed');
        nextIndex = 0;
        return;
    end

    % get the replace string
    replaceStr = get(s.hg.replaceString, 'String');

    type = sf('get', item, '.isa');

    % get the fields bitfield
    fields = get_fields_l(type, item, create_search_matrix_l(fields));
    fieldStrings = get_field_strings_l;
    
    % offset matchindex
    matchIndex = matchIndex + s.sp.offset;

    nextIndex = matchIndex;

    [searchCase, replaceCase] = regexp_options_l(options);

    matchNotFound = 0;

    % check the fields
    for i = 1:length(fieldStrings)
        if ~matchNotFound & fields(i)
            property = sf('get', item, fieldStrings{i});
            propertyLen = length(property);
            if matchIndex <= propertyLen
                matches = regexp(property, searchExpr, searchCase);
                replaceIndex = find(matches==matchIndex);

                if isempty(replaceIndex)
                    matchNotFound = 1;
                else
                    property = regexprep(property, searchExpr, replaceStr, replaceCase, replaceIndex);
                    sf('set', item, fieldStrings{i}, property);
                    replace_side_effect_l(property, propertyLen, matchIndex)
                    return;
                end
            else
                % decriment matchIndex by the length of this property
                matchIndex = matchIndex - length(property);
            end
        end
    end

    if ~matchNotFound & is_eml_l(type, item)
        property = get_eml_script_l(item);
        propertyLen = length(property);
        if matchIndex <= propertyLen
            property = set_eml_substrings_l(item, property, searchExpr, replaceStr, searchCase, replaceCase, matchIndex);
            matchNotFound = isempty(property);
            if ~matchNotFound
               replace_side_effect_l(property, propertyLen, matchIndex)
               return;
            end
        else
            % decriment matchIndex by the length of this property
            matchIndex = matchIndex - length(property);
        end
    end

    if is_truth_table_l(type, item)
        iterator = iterate_truth_table_l(item, 'next');
        while ~matchNotFound & ~isempty(iterator.index)
            propertyLen = length(iterator.value);
            if matchIndex <= propertyLen
                matches = regexp(iterator.value, searchExpr, searchCase);
                replaceIndex = find(matches==matchIndex);

                if isempty(replaceIndex)
                    matchNotFound = 1;
                else
                    iterator.value = regexprep(iterator.value, searchExpr, replaceStr, replaceCase, replaceIndex);
                    iterator = iterate_truth_table_l(iterator, 'set');
                    replace_side_effect_l(iterator.value, propertyLen, matchIndex)
                    return;
                end
            else
                % decriment matchIndex by the length of this property
                matchIndex = matchIndex - length(iterator.value);
            end
            iterator = iterate_truth_table_l(iterator, 'next');
        end
    end

    if matchNotFound
        toss_warning_l('warning', 'Match not found');
    end
    nextIndex = 0;


%---------------------------------------------------------------------------------------
% Performs some ui side effect for replaces
% Parameters:
%   newProperty         The new string
%   oldPropertyLength   The length of the old string
%   matchIndex          The index in this property of the recent replace
%---------------------------------------------------------------------------------------
function replace_side_effect_l(newProperty, oldPropertyLength, matchIndex)
    % get the figure
    fig = find_figure_l;

    % get the figure's user data
    s = get(fig, 'UserData');
    
    under = get(s.hg.found.match, 'UserData');
    set(under, 'Visible', 'off');
    thisMatch = get(under, 'UserData');
    newLines = [0 find(newProperty==10)];
    thisLine = sum(newLines<matchIndex);
    if thisLine<length(newLines)
        endIndex = newLines(thisLine+1)-1;
    else
        endIndex = length(newProperty);
    end
    set(thisMatch.textObject, 'String', newProperty(newLines(thisLine)+1:endIndex));
    s.sp.offset = s.sp.offset + length(newProperty) - oldPropertyLength;    
    set(fig, 'UserData', s);


%---------------------------------------------------------------------------------------
% Replaces all additional occurrances of the search string with the replace string
% Parameters:
%   start           the object to start searching from
%   options         bitfield of search options
%   fields          bitfield of field types to search (see fields_toggle_l)
%   types           bitfield of object types to search (see types_toggle_l)
%---------------------------------------------------------------------------------------
function  replace_all_l(start, options, fields, types)
    objects = 0;

    % get the figure
    fig = find_figure_l;

    while (start)
        replace_this_l(start, options, fields);
        start = search_l(start, options, fields, types);
        objects = objects + 1;
    end

    toss_warning_l('info', ['Edited ' sf_scalar2str(objects) ' objects']);

%---------------------------------------------------------------------------------------
% Replaces all occurrances of the search string within the current object
%   with the replace string
% Parameters:
%   item            the object found
%   options         bitfield of search options
%   fields          bitfield of field types to search (see fields_toggle_l)
%---------------------------------------------------------------------------------------
function replace_this_l(item, options, fields)
    % get the figure
    fig = find_figure_l;

    if isempty(sf('Private', 'filter_deleted_ids', item))
        toss_warning_l('warning', 'Match object not found');
        return;
    end

    if sf('IsIced', item)
        toss_warning_l('warning', 'Match object not currently editable');
        return;
    end

    % get the figure's user data
    s = get(fig, 'UserData');

    % decompose the options
    options = pad_dec2bin_l(options, s.gp.numOptions);

    % get the search expression
    searchExpr = search_options_l(get(s.hg.searchString, 'String'), options);

    % check to see if the search string has changed
    if ~strcmp(searchExpr, s.sp.searchExpr)
        % replace can't handle this case
        toss_warning_l('warning', 'Search String Changed');
        return;
    end
    % get the replace string
    replaceStr = get(s.hg.replaceString, 'String');

    type = sf('get', item, '.isa');

    % get the fields bitfield
    fields = get_fields_l(type, item, create_search_matrix_l(fields));

    % call the inner function
    inner_replace_this_l(item, searchExpr, replaceStr, fields, type, options);


%---------------------------------------------------------------------------------------
% Inner Function for Replace This.
% Parameters:
%   item            the object found
%   searchExpr      the search expression
%   replaceStr      the string to replace with
%   fields          bitfield of field types to search (see fields_toggle_l)
%   type            the type of object 'item'
%   options         bitfield of search options (see options_toggle_l)
% Returns:
%   true if a replace has been made; false otherwise
%---------------------------------------------------------------------------------------
function changed = inner_replace_this_l(item, searchExpr, replaceStr, fields, type, options)
    STATE = sf('get', 'default','state.isa');

    % initialize the return value
    changed = 0;

    [searchCase, replaceCase] = regexp_options_l(options);

    fieldStrings = get_field_strings_l;

    % check the fields
    for i = 1:length(fieldStrings)
        if fields(i)
            property = sf('get', item, fieldStrings{i});
            if property
                % replace the matches in this property
                newProperty = regexprep(property, searchExpr, replaceStr, replaceCase);
                if ~strcmp(property, newProperty)
                    changed = 1;
                    sf('set', item, fieldStrings{i}, newProperty);
                end
            end
        end
    end

    if is_eml_l(type, item)
        property = get_eml_script_l(item);
        if property
            changed = ~isempty(set_eml_substrings_l(item, property, searchExpr, replaceStr, searchCase, replaceCase, 'all'));
        end
    end

    if is_truth_table_l(type, item)
        iterator = iterate_truth_table_l(item, 'next');
        while ~isempty(iterator.index)
            if iterator.value
                % replace the matches in this property
                newProperty = regexprep(iterator.value, searchExpr, replaceStr, replaceCase);
                if ~strcmp(iterator.value, newProperty)
                    changed = 1;
                    iterator.value = newProperty;
                    iterator = iterate_truth_table_l(iterator, 'set');
                end
            end
            iterator = iterate_truth_table_l(iterator, 'next');
        end
    end



%---------------------------------------------------------------------------------------
% Sets the UI into Busy Mode.  Busy Mode makes the cursor a watch
%---------------------------------------------------------------------------------------
function  set_busy_l
    % get the figure
    fig = find_figure_l;

    set(fig, 'Pointer', 'watch');

%---------------------------------------------------------------------------------------
% Sets the UI into Decide Mode.  Decide Mode enables the Replace buttons
%---------------------------------------------------------------------------------------
function  set_decide_l
    % get the figure
    fig = find_figure_l;

    % get the figure's user data
    s = get(fig, 'UserData');

    % neutralize the pointer
    set(fig, 'Pointer', 'arrow');

    % set the replace buttons to be active
    set(s.hg.replaceButton, 'Enable', 'on');
    set(s.hg.replaceAllButton, 'Enable', 'on');
    set(s.hg.found.replaceThis, 'Enable', 'on');

    % enable the properties menu item
    set(s.hg.editProperties, 'Enable', 'on');

    % set the found name to the right color
    set(s.hg.found.name, 'Color', 'blue');


%---------------------------------------------------------------------------------------
% Sets the UI into Idle Mode.  Idle Mode disables the Replace buttons
%---------------------------------------------------------------------------------------
function  set_idle_l
    % get the figure
    fig = find_figure_l;

    % Be robust to lost figure (e.g., close('all','force'))
    if ~fig | ~ishandle(fig)
        return;
    end

    % get the figure's user data
    s = get(fig, 'UserData');

    % neutralize the pointer
    set(fig, 'Pointer', 'arrow');

    % set the replace buttons to be inactive
    set(s.hg.replaceButton, 'Enable', 'off');
    set(s.hg.replaceAllButton, 'Enable', 'off');
    set(s.hg.found.replaceThis, 'Enable', 'off');

    % disable the menu items
    set(s.hg.editProperties, 'Enable', 'off');
    set(s.hg.viewItem, 'Enable', 'off');
    set(s.hg.exploreItem, 'Enable', 'off');

    % check for a warning or info
    if s.sp.warn
        % set the warning into the found titlebar
        set(s.hg.found.icon, 'Visible', 'on');
        set(s.hg.found.icon, 'CData', s.id.warn);
        set(s.hg.found.name, 'String', s.sp.warn, 'UserData', s.sp.warn, 'Color', 'black');
        % clear the warning
        s.sp.warn = '';
        s.sp.info = '';
    elseif s.sp.info
        % set the info into the found titlebar
        set(s.hg.found.icon, 'Visible', 'on');
        set(s.hg.found.icon, 'CData', s.id.info);
        set(s.hg.found.name, 'String', s.sp.info, 'UserData', s.sp.info, 'Color', 'black');
        % clear the info
        s.sp.info = '';
    else
        % clear the found titleBar
        set(s.hg.found.icon, 'Visible', 'off');
        set(s.hg.found.name, 'String', '', 'UserData', '');
    end

    % disable the scrollbars
    set(s.hg.found.sliderV, 'Enable', 'off');
    set(s.hg.found.sliderH, 'Enable', 'off');

    % set the found area to empty
    s.sp.totalRows = 0;
    s.sp.offset = 0;

    % reset the axis area
    axesPos = get(s.hg.found.propertiesAxes, 'Position');
    pa.width = axesPos(3);
    pa.height = axesPos(4);
    pa.offset = 0;
    set(s.hg.found.propertiesAxes, 'UserData', pa);
    set(s.hg.found.propertiesAxes, 'YLim', [0 s.gp.foundObjectHeight]);

    % clear all of the highlights and strings
    clear_found_l(s);

    sf('set', s.portal, '.viewObject', 0);

    % reset the user data
    set(fig, 'UserData', s);



%---------------------------------------------------------------------------------------
% Clears the found fields area
% Parameters:
%   s       The figure userdata structure
%---------------------------------------------------------------------------------------
function clear_found_l(s)
    set(s.hg.found.conditionsGreyArea, 'Visible', 'off');
    set(s.hg.found.actionsGreyArea, 'Visible', 'off');
    set(s.hg.found.match, 'Visible', 'off', 'UserData', []);
    dims = size(s.hg.found.properties);
    for row = 1:dims(1)
        for col = 1:dims(2)
            if s.hg.found.properties(row, col)
                ud = get(s.hg.found.properties(row, col), 'UserData');
                ud.rowStrings = {};
                for highCol = 1:length(ud.highlights)
                    set(ud.highlights(highCol), 'Visible', 'off', 'FaceColor', [.8 .8 .8], 'UserData', []);
                end
                set(s.hg.found.properties(row, col), 'String', '', 'UserData', ud);
            end
        end
    end
    dims = length(s.hg.found.fields);
    for row = 1:dims
        set(s.hg.found.fields(row), 'String', '');
    end

%---------------------------------------------------------------------------------------
% Performs any cleanup invloved in cancelling a search.
%---------------------------------------------------------------------------------------
function cancel_l
    % get the figure
    fig = find_figure_l;

    % clear the activeID
    sf('SnRActiveId', 0);

    % Be robust to lost figure
    if fig & ishandle(fig)
        % set the figure to be idle
        set_idle_l;

        % hide the figure
        set(fig, 'Visible', 'off');
    end;



%---------------------------------------------------------------------------------------
% Help!
%---------------------------------------------------------------------------------------
function help_l
    sfhelp('replace');


%---------------------------------------------------------------------------------------
% Modifies the search options.
%---------------------------------------------------------------------------------------
function set_option_l
    % get the figure
    fig = find_figure_l;

    % get the figure's user data
    s = get(fig, 'UserData');

    % get the value of the search options popup
    option = get(s.hg.options.searchOption, 'Value');

    % inject the proper event
    switch option,
    case 1,
        sf_snr_inject_event('matchWord');
    case 2,
        sf_snr_inject_event('containsWord');
    case 3,
        sf_snr_inject_event('regExp');
    end


%---------------------------------------------------------------------------------------
% Toggles the visibility of the fields section.  Use with no arguments to hide
% Parameters:
%   fields      bitfield offield types
% Bitfield:
%   1           true for searching to include labels
%   2           true for searching to include names
%   3           true for searching to include descriptions
%   4           true for searching to include document links
%   5           true for searching to include custom code
%---------------------------------------------------------------------------------------
function fields_toggle_l(varargin)
    % get the figure
    fig = find_figure_l;

    % get the figure's user data
    s = get(fig, 'UserData');

    switch nargin,
    case 1,
        % generate the fields String
        comma = 0;
        string = '';

        % decompose the fields
        fields = pad_dec2bin_l(varargin{1}, s.gp.numFields);

        if fields(2)
            string = 'Names';
            comma = 1;
        end
        if fields(1)
            if comma
                string = [string, ', '];
            end
            string = [string, 'Labels'];
            comma = 1;
        end
        if fields(3)
            if comma
                string = [string, ', '];
            end
            string = [string, 'Descriptions'];
            comma = 1;
        end
        if fields(4)
            if comma
                string = [string, ', '];
            end
            string = [string, 'Document links'];
            comma = 1;
        end
        if fields(5)
            if comma
                string = [string, ', '];
            end
            string = [string, 'Custom code'];
        end

        % set the fields string
        set(s.hg.fieldsHide.selected, 'String', string);

        % toggle the arrow
        set(s.hg.fieldsToggle, 'String', '>');

        % set the blanket to be visible
        set(s.hg.fieldsHide.label, 'Visible', 'on');
        set(s.hg.fieldsHide.selected, 'Visible', 'on');

        % set the boxes to be invisible
        set(s.hg.fieldsShow.frame, 'Visible', 'off');
        set(s.hg.fieldsShow.labels, 'Visible', 'off');
        set(s.hg.fieldsShow.names, 'Visible', 'off');
        set(s.hg.fieldsShow.descriptions, 'Visible', 'off');
        set(s.hg.fieldsShow.documents, 'Visible', 'off');
        set(s.hg.fieldsShow.customCode, 'Visible', 'off');
   case 0,
        % toggle the arrow
        set(s.hg.fieldsToggle, 'String', '<');

        % set the blanket to be invisible
        set(s.hg.fieldsHide.label, 'Visible', 'off');
        set(s.hg.fieldsHide.selected, 'Visible', 'off');

        % set the boxes to be visible
        set(s.hg.fieldsShow.frame, 'Visible', 'on');
        set(s.hg.fieldsShow.labels, 'Visible', 'on');
        set(s.hg.fieldsShow.names, 'Visible', 'on');
        set(s.hg.fieldsShow.descriptions, 'Visible', 'on');
        set(s.hg.fieldsShow.documents, 'Visible', 'on');
        set(s.hg.fieldsShow.customCode, 'Visible', 'on');
    end


%---------------------------------------------------------------------------------------
% Toggles the visibility of the types section.  Use with no arguments to hide
% Parameters:
%   types       bitfield of search types
% Bitfield:
%   1           true for searching to include states
%   2           true for searching to include charts
%   3           true for searching to include junctions
%   4           true for searching to include transitions
%   5           true for searching to include data
%   6           true for searching to include events
%   7           true for searching to include targets
%---------------------------------------------------------------------------------------
function types_toggle_l(varargin)
    % get the figure
    fig = find_figure_l;

    % get the figure's user data
    s = get(fig, 'UserData');

    switch nargin,
    case 1,
        % generate the fields String
        comma = 0;
        string = '';

        % decompose the types
        types = pad_dec2bin_l(varargin{1}, s.gp.numTypes);

        if types(1)
            string = 'Machine';
            comma = 1;
        end
        if types(8)
            if comma
                string = [string, ', '];
            end
            string = [string, 'Targets'];
            comma = 1;
        end
        if types(3)
            if comma
                string = [string, ', '];
            end
            string = [string, 'Charts'];
            comma = 1;
        end
        if types(2)
            if comma
                string = [string, ', '];
            end
            string = [string, 'States'];
            comma = 1;
        end
        if types(4)
            if comma
                string = [string, ', '];
            end
            string = [string, 'Junctions'];
            comma = 1;
        end
        if types(5)
            if comma
                string = [string, ', '];
            end
            string = [string, 'Transitions'];
            comma = 1;
        end
        if types(6)
            if comma
                string = [string, ', '];
            end
            string = [string, 'Data'];
            comma = 1;
        end
        if types(7)
            if comma
                string = [string, ', '];
            end
            string = [string, 'Events'];
        end

        % set the types string
        set(s.hg.typesHide.selected, 'String', string);

        % toggle the arrow
        set(s.hg.typesToggle, 'String', '>');

        % set the blanket to be visible
        set(s.hg.typesHide.label, 'Visible', 'on');
        set(s.hg.typesHide.selected, 'Visible', 'on');

        % set the boxes to be invisible
        set(s.hg.typesShow.frame, 'Visible', 'off');
        set(s.hg.typesShow.states, 'Visible', 'off');
        set(s.hg.typesShow.charts, 'Visible', 'off');
        set(s.hg.typesShow.junctions, 'Visible', 'off');
        set(s.hg.typesShow.transitions, 'Visible', 'off');
        set(s.hg.typesShow.data, 'Visible', 'off');
        set(s.hg.typesShow.events, 'Visible', 'off');
        set(s.hg.typesShow.targets, 'Visible', 'off');
        set(s.hg.typesShow.machine, 'Visible', 'off');
   case 0,
        % toggle the arrow
        set(s.hg.typesToggle, 'String', '<');

        % set the blanket to be invisible
        set(s.hg.typesHide.label, 'Visible', 'off');
        set(s.hg.typesHide.selected, 'Visible', 'off');

        % set the boxes to be visible
        set(s.hg.typesShow.frame, 'Visible', 'on');
        set(s.hg.typesShow.states, 'Visible', 'on');
        set(s.hg.typesShow.charts, 'Visible', 'on');
        set(s.hg.typesShow.junctions, 'Visible', 'on');
        set(s.hg.typesShow.transitions, 'Visible', 'on');
        set(s.hg.typesShow.data, 'Visible', 'on');
        set(s.hg.typesShow.events, 'Visible', 'on');
        set(s.hg.typesShow.targets, 'Visible', 'on');
        set(s.hg.typesShow.machine, 'Visible', 'on');
    end


%---------------------------------------------------------------------------------------
% Populates the search scope selections
% Parameters:
%   id          the id to select (optional)
%---------------------------------------------------------------------------------------
function set_scope_l (varargin)
    % get the figure
    fig = find_figure_l;

    % get the figure's user data
    s = get(fig, 'UserData');

    % get a list of open machines
    s.sp.machines = sf('MachinesOf', 0);

    % clear everything if there are no machines
    if (isempty(s.sp.machines))
        % reset the title
        set(fig, 'Name', 'Search & Replace');

        % clear all the info from the uicontrol
        set(s.hg.scope, 'UserData', 0, 'Value', 1, 'String', ' ');

        % set the modified user data to the figure
        set(fig, 'UserData', s);

        if (nargin == 1)
            % notify the user that there are no machines loaded
            toss_warning_l('warning', 'There are no open machines to search');
        end

        return;
    end

    % flag for expanding the charts of the machine
    s.sp.expand = 1;

    CHART = sf('get', 'default','chart.isa');
    MACHINE = sf('get', 'default','machine.isa');

    % get the selection
    if (nargin == 1)
        selected = varargin{1};
    else
        ids = get(s.hg.scope, 'UserData');
        value = get(s.hg.scope, 'Value');
        selected = ids(value);
        strings = get(s.hg.scope, 'String');
        if ids
            oldSelection = strings{value};
            if (oldSelection(1) == '-')
                s.sp.expand = 0;
            end
            if (check_handle_l(selected, 'machine') | check_handle_l(selected, 'chart'))
                sf('SnRActiveId', selected);
            else
                selected = sf('SnRActiveId');
            end
        end
    end

    if (~selected)
        selected = s.sp.machines(1);
        sf('SnRActiveId', selected);
    end

    type = sf('get', selected, '.isa');

    switch type,
    case CHART,
        s.sp.machine = sf('get', selected, '.machine');
        typeName = 'chart';
    case MACHINE,
        s.sp.machine = selected;
        typeName = 'machine';
    otherwise,
        error('Bad object type passed to sfsnr()');
    end;

    % reset the title
    set(fig, 'Name', ['Search & Replace (' typeName ') ' sf('FullNameOf', selected, '.')]);

    % get the list of charts
    if (s.sp.expand)
        s.sp.charts = sf('get', s.sp.machine, '.charts');
    else
        s.sp.charts = [];
    end

    % the index of the machine to expand
    index = find(s.sp.machines==s.sp.machine);

    % the numbers of charts and machines
    chartNum = length(s.sp.charts);
    machineNum = length(s.sp.machines);

    % list of names
    chartNames = sf('get', s.sp.charts, '.name');
    machineNames = sf('get', s.sp.machines, '.name');

    % change non-space whitespace to spaces
    chartNames(isspace(chartNames)) = ' ';
    machineNames(isspace(machineNames)) = ' ';

    % pad the chart names with some spaces
    tab = '   ';
    chartNames = [tab(ones(1,chartNum), :) chartNames];

    % pad the machine names with +
    expander = '+ ';
    machineNames = [expander(ones(1,machineNum), :) machineNames];

    if (s.sp.expand)
        % change the open machine's expander to -
        machineNames(index,1:2) = '- ';
    end

    % convert to cell arrays
    chartNames = reshape(num2cell(chartNames, 2), 1, chartNum);
    machineNames = reshape(num2cell(machineNames, 2), 1, machineNum);

    % the list of ids with the charts expanded for machine
    ids = [s.sp.machines(1:index) s.sp.charts s.sp.machines(index+1:machineNum)];

    % the list of names to parallel the above
    names = [machineNames(1:index) chartNames machineNames(index+1:machineNum)];

    % the index of the selected id
    value = find(ids==selected);

    % set all the info into the uicontrol
    set(s.hg.scope, 'UserData', ids, 'Value', value, 'String', names);

    % set the modified user data to the figure
    set(fig, 'UserData', s);


%---------------------------------------------------------------------------------------
% Initialises/draws the GUI
%---------------------------------------------------------------------------------------
function response = init_GUI_l()

    % security through obscurity
    TAG = 'SF_SNR';

    % see if there already is a figure
    fig = find_figure_l;

    if fig
        s = get(fig, 'UserData');
        if ~check_handle_l(s.portal, 'portal')
            s.portal = create_portal_l(fig, s.gp.portalVisible);
            set(fig, 'UserData', s);
            resize_l;
        end
        yank_blanket_l;
        response = fig;
        return;
    end

    % initialize the last search
    s.sp.searchExpr = '';
    s.sp.topId = 0;
    s.sp.totalRows = 0;
    s.sp.offset = 0;

    % initialize the warning and info strings
    s.sp.warn = '';
    s.sp.info = '';

    % screen size etiqette
    units = 'points';
    screenUnits = get(0, 'Units');
    set(0, 'Units', units);
    screenSize = get(0, 'ScreenSize');
    set(0, 'Units', screenUnits);

    % get the UIControl background color so the figure can match it
    backgroundColor = get(0, 'DefaultUIControlBackgroundColor');

    % read in icon data
    s.id.machine = load_icon_l('machine.bmp', backgroundColor);
    s.id.target = load_icon_l('target.bmp', backgroundColor);
    s.id.chart = load_icon_l('chart.bmp', backgroundColor);
    s.id.state = load_icon_l('state.bmp', backgroundColor);
    s.id.box = load_icon_l('box.bmp', backgroundColor);
    s.id.note = load_icon_l('note.bmp', backgroundColor);
    s.id.func = load_icon_l('function.bmp', backgroundColor);
    s.id.substate = load_icon_l('substate.bmp', backgroundColor);
    s.id.subbox = load_icon_l('subbox.bmp', backgroundColor);
    s.id.subfunc = load_icon_l('subfunc.bmp', backgroundColor);
    s.id.junction = load_icon_l('junction.bmp', backgroundColor);
    s.id.transition = load_icon_l('transition.bmp', backgroundColor);
    s.id.data = load_icon_l('data.bmp', backgroundColor);
    s.id.event = load_icon_l('event.bmp', backgroundColor);
    s.id.warn = load_icon_l('warning.bmp', backgroundColor);
    s.id.info = load_icon_l('info.bmp', backgroundColor);


    % define graphics parametrically
    s.gp.buttonWidth = 50;
    s.gp.textWidth = 60;
    s.gp.optionWidth = 100;
    s.gp.toggleWidth = 10;

    s.gp.UIControlHeight = 20;
    s.gp.iconSize = 14;

    fontSize = get(0, 'DefaultTextFontSize');
    fontGap = round(fontSize/5);
    s.gp.foundRows = 4;
    s.gp.foundTextHeight = fontSize + fontGap;
    s.gp.foundObjectHeight = s.gp.foundRows * s.gp.foundTextHeight + fontGap;
    s.gp.foundObjectHeightMinimum = 2 * s.gp.foundTextHeight + fontGap;
    s.gp.replaceThisWidth = 100;
    s.gp.foundFieldWidth =80;

    portalHeight = 150;
    s.gp.portalHeightMinimum = 10;

    editWidthDefault = 200;
    editWidthMinimum = 10;

    % the generic length for greyspace
    s.gp.buffer = 4;

    % default values for dragging
    s.gp.dragStart = 0;
    s.gp.setRows = s.gp.foundRows;

    % default figure size
    figureHeight = 6*s.gp.UIControlHeight+10*s.gp.buffer+s.gp.foundObjectHeight+s.gp.foundTextHeight+portalHeight;
    figureWidth = 5*s.gp.buffer+s.gp.textWidth+editWidthDefault+s.gp.optionWidth+s.gp.buttonWidth;

    % make sure the initial size is less than 90% of the screen in either direction
    figureWidth = min(figureWidth, .9*screenSize(3));
    figureHeight = min(figureHeight, .9*screenSize(4));

    % minimum figure size
    s.gp.minimumHeight = 6*s.gp.UIControlHeight+10*s.gp.buffer+s.gp.foundObjectHeightMinimum+s.gp.foundTextHeight+s.gp.portalHeightMinimum;
    s.gp.minimumWidth = 5*s.gp.buffer+s.gp.textWidth+editWidthMinimum+s.gp.optionWidth+s.gp.buttonWidth;

    dim = get(0, 'DefaultFigurePosition');


    % create a figure
    fig = figure('doubleBuffer', 'on',...
                 'MenuBar', 'none',...
                 'Name', 'Search & Replace',...
                 'Tag', TAG,...
                 'NumberTitle', 'off',...
                 'Visible', 'off',...
                 'HandleVisibility', 'off',...
                 'IntegerHandle', 'off',...
                 'Color', backgroundColor,...
                 'Units', units,...
                 'DefaultUIControlUnits', units,...
                 'ResizeFcn', 'sf(''Private'', ''sfsnr'', ''resize'');',...
                 'KeyPressFcn', 'sf(''Private'', ''sfsnr'', ''key_press'');',...
                 'WindowButtonDownFcn', 'sf(''Private'', ''sf_snr_inject_event'', ''mouse_down'');',...
                 'WindowButtonUpFcn', 'sf(''Private'', ''sf_snr_inject_event'', ''mouse_up'');',...
                 'WindowButtonMotionFcn', 'sf(''Private'', ''sf_snr_inject_event'', ''mouse_moved'');',...
                 'CloseRequestFcn', 'sf(''Private'', ''sfsnr'', ''cancel'');',...
                 'Position', [(screenSize(3)-figureWidth)/2 (screenSize(4)-figureHeight)/2 figureWidth figureHeight]);

    % set the figure
    find_figure_l(fig);

    % set the figure's self reference
    s.hg.fig = fig;

    % ---Axes-------------------------------------------------------------------------------------------------
    s.hg.axes = axes(                   'Parent',               fig,...
                                        'visible',              'off',...
                                        'position',             [0 0 1 1]);


    % ---Context-Menu-----------------------------------------------------------------------------------------
    s.hg.contextMenu = uicontextmenu(   'Parent',               fig);

    s.hg.showPortal = uimenu(           'Parent',               s.hg.contextMenu,...
                                        'Label',                'Show portal',...
                                        'Callback',             'sf(''Private'', ''sfsnr'', ''toggle_portal'');',...
                                        'Checked',              'on');

    s.hg.viewItem = uimenu(             'Parent',               s.hg.contextMenu,...
                                        'Label',                'Edit',...
                                        'Callback',             'sf(''Private'', ''sf_snr_inject_event'', ''view'');',...
                                        'Enable',               'off');

    s.hg.exploreItem = uimenu(          'Parent',               s.hg.contextMenu,...
                                        'Label',                'Explore',...
                                        'Callback',             'sf(''Private'', ''sf_snr_inject_event'', ''explore'');',...
                                        'Enable',               'off');

    s.hg.editProperties = uimenu(       'Parent',               s.hg.contextMenu,...
                                        'Label',                'Properties',...
                                        'Callback',             'sf(''Private'', ''sf_snr_inject_event'', ''properties'');',...
                                        'Enable',               'off');


    % ---Buttons----------------------------------------------------------------------------------------------
    s.hg.searchButton = uicontrol(      'String',               sprintf('Search'),...
                                        'Parent',               fig,...
                                        'Style',                'pushbutton',...
                                        'CallBack',             'sf(''Private'', ''sf_snr_inject_event'', ''search'');');

    s.hg.replaceButton = uicontrol(     'String',               sprintf('Replace'),...
                                        'Parent',               fig,...
                                        'Style',                'pushbutton',...
                                        'CallBack',             'sf(''Private'', ''sf_snr_inject_event'', ''replace'');');

    s.hg.replaceAllButton = uicontrol(  'String',               sprintf('Replace all'),...
                                        'Parent',               fig,...
                                        'Style',                'pushbutton',...
                                        'CallBack',             'sf(''Private'', ''sf_snr_inject_event'', ''replaceAll'');');

    s.hg.helpButton = uicontrol(        'String',               'Help',...
                                        'Parent',               fig,...
                                        'Style',                'pushbutton',...
                                        'CallBack',             'sf(''Private'', ''sf_snr_inject_event'', ''help'');');

    s.hg.cancelButton = uicontrol(      'String',               'Close',...
                                        'Parent',               fig,...
                                        'Style',                'pushbutton',...
                                        'CallBack',             'sf(''Private'', ''sfsnr'', ''cancel'');');


    % ---String-Inputs----------------------------------------------------------------------------------------
    s.hg.searchString = uicontrol(      'Style',                'edit',...
                                        'Parent',               fig,...
                                        'HorizontalAlignment',  'Left',...
                                        'BackgroundColor',      'white');

    s.hg.replaceString = uicontrol(     'Style',                'edit',...
                                        'Parent',               fig,...
                                        'HorizontalAlignment',  'Left',...
                                        'BackgroundColor',      'white');


    % ---String-Labels----------------------------------------------------------------------------------------
    s.hg.searchLabel = text(            [0], [0], sprintf('Search for:'),...
                                        'Parent',               s.hg.axes,...
                                        'Interpreter',          'none',...
                                        'VerticalAlignment',    'Middle',...
                                        'Clipping',             'off',...
                                        'FontSize',             fontSize-1,...
                                        'HorizontalAlignment',  'Left');

    s.hg.replaceLabel = text(           [0], [0], sprintf('Replace with:'),...
                                        'Parent',               s.hg.axes,...
                                        'Interpreter',          'none',...
                                        'VerticalAlignment',    'Middle',...
                                        'Clipping',             'off',...
                                        'FontSize',             fontSize-1,...
                                        'HorizontalAlignment',  'Left');


    s.hg.scopeLabel = text(             [0], [0], sprintf('Search in:'),...
                                        'Parent',               s.hg.axes,...
                                        'Interpreter',          'none',...
                                        'VerticalAlignment',    'Middle',...
                                        'Clipping',             'off',...
                                        'FontSize',             fontSize-1,...
                                        'HorizontalAlignment',  'Left');


    % ---Search-Scope-----------------------------------------------------------------------------------------
    s.hg.scope = uicontrol('Style',     'popupmenu',...
                                        'Parent',               fig,...
                                        'Visible',              'on',...
                                        'BackgroundColor',      'white',...
                                        'HorizontalAlignment',  'Left',...
                                        'FontName',             'FixedWidth',...
                                        'String',               {sprintf('temp')},...
                                        'UserData',             0,...
                                        'CallBack',             'sf(''Private'', ''sfsnr'', ''set_scope'');');

    % ---Search-Options---------------------------------------------------------------------------------------
    s.gp.numOptions = 4;

    s.hg.options.searchOption = uicontrol('Style',              'popupmenu',...
                                        'Parent',               fig,...
                                        'Visible',              'on',...
                                        'BackgroundColor',      'white',...
                                        'HorizontalAlignment',  'Left',...
                                        'String',               {sprintf('Match whole word'), sprintf('Contains word'), sprintf('Regular expression')},...
                                        'Value',                2,...
                                        'CallBack',             'sf(''Private'', ''sfsnr'', ''set_option'');');


    s.hg.options.matchCase = uicontrol('Style',             'checkbox',...
                                        'Parent',               fig,...
                                        'Visible',              'on',...
                                        'HorizontalAlignment',  'Left',...
                                        'String',               sprintf('Match case'),...
                                        'TooltipString',        sprintf('Match case'),...
                                        'CallBack',             'sf(''Private'', ''sf_snr_inject_event'', ''matchCase'');');


    s.hg.options.preserveCase = uicontrol('Style',          'checkbox',...
                                        'Parent',               fig,...
                                        'Visible',              'on',...
                                        'HorizontalAlignment',  'Left',...
                                        'String',               sprintf('Preserve case'),...
                                        'TooltipString',        sprintf('Preserve case'),...
                                        'CallBack',             'sf(''Private'', ''sf_snr_inject_event'', ''preserveCase'');');


    % ---Field-Types------------------------------------------------------------------------------------------
    s.gp.numFields = 5;

    s.hg.fieldsShow.frame = uicontrol(  'Style',                'frame',...
                                        'Parent',               fig,...
                                        'Visible',              'off',...
                                        'ForegroundColor',      'white');

    s.hg.fieldsShow.labels = uicontrol( 'Style',                'checkbox',...
                                        'Parent',               fig,...
                                        'Visible',              'off',...
                                        'HorizontalAlignment',  'Left',...
                                        'String',               sprintf('Labels'),...
                                        'TooltipString',        sprintf('Labels'),...
                                        'CallBack',             'sf(''Private'', ''sf_snr_inject_event'', ''labels'');');

    ex = get(s.hg.fieldsShow.labels, 'Extent');
    s.gp.fieldsShow.labels.width = ex(3);
    s.gp.fieldsShow.width = ex(3);

    s.hg.fieldsShow.names = uicontrol(  'Style',                'checkbox',...
                                        'Parent',               fig,...
                                        'Visible',              'off',...
                                        'HorizontalAlignment',  'Left',...
                                        'String',               sprintf('Names'),...
                                        'TooltipString',        sprintf('Names'),...
                                        'CallBack',             'sf(''Private'', ''sf_snr_inject_event'', ''names'');');

    ex = get(s.hg.fieldsShow.names, 'Extent');
    s.gp.fieldsShow.names.width = ex(3);
    s.gp.fieldsShow.width = s.gp.fieldsShow.width + s.gp.buffer + ex(3);

    s.hg.fieldsShow.descriptions = uicontrol( 'Style',          'checkbox',...
                                        'Parent',               fig,...
                                        'Visible',              'off',...
                                        'HorizontalAlignment',  'Left',...
                                        'String',               sprintf('Descriptions'),...
                                        'TooltipString',        sprintf('Descriptions'),...
                                        'CallBack',             'sf(''Private'', ''sf_snr_inject_event'', ''descriptions'');');

    ex = get(s.hg.fieldsShow.descriptions, 'Extent');
    s.gp.fieldsShow.descriptions.width = ex(3);
    s.gp.fieldsShow.width = s.gp.fieldsShow.width + s.gp.buffer + ex(3);

    s.hg.fieldsShow.documents = uicontrol( 'Style',              'checkbox',...
                                        'Parent',               fig,...
                                        'Visible',              'off',...
                                        'HorizontalAlignment',  'Left',...
                                        'String',               sprintf('Document links'),...
                                        'TooltipString',        sprintf('Document links'),...
                                        'CallBack',             'sf(''Private'', ''sf_snr_inject_event'', ''document'');');

    ex = get(s.hg.fieldsShow.documents, 'Extent');
    s.gp.fieldsShow.documents.width = ex(3);
    s.gp.fieldsShow.width = s.gp.fieldsShow.width + s.gp.buffer + ex(3);

    s.hg.fieldsShow.customCode = uicontrol( 'Style',            'checkbox',...
                                        'Parent',               fig,...
                                        'Visible',              'off',...
                                        'HorizontalAlignment',  'Left',...
                                        'String',               sprintf('Custom code'),...
                                        'TooltipString',        sprintf('Custom code'),...
                                        'CallBack',             'sf(''Private'', ''sf_snr_inject_event'', ''customCode'');');

    ex = get(s.hg.fieldsShow.customCode, 'Extent');
    s.gp.fieldsShow.customCode.width = ex(3);
    s.gp.fieldsShow.width = s.gp.fieldsShow.width + s.gp.buffer + ex(3);

    s.hg.fieldsHide.label = uicontrol(  'Style',                'text',...
                                        'Parent',               fig,...
                                        'HorizontalAlignment',  'Left',...
                                        'FontWeight',           'bold',...
                                        'String',               sprintf('Field types:'));

    s.hg.fieldsHide.selected = uicontrol('Style',                'text',...
                                        'Parent',               fig,...
                                        'HorizontalAlignment',  'Left',...
                                        'String',               '');

    s.hg.fieldsToggle = uicontrol(      'Style',                'pushbutton',...
                                        'Parent',               fig,...
                                        'Visible',              'on',...
                                        'String',               '>',...
                                        'Callback',             'sf(''Private'', ''sf_snr_inject_event'', ''fieldsToggle'');');



    % ---Type-Types------------------------------------------------------------------------------------------
    s.gp.numTypes = 8;

    s.hg.typesShow.frame = uicontrol(   'Style',                'frame',...
                                        'Parent',               fig,...
                                        'Visible',              'off',...
                                        'ForegroundColor',      'white');

    s.hg.typesShow.machine = uicontrol( 'Style',                'checkbox',...
                                        'Parent',               fig,...
                                        'Visible',              'off',...
                                        'HorizontalAlignment',  'Left',...
                                        'String',               sprintf('Machine'),...
                                        'TooltipString',        sprintf('Machine'),...
                                        'CallBack',             'sf(''Private'', ''sf_snr_inject_event'', ''machine'');');

    ex = get(s.hg.typesShow.machine, 'Extent');
    s.gp.typesShow.machine.width = ex(3);
    s.gp.typesShow.width = ex(3);

    s.hg.typesShow.states = uicontrol(  'Style',                'checkbox',...
                                        'Parent',               fig,...
                                        'Visible',              'off',...
                                        'HorizontalAlignment',  'Left',...
                                        'String',               sprintf('States'),...
                                        'TooltipString',        sprintf('States'),...
                                        'CallBack',             'sf(''Private'', ''sf_snr_inject_event'', ''states'');');

    ex = get(s.hg.typesShow.states, 'Extent');
    s.gp.typesShow.states.width = ex(3);
    s.gp.typesShow.width = s.gp.typesShow.width + s.gp.buffer + ex(3);

    s.hg.typesShow.charts = uicontrol(  'Style',                'checkbox',...
                                        'Parent',               fig,...
                                        'Visible',              'off',...
                                        'HorizontalAlignment',  'Left',...
                                        'String',               sprintf('Charts'),...
                                        'TooltipString',        sprintf('Charts'),...
                                        'CallBack',             'sf(''Private'', ''sf_snr_inject_event'', ''charts'');');

    ex = get(s.hg.typesShow.charts, 'Extent');
    s.gp.typesShow.charts.width = ex(3);
    s.gp.typesShow.width = s.gp.typesShow.width + s.gp.buffer + ex(3);

    s.hg.typesShow.junctions = uicontrol('Style',               'checkbox',...
                                        'Parent',               fig,...
                                        'Visible',              'off',...
                                        'HorizontalAlignment',  'Left',...
                                        'String',               sprintf('Junctions'),...
                                        'TooltipString',        sprintf('Junctions'),...
                                        'CallBack',             'sf(''Private'', ''sf_snr_inject_event'', ''junctions'');');

    ex = get(s.hg.typesShow.junctions, 'Extent');
    s.gp.typesShow.junctions.width = ex(3);
    s.gp.typesShow.width = s.gp.typesShow.width + s.gp.buffer + ex(3);

    s.hg.typesShow.transitions = uicontrol('Style',             'checkbox',...
                                        'Parent',               fig,...
                                        'Visible',              'off',...
                                        'HorizontalAlignment',  'Left',...
                                        'String',               sprintf('Transitions'),...
                                        'TooltipString',        sprintf('Transitions'),...
                                        'CallBack',             'sf(''Private'', ''sf_snr_inject_event'', ''transitions'');');

    ex = get(s.hg.typesShow.transitions, 'Extent');
    s.gp.typesShow.transitions.width = ex(3);
    s.gp.typesShow.width = s.gp.typesShow.width + s.gp.buffer + ex(3);

    s.hg.typesShow.data = uicontrol(    'Style',                'checkbox',...
                                        'Parent',               fig,...
                                        'Visible',              'off',...
                                        'HorizontalAlignment',  'Left',...
                                        'String',               sprintf('Data'),...
                                        'TooltipString',        sprintf('Data'),...
                                        'CallBack',             'sf(''Private'', ''sf_snr_inject_event'', ''data'');');

    ex = get(s.hg.typesShow.data, 'Extent');
    s.gp.typesShow.data.width = ex(3);
    s.gp.typesShow.width = s.gp.typesShow.width + s.gp.buffer + ex(3);

    s.hg.typesShow.events = uicontrol(  'Style',                'checkbox',...
                                        'Parent',               fig,...
                                        'Visible',              'off',...
                                        'HorizontalAlignment',  'Left',...
                                        'String',               sprintf('Events'),...
                                        'TooltipString',        sprintf('Events'),...
                                        'CallBack',             'sf(''Private'', ''sf_snr_inject_event'', ''events'');');

    ex = get(s.hg.typesShow.events, 'Extent');
    s.gp.typesShow.events.width = ex(3);
    s.gp.typesShow.width = s.gp.typesShow.width + s.gp.buffer + ex(3);

    s.hg.typesShow.targets= uicontrol(  'Style',                'checkbox',...
                                        'Parent',               fig,...
                                        'Visible',              'off',...
                                        'HorizontalAlignment',  'Left',...
                                        'String',               sprintf('Targets'),...
                                        'TooltipString',        sprintf('Targets'),...
                                        'CallBack',             'sf(''Private'', ''sf_snr_inject_event'', ''targets'');');

    ex = get(s.hg.typesShow.targets, 'Extent');
    s.gp.typesShow.targets.width = ex(3);
    s.gp.typesShow.width = s.gp.typesShow.width + s.gp.buffer + ex(3);

    s.hg.typesHide.label = uicontrol(   'Style',                'text',...
                                        'Parent',               fig,...
                                        'HorizontalAlignment',  'Left',...
                                        'FontWeight',           'bold',...
                                        'String',               sprintf('Object types:'));

    s.hg.typesHide.selected = uicontrol('Style',                'text',...
                                        'Parent',               fig,...
                                        'HorizontalAlignment',  'Left',...
                                        'String',               '');

    s.hg.typesToggle = uicontrol(       'Style',                'pushbutton',...
                                        'Parent',               fig,...
                                        'Visible',              'on',...
                                        'String',               '>',...
                                        'Callback',             'sf(''Private'', ''sf_snr_inject_event'', ''typesToggle'');');



    % ---Found-Object-----------------------------------------------------------------------------------------
    s.hg.found.breakDark = line(        [0 0], [1 1],...
                                        'Parent',               s.hg.axes,...
                                        'color',                'black');

    s.hg.found.breakLight = line(       [0 0], [1 1],...
                                        'Parent',               s.hg.axes,...
                                        'color',                'white');

    s.hg.found.icon = image(            'Visible',              'off',...
                                        'XData',                 1,...
                                        'YData',                 1,...
                                        'Parent',               s.hg.axes);

    s.hg.found.name = text(             [0], [0], '',...
                                        'UserData',             '',...
                                        'Color',                'blue',...
                                        'ButtonDownFcn',        'sf(''Private'', ''sf_snr_inject_event'', ''view'');',...
                                        'Parent',               s.hg.axes,...
                                        'Interpreter',          'none',...
                                        'FontWeight',           'Bold');

    s.hg.found.replaceThis = uicontrol( 'String',               sprintf('Replace all in this object'),...
                                        'Parent',               fig,...
                                        'Style',                'pushbutton',...
                                        'CallBack',             'sf(''Private'', ''sf_snr_inject_event'', ''replaceThis'');');

    pa.height = s.gp.foundObjectHeight;
    pa.width = 1;
    pa.offset = 0;
    s.hg.found.propertiesAxes = axes(   'Color',               'white',...
                                        'Parent',               fig,...
                                        'units',                units,...
                                        'visible',              'on',...
                                        'gridlineStyle',        'none',...
                                        'XTick',                [],...
                                        'YTick',                [],...
                                        'XLim',                 [0 1],...
                                        'YLim',                 [0 s.gp.foundObjectHeight],...
                                        'UserData',             pa);

    s.hg.found.propertiesDark = line(   [0 0], [1 1],...
                                        'Parent',               s.hg.axes,...
                                        'color',                'black');

    s.hg.found.propertiesLight = line(  [0 0], [1 1],...
                                        'Parent',               s.hg.axes,...
                                        'color',                'white');

    s.hg.found.fieldsGreyArea = rectangle('FaceColor',          [.9 .9 .9],...
                                        'Visible',              'on',...
                                        'EdgeColor',            'none',...
                                        'Clipping',             'on',...
                                        'Parent',               s.hg.found.propertiesAxes);

    s.hg.found.conditionsGreyArea = rectangle('FaceColor',      [.9 .9 .9],...
                                        'Visible',              'off',...
                                        'EdgeColor',            'none',...
                                        'Clipping',             'on',...
                                        'Parent',               s.hg.found.propertiesAxes);

    s.hg.found.actionsGreyArea = rectangle('FaceColor',         [.9 .9 .9],...
                                        'Visible',              'off',...
                                        'EdgeColor',            'none',...
                                        'Clipping',             'on',...
                                        'Parent',               s.hg.found.propertiesAxes);

    s.hg.found.sliderV = uicontrol(     'Style',                'slider',...
                                        'Parent',               fig,...
                                        'Enable',              'off',...
                                        'CallBack',             'sf(''Private'', ''sfsnr'', ''slide_v'');');

    s.hg.found.sliderH = uicontrol(     'Style',                'slider',...
                                        'Parent',               fig,...
                                        'Enable',              'off',...
                                        'CallBack',             'sf(''Private'', ''sfsnr'', ''slide_h'');');

    s.hg.found.match = rectangle(       'FaceColor',            'black',...
                                        'EraseMode',            'xor',...
                                        'Visible',              'off',...
                                        'EdgeColor',            'none',...
                                        'Clipping',             'on',...
                                        'UserData',             [],...
                                        'Parent',               s.hg.found.propertiesAxes);

    s.hg.found.dragLine = uicontrol(    'Style',                'text',...
                                        'Parent',               fig,...
                                        'ButtonDownFcn',        '',...
                                        'CallBack',             '',...
                                        'Enable',               'off',...
                                        'Visible',              'off',...
                                        'BackgroundColor',      'black');

    s.hg.found.properties = [];
    s.hg.found.fields = [];
    s.hg.found.activeHighlights = [];


    % ---Portal-----------------------------------------------------------------------------------------------

    s.gp.portalVisible = 1;

    s.portal = create_portal_l(fig, s.gp.portalVisible);

    s.hg.portal.borderDark = line(      [0 0], [1 1],...
                                        'Parent',               s.hg.axes,...
                                        'color',                'black');

    s.hg.portal.borderLight = line(     [0 0], [1 1],...
                                        'Parent',               s.hg.axes,...
                                        'color',                'white');


    % ---Blanket----------------------------------------------------------------------------------------------

    s.hg.blanket = uicontrol(           'Style',                'pushbutton',...
                                        'Parent',               fig,...
                                        'Visible',              'off',...
                                        'FontWeight',           'bold',...
                                        'String',               sprintf('The window is too small'));


    % --------------------------------------------------------------------------------------------------------

    % set the figure's userdata
    set(fig, 'UserData', s);

    % call the resize function
    resize_l;

    response = fig;


%---------------------------------------------------------------------------------------
% Resets the text in the found object panel to reflect the position of the vertical slider
%---------------------------------------------------------------------------------------
function slide_v_l
    % get the figure
    fig = find_figure_l;

    % get the figure's user data
    s = get(fig, 'UserData');

    % get the current vertical slider value
    slide = round(get(s.hg.found.sliderV, 'Value'));

    % Kludge the focus
    set(s.hg.found.sliderV, 'Enable', 'off');
    set(s.hg.found.sliderV, 'Enable', 'on');

    % set the new Y range
    set(s.hg.found.propertiesAxes, 'YLim', [slide*s.gp.foundTextHeight-s.gp.foundObjectHeight slide*s.gp.foundTextHeight]);


%---------------------------------------------------------------------------------------
% Resets the text in the found object panel to reflect the position of the horizontal slider
%---------------------------------------------------------------------------------------
function slide_h_l
    % get the figure
    fig = find_figure_l;

    % get the figure's user data
    s = get(fig, 'UserData');

    % get the current horizontal slider value
    slide = round(get(s.hg.found.sliderH, 'Value'));

    % Kludge the focus
    set(s.hg.found.sliderH, 'Enable', 'off');
    set(s.hg.found.sliderH, 'Enable', 'on');

    % get the old X range
    xl = XLim(s.hg.found.propertiesAxes);

    % set the new X range
    xl = [xl(1)-xl(2)+slide slide];
    set(s.hg.found.propertiesAxes, 'XLim', xl);


%---------------------------------------------------------------------------------------
% Sets the visibility of the portal pane
% Parameters:
%   s           The data structure holding the graphics info
%   visibility  'on' to show, 'off' to hide
% Returns:
%   s           With a possible change to the portal visibility
%---------------------------------------------------------------------------------------
function s = toggle_portal_l(s, visibility)
    if s.gp.portalVisible ~= strcmp(visibility, 'on')
        s.gp.portalVisible = ~s.gp.portalVisible;

        sf('set', s.portal, '.visible', s.gp.portalVisible);

        set(s.hg.portal.borderDark, 'Visible', visibility);
        set(s.hg.portal.borderLight, 'Visible', visibility);
        set(s.hg.showPortal, 'Checked', visibility);
    end


%---------------------------------------------------------------------------------------
% Wrapper function for toggle portal.  Makes it a genuine toggle function.
%---------------------------------------------------------------------------------------
function toggle_portal_wrapper_l
    % get the figure
    fig = find_figure_l;

    % get the figure's user data
    s = get(fig, 'UserData');

    % get the figure's position
    position = get(fig, 'Position');

    % get the portal's position
    viewRect = sf('get', s.portal, '.viewRect');

    % calculate the change in size
    deltaY = viewRect(4) + s.gp.buffer;

    if s.gp.portalVisible
        s = toggle_portal_l(s, 'off');
        deltaY = -1 * deltaY;
    else
        s = toggle_portal_l(s, 'on');
    end

    position(2) = position(2) - deltaY;
    position(4) = position(4) + deltaY;

    set(fig, 'UserData', s, 'Position', position);

    resize_l;


%---------------------------------------------------------------------------------------
% Determines if point is over the specified region
% Parameters:
%   region      The region to check
% Returns:
%   true        if point is over the region, false otherwise
%---------------------------------------------------------------------------------------
function response = over_l(region)
    % get the figure
    fig = find_figure_l;

    % get the figure's user data
    s = get(fig, 'UserData');

    % get the current size
    position = get(fig, 'Position');

    currentPoint = get(fig, 'CurrentPoint');
    xPos = currentPoint(1);
    yPos = currentPoint(2);

    response = 0;

    switch region,
    case 'splitter',
        if (yPos < s.gp.portalTop+s.gp.buffer) & ((yPos > s.gp.portalTop & s.gp.portalVisible) | (s.gp.foundRows > 3 & yPos > s.gp.buffer/2 & ~s.gp.portalVisible))
            s.gp.dragStart = yPos;
            set(fig, 'UserData', s);
            response = 1;
        end
    case 'portal',
        if s.gp.portalVisible & (yPos < s.gp.portalTop & yPos > s.gp.buffer & xPos > s.gp.buffer & xPos < position(3)-s.gp.buffer)
            response = 1;
        else
            % this happens a lot, but not too redundantly, so we'll check machines here.
            check_machines_l;
        end
    case 'found',
        if yPos < s.gp.foundPropsYHigh & yPos > s.gp.foundPropsYLow & xPos > s.gp.buffer & xPos < position(3)-s.gp.buffer
            response = 1;
        end
    end


%---------------------------------------------------------------------------------------
% Pops the context menu
%---------------------------------------------------------------------------------------
function pop_menu_l
    % get the figure
    fig = find_figure_l;

    if ~sf('Playback')
        s = get(fig, 'UserData');
        units = get(fig, 'Units');
        set(fig, 'Units', 'pixels');
        currentPoint = get(fig, 'CurrentPoint');
        set(fig, 'Units', units);
        set(s.hg.contextMenu, 'Position', currentPoint, 'Visible', 'on');
    end

%---------------------------------------------------------------------------------------
% Performs any necessary overhead involved in a splitter drag
% Parameters:
%   opaque      true if the drag should be opaque (optional: default = true)
%---------------------------------------------------------------------------------------
function drag_l(varargin)
    % get the figure
    fig = find_figure_l;

    if (nargin == 1)
        opaque = varargin{1};
    else
        opaque = strcmp(get(fig, 'SelectionType'), 'alt');
    end

    % get the figure's user data
    s = get(fig, 'UserData');

    % get point's y position
    currentPoint = get(fig, 'CurrentPoint');
    yPos = currentPoint(2);

    if opaque
        % hide the drag line
        set(s.hg.found.dragLine, 'Visible', 'off');

        % how many rows should be added
        moveRows = round((yPos-s.gp.dragStart)/s.gp.foundTextHeight);

        % the limits to move
        moveRows = min(moveRows, s.gp.foundRows-2);
        moveRows = max(moveRows, -1 * floor(s.gp.portalTop/s.gp.foundTextHeight));

        if ~moveRows
            return;
        end

        s = resize_found_l(moveRows);

        s.gp.setRows = s.gp.foundRows;

        set(fig, 'UserData', s);

        resize_l;
    else
        % get the figure size
        position = get(fig, 'Position');

        % show the drag line
        set(s.hg.found.dragLine, 'Visible', 'on', 'Position', [0, yPos, position(3), 1]);
    end



%---------------------------------------------------------------------------------------
% Changes the size of the found object.
% Parameters:
%   moveRows    The number of rows to adjust (positive or negative)
% Returns:
%   s           The modified user data for the figure which needs to be set
%---------------------------------------------------------------------------------------
function s = resize_found_l(moveRows)
    % get the figure
    fig = find_figure_l;

    % get the figure's user data
    s = get(fig, 'UserData');

    % get the axes user data
    pa = get(s.hg.found.propertiesAxes, 'UserData');

    slide = get(s.hg.found.sliderV, 'Value');
    if ~strcmp(get(s.hg.found.sliderV, 'Enable'), 'on')
        slide = s.sp.totalRows+pa.offset;
    end

    if strcmp(get(s.hg.found.match, 'Visible'), 'on')
        forcePos = get(s.hg.found.match, 'Position');
        forceRow = round(forcePos(2)/s.gp.foundTextHeight);
    else
        forceRow = -1;
    end

    if s.gp.setRows ~= s.gp.foundRows & s.gp.setRows < s.gp.foundRows - moveRows & s.gp.portalVisible
        moveRows = s.gp.foundRows - s.gp.setRows;
    end

    s.gp.foundRows = s.gp.foundRows - moveRows;
    s.gp.foundObjectHeight = s.gp.foundObjectHeight-moveRows*s.gp.foundTextHeight;
    s.gp.dragStart = s.gp.dragStart+moveRows*s.gp.foundTextHeight;

    % get the axes Y range
    yl = ylim(s.hg.found.propertiesAxes);

    yl(1) = yl(1) + moveRows*s.gp.foundTextHeight;
    if yl(1) < 0 & yl(2) < pa.height
        adjust = min(-1*yl(1), pa.height-yl(2));
        yl = yl + adjust;
        slide = min(slide+round(adjust/s.gp.foundTextHeight), s.sp.totalRows)-pa.offset;
    else
        adjust = slide-s.gp.foundRows-forceRow;
        if adjust > 0 & adjust <= moveRows
            yl = yl - adjust*s.gp.foundTextHeight;
            slide = max(slide-adjust, s.gp.foundRows)-pa.offset;
        else
            slide = slide-pa.offset;
        end
    end

    s.gp.portalTop = s.gp.portalTop+moveRows*s.gp.foundTextHeight;
    if s.gp.portalTop >= s.gp.portalHeightMinimum + s.gp.buffer
        s = toggle_portal_l(s, 'on');
    else
        s = toggle_portal_l(s, 'off');
    end

    if s.sp.totalRows > s.gp.foundRows
        set(s.hg.found.sliderV, 'Min',          s.gp.foundRows+pa.offset,...
                                'Max',          s.sp.totalRows+pa.offset,...
                                'Value',        slide+pa.offset,...
                                'Enable',       'on',...
                                'SliderStep',   [1 s.gp.foundRows]/(s.sp.totalRows-s.gp.foundRows));
    else
        set(s.hg.found.sliderV, 'Enable',       'off');
    end

    if s.gp.portalVisible
        s.gp.minimumHeight = 6*s.gp.UIControlHeight+10*s.gp.buffer+s.gp.foundObjectHeightMinimum+s.gp.foundTextHeight+s.gp.portalHeightMinimum;
    else
        s.gp.minimumHeight = 6*s.gp.UIControlHeight+9*s.gp.buffer+s.gp.foundObjectHeightMinimum+s.gp.foundTextHeight;
    end

    set(s.hg.found.propertiesAxes, 'YLim', yl);


%---------------------------------------------------------------------------------------
% Redraws the GUI based on a resize callback
%---------------------------------------------------------------------------------------
function resize_l
    % get the figure
    fig = find_figure_l;

    % get the figure's user data
    s = get(fig, 'UserData');

    % get the current size
    position = get(fig, 'Position');

    % reset the dimensions on the axes
    set(s.hg.axes, 'xlim', [0 position(3)],...
                   'ylim', [0 position(4)]);

    % enforce minumum dimentions
    % position(3) = max(position(3), s.gp.minimumWidth);
    % position(4) = max(position(4), s.gp.minimumHeight);
    if position(3) < s.gp.minimumWidth | position(4) < s.gp.minimumHeight
        set(s.hg.blanket, 'Position', [0 0 position(3) position(4)], 'Visible', 'on');
        set(fig, 'WindowButtonMotionFcn', 'sf(''Private'', ''sfsnr'', ''yank_blanket'');');
        return;
    else
        set(s.hg.blanket, 'Visible', 'off');
        set(fig, 'WindowButtonMotionFcn', 'sf(''Private'', ''sf_snr_inject_event'', ''mouse_moved'');');
    end


    % --------------------------------------------------------------------------------------------------------
    % ---Buttons----------------------------------------------------------------------------------------------
    % --------------------------------------------------------------------------------------------------------
    buttonX = position(3)-s.gp.buffer-s.gp.buttonWidth;
    set(s.hg.searchButton,     'Position', [buttonX position(4)-1*(s.gp.buffer+s.gp.UIControlHeight) s.gp.buttonWidth s.gp.UIControlHeight]);
    set(s.hg.replaceButton,    'Position', [buttonX position(4)-2*(s.gp.buffer+s.gp.UIControlHeight) s.gp.buttonWidth s.gp.UIControlHeight]);
    set(s.hg.replaceAllButton, 'Position', [buttonX position(4)-3*(s.gp.buffer+s.gp.UIControlHeight) s.gp.buttonWidth s.gp.UIControlHeight]);
    set(s.hg.helpButton,       'Position', [buttonX position(4)-4*(s.gp.buffer+s.gp.UIControlHeight) s.gp.buttonWidth s.gp.UIControlHeight]);
    set(s.hg.cancelButton,     'Position', [buttonX position(4)-5*(s.gp.buffer+s.gp.UIControlHeight) s.gp.buttonWidth s.gp.UIControlHeight]);


    % --------------------------------------------------------------------------------------------------------
    % ---Search-Options-----------------------------------------------------------------------------------------
    % --------------------------------------------------------------------------------------------------------
    optionsX = buttonX-s.gp.buffer-s.gp.optionWidth;
    set(s.hg.options.matchCase,    'Position', [optionsX position(4)-1*(s.gp.buffer+s.gp.UIControlHeight) s.gp.optionWidth s.gp.UIControlHeight]);
    set(s.hg.options.preserveCase, 'Position', [optionsX position(4)-2*(s.gp.buffer+s.gp.UIControlHeight) s.gp.optionWidth s.gp.UIControlHeight]);
    set(s.hg.options.searchOption, 'Position', [optionsX position(4)-3*(s.gp.buffer+s.gp.UIControlHeight) s.gp.optionWidth s.gp.UIControlHeight]);


    % --------------------------------------------------------------------------------------------------------
    % ---Search-Strings---------------------------------------------------------------------------------------
    % --------------------------------------------------------------------------------------------------------
    editX = 2*s.gp.buffer+s.gp.textWidth;
    editWidth = optionsX-editX-s.gp.buffer;
    set(s.hg.searchString,  'Position', [editX position(4)-1*(s.gp.buffer+s.gp.UIControlHeight) editWidth s.gp.UIControlHeight]);
    set(s.hg.replaceString, 'Position', [editX position(4)-2*(s.gp.buffer+s.gp.UIControlHeight) editWidth s.gp.UIControlHeight]);
    set(s.hg.scope,         'Position', [editX position(4)-3*(s.gp.buffer+s.gp.UIControlHeight) editWidth s.gp.UIControlHeight]);


    % --------------------------------------------------------------------------------------------------------
    % ---Search-Labels----------------------------------------------------------------------------------------
    % --------------------------------------------------------------------------------------------------------
    set(s.hg.searchLabel,  'Position', [s.gp.buffer position(4)-1*(s.gp.buffer+s.gp.UIControlHeight)+s.gp.UIControlHeight/2]);
    set(s.hg.replaceLabel, 'Position', [s.gp.buffer position(4)-2*(s.gp.buffer+s.gp.UIControlHeight)+s.gp.UIControlHeight/2]);
    set(s.hg.scopeLabel,   'Position', [s.gp.buffer position(4)-3*(s.gp.buffer+s.gp.UIControlHeight)+s.gp.UIControlHeight/2]);


    % --------------------------------------------------------------------------------------------------------
    % ---Field-Types------------------------------------------------------------------------------------------
    % --------------------------------------------------------------------------------------------------------
    fieldRow = 5;
    fieldSlush = (buttonX-4*s.gp.buffer-s.gp.toggleWidth-s.gp.fieldsShow.width)/s.gp.numFields;
    fieldsHideSize = get(s.hg.fieldsHide.label, 'Extent');
    set(s.hg.fieldsToggle,     'Position', [s.gp.buffer   position(4)-fieldRow*(s.gp.buffer+s.gp.UIControlHeight)+1 s.gp.toggleWidth s.gp.UIControlHeight-2]);
    set(s.hg.fieldsShow.frame, 'Position', [s.gp.buffer-1 position(4)-fieldRow*(s.gp.buffer+s.gp.UIControlHeight)-1 buttonX-2*s.gp.buffer+2 s.gp.UIControlHeight+2]);

    pos = [ 2*s.gp.buffer+s.gp.toggleWidth,...
            position(4)-fieldRow*(s.gp.buffer+s.gp.UIControlHeight),...
            s.gp.fieldsShow.names.width+fieldSlush,...
            s.gp.UIControlHeight];
    set(s.hg.fieldsShow.names,        'Position', pos);

    pos(1) = pos(1) + pos(3) + s.gp.buffer;
    pos(3) = s.gp.fieldsShow.labels.width+fieldSlush;
    set(s.hg.fieldsShow.labels,       'Position', pos);

    pos(1) = pos(1) + pos(3) + s.gp.buffer;
    pos(3) = s.gp.fieldsShow.descriptions.width+fieldSlush;
    set(s.hg.fieldsShow.descriptions, 'Position', pos);

    pos(1) = pos(1) + pos(3) + s.gp.buffer;
    pos(3) = s.gp.fieldsShow.documents.width+fieldSlush;
    set(s.hg.fieldsShow.documents,    'Position', pos);

    pos(1) = pos(1) + pos(3) + s.gp.buffer;
    pos(3) = s.gp.fieldsShow.customCode.width+fieldSlush;
    set(s.hg.fieldsShow.customCode,   'Position', pos);

    set(s.hg.fieldsHide.label,    'Position', [2*s.gp.buffer+s.gp.toggleWidth                   position(4)-fieldRow*(s.gp.buffer+s.gp.UIControlHeight) fieldsHideSize(3) s.gp.UIControlHeight]);
    set(s.hg.fieldsHide.selected, 'Position', [2*s.gp.buffer+s.gp.toggleWidth+fieldsHideSize(3) position(4)-fieldRow*(s.gp.buffer+s.gp.UIControlHeight) buttonX-3*s.gp.buffer-fieldsHideSize(3)-s.gp.toggleWidth s.gp.UIControlHeight]);


    % --------------------------------------------------------------------------------------------------------
    % ---Type-Types-------------------------------------------------------------------------------------------
    % --------------------------------------------------------------------------------------------------------
    typeRow = 4;
    typeSlush = (buttonX-4*s.gp.buffer-s.gp.toggleWidth-s.gp.typesShow.width)/s.gp.numTypes;
    typesHideSize = get(s.hg.typesHide.label, 'Extent');
    set(s.hg.typesToggle,     'Position', [s.gp.buffer   position(4)-typeRow*(s.gp.buffer+s.gp.UIControlHeight)+1 s.gp.toggleWidth s.gp.UIControlHeight-2]);
    set(s.hg.typesShow.frame, 'Position', [s.gp.buffer-1 position(4)-typeRow*(s.gp.buffer+s.gp.UIControlHeight)-1 buttonX-2*s.gp.buffer+2 s.gp.UIControlHeight+2]);

    pos = [ 2*s.gp.buffer+s.gp.toggleWidth,...
            position(4)-typeRow*(s.gp.buffer+s.gp.UIControlHeight),...
            s.gp.typesShow.machine.width+typeSlush,...
            s.gp.UIControlHeight];
    set(s.hg.typesShow.machine,     'Position', pos);

    pos(1) = pos(1) + pos(3) + s.gp.buffer;
    pos(3) = s.gp.typesShow.targets.width+typeSlush;
    set(s.hg.typesShow.targets,     'Position', pos);

    pos(1) = pos(1) + pos(3) + s.gp.buffer;
    pos(3) = s.gp.typesShow.charts.width+typeSlush;
    set(s.hg.typesShow.charts,      'Position', pos);

    pos(1) = pos(1) + pos(3) + s.gp.buffer;
    pos(3) = s.gp.typesShow.states.width+typeSlush;
    set(s.hg.typesShow.states,      'Position', pos);

    pos(1) = pos(1) + pos(3) + s.gp.buffer;
    pos(3) = s.gp.typesShow.junctions.width+typeSlush;
    set(s.hg.typesShow.junctions,   'Position', pos);

    pos(1) = pos(1) + pos(3) + s.gp.buffer;
    pos(3) = s.gp.typesShow.transitions.width+typeSlush;
    set(s.hg.typesShow.transitions, 'Position', pos);

    pos(1) = pos(1) + pos(3) + s.gp.buffer;
    pos(3) = s.gp.typesShow.data.width+typeSlush;
    set(s.hg.typesShow.data,        'Position', pos);

    pos(1) = pos(1) + pos(3) + s.gp.buffer;
    pos(3) = s.gp.typesShow.events.width+typeSlush;
    set(s.hg.typesShow.events,      'Position', pos);

    set(s.hg.typesHide.label,    'Position', [2*s.gp.buffer+s.gp.toggleWidth position(4)-typeRow*(s.gp.buffer+s.gp.UIControlHeight) typesHideSize(3) s.gp.UIControlHeight]);
    set(s.hg.typesHide.selected, 'Position', [2*s.gp.buffer+s.gp.toggleWidth+typesHideSize(3) position(4)-typeRow*(s.gp.buffer+s.gp.UIControlHeight) buttonX-3*s.gp.buffer-typesHideSize(3)-s.gp.toggleWidth s.gp.UIControlHeight]);


    % --------------------------------------------------------------------------------------------------------
    % ---Found-Object-Panel-----------------------------------------------------------------------------------
    % --------------------------------------------------------------------------------------------------------
    foundTop = position(4)-5*(s.gp.buffer+s.gp.UIControlHeight)-s.gp.buffer;
    s.gp.portalTop = foundTop-3*s.gp.buffer-s.gp.UIControlHeight-s.gp.foundObjectHeight-s.gp.foundTextHeight;
    foundBottom = 0;
    if ~s.gp.portalVisible
        foundBottom = s.gp.portalTop;
    elseif s.gp.portalTop < s.gp.portalHeightMinimum+s.gp.buffer
        foundBottom = s.gp.portalTop-(s.gp.portalHeightMinimum+s.gp.buffer);
    elseif s.gp.setRows > s.gp.foundRows & s.gp.portalTop > s.gp.portalHeightMinimum+s.gp.buffer+s.gp.foundTextHeight
        foundBottom = s.gp.portalTop-(s.gp.portalHeightMinimum+s.gp.buffer+s.gp.foundTextHeight);
    end
    if foundBottom
        moveRows = -1*floor(foundBottom/s.gp.foundTextHeight);
        moveRows = min(moveRows, s.gp.foundRows-2);
        if moveRows
            set(fig, 'UserData', s);
            s = resize_found_l(moveRows);
        end
    end

    set(s.hg.found.breakDark,  'XData', [s.gp.buffer position(3)-s.gp.buffer], 'YData', [foundTop   foundTop]);
    set(s.hg.found.breakLight, 'XData', [s.gp.buffer position(3)-s.gp.buffer], 'YData', [foundTop-1 foundTop-1]);

    replaceThisX = position(3)-s.gp.buffer-s.gp.replaceThisWidth;

    iconOffset = (s.gp.UIControlHeight-s.gp.iconSize)/2;
    iconX = s.gp.buffer + iconOffset;
    iconY = foundTop-s.gp.buffer-s.gp.UIControlHeight+iconOffset;
    set(s.hg.found.icon, 'XData', [iconX iconX+s.gp.iconSize], 'Ydata', [iconY iconY+s.gp.iconSize]);

    nameX = 2*s.gp.buffer + s.gp.UIControlHeight;
    set(s.hg.found.name,        'Position', [nameX                        foundTop-s.gp.buffer-s.gp.UIControlHeight/2]);
    set(s.hg.found.replaceThis, 'Position', [replaceThisX                 foundTop-s.gp.buffer-s.gp.UIControlHeight s.gp.replaceThisWidth s.gp.UIControlHeight]);

    % trim the width of the name
    s.gp.nameWidth = replaceThisX - nameX - s.gp.buffer;
    trim_name_l(s);

    s.gp.foundPropsYHigh = foundTop-2*s.gp.buffer-s.gp.UIControlHeight;
    s.gp.foundPropsYLow = s.gp.foundPropsYHigh-s.gp.foundObjectHeight-s.gp.foundTextHeight;
    foundPropsXLeft = s.gp.buffer;
    foundPropsXRight = position(3)-s.gp.buffer;

    foundPropsWidth = foundPropsXRight-foundPropsXLeft-s.gp.foundTextHeight;

    set(s.hg.found.propertiesAxes, 'position', [foundPropsXLeft s.gp.foundPropsYLow+s.gp.foundTextHeight foundPropsWidth s.gp.foundObjectHeight]);

    propertiesX = get(s.hg.found.propertiesAxes, 'Xlim');
    propertiesY = get(s.hg.found.propertiesAxes, 'Ylim');
    propertiesX(2) = propertiesX(1) + foundPropsWidth;
    set(s.hg.found.propertiesAxes, 'XLim', propertiesX);

    pa = get(s.hg.found.propertiesAxes, 'UserData');

    set(s.hg.found.propertiesDark,  'XData', [foundPropsXLeft-1     foundPropsXLeft-1      foundPropsXRight],...
                                    'YData', [s.gp.foundPropsYLow   s.gp.foundPropsYHigh+1 s.gp.foundPropsYHigh+1]);
    set(s.hg.found.propertiesLight, 'XData', [foundPropsXLeft-1     foundPropsXRight+1     foundPropsXRight+1],...
                                    'YData', [s.gp.foundPropsYLow-1 s.gp.foundPropsYLow-1  s.gp.foundPropsYHigh+1]);

    set(s.hg.found.sliderV,         'position', [foundPropsXRight-s.gp.foundTextHeight s.gp.foundPropsYLow+s.gp.foundTextHeight s.gp.foundTextHeight s.gp.foundObjectHeight]);
    set(s.hg.found.sliderH,         'position', [foundPropsXLeft s.gp.foundPropsYLow foundPropsWidth s.gp.foundTextHeight]);

    set(s.hg.found.fieldsGreyArea,  'Position', [0, -1*s.gp.foundObjectHeight, s.gp.foundFieldWidth 2*s.gp.foundObjectHeight+pa.height]);

    pos = get(s.hg.found.conditionsGreyArea, 'Position');
    pos(3) = max(pos(3), foundPropsWidth);
    set(s.hg.found.conditionsGreyArea, 'Position', pos);

    pos = get(s.hg.found.actionsGreyArea, 'Position');
    pos(3) = max(pos(3), foundPropsWidth);
    set(s.hg.found.actionsGreyArea, 'Position', pos);

    foundTextX = s.gp.foundFieldWidth+s.gp.buffer;

    if pa.width > foundPropsWidth
        forcePos = get(s.hg.found.match, 'Position');
        rightView = max(foundPropsWidth, forcePos(1)+forcePos(3));
        sliderLength = pa.width-foundPropsWidth;
        set(s.hg.found.sliderH, 'Min',          foundPropsWidth,...
                                'Max',          pa.width,...
                                'Value',        rightView,...
                                'Enable',       'on',...
                                'SliderStep',   [min(s.gp.buffer, sliderLength)/sliderLength foundPropsWidth/sliderLength ]);
        set(s.hg.found.propertiesAxes, 'XLim', [rightView-foundPropsWidth rightView]);
    else
        set(s.hg.found.sliderH, 'Enable',       'off');
        set(s.hg.found.propertiesAxes, 'XLim', [0 foundPropsWidth]);
    end


    % --------------------------------------------------------------------------------------------------------
    % ---Portal-----------------------------------------------------------------------------------------------
    % --------------------------------------------------------------------------------------------------------
    portalPropsYHigh = s.gp.portalTop;
    portalPropsYLow = s.gp.buffer;
    portalHeight = portalPropsYHigh-portalPropsYLow;
    portalPropsXLeft = s.gp.buffer;
    portalPropsXRight = position(3)-s.gp.buffer;

    if s.gp.portalVisible
        sf('set', s.portal, '.viewRect', [portalPropsXLeft portalPropsYLow portalPropsXRight-portalPropsXLeft portalHeight]);
        set(s.hg.portal.borderDark,  'XData', [portalPropsXLeft-1 portalPropsXLeft-1  portalPropsXRight],...
                                     'YData', [portalPropsYLow    portalPropsYHigh+1  portalPropsYHigh+1]);
        set(s.hg.portal.borderLight, 'XData', [portalPropsXLeft-1 portalPropsXRight+1 portalPropsXRight+1],...
                                     'YData', [portalPropsYLow-1  portalPropsYLow-1   portalPropsYHigh+1]);
    end

    set(fig, 'UserData', s);


%---------------------------------------------------------------------------------------
% Generates an array of true and false to represent a decimal in binary
% Parameters:
%   dec         the decimal number to convert
%   len         the minimum length of the return string
% Returns:
%   The binary number as an array in binary
%--------------------------------------------------------------------------------------
function response = pad_dec2bin_l(dec, len)

    % first convert the number to a string
    dec = double(dec);
    str = dec2bin(dec, len);
    
    response = str == '1';



%---------------------------------------------------------------------------------------
% Trims the path/name for the found item.
% Parameters:
%   s       The user data for the SNR figure
%---------------------------------------------------------------------------------------
function trim_name_l(s)
    fullName = get(s.hg.found.name, 'UserData');
    if ~isempty(fullName)
        length = strlen(fullName);
        set(s.hg.found.name, 'String', fullName);
        extent = get(s.hg.found.name, 'extent');
        index = 1;
        while extent(3) > s.gp.nameWidth
            index = index+1;
            set(s.hg.found.name, 'String', ['...' fullName(index: length)]);
            extent = get(s.hg.found.name, 'extent');
        end
    end


%---------------------------------------------------------------------------------------
% Modifies the search expression based on the search options
% Parameters:
%   searchExpr      the search expression as specified by the user
%   options         bitfield of search options (see options_toggle_l)
% Returns:
%   the augmented search expression
%---------------------------------------------------------------------------------------
function searchExpr = search_options_l(searchExpr, options)

    if ~(options(2) | options(1))
        searchExpr = regexprep(searchExpr, '([$^.\\*+[\](){}?\|])', '\\$1');
    end

    if options(1)
        searchExpr = ['\<' searchExpr '\>'];
    end


%---------------------------------------------------------------------------------------
% Determines the string values for regexp and regexprep parameters
% Parameters:
%   options         bitfield of search options (see options_toggle_l)
% Returns:
%   searchCase      'matchcase' or 'ignorecase'
%   replaceCase     'preservecase' or searchCase
%---------------------------------------------------------------------------------------
function [searchCase, replaceCase] = regexp_options_l(options)
    if options(3)
        searchCase = 'matchcase';
    else
        searchCase = 'ignorecase';
    end
    if options(4)
        replaceCase = 'preservecase';
    else
        replaceCase = searchCase;
    end


%---------------------------------------------------------------------------------------
% Loads data for an icon from a specified image file.
% Parameters:
%   name        The name of the file, relative to the base icon path.
%   background  The color to set the background of the image to.
% Returns:
%   a matrix of RGB for the icon data.
%---------------------------------------------------------------------------------------
function iconData = load_icon_l(name, background)

    iconData = imread([sf('Root') 'private' filesep name], 'bmp');

    % denormalize if necessary
    if background(1) > 0 & background(1) < 1
        background = background*255;
    end

    dims = size(iconData);

    % set the mask to the color of the top-left corner
    maskColor = iconData(1,1,:);

    red = iconData(:,:,1);
    green = iconData(:,:,2);
    blue = iconData(:,:,3);

    mask = red == maskColor(1);
    mask = mask & green == maskColor(2);
    mask = mask & blue == maskColor(3);

    red(mask) = background(1);
    green(mask) = background(2);
    blue(mask) = background(3);

    iconData(:,:,1) = flipud(red);
    iconData(:,:,2) = flipud(green);
    iconData(:,:,3) = flipud(blue);


%---------------------------------------------------------------------------------------
% Tosses the user a warning iff a warning hasn't already been tossed
% Paremeters:
%   severity    'info' for info, 'warning' for warning
%   warn        The warning string to toss
%---------------------------------------------------------------------------------------
function toss_warning_l(severity, warn)
    % get the figure
    fig = find_figure_l;

    % get the user data
    s = get(fig, 'UserData');

    switch severity,
    case 'info',
        if isempty(s.sp.info)
            s.sp.info = warn;
        end
    case 'warning',
        if isempty(s.sp.warn)
            s.sp.warn = warn;
        end
    end

    % set the user data
    set(fig, 'UserData', s);


%---------------------------------------------------------------------------------------
% Determines if an object can be viewed in the Stateflow editor
% Parameters:
%   item        The item to check.
% Returns:
%   true        If the item has a valid representation in the editor.
%---------------------------------------------------------------------------------------
function response = is_viewable_l(item)
    type = sf('get', item, '.isa');

    DATA = sf('get', 'default','data.isa');
    EVENT = sf('get', 'default','event.isa');
    MACHINE = sf('get', 'default','machine.isa');
    TARGET = sf('get', 'default','target.isa');

    switch type
    case {DATA, EVENT, MACHINE, TARGET}
        response = 0;
    otherwise
        response = 1;
    end


%---------------------------------------------------------------------------------------
% Focuses the view on the item in the Stateflow editor
% Parameters:
%   item        The item to focus.
%---------------------------------------------------------------------------------------
function view_item_l(item)

    type = sf('get', item, '.isa');

    JUNCTION = sf('get', 'default','junction.isa');
    TRANSITION = sf('get', 'default','transition.isa');
    STATE = sf('get', 'default','state.isa');
    CHART = sf('get', 'default','chart.isa');

    switch type
    case {JUNCTION, TRANSITION}
        parent = sf('get', item, '.linkNode.parent');
    case STATE,
        parent = sf('get', item, '.treeNode.parent');
    case CHART,
        parent = item;
    otherwise
        return;
    end

    parentType = sf('get', parent, '.isa');
    while parentType ~= CHART
        parent = sf('get', parent, '.treeNode.parent');
        parentType = sf('get', parent, '.isa');
    end

    sf('Open', item);
    sf('FitToView', parent, item);


%---------------------------------------------------------------------------------------
% Create a matrix of searchable combinations of fields and types
% Parameters:
%   fields          bitfield of field types to search (see fields_toggle_l)
%   types           bitfield of object types to search (see types_toggle_l) (optional, default to all)
% Returns:
%   A (numTypes x numFields) matrix of valid search combinations
%---------------------------------------------------------------------------------------
function searchMatrix = create_search_matrix_l(varargin)

    numTypes = 8;
    numFields = 5;

    switch(nargin),
    case 0,
        fields = ones(numFields);
        types = ones(numTypes);
    case 1,
        fields = pad_dec2bin_l(varargin{1}, numFields);
        types = ones(numTypes);
    case 2,
        fields = pad_dec2bin_l(varargin{1}, numFields);
        types = pad_dec2bin_l(varargin{2}, numTypes);
    otherwise,
        % invalid
        searchMatrix = [];
        return;
    end

    % check for a valid combination of fields
    searchMatrix = types(ones(1, numFields), :) & fields(ones(1,numTypes), :)';

    % establish the valid matrix
    %              Machine States Charts Junctions Transisitons Data Events Targets
    validMatrix = [0       1      0      0         1            0    0      0;... % Label
                   0       1      0      0         0            1    1      1;... % Name
                   1       1      1      1         1            1    1      1;... % Description
                   1       1      1      1         1            1    1      1;... % Document Link
                   0       0      0      0         0            0    0      1];   % Custom Code

    searchMatrix = searchMatrix & validMatrix;


%---------------------------------------------------------------------------------------
% Gets the valid fields to search for the given type.
% Parameters:
%   type            The type to search
%   item            The item to check.
%   searchMatrix    A matrix of valid search combinations (see create_search_matrix_l)
% Returns:
%   A vector of fields to search (see fields_toggle_l)
%---------------------------------------------------------------------------------------
function searchFields = get_fields_l(type, item, searchMatrix)

    MACHINE = sf('get', 'default','machine.isa');
    CHART = sf('get', 'default','chart.isa');
    TARGET = sf('get', 'default','target.isa');
    STATE = sf('get', 'default','state.isa');
    DATA = sf('get', 'default','data.isa');
    EVENT = sf('get', 'default','event.isa');
    JUNCTION = sf('get', 'default','junction.isa');
    TRANSITION = sf('get', 'default','transition.isa');

    types = [MACHINE STATE CHART JUNCTION TRANSITION DATA EVENT TARGET];

    searchFields = searchMatrix(:,find(types == type));

    % Rig the search fields to reflect state name is in it's label
    searchFields(1) = searchFields(1) | (searchFields(2) & type == STATE);
    searchFields(2) = searchFields(2) & type ~= STATE;

    % turn off labels for eML
    if is_eml_l(type, item);
        searchFields(1) = 0;
    end


%---------------------------------------------------------------------------------------
% Gets the field names to use for searching
% Returns:
%   A cell array of fields to use for searching
%---------------------------------------------------------------------------------------
function fieldStrings = get_field_strings_l
    fieldStrings = {'.labelString' '.name' '.description' '.document' '.customCode'};


%---------------------------------------------------------------------------------------
% Determines if an object is a truth table
% Returns:
%   true if an object is a truth table false otherwise
%---------------------------------------------------------------------------------------
function isTruthTable = is_truth_table_l(type, item)
    STATE = sf('get', 'default','state.isa');
    if type==STATE
        isTruthTable = sf('get', item, '.truthTable.isTruthTable');
    else
        isTruthTable = 0;
    end



%---------------------------------------------------------------------------------------
% Iterates through a truth table for searching.
% Parameters:
%   iterator        The iteration state, or empty to start over
%   action          The action to perform on the table
%                   Supported actions are
%                       'next'  go to the next item
%                       'set'   set the current value in the table
% Returns:
%   The iteration state with fields:
%       truthTableID    The truth table to iterate
%       predicateArray  The predicate array from the truth table
%       actionArray     The action array from the truth table
%       index           The state of the iterator
%       row             The row of the appropriate table this index represents
%       col             The row of the appropriate table this index represents
%       currentArray    The appropriate table
%       value           The value of the current element in the array
%---------------------------------------------------------------------------------------
function iterator = iterate_truth_table_l(iterator, action)
    if isnumeric(iterator)
        % this is the initial iteration, build the state
        iterator.truthTableID = iterator;
        iterator.predicateArray = sf('get', iterator.truthTableID, '.truthTable.predicateArray');
        iterator.actionArray = sf('get', iterator.truthTableID, '.truthTable.actionArray');
        iterator.index = 0;
    end

    if strcmpi(action, 'next')
        iterator.index = iterator.index + 1;
    end

    currentArray = [];
    tableId = 0;

    predCols = 2;
    predDims = size(iterator.predicateArray);
    conditionTableSize = predCols *(predDims(1)-1);
    if iterator.index <= conditionTableSize
        iterator.col = mod(iterator.index-1,predCols )+1;
        iterator.row = ceil(iterator.index/predCols );
        currentArray = 'predicateArray';
    end

    mapIndex = iterator.index-conditionTableSize;
    actionMapSize = (predDims(2)-predCols);
    if mapIndex <= actionMapSize & isempty(currentArray);
        iterator.row = predDims(1);
        iterator.col = mapIndex+predCols;
        currentArray = 'predicateArray';
    end

    actionIndex = mapIndex - actionMapSize;
    actionCols = 2;
    actionDims = size(iterator.actionArray);
    actionTableSize = actionCols*actionDims(1);
    if actionIndex <= actionTableSize & isempty(currentArray);
        iterator.col = mod(actionIndex-1,actionCols)+1;
        iterator.row = ceil(actionIndex/actionCols);
        currentArray = 'actionArray';
        tableId = 1;
    end

    if isempty(currentArray);
        iterator.index = [];
        return;
    end

    iterator.currentArray = getfield(iterator, currentArray);

    if strcmpi(action, 'set')
        iterator.currentArray{iterator.row, iterator.col} = iterator.value;
        iterator = setfield(iterator, currentArray, iterator.currentArray);
        sf('Private', 'truth_table_man', 'update_data', iterator.truthTableID, 'snr', tableId, iterator.row, iterator.col, iterator.value);
    else
        iterator.value = iterator.currentArray{iterator.row, iterator.col};
    end




%---------------------------------------------------------------------------------------
% Determines if an object is an eml function
% Returns:
%   true if an object is an eml function false otherwise
%---------------------------------------------------------------------------------------
function isEML = is_eml_l(type, item)
    STATE = sf('get', 'default','state.isa');
    if type==STATE
        isEML = sf('get', item, '.eml.isEML');
    else
        isEML = 0;
    end


%---------------------------------------------------------------------------------------
% Gets the text of an eml function
% Returns:
%   the script, less the function line
%---------------------------------------------------------------------------------------
function script = get_eml_script_l(item)
hEditor = eml_man('get_editor');
if ~isempty(hEditor) && hEditor.documentIsOpen(item)
  script = char(hEditor.documentGetText(item));
else
  script = sf('get', item, '.eml.script');
end

%---------------------------------------------------------------------------------------
% Sets the text of an eml function
%---------------------------------------------------------------------------------------
function set_eml_script_l(item, script)
    sf('set', item, '.eml.script', script);


%---------------------------------------------------------------------------------------
% Sets the text of an eml function via substrings
%---------------------------------------------------------------------------------------
function script = set_eml_substrings_l(item, script, searchExpr, replaceStr, searchCase, replaceCase, matchMethod)
    [s e] = regexp(script, searchExpr, searchCase);

    if isequal(matchMethod, 'all')
        matchIndex = length(s):-1:1;
    else
        matchMethod = find(s==matchMethod);
        matchIndex = matchMethod;
    end

    if isempty(matchIndex)
        script = '';
    else
      hEditor = eml_man('get_editor');
      if ~isempty(hEditor) && hEditor.documentIsOpen(item)
        scriptLen = length(script);
        for i = matchIndex
          script = regexprep(script, searchExpr, replaceStr, replaceCase, i);
          newScriptLen = length(script);
          lengthChange = newScriptLen-scriptLen;
          scriptLen = newScriptLen;
          
          hEditor.documentUpdateSubstring(item,s(i),e(i),script(s(i):e(i)+lengthChange));
        end
        sf('TurnOffEMLUIUpdates',1);
        set_eml_script_l(item, script)
        sf('TurnOffEMLUIUpdates',0);
      else
        script = regexprep(script, searchExpr, replaceStr, replaceCase, matchMethod);
        set_eml_script_l(item, script)
      end
    end

%---------------------------------------------------------------------------------------
% Shortcut to check if a handle is valid and the appropriate type
% Parameters:
%   handle      The handle to test
%   type        the type the handle should be
% Returns:
%   true if handle is a valid instance of type
%---------------------------------------------------------------------------------------
function response = check_handle_l(handle, type)
    if sf('ishandle', handle) & (sf('get', handle, '.isa') == sf('get', 'default', [type '.isa']))
        response = 1;
    else
        response = 0;
    end


%---------------------------------------------------------------------------------------
% Checks if the list of machines is up to date and updates them if necessary
%---------------------------------------------------------------------------------------
function check_machines_l
    % get the figure
    fig = find_figure_l;

    % get the figure's user data
    s = get(fig, 'UserData');

    % get a list of open machines
    openMachines = sf('MachinesOf', 0);

    if isempty(openMachines) | ~isequal(openMachines, s.sp.machines)
        set_scope_l;
    elseif s.sp.expand
        % check the charts, too
        openCharts = sf('get', s.sp.machine, '.charts');
        if ~isequal(openCharts, s.sp.charts)
            set_scope_l;
        end
    end


%---------------------------------------------------------------------------------------
% Creates a portal just the way we like it
% Parameters:
%   parent      the figure in which to put the portal
%   visible     the portal visibility
% Returns:
%   a brand spanking new portal
%---------------------------------------------------------------------------------------
function portal = create_portal_l(parent, visible)
    portal = sf('new', 'portal');
    sf('set', portal, '.viewRectMode',        'FIXED_POSITION',...
                      '.viewRect',            [0 0 10 10],...
                      '.visible',             visible,...
                      '.figH',                parent,...
                      '.autoHighlightViewObj',1);


%---------------------------------------------------------------------------------------
% Hides the blanket and resizes the figure to it's minimum size.
%---------------------------------------------------------------------------------------
function yank_blanket_l
    % get the figure
    fig = find_figure_l;

    % get the figure's user data
    s = get(fig, 'UserData');

    position = get(fig, 'Position');

    position(3) = max(position(3), s.gp.minimumWidth+1);
    if position(4) < s.gp.minimumHeight
        position(2) = position(2) + position(4) - (s.gp.minimumHeight+1);
        position(4) = s.gp.minimumHeight+1;
    end


    set(s.hg.blanket, 'Visible', 'off');
    set(fig,    'WindowButtonMotionFcn',    'sf(''Private'', ''sf_snr_inject_event'', ''mouse_moved'');',...
                'Position',                 position);


%---------------------------------------------------------------------------------------
% Event handler for key actions.
%---------------------------------------------------------------------------------------
function key_press_l
    % get the figure
    fig = find_figure_l;

    % get the user data
    s = get(fig, 'UserData');

    % get the key pressed
    key = get(fig, 'CurrentKey');

    % get the modifier
    modifier = get(fig, 'CurrentModifier');

    if ~isempty(modifier) & strcmp(modifier{1}, 'control')
        switch key,
        case 't',
            sfsnr('toggle_portal');
        case 'i',
            sf_snr_inject_event('view');
        case 'r',
            sf_snr_inject_event('explore');
        case 'p',
            sf_snr_inject_event('properties');
        case 'w',
            sfsnr('cancel');
        end
    else
        switch key,
        case 'escape',
            % hide the drag line
            set(s.hg.found.dragLine, 'Visible', 'off');
            sf_snr_inject_event('escape');
        case 'f3',
            sf_snr_inject_event('search');
        end
    end


%---------------------------------------------------------------------------------------
% Persistent holder for the figure
%---------------------------------------------------------------------------------------
function response = find_figure_l(varargin)
    persistent fig;

    % get a list of existing snr figures
    figs = findall(0, 'type', 'figure', 'tag', 'SF_SNR');

    if nargin == 1
        fig = varargin{1};
    elseif isempty(fig) | ~ishandle(fig),
        if (~isempty(figs))
            % search the list of figs for a valid one
            for fig = figs
                s = get(fig, 'UserData');
                if (s.hg.fig == fig)
                    break;
                end
            end
        end
    end

    % cull extra figures if necessary
    if ~isempty(fig)
        index = find(figs==fig);
        if (index)
            figs(index) = [];
        else
            fig = [];
        end
    end
    delete(figs);

    response = fig;


%---------------------------------------------------------------------------------------
% Gets the set of children for a parent.
% Works around the problem that boxes children are adopted by their grandparents
% Parameters:
%   childFcn    The function name to fetch the children
%   parent      The parent treeNode
% Returns:
%   the set of this parent's true children
%---------------------------------------------------------------------------------------
function children = children_of_l(childFcn, parent)

    % get this parent's children
    children = sf(childFcn, parent);

    % filter out grandchildren
    children = sf('find', children, '.linkNode.parent', parent);
