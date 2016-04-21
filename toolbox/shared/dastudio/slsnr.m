function response = slsnr(varargin)
% slsnr - Simulink Search And Replace
% Main function used to parse out calls to other functions.
% Parameters:
%   varargin    cell array of parameters.  First parameter indicates function name,
%               additional parameters are parameters to that funcion.

% Author: J Breslau
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:32:22 $



    % set the default response
    response = 1;

    try

        % with no arguments just revive the state machine
        if nargin==0
            sl_snr_inject_event('standAlone');
            return;
        end

        if (ishandle(varargin{1}))
            topObject = varargin{1};
            active = set_scope_l;
            if ~isempty(active) & topObject == active
                % see if there already is a figure
                fig = find_figure_l;

                if fig
                    % bypass reset
                    revitalize_figure_l(fig);
                    figure(fig);
                    return;
                end
            end
            sl_snr_inject_event('standAlone');
            set_scope_l(topObject);
            return;
        end

        switch varargin{1},
        case 'init',
            init_l(varargin{2});
        case 'init_GUI',
            response = init_GUI_l;
        case 'search_string_empty',
            response = search_string_empty_l;
        case 'enough_time_elapsed',
            response = enough_time_elapsed_l;
        case 'search',
            set_busy_l;
            response = search_l(varargin{2});
        case 'inner_search',
            response = inner_search_l(varargin{2}, varargin{3}, varargin{4}, 0);
        case 'reset_search',
            reset_search_l;
        case 'found_item',
            set_busy_l;
            response = found_item_l(varargin{2}, varargin{3});
        case 'replace',
            set_busy_l;
            response = replace_l(varargin{2}, varargin{3});
        case 'replace_all',
            set_busy_l;
            replace_all_l(varargin{2});
        case 'replace_this',
            set_busy_l;
            replace_this_l(varargin{2});
        case 'inner_replace_this',
            response = inner_replace_this_l(varargin{2}, varargin{3}, varargin{4}, [0 1 0 1]);
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
        case 'kill',
            sl_snr_inject_event('kill');
            fig = find_figure_l;
            if fig
                set(0, 'CurrentFigure', fig)
                closereq;
                find_figure_l([]);
            end
        case 'cancel',
            sl_snr_inject_event('cancel');
            cancel_l;
        case 'help',
            help_l;
        case 'key_press',
            key_press_l;
        case 'warn',
            toss_warning_l(varargin{2}, varargin{3});
        case 'set_option',
            set_option_l;
        case 'set_scope',
            set_scope_l('select');
        case 'is_viewable',
            response = is_viewable_l;
        case 'view_item',
            view_item_l;
        case 'explore_item',
            explore_item_l;
        case 'edit_item_properties',
            edit_item_properties_l;
        case 'yank_blanket',
            yank_blanket_l;
        otherwise,
            response = 0;
        end
    catch
        % deal with errors
        disp(lasterr);
    end


%---------------------------------------------------------------------------------------
% Initializes any structures
% Parameters:
%   options         bitfield of search options
%---------------------------------------------------------------------------------------
function init_l(options)
    % get the figure
    fig = find_figure_l;

    % get the figure's user data
    s = get(fig, 'UserData');

    set_scope_l;

    % decompose the options
    options = pad_dec2bin_l(options, s.gp.options.count);

    if options(1)
        set(s.hg.options.searchOption, 'Value', 1);
    elseif options(2)
        set(s.hg.options.searchOption, 'Value', 3);
    else
        set(s.hg.options.searchOption, 'Value', 2);
    end
    set(s.hg.options.matchCase,    'Value', options(3));
    set(s.hg.options.preserveCase, 'Value', options(4));



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

    response = isempty(get(s.hg.strings.search, 'String'));



%---------------------------------------------------------------------------------------
% Gets a list of replacable properties for the current object
% Parameters:
%   item            the object to find properties for
% Returns:
%   a cell array of property names
%---------------------------------------------------------------------------------------
function properties = get_replace_properties_l(item)
    % get the item's class
    classhandle = item.classhandle;

    % get the class's properties
    properties = classhandle.properties;

    % get the settable string properties
    properties = properties.find('-regexp', 'DataType', '[Ss]tring', 'AccessFlags.PublicSet', 'on');

    % get the names
    properties = properties.get('name');

    if ischar(properties)
        properties = {properties};
    end


