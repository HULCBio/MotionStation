function varargout = sptimport(varargin)
%SPTIMPORT Import Dialog box for importing data into the SPTool.
%   [componentNum,struc,importSettings,wd] = ...
%                  sptimport(components,labelList,importSettings,wd)
%     puts up a dialog box allowing a user to create a SPTool structure
%     from MATLAB variables, or to select an exported SPTool structure.
%     Inputs:
%        components - data structure created by sptregistry functions,
%          contains information about the components of this SPTool session.
%        labelList - list of strings - current variable labels in the SPTool.
%          sptimport will prompt user if he specifies a label which already
%          exists in this list
%        importSettings - if [], the default settings are chosen
%          otherwise uses importSettings from last call to this function.
%          this is a way to remember the settings the user last typed into
%          this dialog box.
%        wd - working directory - location to begin browsing for files
%     Outputs:
%        componentNum - 0 if user hit cancel, 1..N if success; value indicates
%         which component this structure belongs to
%        struc - new SPTool structure (may have same name as existing object)
%        importSettings - use this to call this dialog box next time.
%        wd - working directory - end location for file browsing

%   Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.14.4.2 $

if nargin == 0
    action = get(gcbo,'Tag');
elseif isstr(varargin{1})
    action = varargin{1};
else
    action = 'init';
end

