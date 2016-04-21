function htmlStr = state2html(stateID)

    if is_eml_script(stateID)
        htmlStr = eml2html(0, stateID);
        return;
    end

    if sf('get', stateID, '.isa')==sf('get', 'default','state.isa');
        chartID = sf('get',stateID,'.chart');
    else
        chartID = stateID;
        if is_eml_chart(chartID)
            stateID = eml_fcns_in(chartID);
        elseif is_truth_table_chart(chartID)
            stateID = truth_tables_in(chartID);
        else
            error(['Item ' chartID ' is neither a truth table nor an Embedded MATLAB function.']);
        end
    end

    if is_eml_fcn(stateID)
        htmlStr = eml2html(chartID, stateID);
    elseif is_truth_table_fcn(stateID)
        htmlStr = tt2html(chartID, stateID);
    else
        error(['Item ' stateID ' is neither a truth table nor an Embedded MATLAB function']);
    end


function htmlStr = eml2html(chartID, emlID)

    if is_eml_script(emlID)
        libName = sf('get', emlID, 'script.libName');
        templateName = sf('get', emlID, 'script.name');
        pathName = sf('get', emlID, 'script.filePath');
        functionName = sprintf('%s\\%s (%s)', libName, templateName, pathName);
    elseif is_eml_chart(chartID)
        functionName = sf('FullNameOf', chartID, '.');
    else
        functionName = sf('FullNameOf', emlID, '.');
    end

    functionName = ['(Embedded MATLAB) ' functionName];

    htmlStr = hTag('h5',functionName);

    htmlStr = appendStr(htmlStr, '<hr>');

    if is_eml_script(emlID)
        script = sf('get', emlID, '.script');
    else
        script = sf('get', emlID, '.eml.script');
    end

    script = htmlClean(script);

    script = strrep(script, char(10), ['<br>' 10]);

    htmlStr = appendStr(htmlStr, hTag('small',script));

    htmlStr = hTag('html',appendStr(hTag('head',hTag('title',functionName)),hTag('body',htmlStr)));

function htmlStr = tt2html(chartID, truthTableID)

    if(is_truth_table_chart(chartID))
        tableName = ['(truth table) ' sf('FullNameOf', chartID, '.')];
    else
        tableName = ['(truth table) ' sf('FullNameOf', truthTableID, '.')];
    end

    htmlStr = hTag('h5',tableName);

    htmlStr = appendStr(htmlStr, hTag('h3','Condition Table:'));

    predicateArray = sf('get', truthTableID, '.truthTable.predicateArray');
    cols = size(predicateArray, 2);
    columnNames = {'#', 'Description', 'Condition'};
    numCols = length(columnNames);
    for col = numCols+1:cols+1
        columnNames{col} = int2str(rem(col-numCols,10));
    end
    htmlStr = appendStr(htmlStr, buildTable(predicateArray, columnNames, 0, [2 3]));

    htmlStr = appendStr(htmlStr, hTag('h3','Action Table:'));

    actionArray = sf('get', truthTableID, '.truthTable.actionArray');
    columnNames = {'#', 'Description', 'Action'};
    htmlStr = appendStr(htmlStr, buildTable(actionArray, columnNames, 1, [2 3]));

    htmlStr = hTag('html',appendStr(hTag('head',hTag('title',tableName)),hTag('body',htmlStr)));

function tagStr = hTag(tag, str)
    tag = upper(tag);
    endTag = strtok(tag);
    tab = char(9);
    newline = char(10);
    if isempty(str)
        str = '&nbsp;';
    end
    str = [tab strrep(str, newline, [newline tab])];
    tagStr = ['<' tag '>' newline str newline '</' endTag '>'];

function str = appendStr(str, append)
    newline = char(10);
    str = [str newline append];

function str = buildRow(row, leftCols, tag)
    if nargin == 2
        tag = 'td align="center"';
    end
    leftTag = [strtok(tag) ' align="left"'];
    str = hTag('th',row{1});
    for col = 2:length(row);
        if find(leftCols==col)
            thisTag = leftTag;
        else
            thisTag = tag;
        end
        str = appendStr(str,hTag(thisTag,hTag('small',row{col})));
    end

function str = buildTable(table, headers, includeLastRow, leftCols)
    str = hTag('tr', buildRow(headers, [], 'th'));

    table = htmlClean(table);

    rows = size(table, 1);
    rowHeaders = {};
    for row = 1:rows
        rowHeaders{row,1} = int2str(row);
    end
    if ~includeLastRow
        rowHeaders{rows} = '';
    end
    table = [rowHeaders table];
    for row = 1:rows
        str = appendStr(str, hTag('tr', buildRow(table(row,:), leftCols)));
    end

    str = hTag('table border=1 cellspacing=0', str);

function str = htmlClean(str)

    str = strrep(str,'<','&lt;');
    str = strrep(str,'>','&gt;');
    str = strrep(str,'&','&amp;');


% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/15 01:00:40 $
