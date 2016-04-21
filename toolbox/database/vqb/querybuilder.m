function querybuilder(varargin)
%QUERYBUILDER Start visual SQL query builder.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.31.4.14 $   $Date: 2004/04/06 01:05:56 $

%Focus dialog if already open and return
f = getappdata(0,'SQLDLG');
if ~isempty(f) || nargin == 2
  switch nargin
      case 0
        figure(f);
      case 1
        feval(varargin{1},[],[],f);
      case 2
        feval(varargin{1},[],[],varargin{2});
  end
  return
end

%GUI spacing
[dfp,mfp,bspc,bhgt,bwid,bwid2] = spaceparams([],[],[]);

%Return valid data sources
datasources = getdatasources;     

if isempty(datasources)  %Empty datasources indicates no defined sources
  errordlg('No available data sources.');
  return
elseif ~iscell(datasources) & datasources == -1
  errordlg('Unable to open ODBC.INI.');
  return
end

%Build main window
f = figure('Name','Visual Query Builder','Numbertitle','off',...
           'Integerhandle','off','Menubar','none','Tag','SQLDLG');
set(f,'Resizefcn',{@cleanupdialog,f},'Closerequestfcn',{@exitvqb,f});         
setappdata(0,'SQLDLG',f)       

%Adjust size of dialog to fit uicontrols
p = get(gcf,'Position');
rgt = 6*(bspc+bwid);
top = p(4);
set(gcf,'Position',[p(1) p(2) rgt top]);

%Data import/export uicontrols
uicontrol('Enable','off',...
          'Position',[bspc top-(3.5*bspc+bhgt) 4*bspc+6*bwid 2*bspc+bhgt]);
uicontrol('Style','text','String','Data operation',...
   'Position',[2*bspc top-(.5*bspc+bhgt) bwid bhgt]);

%SELECT or INSERT radio buttons
ui.soi(1) = uicontrol('Style','radiobutton','String','Select','Tag','SoI','Value',1,...
  'Callback',{@soi,f},'Tooltip','Read data from database',...
  'Userdata','SELECT','Position',[2*bspc top-(3*bspc+bhgt) bwid bhgt]);
ui.soi(2) = uicontrol('Style','radiobutton','String','Insert','Tag','SoI','Value',0,...
  'Callback',{@soi,f},'Tooltip','Write data into database',...
  'Userdata','INSERT','Position',[3*bspc+bwid top-(3*bspc+bhgt) bwid bhgt]);

%Data Sources uicontrols
uicontrol('Enable','off',...
          'Position',[bspc top-(3*bspc+6*bhgt) 4*bspc+6*bwid 5*bhgt-2*bspc]);
uicontrol('Style','text','String','Data source',...
   'Position',[2*bspc top-(4*bspc+2*bhgt) bwid bhgt]);
ui.sources = uicontrol('Style','listbox','String',datasources,'Callback',{@sources,f},...
  'Tag','sources','Tooltip','List of valid data sources on system',...
  'Max',2,'Value',[],...
  'Position',[2*bspc top-(2*bspc+6*bhgt) 2*bwid 4*bhgt-2*bspc]);

%Data Source table uicontrols
uicontrol('Style','text','String','Tables',...
   'Position',[3*bspc+2*bwid top-(4*bspc+2*bhgt) bwid bhgt]);
ui.tables = uicontrol('Style','listbox','String','','Max',2,...
   'Tag','tables','Callback',{@tablesvqb,f},...
   'Tooltip','Tables in selected data source',...
   'Position',[3*bspc+2*bwid top-(2*bspc+6*bhgt) 2*bwid 4*bhgt-2*bspc]);

%Table fieldnames
uicontrol('Style','text','String','Fields',...
   'Position',[4*bspc+4*bwid top-(4*bspc+2*bhgt) bwid bhgt]);
ui.fields = uicontrol('Style','listbox','String','',...
   'Tag','fields','Max',2,'Callback',{@buildquery,f},... 
   'Tooltip','Fields in selected table',...
   'Position',[4*bspc+4*bwid top-(2*bspc+6*bhgt) 2*bwid 4*bhgt-2*bspc]);
 
%Options panel
uicontrol('Enable','off',...
  'Position',[bspc top-(4*bspc+9*bhgt) 4*bspc+6*bwid 3*bspc+2*bhgt]);
uicontrol('Style','text','String','Advanced query options',...
  'Position',[2*bspc top-(4*bspc+7*bhgt) bwid bhgt]); 

%Select ALL or DISTINCT radio buttons
ui.aod(1) = uicontrol('Style','radiobutton','String','All','Tag','AoD','Value',1,...
  'Callback',{@aod,f},'Tooltip','Return ALL records',...
  'Userdata','ALL','Position',[2*bspc top-(3*bspc+8*bhgt) bwid bhgt]);
ui.aod(2) = uicontrol('Style','radiobutton','String','Distinct','Tag','AoD','Value',0,...
  'Callback',{@aod,f},'Tooltip','Return UNIQUE records',...
  'Userdata','DISTINCT','Position',[2*bspc top-(3*bspc+9*bhgt) bwid bhgt]);

%Pushbuttons for advanced query statements
ui.where = uicontrol('String','Where...','Callback',{@where,f},...
  'Tooltip','Data search conditions','Tag','Where...',...
  'Position',[9*bspc+bwid top-(3*bspc+8*bhgt) bwid2 bhgt]);
ui.groupby = uicontrol('String','Group by...','Callback',{@groupby,f},...
  'Tooltip','Group data','Tag','Group By...',...
  'Position',[10*bspc+bwid+bwid2 top-(3*bspc+8*bhgt) bwid2 bhgt]);
ui.having = uicontrol('String','Having...','Callback',{@having,f},...
  'Tooltip','Data group conditions','Tag','Having...',...
  'Position',[11*bspc+bwid+2*bwid2 top-(3*bspc+8*bhgt) bwid2 bhgt]);
ui.orderby = uicontrol('String','Order by...','Callback',{@orderby,f},...
  'Tooltip','Sort data','Tag','Order By...',...
  'Position',[12*bspc+bwid+3*bwid2 top-(3*bspc+8*bhgt) bwid2 bhgt]);

%Build listboxes for visual queue that clause has been built
tmpstr = 'set(gcbo,''Value'',[])';
ui.wherelist = uicontrol('Style','edit','Tag','wherelist','Max',2,'Callback',tmpstr,...
  'Tooltip','Current data search conditions',...
  'Position',[9*bspc+bwid top-(3*bspc+9*bhgt) bwid2 bhgt]);
ui.groupbylist = uicontrol('Style','edit','Tag','groupbylist','Max',2,'Callback',tmpstr,...
  'Tooltip','Current data grouping settings',...
  'Position',[10*bspc+bwid+bwid2 top-(3*bspc+9*bhgt) bwid2 bhgt]);
ui.havinglist = uicontrol('Style','edit','Tag','havinglist','Max',2,'Callback',tmpstr,...
  'Tooltip','Current data group search conditions',...
  'Position',[11*bspc+bwid+2*bwid2 top-(3*bspc+9*bhgt) bwid2 bhgt]);
ui.orderbylist = uicontrol('Style','edit','Tag','orderbylist','Max',2,'Callback',tmpstr,...
  'Tooltip','Current data sorting settings',...
  'Position',[12*bspc+bwid+3*bwid2 top-(3*bspc+9*bhgt) bwid2 bhgt]);

%Build SQL statement and output variable uicontrols
uicontrol('Enable','off',...
  'Position',[bspc top-(4*bspc+14*bhgt) 4*bspc+6*bwid 2*bspc+4*bhgt]);
ui.typename = uicontrol('Style','text','String','SQL statement',...
  'Position',[2*bspc top-(5*bspc+10*bhgt) bwid bhgt]);  
ui.query = uicontrol('Style','edit','String','','Tag','query',...
  'Tooltip','SQL statement for execution',...
  'Position',[2*bspc top-(5*bspc+11*bhgt) 2*bspc+6*bwid bhgt]);
uicontrol('Style','text','String','MATLAB workspace variable',...
  'Position',[2*bspc top-(7*bspc+12*bhgt) bwid bhgt]);  
ui.wkvariable = uicontrol('Style','edit','String','','Tag','wkvariable',...
  'Tooltip',' MATLAB workspace variable for return data storage',...
  'Callback',{@buildquery,f},...
  'Position',[2*bspc top-(7*bspc+13*bhgt) bwid bhgt]);
ui.vqbstatus = uicontrol('Style','text','Foregroundcolor','blue','Tag','vqbstatus',...
  'Fontweight','bold',...
  'Position',[2*bspc+2*bwid top-(7*bspc+12*bhgt) bwid bhgt]);
ui.execute = uicontrol('String','Execute','Callback',{@executequery,f},...
  'Tooltip','Execute shown SQL statement','Tag','Execute',...
  'Position',[4*bspc+5*bwid top-(7*bspc+13*bhgt) bwid bhgt]);

%Build list box for return data display
uicontrol('Enable','off',...
  'Position',[bspc top-(7*bspc+19*bhgt) 4*bspc+6*bwid 6*bhgt-3*bspc]);
uicontrol('Style','text','String','Data',...
  'Position',[2*bspc top-(9*bspc+14*bhgt) bwid bhgt]);
uicontrol('Style','text','String','Workspace variable',...
  'Position',[2*bspc top-(9*bspc+15*bhgt) bwid bhgt]);
uicontrol('Style','text','String','Size',...
  'Position',[2*bspc+2.25*bwid top-(9*bspc+15*bhgt) bwid bhgt]);
uicontrol('Style','text','String','Memory (bytes)',...
  'Position',[2*bspc+4*bwid top-(9*bspc+15*bhgt) bwid bhgt]);
ui.querydata = uicontrol('Style','listbox','Tag','querydata','Fontname',get(0,'FixedWidthFontName'),'Max',2,...
  'Tooltip','List of variables created by Visual Query Builder queries',...
  'Callback',{@querydata,f},'Userdata',0,...
  'Position',[2*bspc top-(6*bspc+19*bhgt) 2*bspc+6*bwid 4*bhgt-2*bspc]);

%Build uicontrols to store clause data
ui.whereclausedata = uicontrol('Visible','off','Tag','whereclausedata');
ui.orderbyclausedata = uicontrol('Visible','off','Tag','orderbyclausedata');
ui.havingclausedata = uicontrol('Visible','off','Tag','havingclausedata');
ui.groupbyclausedata = uicontrol('Visible','off','Tag','groupbyclausedata');
ui.saveflag = uicontrol('Visible','off','Tag','saveflag');

%Build Query menu
qm = uimenu('Label','&Query','Accelerator','Q');
uimenu(qm,'Label','&Execute','Tag','Execute','Callback',{@executequery,f});
uimenu(qm,'Label','&Load...','Tag','Load','Callback',{@loadvqb,f});
uimenu(qm,'Label','&Save...','Tag','Save','Callback',{@savevqb,f});
uimenu(qm,'Label','E&xit','Tag','Exit','Callback',{@exitvqb,f});
uimenu(qm,'Label','&Preferences...','Tag','Preferences',...
  'Separator','on','Callback',{@preferences,f});

%Build data display menu
dm = uimenu('Label','&Display','Accelerator','D');
uimenu(dm,'Label','&Data...','Tag','Data',...
  'Callback','eval([''showdatacallbacks(''''data'''','' get(findobj(''Tag'',''wkvariable''),''String'') '')''],'''')');
uimenu(dm,'Label','&Chart...','Tag','Chart',...
  'Callback','eval([''showdatacallbacks(''''chart'''','' get(findobj(''Tag'',''wkvariable''),''String'') '')''],'''')');

%Simple report supported for Windows and SOL2
if any(strcmp({'PCWIN','SOL2'},computer))
  repenable = 'on';
else
  repenable = 'off';
end

if (exist('rptgen') & exist('report')) %check for report generator
  repgenenable = 'on';
  repenable = 'on';
else
  repgenenable = 'off';
end

