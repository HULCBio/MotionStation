function vqbdemo
%VQBDEMO Visual Query Builder demonstrations.
%   VQBDEMO runs the Visual Query Builder demonstration. 

%   Author(s): C.F.Garvin, 10-08098
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.6 $   $Date: 2004/04/06 01:05:58 $

%Demo runs on PC only
if isunix
  errordlg('Visual Builder Demonstration is for PC only.')
  return
end

%Save current setdbprefs settings and use default settings
prefs = setdbprefs;
defprefs = {'cellarray','store','NaN','NaN','null','null'};
setdbprefs(fieldnames(prefs),defprefs)

%Need to turn on hidden handle visibility
hvstat = get(0,'Showhiddenhandles');
set(0,'Showhiddenhandles','on')

%Close Visual Query Builder if it is open to start with clean environment
vqbobj = getappdata(0,'SQLDLG');
if ~isempty(vqbobj)
  delete(vqbobj)
  setappdata(0,'SQLDLG',[])
end
clear vqbobj

%Build a simple select query
dispmess({'Welcome to the MATLAB Visual Query Builder demonstration!';...
    ' ';...
    'The Visual Query Builder allows users unfamiliar with SQL';...
    'to access database data from MATLAB.';...
    ' ';...
    'The command "querybuilder" runs the Visual Query Builder.'});

querybuilder

dispmess({'Choosing a data source displays the valid list of database';...
  'tables.  Let''s choose the data source dbtoolboxdemo'})

vqbobj = getappdata(0,'SQLDLG');
sobj = findobj(vqbobj,'Tag','sources');
sstr = get(sobj,'String');
if ~any(strcmp('dbtoolboxdemo',lower(sstr)))
  delete(findobj('Tag','SQLDLG'))
  errordlg({'Demonstration database has not been defined as the data source ';...
      'named dbtoolboxdemo.  Please see the Database Toolbox manual for ';...
      'information on configuring data sources.'})
  clc
  %Reset hidden handle visibility
  set(0,'Showhiddenhandles',hvstat)
  return
end

set(findobj(gcf,'Tag','sources'),'Value',find(strcmp('dbtoolboxdemo',sstr)))
querybuilder('sources')

dispmess({'Choosing a table displays the valid list of fields in that table.';...
  'Let''s choose the table salesVolume.'})

set(findobj(gcf,'Tag','tables'),'Value',3)
querybuilder('tablesvqb')

dispmess({'Choosing fields will display a valid SQL statement for execution.';...
  'Let''s choose the fields StockNumber, January, February, and March.'})

set(findobj(gcf,'Tag','fields'),'Value',1:4)
querybuilder('buildquery')

dispmess({'Notice that the SQL statement is now displayed.';...
  'Next, we must denote a MATLAB workspace variable where the ';...
  'returned query data will be stored.   Let''s name the variable ''A''.'})

set(findobj(gcf,'Tag','wkvariable'),'String','A')

querybuilder('executequery')
disp(' ')
evalin('base','A')   %Execute the query and echo data in MATLAB window

dispmess({'Clicking the Execute button executes the shown SQL statement.';...
  'Notice that the workspace variable list is updated to show ';...
  'the contents of the MATLAB workspace.   Type A at the MATLAB';...
  'prompt to show the returned query data.'})

%Add a constraint to the query
dispmess({'Queries can be refined by adding WHERE, GROUP BY, HAVING and';...
    'ORDER BY clauses.  To add constraints to a query click on the Where...';...
    'pushbutton.'})

querybuilder('where')    %Open the WHERE clauses... dialog

dispmess({'Let''s define the constraint that the StockNumber must be';...
    'greater than 400000.  Pull down on the popupmenu next to the Relation';...
    'radiobutton and choose >.  Enter the value 400000 in the edit box';...
    'next to the popupmenu.'})

set(findobj('Tag','relation'),'Value',3)
set(findobj('Tag','relstring'),'String','400000')

dispmess({'Clicking Apply updates the Current clauses: listbox'})

whereclausefig = findobj('Tag','WHERE');
figure(whereclausefig) %Make sure right window has focus
querybuilder('applycond',whereclausefig)   %Run querybuilder to update dialog