switch action
  case 'init'  
    if isempty(varargin{3})|~ishandle(varargin{3}.fig)
      % Open figure and create ui objects
      initImport
      ud = get(gcf,'userdata');
      ud.fullFileName = '';
      ud.fileNameString = '';
      ud.FsString = '1';
      set(ud.h.editFs,'string',ud.FsString);
      ud.fig = gcf;
        ud.labelList = varargin{2};
      ud.struc = [];
      
      set([ud.h.filename ud.h.filenameLabel ud.h.browse],'enable','off')
      minwidth([ud.h.SourceLabel ud.h.ContentsLabel ud.h.labelLabel])

      % More initialization code here

      components = varargin{1};
      ud.wd = varargin{4};  % working directory
      numComponents = length(components);
      importAsString = cell(1,numComponents);
      for i=1:numComponents
        [popupString,fields,FsFlag,defaultLabel] = ...
            feval(components(i).importFcn,'fields');
        ud.FsFlag(i) = FsFlag;
        importAsString{i} = popupString;
        ud.fields{i} = fields;
        ud.importFcn{i} = components(i).importFcn;
        ud.defaultLabel{i} = uniqlabel(ud.labelList,defaultLabel);
        ud.formValue(i) = 1;
        for j = 1:length(fields)
          ud.fieldStrings{i}{j} = cell(1,length(fields(j).fields));
          for k = 1:length(fields(j).fields)
              ud.fieldStrings{i}{j}{k} = '';
          end
        end
      end
      set(ud.h.importas,'string',importAsString,'value',1)
      set(gcf,'userdata',ud)
      changeComponent
    
      getContentsOfWorkspace

    else
      ud = varargin{3};
      figure(ud.fig)
      ud.labelList = varargin{2};
      components = varargin{1};
      ud.wd = varargin{4};  % working directory
      numComponents = length(components);
      for i = 1:numComponents
          [popupString,fields,FsFlag,defaultLabel] = ...
                      feval(components(i).importFcn,'fields');
          ud.defaultLabel{i} = uniqlabel(ud.labelList,defaultLabel);
      end
      currentComponent = get(ud.h.importas,'value');
      set(ud.h.editLabel,'string',ud.defaultLabel{currentComponent})
      set(ud.fig,'userdata',ud)
      if strcmp(computer,'PCWIN') | strcmp(computer,'MAC2')
      % on UNIX, already modal
          set(ud.fig,'windowstyle','modal')
      end
      set(ud.fig,'visible','on')
      if get(ud.h.radio1,'value')==1
          getContentsOfWorkspace
      else
          getContentsOfFile
      end
    end

    % Initialization done ... now wait for OK or Cancel buttons:
    set(ud.h.OKButton,'userdata','')
    waitfor(ud.h.OKButton, 'userdata')
    
    ud = get(ud.fig,'userdata');
    
    switch get(ud.h.OKButton,'userdata')
    case 'OK'
       struc = ud.struc;
       componentNum = get(ud.h.importas,'value');
    case 'Cancel'
       componentNum = 0;
       struc = [];
    end
    
    set(ud.fig,'visible','off')
    if strcmp(computer,'PCWIN') | strcmp(computer,'MAC2')
    % prevent modal focus on invisible window when not on UNIX
        set(ud.fig,'windowstyle','normal')
    end
    
    % delete help objects if they are there:
    delete(findobj(ud.fig,'tag','importhelp'))
    
    varargout = {componentNum,struc,ud,ud.wd};
    
  case 'radio1'
    % Callback code for radiobutton with Tag "radio1"
    % Source: from Workspace
    ud = get(gcf,'userdata');
    val = get(ud.h.radio1,'value');
    if val==0   % User has clicked on this radio even though it was
                % already on - so leave it on and exit
        set(ud.h.radio1,'value',1)
    else
        set(ud.h.radio2,'value',0)
        set([ud.h.filename ud.h.filenameLabel ud.h.browse],'enable','off')
        set(ud.h.ContentsLabel,'string','Workspace Contents')
        minwidth(ud.h.ContentsLabel)
        getContentsOfWorkspace
    end
    
  case 'radio2'
    % Callback code for radiobutton with Tag "radio2"
    % Source: from Disk
    ud = get(gcf,'userdata');
    val = get(ud.h.radio2,'value');
    if val==0   % User has clicked on this radio even though it was
                % already on - so leave it on and exit
        set(ud.h.radio2,'value',1)
    else
        set(ud.h.radio1,'value',0)
        set([ud.h.filename ud.h.filenameLabel ud.h.browse],'enable','on')
        set(ud.h.ContentsLabel,'string','File Contents')
        minwidth(ud.h.ContentsLabel)
        getContentsOfFile
    end

  case 'filename'
    % Callback code for edit with Tag "filename"
    ud = get(gcf,'userdata');
    filename = get(ud.h.filename,'string');
    if isempty(find(filename=='.')) 
        if (length(filename)<4) | ~strcmp(lower(filename(end-3:end)),'.mat')  
            filename = [filename '.mat'];
            set(ud.h.filename,'string',filename)
        end
    end
    fullFileName = which(filename);
    if ~isempty(fullFileName)
        ud.fullFileName = fullFileName;
        ud.fileNameString = get(ud.h.filename,'string');
        set(gcf,'userdata',ud)
        getContentsOfFile
    else
        if (length(filename)<4) | ~strcmp(lower(filename(end-3:end)),'.mat'),
            errstr = 'The MAT-file''s name must end in ".mat".';
        else
            errstr = ['Sorry, I can''t find the file "' filename '".'];
        end
        waitfor(msgbox(errstr,'File Error','error','modal'))
        set(ud.h.filename,'string',ud.fileNameString)
    end
    
  case 'browse'
    % Callback code for pushbutton with Tag "browse"
    ud = get(gcf,'userdata');
    matlab_wd = pwd;
    cd(ud.wd)
    [f,p]=uigetfile('*.mat');
    cd(matlab_wd)
    if ~isequal(f,0)
        ud.fullFileName = fullfile(p,f);
        ud.fileNameString = f;
        ud.wd = p;
        set(ud.h.filename,'string',ud.fileNameString)
        set(gcf,'userdata',ud)
        getContentsOfFile
    end
  
  case 'listbox'
    % Callback code for listbox with Tag "listbox"
    ud = get(gcf,'userdata');
    val = get(ud.h.listbox,'value');
    str = get(ud.h.listbox,'string');
    types = get(ud.h.listbox,'userdata');
    currentComponent = get(ud.h.importas,'value');
    currentForm = get(ud.h.formPopup,'value');
    hands = [ud.h.arrow1 ud.h.edit1 
             ud.h.arrow2 ud.h.edit2 
             ud.h.arrow3 ud.h.edit3 
             ud.h.arrow4 ud.h.edit4 
             ud.h.arrow5 ud.h.editFs];

    switch types(val)
    case -1   % selection not a SPT data type and not "transferrable" to the
              % edit boxes by using the arrows
        set(hands(:,1),'enable','off')
        set(hands(:,2),'enable','on')
        % set edit strings
        strings = ud.fieldStrings{currentComponent}{currentForm}';
        set(hands(1:length(strings),2),{'string'},strings)
        set(ud.h.editFs,'string',ud.FsString)
        
    case 0    % selection is transferrable
        set(hands(:,1:2),'enable','on')
        % set edit strings
        strings = ud.fieldStrings{currentComponent}{currentForm}';
        set(hands(1:length(strings),2),{'string'},strings)
        set(ud.h.editFs,'string',ud.FsString)
             
    otherwise % selection is a valid SPT data type
              %  - can't transfer by arrows
              %  - might need to change component
              %  - set edit boxes to 'enable','off' with special strings
        if get(ud.h.importas,'value')~=types(val)
            set(ud.h.importas,'value',types(val))
            changeComponent
            set(ud.h.listbox,'value',val)
        end
        varName = str{val};
        ind = find(varName=='[');
        varName(ind-1:end)=[];
        workspaceFlag = get(ud.h.radio1,'value');
        if ud.FsFlag(types(val))
           if workspaceFlag
               Fs = getStructureField(varName,'Fs');
           else
               Fs = getStructureField(varName,'Fs',ud.fullFileName);
           end
           set(ud.h.editFs,'string',sprintf('%.9g',Fs))
        end
        if workspaceFlag
            label = getStructureField(varName,'label');
        else
            label = getStructureField(varName,'label',ud.fullFileName);
        end
        set(ud.h.editLabel,'string',label)
        set(hands(:,1),'enable','off')
        set(hands(1:4,2),'enable','off','string',['<' label '>'])
    end
    
  case 'Help'
    % Callback code for pushbutton with Tag "Help"
    fig = gcf;
    uiList = findobj(fig,'type','uicontrol');
    saveVis = get(uiList,'visible');
    if strcmp(computer,'PCWIN')
        set(uiList,'visible','off')
    end
    ud = get(fig,'userdata');
    fp = get(fig,'position');
    sz = sptsizes;
    f = uicontrol('style','frame',...
           'position',[sz.fus sz.fus fp(3)-2*sz.fus fp(4)-sz.fus-1],...
           'tag','importhelp');
    tp = [2*sz.fus 4*sz.fus+sz.uh fp(3)-4*sz.fus fp(4)-(6*sz.fus+sz.uh)];
       % text position
    [fontname,fontsize]=fixedfont;
    t = uicontrol('style','listbox','position',tp,'string',importHelpStr,'max',2,...
         'tag','importhelp','horizontalalignment','left',...
         'backgroundcolor','w','fontname',fontname,'fontsize',fontsize);
    % bp = [2*sz.fus 2*sz.fus sz.bw sz.uh];  % button position
    bp = [27 16 60 20];  %-- use exact same pos as 'Help' button
    b = uicontrol('style','pushbutton','position',bp,...
         'tag','importhelp','string','OK',...
         'callback','delete(findobj(gcf,''tag'',''importhelp''))');
    waitfor(b)
    if all(ishandle(uiList))
        if strcmp(computer,'PCWIN')
            set(uiList,{'visible'},saveVis)
        end
    end
    
  case 'Cancel'
    % Callback code for pushbutton with Tag "Cancel"
    ud = get(gcf,'userdata');
    % handle close request when in "Help" mode:
    b = findobj(gcf,'tag','importhelp');
    if ~isempty(b)
        delete(b)  % triggers waitfor in 'Help' callback
    end

    set(ud.h.OKButton,'userdata','Cancel')  % triggers waitfor in initial
                                            % function call
      
  case 'OKButton'
    % Callback code for pushbutton with Tag "OK"
    ud = get(gcf,'userdata');


    str = get(ud.h.listbox,'string');
    val = get(ud.h.listbox,'value');
    types = get(ud.h.listbox,'userdata');
    currentComponent = get(ud.h.importas,'value');
    currentForm = get(ud.h.formPopup,'value');
    errstr = ''; % error string
    
    componentNames = get(ud.h.importas,'string');
    if types(val)>0  % import previously exported object
        varName = str{val};
        ind = find(varName=='[');
        varName(ind-1:end)=[];
        workspaceFlag = get(ud.h.radio1,'value');
        if workspaceFlag
            ud.struc = getVariable(varName);
        else
            ud.struc = getVariable(varName,ud.fullFileName);
        end

        err = 0;        
        if ud.FsFlag(types(val))
           if workspaceFlag
               [ud.struc.Fs,err] = getVariable(get(ud.h.editFs,'string'));
           else
               [ud.struc.Fs,err] = getVariable(get(ud.h.editFs,'string'),...
                                                ud.fullFileName);
           end
           if err,
               errstr = ['Sorry, the Sampling Frequency you entered '...
                         'cannot be evaluated.'];
           end
        end
        
        if ~err
            [valid,ud.struc] = feval(ud.importFcn{currentComponent},...
                  'valid',ud.struc);
            if ~valid,
                errstr = ['Sorry, your selection is not a valid ' ...
                          componentNames{currentComponent} '.'];
            end
            err = ~valid;
        end
    else % make a new object
        % make a vector of handles
        strings = ud.fields{currentComponent}(currentForm).fields;
        hands = [ ud.h.edit1 
                  ud.h.edit2 
                  ud.h.edit3 
                  ud.h.edit4 ];
        hands = hands(1:length(strings));        
        if ud.FsFlag(currentComponent)
            hands = [hands; ud.h.editFs];
            strings{end+1} = get(ud.h.labelFs,'string');
        end
        params = cell(1,length(hands)+1);
        params{1} = get(ud.h.formPopup,'value');
        if get(ud.h.radio2,'value')
            getVariableParams{2} = ud.fullFileName;
        end
        for i=1:length(hands)
            getVariableParams{1} = get(hands(i),'string');
            [params{i+1},err] = getVariable(getVariableParams{:});
            if err,
               switch err
               case 1
                   errstr = ['Sorry, your entry in the "' strings{i} ...
                             '" field could not be evaluated.'];
               case 2
                   errstr = ['Sorry, you need to enter something '...
                             'in the "' strings{i} '" field.'];
               end
               break
            end
        end
        if ~err
            [err,errstr,ud.struc] = ...
                   feval(ud.importFcn{currentComponent},'make',params);
        end
    end

    if ~err
        label = get(ud.h.editLabel,'string');
        err = ~isvalidvar(label);
        if ~err
            if ~isempty(findcstr(ud.labelList,label))
                % prompt for over-write
                switch questdlg(...
                         {['By importing "' label '", you are replacing an']
                           'already existing object in the SPTool named'
                          ['"' label '".  Any objects that depend on"' label '"']
                          ['will be altered.'] 
                          'Are you sure you want to import?'},...
                          'Name Conflict','Yes','No','No')
                case 'Yes'
                   ud.struc.label = label;
                case 'No'
                   return
                end
            else
                ud.struc.label = label;
            end   
        else
            errstr = {'Sorry, the name you have entered is not valid.'
                      'It must be a legal MATLAB variable name.'};
        end     
    end
    
    set(gcf,'userdata',ud)

    if isempty(errstr)
        % now send signal that we are done to waitfor:
        set(ud.h.OKButton,'userdata','OK')
    else
        % put up error dialog box
        h=msgbox(errstr,'Import Error','error','modal');
        waitfor(h)
    end

  case 'importas'
    % Callback code for popupmenu with Tag "importas"
    changeComponent
    
  case 'formPopup'
    % Callback code for popupmenu with Tag "formPopup"
    ud = get(gcf,'userdata');
    currentComponent = get(ud.h.importas,'value');
    currentForm = get(ud.h.formPopup,'value');
    ud.formValue(currentComponent) = currentForm;
    set(gcf,'userdata',ud)
    changeComponent(1)
    
  case 'arrow1'
    % Callback code for pushbutton with Tag "arrow1"
    ud = get(gcf,'userdata');
    str = get(ud.h.listbox,'string');
    val = get(ud.h.listbox,'value');
    set(ud.h.edit1,'string',str{val})
    editStringChange(1)
    
  case 'arrow2'
    % Callback code for pushbutton with Tag "arrow2"
    ud = get(gcf,'userdata');
    str = get(ud.h.listbox,'string');
    val = get(ud.h.listbox,'value');
    set(ud.h.edit2,'string',str{val})
    editStringChange(2)

  case 'arrow3'
    % Callback code for pushbutton with Tag "arrow3"
    ud = get(gcf,'userdata');
    str = get(ud.h.listbox,'string');
    val = get(ud.h.listbox,'value');
    set(ud.h.edit3,'string',str{val})
    editStringChange(3)

  case 'arrow4'
    % Callback code for pushbutton with Tag "arrow4"
    ud = get(gcf,'userdata');
    str = get(ud.h.listbox,'string');
    val = get(ud.h.listbox,'value');
    set(ud.h.edit4,'string',str{val})
    editStringChange(4)

  case 'arrow5'
    % Callback code for pushbutton with Tag "arrow5"
    ud = get(gcf,'userdata');
    str = get(ud.h.listbox,'string');
    val = get(ud.h.listbox,'value');
    set(ud.h.editFs,'string',str{val})
    ud.FsString = get(ud.h.editFs,'string');
    set(gcf,'userdata',ud)
  
  case 'edit1'
    % Callback code for edit with Tag "edit1"
    editStringChange(1)
    
  case 'edit2'
    % Callback code for edit with Tag "edit2"
    editStringChange(2)
    
  case 'edit3'
    % Callback code for edit with Tag "edit3"
    editStringChange(3)
    
  case 'edit4'
    % Callback code for edit with Tag "edit4"
    editStringChange(4)
    
  case 'editFs'
    % Callback code for edit with Tag "editFs"
    ud = get(gcf,'userdata');
    ud.FsString = get(ud.h.editFs,'string');
    set(gcf,'userdata',ud)
    
