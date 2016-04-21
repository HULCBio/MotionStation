function confds(x)
%CONFDS Configure data source (UNIX only).
%   CONFDS configures data sources for non-PC versions of the Database Toolbox.

%   Author(s): C.F.Garvin, 12-30-98
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $   $Date: 2002/12/19 04:05:42 $


if isunix   %Applicable to non-PC platforms only
  
  set(findobj('Type','figure'),'Pointer','watch')

  if nargin == 0  %Set x = 'dialog' for command line call to confds
    x = 'dialog';
  else            %Get handles and necessary data for switch commands
    
    sdata = getuprop(gcf,'dsdata');          %Datasource userdata
    sobj = findobj(gcf,'Tag','source');   %Datasource names
    sstr = get(sobj,'String');
    nobj = findobj(gcf,'Tag','Name');     %Source name
    nstr = get(nobj,'String');
    dobj = findobj(gcf,'Tag','Driver');   %Source driver
    dstr = get(dobj,'String');
    uobj = findobj(gcf,'Tag','URL');      %Source URL
    ustr = get(uobj,'String');
    
  end
  
  switch x
    
    case 'add'
      
      if (isempty(ustr) | isempty(dstr) | isempty(nstr))   %Check for missing entry
        errordlg('Missing datasource Name, Driver or URL.')
        set(findobj('Type','figure'),'Pointer','arrow')
        return  
      end
      
      if any(strcmp(nstr,sdata(:,1)))    %Prevent duplicate datasource names
        errordlg('Duplicate datasource Name.  Rename or remove existing datasource.')
        set(findobj('Type','figure'),'Pointer','arrow')
        return
      end
      
      [m,n] = size(sdata);     %Update datasource data and unsaved flag
      if isempty([sdata{:}])
        sdata = {nstr dstr ustr};
        sstr = {nstr};
      else
        sdata(m+1,:) = {nstr dstr ustr};
        sstr = [sstr;{nstr}];
      end  
      setuprop(gcf,'dsdata',sdata)
      set(sobj,'String',sstr,'Value',m+1)
      
      confds('save')
      
    case 'cancel'
      
      close(gcf)
      
    case 'help'
      
      qbhelp('Configure DataSource')
      
    case {'name','driver','url'}
      
      setuprop(gcf,'unsaved',1)
      
    case 'ok'
      
      if getuprop(gcf,'unsaved')   %Any unsaved information in dialog?
        b = questdlg('Save unsaved datasource information?','Unsaved data','Yes','No','Cancel','No');
        switch b
          case 'Yes'
            confds('add')
            if (isempty(ustr) | isempty(dstr) | isempty(nstr)) %Don't close dialog if missing info 
              return
            end
          case 'No'
          case 'Cancel'
            set(findobj('Type','figure'),'Pointer','arrow')
            return
        end
      end 
      
      close(gcf)
        
    case 'remove'
      
      sval = get(sobj,'Value');
      if isempty(sdata) | isempty(sval)
        set(findobj('Type','figure'),'Pointer','arrow')
        return  
      end
      sdata(sval,:) = [];
      sstr(sval) = [];
      setuprop(gcf,'dsdata',sdata)
      set(sobj,'String',sstr,'Value',[])
      set([nobj dobj uobj],'String',[])
      
      confds('save')
      
    case 'save'
      
      %Save data to file
      srcs = sdata;
      try
        save datasource srcs
      catch
        errordlg('Problem saving file DATASOURCE.MAT.  You may not have write privileges.')
        set(findobj('Type','figure'),'Pointer','arrow')
        return
      end
      
      setuprop(gcf,'unsaved',0)
      
    case 'source'
      
      sval = get(sobj,'Value');
      sval = min(sval);
      set(sobj,'Value',sval) 
      if isempty(sval)
        set(findobj('Type','figure'),'Pointer','arrow')
        return
      end
      set(nobj,'String',sdata{sval,1})
      set(dobj,'String',sdata{sval,2})
      set(uobj,'String',sdata{sval,3})
      
    case 'test'
      
      sval = get(sobj,'Value');
      if isempty(sval)
        errordlg('No datasource chosen for connection test.')
        set(findobj('Type','figure'),'Pointer','arrow')
        return
      end
      sourcestr = sstr{sval};
      c = loginconnect(sourcestr);
      
      if ~isa(c.Handle,'double')
        msgbox('Connection test successful.')
        close(c)
      end
      
    case 'dialog'
      
      %Load datasource information
      if exist('datasource.mat')
        load datasource
        if ~exist('srcs')
          errordlg('Datasource file DATASOURCE.MAT corruption.')
          set(findobj('Type','figure'),'Pointer','arrow')
          return
        end
      else
         srcs = cell(1,3);
         srcs(1,:) = [];   %This line to get 0 x 3 cell array
      end

      %Spacing parameters
      dfp = get(0,'DefaultFigurePosition');
      mfp = [560 420];    %Reference width and height
      bspc = mean([5/mfp(2)*dfp(4) 5/mfp(1)*dfp(3)]);
      bhgt = 20/mfp(2) * dfp(4);
      bwid = 80/mfp(1) * dfp(3);

      
      %Frame parameters
      fwid1 = 3*bspc+3*bwid;
      fhgt1 = 11*bspc+9*bhgt;
      fwid2 = 2*bspc+bwid;
      fhgt2 = 4*bspc+3*bhgt;
      fwid3 = 4*bspc+bwid;
      fhgt3 = 6*bspc+6*bhgt;
      
      %Open dialog if not open
      fobj = findobj('Tag','ConfDS');
      if ~isempty(fobj)
        figure(fobj)
        set(findobj('Type','figure'),'Pointer','arrow')
        return
      end
      
      f = figure('Numbertitle','off','Name','Configure Data Source','Integerhandle','off',...
          'Menubar','none','Tag','ConfDS','Resize','off');
    
      %Build frames 
      uicontrol('Enable','off','Position',[bspc bspc fwid1 fhgt1]);
      uicontrol('Enable','off','Position',[2*bspc+fwid1 bspc fwid2 fhgt2]);
      uicontrol('Enable','off','Position',[fwid1 2*bspc+fhgt2 fwid3 fhgt3]);
      uicontrol('Style','text','String',' ',...
        'Position',[fwid1-bspc 2*bspc+2+fhgt2 bwid 5*bspc+6*bhgt]);
                  
      %Set datasource data and save data flag
      setuprop(gcf,'dsdata',srcs)
      setuprop(gcf,'unsaved',0)
      
      %Build datasource uicontrols
      uicontrol('Style','listbox','String',srcs(:,1),'Callback','confds(''source'')','Tag','source',...
        'Tooltip','List of available datasources',...
        'Max',2,'Value',[],'Position',[2*bspc 2*bspc 1.5*bwid 8*bspc+8*bhgt]);
      uicontrol('Style','text','String','Data source:','Position',[2*bspc 10*bspc+8*bhgt bwid bhgt]);
      uicontrol('Style','text','String','Name:',...
        'Position',[4*bspc+1.5*bwid 10*bspc+8*bhgt bwid bhgt]);
      uicontrol('Style','edit','Tag','Name','Tooltip','Datasource name','Callback','confds(''name'')',...
        'Position',[4*bspc+1.5*bwid 10*bspc+7*bhgt bspc+2.5*bwid bhgt]);
      uicontrol('Style','text','String','Driver:',...
        'Position',[4*bspc+1.5*bwid 9*bspc+6*bhgt bwid bhgt]);
      uicontrol('Style','edit','Tag','Driver','Tooltip','Datasource driver','Callback','confds(''name'')',...
        'Position',[4*bspc+1.5*bwid 9*bspc+5*bhgt bspc+2.5*bwid bhgt]);
      uicontrol('Style','text','String','URL:',...
        'Position',[4*bspc+1.5*bwid 8*bspc+4*bhgt bwid bhgt]);
      uicontrol('Style','edit','Tag','URL','Tooltip','Datasource URL','Callback','confds(''name'')',...
        'Position',[4*bspc+1.5*bwid 8*bspc+3*bhgt bspc+2.5*bwid bhgt]);
      
      %Build datasource Add, Remove, Test pushbuttons
      uicontrol('String','Test','Callback','confds(''test'')','Tooltip','Test datasource connection',...
        'Position',[3*bspc+1.75*bwid 3*bspc bwid bhgt]);
      uicontrol('String','Remove','Callback','confds(''remove'')','Tooltip','Remove selected datasource',...
        'Position',[3*bspc+1.75*bwid 4*bspc+bhgt bwid bhgt]);
      uicontrol('String','Add','Callback','confds(''add'')','Tooltip','Add datasource',...
        'Position',[3*bspc+1.75*bwid 5*bspc+2*bhgt bwid bhgt]);
      
      %Build OK, Cancel, Help pushbuttons
      uicontrol('String','Help','Callback','confds(''help'')',...
        'Tooltip','Datasource configuration help',...
        'Position',[6*bspc+3*bwid 2*bspc bwid bhgt]);
      uicontrol('String','Cancel','Callback','confds(''cancel'')','Tooltip','Close dialog',...
        'Position',[6*bspc+3*bwid 3*bspc+bhgt bwid bhgt]);
      uicontrol('String','OK','Callback','confds(''ok'')','Tooltip','Close dialog',...
        'Position',[6*bspc+3*bwid 4*bspc+2*bhgt bwid bhgt]);
    
      %Reset figure position to match frames
      pos = get(f,'Position');
      set(f,'Position',[pos(1) pos(2) 3*bspc+fwid1+fwid2 2*bspc+fhgt1])
      
      %Cleanup dialog
      querybuilder('cleanupdialog',f)
      
  end
  
  set(findobj('Type','figure'),'Pointer','arrow')

end