dispmess({'To edit a clause, either double click on the desired clause,';...
  'in this case StockNumber > 400000, or choose the clause and click Edit.';...
  'Clicking the Operator AND and choosing Apply updates the original clause';...
  'Let''s add an upper bound to the StockNumber constraint of 500000.'})

set(findobj('Tag','whereclauses'),'Value',1)
figure(whereclausefig) %Make sure right window has focus
querybuilder('editclause',whereclausefig) 

set(findobj('String','None'),'Value',0)
set(findobj('String','AND'),'Value',1)

dispmess({''})

figure(whereclausefig) %Make sure right window has focus
querybuilder('applycond',whereclausefig)

set(findobj('Tag','relation'),'Value',2)
set(findobj('Tag','relstring'),'String','500000')

dispmess({''})

figure(whereclausefig) %Make sure right window has focus
querybuilder('applycond',whereclausefig)

dispmess({'Clicking OK closes the WHERE clauses... dialog and updates';...
    'the SQL statement.'})

figure(whereclausefig) %Make sure right window has focus
querybuilder('condok',whereclausefig)

dispmess({'Clicking Execute runs the new query and stores the data in the';...
    'variable ''A''.  Note that only the records for the StockNumbers between';...
    '400000 and 500000 are returned.'})
querybuilder('executequery')
disp(' ')
evalin('base','A')   %Execute the query and echo data in MATLAB window


%Sort the returned data
dispmess({'Now let''s modify the query so the return data is sorted in a';...
    'specific order.  Click the Order By... button to open the ORDER BY ';...
    'clauses... dialog.'})

querybuilder('orderby')

dispmess({'Let''s sort the data in descending order by field January.';...
    'Choose January from the fields listbox, and click the Descending';...
    'sort order button.  Click Apply to build the Order By clause.'});

set(findobj('Tag','orderbyfields'),'Value',2)
set(findobj('Tag','sortorder'),'Value',0)
set(findobj('Tag','sortorder','String','Descending'),'Value',1)
orderbyclausedialog = findobj('Tag','ORDER BY');
figure(orderbyclausedialog) %Make sure right window has focus
querybuilder('applycond',orderbyclausedialog)

dispmess({'Now let''s add a secondary sort field, February.  Choose February';...
    'from the fields list box, enter the Sort Key Number as 2 as the data';...
    'will be sorted first by the field January, the primary sort key, and';...
    'then by the field February, the secondary sort key.  The sort order';...
    'for the field February will be ascending.'})

set(findobj('Tag','orderbyfields'),'Value',3)
set(findobj('Tag','sortorder'),'Value',0)
set(findobj('Tag','sortorder','String','Ascending'),'Value',1)
set(findobj('Tag','sortkey'),'String','2')

dispmess({''})

figure(orderbyclausedialog) %Make sure right window has focus
querybuilder('applycond',orderbyclausedialog)

dispmess({'Clicking OK closes the ORDER BY clauses... dialog and updates';...
    'the SQL statement.'})

figure(orderbyclausedialog) %Make sure right window has focus
querybuilder('condok',orderbyclausedialog)

dispmess({'Clicking Execute runs the new query, sorting the data first';...
    'by the field January and then by the field February.'})

querybuilder('executequery')
disp(' ')
evalin('base','A')   %Execute the query and echo data in MATLAB window