%---------------------------------------------------------------------------------------
% Sets the current found item
% Parameters:
%   startIndex      the index of the character after which to start matching
%   options         bitfield of search options
% Returns:
%   the index of the first character the first match or zero if there is no match
%---------------------------------------------------------------------------------------
function response = found_item_l(startIndex, options)
    % get the figure
    fig = find_figure_l;

    % get the current object
    item = current_object_l;

    if isempty(item)
        toss_warning_l('warning', 'Search object not found');
        response = 0;
        return;
    end

    % get the figure's user data
    s = get(fig, 'UserData');

    % check for warnings
    if s.notify.warn | s.notify.info
        response = 0;
        return;
    end

    % decompose the options
    options = pad_dec2bin_l(options, s.gp.options.count);

    % get the search expression
    i.searchExpr = search_options_l(get(s.hg.strings.search, 'String'), options);

    % check to see if the search string has changed
    if reset_search_l
        % found item can't handle this case
        response = 0;
        reset_search_l;
        return;
    end

    % try to advance to the next match from the last search
    ud = get(s.hg.found.match, 'UserData');
    if ~isempty(ud.under)
        lastMatchIndex = find(s.hg.found.activeHighlights==ud.under);
        if lastMatchIndex < length(s.hg.found.activeHighlights)
            % there is another match in this object
            set(ud.under, 'FaceColor', [.8 .8 .8]);
            ud.under = s.hg.found.activeHighlights(lastMatchIndex+1);
            thisMatch = get(ud.under, 'UserData');
            if ~isempty(thisMatch)
                set(s.hg.found.match, 'position', get(ud.under, 'position'));
                set(ud.under, 'FaceColor', [1 1 1]);
                force_row_l(s, thisMatch.row);
                force_column_l(s);
                set(fig, 'UserData', s);
                response = thisMatch.index + ud.offset;
            end
            set(s.hg.found.match, 'UserData', ud);
        else
            response = 0;
        end
        return;
    end


    % initialize the possible return strings
    i.count = 0;
    i.matchIndex = 0;
    i.startIndex = startIndex;
    i.found = 0;
    i.fieldStrings = {};
    i.row = 1;
    i.col = 1;
    i.parent = s.hg.found.propertiesAxes;
    i.properties = s.hg.found.properties;
    i.newHighlights = [];
    i.newRows = 0;
    if options(3)
        i.matchCase = 'matchcase';
    else
        i.matchCase = 'ignorecase';
    end

    % get the user data from the axes
    pa = get(s.hg.found.propertiesAxes, 'UserData');

    title = ['(' item.getDisplayClass ') ' item.getFullName];
    title(title==10) = ' ';

    set(s.hg.found.icon, 'CData', get_icon_l(item))

    set(s.hg.found.icon, 'Visible', 'on');

    % set the name
    set(s.hg.found.name, 'String', title, 'UserData', title);

    % trim the name
    trim_name_l(s);

    % clear all of the highlights and strings
    clear_found_l(s);

    % get a list of properties for the item
    properties = get_replace_properties_l(item);

    for index = 1:length(properties)
        property = properties{index};
        try
            value = item.get(property);
            if (value)
                i = dismantle_property_l (value, [property ':'], i);
            end
        catch
            % invalid property value, we'll leave it out
        end
    end


    if ~i.found
        response = 0;
        return;
    end

    s.hg.found.properties = i.properties;

    s.sp.totalRows = i.row-1;

    pa = force_row_l(s, i.found);

    pa.width = 0;
    foundTextX = s.gp.found.fieldWidth+s.gp.buffer;

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
            set(s.hg.found.fields(fieldStringIndex), 'Position', [s.gp.found.fieldWidth pa.height-(row-1)*s.gp.found.textHeight],...
                                                     'String', i.fieldStrings{row});
            fieldStringIndex = fieldStringIndex + 1;
        end
    end
    columnXpos = foundTextX;
    s.hg.found.activeHighlights = [];
    for propertyCol = 1:propertyCols
        for row = 1:propertyRows
            if s.hg.found.properties(row, propertyCol)
                set(s.hg.found.properties(row, propertyCol), 'Position', [columnXpos pa.height-(row-1)*s.gp.found.textHeight]);
                lastEx = get(s.hg.found.properties(row, propertyCol), 'Extent');
                highlight = 0;
                highCol = 1;
                ud = get(s.hg.found.properties(row, propertyCol), 'UserData');
                fullString = '';
                for col = 1:length(ud.rowStrings)
                    fullString = [fullString strrep(ud.rowStrings{col}, char(9), '    ')];
                    set(s.hg.found.properties(row, propertyCol), 'String', fullString);
                    ex = get(s.hg.found.properties(row, propertyCol), 'Extent');
                    if highlight & ex(3) > 0
                        highEx(1) = lastEx(1)+lastEx(3)-.5;
                        highEx(2) = pa.height-row*s.gp.found.textHeight;
                        highEx(3) = ex(3)-lastEx(3)+1;
                        highEx(4) = s.gp.found.textHeight;
                        set(ud.highlights(highCol), 'position', highEx, 'Visible', 'on');
                        s.hg.found.activeHighlights = [s.hg.found.activeHighlights ud.highlights(highCol)];
                        if get(ud.highlights(highCol), 'FaceColor') == [1 1 1]
                            matchUD.offset = 0;
                            matchUD.under = ud.highlights(highCol);
                            set(s.hg.found.match, 'position', highEx, 'Visible', 'on', 'UserData', matchUD);
                        end
                        highCol = highCol + 1;
                    end
                    highlight = ~highlight;
                    pa.width = max(pa.width, ex(1)+ex(3));
                    lastEx = ex;
                end
            end
        end
        columnXpos = pa.width + s.gp.buffer;
    end

    set(s.hg.found.propertiesAxes, 'UserData', pa);

    maxWidth = force_column_l(s);

    set(s.hg.context.exploreItem, 'Enable', 'on');

    set(fig, 'UserData', s);

    thisMatch = get(matchUD.under, 'UserData');
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
    if s.sp.totalRows > s.gp.found.rows
        pa.height = s.sp.totalRows*s.gp.found.textHeight;
        pa.offset = 0;
        bottomRow = min(max(s.gp.found.rows, row+(s.gp.found.rows/2)), s.sp.totalRows);
        slide = s.gp.found.rows + s.sp.totalRows - bottomRow;
        set(s.hg.found.sliderV, 'Min',          s.gp.found.rows,...
                                'Max',          s.sp.totalRows,...
                                'Value',        slide,...
                                'Enable',       'on',...
                                'SliderStep',   [1 s.gp.found.rows]/(s.sp.totalRows-s.gp.found.rows));
        set(s.hg.found.propertiesAxes, 'YLim', [slide*s.gp.found.textHeight-s.gp.found.objectHeight slide*s.gp.found.textHeight]);
        set(s.hg.found.fieldsGreyArea, 'Position', [0, -1*s.gp.found.objectHeight, s.gp.found.fieldWidth 2*s.gp.found.objectHeight+pa.height]);
    else
        set(s.hg.found.sliderV, 'Enable',       'off');
        pa.height = s.gp.found.objectHeight;
        pa.offset = s.gp.found.rows - s.sp.totalRows;
        set(s.hg.found.propertiesAxes, 'YLim', [0 s.gp.found.objectHeight]);
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

    % track the match by an offset
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
            row = row+1;
        end

        prev = 0;
        col = 1;
        highCol = 1;
        if row > dims(1) | i.col > dims(2) | ~i.properties(row, i.col)
            i.properties(row, i.col) = text('String',    '',...
                                   'Parent',             i.parent,...
                                   'Interpreter',        'none',...
                                   'UserData',           ud,...
                                   'Clipping',           'on',...
                                   'VerticalAlignment',  'Top');
            i.newRows = 1;
        end

        ud = get(i.properties(row, i.col), 'UserData');
        highLen = length(ud.highlights);


        [first last] = regexp(token, i.searchExpr, i.matchCase);

        for step = 1:length(first)
            ud.rowStrings{col} = token(prev+1:first(step)-1);
            col = col+1;

            fragment = token(first(step):last(step));
            highColor = [.8 .8 .8];
            thisMatch.index = i.matchIndex + offset + first(step);
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

        row = row + 1;
    end

    i.row = row;
    if ~i.found
        i.matchIndex = i.matchIndex+length(property);
    end



%---------------------------------------------------------------------------------------
% Searches the model for the next instance of the search string.
% Parameters:
%   options         bitfield of search options
% Returns:
%    1              if the search was successful
%    0              if no match is found
%   -1              if no match was found and the search was reset
%---------------------------------------------------------------------------------------
function response = search_l(options)
    % get the figure
    fig = find_figure_l;

    % get the current object
    start = current_object_l;

    % get the figure's user data
    s = get(fig, 'UserData');

    % clear all of the highlights and strings
    clear_found_l(s);

    % check for warnings
    if s.notify.warn | s.notify.info
        response = 0;
        return;
    end

    % decompose the options
    options = pad_dec2bin_l(options, s.gp.options.count);

    % get the search expression
    searchExpr = search_options_l(get(s.hg.strings.search, 'String'), options);

    % get the search scope
    topObject = set_scope_l;

    if isempty(topObject)
        toss_warning_l('warning', 'There are no open objects to search');
        response = 0;
        return;
    end

    % find out if we need to reset the search
    resetSearch = reset_search_l;

    % check to see if the search conditions have changed
    if ~isempty(start) & resetSearch
        % start searching from the top
        start = current_object_l([]);
    end

    if ~ishandle(topObject)
        toss_warning_l('warning', 'Search object not found');
        response = 0;
        return;
    end

    % call the inner function for the rest of the search
    object = inner_search_l(start, topObject, searchExpr, options(3));

    % check for a failed reset search
    if ~isempty(object)
        response = 1;
    elseif resetSearch
        response = -1;
    else
        response = 0;
    end

%---------------------------------------------------------------------------------------
% Inner Function for Search
% Parameters:
%   current         the object to start searching from
%   topObject       the toplevel scope for this search
%   searchExpr      the expression to search for
%   caseSensitive   true to search sensitive to case
% Returns:
%   the object in which the search string was found
%---------------------------------------------------------------------------------------
function response = inner_search_l(current, topObject, searchExpr, caseSensitive)

    if isempty(current)
        current = topObject;
        beenThere = 0;
    else
        next = down(current);
        beenThere = 1;
    end

    while (ishandle(current))
        if ~beenThere
            % check this node
            if search_object_l(current, searchExpr, caseSensitive)
                current_object_l(current);
                response = current;
                return;
            end
            next = down(current);
        end % if ~beenThere

        beenThere = 0;

        if isempty(next)
            % no more children, move to siblings, unless this is the top
            if (current == topObject)
                % made it back to the top... done!
                response = [];
                return;
            end
            next = right(current);
            if isempty(next)
                % no more siblings move to parents
                next = up(current);
                beenThere = 1;
            end
        end
        current = next;
        next = [];
    end

    % found nothing
    response = [];



