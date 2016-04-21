function [table, container] = uitable(varargin)
% UITABLE creates a two dimensional graphic uitable component in a figure window.
%     UITABLE creates a 1x1 uitable object using default property values in
%     a figure window.
%
%     UITABLE(numrows,numcolumns) creates a uitable object with specified
%     number of rows and columns.
%
%     UITABLE(data,columnNames) creates a uitable object with the specified
%     data and columnNames. Data can be a cell array or a vector and
%     columnNames should be cell arrays.
%
%     UITABLE('PropertyName1',value1,'PropertyName2',value2,...) creates a
%     uitable object with specified property values. MATLAB uses default
%     property values for any property not explicitly set. The properties
%     that user can set are: ColumnNames, Data, GridColor, NumColumns,
%     NumRows, Position, ColumnWidth and RowHeight.
%
%     UITABLE(figurehandle, ...) creates a uitable object in the figure
%     window specified by the figure handle.
%
%     HANDLE = UITABLE(...) creates a uitable object and returns its handle.
%
%     Properties:
%
%     ColumnNames:  Cell array of strings for column names.
%     Data:         Cell array of values to be displayed in the table.
%     GridColor:    string, RGB vector.
%     NumColumns:   int specifying number of columns.
%     NumRows:      int specifying number of rows.
%     Parent:       Parent figure handle. If not specified, it is the gcf.
%     Position:     4 element vector specifying the position.
%     ColumnWidth:  int specifying the width of columns.
%     RowHeight:    int specifying the height of columns.
%
%     Editable:     Boolean specifying if a column is editable.
%     Units:        String - pixels/normalized/inches/points/centimeters.
%     Visible:      Boolean specifying if table is visible.
%     DataChangedCallback - Callback function name or handle.
%
%
%     Examples:
%
%     t = uitable(3, 2);
%
%     Creates a 3x2 empty uitable object in a figure window.
%
%     f = figure;
%     t = uitable(f, rand(5), {'A', 'B', 'C', 'D', 'E'});
%
%     Creates a 5x5 uitable object in a figure window with the specified
%     data and the column names.
%
%     data = rand(3);
%     colnames = {'X-Data', 'Y-Data', 'Z-Data'};
%     t = uitable(data, colnames,'Position', [20 20 250 100]);
%
%     Creates a uitable object with the specified data and column names and
%     the specified Position.
%
%     See also UITREE, UITREENODE

% Copyright 2002-2004 The MathWorks, Inc.

% Release: R14. This feature will not work in previous versions of MATLAB.

%% Setup and P-V parsing
error(nargoutchk(0,2,nargout));

fig = [];
numargs = nargin;

datastatus=false; columnstatus=false;
rownum = 1; colnum = 1; % Default to a 1x1 table.
position = [20 20 200 200];
combo_box_found = false;
check_box_found = false;

import com.mathworks.hg.peer.UitablePeer;

if (numargs > 0 & ishandle(varargin{1}) & ...
        isa(handle(varargin{1}), 'figure'))
    fig = varargin{1};
    varargin = varargin(2:end);
    numargs = numargs - 1;
end
    
if (numargs > 0 & ishandle(varargin{1}))
    if ~isa(varargin{1}, 'javax.swing.table.DefaultTableModel')
        error(['Unrecognized parameter: ', varargin{1}]);
    end
    data_model = varargin{1};
    varargin = varargin(2:end);
    numargs = numargs - 1;

elseif ((numargs > 0) & isscalar(varargin{1})& isscalar(varargin{2}))
    if(isnumeric(varargin{1}) & isnumeric(varargin{2}))
        rownum = varargin{1};
        colnum = varargin{2};

        varargin = varargin(3:end);
        numargs = numargs-2;
    else
        error('When using UITABLE numrows and numcols have to be numeric scalars.')
    end

elseif ((numargs > 0) & size(varargin{2},1) == 1 & iscell(varargin{2}))
        if (size(varargin{1},2) == size(varargin{2},2))
            if (isnumeric(varargin{1}))
                varargin{1} = num2cell(varargin{1});
            end
        else
            error('Number of column names must match number of columns in data');
        end
        data = varargin{1};     datastatus        = true;
        coln = varargin{1+1};   columnstatus      = true;

        varargin = varargin(3:end);
        numargs = numargs-2;
end