%Use subquery as constraint
dispmess({'Constraints can also be defined by using subqueries.';...
    'Subqueries are queries nested within queries.  In this example,';...
    'data is returned based on a constraint defined by the return data';...
    'of another query.   Let''s get the monthly sales data for the ';...
    'product with the StockNumber that corresponds to the product';...
    '''Building Blocks''.   The table salesVolume is chosen and all';...
    'the fields in this table are selected.'})

%Remove sorting data
querybuilder('orderby')
orderbyclausefig = findobj('Tag','ORDER BY');
set(findobj('Tag','orderbyclauses'),'Value',1:2)
querybuilder('deleteclause',orderbyclausefig)
querybuilder('condok',orderbyclausefig)

set(findobj('Tag','tables'),'Value',3)
querybuilder('tablesvqb')
set(findobj('Tag','fields'),'Value',1:13)
querybuilder('buildquery')
set(findobj(gcf,'Tag','wkvariable'),'String','A')

dispmess({'Next, the constraint that relates the StockNumber to the';...
    'productDescription must be defined using a WHERE clause.'})

querybuilder('where')
whereclausefig = findobj('Tag','WHERE');
set(findobj('Tag','whereclauses'),'Value',1:2)
querybuilder('deleteclause',whereclausefig)

dispmess({'The relational operator ''='' will be used here.  Clicking';...
    'SubQuery... opens the subquery dialog.  Note that the subqueries';...
    'will use WHERE clauses only.'})

querybuilder('subquerydialog')

dispmess({'First, the table productTable is chosen.  The table''s fields';...
    'appear in the Fields and SubQuery WHERE Clauses Fields listboxes.'})

sqobj = findobj('Tag','SUBQDLG');
figure(sqobj)
set(findobj('Tag','stables'),'Value',2)
querybuilder('subqtables',sqobj)

dispmess({'Next, the field stockNumber is chosen.  The SQL subquery is ';...
    'constructed and displayed at this time.'})

figure(sqobj)
set(findobj('Tag','sfields'),'Value',2)
querybuilder('subqfields',sqobj)

dispmess({'Now, the productDescription is defined as being equal to ';...
    'to the product ''Building Blocks''.'})

set(findobj('Tag','swherefields'),'Value',5)
set(findobj('Tag','srelstring'),'String','''Building Blocks''')

dispmess({'Clicking Apply builds the WHERE clause and updates the SQL';...
    'subquery.'})

figure(sqobj)
querybuilder('applysubquerydlg',sqobj)

dispmess({'Clicking OK closes the subquery dialog and returns control';...
    'to the main query WHERE clauses... dialog.'})

figure(sqobj)
querybuilder('acceptsubquery',sqobj)

dispmess({'Clicking Apply builds the WHERE clause incorporating the ';...
    'defined subquery into the constraint.'})

whereclausefig = figure(findobj('Tag','WHERE')) %Make sure right window has focus
querybuilder('applycond',whereclausefig)

dispmess({'Clicking OK accepts the defined constraint and rebuilds the';...
    'SQL query statement.'})

figure(whereclausefig) %Make sure right window has focus
querybuilder('condok',whereclausefig)

dispmess({'Now the query is executed by clicking Execute and the monthly';...
    'sales data for the product ''Building Blocks'' is returned to the ';...
    'MATLAB workspace.'})

querybuilder('executequery')
disp(' ')
evalin('base','A')   %Execute the query and echo data in MATLAB window

%JOIN statement
dispmess({'Now let''s build a query where data is retrieved from multiple';...
    'tables.  This database operation is called a JOIN.';...
    ' ';...
    'In a previous example, the StockNumber for a product was requested';...
    'from the database.  If the product name for a given stock number is ';...
    'is unknown, the returned information may not be very useful.  By ';...
    'fetching data from the tables productTable and salesVolume, more ';...
    'useful information can be obtained.'})

querybuilder('where')
set(findobj('Tag','whereclauses'),'Value',1)
whereclausefig = figure(findobj('Tag','WHERE'));
querybuilder('deleteclause',whereclausefig)
querybuilder('condok',whereclausefig)

set(findobj('Tag','tables'),'Value',2:3)
querybuilder('tablesvqb')

dispmess({'Note that each fieldname now includes its corresponding tablename';...
    ' ';...
    'Choosing the fields productTable.productDescription, salesVolume.January';...
    'salesVolume.February, and salesVolume.March rebuilds the SQL statement'})

set(findobj('Tag','fields'),'Value',[5,7:9])
querybuilder('buildquery')

dispmess({'Next, it is necessary to provide a query constraint equating the';...
  'productTable.stockNumber to the salesVolume.StockNumber.  This constraint';...
  'will replace the stock number returned previously with the product name.';...
  'Note that the fieldname salesVolume.StockNumber in the Relation edit box.'})

querybuilder('where')
whereclausefig = figure(findobj('Tag','WHERE'));
querybuilder('deleteclause',whereclausefig)
querybuilder('deleteclause',whereclausefig)
set(findobj('Tag','wherefields'),'Value',2)
set(findobj('Tag','relation'),'Value',1)
set(findobj('Tag','relstring'),'String','salesVolume.StockNumber')

dispmess({''})

figure(whereclausefig) %Make sure right window has focus
querybuilder('applycond',whereclausefig)

dispmess({'Clicking OK closes the dialog and updates the SQL statement.'})

figure(whereclausefig) %Make sure right window has focus
querybuilder('condok',whereclausefig)

dispmess({'The MATLAB workspace variable box must be updated again';...
    'to avoid losing wanted data from a previous query.  In this example';...
    '''A'' is used again.  Clicking Execute runs the query.'})

set(findobj('Tag','wkvariable'),'String','A')
querybuilder('executequery')
disp(' ')
evalin('base','A')   %Execute the query and echo data in MATLAB window

%Demonstrate display functionality
dispmess({'Selecting the menu choice Display Data creates an interactive figure';...
    'window showing the unique values for each selected field.  Choosing';...
    'a text string with the mouse will show additional information';...
    'about the returned data.'})

evalin('base','showdata(A,{''productDescription'';''January'';''February'';''March''})')

dispmess({'In the February column, clicking on the number 900 gives ';...
    'more information about which products sold 900 units in February,';...
    'specifically a count of many items in the other selected fields are';...
    'correlated to the selected item.'})

showdatacallbacks('select',[],findobj(findobj('Tag','VQBDataWindow'),'String','900'))

dispmess({'Additionally, the returned data can be represented graphically also.'})

close(findobj('Tag','VQBDataWindow'))

dispmess({'Choosing the menu choice Display Chart... opens the Visual Query';...
    'charting tools dialog.  Let''s build a 2D line chart from the returned';...
    'data.  At all times, a preview of the current figure or the reason why';...
    'the figure cannot be constructed is shown in a preview window.  ';...
    ' ';...
    'From the 2D charts menu, the chart type plot is chosen.'})

try
  showdatacallbacks('chart')
catch
  evalin('base','showdatacallbacks(''preview'',A)')
end

dispmess({'Next, the fields salesVolume.January, salesVolume.February,';...
    'and salesVolume.March are chosen from the X Data list box.  Note';...
    'that a preview plot is now displayed at the bottom of the dialog.'})

set(findobj('Tag','xdata'),'Value',2:4)
evalin('base','showdatacallbacks(''preview'',A)')

dispmess({'The next step is to define the axis tick labels.  A specific';...
    'field can be chosen or the selected fieldnames can be used as the tick';...
    'labels.   For this example, the data from the field productTable.productDescription';...
    'is used for the X-axis tick labels.'})

set(findobj('Tag','xlabels'),'Value',1)
evalin('base','showdatacallbacks(''preview'',A)')

dispmess({'A legend is needed to show what each line represents in the figure.';...
    'Clicking the Show Legend checkbox enables the Legend Labels listbox.';...
    'For the legend labels, the X data fieldnames will be used.'})

set(findobj('Tag','Legend'),'Value',1)
set(findobj('Userdata','legendobject'),'Enable','on')
set(findobj('Tag','legendlabels'),'Value',5)
evalin('base','showdatacallbacks(''preview'',A)')

dispmess({'When the desired data and labels have been selected, the chart is';...
    'displayed by clicking the Display button.'})

evalin('base','showdatacallbacks(''display'',A)')

dispmess({'Next, the data can be displayed as a report in a web browser.'})

%Close charting tools dialog
close(findobj('Tag','CHTDLG'))

dispmess({'Selecting the menu choice Display Report... will open a web';...
    'browser and display the returned query data in a table.'})

evalin('base','showdatacallbacks(''report'',A)')

disp('This completes the Visual Query Builder demonstration.')

delete(findobj('Type','figure'));   %Clean up desktop
setappdata(0,'SQLDLG',[])

querybuilder

%Reset hidden handle visibility
set(0,'Showhiddenhandles',hvstat)

%Reset original preferences
setdbprefs(fieldnames(prefs),{prefs.DataReturnFormat,prefs.ErrorHandling,...
                               prefs.NullNumberRead,prefs.NullNumberWrite,...
                               prefs.NullStringRead,prefs.NullStringWrite});
                       
                       
%Subfunctions
function dispmess(s)
%DISPMESS Display demo prompts.
%   DISPMESS(S) displays the given message S and prompts the user to
%   continue or quit the demo.

clc
news = [{' '};...
    s;...
    {'Hit RETURN to continue or Control-C to end demonstration.'};...
    {' '}];

for i = 1:length(news)
  disp(news{i});
end
pause
