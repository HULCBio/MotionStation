function fig = state_print_fig(stateID, displayTitle)

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/15 01:00:41 $

    if sf('get', stateID, '.isa')==sf('get', 'default','state.isa');
        chartID = sf('get',stateID,'.chart');
    else
        chartID = stateID;
        if is_eml_chart(chartID)
            stateID = eml_fcns_in(chartID);
        elseif is_truth_table_chart(chartID)
            stateID = truth_tables_in(chartID);
        else
            fig = [];
            return;
        end
    end

    if is_eml_fcn(stateID)
        is_truth_table = 0;
        title = 'Embedded MATLAB Display';
    elseif is_truth_table_fcn(stateID)
        is_truth_table = 1;
        title = 'Truth Table Display';
    else
        fig = [];
        return;
    end

    portrait = isequal(get_param(bdroot(sf('Private', 'chart2block', chartID)), 'PaperOrientation'), 'portrait');

    i.fieldStrings = {};
    i.row = 1;
    i.col = 1;
    i.properties = {};

    if is_truth_table
        iterator = iterate_truth_table_l(stateID, 'next');

        [rows cols] = size(iterator.predicateArray);
        columnNames = {'Description', 'Condition'};
        numCols = length(columnNames);
        for col = numCols+1:cols
            columnNames{col} = int2str(rem(col-numCols,10));
        end

        conditionHeader = i.row;
        i.row = i.row + 1;
        conditionRow = i.row;
        [i iterator] = dismantle_table_l(columnNames, i, iterator);

        % remove the label from the last row
        i.fieldStrings{i.row-1} = [];

        actionHeader = i.row;
        i.row = i.row + 1;
        actionRow = i.row;
        columnNames = {'Description', 'Action'};
        [i iterator] = dismantle_table_l(columnNames, i, iterator);
    else
        script = get_eml_script_l(stateID);

        if script
            i = dismantle_property_l (script, '', i);
        end
    end

    units = 'points';

    fontSize = get(0, 'DefaultTextFontSize');
    fontGap = round(fontSize/5);
    textHeight = fontSize + fontGap;

    totalRows = i.row-1;
    pa.width = 0;
    pa.height = totalRows*textHeight;
    foundTextX = 20;
    buffer = 4;

    % create a figure
    fig = figure('doubleBuffer', 'on',...
                 'MenuBar', 'none',...
                 'Name', title,...
                 'NumberTitle', 'off',...
                 'Color', [.9 .9 .9],...
                 'Visible', 'off',...
                 'IntegerHandle', 'off',...
                 'Units', units);


    displayAxes = axes(                 'Color',               'white',...
                                        'Parent',               fig,...
                                        'units',                units,...
                                        'visible',              'on',...
                                        'gridlineStyle',        'none',...
                                        'XTick',                [],...
                                        'YTick',                [],...
                                        'XLim',                 [0 1000],...
                                        'YLim',                 [0 1000]);


    fieldsGreyArea = rectangle(         'FaceColor',            [.9 .9 .9],...
                                        'EdgeColor',            'none',...
                                        'Clipping',             'on',...
                                        'Parent',               displayAxes);

    if is_truth_table
        conditionsGreyArea = rectangle(     'FaceColor',            [.9 .9 .9],...
                                            'EdgeColor',            'none',...
                                            'Clipping',             'on',...
                                            'Parent',               displayAxes);

        actionsGreyArea = rectangle(        'FaceColor',            [.9 .9 .9],...
                                            'EdgeColor',            'none',...
                                            'Clipping',             'on',...
                                            'Parent',               displayAxes);

        conditionsHeaderArea = rectangle(   'FaceColor',            [.8 .8 .8],...
                                            'EdgeColor',            'none',...
                                            'Clipping',             'on',...
                                            'Parent',               displayAxes);

        actionsHeaderArea = rectangle(      'FaceColor',            [.8 .8 .8],...
                                            'EdgeColor',            'none',...
                                            'Clipping',             'on',...
                                            'Parent',               displayAxes);
    end

    [propertyRows propertyCols] = size(i.properties);

    if propertyRows > length(i.fieldStrings)
        i.fieldStrings{propertyRows} = [];
    end
    for row = 1:propertyRows
        if ~isempty(i.fieldStrings{row})
            text(foundTextX-buffer, pa.height-(row-1)*textHeight, i.fieldStrings{row},...
                 'Parent',               displayAxes,...
                 'Interpreter',          'none',...
                 'VerticalAlignment',    'Top',...
                 'Clipping',             'on',...
                 'HorizontalAlignment',  'Right');
        end
    end

    columnXpos = foundTextX;
    for propertyCol = 1:propertyCols
        for row = 1:propertyRows
            if ~isempty(i.properties{row, propertyCol})
                property = text(columnXpos, pa.height-(row-1)*textHeight, i.properties{row, propertyCol},...
                                'Parent',             displayAxes,...
                                'Units',              units,...
                                'Interpreter',        'none',...
                                'Clipping',           'on',...
                                'VerticalAlignment',  'Top');
                ex = get(property, 'Extent');
                pa.width = max(pa.width, ex(1)+ex(3));
            end
        end
        columnXpos = pa.width + buffer;
    end

    set(displayAxes,    'Position', [buffer buffer pa.width pa.height],...
                        'XLim', [0 pa.width],...
                        'YLim', [0 pa.height]);

    if displayTitle
        title = text(       'Interpreter',          'none',...
                            'String', sf('FullNameOf', stateID, '.'));
        set(displayAxes, 'Title', title);
        titleExtent = get(title, 'Extent');
    else
        titleExtent = zeros(1,4);
    end

    set(fig, 'Position', [buffer buffer pa.width+2*buffer pa.height+2*buffer+titleExtent(4)]);

    paperUnits = get(fig, 'PaperUnits');
    set(fig, 'PaperUnits', 'points');
    paperSizeInPoints = get(fig, 'PaperSize');
    set(fig, 'PaperUnits', paperUnits);
    paperSize = get(fig, 'PaperSize');
    paperScale = mean(paperSizeInPoints./paperSize);

    width = (pa.width+2*buffer)/paperScale;
    height = (pa.height+2*buffer+titleExtent(4))/paperScale;

    if ~portrait
        set(fig, 'PaperOrientation', 'landscape');
        paperSize = fliplr(paperSize);
    end

    paperPosition(1) = (paperSize(1)-width)/2;
    paperPosition(2) = (paperSize(2)-height)/2;
    paperPosition(3) = width;
    paperPosition(4) = height;
    set(fig, 'PaperPosition', paperPosition);

    line([0 pa.width pa.width], [pa.height pa.height 0],'Parent', displayAxes, 'color', 'black');

    set(fieldsGreyArea,     'Position', [0, 0, foundTextX pa.height]);

    if is_truth_table
        set(conditionsGreyArea, 'Position', [0, pa.height-conditionRow*textHeight, pa.width textHeight]);
        set(conditionsHeaderArea, 'Position', [0, pa.height-conditionHeader*textHeight, pa.width textHeight]);
        text(buffer, pa.height-(conditionHeader-1)*textHeight, 'Condition Table:',...
             'Parent',               displayAxes,...
             'Interpreter',          'none',...
             'VerticalAlignment',    'Top',...
             'FontWeight',           'Bold',...
             'Clipping',             'on');
        set(actionsGreyArea,    'Position', [0, pa.height-actionRow*textHeight,    pa.width textHeight]);
        set(actionsHeaderArea,    'Position', [0, pa.height-actionHeader*textHeight,    pa.width textHeight]);
        text(buffer, pa.height-(actionHeader-1)*textHeight, 'Action Table:',...
             'Parent',               displayAxes,...
             'Interpreter',          'none',...
             'VerticalAlignment',    'Top',...
             'FontWeight',           'Bold',...
             'Clipping',             'on');
    end