uimenu(dm,'Label','&Report...','Tag','Report','Enable',repenable,...
  'Callback','eval([''showdatacallbacks(''''report'''','' get(findobj(''Tag'',''wkvariable''),''String'') '')''],'''')');
uimenu(dm,'Label','Report &Generator...','Tag','ReportGenerator',...
  'Enable',repgenenable,'Callback','showdatacallbacks(''repgen'')');

%Build Help Menu
hm = uimenu('Label','&Help','Accelerator','H');
uimenu(hm,'Label','&Visual Query Builder Help','Tag','Help','Callback','qbhelp(''ALL'')');
uimenu(hm,'Label','Database &Toolbox Help','Tag','Help','Callback','qbhelp(''TOOLBOX'')');
if ~isunix   %Currently no demo for UNIX
  uimenu(hm,'Label','&Demos','Callback','vqbdemo','Separator','on');
end
uimenu(hm,'Label','&About Database Toolbox','Tag','Help','Callback','qbhelp(''AboutDialog'')','Separator','on');
  
%Create objects to store usernames and passwords
L = length(datasources);
udata = cell(1,L);
ui.usernames = uicontrol('Visible','off','Tag','UserNames','Userdata',udata);
ui.passwords = uicontrol('Visible','off','Tag','Passwords','Userdata',udata);

%Store GUI handles
setappdata(f,'uidata',ui)

%Display current workspace variables in listbox
varlist([],[],f)

%Visual cleanup of gui
cleanupdialog([],[],f)

%Set handle visibility to callback
set(f,'Handlevisibility','callback')

%%Subfunctions

function acceptsubquery(obj,evd,frame)
%ACCEPTSUBQUERY Apply subquery and close dialog.

ui = getappdata(frame,'uidata');

%Test if subquery executes without error
conn = loginconnect(get(ui.ssource,'String'));
subquerystr = get(ui.subquerystr,'String');
e = exec(conn,subquerystr);
if ~isempty(e.Message)
  errordlg(e.Message)
  try
    close(e)
  catch
  end
  close(conn)
  return
end
close(e)
close(conn)

%Get subquery userdata and string and store in WHERE or HAVING clause dialog
dobj = findobj('Tag','WHERE');
if isempty(dobj)
  dobj = findobj('Tag','HAVING');
end
if isempty(dobj)
  errordlg('WHERE or HAVING clauses dialog not found.  Unable to save subquery.'), return
end

wcdat = get(ui.swhereclauses,'Userdata');
wcstr = get(ui.swhereclauses,'String');
if ~isempty(subquerystr)
  subquerystr = ['(' subquerystr ')'];
end

%Store userdata, sql string, table listbox and field listbox values
setuprop(dobj,'SUBQUERYDATA',wcdat)
setuprop(dobj,'SUBQUERYSTRING',wcstr) 
setuprop(dobj,'TABLEVALUES',get(ui.stables,'Value'));
setuprop(dobj,'FIELDVALUES',get(ui.sfields,'Value'));

condstr = get(findobj('Tag','rcond','Value',1),'String');
switch condstr
  case 'Relation'
    set(findobj('Tag','relstring'),'String',subquerystr)
  case 'In'
    set(findobj('Tag','instring'),'String',subquerystr)
end

close(frame)  %close subquery dialog
setappdata(0,'SUBQDLG',[])
figure(dobj) %Focus on where clause dialog


function andor(obj,evd,frame)
%ANDOR AND/OR/None radio buttons.

ui = getappdata(frame,'conduidata');
set(ui.andor,'Value',0)
set(gcbo,'Value',1)


function aod(obj,evd,frame)         
%AOD Add ALL or DISTINCT keyword to query
  
ui = getappdata(frame,'uidata');

%Update values of radiobuttons and rebuild query string       
set(ui.aod,'Value',0);
set(gcbo,'Value',1);
querystr = get(ui.query,'String');
if ~isempty(querystr)
  buildquery(obj,evd,frame);
end
    
 
function [tn,tt] = alttables(c,ctg,p,d)
%ALTTABLES Table information based on database flavor.
%   [TN,TT] = ALTTABLES(C,CTG,P,D) attempts to get table information based
%   which database is being used.   C is the database connection.
%   CTG is the catalog.  P is the database product name. 
%   D is the connection meta data.
%   The table names, TN, and table types, TT, are returned.
%   This function is used if the TABLES command returns no data.

%Get tables based on P
switch upper(p(1:3))
  case 'ORA'
	e = exec(c,'select * from USER_TABLES');
	e = fetch(e);
    close(e)
    nn = e.Data(:,1);
    if ~strcmp(nn,'No Data')
	  nt = e.Data(:,2);
    end
    e = exec(c,'select * from USER_VIEWS');
    e = fetch(e);
    close(e)
    vn = e.Data(:,1);
    if ~strcmp(vn,'No Data')
      tmp = {'VIEW'};
	  vt = tmp(ones(size(vn)));
    end
	if ~exist('nt') && ~exist('vt')
      error('database:vqb:noTableInfo','Unable to get table information for data source.')
    end
    tn = [nn;vn];
	tt = [nt;vt];
  otherwise
	tinfo = tables(d,ctg,'');
    if ~isempty(tinfo)
      tn = tinfo(:,1);
      tt = tinfo(:,2);
    else
      error('database:vqb:noTableInfo','Unable to get table information from data source.')
    end
    switch p
      case 'EXCEL'    %Excel lists default sheet names as SYSTEM TABLES, need them listed
        i = find(strcmp('SYSTEM TABLE',tt));
        if ~isempty(i)
            tt(i) = {'TABLE'};
        end
    end
end


function applycond(obj,evd,frame)
%APPLYCOND Apply chosen clause settings.

tagname = getappdata(frame,'tagname');
uicond = getappdata(frame,'conduidata');
uiclause = getappdata(frame,'clauseuidata');

if any(strcmp(tagname,{'orderby';'groupby'}));
  applyordergroup(obj,evd,frame)
  return
end

ud = cell(1,9);    %Initialize storage space for clause GUI parameters

%Get current index into clause  data if editing an existing clause
udind = get(uiclause.apply,'Userdata');
set(uiclause.apply,'Userdata',[]);

%Get field
wfobj = findobj(gcf,'Tag',[tagname 'fields']);
wfdat = get(wfobj,{'String','Value'});
fldstr = wfdat{1}{wfdat{2}};
ud{1} = wfdat{2};

%Get the condition
cobj = findobj(uicond.rcond,'Tag','rcond','Value',1);
tmpstr = get(cobj,'String');
if strcmp(tmpstr,'Relation')
  rdat = get(uicond.relation,{'String','Value'});
  cndstr = rdat{1}{rdat{2}};
else
  cndstr = tmpstr;  
end
ud{2} = get(uicond.rcond,'Value');

%Get the constraints
switch tmpstr
  case 'Relation'     %conditional operator
    lstr = get(uicond.relstring,'String');
    ud{3} = rdat{2};
    ud{4} = lstr;
    
  case 'Between'
    l1dat = get(uicond.lwstring,'String');
    l2dat = get(uicond.upstring,'String');
    lstr = [l1dat ' AND ' l2dat];
    ud{3} = l1dat;
    ud{4} = l2dat;
    
  case 'In'
    lstr = get(uicond.instring,'String');
    ud{3} = lstr;
            
  case 'Is Null'
    lstr = [];
    ud{3} = [];
    ud{4} = [];
    
  case 'Like'
    lstr = get(uicond.matchstring,'String');
    ud{3} = lstr;
    
end

%Get subquery data if exists
ud{6} = getuprop(gcf,'SUBQUERYDATA');
ud{7} = getuprop(gcf,'SUBQUERYSTRING');
ud{8} = getuprop(gcf,'TABLEVALUES');
ud{9} = getuprop(gcf,'FIELDVALUES');

%Get the clause operator and reset operator radios
aostr = get(findobj(uicond.andor,'Value',1),'String');
if strcmp(aostr,'None')
  aostr = [];  
end
ud{5} = get(uicond.andor,'Value');
set(uicond.andor,'Value',0);
set(findobj(uicond.andor,'String','None'),'Value',1)

%Build the clause and save it
wcobj = findobj(gcf,'Tag',[tagname 'clauses']);
curclause = get(wcobj,'String');
curuserd = get(wcobj,'Userdata');

%Include existing grouping syntax
if isempty(udind)
  openpar = [];
  closepar = [];
else
  
  tmpclause = curclause{udind};

  %Restore open parenthesis
  pari = find(tmpclause == '(');
  spci = find(tmpclause == ' ');
  j = find(pari < spci(1));
  openpar = tmpclause(pari(j));

  %Restore closing parenthesis
  pari = find(tmpclause == ')');
  spci = find(tmpclause == ' ');
  j = find(pari > spci(end-1) & pari < spci(end));
  closepar = tmpclause(pari(j));
  
end

%Build new clause
newclause = [openpar fldstr ' ' upper(cndstr) ' ' lstr ' ' closepar ' ' aostr];

%Append/Update clause
if isempty(curuserd)    %No user data
  newud = ud;
  hwclause = {newclause};
  lval = 1;
elseif isempty(udind)   %Append user data
  newud = [curuserd;ud];
  hwclause = [curclause;{newclause}];
  lval = size(hwclause,1);
else
  curuserd(udind,:) = ud;   %Modify user data
  newud = curuserd;
  curclause{udind} = newclause;
  hwclause = curclause;
  lval = udind;
end 

set(wcobj,'String',hwclause,'Value',[],'Userdata',newud)

%Clear the gui (edit boxes for now)
set(findobj(gcf,'Style','edit'),'String',[])
set(uicond.rcond,'Value',0)
set(findobj(uicond.rcond,'Tag','rcond','String','Relation'),'Value',1)
set(uicond.subquery,'Enable','on')


function applyordergroup(obj,evd,frame)
%APPLYORDERGROUP Apply function for Order or Group By clause dialog

tagname = getappdata(frame,'tagname');
ud = cell(1,4);    %Initialize storage space for clause GUI parameters

%Get current index into orderbyclause data if editing an existing clause
inobj = findobj(gcf,'Tag','Apply');
udind = get(inobj,'Userdata');
set(inobj,'Userdata',[]);

%Get field
wfobj = findobj(gcf,'Tag',[tagname 'fields']);
wfdat = get(wfobj,{'String','Value'});
fldstr = wfdat{1}{wfdat{2}};
ud{1} = wfdat{2};

%Get current clause data
ocobj = findobj(gcf,'Tag',[tagname 'clauses']);
curclause = get(ocobj,'String');
curuserd = get(ocobj,'Userdata');

%Define edit behavior to avoid duplicate entries
if ~isempty(udind)
  curclause(udind) = [];
  curuserd(udind,:) = [];
end

%Get size of current clauses
[m,n] = size(curclause);

%Get the sort key number
sobj = findobj(gcf,'Tag','sortkey');
tmpstr = get(sobj,'String');
tmpval = str2double(tmpstr);
if isnan(tmpval)
  tmpval = m+1;     %Default sort key number is m+1  
end
ud{2} = tmpval;
    
%Get the sort order
if strcmp(tagname,'orderby');
  oobj = findobj(gcf,'Tag','sortorder');
  ud{3} = get(oobj,'Value');
  orderstr = [' ' get(findobj(oobj,'Value',1),'Userdata')];
  ud{4} = orderstr;
else
  orderstr = [];
end

%Build the clause and save it
newclause = [fldstr orderstr];
   
%Display clause in desired order
if isempty(curclause)
  so = tmpval;              %sortorder is single value if no current clause
else
  so = [(2:m+1)';tmpval];   %Increment row number by 1 to get newclause into right slot
end  
[y,i] = sort(so);
tmpclause = [curclause;{newclause}];
tmpud = [curuserd;ud];
ordergroupclause = tmpclause(i);
newud = tmpud(i,:);

set(ocobj,'String',ordergroupclause,'Value',[],'Userdata',newud)

%Clear the gui (edit boxes for now)
set(findobj(gcf,'Style','edit'),'String',[])


function applysubquerydlg(obj,evd,frame)
%APPLYSUBQUERYDLG Accept subquery clause.

ui = getappdata(frame,'uidata');

%Get userdata of listbox to store whereclause settings 
wcind = get(gcbo,'Userdata');    %Edit exist clause
wcdat = get(ui.swhereclauses,'Userdata');
if isempty(wcdat)
  wind = 1;
  wcdat = cell(1,5);
elseif ~isempty(wcind)
  wind = wcind;
else
  [m,n] = size(wcdat);
  wind = m+1;
end

set(gcbo,'Userdata',[])   %Reset whereclause index

%Build where clause
robj = findobj(ui.srcond,'Value',1); %Get condition
rstr = get(robj,'String');
wstr = get(ui.swherefields,'String');
if isempty(wstr)
  return
end
wval = get(ui.swherefields,'Value');
wfld = wstr{wval};
oobj = findobj(ui.swops,'Value',1); %Get clause operator
opstr = get(oobj,'String');
if strcmp(opstr,'None')
  opstr = [];
else
  opstr = [opstr ' '];
end
wcdat{wind,1} = wval;   %Fill general clause data cell array
wcdat{wind,2} = get(ui.srcond,'Value');
wcdat{wind,5} = get(ui.swops,'Value');

switch rstr   %Extract for given condition

  case 'Relation'
  
    pstr = get(ui.srelop,'String');
    pval = get(ui.srelop,'Value');
    relop = pstr{pval};
    vstr = get(ui.srelstring,'String');                
    clstr = [wfld ' ' relop ' ' vstr ' ' opstr]; %Build clause
    wcdat{wind,3} = pval; %Fill clause data cell array with Relation specific data
    wcdat{wind,4} = vstr;
  
  case 'Between'
  
    lstr = get(ui.slwstring,'String'); %Get constraints
    ustr = get(ui.supstring,'String');
    clstr = [wfld ' BETWEEN ' lstr ' AND ' ustr ' ' opstr]; %Build clause        
    wcdat{wind,3} = lstr; %Fill clause data cell array with Between specific data
    wcdat{wind,4} = ustr;
  
  case 'In'
  
    istr = get(ui.sinstring,'String'); %Get constraints
    clstr = [wfld ' IN ' istr ' ' opstr];  %Build clause
    wcdat{wind,3} = istr; %Fill clause data cell array with In specific data
  
  case 'Is Null'
  
    clstr = [wfld ' IS NULL ' opstr];  %Build clause
  
  case 'Like'
  
    mstr = get(ui.smatchstring,'String'); %Get constraints
    clstr = [wfld ' LIKE ' mstr ' ' opstr];  %Build clause  
    wcdat{wind,3} = mstr; %Fill clause data cell array with Like specific data
  
end

%Update where clauses
wcstr = get(ui.swhereclauses,'String');
if ~isempty(wcind)   %Edit existing string
  wcstr{wind} = clstr;
else
  wcstr = [wcstr;{clstr}];
end
set(ui.swhereclauses,'String',wcstr,'Value',[],'Userdata',wcdat)

%Reset operator radiobuttons and edit boxes
set(ui.swops,'Value',0)
set(findobj(ui.swops,'String','None'),'Value',1)
set(findobj('Userdata','whereedit'),'String',[])

if ~isempty(get(ui.subquerystr,'String'))
  subqfields([],[],frame)
end


function buildquery(obj,evd,frame)
%BUILDQUERY SQL statement builder.
%   BUILDQUERY builds an SQL statement for execution in the given
%   database.

ui = getappdata(frame,'uidata');

%Get the selected fields
fdat = get(ui.fields,{'String','Value'});
fstr = fdat{1}(fdat{2});

if isempty(fstr) | isempty(fdat{2})    %Do not build query if no fields are selected
  return
end

%Determine if building insert command or SQL Select statement
rwstr = get(findobj(ui.soi,'Value',1),'String');

%If select, fields do not have quotes around them in string
switch rwstr
    case 'Select'
      flddlm = ',';
    case 'Insert'
      flddlm = ''',''';
end

fields = [];
for i = 1:length(fstr)-1
  fields = [fields fstr{i} flddlm];
end
if isempty(fields)
  i = 0;
end
fields = [fields fstr{i+1}]; 

%Get the selected table
tdat = get(ui.tables,{'String','Value'});
table = {tdat{1}{tdat{2}}};

switch rwstr
  case 'Select'

    %Create table list for JOIN operation (more than one table selected)
    tables = [];
    for i = 1:length(table)-1
     tables = [tables table{i} ','];
    end
    if isempty(tables)
      i = 0;
    end
    tables = [tables table{i+1}];

    %Get the ALL or DISTINCT keyword
    aodobj = findobj(ui.aod,'Tag','AoD','Value',1);
    selkey = get(aodobj,'Userdata');

    %Build SELECT statement
    s = ['SELECT '  selkey ' ' fields ' FROM ' tables];

    %Append WHERE clauses if they exist
    wcdat = get(ui.whereclausedata,'Userdata');
    if ~isempty(wcdat) 
      if ~isempty(wcdat{1})
        wcstr = wcdat{1};     %Where clause strings
        w = [];
        for i = 1:length(wcstr)
          w = [w ' ' wcstr{i}];
        end
        s = [s ' WHERE' w];
      end
    end

    %Append GROUP BY clauses if they exist
    gcdat = get(ui.groupbyclausedata,'Userdata');
    if ~isempty(gcdat)
      if ~isempty(gcdat{1})
        gcstr = gcdat{1};
        g = [];
        for i = 1:length(gcstr)
          if isempty(g)
            g = [g ' ' gcstr{i}];
          else
            g = [g ', ' gcstr{i}];
          end
        end
        s = [s ' GROUP BY' g];
      end    
    end

    %Append HAVING clause if it exists
    hcdat = get(ui.havingclausedata,'Userdata');
    if ~isempty(hcdat)
      if ~isempty(hcdat{1})
        hcstr = hcdat{1};
        h = [];
        for i = 1:length(hcstr)
          h = [h ' ' hcstr{i}];
        end
        s = [s ' HAVING' h];
      end
    end

    %Append ORDER BY clauses if they exist
    ocdat = get(ui.orderbyclausedata,'Userdata');
    if ~isempty(ocdat)
      if ~isempty(ocdat{1})
        ocstr = ocdat{1};
        o = [];
        for i = 1:length(ocstr)
          if isempty(o)
            o = [o ' ' ocstr{i}];
          else
            o = [o ', ' ocstr{i}];
          end
        end
        s = [s ' ORDER BY' o];
      end    
    end

    %Perform error checking for bad clause data
    eflag = errors(obj,evd,frame);
    
    %Update heading
    set(ui.typename,'String','SQL statement');

  case 'Insert'
     
    %Get variable name from workspace to insert
    wvstr = get(ui.wkvariable,'String');
    if ~isempty(wvstr)    
      s = ['insert(conn,''' table{:} ''',{''' fields '''},' wvstr ')'];
    else
      s = [];
    end
    
    %Update heading
    set(ui.typename,'String','MATLAB command');
    
end

%Display SQL statement
set(ui.query,'String',s)

%Set saveflag to prompt user for unsaved data
set(ui.saveflag,'Value',1)

%Reset dialog name, removing loaded query name if present
set(getappdata(0,'SQLDLG'),'Name','Visual Query Builder')


function x = clausedialog(tagname,bspc,bwid,bhgt);
%CLAUSEDIALOG Main clause dialog figure window.
%   CLAUSEDIALOG(TAGNAME,BSPC,BWID,BHGT) displays the main clause dialog window
%   for the given clause type, TAGNAME.   BSPC, BWID, and BHGT are the button space, 
%   width, and height parameters.  

ui.fields = findobj('Type','figure','Tag',tagname);
if ~isempty(ui.fields)
  close(ui.fields);
end

%Format tagname
ltag = lower(tagname);
i = find(ltag == ' ');
ltag(i) = [];

f = figure('Numbertitle','off','Menubar','none','HandleVisibility','callback',...
    'Userdata','vqbdialogs','Name',[tagname ' Clauses'],'Tag',tagname,'Integerhandle','off');
fp = get(gcf,'Position');
set(gcf,'Position',[fp(1) fp(2) 7*bspc+7*bwid 6*bspc+11*bhgt]);
setappdata(f,'tagname',ltag)

%Build dialog frames
uicontrol('Enable','off','Position',[bspc 4*bspc+5*bhgt 5*bspc+7*bwid 6*bhgt]);

%Set callback function and position of Edit button 
if any(strcmp(ltag,{'where','having'}))
  editpos = bspc+bhgt;
else
  editpos = 0;
end

%Build list box to show clauses
uicontrol('Enable','off','Position',[bspc bspc 5*bspc+7*bwid bspc+5*bhgt]);
ui.clauses = uicontrol('Style','listbox','Tag',[ltag 'clauses'],'Callback',{@editclause,f},...
  'Tooltip','List of clauses','Max',2,'Value',[],...
  'Position',[2*bspc 2*bspc 5*bwid bspc+4*bhgt]);
uicontrol('Style','text','String','Current clauses','Position',[2*bspc 3*bspc+4*bhgt bwid bhgt]);

%Build pushbuttons
ui.help = uicontrol('String','Help','Tag','Help','Callback','qbhelp(get(gcf,''Tag''))',...
  'Position',[6*bspc+6*bwid 6*bspc+6*bhgt bwid-bspc bhgt]);
ui.apply = uicontrol('String','Apply','Callback',{@applycond,f},'Tag','Apply',...
  'Tooltip','Add clause',...
  'Position',[6*bspc+6*bwid 5*bspc+5*bhgt bwid-bspc bhgt]);
ui.edit = uicontrol('String','Edit','Callback',{@editclause,f},'Tag','Edit','Userdata',0,...
  'Tooltip','Edit clause',...
  'Position',[5*bspc+6*bwid 5*bspc+3*bhgt bwid bhgt]);
%Add Group clauses button if Where/Having dialog
if editpos
  ui.group = uicontrol('String','Group','Callback',{@groupclauses,f},'Tag','Group',...
    'Tooltip','Group clauses',...
    'Position',[3*bspc+5*bwid 4*bspc+2*bhgt bwid bhgt]);
  ui.ungroup = uicontrol('String','Ungroup','Callback',{@ungroupclauses,f},'Tag','Ungroup',...
    'Tooltip','Ungroup clauses',...
    'Position',[3*bspc+5*bwid 3*bspc+bhgt bwid bhgt]);
end
ui.delete = uicontrol('String','Delete','Callback',{@deleteclause,f},'Tag','Delete',...
  'Tooltip','Delete clause',...
  'Position',[5*bspc+6*bwid 4*bspc+2*bhgt bwid bhgt]);
ui.cancel = uicontrol('String','Cancel','Callback','close','Tag','Cancel',...
  'Tooltip','Close dialog without changes',...
  'Position',[5*bspc+6*bwid 3*bspc+bhgt bwid bhgt]);
ui.ok = uicontrol('String','OK','Callback',{@condok,f},'Tag','OK',...
  'Tooltip','Close dialog and build SQL statement',...
  'Position',[5*bspc+6*bwid 2*bspc bwid bhgt]);

setappdata(f,'clauseuidata',ui)


function cleanupdialog(obj,evd,frame)
%CLEANUPDIALOG Visual enhancement of dialog.

%Set colors and alignment
e = findobj(frame,'Style','edit');
l = findobj(frame,'Style','listbox');
p = findobj(frame,'Style','popupmenu');
set([e;l;p],'Backgroundcolor','white','Horizontalalignment','left')
dbc = get(0,'Defaultuicontrolbackgroundcolor');
set(frame,'Color',dbc)

%Make text boxes proper width
textuis = findobj(frame,'Style','text');
for i = 1:length(textuis)
  pos = get(textuis(i),'Position');
  ext = get(textuis(i),'Extent');
  set(textuis(i),'Position',[pos(1) pos(2) ext(3) pos(4)])
end
set(textuis,'Backgroundcolor',dbc)

%Normalize units
set(findobj(frame,'Type','uicontrol'),'Units','normal')


function closesubquerydlg(obj,evd,frame)
%CLOSESUBQUERYDLG
    
close(frame)
setappdata(0,'SUBQDLG',[])


function condandoper(tagname,bspc,bwid,bhgt)
%CONDANDOPER Condition and operator uicontrols for WHERE and HAVING clause dialogs.
%   CONDANDOPER(TAGNAME,BSPC,BWID,BHGT) builds the condition and operator uicontrols
%   for the WHERE and HAVING clause dialogs.  BSPC, BWID, and BHGT are the button space, 
%   width, and height parameters.

%Build radio buttons and edit boxes to define clause
uicontrol('Style','text','String','Condition',...
  'Position',[4*bspc+2*bwid 5*bspc+10*bhgt bwid bhgt]);
ui.rcond(1) = uicontrol('Style','radiobutton','Tag','rcond',...
  'String','Like','Callback',{@rrcond,gcf},...
  'Position',[4*bspc+2*bwid 6*bspc+5*bhgt bwid bhgt]);
ui.matchstring = uicontrol('Style','edit','Tag','matchstring',...
  'Tooltip','Comparison string or value ie ''abc'' or 1',...
  'Position',[4*bspc+3*bwid 6*bspc+5*bhgt bspc+2*bwid bhgt]);
ui.rcond(2) = uicontrol('Style','radiobutton','Tag','rcond',...
  'String','Is null','Callback',{@rrcond,gcf},...
  'Position',[4*bspc+2*bwid 6*bspc+6*bhgt bwid bhgt]);
ui.rcond(3) = uicontrol('Style','radiobutton','Tag','rcond',...
  'String','In','Callback',{@rrcond,gcf},...
  'Position',[4*bspc+2*bwid 6*bspc+7*bhgt bwid bhgt]);
ui.instring = uicontrol('Style','edit','Tag','instring',...
  'Tooltip','List of comparison strings or values ie (''abc'',''cde'') or (1,2)',...
  'Position',[4*bspc+3*bwid 6*bspc+7*bhgt bspc+2*bwid bhgt]);
ui.rcond(4) = uicontrol('Style','radiobutton','Tag','rcond',...
  'String','Between','Callback',{@rrcond,gcf},...
  'Position',[4*bspc+2*bwid 6*bspc+8*bhgt bwid bhgt]);
ui.lwstring = uicontrol('Style','edit','Tag','lwstring',...
  'Tooltip','Lower bound comparison string or value ie ''abc'' or 1',...
  'Position',[4*bspc+3*bwid 6*bspc+8*bhgt bwid bhgt]);
ui.upstring = uicontrol('Style','edit','Tag','upstring',...
  'Tooltip','Upper bound comparison string or value ie ''cde'' or 2',...
  'Position',[5*bspc+4*bwid 6*bspc+8*bhgt bwid bhgt]);
ui.rcond(5) = uicontrol('Style','radiobutton','Tag','rcond','Value',1,...
  'String','Relation','Callback',{@rrcond,gcf},...
  'Position',[4*bspc+2*bwid 6*bspc+9*bhgt bwid bhgt]);
ui.relation = uicontrol('Style','popupmenu','String',{'=','<','>','>=','<=','<>'},'Tag','relation',...
  'Tooltip','Relational operator',...
  'Position',[4*bspc+3*bwid 6*bspc+9*bhgt bwid bhgt]);
ui.relstring = uicontrol('Style','edit','Tag','relstring',...
  'Tooltip','Comparison string or value ie ''abc'' or 1',...
  'Position',[5*bspc+4*bwid 6*bspc+9*bhgt bwid bhgt]);

%Build AND/OR radio buttons, add subquery button
ui.subquery = uicontrol('String','Subquery...','Callback',{@subquerydialog,gcf},...
    'Tooltip','Build a subquery',...
    'Position',[6*bspc+6*bwid 6*bspc+9*bhgt bwid-bspc bhgt]);
uicontrol('Style','text','String','Operator',...
  'Position',[7*bspc+5*bwid 5*bspc+10*bhgt bwid bhgt]);
ui.andor(1) = uicontrol('Style','radiobutton','Tag','andor',...
  'Tooltip','AND operator',...
  'String','AND','Callback',{@andor,gcf},'Value',0,...
  'Position',[7*bspc+5*bwid 6*bspc+9*bhgt bwid-2*bspc bhgt]);
ui.andor(2) = uicontrol('Style','radiobutton','Tag','andor',...
  'Tooltip','OR operator',...
  'String','OR','Callback',{@andor,gcf},'Value',0,...
  'Position',[7*bspc+5*bwid 6*bspc+8*bhgt bwid-2*bspc bhgt]);
ui.andor(3)= uicontrol('Style','radiobutton','Tag','andor',...
  'Tooltip','No operator',...
  'String','None','Callback',{@andor,gcf},'Value',1,...
  'Position',[7*bspc+5*bwid 6*bspc+7*bhgt bwid-2*bspc bhgt]);
 
%Fill dialog with existing dialog
ewcobj = findobj('Tag',[lower(tagname) 'clausedata']);
ewcdat = get(ewcobj,'Userdata');
if ~isempty(ewcdat)
  wcstr = ewcdat{1};
  wcdat = ewcdat{2};
  wclobj = findobj('Tag',[lower(tagname) 'clauses']);
  set(wclobj,'String',wcstr,'Userdata',wcdat)
end

%Store ui handles
setappdata(gcf,'conduidata',ui)


function condok(obj,evd,frame)
%CONDOK Accept changes and close condition dialog.

tagname = getappdata(frame,'tagname');

%Add the clauses to the current query
wcobj = findobj(gcf,'Tag',[tagname 'clauses']);
wcstr = get(wcobj,'String');
wcud = get(wcobj,'Userdata');
wcdat = {wcstr wcud};
close
set(findobj('Tag',[tagname 'clausedata']),'Userdata',wcdat)
f = getappdata(0,'SQLDLG');
figure(f);
ui = getappdata(f,'uidata');
qstr = get(ui.query,'String');
if ~isempty(qstr)
  buildquery([],[],f);
end

%Fill listbox for visual queue that clause data exists
set(findobj('Tag',[tagname 'list']),'String',wcstr,'Value',[])


function deleteclause(obj,evd,frame)
%DELETE Remove clause from list

tagname = getappdata(frame,'tagname');
wcobj = findobj(frame,'Tag',[tagname 'clauses']);

%Update string
clsdat = get(wcobj,{'String','Value'});
if ~isempty(clsdat{1})
  clsdat{1}(clsdat{2}) = [];
  hwclause = clsdat{1};
  
  %Update userdata
  curud = get(wcobj,'Userdata');
  curud(clsdat{2},:) = [];

  set(wcobj,'String',hwclause,'Value',[],'Userdata',curud)
end


function deletesubqclause(obj,evd,frame)
%DELETESUBQCLAUSE 

ui = getappdata(frame,'uidata');

%Delete where clauses
wcstr = get(ui.swhereclauses,'String');
wcval = get(ui.swhereclauses,'Value');
wcdat = get(ui.swhereclauses,'Userdata');
if ~isempty(wcstr)
  wcstr(wcval) = [];
  wcdat(wcval,:) = [];
end
set(ui.swhereclauses,'String',wcstr,'Value',[],'Userdata',wcdat)
subqfields([],[],frame)


function displayfieldsbox(tagname,bspc,bwid,bhgt,selflag)
%DISPLAYFIELDSBOX Displays current fields in the select clause dialog box
%   DISPLAYFIELDSBOX(TAGNAME,BSPC,BWID,BHGT,SELFLAG) displays the current fields in a list box in the
%   current select clause dialog box, ie WHERE, ORDER BY.  TAGNAME is the tag assigned 
%   to the listbox.  BSPC, BWID, and BHGT are the button space, width, and height parameters.
%   SELFLAG determines whether all valid fields are displayed or only those in the SELECT statement.
%   Using a GROUP BY clause makes only SELECTed fields valid for ORDER BY clauses.

%Default selflag is 0
if nargin < 5
  selflag = 0;
end

%Get all valid fields or selected fields depending on flag
ui.fields = findobj('Tag','fields');
fstr = get(ui.fields,'String');
fval = get(ui.fields,'Value');
if selflag
  fldstr = fstr(fval);  
else 
  fldstr = fstr;
end

%Build uicontrols
uicontrol('Style','text','String','Fields',...
  'Position',[2*bspc 5*bspc+10*bhgt bwid bhgt]);
uicontrol('Style','listbox','String',fldstr,...
  'Tooltip','Valid fields',...
   'Tag',tagname,'Max',1,'Position',[2*bspc 5*bspc+5*bhgt 2*bwid 5*bhgt]);


function editclause(obj,evd,frame)
%EDITCLAUSE 

%Enable listbox double click behavior
if strcmp(get(gcbo,'Style'),'listbox')
  pbobj = findobj(frame,'Tag','Edit','Style','pushbutton');
  if (now - get(pbobj,'Userdata')) > 5e-6
    set(pbobj,'Userdata',now)
    set(findobj('Type','figure'),'Pointer','arrow')
    return
  end
end

uicond = getappdata(frame,'conduidata');
uiclause = getappdata(frame,'clauseuidata');
tagname = getappdata(frame,'tagname');

if any(strcmp(tagname,{'orderby';'groupby'}))
  editordergroupclause(obj,evd,frame,tagname)
  return
end

%Clear edit boxes
set(findobj(gcf,'Style','edit'),'String',[])

%Edit the selected clause
wcobj = findobj(gcf,'Tag',[tagname 'clauses']);
wcval = get(wcobj,'Value');
if length(wcval) > 1
  wcval = min(wcval);
  set(wcobj,'Value',wcval)
end
wcdat = get(wcobj,'Userdata');
if isempty(wcval),set(findobj('Type','figure'),'Pointer','arrow'),return,end
set(findobj(gcf,'Tag',[tagname 'fields']),'Value',wcdat{wcval,1})
set(uicond.rcond,{'Value'},wcdat{wcval,2})

%Fill in the uicontrols on the type of Condition
rcstr = get(findobj(uicond.rcond,'Value',1),'String');
switch rcstr
  case 'Relation'
    set(uicond.relation,'Value',wcdat{wcval,3})
    set(uicond.relstring,'String',wcdat{wcval,4})
    
  case 'Between'
    set(uicond.lwstring,'String',wcdat{wcval,3})
    set(uicond.upstring,'String',wcdat{wcval,4})
    
  case 'In'
    set(uicond.instring,'String',wcdat{wcval,3})
            
  case 'Is Null'
    
  case 'Like'
    set(uicond.matchstring,'String',wcdat{wcval,3})
    
end

%Fill the clause operator radio buttons
set(uicond.andor,{'Value'},wcdat{wcval,5})  

%Store index value into list of clauses
set(uiclause.apply,'Userdata',wcval)

%Enable subqueries if relation or in condition
if any(strcmp(get(findobj(uicond.rcond,'Value',1),'String'),{'Relation','In'}))
  set(uicond.subquery,'Enable','on')
  setuprop(gcf,'SUBQUERYDATA',wcdat{wcval,6})
  setuprop(gcf,'SUBQUERYSTRING',wcdat{wcval,7})
  setuprop(gcf,'TABLEVALUES',wcdat{wcval,8})
  setuprop(gcf,'FIELDVALUES',wcdat{wcval,9})
else
  set(uicond.subquery,'Enable','off')      
end


function editordergroupclause(obj,evd,frame,tagname)
%EDITORDERGROUPCLAUSE
            
%Clear edit boxes
set(findobj(gcf,'Style','edit'),'String',[])

%Edit the selected order/group clause
wcobj = findobj(gcf,'Tag',[tagname 'clauses']);
wcval = get(wcobj,'Value');
if length(wcval) > 1
  wcval = min(wcval);
  set(wcobj,'Value',wcval)
end
if isempty(wcval),set(findobj('Type','figure'),'Pointer','arrow'),return,end
wcdat = get(wcobj,'Userdata');
set(findobj(gcf,'Tag',[tagname 'fields']),'Value',wcdat{wcval,1})
set(findobj(gcf,'Tag','sortkey'),'String',num2str(wcval,2))
if strcmp(tagname,'orderby')
  set(findobj(gcf,'Tag','sortorder'),{'Value'},wcdat{wcval,3})
end
        
%Store index value into list of clauses
set(findobj(gcf,'Tag','Apply'),'Userdata',wcval)


function editsubqclause(obj,evd,frame)
%EDITSUBQCLAUSE Edit subquery clause.

ui = getappdata(frame,'uidata');

%Enable listbox double click behavior
if strcmp(get(gcbo,'Style'),'listbox')
  if (now - get(ui.edit,'Userdata')) > 5e-6
    set(ui.edit,'Userdata',now)
    set(findobj('Type','figure'),'Pointer','arrow')
    return
  end
end
             
%Clear edit boxes
set(findobj('Userdata','whereedit'),'String',[])
    
%Fill boxes with data from selected clause
wcdat = get(ui.swhereclauses,'Userdata');
wcval = get(ui.swhereclauses,'Value');
if isempty(wcval), return, end
if length(wcval) > 1
  wcval = min(wcval);
  set(ui.swhereclauses,'Value',wcval)
end
set(ui.apply,'Userdata',wcval) %Store index of edit line
set(ui.swherefields,'Value',wcdat{wcval,1})
set(ui.srcond,{'Value'},wcdat{wcval,2})
set(ui.swops,{'Value'},wcdat{wcval,5})

%Fill condition specific uicontrols
tmp = flipud(wcdat{wcval,2});
cind = find([tmp{:}]);

switch cind
  
  case 1  %Relation
    set(ui.srelop,'Value',wcdat{wcval,3})
    set(ui.srelstring,'String',wcdat{wcval,4})
    
  case 2  %Between
    set(ui.slwstring,'String',wcdat{wcval,3})
    set(ui.supstring,'String',wcdat{wcval,4})
    
  case 3  %In
    set(ui.sinstring,'String',wcdat{wcval,3})
    
  case 4  %Is Null
    
  case 5  %Like
    set(ui.smatchstring,'String',wcdat{wcval,3})
    
end


function e = errors(obj,evd,frame)
%ERRORS Error checking on query information.

ui = getappdata(frame,'uidata');

%Get data needed to look for possible problems
fdat = get(ui.fields,{'String','Value'});
gdat = get(ui.groupbyclausedata,'Userdata');
hdat = get(ui.havingclausedata,'Userdata');
odat = get(ui.orderbyclausedata,'Userdata');
e = 0;

%If no group by clauses, there should be no problems
if isempty(gdat)
  set(findobj('Type','figure'),'Pointer','arrow')
  return
end
if iscell(gdat) && isempty([gdat{:}])
  set(findobj('Type','figure'),'Pointer','arrow')
  return
end

%Get selected datasource string
sourcestr = sourcename(obj,evd,frame);

%Need connection  and dmd to determine supported GROUP BY properties
conn = loginconnect(sourcestr);
if strcmp(class(conn.Handle),'double')
  set(findobj('Type','figure'),'Pointer','arrow')
  return    %Invalid connection, stop processing
end
d = dmd(conn);

%GROUP BY clause must reference only fields chosen for select
gfld = gdat{1};
ffld = {fdat{1}{fdat{2}}};
noerror = 1;

%Determine supported Group By properties
if supports(d,'GroupByUnrelated')
elseif supports(d,'GroupByBeyondSelect')
  for i = 1:length(ffld)
    if ~strcmp(ffld(i),gfld)
      noerror = 0;
      break
    end
  end
end
close(conn)

if ~noerror  %Found field in GROUP BY clause no selected in statement
  errordlg('GROUP BY clause must reference all fields found in SELECT statement.');
  set(findobj('Type','figure'),'Pointer','arrow')
  e = 1;
  return
end

%Get GROUP BY and HAVING fields clashes
if ~isempty(hdat)
  hfld = hdat{1};
  for i = 1:length(hfld)
    tmpfld = hfld{i};
    j = find(tmpfld == ' ');
    tmpfld = tmpfld(1:j(1)-1);
    noerror = min(noerror,any(strcmp(tmpfld,gfld)));  %Noerror flag set to 0 if mismatch found
  end
end
if ~noerror  %Found case where HAVING field not in GROUP BY fields
  errordlg('HAVING clause references fields not found in GROUP BY clause.');
  set(findobj('Type','figure'),'Pointer','arrow')
  e = 1;
  return
end

%Get GROUP BY and ORDER BY fields clashes
if ~isempty(odat)
  ofld = odat{1};
  for i = 1:length(ofld)
    tmpfld = ofld{i};
    j = find(tmpfld == ' ');
    tmpfld = tmpfld(1:j(1)-1);
    noerror = min(noerror,any(strcmp(tmpfld,gfld))); %Noerror flag set to 0 is mismatch found
  end
end
if ~noerror %Found case where ORDER BY fields not in GROUP BY fields
  errordlg('ORDER BY clauses references fields not found in GROUP BY clause.');
  set(findobj('Type','figure'),'Pointer','arrow')
  e = 1;
  return
end


function executequery(obj,evd,frame)
%EXECUTEQUERY Run built query.

anse = errors(obj,evd,frame);
if anse
  return
end

set(findobj('Type','figure'),'Pointer','watch')
ui = getappdata(frame,'uidata');

%Get query string
querystr = get(ui.query,'String');

%Get workspace variable
wkvar = get(ui.wkvariable,'String');

%Get data source
[sourcestr,sval] = sourcename(obj,evd,frame);

%Exit if query or variable string is empty or if no data source chosen
if isempty(sval)
  errordlg('Please choose a data source.')
  set(findobj('Type','figure'),'Pointer','arrow')
  return
end
if isempty(querystr)
  errordlg('No SQL statement found for execution.')
  set(findobj('Type','figure'),'Pointer','arrow')
  return
end
if isempty(wkvar) | ~isnan(str2double(wkvar))
  errordlg('Please specify a valid MATLAB workspace variable for return data storage or writing to database.')
  set(findobj('Type','figure'),'Pointer','arrow')
  return
end

%Open connection
conn = loginconnect(sourcestr);

%Determine if read or write action
rwstr = get(findobj(ui.soi,'Value',1),'String');

%Make appropriate exec or insert call
switch rwstr

  case 'Select'

    %Execute the statement
    curs = exec(conn,querystr);

    %Exit if error returned from query
    if ~isempty(curs.Message)
      errordlg(curs.Message)
      close(conn)
      set(findobj('Type','figure'),'Pointer','arrow')
      return
    end

    %No data returned by query or bad query
    ansr = struct(curs);
    if isempty(ansr.ResultSet)
      errordlg('Invalid SQL statement')
      close(conn)
      set(findobj('Type','figure'),'Pointer','arrow')
      return
    end
  
    %Fetch the data in 1000 records chunks to allow for interruption of fetch
    set(ui.vqbstatus,'String','Executing Query. Type Control-C to cancel.')
    cleanupdialog(obj,evd,frame)
    drawnow
    ansf = [];
    dfmt = setdbprefs('DataReturnFormat');
    qans = [];

    if strcmp(dfmt,'structure')
  
      curs = fetch(curs);
      ansf = curs.Data;
  
    else
      while 1  
    
        curs = fetch(curs,1280);
   
        if ~isa(curs.Data,'struct') & ~strcmp(curs.Data,'No Data')
          ansf = [ansf;curs.Data];
        else
          break
        end
      end
    end
    set(ui.vqbstatus,'String','')

    %Exit if error returned from fetch
    if ~isempty(curs.Message)
      errordlg(curs.Message)
      close(curs)
      close(conn)
      set(findobj('Type','figure'),'Pointer','arrow')
      return
    end

    %Close cursors and connections
    close(curs)
    close(conn)

    %Store data in specified variable
    assignin('base',wkvar,ansf);
 
  case 'Insert'

    try
      assignin('base','conn',conn);
      set(ui.vqbstatus,'String','Inserting data. Type Control-C to cancel.')
      cleanupdialog(obj,evd,frame)
      drawnow
      evalin('base',querystr)
      evalin('base','close(conn);clear conn')
      %Get table name for status message
      i = find(querystr == ',');
      tablestr = querystr(i(1)+2:i(2)-2);
      msgbox(['Data in variable ' wkvar ' successfully written to table ' tablestr '.'])
    catch
      errordlg(lasterr)
    end
end
set(ui.vqbstatus,'String','')
varlist(obj,evd,frame)   
set(findobj('Type','figure'),'Pointer','arrow')


function exitvqb(obj,evd,frame)
%EXITVQB Close querybuilder.    

%Determine if unsaved query data in window
sflag = get(findobj(gcf,'Tag','saveflag'),'Value');
if sflag
  bname = questdlg('Save Current Query?','Unsaved Query Data...');
  switch bname
    case 'Yes'
      savevqb(obj,evd,frame);
    case 'No'
    case 'Cancel'
      set(findobj('Type','figure'),'Pointer','arrow')
      return
  end
end  
%Close all subdialogs
close(findobj('Userdata','vqbdialogs'))
close(findobj('Tag','CHTDLG'))
closereq 
setappdata(0,'SQLDLG',[])   


function filldialog(tagname)
%FILLDIALOG Group By and Order By dialog parameters.
%   FILLDIALOG(TAGNAME) fill the Group By or Order By dialogs given a
%   TAGNAME string identifying which dialog is being opened.

%Fill dialog with existing dialog
eocobj = findobj('Tag',[tagname 'clausedata']);
eocdat = get(eocobj,'Userdata');
if ~isempty(eocdat)
  ocstr = eocdat{1};
  ocdat = eocdat{2};
  oclobj = findobj('Tag',[tagname 'clauses']);
  set(oclobj,'String',ocstr,'Userdata',ocdat)
end


function groupby(obj,evd,frame)
%GROUPBY Group By clause button.

ui = getappdata(frame,'uidata');
[dfp,mfp,bspc,bhgt,bwid,bwid2] = spaceparams(obj,evd,frame);

%Cannot display GROUP BY dialog without any fieldname 
fstr = get(ui.fields,'String');
fval = get(ui.fields,'Value');
if isempty(fstr) | isempty(fval)    %No table  or fields selected 
  errordlg('No fieldnames selected.');
  set(findobj('Type','figure'),'Pointer','arrow')
  return
end

%Get selected datasource string
sourcestr = sourcename(obj,evd,frame);

%Need connection  and dmd to determine supported GROUP BY properties
conn = loginconnect(sourcestr);
if strcmp(class(conn.Handle),'double')
  set(findobj('Type','figure'),'Pointer','arrow')
  return    %Invalid connection, stop processing
end
d = dmd(conn);
    
%Build GROUP BY clause dialog
clausedialog('GROUP BY',bspc,bwid,bhgt);

%Table fieldnames
x = supports(d,'GroupByBeyondSelect') | supports(d,'GroupByUnrelated');
displayfieldsbox('groupbyfields',bspc,bwid,bhgt,~x);
close(conn)

%Build edit boxes to define clause
uicontrol('Style','text','String','Group key number',...
  'Position',[4*bspc+2*bwid 5*bspc+10*bhgt bwid bhgt]);
uicontrol('Style','edit','Tag','sortkey','String','1',...
  'Tooltip','Entry number in clause list',...
  'Position',[4*bspc+2*bwid 3*bspc+9*bhgt bwid bhgt]);

%Fill dialog with existing dialog
filldialog('groupby');
cleanupdialog([],[],gcf)


function groupclauses(obj,evd,frame)
%GROUPCLAUSES Clause precedence grouping.

ui = getappdata(frame,'uidata');

%Find the object containing the clauses
dlgstr = get(gcf,'Tag');
switch dlgstr
  case 'WHERE'
    ui.whereclausedata = findobj(gcf,'Tag','whereclauses');    %whereclauses
  case 'SUBQDLG'
    ui.whereclausedata = findobj(gcf,'Tag','swhereclauses');    %subquery whereclauses
end

%Get the string and chosen clauses
wstr = get(ui.whereclausedata,'String');
wval = get(ui.whereclausedata,'Value');
nvals = length(wval);

%Add parenthesis
if ~isempty(wval)
  wstr{wval(1)} = ['(' wstr{wval(1)}];
  %If logical operator in last clause, put ) before it
  i = findstr(wstr{wval(nvals)},' AND');
  if isempty(i)
    i = findstr(wstr{wval(nvals)},' OR');
  end
  if isempty(i)
    wstr{wval(nvals)} = [wstr{wval(nvals)} ') '];
  else
    wlen = length(wstr{wval(nvals)});
    wstr{wval(nvals)} = [wstr{wval(nvals)}(1:i-1) ' ) ' wstr{wval(nvals)}(i+1:wlen)];
  end
  set(ui.whereclausedata,'String',wstr)
end

%Update subquery sql statement if in subquery dialog
switch dlgstr
  case 'SUBQDLG'
    subqfields([],[],frame)
end


function having(obj,evd,frame)
%HAVING Having clause button.

ui = getappdata(frame,'uidata');
[dfp,mfp,bspc,bhgt,bwid,bwid2] = spaceparams(obj,evd,frame);

%Do not display HAVING dialog if WHERE dialog is open
ui.whereclausedata = findobj('Tag','WHERE');
if ~isempty(ui.whereclausedata)
  errordlg('Close WHERE clauses... dialog before building HAVING clause.')
  set(findobj('Type','figure'),'Pointer','arrow')
  return
end

%Need valid GROUP BY clause in order to create HAVING clause
gudt = get(ui.groupbyclausedata,'Userdata');
hudt = get(ui.havingclausedata,'Userdata');
if isempty(gudt) & isempty(hudt) %Allow HAVING to open if existing HAVING clause
  errordlg('HAVING clause cannot be built without existing GROUP BY clause.');
  set(findobj('Type','figure'),'Pointer','arrow')
  return
end

%Build HAVING clause dialog
clausedialog('HAVING',bspc,bwid,bhgt);

%Selected table fieldnames
displayfieldsbox('havingfields',bspc,bwid,bhgt,1);

%Build conditions and operator uicontrols
condandoper('HAVING',bspc,bwid,bhgt);
cleanupdialog([],[],gcf)


function loadvqb(obj,evd,frame)
%LOADVAB Load an SQL statement from a file

ui = getappdata(frame,'uidata');

[f,p] = uigetfile('*.qry','Load SQL Statement...');
if f == 0
  set(findobj('Type','figure'),'Pointer','arrow')
  return
end

try  
  eval(['load ''' p f ''' -mat'])      
  
  sval = find(strcmp(get(ui.sources,'String'),sstr));    %Reset source
  if isempty(sval)
    errordlg(['Data source ' sstr ' not found.']);
    set(findobj('Type','figure'),'Pointer','arrow')
    return
  end
  set(ui.sources,'Value',sval);      
  sources(obj,evd,frame);   %Update tables based on data source
  
  tval = [];
  for i = 1:length(tstr)
    tval(i) = find(strcmp(get(ui.tables,'String'),tstr{i}));    %Reset tables
  end  
  set(ui.tables,'Value',tval);
  tablesvqb(obj,evd,frame);    %Update fields based on tables
  
  fval = [];
  for i = 1:length(fstr)
    fval(i) = find(strcmp(get(ui.fields,'String'),fstr{i}));    %Reset fields
  end  
  set(ui.fields,'Value',fval);
  buildquery(obj,evd,frame);    %Update SQL statement
  
  %Reset ALL/DISTINCT flag
  set(ui.aod,{'Value'},aodval)
  
  %Get the clause data for saving
  set(ui.whereclausedata,'Userdata',wdat);
  set(ui.groupbyclausedata,'Userdata',gdat);
  set(ui.havingclausedata,'Userdata',hdat);
  set(ui.orderbyclausedata,'Userdata',odat);
  if ~isempty(wdat),set(findobj('Tag','wherelist'),'String',wdat{1}),end
  if ~isempty(gdat),set(findobj('Tag','groupbylist'),'String',gdat{1}),end
  if ~isempty(hdat),set(findobj('Tag','havinglist'),'String',hdat{1}),end
  if ~isempty(odat),set(findobj('Tag','orderbylist'),'String',odat{1}),end
  
  %Rebuild the SQL statement 
  buildquery(obj,evd,frame);
  
  %Redisplay save query string in case it was manually modified
  if exist('querystr')
    set(ui.query,'String',querystr)
  end
  
  %Display loaded query name in title bar
  set(gcf,'Name',['Visual Query Builder - ' f])
  
  %Check Select or Insert as appropriate
  if exist('querystr')
    if strcmp(upper(querystr(1:6)),'INSERT')
      set(ui.soi(2),'Value',1)
      set(ui.soi(1),'Value',0)
    else
      set(ui.soi(2),'Value',0)
      set(ui.soi(1),'Value',1)
    end
  end
  
  %Unset save flag, buildquery sets it by default, does not apply for this action
  set(findobj(gcf,'Tag','saveflag'),'Value',0)
  
catch
  
  errordlg(['Unable to load ' p f]);
  
end


function orderby(obj,evd,frame)
%ORDERBY Order By clause button.

ui = getappdata(frame,'uidata');
[dfp,mfp,bspc,bhgt,bwid,bwid2] = spaceparams(obj,evd,frame);

%Cannot display ORDER BY dialog without any fieldnames    
fstr = get(ui.fields,'String');
if isempty(fstr)
  errordlg('No table selected.');
  set(findobj('Type','figure'),'Pointer','arrow')
  return
end

%Build ORDER BY clause dialog
clausedialog('ORDER BY',bspc,bwid,bhgt);

%Table fieldnames, if GROUP BY clause exists, only fields in 
%GROUP BY clause are relevant
gudt = get(ui.groupbyclausedata,'Userdata');
if isempty(gudt)
  selflag = 0;
else
  selflag = 1;
end
displayfieldsbox('orderbyfields',bspc,bwid,bhgt,selflag);

%Build radio buttons and edit boxes to define clause
uicontrol('Style','text','String','Sort key number',...
  'Position',[4*bspc+2*bwid 5*bspc+10*bhgt bwid bhgt]);
uicontrol('Style','edit','Tag','sortkey','String','1',...
  'Tooltip','Entry number in clause list',...
  'Position',[4*bspc+2*bwid 3*bspc+9*bhgt bwid bhgt]);
uicontrol('Style','text','String','Sort order',...
  'Position',[7*bspc+3*bwid 5*bspc+10*bhgt bwid bhgt]);
uicontrol('Style','radiobutton','Tag','sortorder','Userdata','ASC',...
  'Tooltip','Sort field in ascending order',...
  'String','Ascending','Callback',{@sortorder},'Value',1,...
  'Position',[7*bspc+3*bwid 5*bspc+9*bhgt bwid bhgt]);
uicontrol('Style','radiobutton','Tag','sortorder','Userdata','DESC',...
  'Tooltip','Sort field in descending order',...
  'String','Descending','Callback',{@sortorder},'Value',0,...
  'Position',[7*bspc+3*bwid 5*bspc+8*bhgt bwid bhgt]);

%Fill dialog with existing dialog
filldialog('orderby');
cleanupdialog([],[],gcf)


function prefapply(obj,evd,frame)
%PREFAPPLY Preferences dialog Apply button.

nsr = get(findobj('Tag','NullStringRead'),'String');
nnr = get(findobj('Tag','NullNumberRead'),'String');
nsw = get(findobj('Tag','NullStringWrite'),'String');
nnw = get(findobj('Tag','NullNumberWrite'),'String');
dp = {'cellarray';'numeric';'structure'};
drf = dp{get(findobj('Tag','DataReturn'),'Value')};
ep = {'store';'report';'empty'};
ehb = ep{get(findobj('Tag','ErrorHandling'),'Value')};

%Trap bad settings
if isempty(nnr) | strcmp(nnr,'[]')
  if any(strcmp(drf,{'numeric','structure'}))
    errordlg('Please enter a value for NULL number read.')
    set(findobj('Type','figure'),'Pointer','arrow')
    return
  end
  nnr = '[]';
end

setdbprefs({'NullStringRead';'NullNumberRead';'NullStringWrite';'NullNumberWrite';'DataReturnFormat';'ErrorHandling'},...
  {nsr;nnr;nsw;nnw;drf;ehb});


function preferences(obj,evd,frame)
%PREFERENCES Build preferences dialog

%GUI spacing
[dfp,mfp,bspc,bhgt,bwid,bwid2] = spaceparams([],[],[]);

f = findobj('Tag','VQBPrefs');
if isempty(f)
  f = figure('Tag','VQBPrefs','Name','Database Toolbox Preferences','Userdata','vqbdialogs',...
    'HandleVisibility','callback','Menubar','none','Integerhandle','off','Numbertitle','off');
  set(f,'Keypressfcn',{@prefok,f});
else
  figure(f);
  set(findobj('Type','figure'),'Pointer','arrow')
  return
end
p = get(f,'Position');
    
%Frame dimensions
fwid1 = 5*bspc+3*bwid;
fhgt1 = 4*bspc+5*bhgt;
fwid2 = 2*bspc+2*bwid;
fhgt2 = 5*bspc+4*bhgt;
fwid3 = 3*bspc+fwid1+fwid2;
fhgt3 = 3*bspc+7*bhgt;

%Reset figure position
set(f,'Position',[p(1) p(2) 2*bspc+fwid3 bspc+fhgt3]);
p = get(f,'Position');
rgt = p(3);
top = p(4);

%Build NULL data handling uicontrols
prefs = setdbprefs;  %Get current settings
uicontrol('Enable','off','Position',[2*bspc top-(6*bspc+5*bhgt) fwid1 fhgt1]);
uicontrol('Style','text','String','Null data handling',...
  'Position',[3*bspc top-(bspc+bhgt) bwid bhgt]);
uicontrol('Style','text','String','Read NULL strings as:','Fontweight','bold',...
  'Position',[4*bspc top-(2*bspc+2*bhgt) bwid bhgt]);
uicontrol('Style','edit','Tag','NullStringRead','String',prefs.NullStringRead,...
  'Position',[5*bspc+2*bwid top-(bspc+2*bhgt) bwid bhgt]);
uicontrol('Style','text','String','Read NULL numbers as:','Fontweight','bold',...
  'Position',[4*bspc top-(3*bspc+3*bhgt) bwid bhgt]);
    uicontrol('Style','edit','Tag','NullNumberRead','String',prefs.NullNumberRead,...
  'Position',[5*bspc+2*bwid top-(2*bspc+3*bhgt) bwid bhgt]);
uicontrol('Style','text','String','Write NULL strings from:','Fontweight','bold',...
  'Position',[4*bspc top-(4*bspc+4*bhgt) bwid bhgt]);
uicontrol('Style','edit','Tag','NullStringWrite','String',prefs.NullStringWrite,...
  'Position',[5*bspc+2*bwid top-(3*bspc+4*bhgt) bwid bhgt]);
uicontrol('Style','text','String','Write NULL numbers from:','Fontweight','bold',...
  'Position',[4*bspc top-(5*bspc+5*bhgt) bwid bhgt]);
uicontrol('Style','edit','Tag','NullNumberWrite','String',prefs.NullNumberWrite,...
  'Position',[5*bspc+2*bwid top-(4*bspc+5*bhgt) bwid bhgt]);

%Build data return format and error handling uicontrols
uicontrol('Enable','off','Position',[3*bspc+fwid1 top-(6*bspc+5*bhgt) fwid2 fhgt1]);
uicontrol('Style','text','String','Return data',...
  'Position',[4*bspc+fwid1 top-(bspc+bhgt) bwid bhgt]);
uicontrol('Style','text','String','Data return format','Fontweight','bold',...
  'Position',[5*bspc+fwid1 top-(2*bspc+2*bhgt) bwid bhgt]);
dp = {'cellarray';'numeric';'structure'};
dpv = find(strcmp(prefs.DataReturnFormat,dp));
uicontrol('Style','popupmenu','String',dp,'Tag','DataReturn',...
  'Value',dpv,'Position',[5*bspc+fwid1 top-(2*bspc+3*bhgt) bwid bhgt]);
uicontrol('Style','text','String','Error handling','Fontweight','bold',...
  'Position',[5*bspc+fwid1 top-(4*bspc+4*bhgt) bwid bhgt]);
ep = {'store';'report';'empty'};
epv = find(strcmp(prefs.ErrorHandling,ep));
uicontrol('Style','popupmenu','String',ep,'Tag','ErrorHandling',...
  'Value',epv,'Position',[5*bspc+fwid1 top-(4*bspc+5*bhgt) bwid bhgt]);
  
%Build pushbutton uicontrols
uicontrol('String','OK','Callback',{@prefok,f},'Tag','PrefOK',...
  'Position',[7*bspc+bwid top-(7*bspc+6*bhgt) bwid bhgt]);
uicontrol('String','Cancel','Callback','close','Tag','Cancel',...
  'Position',[8*bspc+2*bwid top-(7*bspc+6*bhgt) bwid bhgt]); 
uicontrol('String','Apply','Callback',{@prefapply,f},'Tag','PrefApply',...
  'Position',[9*bspc+3*bwid top-(7*bspc+6*bhgt) bwid bhgt]);
 uicontrol('String','Help','Callback','qbhelp(''Preferences'');','Tag','PrefHelp',...
  'Position',[10*bspc+4*bwid top-(7*bspc+6*bhgt) bwid bhgt]);
   
cleanupdialog([],[],gcf);


function prefok(obj,evd,frame)
%PREFOK Accept settings and close Preferences dialog.    

prefapply(obj,evd,frame)
close


function querydata(obj,evd,frame)
%QUERYDATA Workspace variable listbox callback

ui = getappdata(frame,'uidata');

%Implement double click behavior (store time on first click)
if (now - get(ui.querydata,'Userdata')) > 5e-6
  set(ui.querydata,'Userdata',now)
  set(findobj('Type','figure'),'Pointer','arrow')
  return
end

%Get selected variable from list
dval = get(ui.querydata,'Value');
dstr = get(ui.querydata,'String');
varstr = dstr{dval};

%String up to first space if chosen variable
i = find(varstr == ' ');
v = varstr(1:i(1)-1);

%Open variable in array editor
openvar(v)


function rrcond(obj,evd,frame)
%RRCOND Clause condition radios.

ui = getappdata(frame,'conduidata');
set(ui.rcond,'Value',0)
set(gcbo,'Value',1)
set(findobj(gcf,'Style','edit'),'String',[])
if any(strcmp(get(gcbo,'String'),{'Relation','In'}))
  set(ui.subquery,'Enable','on')
else
  set(ui.subquery,'Enable','off')  
end


function savevqb(obj,evd,frame)
%SAVEVQB Save an SQL statement to a MAT file

ui = getappdata(frame,'uidata');
querystr = get(ui.query,'String');

if isempty(querystr)
  errordlg('No SQL statement to save.')
  set(findobj('Type','figure'),'Pointer','arrow')  
  return
end

[f,p] = uiputfile('*.qry','Save SQL Statement...');
if f == 0
  set(findobj('Type','figure'),'Pointer','arrow')
  return
end

%Get source, table and field information for saving
sdat = get(ui.sources,{'String','Value'});
sstr = sdat{1}{sdat{2}};
if isempty(sstr)
  errordlg('Cannot save query without datasource selected.')
  set(findobj('Type','figure'),'Pointer','arrow')  
  return
end

%Get table and field settings
tdat = [];tstr = [];fdat = [];fstr = [];
try
  tdat = get(ui.tables,{'String','Value'});
  tstr = {tdat{1}{tdat{2}}};
  fdat = get(ui.fields,{'String','Value'});
  fstr = {fdat{1}{fdat{2}}};
catch
end

%Get ALL/DISTINCT values
aodval = get(ui.aod,'Value');

%Get the clause data for saving
wdat = get(ui.whereclausedata,'Userdata');
gdat = get(ui.groupbyclausedata,'Userdata');
hdat = get(ui.havingclausedata,'Userdata');
odat = get(ui.orderbyclausedata,'Userdata');

%Append .qry to file if not given
fl = length(f);
if fl < 4 | ~strcmp(f(fl-3:fl),'.qry')
  f = [f '.qry'];
end

try 
  eval(['save ''' p f ''' sstr tstr fstr aodval wdat gdat hdat odat querystr -mat'])
  set(findobj(gcf,'Tag','saveflag'),'Value',0)    %Reset save flag
  set(gcf,'Name',['Visual Query Builder - ' f])   %Show current name
catch
  errordlg(['Unable to save query to ' p f]);
end


function sources(obj,evd,frame)
%SOURCES Datasource selection.

ui = getappdata(frame,'uidata');

%Get selected datasource string
if ~isempty(get(ui.sources,'Value'))
  [sourcestr,sval] = sourcename(obj,evd,frame);
end

%Determine if unsaved query data in window
sflag = get(ui.saveflag,'Value');
if sflag
  bname = questdlg('Save Current Query?','Unsaved Query Data...');
  switch bname
    case 'Yes'
      savevqb(obj,evd,frame);
    case 'No'
      set(ui.saveflag,'Value',0)    %Reset save flag
    case 'Cancel'
      set(findobj('Type','figure'),'Pointer','arrow')
      return
  end
end  
   
%Selecting a new data source erases any clause data
set([ui.whereclausedata,ui.orderbyclausedata,ui.groupbyclausedata,ui.havingclausedata],'Userdata',[]);

%Set visual queue listboxes to empty strings
set([ui.wherelist,ui.groupbylist,ui.havinglist,ui.orderbylist],'String',[])

%Return if no source selected
if isempty(get(ui.sources,'Value'))
  set(ui.tables,'String','')
  set(ui.fields','String','')
  set(findobj('Type','figure'),'Pointer','arrow')
  return
end

%Make connection to chosen to source
conn = loginconnect(sourcestr);
if strcmp(class(conn.Handle),'double')
  set(findobj('Type','figure'),'Pointer','arrow')
  return    %Invalid connection, stop processing
end

%Get table information (for all schemas)
d = dmd(conn);
ctg = get(conn,'Catalog');
p = get(d,'DatabaseProductName');
try
  drf = setdbprefs('DataReturnFormat');
  setdbprefs('DataReturnFormat','cellarray')
  [tableName,tableType] = alttables(conn,ctg,p,d);
  setdbprefs('DataReturnFormat',drf)
catch
  errordlg('Unable to get table information from data source.')
  set(findobj('Type','figure'),'Pointer','arrow')
  setdbprefs('DataReturnFormat',drf)
  return
end
   
%Table types of TABLE are desired tables
i = find(~(strcmp({'SYSTEM TABLE'},tableType) | ...
           strcmp({'SYNONYM'},tableType)));
table = tableName(i);

%Determine if GROUP BY and HAVING clauses are supported
x = supports(d,'GroupBy');
if (x && ~get(ui.soi(2),'Value'))
  set(ui.groupby,'Enable','on')
  set(ui.having,'Enable','on')
else
  set(ui.groupby,'Enable','off')
  set(ui.having,'Enable','off')
end

%Close connection
close(conn);

%Check for spaces in table name
for i = 1:length(table)
  tmptab = table{i};
  L = length(tmptab);
  j = find(tmptab == ' ' | tmptab == '$');
  if ~isempty(j)
    table{i} = ['"' table{i} '"'];
  end
end

%Reset fields listbox, query, workspace variable and data string so incorrect fieldnames are not showing for chosen source
set([ui.fields,ui.query,ui.wkvariable],'String',[])
set(ui.tables,'String',table(:),'Value',[])

%Set source object to allow for only data source selection
set(ui.sources,'Max',1,'Value',1)   %Need to toggle value to get correct visual effect,
set(ui.sources,'Value',sval)        %otherwise, source at end of list is scrolled of screen


function soi(obj,evd,frame)         
%AOD Select or Insert keyword to query
  
ui = getappdata(frame,'uidata');

%Update values of radiobuttons and rebuild query string       
set(ui.soi,'Value',0);
set(gcbo,'Value',1);
rwstr = get(gcbo,'String');
switch rwstr
  case 'Select'
    set([ui.where ui.groupby ui.having ui.orderby ... 
         ui.wherelist ui.groupbylist ui.havinglist ui.orderbylist],'Enable','on')
    set(ui.aod,'Enable','on',{'Value'},{1;0})
    set(ui.typename,'String','SQL statement')
  case 'Insert'
    set(ui.aod,'Enable','off',{'Value'},{0;0})
    set([ui.where ui.groupby ui.having ui.orderby ... 
         ui.wherelist ui.groupbylist ui.havinglist ui.orderbylist],'Enable','off')
    set(ui.typename,'String','MATLAB command')
end

%Build query or command if enough information is available.
try
  buildquery(obj,evd,frame);
end

cleanupdialog(obj,evd,frame)


function sortorder(obj,evd,frame)
%SORTORDER Order/Group By radio button callbacks

tag = get(gcbo,'Tag');
set(findobj(gcf,'Tag',tag),'Value',0)
set(gcbo,'Value',1)


function [sourcestr,sval] = sourcename(obj,evd,frame)
%SOURCENAME Get selected datasource string

ui = getappdata(frame,'uidata');
sstr = get(ui.sources,'String');
sval = get(ui.sources,'Value');
if ~isempty(sval)
  sval = sval(1);
  set(ui.sources,'Value',sval)                     %Do not allow multiselect
  sourcestr = sstr{sval};                          %Datasource string
end  


function [dfp,mfp,bspc,bhgt,bwid,bwid2] = spaceparams(obj,evd,frame);
%SPACEPARAMS GUI spacing parameters
dfp = get(0,'DefaultFigurePosition');
mfp = [560 420];    %Reference width and height
bspc = mean([5/mfp(2)*dfp(4) 5/mfp(1)*dfp(3)]);
bhgt = 20/mfp(2) * dfp(4);
bwid = 80/mfp(1) * dfp(3);
bwid2 = 90/mfp(1) * dfp(3);


function subqfields(obj,evd,frame)
%SUBQFIELDS Subquery dialog field selection.

ui = getappdata(frame,'uidata');

%Clear current subquery
set(ui.subquerystr,'String',[])

%Get selected tables
tstr = get(ui.stables,'String');
tval = get(ui.stables,'Value');
tablez = tstr(tval);
table = [];
for i = 1:length(tablez)
  table = [table tablez{i} ', '];
end
L = length(table);
table = table(1:L-2);

%Get selected fields
fstr = get(ui.sfields,'String');
fval = get(ui.sfields,'Value');
fields = fstr(fval);

if isempty(fields)
  return  %Cannot build query without selected fields
end  

field = [];
for i = 1:length(fields)
  field = [field fields{i} ', '];
end
L = length(field);
field = field(1:L-2);

%Get current subquery where clauses
wstr = get(ui.swhereclauses,'String');
whereclause = [];
for i = 1:length(wstr)
  whereclause = [whereclause wstr{i}];
end

%Build subquery without WHERE
subquerystr = ['SELECT ' field ' FROM ' table];

%Add where clauses
if ~isempty(whereclause)
  subquerystr = [subquerystr ' WHERE ' whereclause];
end

%Display subquery
set(ui.subquerystr,'String',subquerystr)


function subqradios(obj,evd,frame)
%SUBQRADIOS Subquery dialog radio buttons. 

%Radio button toggling
flg = get(gcbo,'Tag');
robj = findobj('Tag',flg);
set(robj,'Value',0)
set(gcbo,'Value',1)

%Clear edit boxes if Condition box is checked
if strcmp(flg,'srcond')
  set(findobj('Userdata','whereedit'),'String',[])
end


function subqtables(obj,evd,frame)
%SUBQTABLES Subquery dialog tables list.

ui = getappdata(frame,'uidata');

%Make connection to datasource
conn = loginconnect(get(ui.ssource,'String'));

%Find field names for selected tables
tstr = get(ui.stables,'String');
tval = get(ui.stables,'Value');
tablez = tstr(tval);

%Check for spaces in table name
for i = 1:length(tablez)
  tmptab = tablez{i};
  L = length(tmptab);
  i = find(tmptab == ' ');
  if any(i < L)
    errordlg('Blank spaces in tablenames are not supported.'), return
  end
end

%Get metadata of connection and get column names
d = dmd(conn);
L = length(tablez);
fields = {};
for i = 1:L
  
  table = tablez{i};  %Columns method returns more info, but is much slower
  ex = exec(conn,['select * from ' table]);
  f = fetch(ex,1);
  tmp = columnnames(f);
  eval(['tabfields = {' tmp '};'])
  close(f);close(ex); 
  
  %Prepend tablename if JOIN operation
  if length(tval) > 1
    for j = 1:length(tabfields)
      tabfields{j} = [table '.' tabfields{j}];
    end
    fields = [fields;tabfields'];
  else
    fields = tabfields';
  end
end
 
%Display fieldnames
set([ui.sfields;ui.swherefields],'String',fields,'Value',[]);
set(ui.swherefields,'Value',1,'Max',1)

%Close connection
close(conn);  

%Clear current subquery
set(ui.subquerystr,'String',[])


function subquerydialog(obj,evd,frame)
%SUBQUERYDIALOG Subquery dialog box.

%Refocus dialog if already open
sqobj = getappdata(0,'SUBQDLG');
if ~isempty(sqobj)
  figure(sqobj);
  return
end

%Figure spacing parameters
[dfp,mfp,bspc,bhgt,bwid,bwid2] = spaceparams(obj,evd,frame);
fwid = 7*bspc+6*bwid;
fhgt1 = 2*bspc+3*bhgt;
fhgt2 = 12*bhgt-bspc;
fhgt3 = 4*bhgt;
fhgt4 = 6*bhgt;

F = figure('NumberTitle','off','Name','Subquery','Menubar','none','Integerhandle','off','Userdata','vqbdialogs',...
  'HandleVisibility','callback','Tag','SUBQDLG');
setappdata(0,'SUBQDLG',F);
pos = get(F,'Position');
set(F,'Position',[pos(1) pos(2) 2*bspc+fwid pos(4)],'ResizeFcn',{@cleanupdialog,F})
pos = get(F,'Position');
rgt = pos(3); 
top = pos(4);

%Build subquery statement and dialog pushbuttons frame
uicontrol('Enable','off','Position',[bspc bspc fwid fhgt1]);
ui.cancel = uicontrol('String','Cancel','Callback',{@closesubquerydlg,F},'Tag','Cancel',...
  'Tooltip','Close dialog without changes',...
  'Position',[2.5*bspc+1.5*bwid 2*bspc bwid bhgt]);
ui.help = uicontrol('String','Help','Callback','qbhelp(''Subquery'')',...
  'Position',[3.5*bspc+2.5*bwid 2*bspc bwid bhgt]);
ui.ok = uicontrol('String','OK','Callback',{@acceptsubquery,F},'Tag','OK',...
  'Tooltip','Accept subquery',...
  'Position',[4.5*bspc+3.5*bwid 2*bspc bwid bhgt]);
ui.subquerystr = uicontrol('Style','edit','Tag','subquerystr',...
  'Tooltip','Current subquery',...
  'Position',[2*bspc 3*bspc+bhgt 5*bspc+6*bwid bhgt]);
uicontrol('Style','text','String','SQL subquery statement',...
  'Position',[2*bspc 4*bspc+2*bhgt bwid bhgt]);
    
%Build advanced subquery uicontrols
uicontrol('Enable','off','Position',[bspc 3*bspc+fhgt1 fwid fhgt2]);
uicontrol('Enable','off',...
  'Position',[2*bspc 4*bspc+fhgt1 fwid-2*bspc fhgt3]);
ui.swhereclauses = uicontrol('Style','listbox','Tag','swhereclauses','Max',2,...
  'Callback',{@editsubqclause,F},'Tooltip','List of subquery clauses',...
  'Position',[3*bspc 5*bspc+fhgt1 4*bwid 3*bhgt]);
uicontrol('Style','text','String','Current subquery WHERE clauses',...
  'Position',[3*bspc 5*bspc+fhgt1+3*bhgt bwid bhgt]);
ui.delete = uicontrol('String','Delete','Tag','Delete','Callback',{@deletesubqclause,F},...
  'Tooltip','Delete clause',...
  'Position',[6*bspc+5*bwid 7*bspc+fhgt1 bwid bhgt]);
ui.edit = uicontrol('String','Edit','Tag','Edit','Callback',{@editsubqclause,F},...
  'Userdata',0,'Tooltip','Edit Clause',...
  'Position',[6*bspc+5*bwid 8*bspc+fhgt1+bhgt bwid bhgt]);
ui.group = uicontrol('String','Group','Tag','Group','Callback',{@groupclauses,F},...
  'Tooltip','Group clause',...
  'Position',[4*bspc+4*bwid 8*bspc+fhgt1+bhgt bwid bhgt]);
ui.ungroup = uicontrol('String','Ungroup','Tag','Ungroup','Callback',{@ungroupclauses,F},...
  'Tooltip','Ungroup clauses',...
  'Position',[4*bspc+4*bwid 7*bspc+fhgt1 bwid bhgt]);

uicontrol('Enable','off',...
  'Position',[2*bspc 6*bspc+fhgt1+fhgt3 fwid-2*bspc fhgt4]);
ui.swherefields = uicontrol('Style','listbox','Tag','swherefields','Max',2,...
  'Tooltip','Fields in selected table(s)',...
  'Position',[3*bspc 7*bspc+fhgt1+fhgt3 2*bwid 5*bhgt]);
uicontrol('Style','text','String','Fields',...
  'Position',[3*bspc 7*bspc+fhgt1+fhgt3+5*bhgt bwid bhgt]);
ui.srcond(1) = uicontrol('Style','radiobutton','String','Like','Tag','srcond',...
  'Callback',{@subqradios,F},...
  'Position',[4*bspc+2*bwid 7*bspc+fhgt1+fhgt3 bwid bhgt]);
ui.srcond(2) = uicontrol('Style','radiobutton','String','Is null','Tag','srcond',...
  'Callback',{@subqradios,F},...
  'Position',[4*bspc+2*bwid 7*bspc+fhgt1+fhgt3+bhgt bwid bhgt]);
ui.srcond(3) = uicontrol('Style','radiobutton','String','In','Tag','srcond',...
  'Callback',{@subqradios,F},...
  'Position',[4*bspc+2*bwid 7*bspc+fhgt1+fhgt3+2*bhgt bwid bhgt]);
ui.srcond(4) = uicontrol('Style','radiobutton','String','Between','Tag','srcond',...
  'Callback',{@subqradios,F},...
  'Position',[4*bspc+2*bwid 7*bspc+fhgt1+fhgt3+3*bhgt bwid bhgt]);
ui.srcond(5) = uicontrol('Style','radiobutton','String','Relation','Tag','srcond','Value',1,...
  'Callback',{@subqradios,F},...
  'Position',[4*bspc+2*bwid 7*bspc+fhgt1+fhgt3+4*bhgt bwid bhgt]);
uicontrol('Style','text','String','Condition',...
  'Position',[4*bspc+2*bwid 7*bspc+fhgt1+fhgt3+5*bhgt bwid bhgt]);
ui.smatchstring = uicontrol('Style','edit','Tag','smatchstring','Userdata','whereedit',...
  'Tooltip','Comparison string or value ie ''abc'' or 1',...
  'Position',[4*bspc+3*bwid 7*bspc+fhgt1+fhgt3 2*bwid bhgt]);
ui.sinstring = uicontrol('Style','edit','Tag','sinstring','Userdata','whereedit',...
  'Tooltip','List of comparison strings or values ie (''abc'',''cde'') or (1,2)',...
  'Position',[4*bspc+3*bwid 7*bspc+fhgt1+fhgt3+2*bhgt 2*bwid bhgt]);
ui.slwstring = uicontrol('Style','edit','Tag','slwstring','Userdata','whereedit',...
  'Tooltip','Lower bound comparison string or value ie ''abc'' or 1',...
  'Position',[4*bspc+3*bwid 7*bspc+fhgt1+fhgt3+3*bhgt bwid bhgt]);
ui.supstring = uicontrol('Style','edit','Tag','supstring','Userdata','whereedit',...
  'Tooltip','Upper bound comparison string or value ie ''cde'' or 2',...
  'Position',[4*bspc+4*bwid 7*bspc+fhgt1+fhgt3+3*bhgt bwid bhgt]);
relstring = {'=';'<';'>';'>=';'<=';'<>'};
ui.srelop = uicontrol('Style','popupmenu','Tag','srelop','String',relstring,...
  'Tooltip','Relational operator',...
  'Position',[4*bspc+3*bwid 7*bspc+fhgt1+fhgt3+4*bhgt bwid bhgt]);
ui.srelstring = uicontrol('Style','edit','Tag','srelstring','Userdata','whereedit',...
  'Tooltip','Comparison string or value ie ''abc'' or 1',...
  'Position',[4*bspc+4*bwid 7*bspc+fhgt1+fhgt3+4*bhgt bwid bhgt]);
ui.apply = uicontrol('String','Apply','Tag','Apply','Callback',{@applysubquerydlg,F},'Userdata',[],...
  'Tooltip','Add clause',...
  'Position',[6*bspc+5*bwid 7*bspc+fhgt1+fhgt3 bwid bhgt]);
ui.swops(1) = uicontrol('Style','radiobutton','String','None','Value',1,'Tag','swops',...
  'Callback',{@subqradios,F},'Tooltip','No operator',...
  'Position',[6*bspc+5*bwid 7*bspc+fhgt1+fhgt3+2*bhgt bwid bhgt]);
ui.swops(2) = uicontrol('Style','radiobutton','String','OR','Tag','swops','Callback',{@subqradios,F},...
  'Tooltip','OR operator',...
  'Position',[6*bspc+5*bwid 7*bspc+fhgt1+fhgt3+3*bhgt bwid bhgt]);
ui.swops(3) = uicontrol('Style','radiobutton','String','AND','Tag','swops','Callback',{@subqradios,F},...
  'Tooltip','AND operator',...  
  'Position',[6*bspc+5*bwid 7*bspc+fhgt1+fhgt3+4*bhgt bwid bhgt]);
uicontrol('Style','text','String','Operator',...
  'Position',[6*bspc+5*bwid 7*bspc+fhgt1+fhgt3+5*bhgt bwid bhgt]);
uicontrol('Style','text','String','Subquery WHERE clauses',...
  'Position',[2*bspc 7*bspc+fhgt1+fhgt3+6*bhgt bwid bhgt]);

%Build source, tables, and fields uicontrols
uicontrol('Enable','off','Position',[bspc 5*bspc+fhgt1+fhgt2 fwid bspc+4*bhgt]);
uicontrol('Style','text','String','Data source','Position',[2*bspc top-bhgt bwid bhgt]);
sqldlg = getappdata(0,'SQLDLG');
uimain = getappdata(sqldlg,'uidata');
sstr = get(uimain.sources,'String');
sval = get(uimain.sources,'Value');
if isempty(sqldlg) | isempty(sval)
  datasource = [];
else
  datasource = sstr{sval};
end  
ui.ssource = uicontrol('Style','text','Fontweight','bold','String',datasource,'Tag','ssource',...
  'Position',[2*bspc top-(bspc+2*bhgt) bwid bhgt]);
uicontrol('Style','text','String','Tables',...
  'Position',[3*bspc+2*bwid top-bhgt bwid bhgt]);
tstr = get(uimain.tables,'String');
ui.stables = uicontrol('Style','listbox','String',tstr,'Tag','stables','Max',2,...
  'Value',[],'Callback',{@subqtables,F},'Tooltip','Data source tables',...
  'Position',[3*bspc+2*bwid 6*bspc+fhgt1+fhgt2 bspc+2*bwid bspc+3*bhgt]);
ui.sfields = uicontrol('Style','listbox','Tag','sfields','Max',2,'Value',[],...
  'Callback',{@subqfields,F},'Tooltip','Fields in selected table(s)',...
  'Position',[5*bspc+4*bwid 6*bspc+fhgt1+fhgt2 2*bspc+2*bwid bspc+3*bhgt]);
uicontrol('Style','text','String','Fields','Position',[5*bspc+4*bwid top-bhgt bwid bhgt]);    

%Retrieve subquery data if editing existing subquery
tmp = findobj('Tag','WHERE');   %Determine if WHERE or HAVING clause
if isempty(tmp)
  dlgtag = 'HAVING';
else
  dlgtag = 'WHERE';
end

sqdat = getuprop(findobj('Tag',dlgtag),'SUBQUERYDATA');
sqstr = getuprop(findobj('Tag',dlgtag),'SUBQUERYSTRING');
tval = getuprop(findobj('Tag',dlgtag),'TABLEVALUES');
fval = getuprop(findobj('Tag',dlgtag),'FIELDVALUES');

setappdata(F,'uidata',ui)

if isempty(sqdat)
  querybuilder('cleanupdialog',F)
  return
end

%Update tables, fields and subquery string
set(ui.swhereclauses,'Userdata',sqdat,'String',sqstr)
set(ui.stables,'Value',tval)
subqtables([],[],F)
set(ui.sfields,'Value',fval)
subqfields([],[],F)
  
querybuilder('cleanupdialog',F)


function tablesvqb(obj,evd,frame)
%TABLESVQB Tables selection.

ui = getappdata(frame,'uidata');
set(frame,'Pointer','watch')

%Reset fields listbox, query, workspace variable and data string so incorrect fieldnames are not showing for chosen source
set([ui.fields;ui.query;ui.wkvariable],'String',[])

%Make connection to datasource
dsval = get(ui.sources,'Value');
dsstr = get(ui.sources,'String');
datasource = dsstr{dsval};
conn = loginconnect(datasource); 

%Get selected tables 
tval = get(ui.tables,'Value');
tstr = get(ui.tables,'String');
tablez = tstr(tval);
  
%Get metadata of connection and get column names
d = dmd(conn);
L = length(tablez);
fields = {};
for i = 1:L
  
  table = tablez{i};  %Columns method returns more info, but is much slower
  ex = exec(conn,['select * from ' table]);
  ex = fetch(ex,1);
  atrib = attr(ex);
  tabfields = cellstr(str2mat(atrib.fieldName));
  close(ex); 
  
  %Check for spaces in field name
  for i = 1:length(tabfields)
    tmpfld = tabfields{i};
    j = find(tmpfld == ' ' | tmpfld == '$');
    if ~isempty(j)
      tabfields{i} = ['"' tabfields{i} '"'];
    end
  end
  
  %Prepend tablename if JOIN operation
  if length(tval) > 1
    for j = 1:length(tabfields)
      tabfields{j} = [table '.' tabfields{j}];
    end
    fields = [fields;tabfields];
  else
    fields = tabfields;
  end
end
 
%Display fieldnames
set(ui.fields,'String',fields,'Value',[]);

%Close connection
close(conn);
set(frame,'Pointer','arrow')


function ungroupclauses(obj,evd,frame)
%UNGROUPCLAUSES Clause precedence ungrouping.

ui = getappdata(frame,'uidata');

%Find the object containing the clauses
dlgstr = get(gcf,'Tag');
switch dlgstr
  case 'WHERE'
    ui.whereclausedata = findobj(gcf,'Tag','whereclauses');    %whereclauses
  case 'SUBQDLG'
    ui.whereclausedata = findobj(gcf,'Tag','swhereclauses');    %subquery whereclauses
end

%Get the string and chosen clauses
wstr = get(ui.whereclausedata,'String');
wval = get(ui.whereclausedata,'Value');
nvals = length(wval);

%Remove parenthesis
if ~isempty(wval)
  if strcmp(wstr{wval(1)}(1),'(')
    wstr{wval(1)}(1) = [];
  else
    errordlg('First chosen clause not within parenthesis.')
    set(findobj('Type','figure'),'Pointer','arrow')
    return
  end
  
  %Get length of last clause and location of )'s
  wlen = length(wstr{wval(nvals)});
  i = findstr(')',wstr{wval(nvals)});
  
  %Find ), ) AND, or ) OR
  switch wstr{wval(nvals)}(max(i):wlen)
    case  {')',') ',')  ','))'}
      wstr{wval(nvals)}(max(i)) = [];
    case {') OR',') AND',') OR ',') AND '}
      wstr{wval(nvals)}(max(i)) = [];
    otherwise
      errordlg('Last chosen clause not within parenthesis.')
      set(findobj('Type','figure'),'Pointer','arrow')
      return
  end
  set(ui.whereclausedata,'String',wstr)
end  

%Update subquery sql statement if in subquery dialog
switch dlgstr
  case 'SUBQDLG'
    subqfields([],[],frame)
end


function varlist(obj,evd,frame)
%VARLIST Build string to display current workspace data 

ui = getappdata(frame,'uidata');
XxX = evalin('base','whos');
ansstr = {};
ans = ' ';  
for ansi = 1:length(XxX)
  tmpans = [num2str(XxX(ansi).size(1)) 'x' num2str(XxX(ansi).size(2))];
  ansstr = [ansstr;...
     {sprintf([XxX(ansi).name ans(ones(1,22-length(XxX(ansi).name))) tmpans ans(ones(1,17-length(tmpans))) num2str(XxX(ansi).bytes)])}];
end
set(ui.querydata,'String',ansstr,'Value',[])


function where(obj,evd,frame)
%WHERE Where clause button.

ui = getappdata(frame,'uidata');
[dfp,mfp,bspc,bhgt,bwid,bwid2] = spaceparams(obj,evd,frame);

%Cannot display WHERE dialog without any fieldnames

fstr = get(ui.fields,'String');
if isempty(fstr)
  errordlg('No valid fieldnames displayed.');
  set(findobj('Type','figure'),'Pointer','arrow')
  return
end

%Do not display WHERE dialog if HAVING dialog is open
ui.havingclausedata = findobj('Tag','HAVING');
if ~isempty(ui.havingclausedata)
  errordlg('Close HAVING clauses... dialog before building WHERE clause.')
  set(findobj('Type','figure'),'Pointer','arrow')
  return
end

%Build WHERE clause dialog
clausedialog('WHERE',bspc,bwid,bhgt);
    
%Table fieldnames
displayfieldsbox('wherefields',bspc,bwid,bhgt);

%Build conditions and operator uicontrols
condandoper('WHERE',bspc,bwid,bhgt);
cleanupdialog([],[],gcf)
