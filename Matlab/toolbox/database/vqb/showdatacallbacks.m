function showdatacallbacks(o,x,obj)
%SHOWDATACALLBACKS Visual Query Builder data display callbacks.
%   SHOWDATACALLBACKS(O,X) runs the Visual Query Builder data display callbacks
%   for the given operation, O, and cell array, X.

%   Author(s): C.F.Garvin, 09-08-1998
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.31.4.4 $   $Date: 2004/04/06 01:05:57 $

set(findobj('Type','figure'),'Pointer','watch')

%Data needs to be in cell array
if exist('x')
  dtcls = class(x);
  switch dtcls
    case 'struct'  
      flds = fieldnames(x);
      numflds = length(flds);
      [rws,cls] = size(x.(flds{1}));
      tmpx = cell(rws,numflds);
      for i = 1:numflds
        switch class(x.(flds{i}))
          case 'double'
            tmpx(:,i) = num2cell(x.(flds{i}));
          case 'cell'
            tmpx(:,i) = x.(flds{i});
        end
      end
      x = tmpx;
      
    case 'double'
      x = num2cell(x);
  end
end

lasterr('')  %Clear old error conditions

if ~strcmp(o,'repgen')
  
  %Get selected field strings
  fobj = findobj('Tag','fields');
  fstr = get(fobj,'String');
  fval = get(fobj,'Value');
  fields = fstr(fval);

  %Plot functions
  twodstr = {'plot';'loglog';'semilogx';'semilogy';'polar';'bar';'barh';'fill';...
    'pie';'comet';'errorbar';'ribbon';'contour';'feather';'stem';'stairs';'quiver';'scatter'};
  threedstr = {'plot3';'mesh';'meshc';'meshz';'surf';'surfc';'surfl';'surfnorm';'bar3';...
    'bar3h';'fill3';'pie3';'contourf';'contour3';'comet3';...
    'scatter3';'stem3';'waterfall';'quiver3';'cylinder'};
  plotfuns = sort([twodstr;threedstr]);
  
end