%---------------------------------------------------------------------------------------
% Searches the given object for the next instance of the search string.
% Parameters:
%   object          object to search
%   searchExpr      the expression to search for
%   caseSensitive   true to search sensitive to case
% Returns:
%   1 if the search string was found or 0
%---------------------------------------------------------------------------------------
function response = search_object_l(object, searchExpr, caseSensitive)

    % set up the default response
    response = 0;

    if caseSensitive
        matchCase = 'matchcase';
    else
        matchCase = 'ignorecase';
    end

    % get a list of properties for the object
    properties = get_replace_properties_l(object);

    for index = 1:length(properties)
        property = properties{index};
        try
            value = object.get(property);

            if (~isempty(regexp(value, searchExpr, matchCase, 'once')))
                response = 1;
                return;
            end
        catch
            % invalid property value
        end
    end


%---------------------------------------------------------------------------------------
% Replaces the current match with the replace string.
% Parameters:
%   matchIndex      the index of the first character of the match
%   options         bitfield of search options
% Returns:
%   the index of the first character to start searching for the next match
%---------------------------------------------------------------------------------------
function nextIndex = replace_l(matchIndex, options)
    % initialize the return value
    nextIndex = matchIndex;

    % get the figure
    fig = find_figure_l;

    % get the current object
    item = current_object_l;

    if isempty(item)
        toss_warning_l('warning', 'Match object not found');
        response = 0;
        return;
    end

    % get the figure's user data
    s = get(fig, 'UserData');

    % decompose the options
    options = pad_dec2bin_l(options, s.gp.options.count);

    % get the search expression
    searchExpr = search_options_l(get(s.hg.strings.search, 'String'), options);

    % check to see if the search string has changed
    if reset_search_l
        % replace can't handle this case
        toss_warning_l('warning', 'Search String Changed');
        nextIndex = 0;
        return;
    end

    % get the replace string
    replaceStr = get(s.hg.strings.replace, 'String');

    [searchCase, replaceCase, tokens] = regexp_options_l(options);

    % get a list of properties for the item
    properties = get_replace_properties_l(item);

    for index = 1:length(properties)
        property = properties{index};
        value = item.get(property);
        valueLen = length(value);
        if matchIndex <= valueLen
            matches = regexp(value, searchExpr, searchCase);
            matchIndex = find(matches==matchIndex);

            if isempty(matchIndex)
                matchNotFound = 1;
                break;
            else
                value = regexprep(value, searchExpr, replaceStr, replaceCase, tokens, matchIndex);
                try
                    item.set(property, value);
                    replace_side_effect_l(s, value, valueLen)
                catch
                    toss_warning_l('warning', lasterr);
                end
                return;
            end
        else
            % decriment matchIndex by the length of this value
            matchIndex = matchIndex - length(value);
        end
    end


    toss_warning_l('warning', 'Match not found');
    nextIndex = 0;


%---------------------------------------------------------------------------------------
% Performs some ui side effect for replaces
% Parameters:
%   s                   The figure userdata structure
%   newProperty         The new string
%   oldPropertyLength   The length of the old string
%---------------------------------------------------------------------------------------
function replace_side_effect_l(s, newProperty, oldPropertyLength)
    ud = get(s.hg.found.match, 'UserData');
    ud.offset = ud.offset + length(newProperty) - oldPropertyLength;
    set(s.hg.found.match, 'UserData', ud);
    set(ud.under, 'Visible', 'off');
    thisMatch = get(ud.under, 'UserData');
    newLines = find(newProperty==10);
    thisLine = sum(newLines<thisMatch.index);
    if thisLine<length(newLines)
        endIndex = newLines(thisLine+1)-1;
    else
        endIndex = length(newProperty);
    end
    set(thisMatch.textObject, 'String', newProperty(newLines(thisLine)+1:endIndex));


%---------------------------------------------------------------------------------------
% Replaces all additional occurrances of the search string with the replace string
% Parameters:
%   options         bitfield of search options
%---------------------------------------------------------------------------------------
function replace_all_l(options)
    objects = 0;

    % get the figure
    fig = find_figure_l;

    % get the current object
    item = current_object_l;

    if isempty(item)
        toss_warning_l('warning', 'Match object not found');
        return;
    end

    searchStatus = 1;

    while (searchStatus > 0)
        replace_this_l(options);
        searchStatus = search_l(options);
        objects = objects + 1;
    end

    toss_warning_l('info', ['Edited ' num2str(objects) ' objects']);

%---------------------------------------------------------------------------------------
% Replaces all occurrances of the search string within the current object
%   with the replace string
% Parameters:
%   options         bitfield of search options
%---------------------------------------------------------------------------------------
function replaces = replace_this_l(options)
    % get the figure
    fig = find_figure_l;

    % get the current object
    item = current_object_l;

    if isempty(item)
        toss_warning_l('warning', 'Match object not found');
        return;
    end

    % get the figure's user data
    s = get(fig, 'UserData');

    % decompose the options
    options = pad_dec2bin_l(options, s.gp.options.count);

    % get the search expression
    searchExpr = search_options_l(get(s.hg.strings.search, 'String'), options);

    % check to see if the search string has changed
    if reset_search_l
        % replace can't handle this case
        toss_warning_l('warning', 'Search String Changed');
        return;
    end

    % get the replace string
    replaceStr = get(s.hg.strings.replace, 'String');

    % call the inner function
    inner_replace_this_l(item, searchExpr, replaceStr, options);


%---------------------------------------------------------------------------------------
% Inner Function for Replace This.
% Parameters:
%   item            the object found
%   searchExpr      the search expression
%   replaceStr      the string to replace with
%   options         bitfield of search options
%---------------------------------------------------------------------------------------
function changed = inner_replace_this_l(item, searchExpr, replaceStr, options)
    % initialize the return value
    changed = 0;


    [searchCase, replaceCase, tokens] = regexp_options_l(options);

    % get a list of properties for the item
    properties = get_replace_properties_l(item);

    for index = 1:length(properties)
        property = properties{index};
        try
            value = item.get(property);
        catch
            % invalid property
        end

        if (~isempty(value))
            % replace the matches in this property
            newValue = regexprep(value, searchExpr, replaceStr, replaceCase, tokens);
            if ~strcmp(value, newValue)
                changed = 1;
                try
                    item.set(property, newValue);
                catch
                    % deal with errors
                    disp(lasterr);
                end
            end
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
function set_decide_l
    % get the figure
    fig = find_figure_l;

    % get the figure's user data
    s = get(fig, 'UserData');

    % neutralize the pointer
    set(fig, 'Pointer', 'arrow');

    % set the replace buttons to be active
    set(s.hg.buttons.replace, 'Enable', 'on');
    set(s.hg.buttons.replaceAll, 'Enable', 'on');
    set(s.hg.buttons.replaceThis, 'Enable', 'on');

    % enable the properties menu item
    set(s.hg.context.editProperties, 'Enable', 'on');

    % set the found name to the right color
    set(s.hg.found.name, 'Color', 'blue');