for i = 1:2:numargs-1
    if (~ischar(varargin{i}))
        error(['Unrecognized parameter: ', varargin{1}]);
    end
    switch lower(varargin{i})
        case 'data'
            if (isnumeric(varargin{i+1}))
                varargin{i+1} = num2cell(varargin{i+1});
            end
            data        = varargin{i+1};
            datastatus  = true;

        case 'columnnames'
            if(iscell(varargin{i+1}))
                coln            = varargin{i+1};
                columnstatus    = true;
            else
                error('When using UITABLE Column data should be 1xn cell array')
            end

        case 'numrows'
            if (isnumeric(varargin{i+1}))
                rownum = varargin{i+1};
            else
                error('numrows has to be a scalar')
            end

        case 'numcolumns'
            if (isnumeric(varargin{i+1}))
                colnum = varargin{i+1};
            else
                error('numcolumns has to be a scalar')
            end

        case 'gridcolor'
            if (ischar(varargin{i+1}))
                gridcolor = varargin{i+1};
            else if (isnumeric(varargin{i+1}) & size(varargin{i+1}) == [1 3])
                    gridcolor = varargin{i+1};
                else
                    error('gridcolor has to be a valid string')
                end
            end

        case 'rowheight'
            if (isnumeric(varargin{i+1}))
                rowheight = varargin{i+1};
            else
                error('rowheight has to be a scalar')
            end

        case 'parent'
            if ishandle(varargin{i+1})
                f = varargin{i+1};
                if isa(handle(f), 'figure')
                    fig = f;
                end
            end
            
        case 'position'
            if (isnumeric(varargin{i+1}))
                position = varargin{i+1};
            else
                error('position has to be a 1x4 numeric array')
            end

        case 'columnwidth'
            if (isnumeric(varargin{i+1}))
                columnwidth = varargin{i+1};
            else
                error('columnwidth has to be a scalar')
            end
        otherwise
            error(['Unrecognized parameter: ', varargin{1}]);
    end
end

if (~exist('data_model')), data_model = javax.swing.table.DefaultTableModel;, end

% ---combo box detection--- %
% Begin edit
if (datastatus)
    if (iscell(data))
        rownum = size(data,1);
        colnum = size(data,2);
        combo_count =0;
        check_count = 0;
        for j = 1:rownum
            for k = 1:colnum
                if (iscell(data{j,k}))
                    combo_box_found = true;
                    combo_count = combo_count + 1;
                    combo_box_data{combo_count} = data{j,k};
                    combo_box_column(combo_count ) = k;
                    dc = data{j,k};
                    data{j,k} = dc{1};
                else 
                    if(islogical(data{j,k}))
                        check_box_found = true; 
                        check_count = check_count + 1;
                        check_box_column(check_count) = k;
                    end
                end
            end
        end
    end
end
% End edit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ( columnstatus & datastatus )
    if(size(data,2)== size(coln,2))
        data_model.setDataVector(data,coln);
    else
        error('Number of columns in both Data and ColumnNames should match');
    end
elseif ( ~columnstatus & datastatus )
    for i=1:size(data,2)
        coln{i} = num2str(i);
    end
    data_model.setDataVector(data,coln);
elseif ( columnstatus & ~datastatus)
    error('No Data provided along with ColumnNames');
end

if exist('rownum'),     data_model.setRowCount(rownum);,        end;
if exist('colnum'),     data_model.setColumnCount(colnum);,     end;

% todo - make the parent argument work above
if isempty(fig)
    fig = gcf;
end;

if isempty(get(fig,'JavaFrame'))
    error('You can create a Table only in Java Figures. To turn on the Java Figures, please type ''feature(''JavaFigures'',1)''')
end

table_h= UitablePeer(data_model);

if exist('gridcolor'),   table_h.setgridcolor(gridcolor);,     end;
if exist('rowheight'),   table_h.setHieghtofRows(rowheight);,  end;
if exist('columnwidth'), table_h.setColumnWidth(columnwidth);, end;

if (combo_box_found),    
    for i=1:combo_count
        table_h.setComboBoxEditor(combo_box_data(i), combo_box_column(i));
    end
end
if (check_box_found),    
    for i = 1: check_count
        table_h.setCheckBoxEditor(check_box_column(i));
    end
end

if (isempty(fig))
    fig = gcf;
end

% pass the figure child in, let javacomponent introspect
[obj, container] = javacomponent(table_h, position, fig);

table = handle(table_h, 'callbackproperties');