%---------------------------------------------------------------------------------------
% Adds all the fields of a table to the properties list
% Parameters:
%   columnNames a cell array of strings to use as column headers
%   i           the structure of iterative data used by dismantle_property_l
% Returns:
%   i           the structure of iterative data incremented as necessary
%---------------------------------------------------------------------------------------
function [i, iterator] = dismantle_table_l (columnNames, i, iterator)
    i.readonly = 1;
    for col = 1:length(columnNames)
        i.col = col;
        i = dismantle_property_l (columnNames{col}, [], i);
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
                iterator = iterate_truth_table_l(iterator, 'next');
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

        % increment the row & offset for any additional newlines
        while (offset < length(property) & property(offset+1) == 10)
            offset = offset+1;
            if isempty(field)
                i.fieldStrings{row} = [sf_scalar2str(row-i.row+1) ':'];
            end
            row = row+1;
        end

        prev = 0;
        col = 1;

        % advance the offset to the beginning of the next match
        offset = offset + length(token);

        % set the string for this row
        i.properties{row, i.col} = token;

        if isempty(field)
            i.fieldStrings{row} = [sf_scalar2str(row-i.row+1) ':'];
        end

        row = row + 1;
    end

    i.row = row;


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
        
        if isempty(iterator.predicateArray)
            iterator.predicateArray = truth_table_man('construct_initial_predicate_table');
        end
        
        if isempty(iterator.actionArray)
            iterator.actionArray = truth_table_man('construct_initial_action_table');
        end
        
        iterator.index = 0;
    end

    if strcmpi(action, 'next')
        iterator.index = iterator.index + 1;
    end

    currentArray = [];

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
    end

    if isempty(currentArray);
        iterator.index = [];
        return;
    end

    iterator.currentArray = getfield(iterator, currentArray);

    if strcmpi(action, 'set')
        iterator.currentArray{iterator.row, iterator.col} = iterator.value;
        iterator = setfield(iterator, currentArray, iterator.currentArray);
        sf('set', iterator.truthTableID, ['.truthTable.' currentArray], iterator.currentArray);
    else
        iterator.value = iterator.currentArray{iterator.row, iterator.col};
    end