%---------------------------------------------------------------------------------------
% Sets the UI into Idle Mode.  Idle Mode disables the Replace buttons
%---------------------------------------------------------------------------------------
function set_idle_l
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
    set(s.hg.buttons.replace, 'Enable', 'off');
    set(s.hg.buttons.replaceAll, 'Enable', 'off');
    set(s.hg.buttons.replaceThis, 'Enable', 'off');

    % disable the menu items
    set(s.hg.context.editProperties, 'Enable', 'off');
    set(s.hg.context.viewItem, 'Enable', 'off');
    set(s.hg.context.exploreItem, 'Enable', 'off');

    % check for a warning or info
    if s.notify.warn
        % set the warning into the found titlebar
        set(s.hg.found.icon, 'Visible', 'on');
        set(s.hg.found.icon, 'CData', s.icons.warn);
        set(s.hg.found.name, 'String', s.notify.warn, 'UserData', s.notify.warn, 'Color', 'black');
        % clear the warning
        s.notify.warn = '';
        s.notify.info = '';
    elseif s.notify.info
        % set the info into the found titlebar
        set(s.hg.found.icon, 'Visible', 'on');
        set(s.hg.found.icon, 'CData', s.icons.info);
        set(s.hg.found.name, 'String', s.notify.info, 'UserData', s.notify.info, 'Color', 'black');
        % clear the info
        s.notify.info = '';
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

    % reset the axis area
    axesPos = get(s.hg.found.propertiesAxes, 'Position');
    pa.width = axesPos(3);
    pa.height = axesPos(4);
    pa.offset = 0;
    set(s.hg.found.propertiesAxes, 'UserData', pa);
    set(s.hg.found.propertiesAxes, 'YLim', [0 s.gp.found.objectHeight]);

    % clear the current object
    current_object_l([]);

    % clear all of the highlights and strings
    clear_found_l(s);

    % reset the user data
    set(fig, 'UserData', s);



%---------------------------------------------------------------------------------------
% Clears the found fields area
% Parameters:
%   s       The figure userdata structure
%---------------------------------------------------------------------------------------
function clear_found_l(s)
    ud.under = [];
    ud.offset = 0;
    set(s.hg.found.match, 'Visible', 'off', 'UserData', ud);
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
        sl_snr_inject_event('matchWord');
    case 2,
        sl_snr_inject_event('containsWord');
    case 3,
        sl_snr_inject_event('regExp');
    end


%---------------------------------------------------------------------------------------
% Populates the search scope selections
% Parameters:
%   object          the object to select (optional)
% Returns:
%   the current top level scope
%---------------------------------------------------------------------------------------
function scope = set_scope_l (varargin)
    persistent topObject;

    % initialize the return value
    scope = topObject;

    % get the figure
    fig = find_figure_l;

    % nothing to do without a figure
    if isempty(fig)
        return;
    end

    % get the figure's user data
    figData = get(fig, 'UserData');

    % get the optional parameter
    select = [];
    if (nargin == 1)
        select = varargin{1};
        if ishandle(select)
            topObject = select;
            while ~isempty(up(topObject))
                topObject = up(topObject);
            end
        end
    end

    % get the scope menu
    scopeMenu = figData.hg.strings.scope;

    % define the figure title
    figTitle = 'Search & Replace';

    % flag as to whether there is a side effect
    sideEffect = 0;

    root = slroot;

    scopeIterator = root.down;

    % watch out for libraries
    while ~isempty(scopeIterator) & scopeIterator.isLibrary
        scopeIterator = scopeIterator.right;
    end

    % clear everything if there are no scopes
    if isempty(scopeIterator)
        % reset the title
        set(fig, 'Name', figTitle);

        % clear all the info from the uicontrol
        set(scopeMenu, 'UserData', [], 'Value', 1, 'String', ' ');

        % clear topObject
        topObject = [];
        return;
    end

    % ensure that topObject is set
    if isempty(topObject) | ~ishandle(topObject)
        topObject = scopeIterator;
    end

    % get the selection
    data = get(scopeMenu, 'UserData');
    value = get(scopeMenu, 'Value');
    strings = get(scopeMenu, 'String');

    if ~isempty(data)
        newObject = data.objects(value);
        if ~isempty(select)
            if (ischar(select) & strcmp(select, 'select'))
                % toggle expansion
                expanded = find(data.expanded == newObject);
                if (~isempty(expanded))
                    data.expanded(expanded) = [];
                else
                    data.expanded = [data.expanded newObject];
                end
            elseif ~select.isa('Simulink.Root')
                % select the argument
                newObject = select;
            end
        end
        if newObject ~= topObject & ishandle(newObject)
            topObject = newObject;
            sideEffect = 1;
        end
    else
        % first instance, expand models
        modelIterator = down(root);
        data.expanded = [];
        while ~isempty(modelIterator);
            data.expanded = [data.expanded modelIterator];
            modelIterator = right(modelIterator);
        end
        sideEffect = 1;
        if (~isempty(select) & ~ischar(select) & ~select.isa('Simulink.Root'))
            topObject = select;
        end
    end

    scopeIterator = up(topObject);
    rootSys = topObject.name;

    while (~isempty(scopeIterator) & scopeIterator ~= root)
        data.expanded = unique([data.expanded scopeIterator]);
        rootSys = scopeIterator.name;
        scopeIterator = up(scopeIterator);
    end

    strings = {};
    data.objects = [];

    [strings, data] = populate_tree_l(root, -1, strings, data);

    % the index of the topObject
    value = find(data.objects==topObject);
    if isempty(value)
        if isempty(data.objects)
            topObject = [];
            rootSys = '';
        else
            topObject = data.objects(1);
            rootSys = topObject.getDisplayLabel;
        end
        value = 1;
    end


    fullpath = '';
    if ~isempty(topObject)
        try
            fullpath = topObject.getFullName;
            % enhance the figure title
            figTitle =  [figTitle ' - ' fullpath];
        catch
            figTitle =  [figTitle ' - ' topObject.name];
        end
    end

    % enact any side effect if necessary
    if (sideEffect)
        reset_search_l;
    end

    % reset the title and userdata
    set(fig, 'Name', figTitle, 'UserData', figData);

    % set all the info into the uicontrol
    set(scopeMenu, 'UserData', data, 'Value', value, 'String', strings, 'ToolTipString', fullpath);

    % return the topObject
    scope = topObject;


%---------------------------------------------------------------------------------------
% Recusrively populates the tree
%---------------------------------------------------------------------------------------
function [strings, data] = populate_tree_l(current, depth, strings, data)

    tab = 1;
    expand = 0;

    name = current.getDisplayLabel;
    name(name==10) = ' ';
    hierKids = current.getHierarchicalChildren;
    if (isempty(hierKids))
        data.expanded(find(data.expanded==current)) = [];
        prefix = '  ';
    else
        if (find(data.expanded==current))
            prefix = '- ';
            expand = 1;
        else
            prefix = '+ ';
        end
    end
    strings = [strings {[ones(1,depth*tab)*' ' prefix name]}];
    data.objects = [data.objects current];

    for i = 1:length(hierKids)
        kid = hierKids(i);
        if (expand & ~kid.isLibrary)
            [strings, data] = populate_tree_l(kid, depth+1, strings, data);
        end
    end