end

function editStringChange(i)
%editStringChange  sets userdata structure which saves the strings
%                  entered into the import dialog box
%     i is between 1 and 4
%     userdata is changed
    ud = get(gcf,'userdata');
    currentComponent = get(ud.h.importas,'value');
    currentForm = get(ud.h.formPopup,'value');
    eval(['ud.fieldStrings{currentComponent}{currentForm}{i} = ' ...
          'get(ud.h.edit' num2str(i) ',''string'');']);
    set(gcf,'userdata',ud)

function getContentsOfFile
  % Called by 'browse' button and callback of filename edit box,
  % also when 'From Disk' radio button is clicked

  ud = get(gcf,'userdata');
  if isempty(ud.fullFileName)
    set(ud.h.listbox,'string',{'<no file selected>'},'value',1,'userdata',-1)
  else
    whosString = ['w=whos(''-file'',''' ud.fullFileName ''');'];
    err=0;
    eval(whosString,'err=1;')
    if err
        set(ud.h.listbox,'string',{'<file not found>'},'value',1,'userdata',-1)
    else
        if length(w) == 0
            set(ud.h.listbox,'string',{'<file empty>'},'value',1,'userdata',-1)
        else
            listString = {'<no selection>' w.name};
            [type,listString] = componentMarkup(listString,w,ud.fullFileName);
            set(ud.h.listbox,'string',listString,'value',1,'userdata',type)
        end
    end
  end
  selectNothing
  
function getContentsOfWorkspace
  % Called when 'From Workspace' radio button is clicked
  % and (possibly) at initialization time
  
  ud = get(gcf,'userdata');
  w = evalin('base','whos');
  if length(w) == 0
      set(ud.h.listbox,'string',{'<no variables>'},'value',1,'userdata',-1)
  else
      listString = {'<no selection>' w.name};
      [type,listString] = componentMarkup(listString,w);
      set(ud.h.listbox,'string',listString,'value',1,'userdata',type)
  end
  selectNothing
  

function selectNothing
  ud = get(gcf,'userdata');
  currentComponent = get(ud.h.importas,'value');
  currentForm = get(ud.h.formPopup,'value');
  hands = [ud.h.arrow1 ud.h.edit1 
             ud.h.arrow2 ud.h.edit2 
             ud.h.arrow3 ud.h.edit3 
             ud.h.arrow4 ud.h.edit4 
             ud.h.arrow5 ud.h.editFs];
  set(hands(:,1),'enable','off')
  set(hands(:,2),'enable','on')
  % set edit strings
  strings = ud.fieldStrings{currentComponent}{currentForm}';
  set(hands(1:length(strings),2),{'string'},strings)
  set(ud.h.editFs,'string',ud.FsString)


function [type,listString] = componentMarkup(listString,w,fname)
%componentMarkup - identify types of objects in workspace or MAT-file
%  Inputs:
%      listString - cell array - the first element is ignored, the remaining
%        elements are string variable names in the workspace or file
%      w - whos structure from workspace or MAT-file
%      fname - if present, specifies full MAT-file name (directory & filename)
%              if not present, componentMarkup expects to find the variables in 
%                the WORKSPACE.
%  Outputs:
%      type - vector of integers, 1 element for each string in listString
%                 -1  --> do not allow transfer with the arrow buttons
%                         (unknown SPT object or the first element in the list)
%                  0  --> normal MATLAB vector; allow transfer with arrow buttons
%                  1..n (where n = number of components) -->
%                         SPT object identified, number corresponds to position
%                         in string of ud.h.importas
%      listString - list of strings for ud.h.listbox, edited to indicate
%                  various SPT objects

ud = get(gcf,'userdata');
if nargin == 2    % FROM WORKSPACE
    workspaceFlag = 1;
else
    workspaceFlag = 0;
end

type = zeros(1,length(listString));
type(1) = -1;
dataNames = get(ud.h.importas,'string');
%versions = cell(length(dataNames));
%for i = 1:length(ud.importFcn)
%    versions{i} = feval(ud.importFcn{i},'version');
%end
for i = 2:length(listString)
    if strcmp(w(i-1).class,'struct') & isequal(w(i-1).size,[1 1])
       if workspaceFlag
           SPTIdent = getStructureField(listString{i},'SPTIdentifier');
       else
           SPTIdent = getStructureField(listString{i},'SPTIdentifier',fname);
       end
       if ~isempty(SPTIdent)
           ind = find(strcmp(dataNames,SPTIdent.type));
           if isempty(ind)
               type(i) = -1;
           else
               type(i) = ind;
           end
       end
       switch type(i)
       case -1
           listString{i} = [listString{i} ' [Unknown]'];
       case 0
           % do nothing
       otherwise
           listString{i} = ...
                 [listString{i} ' [' dataNames{ind} ']'];
       end
    end
end

function varargout = getStructureField(varargin)
%getStructureField
% field = getStructureField(varName,fieldName,fname)
% Returns the field 'fieldName' of the structure 'varName' in the
% MAT-file 'fname'.  fname is optional; if you don't specify it, this
% function looks in the workspace instead.

if nargin == 2  % workspace
    varargout{1} = evalin('base',[varargin{1} '.' varargin{2}],'[]');
else  % MAT-file
    load(varargin{3},varargin{1})
    varargout{1} = eval([varargin{1} '.' varargin{2}],'[]');
end


function varargout = getVariable(varargin)
%getVariable
% [var,err] = getVariable(varName,fname)
% Returns the var 'varName' in the MAT-file 'fname'.  fname is optional; 
% if you don't specify it, this function looks in the workspace instead.
% If 'varName' is not found in fname, the string is evaluated in this function's
% workspace;
% err = 2 if the string is empty,
%       1 if there is an error in evaluating the string, 
%       0 if OK
GETVARIABLE_ERROR = 0;  % this name  needs to be long and ugly to minimize 
                           % chances of a (still possible) name clash
if isempty(varargin{1})
    varargout{1} = [];
    varargout{2} = 2;
    return
end
if nargin == 1  % workspace
    varargout{1} = evalin('base',varargin{1},'''ARBITRARY_STRING''');
    if isequal(varargout{1},'ARBITRARY_STRING')
        GETVARIABLE_ERROR = 1;
    end
else  % MAT-file
    w = warning('off');
    eval(['load(''' varargin{2} ''',''' varargin{1} ''')'],'GETVARIABLE_ERROR=1;')
    eval(['varargout{1}=' varargin{1} ';'],'GETVARIABLE_ERROR=1;');
    warning(w);
end
if GETVARIABLE_ERROR
    varargout{1} = [];
end
varargout{2}=GETVARIABLE_ERROR;


function changeComponent(formFlag)
%changeComponent - set Import As: area of dialog according to components
% if formFlag is present, the 'form' popup has changed (not the
% 'Import As' popup).

    ud = get(gcf,'userdata');
    currentComponent = get(ud.h.importas,'value');
    currentForm = get(ud.h.formPopup,'value');
    if currentForm ~= ud.formValue(currentComponent)
        currentForm = ud.formValue(currentComponent);
        set(ud.h.formPopup,'value',currentForm)
    end
    set(ud.h.formPopup,'value',ud.formValue(currentComponent))
    if length(ud.fields{currentComponent}) == 1
        set([ud.h.Form ud.h.formPopup],'visible','off')
    else
        set([ud.h.Form ud.h.formPopup],'visible','on')
    end
    set(ud.h.formPopup,'string',{ud.fields{currentComponent}.form})
    hands = [ud.h.arrow1 ud.h.edit1 ud.h.label1
             ud.h.arrow2 ud.h.edit2 ud.h.label2
             ud.h.arrow3 ud.h.edit3 ud.h.label3
             ud.h.arrow4 ud.h.edit4 ud.h.label4
             ud.h.arrow5 ud.h.editFs ud.h.labelFs];

    currentLabels = ...
         ud.fields{currentComponent}(currentForm).fields;
    set(hands(1:length(currentLabels),:),'visible','on')
    set(hands(length(currentLabels)+1:4,:),'visible','off')
    
    % set labels:
    set(hands(1:length(currentLabels),3),{'string'},currentLabels')
 
    types = get(ud.h.listbox,'userdata');
    
    if nargin<1
       % if an SPT Object is selected in the listbox, deselect it
       % in the process of changing Components
       if types(get(ud.h.listbox,'value')) > 0
           set(ud.h.listbox,'value',1)  % no selection!
           set(hands(:,1),'enable','off')
           set(hands(:,2),'enable','on')
       end
       set(ud.h.editLabel,'string',ud.defaultLabel{currentComponent})
       if ~ud.FsFlag(currentComponent)
           set(hands(5,:),'visible','off')
       else
           set(hands(5,:),'visible','on')
       end
    end
    
    if types(get(ud.h.listbox,'value')) <= 0
        % if previously exported structure is not selected, update edit strings
        set(hands(1:length(currentLabels),2),{'string'},...
            ud.fieldStrings{currentComponent}{currentForm}')
    end
    
function initImport
% This is the [HAND EDITED] machine-generated representation of a 
% MATLAB object
% and its children.  Note that handle values may change when these
% objects are re-created. This may cause problems with some callbacks.
% The command syntax may be supported in the future, but is currently 
% incomplete and subject to change.
%
% To re-open this system, just type the name of the m-file at the MATLAB
% prompt. The M-file and its associtated MAT-file must be on your path.
ud = [];
ss = get(0,'screensize');
h = 308;
w = 587;  % height and width in pixels
% Place window's upper left corner at [40,60] offset from upper left
fp = [40 ss(4)-h-60 w h];
a = figure('Color',get(0,'defaultuicontrolbackgroundcolor'), ...
   'Position',fp, ...
   'dockcontrols','off',...
   'IntegerHandle','off',...
   'Name','Import to SPTool',...
   'NumberTitle','off',...
   'Resize','off',...
   'CloseRequestFcn','sbswitch(''sptimport'',''Cancel'')',...
   'Tag','Fig1',...
   'WindowStyle','modal',...
   'HandleVisibility','callback',...
   'units','pixels',...
   'menubar','none');
b = uicontrol('Parent',a, ...
   'units','pixels',...
     'Position',[6 5 324 39], ...
   'Style','frame', ...
   'Tag','Frame6');
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'Position',[353 5 228 38], ...
   'Style','frame', ...
   'Tag','Frame5');
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'Position',[354 53 228 244], ...
   'Style','frame', ...
   'Tag','Frame4');
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'Position',[159 53 147 245], ...
   'Style','frame', ...
   'Tag','Frame3');
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'Position',[7 53 141 245], ...
   'Style','frame', ...
   'Tag','Frame2');
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'Position',[11 151 133 101], ...
   'Style','frame', ...
   'Visible','off',...
   'Tag','Frame1');
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'CallBack','sbswitch(''sptimport'')', ...
   'Position',[12 259 125 20], ...
   'String','From Workspace', ...
   'Style','radiobutton', ...
   'Tag','radio1', ...
   'Value',1);
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'CallBack','sbswitch(''sptimport'')', ...
   'Position',[12 238 107 20], ...
   'String','From Disk', ...
   'Style','radiobutton', ...
   'Tag','radio2', ...
   'Value',0);
ud = addToUserData(ud,b);
if strcmp(computer,'PCWIN'),
    pos=[27 219 106 20];
else 
    pos=[27 215 106 20];
end
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'HorizontalAlignment','left', ...
   'Position',pos, ...
   'String','MAT-file Name:', ...
   'Style','text', ...
   'Tag','filenameLabel');
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'BackgroundColor',[1 1 1], ...
   'CallBack','sbswitch(''sptimport'')', ...
   'HorizontalAlignment','left',...
   'Position',[28 195 110 24], ...
   'Style','edit', ...
   'Tag','filename');
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'CallBack','sbswitch(''sptimport'')', ...
   'Position',[30 170 106 20], ...
   'String','Browse...', ...
   'Tag','browse');
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'Position',[18 286 116 20], ...
   'String','Source', ...
   'Style','text', ...
   'Tag','SourceLabel');
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'Position',[166 285 136 20], ...
   'String','Workspace Contents', ...
   'Style','text', ...
   'Tag','ContentsLabel');
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'BackgroundColor',[1 1 1], ...
   'CallBack','sbswitch(''sptimport'')', ...
   'Position',[165 58 136 225], ...
   'Style','listbox', ...
   'Tag','listbox', ...
   'UserData',-1,...
   'Value',1);
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'CallBack','sbswitch(''sptimport'')', ...
   'Position',[247 16 60 20], ...
   'String','Help', ...
   'Tag','Help');
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'CallBack','sbswitch(''sptimport'')', ...
   'Position',[137 16 60 20], ...
   'String','Cancel', ...
   'Tag','Cancel');
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'CallBack','sbswitch(''sptimport'')', ...
   'Position',[27 16 60 20], ...
   'String','OK', ...
   'Tag','OKButton');
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'Position',[358 283 74 20], ...
   'String','Import As:', ...
   'Style','text', ...
   'Tag','StaticText2');
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'CallBack','sbswitch(''sptimport'')', ...
   'Position',[431 283 117 20], ...
   'String',' ', ...
   'Style','popupmenu', ...
   'BackgroundColor','white',...
   'Tag','importas', ...
   'Value',1);
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'Position',[370 258 60 20], ...
   'String','Form:', ...
   'Style','text', ...
   'Tag','Form');
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'CallBack','sbswitch(''sptimport'')', ...
   'Position',[420 259 145 20], ...
   'String',' ', ...
   'Style','popupmenu', ...
   'BackgroundColor','white',...
   'Tag','formPopup', ...
   'Value',1);
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'BackgroundColor',[1 1 1], ...
   'HorizontalAlignment','left', ...
   'Position',[363 228 110 21], ...
   'Style','edit', ...
   'CallBack','sbswitch(''sptimport'')', ...
   'Tag','edit1');
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'HorizontalAlignment','left', ...
   'Position',[478 228 100 20], ...
   'String','Label1', ...
   'Style','text', ...
   'Tag','label1');
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'CallBack','sbswitch(''sptimport'')', ...
   'Position',[312 228 36 20], ...
   'String','-->', ...
   'Tag','arrow1');
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'CallBack','sbswitch(''sptimport'')', ...
   'Position',[312 195 36 20], ...
   'String','-->', ...
   'Tag','arrow2');
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'HorizontalAlignment','left', ...
   'Position',[478 195 100 20], ...
   'String','Label1', ...
   'Style','text', ...
   'Tag','label2');
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'BackgroundColor',[1 1 1], ...
   'HorizontalAlignment','left', ...
   'Position',[363 195 110 21], ...
   'Style','edit', ...
   'CallBack','sbswitch(''sptimport'')', ...
   'Tag','edit2');
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'BackgroundColor',[1 1 1], ...
   'HorizontalAlignment','left', ...
   'Position',[363 162 110 21], ...
   'CallBack','sbswitch(''sptimport'')', ...
   'Style','edit', ...
   'Tag','edit3');
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'HorizontalAlignment','left', ...
   'Position',[478 162 100 20], ...
   'String','Label1', ...
   'Style','text', ...
   'Tag','label3');
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'CallBack','sbswitch(''sptimport'')', ...
   'Position',[312 162 36 20], ...
   'String','-->', ...
   'Tag','arrow3');
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'BackgroundColor',[1 1 1], ...
   'HorizontalAlignment','left', ...
   'Position',[363 128 110 21], ...
   'CallBack','sbswitch(''sptimport'')', ...
   'Style','edit', ...
   'Tag','edit4');
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'HorizontalAlignment','left', ...
   'Position',[478 128 100 20], ...
   'String','Label1', ...
   'Style','text', ...
   'Tag','label4');
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'CallBack','sbswitch(''sptimport'')', ...
   'Position',[312 128 36 20], ...
   'String','-->', ...
   'Tag','arrow4');
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'BackgroundColor',[1 1 1], ...
   'CallBack','sbswitch(''sptimport'')', ...
   'HorizontalAlignment','left', ...
   'Position',[363 63 210 21], ...
   'Style','edit', ...
   'Tag','editFs');
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'HorizontalAlignment','left', ...
   'Position',[365 86 128 16], ...
   'String','Sampling Frequency', ...
   'Style','text', ...
   'Tag','labelFs');
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'CallBack','sbswitch(''sptimport'')', ...
   'Position',[312 63 36 20], ...
   'String','-->', ...
   'Tag','arrow5');
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'BackgroundColor',[1 1 1], ...
   'HorizontalAlignment','left', ...
   'Position',[363 12 209 21], ...
   'Style','edit', ...
   'Tag','editLabel');
ud = addToUserData(ud,b);
b = uicontrol('Parent',a, ...
   'units','pixels',...
   'HorizontalAlignment','left', ...
   'Position',[364 34 50 16], ...
   'String','Name', ...
   'Style','text', ...
   'Tag','labelLabel');
ud = addToUserData(ud,b);
set(a,'userdata',ud)


function udOutput = addToUserData(udInput,b)
%addToUserData - adds the handle b to input structure with the
%  field name given by b's tag
    udOutput = udInput;
    eval(['udOutput.h.' get(b,'tag') ' = b;'])
    
function minwidth(h,n)
%MINWIDTH Minimize width of centered text object to be just wide
% enough for extent.
% optional second argument specifies additional pixels on either side
% of text, defaults to 2

if nargin == 1
    n = 2;
end
for i=1:length(h)
    ex = get(h(i),'extent');
    pos = get(h(i),'position');
    switch get(h(i),'horizontalalignment')
    case 'center'
       set(h(i),'position',[pos(1)+pos(3)/2-ex(3)/2-n pos(2) ex(3)+2*n pos(4)])
    case 'left'
       set(h(i),'position',[pos(1)+n pos(2) ex(3)+2*n pos(4)])
       set(h(i),'horizontalalignment','center')
    end
end

function s = importHelpStr
% return cell array of strings which describes the import dialog

s = {
'IMPORTING DATA TO SPTOOL'
' '
'SOURCE   In this frame, click on "From Workspace" to import'
'data from the MATLAB workspace.  Click on "From Disk" to import'
'data from a MAT-file saved on disk.  With "From Disk" selected,'
'you can type a MAT-file name and hit enter, or click Browse to'
'look for a file on your computer.'
' '
'CONTENTS   If "From Workspace" is selected, this is a list'
'of the variables in the MATLAB workspace.  If "From Disk"'
'is selected, this is a list of the variables saved in the'
'MAT-file you entered.  To import data that has been previously'
'exported from the SPTool, just click on it here.'
' '
'ARROWS   Use an arrow button "-->" to move the selected'
'variable into the variable field to the right of the arrow.'
'You can also type variable names directly into these fields.'
'When "From Workspace" is selected, you can type in expressions'
'as well to create data or filters on the fly.'
' '
'IMPORT AS...   Select from this menu the type of data that'
'you wish to import. The fields underneath will change according'
'to the information needed to import the object.  For example, a'
'"Signal" object requires a Data field which is the signal data'
'vector or matrix, and a Sampling Frequency which is a scalar.'
' '
'NAME   Enter a name for your imported data here.  The SPTool'
'uses this name to keep track of your data.  The name must be'
'a legal MATLAB variable name, that is, it must begin with a'
'letter and then consist only of letters, numerals (0 through '
'9), and underscores "_".'
};
   
   
   
   