switch o
  
  case 'chart'
    
    %GUI spacing parameters
    dfp = get(0,'Defaultfigureposition');
    mfp = [560 420];
    fspc = mean([5/mfp(2)*dfp(4) 5/mfp(1)*dfp(3)]);
    bspc = mean([5/mfp(2)*dfp(4) 5/mfp(1)*dfp(3)]);
    bhgt = 20/mfp(2) * dfp(4);
    bhgt2 = 64/mfp(2) * dfp(4);
    bwid = 80/mfp(1) * dfp(3);
    bwid2 = 225/mfp(1) * dfp(3);
    bwid3 = 177/mfp(1) * dfp(3);
    
    %Focus dialog if already open and return
    dlgobj = findobj('Tag','CHTDLG');
    if ~isempty(dlgobj)
      figure(dlgobj);
      set(findobj('Type','figure'),'Pointer','arrow')
      return
    end
    
    %Build main window
    f = figure('Name','Visual Query Builder Charting','Numbertitle','off',...
      'Integerhandle','off',...
      'HandleVisibility','callback','Menubar','none','Tag','CHTDLG','Userdata','plot');
    pos = get(f,'Position');
    rgt = pos(3);
    top = pos(4);
     
    %Labeling choice strings
    labels = [fields;{'Use Field Names'}];
    
    %Background frames
    uicontrol('Enable','off',...
      'Position',[fspc fspc+3*bspc+2*bhgt+bhgt2 rgt-2*fspc 4*bspc+4*bhgt+3*bhgt2])
    uicontrol('Enable','off',...
      'Position',[fspc fspc 2*bspc+bwid3 2*bspc+2*bhgt+bhgt2]);
    uicontrol('Enable','off',...
      'Position',[rgt-(fspc+2*bspc+bwid) fspc 2*bspc+bwid 4*bspc+3*bhgt]);
    
    %Plotting function uicontrols
    
    %enmat is a uicontrol enable matrix based on possible inputs to 
    %the selected plotting function
    enmat = {'on','on','on','off','on','on','off';...    %bar
        'on','on','on','off','on','on','on';...          %bar3
        'on','on','on','off','on','on','on';...          %bar3h
        'on','on','on','off','on','on','off';...         %barh
        'on','on','on','off','on','on','off';...         %comet
        'on','on','on','off','on','on','on';...          %comet3
        'on','on','on','on','on','on','off';...          %contour
        'on','on','on','on','on','on','on';...           %contour3
        'on','on','on','on','on','on','off';...          %contourf
        'on','off','off','off','on','on','on';...         %cylinder
        'on','on','on','on','on','on','off';...          %errorbar
        'on','on','off','off','on','on','off';...        %feather
        'on','on','on','off','on','on','off';...         %fill
        'on','on','on','on','on','on','on';...           %fill3
        'on','on','off','off','on','on','off';...        %loglog
        'on','on','on','on','on','on','on';...           %mesh
        'on','on','on','on','on','on','on';...           %meshc
        'on','on','on','on','on','on','on';...           %meshz
        'on','on','off','off','on','off','off';...       %pie
        'on','on','off','off','on','off','off';...       %pie3
        'on','on','off','off','on','on','off';...        %plot
        'on','on','on','off','on','on','on';...          %plot3
        'on','on','off','off','off','off','off';...      %polar
        'on','on','on','on','on','on','off';...          %quiver
        'on','on','on','on','on','on','on';...           %quiver3
        'on','on','off','off','on','on','on';...        %ribbon
        'on','on','off','off','on','on','off';...        %scatter
        'on','on','on','off','on','on','on';...          %scatter3
        'on','on','off','off','on','on','off';...        %semilogx
        'on','on','off','off','on','on','off';...        %semilogy
        'on','on','off','off','on','on','off';...        %stairs
        'on','on','off','off','on','on','off';...        %stem
        'on','on','on','off','on','on','on';...          %stem3
        'on','on','on','on','on','on','on';...           %surf
        'on','on','on','on','on','on','on';...        %surfc
        'on','on','on','on','on','on','on';...           %surfl
        'on','on','on','off','on','on','on';...          %surfnorm
        'on','on','on','on','on','on','on';...           %waterfall
      };
    
    uicontrol('Style','text','String','Charts','Horizontalalignment','center',...
      'Position',[fspc+bspc top-(fspc+bspc+bhgt) bwid bhgt]);
    uicontrol('Style','listbox','String',plotfuns,'Tag','plotfun',...
      'Userdata',enmat,'Max',1,'Value',1,...
      'Position',[fspc+bspc top-(fspc+bspc+2*(bhgt+bhgt2)) bwid bspc+2*bhgt2+bhgt]);
       
    %X,Y,Z,Color data uicontrols
    uicontrol('Style','text','String','X data','Horizontalalignment','center',...
      'Position',[fspc+2*bspc+bwid top-(fspc+bspc+bhgt) bwid2 bhgt]);
    uicontrol('Style','listbox','String',fields,'Tag','xdata',...
      'Position',[fspc+2*bspc+bwid top-(fspc+bhgt+bhgt2) bwid2 bhgt2]);
    uicontrol('Style','text','String','Y data','Horizontalalignment','center',...
      'Position',[fspc+3*bspc+bwid+bwid2 top-(fspc+bspc+bhgt) bwid2 bhgt]);
    uicontrol('Style','listbox','String',fields,'Tag','ydata',...
      'Position',[fspc+3*bspc+bwid+bwid2 top-(fspc+bhgt+bhgt2) bwid2 bhgt2]);
    uicontrol('Style','text','String','Z data','Horizontalalignment','center',...
      'Enable','on','Userdata','3D',...
      'Position',[fspc+2*bspc+bwid top-(fspc+2*(bspc+bhgt)+bhgt2) bwid2 bhgt]);
    uicontrol('Style','listbox','String',fields,'Tag','zdata',...
      'Enable','off','Userdata','3D',...
      'Position',[fspc+2*bspc+bwid top-(fspc+bspc+2*(bhgt+bhgt2)) bwid2 bhgt2]);
    uicontrol('Style','text','String','Color data','Horizontalalignment','center',...
      'Enable','on','Userdata','3D',... 
      'Position',[fspc+3*bspc+bwid+bwid2 top-(fspc+2*(bspc+bhgt)+bhgt2) bwid2 bhgt]);
    uicontrol('Style','listbox','String',fields,'Tag','cdata',...
      'Enable','off','Userdata','3D',...
      'Position',[fspc+3*bspc+bwid+bwid2 top-(fspc+bspc+2*(bhgt+bhgt2)) bwid2 bhgt2]);
    
    %Build Aggregate column data checkbox
    uicontrol('Style','checkbox','String','Aggregate column data',...
      'Tag','Aggregate','Value',0,...
      'Position',[fspc+bspc top-(fspc+3*bspc+3*bhgt+2*bhgt2) bwid3 bhgt]);
        
    %Build axis label controls uicontrols
    uicontrol('Style','text','String','X labels',...
      'Position',[fspc+bspc top-(fspc+4*bspc+4*bhgt+2*bhgt2) bwid3 bhgt]);
    uicontrol('Style','listbox','String',labels,'Tag','xlabels',...
      'Position',[fspc+bspc top-(fspc+3*bspc+4*bhgt+3*bhgt2) bwid3 bhgt2]);
    uicontrol('Style','text','String','Y labels',...
      'Position',[fspc+2*bspc+bwid3 top-(fspc+4*bspc+4*bhgt+2*bhgt2) bwid3 bhgt]);
    uicontrol('Style','listbox','String',labels,'Tag','ylabels',...
      'Position',[fspc+2*bspc+bwid3 top-(fspc+3*bspc+4*bhgt+3*bhgt2) bwid3 bhgt2]);
    uicontrol('Style','text','String','Z labels',...
      'Enable','on','Userdata','3D',...
      'Position',[fspc+3*bspc+2*bwid3 top-(fspc+4*bspc+4*bhgt+2*bhgt2) bwid3 bhgt]);
    uicontrol('Style','listbox','String',labels,'Tag','zlabels',...
      'Enable','off','Userdata','3D',...
      'Position',[fspc+3*bspc+2*bwid3 top-(fspc+3*bspc+4*bhgt+3*bhgt2) bwid3 bhgt2]);

    %Build legend control uicontrols
    uicontrol('Style','checkbox','String','Show legend',...
      'Tag','Legend','Value',0,...
      'Position',[fspc+bspc top-(fspc+6*bspc+5*bhgt+3*bhgt2) bwid3 bhgt]);
    uicontrol('Style','text','String','Legend labels',...
      'Enable','on','Userdata','legendobject',... 
      'Position',[fspc+bspc top-(fspc+7*bspc+6*bhgt+3*bhgt2) bwid3 bhgt]);
    leglabels = [fields;{'Use X Data Field Names'};{'Use Y Data Field Names'};...
        {'Use Z Data Field Names'}];
    uicontrol('Style','listbox','String',leglabels,'Tag','legendlabels',...
      'Enable','off','Userdata','legendobject',...
      'Position',[fspc+bspc top-(fspc+6*bspc+6*bhgt+4*bhgt2) bwid3 bhgt2]);
    
    %Build dialog pushbuttons
    uicontrol('String','Close','Callback','close',...
      'Position',[rgt-(fspc+bspc+bwid) fspc+bspc bwid bhgt]);
    uicontrol('String','Help','Callback','showdatacallbacks(''helpcharts'')',...
      'Position',[rgt-(fspc+bspc+bwid) fspc+2*bspc+bhgt bwid bhgt]);
    uicontrol('String','Display',...
      'Callback','eval([''showdatacallbacks(''''display'''','' get(findobj(''Tag'',''wkvariable''),''String'') '')''])',...
      'Position',[rgt-(fspc+bspc+bwid) fspc+3*bspc+2*bhgt bwid bhgt]);
    
    %Build preview axis
    axes('Position',[.40 .05 .37 .2],'Box','on','Tag','previewdata',...
      'Fontsize',7);
    
    %Set callbacks for uicontrol   
    pobj = findobj(f,'Tag','plotfun');
    lobj = findobj(f,'Style','listbox');
    cobj = findobj(f,'Style','checkbox');
    set([lobj;cobj],'Callback','eval([''showdatacallbacks(''''preview'''','' get(findobj(''Tag'',''wkvariable''),''String'') '')''])')    
                    
    %GUI cleanup
    set(lobj,'Max',2,'Value',[],'Backgroundcolor','white')
    set(pobj,'Max',1)
    
    uobj = findobj(f,'Type','uicontrol');
    set(uobj,'Units','normal')
    dbc = get(0,'Defaultuicontrolbackgroundcolor');
    set(gcf,'Color',dbc)
    
    %Display default plot to guide user
    set(findobj('Tag','xdata'),'Value',1)
    set(findobj('Tag','plotfun','Userdata',1),'Value',1)
    i = find(strcmp('plot',plotfuns));
    set(pobj,'Value',i)
    evalin('base',['showdatacallbacks(''preview'',' get(findobj('Tag','wkvariable'),'String') ')'])  
         
  case 'data'
    
    try
           
      %Parse table names out of fields if JOIN operation
      fields = removetablenames(fields);
            
      %Build data window, need to make variable global to access it
      showdata(x,fields);
           
    catch
      
      errordlg('Problem accessing MATLAB workspace variable shown in Visual Query Builder.')
      set(findobj('Type','figure'),'Pointer','arrow')
      return
      
    end
    
  case {'display','preview'}
    
    %Focus on charting dialog window in case demo is running
    figure(findobj('Tag','CHTDLG'));
    
    try
      
      %Delete previous error if showing
      delete(findobj('Tag','errorindicator'))
      
      %Get plotting function
      ca = get(gcbo,'Tag');
      if strcmp(ca,'plotfun')
        popstr = get(gcbo,'String');
        popval = get(gcbo,'Value');
        plotfun = popstr{popval};
        set(gcf,'Userdata',plotfun)
      else
        plotfun = get(gcf,'Userdata');
      end
           
      %Update uicontrol settings
      lstobj = sort(findobj(gcf,'Style','listbox'));
      enmat = get(lstobj(1),'Userdata');    %Get enable flags 
      pval = get(lstobj(1),'Value');        %Get value in matrix
      set(lstobj(2:8),{'Enable'},enmat(pval,:)')  %Set enable properties
      set(findobj(gcf,'Enable','off'),'Value',[]) %No values for dis ui's
      if strcmp(ca,'Legend')
        legobj = findobj(gcf,'Userdata','legendobject');
        if get(gcbo,'Value')
          set(legobj,'Enable','on')
        else
          set(legobj,'Enable','off')
        end
      end
      
      %Get aggregate flag
      aobj = findobj('Tag','Aggregate');
      agg = get(aobj,'Value');
      
      %Get x data selection
      xdobj = findobj(gcf,'Tag','xdata');
      xdval = get(xdobj,'Value');
      xdata = cell2mat(x(:,xdval),agg);
    
      %Get y data selection
      ydobj = findobj(gcf,'Tag','ydata');
      ydval = get(ydobj,'Value');
      ydata = cell2mat(x(:,ydval),agg);
    
      %Get z data selection
      zdobj = findobj(gcf,'Tag','zdata');
      zdval = get(zdobj,'Value');
      zdata = cell2mat(x(:,zdval),agg);
    
      %Get color data selection
      cdobj = findobj(gcf,'Tag','cdata');
      cdval = get(cdobj,'Value');
      cdata = cell2mat(x(:,cdval),agg);
      
      %Get labels if specified
      xlobj = findobj(gcf,'Tag','xlabels');
      xlval = min(get(xlobj,'Value'));     %Trap multi selected values
      set(xlobj,'Value',xlval);
      try
        xldat = x(:,xlval);
      catch
        lasterr('')    %Don't trap this error later on
        xldat = removetablenames(fields(xdval));
      end
      
      %Get labels if specified
      ylobj = findobj(gcf,'Tag','ylabels');
      ylval = min(get(ylobj,'Value'));
      set(ylobj,'Value',ylval);
      try
        yldat = x(:,ylval);
      catch
        lasterr('')
        yldat = removetablenames(fields(ydval));
      end

      %Get labels if specified
      zlobj = findobj(gcf,'Tag','zlabels');
      zlval = min(get(zlobj,'Value'));
      set(zlobj,'Value',zlval);
      try
        zldat = x(:,zlval);
      catch
        lasterr('')
        zldat = removetablenames(fields(zdval));
      end
      
      %For display flag, open new figure window
      if strcmp(o,'display')
        figure;
      end
      
      %Determine how plot command should be called, 16 possible combos
      %Use binary numbers to represent combinations
      y = [~isempty(cdata) ~isempty(zdata) ~isempty(ydata) ~isempty(xdata)];
      b = num2str(y);
      i = find(b == ' ');
      b(i) = [];
      n = bin2dec(num2str(b));
      
      %Switchyard of 16 possible calling sequences
      switch n
        case 0
          error('database:vqb:dataDisplayError','Not enough input arguments.')
        case 1
          xchrt(plotfun,xdata);
        case 2
          xchrt(plotfun,ydata);
        case 3
          xychrt(plotfun,xdata,ydata);
        case 4
          xchrt(plotfun,zdata);
        case 5
          xychrt(plotfun,xdata,zdata);
        case 6
          xychrt(plotfun,ydata,zdata);
        case 7
          xyzchrt(plotfun,xdata,ydata,zdata);
        case 8
          xchrt(plotfun,cdata);
        case 9
          xychrt(plotfun,xdata,cdata);
        case 10
          xychrt(plotfun,zdata,cdata);
        case 11
          xyzchrt(plotfun,xdata,ydata,cdata);
        case 12
          xychrt(plotfun,zdata,cdata);
        case 13
          xyzchrt(plotfun,xdata,zdata,cdata);
        case 14
          xyzchrt(plotfun,ydata,zdata,cdata);
        case 15
          xyzcchrt(plotfun,xdata,ydata,zdata,cdata);
      end
        
      if ~isempty(lasterr)
        set(findobj('Type','figure'),'Pointer','arrow')
        return    %Already failed, so stop here
      end
      
      %Set labels if specified
      labelaxis(xldat,'x',agg,plotfun)
      labelaxis(yldat,'y',agg,plotfun)
      labelaxis(zldat,'z',agg,plotfun)      
      set(gca,'Box','on')
      
      %Display legend if requested
      wstatus = warning;
      warning off
      lobj = findobj('Tag','Legend');
      lflag = get(lobj,'Value');
      if lflag
        %Get labels if specified
        llobj = findobj('Tag','legendlabels');
        llval = min(get(llobj,'Value'));
        set(llobj,'Value',llval);
        lenll = length(fields);
        try
          lldat = x(:,llval);
          if ~ischar(lldat{1});   %For numbers to be used as labels
            lldat = num2str([lldat{:}]');
          end
        catch
          legflag = llval-lenll;    %Use x,y, or z fields as legend labels
          if legflag == 1
            lldat = removetablenames(fields(xdval));
          elseif legflag == 2
            lldat = removetablenames(fields(ydval));
          elseif legflag == 3
            lldat = removetablenames(fields(zdval));
          end
        end
       
        if ~isempty(lldat)
          if ~iscell(lldat)
            legend(gca,lldat);
          else
            legend(gca,char(lldat));
          end
        else
          set(findobj('Type','figure'),'Pointer','arrow')  
          return  
        end
        
        if strcmp(o,'preview')   %Adjust legend position if preview mode
          lgobj = findobj(gcf,'Tag','legend');
          lp = get(lgobj,'Position');
          set(lgobj,'Position',[.65 .07 lp(3) lp(4)])
        end
      end
      warning(wstatus.state)

    catch
      
      cla;
      set(gca,'Xscale','linear','Yscale','linear','Zscale','linear')
         
    end
    
  case 'helpcharts'
    
    qbhelp('DISPLAY CHART')
    
  case 'report'
    
    wobj = findobj(fobj,'Tag','wkvariable');
    varstr = get(wobj,'String');
    assignin('base','ans',x)
    rptgen.report('databasetlbx.rpt');
    
  case 'repgen'
    
    try
      rptlist
    catch
      errordlg('Unable to start MATLAB Report Generator.')
    end
    
  case 'select'
    
    %Refocus on Data Window (for demo)
    figure(findobj('Tag','VQBDataWindow'));
    
    %Get selected object, or use given object for demo
    if nargin == 3
      t = get(obj);
    else
      t = get(gco);
    end
    
    %Get coordinates of object
    xyz = t.Position;
    
    %Get current data set
    a = get(gcf,'Userdata');
    
    %Get the selected column of data
    x = xyz(1);
    if ischar(a{1,x})
      c = a(:,x);
    else
      c = [a{:,x}];
    end
    
    %Determine how many matches are found for selected field value and get row indices
    s = t.UserData;   %Use userdata in case string shows count
    n = str2double(s);
    if isempty(n) | iscell(c)
      w = find(strcmp({s},c));
    elseif isnan(n)
      w = find(isnan(c));
    else
      w = find(n == c);
    end
    m = length(w);
           
    %Visually display selected values
    tmp = findobj(gcf,'Fontweight','bold','Type','text');
    ud = get(tmp,'Userdata');
    if ~iscell(ud)
      ud = {ud};
    end
    set(tmp,'Fontweight','normal','Color',[.3 .3 .3],{'String'},ud)
    
    %Display string to show how many items have been selected
    [i,j] = size(a);
    text(.3,-.05,[num2str(m) ' of ' num2str(i) ' items selected (' num2str(m/i*100) '%)'],...
      'Units','normal','Fontweight','bold')

    %Draw connecting lines to show data relationships
    dcl = findobj(gcf,'Tag','dataconnectlines');  %Delete old lines
    delete(dcl)
    y = zeros(j,m);
    x = (1:j)';
    x = x(:,ones(1,m));
    
    hold on
    for nl = 1:m
      for nc = 1:j
        obj = findobj(gcf,'String',num2str(a{w(nl),nc}));
        for k = 1:length(obj)  %Can have same values in different columns
          tmp = get(obj(k),'Position');
          if tmp(1) == nc
            y(nc,nl) = tmp(2);
          end
        end
      end
    end
    plot(x,y,'Linestyle',':','Tag','dataconnectlines')
    hold off

    %Find corresponding match values in each column
    for k = 1:j
      tmp = findobj(gcf,'Tag',['col' num2str(k)]);
      str = get(tmp,'String');
      mat = a(w,k);
      if ~ischar(mat{1})
        newmat = unique([mat{:}]);
      else
        newmat = unique(mat(:));
      end
      for n = 1:length(newmat)
        if iscell(newmat)
          p = find(strcmp(newmat(n),str));
          lm = find(strcmp(newmat(n),mat));
        else
          p = find(strcmp(num2str(newmat(n)),str));
          if isnan(newmat(n))
            lm  = find(isnan([mat{:}]));
          else
            lm = find(newmat(n) == [mat{:}]);
          end
        end
        ud = get(tmp(p(1)),'Userdata');
        z = [ud '  (' num2str(length(lm)) ')'];
        set(tmp(p(1)),'Fontweight','bold','Color','black','String',z)
      end
    end
    
end

set(findobj('Type','figure'),'Pointer','arrow')

 
%Subfunctions
 
function y = cell2mat(x,agg)
%CELL2MAT Converts cell array to matrix.
%   Y = CELL2MAT(X,AGG) converts the cell array X to a matrix.  If the
%   aggregation flag is 0, strings are converted to NaN's.   If the aggregation
%   flag is 1, the cell array is replaced with a matrix counters representing
%   the number of times an entry is found in the column.

if isempty(x)
  y = x;
  return  
end
if nargin < 2
  agg = 0;
end

[m,n] = size(x);

if ~agg
  
  %Remove strings from data (not aggregate)
  tmp = zeros(m,n);
  for i = 1:m*n
    if ischar(x{i})
      tmp(i) = i;
    else
      tmp(i) = x{i};
    end
  end
  
else     
  
  %Aggregate column data (will realy only make sense for single column)
  strflag  = ischar(x{1});
 
  %Need unique fields
  if strflag
    u = unique(x);
  else
    u = unique(reshape([x{:}],m,n));
  end
  [m,n] = size(u);
  tmp = zeros(m,n);
  for i = 1:m*n
    if strflag
      tmp(i) = length(find(strcmp(u{i},x(:))));
    else
      tmp(i) = length(find(u(i) == [x{:}]));
    end
  end
     
end

y = tmp;

function y = removetablenames(x)
%REMOVETABLENAMES Remove table names from field names.
%   Y = REMOVETABLENAMES(X) removes the table names from the field names,
%   if necessary, for labeling purposes.   Table names are included in the
%   field names for JOIN operations.   

%In each field, find first '.' and return portion of string after it
y = cell(length(x),1);
for i = 1:length(x)
  tmp = x{i};
  k = find(tmp == '.');
  if ~isempty(k)
    y{i} = tmp(k(1)+1:length(tmp));
  else
    y{i} = tmp;
  end
end

function y = makebold(x)
%MAKEBOLD Add bold formatting to strings for HTML output.
%   Y = MAKEBOLD(X) wraps the elements of the cell string array, X, with
%   <b></b> for HTML output.

y = cell(1,length(x));
for i = 1:length(x)
  y{i} = ['<b>' x{i} '</b>'];
end
  
function labelaxis(d,s,agg,f)
%LABELAXIS Display axis labels.
%   LABELAXIS(D,S,AGG,F) sets the labels of the given axis, S, using the data D.
%   If the aggregate flag, AGG, is set, sort the labels into unique values.
%   F is the plot function name and is used to determine if special
%   labeling is needed.

if ~isempty(lasterr)
  return    %Already failed
end

try
  
  h = get(gca,'Children');
  if ~isempty(d)
    if agg       %Aggregate like strings
      if ischar(d{1})
        d = unique(d);
      else
        d = num2cell(reshape([d{:}],size(d)));
      end
    end
     
    switch f
      
      case {'pie','pie3'}    %Pie charts have special labels
        t = sort(findobj(gcf,'Type','text'));
        set(t,{'String'},d)
        return
        
      otherwise
        
        if ischar(d{1})       %Replace existing labels with strings
          set(gca,[s 'ticklabel'],d)
        elseif ~ischar(d{1})  %Set ticks to chosen numeric data
          l = unique([d{:}]);
          set(gca,[s 'tick'],l,[s 'ticklabel'],l)
        end
        
    end
      
  end

catch
  
  errchrt;
  
end

function xchrt(f,x)
%XCHRT Plot single input variable.
%   XCHRT(F,X) runs the plotting function F with the single input X.

try
  feval(f,x);
catch
  errchrt;
end


function xychrt(f,x,y)
%XYCHRT Plot two input variables.
%   XYCHRT(F,X) runs the plotting function F with the inputs X and Y.

try
  feval(f,x,y);
catch
  errchrt;
end


function xyzchrt(f,x,y,z)
%XYZCHRT Plot three input variables.
%   XYZCHRT(F,X,Y,Z) runs the plotting function F with the inputs X, Y,
%   and Z.
 
try
  feval(f,x,y,z);
catch
  errchrt;
end


function xyzcchrt(f,x,y,z,c)
%XYZCCHRT Plot four input variables.
%   XYZCCHRT(F,X,Y,Z,C) runs the plotting function F with the inputs X, Y,
%   Z, and C.

try
  feval(f,x,y,z,c);
catch
  errchrt;
end

function errchrt()
%ERRCHRT Chart usage table.
%   ERRCHRT displays the error for last charting operation.

cla
u = uicontrol('Style','text','String',lasterr,'Fontweight','bold',...
  'Tag','errorindicator','Position',[200 5 255 100]);
set(u,'Units','normal')
set(gca,'Visible','off')
   