%---------------------------------------------------------------------------------------
% Initialises/draws the GUI
%---------------------------------------------------------------------------------------
function response = init_GUI_l()

    % see if there already is a figure
    fig = find_figure_l;

    if fig
        revitalize_figure_l(fig);
        response = fig;
        return;
    end

    % initialize the warning and info strings
    s.notify.warn = '';
    s.notify.info = '';

    % screen size etiqette
    units = 'points';
    screenUnits = get(0, 'Units');
    set(0, 'Units', units);
    screenSize = get(0, 'ScreenSize');
    set(0, 'Units', screenUnits);

    % get the UIControl background color so the figure can match it
    backgroundColor = get(0, 'DefaultUIControlBackgroundColor');

    % read in icon data
    s.icons.warn = load_icon_l('warning.bmp');
    s.icons.info = load_icon_l('info.bmp');


    % define graphics parametrically
    s.gp.buttons.width = 50;
    s.gp.labels.width = 60;
    s.gp.options.width = 100;

    s.gp.UIControlHeight = 20;
    s.gp.iconSize = 14;

    fontSize = get(0, 'DefaultTextFontSize');
    fontGap = round(fontSize/5);
    s.gp.found.rows = 8;
    s.gp.found.textHeight = fontSize + fontGap;
    s.gp.found.objectHeight = s.gp.found.rows * s.gp.found.textHeight + fontGap;
    s.gp.found.objectHeightMinimum = 2 * s.gp.found.textHeight + fontGap;
    s.gp.found.replaceThisWidth = 100;
    s.gp.found.fieldWidth = 130;

    editWidthDefault = 200;
    editWidthMinimum = 10;

    % the generic length for greyspace
    s.gp.buffer = 4;

    % default figure size
    figureHeight = 6*s.gp.UIControlHeight+9*s.gp.buffer+s.gp.found.objectHeight+s.gp.found.textHeight;
    figureWidth = 5*s.gp.buffer+s.gp.labels.width+editWidthDefault+s.gp.options.width+s.gp.buttons.width;

    % make sure the initial size is less than 90% of the screen in either direction
    figureWidth = min(figureWidth, .9*screenSize(3));
    figureHeight = min(figureHeight, .9*screenSize(4));

    % minimum figure size
    s.gp.minimumHeight = 6*s.gp.UIControlHeight+9*s.gp.buffer+s.gp.found.objectHeightMinimum+s.gp.found.textHeight;
    s.gp.minimumWidth = 5*s.gp.buffer+s.gp.labels.width+editWidthMinimum+s.gp.options.width+s.gp.buttons.width;

    dim = get(0, 'DefaultFigurePosition');


    % create a figure
    fig = figure('doubleBuffer', 'on',...
                 'MenuBar', 'none',...
                 'Name', 'Search & Replace',...
                 'Tag', 'SL_SNR',...
                 'NumberTitle', 'off',...
                 'Visible', 'off',...
                 'HandleVisibility', 'off',...
                 'IntegerHandle', 'off',...
                 'Color', backgroundColor,...
                 'Units', units,...
                 'DefaultUIControlUnits', units,...
                 'ResizeFcn', 'slsnr resize;',...
                 'KeyPressFcn', 'slsnr key_press;',...
                 'WindowButtonDownFcn', 'sl_snr_inject_event mouse_down;',...
                 'WindowButtonUpFcn', 'sl_snr_inject_event mouse_up;',...
                 'WindowButtonMotionFcn', 'sl_snr_inject_event mouse_moved;',...
                 'CloseRequestFcn', 'slsnr cancel;',...
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
    s.hg.context.menu = uicontextmenu(  'Parent',               fig);

    s.hg.context.viewItem = uimenu(     'Parent',               s.hg.context.menu,...
                                        'Label',                'Edit',...
                                        'Callback',             'sl_snr_inject_event view;',...
                                        'Enable',               'off');

    s.hg.context.exploreItem = uimenu(  'Parent',               s.hg.context.menu,...
                                        'Label',                'Explore',...
                                        'Callback',             'sl_snr_inject_event explore;',...
                                        'Enable',               'off');

    s.hg.context.editProperties = uimenu('Parent',               s.hg.context.menu,...
                                        'Label',                'Properties',...
                                        'Callback',             'sl_snr_inject_event properties;',...
                                        'Enable',               'off');


    % ---Buttons----------------------------------------------------------------------------------------------
    s.hg.buttons.search = uicontrol(    'String',               sprintf('Search'),...
                                        'Parent',               fig,...
                                        'Style',                'pushbutton',...
                                        'CallBack',             'sl_snr_inject_event search;');

    s.hg.buttons.replace = uicontrol(   'String',               sprintf('Replace'),...
                                        'Parent',               fig,...
                                        'Style',                'pushbutton',...
                                        'CallBack',             'sl_snr_inject_event replace;');

    s.hg.buttons.replaceAll = uicontrol('String',               sprintf('Replace all'),...
                                        'Parent',               fig,...
                                        'Style',                'pushbutton',...
                                        'CallBack',             'sl_snr_inject_event replaceAll;');

    s.hg.buttons.help = uicontrol(      'String',               'Help',...
                                        'Parent',               fig,...
                                        'Style',                'pushbutton',...
                                        'CallBack',             'slsnr help;');

    s.hg.buttons.cancel = uicontrol(    'String',               'Close',...
                                        'Parent',               fig,...
                                        'Style',                'pushbutton',...
                                        'CallBack',             'slsnr cancel;');


    % ---String-Inputs----------------------------------------------------------------------------------------
    s.hg.strings.search = uicontrol(    'Style',                'edit',...
                                        'Parent',               fig,...
                                        'HorizontalAlignment',  'Left',...
                                        'BackgroundColor',      'white');

    s.hg.strings.replace = uicontrol(   'Style',                'edit',...
                                        'Parent',               fig,...
                                        'HorizontalAlignment',  'Left',...
                                        'BackgroundColor',      'white');


    % ---String-Labels----------------------------------------------------------------------------------------
    s.hg.labels.search = text(            [0], [0], sprintf('Search for:'),...
                                        'Parent',               s.hg.axes,...
                                        'Interpreter',          'none',...
                                        'VerticalAlignment',    'Middle',...
                                        'Clipping',             'off',...
                                        'FontSize',             fontSize-1,...
                                        'HorizontalAlignment',  'Left');

    s.hg.labels.replace = text(           [0], [0],  sprintf('Replace with:'),...
                                        'Parent',               s.hg.axes,...
                                        'Interpreter',          'none',...
                                        'VerticalAlignment',    'Middle',...
                                        'Clipping',             'off',...
                                        'FontSize',             fontSize-1,...
                                        'HorizontalAlignment',  'Left');


    s.hg.labels.scope = text(             [0], [0], sprintf('Search in:'),...
                                        'Parent',               s.hg.axes,...
                                        'Interpreter',          'none',...
                                        'VerticalAlignment',    'Middle',...
                                        'Clipping',             'off',...
                                        'FontSize',             fontSize-1,...
                                        'HorizontalAlignment',  'Left');


    % ---Search-Scope-----------------------------------------------------------------------------------------
    s.hg.strings.scope = uicontrol('Style',     'popupmenu',...
                                        'Parent',               fig,...
                                        'Visible',              'on',...
                                        'BackgroundColor',      'white',...
                                        'HorizontalAlignment',  'Left',...
                                        'FontName',             'FixedWidth',...
                                        'String',               {sprintf('temp')},...
                                        'CallBack',             'slsnr set_scope;');

    % ---Search-Options---------------------------------------------------------------------------------------
    s.gp.options.count = 4;

    s.hg.options.searchOption = uicontrol('Style',              'popupmenu',...
                                        'Parent',               fig,...
                                        'Visible',              'on',...
                                        'BackgroundColor',      'white',...
                                        'HorizontalAlignment',  'Left',...
                                        'String',               {sprintf('Match whole word'), sprintf('Contains word'), sprintf('Regular expression')},...
                                        'Value',                2,...
                                        'CallBack',             'slsnr set_option;');


    s.hg.options.matchCase = uicontrol('Style',             'checkbox',...
                                        'Parent',               fig,...
                                        'Visible',              'on',...
                                        'HorizontalAlignment',  'Left',...
                                        'String',               sprintf('Match case'),...
                                        'TooltipString',        sprintf('Match case'),...
                                        'CallBack',             'sl_snr_inject_event matchCase;');


    s.hg.options.preserveCase = uicontrol('Style',          'checkbox',...
                                        'Parent',               fig,...
                                        'Visible',              'on',...
                                        'HorizontalAlignment',  'Left',...
                                        'String',               sprintf('Preserve case'),...
                                        'TooltipString',        sprintf('Preserve case'),...
                                        'CallBack',             'sl_snr_inject_event preserveCase;');



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
                                        'ButtonDownFcn',        'sl_snr_inject_event view;',...
                                        'Parent',               s.hg.axes,...
                                        'Interpreter',          'none',...
                                        'FontWeight',           'Bold');

    s.hg.buttons.replaceThis = uicontrol( 'String',             sprintf('Replace all in this object'),...
                                        'Parent',               fig,...
                                        'Style',                'pushbutton',...
                                        'CallBack',             'sl_snr_inject_event replaceThis;');

    pa.height = s.gp.found.objectHeight;
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
                                        'YLim',                 [0 s.gp.found.objectHeight],...
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

    s.hg.found.sliderV = uicontrol(     'Style',                'slider',...
                                        'Parent',               fig,...
                                        'Enable',              'off',...
                                        'CallBack',             'slsnr slide_v;');

    s.hg.found.sliderH = uicontrol(     'Style',                'slider',...
                                        'Parent',               fig,...
                                        'Enable',              'off',...
                                        'CallBack',             'slsnr slide_h;');

    ud.under = [];
    ud.offset = 0;
    s.hg.found.match = rectangle(       'FaceColor',            'black',...
                                        'EraseMode',            'xor',...
                                        'Visible',              'off',...
                                        'EdgeColor',            'none',...
                                        'Clipping',             'on',...
                                        'UserData',             ud,...
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

    set(fig, 'Visible', 'on');

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
    set(s.hg.found.propertiesAxes, 'YLim', [slide*s.gp.found.textHeight-s.gp.found.objectHeight slide*s.gp.found.textHeight]);


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
    case 'found',
        if yPos < s.gp.found.YHigh & yPos > s.gp.found.YLow & xPos > s.gp.buffer & xPos < position(3)-s.gp.buffer
            response = 1;
        end
    end

    set_scope_l;

%---------------------------------------------------------------------------------------
% Pops the context menu
%---------------------------------------------------------------------------------------
function pop_menu_l
    % get the figure
    fig = find_figure_l;

    s = get(fig, 'UserData');
    units = get(fig, 'Units');
    set(fig, 'Units', 'pixels');
    currentPoint = get(fig, 'CurrentPoint');
    set(fig, 'Units', units);
    set(s.hg.context.menu, 'Position', currentPoint, 'Visible', 'on');

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
        forceRow = round(forcePos(2)/s.gp.found.textHeight);
    else
        forceRow = -1;
    end

    s.gp.found.rows = s.gp.found.rows - moveRows;
    s.gp.found.objectHeight = s.gp.found.objectHeight-moveRows*s.gp.found.textHeight;

    % get the axes Y range
    yl = ylim(s.hg.found.propertiesAxes);

    yl(1) = yl(1) + moveRows*s.gp.found.textHeight;
    if yl(1) < 0 & yl(2) < pa.height
        adjust = min(-1*yl(1), pa.height-yl(2));
        yl = yl + adjust;
        slide = min(slide+round(adjust/s.gp.found.textHeight), s.sp.totalRows)-pa.offset;
    else
        adjust = slide-s.gp.found.rows-forceRow;
        if adjust > 0 & adjust <= moveRows
            yl = yl - adjust*s.gp.found.textHeight;
            slide = max(slide-adjust, s.gp.found.rows)-pa.offset;
        else
            slide = slide-pa.offset;
        end
    end

    if s.sp.totalRows > s.gp.found.rows
        set(s.hg.found.sliderV, 'Min',          s.gp.found.rows+pa.offset,...
                                'Max',          s.sp.totalRows+pa.offset,...
                                'Value',        slide+pa.offset,...
                                'Enable',       'on',...
                                'SliderStep',   [1 s.gp.found.rows]/(s.sp.totalRows-s.gp.found.rows));
    else
        set(s.hg.found.sliderV, 'Enable',       'off');
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
    if position(3) < s.gp.minimumWidth | position(4) < s.gp.minimumHeight
        set(s.hg.blanket, 'Position', [0 0 position(3) position(4)], 'Visible', 'on');
        set(fig, 'WindowButtonMotionFcn', 'slsnr yank_blanket;');
        return;
    else
        set(s.hg.blanket, 'Visible', 'off');
        set(fig, 'WindowButtonMotionFcn', 'sl_snr_inject_event mouse_moved;');
    end


    % --------------------------------------------------------------------------------------------------------
    % ---Buttons----------------------------------------------------------------------------------------------
    % --------------------------------------------------------------------------------------------------------
    buttonX = position(3)-s.gp.buffer-s.gp.buttons.width;
    set(s.hg.buttons.search,     'Position', [buttonX position(4)-1*(s.gp.buffer+s.gp.UIControlHeight) s.gp.buttons.width s.gp.UIControlHeight]);
    set(s.hg.buttons.replace,    'Position', [buttonX position(4)-2*(s.gp.buffer+s.gp.UIControlHeight) s.gp.buttons.width s.gp.UIControlHeight]);
    set(s.hg.buttons.replaceAll, 'Position', [buttonX position(4)-3*(s.gp.buffer+s.gp.UIControlHeight) s.gp.buttons.width s.gp.UIControlHeight]);
    set(s.hg.buttons.help,       'Position', [buttonX position(4)-4*(s.gp.buffer+s.gp.UIControlHeight) s.gp.buttons.width s.gp.UIControlHeight]);
    set(s.hg.buttons.cancel,     'Position', [buttonX position(4)-5*(s.gp.buffer+s.gp.UIControlHeight) s.gp.buttons.width s.gp.UIControlHeight]);


    % --------------------------------------------------------------------------------------------------------
    % ---Search-Options-----------------------------------------------------------------------------------------
    % --------------------------------------------------------------------------------------------------------
    optionsX = buttonX-s.gp.buffer-s.gp.options.width;
    set(s.hg.options.matchCase,    'Position', [optionsX position(4)-1*(s.gp.buffer+s.gp.UIControlHeight) s.gp.options.width s.gp.UIControlHeight]);
    set(s.hg.options.preserveCase, 'Position', [optionsX position(4)-2*(s.gp.buffer+s.gp.UIControlHeight) s.gp.options.width s.gp.UIControlHeight]);
    set(s.hg.options.searchOption, 'Position', [optionsX position(4)-3*(s.gp.buffer+s.gp.UIControlHeight) s.gp.options.width s.gp.UIControlHeight]);


    % --------------------------------------------------------------------------------------------------------
    % ---Search-Strings---------------------------------------------------------------------------------------
    % --------------------------------------------------------------------------------------------------------
    editX = 2*s.gp.buffer+s.gp.labels.width;
    editWidth = optionsX-editX-s.gp.buffer;
    set(s.hg.strings.search,  'Position', [editX position(4)-1*(s.gp.buffer+s.gp.UIControlHeight) editWidth s.gp.UIControlHeight]);
    set(s.hg.strings.replace, 'Position', [editX position(4)-2*(s.gp.buffer+s.gp.UIControlHeight) editWidth s.gp.UIControlHeight]);
    set(s.hg.strings.scope,   'Position', [editX position(4)-3*(s.gp.buffer+s.gp.UIControlHeight) editWidth s.gp.UIControlHeight]);


    % --------------------------------------------------------------------------------------------------------
    % ---Search-Labels----------------------------------------------------------------------------------------
    % --------------------------------------------------------------------------------------------------------
    set(s.hg.labels.search,  'Position', [s.gp.buffer position(4)-1*(s.gp.buffer+s.gp.UIControlHeight)+s.gp.UIControlHeight/2]);
    set(s.hg.labels.replace, 'Position', [s.gp.buffer position(4)-2*(s.gp.buffer+s.gp.UIControlHeight)+s.gp.UIControlHeight/2]);
    set(s.hg.labels.scope,   'Position', [s.gp.buffer position(4)-3*(s.gp.buffer+s.gp.UIControlHeight)+s.gp.UIControlHeight/2]);


    % --------------------------------------------------------------------------------------------------------
    % ---Found-Object-Panel-----------------------------------------------------------------------------------
    % --------------------------------------------------------------------------------------------------------
    found.top = position(4)-5*(s.gp.buffer+s.gp.UIControlHeight)-s.gp.buffer;
    found.bottom = found.top-3*s.gp.buffer-s.gp.UIControlHeight-s.gp.found.objectHeight-s.gp.found.textHeight;
    moveRows = -1*floor(found.bottom/s.gp.found.textHeight);
    moveRows = min(moveRows, s.gp.found.rows-2);
    if moveRows
        set(fig, 'UserData', s);
        s = resize_found_l(moveRows);
    end

    set(s.hg.found.breakDark,  'XData', [s.gp.buffer position(3)-s.gp.buffer], 'YData', [found.top   found.top]);
    set(s.hg.found.breakLight, 'XData', [s.gp.buffer position(3)-s.gp.buffer], 'YData', [found.top-1 found.top-1]);

    replaceThisX = position(3)-s.gp.buffer-s.gp.found.replaceThisWidth;

    iconOffset = (s.gp.UIControlHeight-s.gp.iconSize)/2;
    iconX = s.gp.buffer + iconOffset;
    iconY = found.top-s.gp.buffer-s.gp.UIControlHeight+iconOffset;
    set(s.hg.found.icon, 'XData', [iconX iconX+s.gp.iconSize], 'Ydata', [iconY iconY+s.gp.iconSize]);

    nameX = 2*s.gp.buffer + s.gp.UIControlHeight;
    set(s.hg.found.name,          'Position', [nameX        found.top-s.gp.buffer-s.gp.UIControlHeight/2]);
    set(s.hg.buttons.replaceThis, 'Position', [replaceThisX found.top-s.gp.buffer-s.gp.UIControlHeight s.gp.found.replaceThisWidth s.gp.UIControlHeight]);

    % trim the width of the name
    s.gp.found.nameWidth = replaceThisX - nameX - s.gp.buffer;
    trim_name_l(s);

    s.gp.found.YHigh = found.top-2*s.gp.buffer-s.gp.UIControlHeight;
    s.gp.found.YLow = s.gp.found.YHigh-s.gp.found.objectHeight-s.gp.found.textHeight;
    found.XLeft = s.gp.buffer;
    found.XRight = position(3)-s.gp.buffer;

    found.Width = found.XRight-found.XLeft-s.gp.found.textHeight;

    set(s.hg.found.propertiesAxes, 'position', [found.XLeft s.gp.found.YLow+s.gp.found.textHeight found.Width s.gp.found.objectHeight]);

    propertiesX = get(s.hg.found.propertiesAxes, 'Xlim');
    propertiesY = get(s.hg.found.propertiesAxes, 'Ylim');
    propertiesX(2) = propertiesX(1) + found.Width;
    set(s.hg.found.propertiesAxes, 'XLim', propertiesX);

    pa = get(s.hg.found.propertiesAxes, 'UserData');

    set(s.hg.found.propertiesDark,  'XData', [found.XLeft-1     found.XLeft-1      found.XRight],...
                                    'YData', [s.gp.found.YLow   s.gp.found.YHigh+1 s.gp.found.YHigh+1]);
    set(s.hg.found.propertiesLight, 'XData', [found.XLeft-1     found.XRight+1     found.XRight+1],...
                                    'YData', [s.gp.found.YLow-1 s.gp.found.YLow-1  s.gp.found.YHigh+1]);

    set(s.hg.found.sliderV,         'position', [found.XRight-s.gp.found.textHeight s.gp.found.YLow+s.gp.found.textHeight s.gp.found.textHeight s.gp.found.objectHeight]);
    set(s.hg.found.sliderH,         'position', [found.XLeft s.gp.found.YLow found.Width s.gp.found.textHeight]);

    set(s.hg.found.fieldsGreyArea,  'Position', [0, -1*s.gp.found.objectHeight, s.gp.found.fieldWidth 2*s.gp.found.objectHeight+pa.height]);

    found.textX = s.gp.found.fieldWidth+s.gp.buffer;

    if pa.width > found.Width
        forcePos = get(s.hg.found.match, 'Position');
        rightView = max(found.Width, forcePos(1)+forcePos(3));
        sliderLength = pa.width-found.Width;
        set(s.hg.found.sliderH, 'Min',          found.Width,...
                                'Max',          pa.width,...
                                'Value',        rightView,...
                                'Enable',       'on',...
                                'SliderStep',   [min(s.gp.buffer, sliderLength)/sliderLength found.Width/sliderLength ]);
        set(s.hg.found.propertiesAxes, 'XLim', [rightView-found.Width rightView]);
    else
        set(s.hg.found.sliderH, 'Enable',       'off');
        set(s.hg.found.propertiesAxes, 'XLim', [0 found.Width]);
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
    str = dec2bin(dec);

    % get the pad length
    pad = len - length(str);

    % pad the string if necessary
    if pad > 0
        str = [ones(1,pad)*'0' str];
    end

    response = str == '1';



%---------------------------------------------------------------------------------------
% Trims the path/name for the found item.
% Parameters:
%   s       The user data for the SNR figure
%---------------------------------------------------------------------------------------
function trim_name_l(s)
    fullName = get(s.hg.found.name, 'UserData');
    if ~isempty(fullName)
        strLen = length(fullName);
        set(s.hg.found.name, 'String', fullName);
        extent = get(s.hg.found.name, 'extent');
        index = 1;
        while extent(3) > s.gp.found.nameWidth
            index = index+1;
            set(s.hg.found.name, 'String', ['...' fullName(index: strLen)]);
            extent = get(s.hg.found.name, 'extent');
        end
    end


%---------------------------------------------------------------------------------------
% Modifies the search expression based on the search options
% Parameters:
%   searchExpr      the search expression as specified by the user
%   options         bitfield of search options
% Returns:
%   the augmented search expression
%---------------------------------------------------------------------------------------
function searchExpr = search_options_l(searchExpr, options)
    persistent lastExpr;
    persistent lastOptions;

    if ~isequal(lastExpr, searchExpr) | ~isequal(lastOptions, options)
        lastExpr = searchExpr;
        lastOptions = options;
        reset_search_l;
    end

    if ~(options(2) | options(1))
        searchExpr = regexprep(searchExpr, '([$^.\\*+[\](){}?|])', '\$1', 'tokenize');
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
%   tokens          'tokenize' or replaceCase
%---------------------------------------------------------------------------------------
function [searchCase, replaceCase, tokens] = regexp_options_l(options)
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
    if options(2)
        tokens = 'tokenize';
    else
        tokens = replaceCase;
    end


%---------------------------------------------------------------------------------------
% Loads data for an icon for a given object
% Parameters:
%   An object to get an icon for
% Returns:
%   a matrix of RGB for the icon data.
%---------------------------------------------------------------------------------------
function iconData = get_icon_l(object)
    persistent icons;

    if isempty(icons)
        icons.default = imread([matlabroot filesep 'toolbox' filesep 'simulink' filesep 'dastudio' filesep 'resources' filesep 'Default.png']);
    end

    type = object.getDisplayClass;
    type(find(type=='.')) = [];

    if isfield(icons, type)
        iconData = getfield(icons, type);
    else
        iconPath = object.getDisplayIcon;
        if isempty(iconPath)
            iconData = icons.default;
        else
            iconPath = regexprep(iconPath, '[\\/]', filesep);
            [d m] = imread([matlabroot filesep iconPath]);
            d = double(flipud(d));
            dims = size(d);
            for row = 1:dims(1)
                for col = 1:dims(2)
                    iconData(row, col,:) = m(d(row, col)+1,:);
                end
            end
            iconData = wash_icon_l(iconData);
            icons = setfield(icons, type, iconData);
        end
    end


%---------------------------------------------------------------------------------------
% Loads data for an icon from a specified image file.
% Parameters:
%   name        The name of the file, relative to matlabroot.
% Returns:
%   a matrix of RGB for the icon data.
%---------------------------------------------------------------------------------------
function iconData = load_icon_l(name)

    iconData = imread([matlabroot filesep 'toolbox' filesep 'simulink' filesep 'dastudio' filesep 'resources' filesep name], 'bmp');

    iconData(:,:,1) = flipud(iconData(:,:,1));
    iconData(:,:,2) = flipud(iconData(:,:,2));
    iconData(:,:,3) = flipud(iconData(:,:,3));
    iconData = wash_icon_l(iconData);

%---------------------------------------------------------------------------------------
% Forces the background of an image to the default background color.
% Assumes the color in the top left corner of the image is the background for that image
% Parameters:
%   iconData    A matrix of RGB for the icon data.
% Returns:
%   the matrix of RGB for the icon data washed out.
%---------------------------------------------------------------------------------------
function iconData = wash_icon_l(iconData)
    persistent background;

    if isempty(background)
        background = get(0, 'DefaultUIControlBackgroundColor');

        % denormalize if necessary
        if mean(background(:)) < 1
            background = uint8(background*255);
        end
    end

    % denormalize if necessary
    if mean(iconData(:)) < 1
        iconData = uint8(iconData*255);
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

    iconData(:,:,1) = red;
    iconData(:,:,2) = green;
    iconData(:,:,3) = blue;


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
        if isempty(s.notify.info)
            s.notify.info = warn;
        end
    case 'warning',
        if isempty(s.notify.warn)
            s.notify.warn = warn;
        end
    end

    % set the user data
    set(fig, 'UserData', s);


%---------------------------------------------------------------------------------------
% Focuses the item in the explorer
%---------------------------------------------------------------------------------------
function explore_item_l

    item = current_object_l;

    if (isempty(item))
        return;
    end

    me = DAStudio.ModelExplorer;
    me.selected = item.handle;


%---------------------------------------------------------------------------------------
% Pops the properties dialog for the current item
%---------------------------------------------------------------------------------------
function edit_item_properties_l

    item = current_object_l;

    if (isempty(item))
        return;
    end

    open_system(item.handle);


%---------------------------------------------------------------------------------------
% Determines if an object can be viewed in the editor
% Returns:
%   true        If the item has a valid representation in the editor.
%---------------------------------------------------------------------------------------
function response = is_viewable_l
    item = current_object_l;

    if (isempty(item))
        response = 0;
        return;
    end

    response = 1;



%---------------------------------------------------------------------------------------
% Focuses the view on the item in the editor
%---------------------------------------------------------------------------------------
function view_item_l

    item = current_object_l;

    if (isempty(item))
        return;
    end

    open_system(item.handle);


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
    set(fig,    'WindowButtonMotionFcn',    'sl_snr_inject_event mouse_moved;',...
                'Position',                 position);


%---------------------------------------------------------------------------------------
% Revitalizes the figure
% Parameters:
%   fig     the figure to revitalize
%---------------------------------------------------------------------------------------
function revitalize_figure_l(fig);
    resize_l;
    yank_blanket_l;


%---------------------------------------------------------------------------------------
% Calculates if enough time has elapsed since the last call.
% Returns:
%   true if the time elapsed is greater than the threshold
%---------------------------------------------------------------------------------------
function response = enough_time_elapsed_l
    persistent timeStamp;

    response = 0;
    currentTime = clock;

    if (isempty(timeStamp) | (etime(currentTime, timeStamp) > .4))
        timeStamp = currentTime;
        response = 1;
    end


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

    if strcmp(modifier{1}, 'control')
        switch key,
        case 'i',
            sl_snr_inject_event('view');
        case 'r',
            sl_snr_inject_event('explore');
        case 'p',
            sl_snr_inject_event('properties');
        case 'w',
            slsnr('cancel');
        end
    else
        switch key,
        case 'escape',
            % hide the drag line
            set(s.hg.found.dragLine, 'Visible', 'off');
            sl_snr_inject_event('escape');
        case 'f3',
            sl_snr_inject_event('search');
        end
    end


%---------------------------------------------------------------------------------------
% Persistent holder for the current object
%---------------------------------------------------------------------------------------
function response = current_object_l(varargin)
    persistent object;

    if nargin == 1
        object = varargin{1};
    elseif isempty(object) | ~ishandle(object),
        object = [];
    end

    response = object;


%---------------------------------------------------------------------------------------
% Persistent holder for the figure
%---------------------------------------------------------------------------------------
function response = find_figure_l(varargin)
    persistent fig;

    % get a list of existing snr figures
    figs = findall(0, 'type', 'figure', 'tag', 'SL_SNR');

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
% Persistent dirty flag for the search
%---------------------------------------------------------------------------------------
function varargout = reset_search_l
    persistent resetSearch;

    if nargout == 1
        if isempty(resetSearch)
            resetSearch = 0;
        end
        varargout{1} = resetSearch;
        resetSearch = 0;
    else
        resetSearch = 1;
    end


