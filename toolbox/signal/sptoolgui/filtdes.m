function varargout = filtdes(varargin)
%FILTDES Filter Designer.
%   This graphical tool allows you to design lowpass, highpass, bandpass,
%   and bandstop digital filters.
%
%   Type 'sptool' to start the Signal Processing GUI Tool and access
%   the Filter Designer.
%
%   [B,A] = FILTDES('getfilt') returns the numerator coefficients in B
%   and denominator coefficients in A of the current filter.
%
%   [B,A,Fs] = FILTDES('getfilt') returns the sampling frequency Fs also.
%
%   See also SPTOOL, SIGBROWSE, FILTVIEW, SPECTVIEW.

%   Author: T. Krauss, 3/7/94
%           Version 2, May 1997
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.20.4.2 $ $Date: 2004/04/13 00:32:22 $

if nargin==0 
    if isempty(findobj(0,'tag','sptool'))
        disp('Type ''sptool'' to start the Signal GUI.')
    else
        disp('To use the Filter Designer, click on the ''Design New'' button')
        disp('under the ''Filters'' column in the ''SPTool''.')
    end
    return
end

if nargin<1
    action = 'init';
    f = [];
elseif isstruct(varargin{1})
    action = 'init';
    f = varargin{1};
else
    action = varargin{1};
end

switch action
%------------------------------------------------------------------------
%filtdes('init')
%filtdes(f) - where f is a filter structure of type 'design'
%  Creates a new figure with tag 'filtdes'
case 'init'
    figname = prepender('Filter Designer');
    screensize = get(0,'screensize');
    fp = get(0,'defaultfigureposition');
    fw = 700;
    %fw = 610;  % figure width - 
               % slightly less than the minimum width of 640 pixels 
               % (assuming 640x480 is smallest screen size)
    fw = min(fw,screensize(3)-50);
    fh = 410;  % figure height - slightly less than minimum screen width (480)
    fp = [fp(1)-(fw-fp(3))/2 fp(2)+fp(4)-fh fw fh];

    % create figure
    fig = figure('visible','off',...
                 'handlevisibility','callback',...
                 'dockcontrols','off',...
                 'tag','filtdes',...
                 'name',figname,...
                 'menubar','none',...
                 'position',fp,...
                 'numbertitle','off',...
                 'integerhandle','off',...
                 'windowbuttondownfcn','filtdes(''down'')',...
                 'windowbuttonmotionfcn','filtdes(''motion'')',...
                 'closerequestfcn','filtdes(''SPTclose'')',...
                 'keypressfcn','filtdes(''keypressfcn'')');

    ud.sz = sptsizes;
    
    % load preferences from SPTool:
    SPTfig = findobj(0,'tag','sptool');
    filtdesPrefs = sptool('getprefs','filtdes',SPTfig);
    ud.prefs.tool.zoompersist = filtdesPrefs.zoomFlag;  
    ud.prefs.nfft = eval(filtdesPrefs.nfft,'1024');
    ud.prefs.grid = filtdesPrefs.grid;
    ud.prefs.AutoDesignInit = filtdesPrefs.AutoDesignInit;
    
    % create "ht" field; stands for "handle table"
    ud.ht.specFrame = uicontrol('style','frame','tag','specFrame');
    % axFrame - invisible - used for axes positioning purposes:
    ud.ht.axFrame = uicontrol('style','frame','visible','off','tag','axFrame');
    ud.ht.measFrame = uicontrol('style','frame','tag','measFrame');
    ud.ht.tb2Frame = uicontrol('style','frame','tag','tb2Frame');  %"toolbar 2 frame"
    %ud.ht.filtMenuFrame = uicontrol('style','frame','tag','filtMenuFrame'); 
    
    ud.ht.specLabel = uicontrol('style','text',...
                  'string','Specifications','tag','specFrame');
    ud.ht.measLabel = uicontrol('style','text',...
                  'string','Measurements','tag','measFrame');
    if strcmp(computer,'MAC2')
        fontSize = 14;
        fontWeight = 'normal';
    elseif strcmp(computer,'PCWIN')
        fontSize = 9;
        fontWeight = 'bold';
    else
        fontSize = 12;
        fontWeight = 'bold';
    end
    set([ud.ht.specLabel ud.ht.measLabel],...
        'fontsize',fontSize,'fontweight',fontWeight)
    set(ud.ht.measLabel,'backgroundcolor',[.9 .5 .5]) 
    set(ud.ht.specLabel,'backgroundcolor',[.7 .9 .7])
    
    ud.ht.revert = uicontrol('style','pushbutton',...
                  'string','Revert','callback','filtdes(''revert'')',...
                  'enable','off','tag','revert');
    ud.ht.apply = uicontrol('style','pushbutton',...
                  'string','Apply','callback','filtdes(''apply'')',...
                  'enable','off','tag','apply');
    ud.ht.autoDesign = uicontrol('style','checkbox',...
                  'string','Auto Design','callback','filtdes(''autodesignCB'')',...
                  'enable','on','value',ud.prefs.AutoDesignInit,'tag','AutoDesign');
    ud.saveAutoDesign = get(ud.ht.autoDesign,'value');
    
    ud.ht.modulePopup = uicontrol('style','popupmenu','Backgroundcolor','white',...
                  'string','1','callback','filtdes(''modulepopup'')',...
                  'enable','on','value',1);
    
    ud.ht.moduleLabel = uicontrol('style','text','string','Algorithm',...
          'horizontalalignment','left');
    ud.ht.FsLabel = uicontrol('style','text','string','Sampling Frequency',...
          'horizontalalignment','left','tag','Fs');
    
    ud.ht.FsEdit = uicontrol('style','edit','string','1',...
                 'backgroundcolor','w','horizontalalignment','left',...
                 'callback','filtdes(''Fsedit'')','tag','Fs');
    
    ud.ht.filtMenuLabel = uicontrol('style','text','string','Filter',...
          'horizontalalignment','left','tag','filtmenu');
    ud.ht.filtMenu = uicontrol('style','popupmenu','Backgroundcolor','white',...
          'string',{'filt1'},'callback','filtdes(''filtmenu'')','tag','filtmenu');

    %====================================
    % MENUS

     %  MENU LABEL             CALLBACK                          TAG
    mc={ '&File'              ' '                                'File'
         '>Pa&ge Setup...'    'printcomp(''pgepos'')'            'pagepos'
         '>Print Pre&view...' 'printcomp(''prev'')'              'printprev'
         '>&Print...'         'printcomp(''prnt'')'              'prnt'
         '>---'               ' '                                ' '
         '>&Close^w'          'filtdes(''SPTclose'')'            'close'
         '&Window'            winmenu('callback')                'winmenu'};
	 
	 % Build the cell array string for the Help menu.
	 mh = filtdes_helpmenu;
	 mc = [mc;mh];
	 handles = makemenu(fig, char(mc(:,1)), ...
                            char(mc(:,2)), char(mc(:,3)));

    set(handles,'handlevisibility','callback')

    winmenu(fig)  % initialize windows menu

    % Register modules              
    ud.modules = fdmodp({});  % calls one in signal/private
    % now call each one found on path:
    p = sptool('getprefs','plugins',SPTfig);
    if p.plugFlag
        ud.modules = sptool('callall','fdmod',ud.modules);
    end

    modulePopupStr = cell(length(ud.modules),1);
    for i=1:length(ud.modules)
         eval(['modulePopupStr{i} = ' ud.modules{i} '(''description'');'],...
           ['modulePopupStr{i} = ''' ud.modules{i} ''';'])
    end
    
    % Initialize Objects arrays
    %  This structure contains a field for each type of object supported
    %  by filtdes, including fdspec, fdax, fdline, and fdmeas
    %  Each field is an array of the corresponding objects
    ud.Objects = [];
    ud.Objects.fdspec = [];
    ud.Objects.fdax = [];
    ud.Objects.fdline = [];
    ud.Objects.fdmeas = [];

    if isempty(f)
        % create a new filter 
        Fs = sptool('commonFs');
        [err,errmsg,ud.filt]=sbswitch('importfilt','make',{1 1 1 Fs});
        ud.filt.type = 'design';
    else
        ud.filt = f;
    end
    set(ud.ht.FsEdit,'string',sprintf('%1.5g',ud.filt.Fs))
    
    if isfield(ud.filt,'specs') & isstruct(ud.filt.specs) & ...
            isfield(ud.filt.specs,'currentModule')
        if isempty(strcmp(ud.modules,ud.filt.specs.currentModule))
            switch ud.filt.type
            case 'design'
                ud.filt.specs.currentModule = ud.modules{1};
            case 'imported'
                ud.filt.specs.currentModule = 'fdpzedit';
            end
        end
    else
        switch ud.filt.type
        case 'design'
            ud.filt.specs.currentModule = ud.modules{1};
        case 'imported'
            ud.filt.specs.currentModule = 'fdpzedit';
        end
    end
    moduleInd = find(strcmp(ud.modules,ud.filt.specs.currentModule));
    ud.currentModule = ud.modules{moduleInd};
    set(ud.ht.modulePopup,'string',modulePopupStr,'value',moduleInd)

    % define ud.pointer  and justzoom
    ud.pointer = 0;
    ud.justzoom = [0 0];
    
    ud.modeObject = [];  % when ud.pointer == 3 to indicate the filtdes
                         % is in a mode, this is the particular fdspec object
                         % of type togglebutton which defines the mode
    ud.defaultModeObject = [];
        % when in regular "mouse click" mode, if this object is not
        % empty, it's value will be set to 1
                          
    % save userdata before calling zoombar since zoombar alters ud.
    %  Also, set resizefcn before calling zoombar since zoombar
    %  appends to resizefcn.  The resizefcn is not set at figure
    %  creation time because if it were, it would get called and that would
    %  be bad since the objects being resized wouldn't exist yet.
    set(fig,'userdata',ud,'resizefcn','filtdes(''resize'')') 
    
    filtdes('resize')
    
    % ====================================================================
    % now add toolbar
    % NEW toolbar, using uitoolbar functionality, available as of 5.3:
    % TPK 6/22/99
    ud = create_toolbar(fig);
    set(fig,'userdata',ud)

    % call module to initialize itself:
    [newfilt,errstr] = feval(ud.currentModule,'init',ud.filt);

    ud = get(fig,'userdata'); % restore userdata in case it has been changed

    if ~isequal(ud.filt,newfilt)
        ud.filt = newfilt;
        set(fig,'userdata',ud)
        ud.filt = importFiltNoLineinfo(ud.filt,1);
        set(fig,'userdata',ud)
    end
    for i = 1:length(ud.Objects.fdspec)
        ud.Objects.fdspec(i).revertvalue = ud.Objects.fdspec(i).value;
    end
    set([ud.ht.revert ud.ht.apply],'enable','off')    

    if strcmp(ud.currentModule,'fdpzedit') & strcmp(get(ud.ht.autoDesign,'enable'),'on')
        ud.saveAutoDesign = get(ud.ht.autoDesign,'value');
        set(fig,'userdata',ud)
        set(ud.ht.autoDesign,'enable','off','value',1)
        set(ud.toolbar.passband,'enable','off')
    end
    
    % last step: make the figure visible
    set(fig,'visible','on')
    
%------------------------------------------------------------------------
%filtdes('down')
%   windowbuttondownfcn for filtdes figure
case 'down'
    fig = gcbf;
    ud = get(fig,'userdata');
    % only needed to implement module specific modes
    if ud.pointer == 3
        afp = get(ud.ht.axFrame,'position');
        cp = get(fig,'currentpoint');
        % if we're in the main axes area, and this is not a line click, 
        % then dispatch the mode buttondown msg
        %  (if the click IS on a line, the 'lineclick' callback
        %  will do the dispatching)
        if pinrect(cp,[afp([1 1])+[0 afp(3)] afp([2 2])+[0 afp(4)]]) & ...
           ~strcmp(get(gco,'type'),'line')
            str = ud.modeObject.modebuttondownmsg;
            if ~isempty(str)
                feval(ud.currentModule,ud.modeObject.modebuttondownmsg,gcbo)
            end
        end    
    end
    
%------------------------------------------------------------------------
%filtdes('motion')
%   windowbuttonmotionfcn for filtdes figure
case 'motion'
    fig = gcbf;
    pt = get(fig,'currentpoint');
    %disp(sprintf('x = %g, y = %g',pt(1),pt(2)))
    ud = get(fig,'userdata');
    pos = get(ud.ht.axFrame,'position');
        
    % handle non-regular modes
    if ud.pointer == -1 % wait mode
        setptr(fig,'watch')
        return
    elseif ud.pointer == 1  % zoom mode
        setptr(fig,'cross')
        return
    elseif ud.pointer == 2  % help mode
        setptr(fig,'help')
        return
    elseif ud.pointer == 3  % module specific mode
        str = ud.modeObject.modemotionfcn;
        if ~isempty(str)
            feval(ud.currentModule,ud.modeObject.modemotionfcn)
        end
        return
    end
    
    if length(ud.Objects.fdax)==0
        return
    end
    
    ax = ud.Objects.fdax(:).h;
    if length(ax)>1
        ax = [ax{:}];
    end
    axFound = 0;
    for i=1:length(ax)
        pos = get(ax(i),'position');
        if sbswitch('pinrect',pt,[pos(1) pos(1)+pos(3) pos(2) pos(2)+pos(4)])
            axFound = 1;
            break
        end
    end
    if axFound
        ax = ax(i);
        axud = get(ax,'userdata');
        thePtr = axud.pointer;
        if isempty(thePtr)
            thePtr = 'arrow';
        end
        
        % now find list of lines in this axes which have nontrivial 
        %  vertexpointer or segmentpointer properties
        pta = get(ax,'currentpoint');
        pta = pta(1,1:2);

        xlim = get(ax,'xlim');
        ylim = get(ax,'ylim');
        pos = get(ax,'position');  % assumed in pixels
        xscale = pos(3)/diff(xlim); % number of pixels per x axis units
        yscale = pos(4)/diff(ylim); % number of pixels per y axis units
        
        allLines = findobj(ax,'type','line');
        for i=1:length(allLines)
            lineUd = get(allLines(i),'userdata');
            if ~isempty(lineUd) & strcmp(get(allLines(i),'visible'),'on')
                vp = lineUd.vertexpointer;
                sp = lineUd.segmentpointer;
                if length(vp)>1 | length(sp)>1 | ~isempty(vp{1}) | ~isempty(sp{1})
                    % Are we close to this line?
                    xd = get(allLines(i),'xdata');
                    yd = get(allLines(i),'ydata');
    
                    [vertexFlag,dist,ind,segdist,segind] = ...
                           closestpoint(pta,allLines(i),xscale,yscale,xd,yd);
                         
                    if vertexFlag & (dist<3.5) & ...
                           (length(vp)>1 | ~isempty(vp{1}))
                        if length(vp) == 1
                            thePtr = vp{1};
                        else
                            thePtr = vp{ind};
                        end
                        break
                    elseif ~vertexFlag & (segdist<3.5) & ...
                           (length(sp)>1 | ~isempty(sp{1}))
                        if length(sp) == 1
                            thePtr = sp{1};
                        else
                            thePtr = sp{segind};
                        end
                        break
                    end
                end
            end
        end
        if ~isempty(thePtr)
            setptr(fig,thePtr)
        else
            setptr(fig,'arrow')
        end
    else
        currentPtr = get(fig,'pointer');  % Prevent flicker on PCWIN
        if ~strcmp(currentPtr,'arrow')
            setptr(fig,'arrow')
        end
        return
    end

%------------------------------------------------------------------------
% filtdes('keypressfcn')
% Call current module's keypressfcn
case 'keypressfcn'
    fig = gcbf;
    ud = get(fig,'userdata');

    eval(['eval(''' ud.currentModule '(''''keypressfcn'''',ud.filt)'')'],...
        '0');
    
%------------------------------------------------------------------------
% enable = filtdes('selection',verb.action,msg,SPTfig)
%  respond to selection change in SPTool
% possible actions are
%    'create'  - New Design button - always enabled
%    'change'  - Edit Design button - enabled when 
%      there is a filter selected which is a valid design
case 'selection'
    msg = varargin{3};
    SPTfig = varargin{4};
    switch varargin{2}
    case 'create'
        enable = 'on';  % this creates a new design; can always hit this button
        % also need to focus the filtdes on the currently selected filter
        fig = findobj('type','figure','tag','filtdes');
        if ~isempty(fig)  % the filtdes is open
            f = sptool('Filters',0,SPTfig);  % get the selected filters
            %designInd = find(strcmp('design',{f.type}));
            %f = f(designInd);
            
            ud = get(fig,'userdata');
            
            varargout{1} = enable;
            
            if isequal(ud.filt,f)
                set(ud.ht.filtMenu,'string',{f.label},...
                    'value',find(strcmp({f.label},ud.filt.label)))
                return
            end

            if isempty(f) & isempty(ud.filt)  % empty designer and no change
                return
            end
            
            if isempty(f)  % "clear" filtdes state
                ud = get(fig,'userdata');
                
                % instead of deleting all objects, just make them
                % invisible
                objCell = {ud.Objects.fdspec ud.Objects.fdax ...
                           ud.Objects.fdline ud.Objects.fdmeas};
                for j=1:length(objCell)
                    for i=1:length(objCell{j})
                        set(objCell{j}(i),'visible','off')
                    end
                end
                
                ud.filt = [];
                set(fig,'userdata',ud)
                set(ud.ht.filtMenu,'string',{'<no filters>'},'value',1)
                set(ud.ht.FsEdit,'enable','off','string','-')
                set([ud.ht.autoDesign ud.ht.filtMenu ud.ht.modulePopup ...
                     ud.toolbar.overlay],'enable','off')
                return
                
            elseif ~isempty(ud.filt) & ~isempty(f)
                ni = find(strcmp(ud.filt.label,{f.label})); % new index of
                          % previously selected filter with same name
                if ~isempty(ni)
                    % we may not have to do anything here if the same
                    % exact filter was selected.
                    % before comparison, copy fields that filtview may 
                    % have changed but filtdes doesn't care about:
                    ud.filt.imp   = f(ni).imp;
                    ud.filt.step  = f(ni).step;
                    ud.filt.t     = f(ni).t;
                    ud.filt.H     = f(ni).H;
                    ud.filt.G     = f(ni).G;
                    ud.filt.f     = f(ni).f;
                    ud.filt.zpk   = f(ni).zpk;
                    ud.filt.lineinfo = f(ni).lineinfo;
                    if isequal(f(ni),ud.filt)
                        set(ud.ht.filtMenu,'string',{f.label},'value',ni)
                        return
                    end
                else
                    ni = 1;
                end
            else
                % ud.filt is empty, coming from empty state
                ni = 1;
                set(ud.ht.FsEdit,'enable','on')
                set([ud.ht.autoDesign ud.ht.filtMenu ud.ht.modulePopup ...
                     ud.toolbar.overlay],'enable','on')
            end
            
            switch msg
            case 'label'
                set(ud.ht.filtMenu,'string',{f.label})
            case 'Fs'
                %if strcmp(f.type,'design')
                filtdes('Fsedit',f.Fs,fig)
                %end
            otherwise        
                filtdes('setfilt',f(ni),fig)
                set(ud.ht.filtMenu,'string',{f.label},'value',ni)
            end
        end
    case 'change'
        f = sptool('Filters',0,SPTfig);
        if isempty(f)
            enable = 'off';
        else    %  if ~isempty(find(strcmp({f.type},'design')))
            enable = 'on';  % this edits current design
%         else
%             enable = 'off';
        end
    end
    varargout{1} = enable;
    

%------------------------------------------------------------------------
% filtdes('action',verb.action)
%  respond to button push in SPTool
% possible actions are
%    'create'
%    'change'
case 'action'
    switch varargin{2}
    case 'create'
        SPTfig = gcf;
        [err,errstr,struc] = importfilt('make',{1 1 1 sptool('commonFs')});
        struc.type = 'design';
        
        labelList = sptool('labelList',SPTfig);
        [popupString,fields,FsFlag,defaultLabel] = importfilt('fields');
        struc.label = sbswitch('uniqlabel',labelList,defaultLabel);
        
        fig = findobj('type','figure','tag','filtdes');
        if isempty(fig)  % create the filtdes tool if not open
            filtdes(struc)
            fig = findobj(0,'type','figure','tag','filtdes');
            ud = get(fig,'userdata');
            struc = ud.filt;
        else
%             ud = get(fig,'userdata');
%             ud.filt = struc;
%             set(fig,'userdata',ud)
            filtdes('setfilt',struc,fig)
        end
         
        %sptool('import',struc,1)  % puts new struc in SPTool AND
              % focuses filtdes on the struc
        
        % now bring filtdes to the front:
        figure(fig)
        
    case 'change'
        SPTfig = gcf;
        fig = findobj('type','figure','tag','filtdes');
        if isempty(fig)  % create the filtdes tool
            f = sptool('Filters',0);  % get the selected filter
            % designInd = find(strcmp('design',{f.type}));
            % f = f(designInd);
            filtdes(f(1))
            fig = findobj(0,'type','figure','tag','filtdes');
            ud = get(fig,'userdata');
            set(ud.ht.filtMenu,'string',{f.label},'value',1)
        end
        % bring filtdes figure to front:
        figure(fig)
    end
%------------------------------------------------------------------------
%filtdes('setfilt',f,fig)
%  Set filter designer to filter object f
case 'setfilt'
    f = varargin{2};
    fig = varargin{3};
    ud = get(fig,'userdata');
    
    ptr = getptr(fig);
    setptr(fig,'watch')
    
    updateSPToolFlag = 0;
    
    if ~isstruct(f.specs) | ~isfield(f.specs,'currentModule') | ...
        isempty(find(strcmp(ud.modules,f.specs.currentModule)))
        switch f.type
        case 'design'
            f.specs.currentModule = ud.modules{1};
        case 'imported'
            f.specs.currentModule = 'fdpzedit';
        end
        updateSPToolFlag = 1;
    end
    moduleInd = find(strcmp(ud.modules,f.specs.currentModule));
    if ~isequal(ud.currentModule,ud.modules{moduleInd})
        % delete existing objects
        % filtdes('clear',fig)
    end
    set(ud.ht.modulePopup,'value',moduleInd)
    
    [newfilt,errstr] = feval(ud.modules{moduleInd},'init',f);
    
    updateSPToolFlag = updateSPToolFlag | (~isequal(newfilt,f));
    ud = get(fig,'userdata');
    ud.filt = newfilt;
    ud.currentModule = ud.modules{moduleInd};
    if ~strcmp(ud.currentModule,'fdpzedit')
        ud.defaultModeObject = [];
    end
    set(fig,'userdata',ud)
    set(ud.ht.FsEdit,'string',sprintf('%1.5g',ud.filt.Fs))
    if updateSPToolFlag
        ud.filt = importFiltNoLineinfo(ud.filt,1);
        set(fig,'userdata',ud)
    end
    
    if strcmp(ud.currentModule,'fdpzedit')
        if strcmp(get(ud.ht.autoDesign,'enable'),'on')
            ud.saveAutoDesign = get(ud.ht.autoDesign,'value');
            set(fig,'userdata',ud)
        end
        set(ud.ht.autoDesign,'enable','off','value',1)
        set(ud.toolbar.passband,'enable','off')
    else
        set(ud.ht.autoDesign,'enable','on','value',ud.saveAutoDesign)
        set(ud.toolbar.passband,'enable','on')
    end
        
    set(fig,ptr{:})

%------------------------------------------------------------------------
%filtdes('error')
case 'error'
    error(varargin{2})
    
%------------------------------------------------------------------------
%obj = filtdes('findobj','fdspec'|'fdax'|'fdline'|'fdmeas',{prop,val,...})
% find filtdes objects
case 'findobj'
    fig = findobj('tag','filtdes');
    ud = get(fig,'userdata');
    
    switch varargin{2}
    case 'fdspec'
        obj = ud.Objects.fdspec;
    case 'fdax'
        obj = ud.Objects.fdax;
    case 'fdline'
        obj = ud.Objects.fdline;
    case 'fdmeas'
        obj = ud.Objects.fdmeas;
    otherwise
        error('Can only find fdspec, fdax, fdline, or fdmeas')
    end
    
    propIndx = 3;
    while ~isempty(obj) & (length(varargin)>propIndx)
        props = get(obj,varargin{propIndx});
        if length(obj)==1
            props = {props};
        end
        for i = length(obj):-1:1
            if ~isequal(props{i},varargin{propIndx+1})
                obj(i) = [];
            end
        end
        propIndx = propIndx + 2;
    end
    
    varargout{1} = obj;
    
%------------------------------------------------------------------------
%filtdes('fdspec')
case 'fdspec'
    fig = gcbf;
    ud = get(fig,'userdata');

    h = get(ud.Objects.fdspec,'h');
    if length(h) == 1
        h = {h};
    end    
    ind = find([h{:}] == gcbo);
    
    oldval = ud.Objects.fdspec(ind).value;

    % Get new value from edit box and execute the edit box's callback
    userchange(ud.Objects.fdspec(ind));

    if ud.Objects.fdspec(ind).value ~= oldval
        if get(ud.ht.autoDesign,'value') == 1
            filtdes('apply')
        else
            set([ud.ht.revert ud.ht.apply],'enable','on')    
        end
    end
    
%------------------------------------------------------------------------
%filtdes('fdmeas')
case 'fdmeas'
    fig = gcbf;
    ud = get(fig,'userdata');

    h = get(ud.Objects.fdmeas,'h');
    if length(h) == 1
        h = {h};
    end
    ind = find([h{:}] == gcbo);
    
    userchange(ud.Objects.fdmeas(ind));
    
%------------------------------------------------------------------------
% filtdes('apply')  
%  Callback for Apply button
%
case 'apply'
    fig = findobj('tag','filtdes');
    ud = get(fig,'userdata');

    oldptr = getptr(fig);   
    setptr(fig,'watch') 
    newfilt = ud.filt;
    [newfilt, errmsg] = fdutil('callModuleApply',ud.currentModule,newfilt,'button');
    
    if ~isempty(errmsg)
        set(fig,oldptr{:})
        str = sprintf(['Sorry, the desired filter could not be designed.\n' ...
                      'Reverting to the last valid filter.\n' ...
                      'The error message is: \n%s'],errmsg);
        msgbox(str,'Error','error','modal')
        filtdes('revert')
        return
    end
    if ~isequal(ud.filt,newfilt)
        ud.filt = newfilt;
        set(fig,'userdata',ud)
        ud.filt = importFiltNoLineinfo(ud.filt,1);
        set(fig,'userdata',ud)
    end
    
    for i = 1:length(ud.Objects.fdspec)
        ud.Objects.fdspec(i).revertvalue = ud.Objects.fdspec(i).value;
    end
    set([ud.ht.revert ud.ht.apply],'enable','off')    
    set(fig,oldptr{:})

%------------------------------------------------------------------------
% filtview('revert')
%  Callback of Revert button
%
case 'revert'
    fig = findobj('tag','filtdes');
    ud = get(fig,'userdata');
    
    for i = 1:length(ud.Objects.fdspec)
        ud.Objects.fdspec(i).value = ud.Objects.fdspec(i).revertvalue;
    end
    set([ud.ht.revert ud.ht.apply],'enable','off')    
    
    feval(ud.currentModule,'revert');
    
%------------------------------------------------------------------------
% filtview('Fsedit')
%  Callback of Sampling frequency edit box
% filtview('Fsedit',Fs)
%  Pass argument Fs to change this filter's sampling frequency
case 'Fsedit'
    fig = findobj('type','figure','tag','filtdes');
    ud = get(fig,'userdata');
    
    if nargin>1
        val = varargin{2};
        errstr = '';
    else
        [val,errstr] = fdutil('fdvalidstr',...
               get(ud.ht.FsEdit,'string'),0,0,[0 Inf],[0 0]);
    end
    
    if ~isempty(errstr)
        msgbox(errstr,'Error','error','modal')
    elseif ud.filt.Fs ~= val
        oldFs = ud.filt.Fs;
        ud.filt.Fs = val;
        set(fig,'userdata',ud)
        newfilt = feval(ud.currentModule,'Fs',ud.filt,oldFs);
        if ~isequal(ud.filt,newfilt)
            ud = get(fig,'userdata');
            ud.filt = newfilt;
            set(fig,'userdata',ud)
            ud.filt = importFiltNoLineinfo(ud.filt); 
            set(fig,'userdata',ud)
            % since Fs was either changed by the user in filtdes, or the change
            % in SPTool to Fs resulted in a change to the ud.filt besides
            %  ud.filt.Fs
        elseif nargin == 1
            set(fig,'userdata',ud)
            ud.filt = importFiltNoLineinfo(ud.filt,1); 
            set(fig,'userdata',ud)
            % since Fs was changed by user in filtdes
        end
    end
    set(ud.ht.FsEdit,'string',sprintf('%1.5g',ud.filt.Fs))
   
%------------------------------------------------------------------------
% filtview('SPTclose')
%   closerequestfcn of figure, and also called when SPTool closes
%
case 'SPTclose'
    fig = findobj('type','figure','tag','filtdes');
    if ~isempty(fig)
        ud = get(fig,'userdata');
        fcnList = inmem;  % only unlock the modules which are loaded
                          % (in case a clear has taken place)
        for i=1:length(ud.modules)
            if ~isempty(find(strcmp(fcnList,ud.modules{i})))
                munlock(ud.modules{i})  % allow modules to be cleared
            end
        end
        delete(fig)
    end
       
%------------------------------------------------------------------------
% filtview('overlay')
%  Callback of Overlay Spectrum... button
%
case 'overlay'
    fig = gcbf;
    ud = get(fig,'userdata');

    if ud.pointer==2   % help mode
        spthelp('exit','overlay')
        return
    end

    s = sptool('Spectra');
    if isempty(s)
        str = {'<none>'};
    else
        str = {'<none>' s.label};
    end
    [ind,OK] = listdlg('Name','Overlay Spectrum',...
                  'PromptString',{'Select a spectrum: ',''},...
                  'SelectionMode','single',...
                  'OKString','OK',...
                  'ListString',str);
    if OK
        if ind == 1
            s = [];
        else
            s = s(ind-1);
        end
        ax = ud.Objects.fdax;
        for i=1:length(ax)
            overlay(ax(i),s)
        end
    end
    
%------------------------------------------------------------------------
% filtview('filtmenu')
%  Callback of filter selection popup
%
case 'filtmenu'
    fig = gcbf;
    ud = get(fig,'userdata');
   
    filtMenuString = get(ud.ht.filtMenu,'string');
    newfiltLabel = filtMenuString{get(ud.ht.filtMenu,'value')};
    if strcmp(ud.filt.label,newfiltLabel)
       % no change
        return
    end
   
    f = sptool('Filters',0);  % get selected filters from SPTool
    f = f(find(strcmp(newfiltLabel,{f.label})));
   
    filtdes('setfilt',f,fig)
   
%------------------------------------------------------------------------
%filtdes('autodesignCB')
%  Callback of autodesign check box
case 'autodesignCB'
    fig = findobj('tag','filtdes');
    ud = get(fig,'userdata');
    
    if get(ud.ht.autoDesign,'value')==1
        % auto design turned on
        if strcmp(get(ud.ht.apply,'enable'),'on')
            filtdes('apply')
        end
    end
    
    ud = get(fig,'userdata');
    ud.saveAutoDesign = get(ud.ht.autoDesign,'value');
    set(fig,'userdata',ud)
    
%------------------------------------------------------------------------
%filtdes('modulepopup')
%  callback of module list popup
case 'modulepopup'
    fig = findobj('tag','filtdes');
    ud = get(fig,'userdata');

    newModule = ud.modules{get(gcbo,'value')};
    if strcmp(ud.currentModule,newModule)
        % no change!
        return
    end
    
    % allow module to prompt user and cancel if desired
    cancel = eval(...
        ['eval(''' ud.currentModule '(''''disallowModuleChange'''',ud.filt)'')'],...
        '0');
    if isequal(cancel,1)
        val = find(strcmp(ud.modules,ud.currentModule));
        set(ud.ht.modulePopup,'value',val)
        return
    end
    
    ptr = getptr(fig);
    setptr(fig,'watch'), drawnow
    
    [newfilt,errstr] = feval(newModule,'init',ud.filt);
    drawnow
    
    set(fig,ptr{:})
        
    ud = get(fig,'userdata');
    ud.filt = newfilt;
    ud.currentModule = newModule;
    ud.filt.specs.currentModule = ud.currentModule;
    ud.defaultModeObject = [];
        
    set(fig,'userdata',ud)
    ud.filt = importFiltNoLineinfo(ud.filt); 
    set(fig,'userdata',ud)
    sptool('import',ud.filt,1)

    for i = 1:length(ud.Objects.fdspec)
        ud.Objects.fdspec(i).revertvalue = ud.Objects.fdspec(i).value;
    end
    if strcmp(ud.currentModule,'fdpzedit') & strcmp(get(ud.ht.autoDesign,'enable'),'on')
        ud.saveAutoDesign = get(ud.ht.autoDesign,'value');
        set(fig,'userdata',ud)
        set(ud.ht.autoDesign,'enable','off','value',1)
        set(ud.toolbar.passband,'enable','off')
    else
        set(ud.ht.autoDesign,'enable','on','value',ud.saveAutoDesign)
        set(ud.toolbar.passband,'enable','on')
    end
    set([ud.ht.revert ud.ht.apply],'enable','off')    

%------------------------------------------------------------------------
%filtdes('clear',fig)
%  deletes all fd objects from filtdes figure
%  SIDE EFFECT: writes userdata of fig
%  fig is optional, found with findobj if omitted
case 'clear'
    if nargin < 2
        fig = findobj('tag','filtdes');
    else
        fig = varargin{2};
    end

    ud = get(fig,'userdata');
    
    % delete all objects of current module:
    delete(ud.Objects.fdspec)
    delete(ud.Objects.fdmeas)
    % lines will be deleted when axes are deleted
    delete(ud.Objects.fdax)
    
%------------------------------------------------------------------------
%filtdes('lineclick')
%  buttondownfcn of an fdline object
%  call appropriate callback and perform vertex or segment drag
case 'lineclick'
    h = varargin{2};
    ax = get(h,'parent');
    fig = get(ax,'parent');
    
    if justzoom(fig)
        return
    end
    ud = get(fig,'userdata');    
    switch ud.pointer
    case 2  % display help for this line
        disp('help for this line!')
        return
    case 3  % module specific mode: call module with 'modebuttondownmsg'
        str = ud.modeObject.modebuttondownmsg;
        if ~isempty(str)
            feval(ud.currentModule,ud.modeObject.modebuttondownmsg,h)
        end
        return
    end
    
    lineud = get(h,'userdata');
    
    pt = get(ax,'currentpoint');
    pt = pt(1,1:2);
    xd = get(h,'xdata');
    yd = get(h,'ydata');

    % convert xd and yd to pixel units
    % ASSUMPTION: both xscale and yscale are linear (NOT log)
    xlim = get(ax,'xlim');
    ylim = get(ax,'ylim');
    pos = get(ax,'position');  % assumed in pixels
    xscale = pos(3)/diff(xlim); % number of pixels per x axis units
    yscale = pos(4)/diff(ylim); % number of pixels per y axis units
    
    [vertexFlag,dist,ind,segdist,segind] = ...
        closestpoint(pt,h,xscale,yscale,xd,yd);
        
    if vertexFlag
      % fprintf(1,'line click - vertex %g: (%g,%g); pix dist: %g\n',...
      %    ind,xd(ind),yd(ind),dist)
    else
      % fprintf(1,'line click - segment %g: (%g,%g) to (%g,%g); pix dist: %g\n',...
      %    segind,xd(segind),yd(segind),xd(segind+1),yd(segind+1),segdist)
    end
    
    evalin('base',lineud.buttondownfcn)

    autoDesign = get(ud.ht.autoDesign,'value');
    
    % create object corresponding to this line handle - this will
    % be used when calling module's apply callback
    L.h = h;
    L = fdline(L);

    errstr = '';    
    newfiltFlag = 0;        
    newfilt = ud.filt;
    if vertexFlag
    % handle vertex drag
        if length(lineud.vertexdragmode)>1
            vertexdragmode = lineud.vertexdragmode{ind};
        else
            vertexdragmode = lineud.vertexdragmode{1};
        end
        switch vertexdragmode
        case 'none'
            if ~isempty(lineud.buttonupfcn)
                uiwaitforButtonUp(fig)
                evalin('base',lineud.buttonupfcn)
            end
            return
        case 'lr'
            cx = 0;  % "constrain x"
            cy = 1;  % "constrain y"
        case 'ud'
            cx = 1;
            cy = 0;
        case 'both'
            cx = 0;
            cy = 0;
        end
        
        if length(lineud.vertexdragcallback)>1
            vertexdragcallback = lineud.vertexdragcallback{ind};
        else
            vertexdragcallback = lineud.vertexdragcallback{1};
        end

        global fd_line_motion_message
        save_wbmf = get(fig,'windowbuttonmotionfcn');
        set(fig,'windowbuttonmotionfcn', {@lclmotionfcn, fig});
        set(fig,'windowbuttonupfcn',     {@lclupfcn,     fig});
       
       done = 0;
       while ~done
           uiwait(fig)
           switch fd_line_motion_message
               case 'motion'
                   pt_new = get(ax,'currentpoint');
                   xd = get(h,'xdata');
                   yd = get(h,'ydata');
                   L.delayrender = 'on';
                   if ~cx & (pt_new(1,1) ~= xd(ind))
                       xd(ind) = pt_new(1,1);
                       set(L,'xdata',xd)
                   end
                   if ~cy & (pt_new(1,2) ~= yd(ind))
                       yd(ind) = pt_new(1,2);
                       set(L,'ydata',yd)
                   end
                   evalin('base',vertexdragcallback)
                   if autoDesign
                       % design filter!
                       oldptr = getptr(fig);   
                       setptr(fig,'watch') 
                       [newfilt, errstr] = fdutil('callModuleApply',...
                           ud.currentModule,newfilt,...
                           'motion',L);
                       if isempty(errstr) & ~isequal(ud.filt,newfilt)
                           newfiltFlag = 1;
                           set([ud.ht.revert ud.ht.apply],'enable','off')
                       elseif ~isempty(errstr)
                           break
                       end
                       set(fig,oldptr{:}) 
                   end
                   L.delayrender = 'off';
               case 'up'
                   done = 1;
           end
       end
       
        % don't need to design if last motion function
        % already did so, unless this is the pole/zero editor
        if ~autoDesign | strcmp(ud.currentModule,'fdpzedit')
            % design filter
            oldptr = getptr(fig);   
            setptr(fig,'watch') 
            [newfilt, errstr] = fdutil('callModuleApply',...
                                   ud.currentModule,newfilt,'up',L);
            if isempty(errstr) & ~isequal(ud.filt,newfilt)
                newfiltFlag = 1;
                set([ud.ht.revert ud.ht.apply],'enable','off')    
            end
            set(fig,oldptr{:}) 
        end
        
        if length(lineud.vertexenddragcallback)>1
            vertexenddragcallback = lineud.vertexenddragcallback{ind};
        else
            vertexenddragcallback = lineud.vertexenddragcallback{1};
        end
        evalin('base',vertexenddragcallback)
        
        set(fig,'windowbuttonmotionfcn',save_wbmf)
        set(fig,'windowbuttonupfcn','')
        clear global fd_line_motion_message
    else
    % handle segment drag
        if length(lineud.segmentdragmode)>1
            segmentdragmode = lineud.segmentdragmode{segind};
        else
            segmentdragmode = lineud.segmentdragmode{1};
        end
        switch segmentdragmode
        case 'none'
            if ~isempty(lineud.buttonupfcn)
                uiwaitforButtonUp(fig)
                evalin('base',lineud.buttonupfcn)
            end
            return
        case 'lr'
            cx = 0;  % "constrain x"
            cy = 1;  % "constrain y"
        case 'ud'
            cx = 1;
            cy = 0;
        case 'both'
            cx = 0;
            cy = 0;
        end
        
        if length(lineud.segmentdragcallback)>1
            segmentdragcallback = lineud.segmentdragcallback{segind};
        else
            segmentdragcallback = lineud.segmentdragcallback{1};
        end

        global fd_line_motion_message
        save_wbmf = get(fig,'windowbuttonmotionfcn');
        set(fig,'windowbuttonmotionfcn',...
           ['global fd_line_motion_message, fd_line_motion_message = '...
            '''motion''; uiresume'] );
        set(fig,'windowbuttonupfcn',...
           ['global fd_line_motion_message, fd_line_motion_message = '...
            '''up''; uiresume']);

        % find place along line segment
        % assume that line segment's length and slope will not
        % change during drag
        seg_x = xd(segind+[0 1]);
        if isnan(diff(seg_x)) % Avoid math on NaN; causes warnings on PCWIN
            alfa_x = 1;
        elseif diff(seg_x)~=0
            alfa_x = (pt(1,1)-seg_x(1))/(diff(seg_x));
            alfa_x = max(0,min(alfa_x,1));
        else
            alfa_x = 0;
        end
        seg_y = yd(segind+[0 1]);
        if isnan(diff(seg_y)) % Avoid math on NaN; causes warnings on PCWIN
            alfa_y = 1;
        elseif diff(seg_y)~=0
            alfa_y = (pt(1,2)-seg_y(1))/(diff(seg_y));
            alfa_y = max(0,min(alfa_y,1));
        else
            alfa_y = 0;
        end

        if (alfa_x==0) & (alfa_y==0)
            % Avoid dividing by zero; causes warnings on PCWIN.  Also, alfa
            % can't be NaN - if alfa = NaN the passband specs line will
            % become invisible (data set to NaNs) which causes Rp=NaN.
            alfa = 0;
        else
            alfa = sqrt(alfa_x^2 + alfa_y^2)/sqrt(sum([alfa_x>0 alfa_y>0]));
        end        
    
        done = 0;
        while ~done
            uiwait(fig)
            switch fd_line_motion_message
            case 'motion'
                pt_new = get(ax,'currentpoint');
                xd = get(h,'xdata');
                yd = get(h,'ydata');
                seg_x = xd(segind+[0 1]);
                seg_y = yd(segind+[0 1]);
                % find point on current segment that is alfa between 
                % the first point of the segment and second point
                pt = (1-alfa)*[seg_x(1) seg_y(1)] + alfa*[seg_x(2) seg_y(2)];
                L.delayrender = 'on';
                if ~cx & (pt_new(1,1) ~= pt(1,1))
                    xd(segind+[0 1]) = seg_x + pt_new(1,1) - pt(1,1);
                    set(L,'xdata',xd)
                end
                if ~cy & (pt_new(1,2) ~= pt(1,2))
                    yd(segind+[0 1]) = seg_y + pt_new(1,2) - pt(1,2);
                    set(L,'ydata',yd)
                end
                evalin('base',segmentdragcallback)
                if autoDesign
                    % design filter!
                    oldptr = getptr(fig);   
                    setptr(fig,'watch') 
                    [newfilt, errstr] = fdutil('callModuleApply',...
                                        ud.currentModule,newfilt,...
                                        'motion',L);
                    if isempty(errstr) & ~isequal(ud.filt,newfilt)
                        newfiltFlag = 1;
                        set([ud.ht.revert ud.ht.apply],'enable','off')    
                    elseif ~isempty(errstr)
                        break
                    end
                    set(fig,oldptr{:}) 
                end
                L.delayrender = 'off';
%                 drawnow
            case 'up'
                done = 1;
            end
        end
        
        if ~autoDesign  % don't need to design if last motion function
                        % already did so
            % design filter
            oldptr = getptr(fig);   
            setptr(fig,'watch') 
            [newfilt, errstr] = fdutil('callModuleApply',...
                                   ud.currentModule,newfilt,'up',L);
            if isempty(errstr) & ~isequal(ud.filt,newfilt)
                newfiltFlag = 1;
                set([ud.ht.revert ud.ht.apply],'enable','off')    
            end
            set(fig,oldptr{:}) 
        end
        
        if length(lineud.segmentenddragcallback)>1
            segmentenddragcallback = lineud.segmentenddragcallback{segind};
        else
            segmentenddragcallback = lineud.segmentenddragcallback{1};
        end
        evalin('base',segmentenddragcallback)
        
        
        set(fig,'windowbuttonmotionfcn',save_wbmf)
        set(fig,'windowbuttonupfcn','')
        clear global fd_line_motion_message
    end
    
    if ~isempty(lineud.buttonupfcn)
        evalin('base',lineud.buttonupfcn)
    end
    
    if ~isempty(errstr)
        msgstr = {'Sorry, this filter could not be designed.' 
                  'Reverting to last valid filter.' 
                  'Error message:' 
                  errstr};
        msgbox(msgstr,'Error',...
               'error','modal')
        filtdes('revert')
        return
    end
    
    if newfiltFlag
        ud = get(fig,'userdata');
        ud.filt = newfilt;
        set(fig,'userdata',ud)
        ud.filt = importFiltNoLineinfo(ud.filt,1);
        set(fig,'userdata',ud)
        for i = 1:length(ud.Objects.fdspec)
            ud.Objects.fdspec(i).lastvalue = ud.Objects.fdspec(i).value;
            ud.Objects.fdspec(i).revertvalue = ud.Objects.fdspec(i).value;
        end
    end
    
%-------------------------------------------------------------------
% enable = filtdes('autodesign',fig)
%   Returns value of AutoDesign checkbox (1 or 0)
%   fig is optional; if not supplied, it is found using findobj
%
case 'autodesign'
    if nargin < 2
        fig = findobj('tag','filtdes');
    else
        fig = varargin{2};
    end
    ud = get(fig,'userdata');
    
    varargout{1} = get(ud.ht.autoDesign,'value'); 
    
%-------------------------------------------------------------------
% enable = filtdes('getenable',fig)
%   Returns 'on' or 'off' based on apply button's enable property
%   fig is optional; if not supplied, it is found using findobj
%
case 'getenable'
    if nargin < 2
        fig = findobj('tag','filtdes');
    else
        fig = varargin{2};
    end
    ud = get(fig,'userdata');
    
    varargout{1} = get(ud.ht.apply,'enable'); 
    
%-------------------------------------------------------------------
% filtdes('setenable',enable,fig)
%   Set revert and apply button's enable properties
%   fig is optional; if not supplied, it is found using findobj
case 'setenable'
    if nargin < 3
        fig = findobj('tag','filtdes');
    else
        fig = varargin{3};
    end
    ud = get(fig,'userdata');

    switch varargin{2}
    case 'on'
        if get(ud.ht.autoDesign,'value')==1
            filtdes('apply')
        else
            set([ud.ht.revert ud.ht.apply],'enable',varargin{2})
        end
    case 'off'
        set([ud.ht.revert ud.ht.apply],'enable',varargin{2})
    otherwise
        error('enable property of filtdes must be ''on'' or ''off''')
    end
%------------------------------------------------------------------------
%filtdes('zoom',button)
%  zoom function for filtdes
%   button is a string and can be any of:
%     mousezoom, zoomout, zoominy, zoomouty, zoominx,
%          zoomoutx, or passband
case 'zoom'

    if nargin < 3
        fig = gcbf;
    else
        fig = varargin{3};
    end
    ud = get(fig,'userdata');
    

    if ud.pointer == 0
        state = strcmp(get(ud.toolbar.mousezoom,'state'),'on');
        if strcmp(varargin{2},'mousezoom') & state
            if ~isempty(ud.defaultModeObject)   
            % entering mousezoom mode - need to leave default mode
                ud.defaultModeObject.value = 0;
            end
        end
    elseif ud.pointer==2   % help mode
        if strcmp(varargin{2},'mousezoom')
            state = strcmp(get(ud.toolbar.mousezoom,'state'),'on');
            % toggle button state back to the way it was:
            if state
                set(ud.toolbar.mousezoom,'state','off')
            else
                set(ud.toolbar.mousezoom,'state','on')
            end
        end
        spthelp('exit','fdzoom',varargin{2})
        if ~isempty(ud.defaultModeObject)  % return to 'default mode'
                                           % if defined
            ud.defaultModeObject.value = 1;
        end
        return
    elseif ud.pointer == 3  % module specific mode
        state = strcmp(get(ud.toolbar.mousezoom,'state'),'on');
        if strcmp(varargin{2},'mousezoom') & state
        % entering mousezoom mode - need to leave mod. specific mode
            ud.modeObject.value = 0;
            str = ud.modeObject.leavemodecallback;
            if ~isempty(str)
                feval(ud.currentModule,str,ud.modeObject)
            end
            ud = get(fig,'userdata');
        end
    end    
    
    switch varargin{2}
    case 'mousezoom'
        state = strcmp(get(ud.toolbar.mousezoom,'state'),'on');
        if state == 1   % button is currently down
            set(fig,'windowbuttondownfcn','filtdes(''zoom'',''mousedown'')')
            ud.pointer = 1;  
            set(fig,'userdata',ud)
            setptr(fig,'arrow')
        else   % button is currently up - turn off zoom mode
            set(fig,'windowbuttondownfcn','filtdes(''down'')')
            if ~isempty(ud.defaultModeObject)
                ud.defaultModeObject.value = 1;
            else
                setptr(fig,'arrow')
                ud.pointer = 0;
                set(fig,'userdata',ud)
            end
        end

    case 'mousedown'  % this is a self callback prompted by a mouse click
                      % in the figure while the mousezoom button is down
        ud.justzoom = get(fig,'currentpoint');
        set(fig,'userdata',ud)

        pstart = get(fig,'currentpoint');

        % don't do anything if click is outside axes area
        fp = get(fig,'position');   % in pixels already
    
        afp = get(ud.ht.axFrame,'position');
        
        %click is outside of axes frame panel:
        if ~pinrect(pstart,[afp(1) afp(1)+afp(3) afp(2) afp(2)+afp(4)])
            return
        end

        r = rbbox([pstart 0 0],pstart);

        % Find out which axes was clicked in according to rules:
        % rule 1: click inside an axes - zoom in that axes
        % rule 2: current point is not in any axes - zoom in on axes most
        %         overlapping dragged rectangle
        
        if isempty(ud.Objects.fdax)
            return
        end
        
        % Convert object array of handles to a vector of handles.
        open_axes = obj2vect(ud.Objects.fdax,'h');

        rects = [];
        target_axes = [];
        for i=1:length(open_axes)
            rects = [rects; get(open_axes(i),'position')];
            if pinrect(pstart,rects(i,[1 1 2 2])+[0 rects(i,3) 0 rects(i,4)])
                target_axes = open_axes(i);
            end
        end    
        if isempty(target_axes)
            overlap = rectint(r,rects);
            overlap = overlap(:)...
                  ./ (rects(:,3).*rects(:,4));
                % what percentage of the area of the axis is 
                %  covered by the dragged out rectangle?
            [maxoverlap,k] = max(overlap);
            if maxoverlap > 0
                target_axes = open_axes(k);
            end
        end

        if isempty(target_axes)
            return   % stay in zoom mode and return
        end
        oldxlim = get(target_axes,'xlim');
        oldylim = get(target_axes,'ylim');
    
        if all(r([3 4])==0)
        % just a click - zoom about that point
             p1 = get(target_axes,'currentpoint');

             xlim = get(target_axes,'xlim');
             ylim = get(target_axes,'ylim');

             switch get(fig,'selectiontype')
             case 'normal'     % zoom in
                 xlim = p1(1,1) + [-.25 .25]*diff(xlim);
                 ylim = p1(1,2) + [-.25 .25]*diff(ylim);
             otherwise    % zoom out
                 xlim = p1(1,1) + [-1 1]*diff(xlim);
                 ylim = p1(1,2) + [-1 1]*diff(ylim);
             end
        
        elseif any(r([3 4])==0)  
        % zero width or height - stay in zoom mode and 
        % try again
            return

        else
        % zoom to the rectangle dragged
            set(fig,'currentpoint',[r(1) r(2)])
            p1 = get(target_axes,'currentpoint');
            set(fig,'currentpoint',[r(1)+r(3) r(2)+r(4)])
            p2 = get(target_axes,'currentpoint');
        
            xlim = [p1(1,1) p2(1,1)];
            ylim = [p1(1,2) p2(1,2)];
        end

        axesIndex = find(target_axes == open_axes);
        xlimbound = ud.Objects.fdax(axesIndex).xlimbound;
        ylimbound = ud.Objects.fdax(axesIndex).ylimbound;
        if ~isstr(xlimbound)
            xlim = inbounds(xlim,xlimbound);
        end
        if ~isstr(ylimbound)
            ylim = inbounds(ylim,ylimbound);
        end
        % retain full axes position in case aspectmode is 'equal',
        % by growing limits in appropriate direction:
        axUD = get(target_axes,'userdata');
        if strcmp(axUD.aspectmode,'equal')
            apos = get(target_axes,'Position');
            %set(get(target_axes,'xlabel'),'userdata',[newxlim newylim]);
            [xlim,ylim] = newlims(apos,xlim,ylim);
        end
        
        set(target_axes,'xlim',xlim,'ylim',ylim)
        
        if ~ud.prefs.tool.zoompersist
            set(fig,'windowbuttondownfcn','filtdes(''down'')')
            set(ud.toolbar.mousezoom,'state','off')
            if ~isempty(ud.defaultModeObject)
                ud.defaultModeObject.value = 1;
            else
                setptr(fig,'arrow')
                ud.pointer = 0;
                set(fig,'userdata',ud)
            end
        end
        
        set(fig,'currentpoint',ud.justzoom)

    case 'zoomout'
        if isempty(ud.Objects.fdax)
            return
        end

        % Convert object array of handles to a vector of handles.
        open_axes = obj2vect(ud.Objects.fdax,'h');

        for i=1:length(open_axes)
            % temporarily hide lines which don't affect limit calculations
            L = filtdes('findobj','fdline','parent',open_axes(i),...
                    'affectlimits','off');
                
            % Convert object array of handles to a vector of handles.
            Lh = obj2vect(L,'h');
            
            saveVis = get(Lh,'visible');
            set(Lh,'visible','off')
            if isstr(ud.Objects.fdax(i).xlimbound)
                set(open_axes(i),'dataaspectratiomode','auto',...
                                 'plotboxaspectratiomode','auto',...
                                 'xlimmode','auto')
                set(open_axes(i),'xlim',get(open_axes(i),'xlim'))
            else
                set(open_axes(i),'xlim',ud.Objects.fdax(i).xlimbound)
            end
            if isstr(ud.Objects.fdax(i).ylimbound)
                set(open_axes(i),'dataaspectratiomode','auto',...
                                 'plotboxaspectratiomode','auto',...
                                 'ylimmode','auto')
                set(open_axes(i),'ylim',get(open_axes(i),'ylim'))
            else
                set(open_axes(i),'ylim',ud.Objects.fdax(i).ylimbound)
            end
            if ~iscell(saveVis)
                saveVis = {saveVis};
            end
            set(Lh,{'visible'},saveVis)
            if strcmp(ud.Objects.fdax(i).aspectmode,'equal')
                xlim = get(open_axes(i),'xlim');
                ylim = get(open_axes(i),'ylim');
                apos = get(open_axes(i),'Position');
                [xlim,ylim] = newlims(apos,xlim,ylim);
                set(open_axes(i),'xlim',xlim,'ylim',ylim)
            end
        end
    case 'zoominy'
        if isempty(ud.Objects.fdax)
            return
        end

        % Convert object array of handles to a vector of handles.
        open_axes = obj2vect(ud.Objects.fdax,'h');

        for i=1:length(open_axes)
            ylim = get(open_axes(i),'ylim');
            newylim = .25*[3 1]*ylim' + [0 diff(ylim)/2];
            if diff(newylim) > 0
                objUD = get(open_axes(i),'userdata');
                if strcmp(objUD.aspectmode,'equal')
                    % to zoom in y when aspectmode is equal, need to zoom in both x and y
                    xlim = get(open_axes(i),'xlim');
                    newxlim = .25*[3 1]*xlim' + [0 diff(xlim)/2];
                    if diff(newxlim) <= 0
                        newxlim = xlim;
                    end
                    apos = get(open_axes(i),'Position');
                    [newxlim,newylim] = newlims(apos,newxlim,newylim);
                    set(open_axes(i),'xlim',newxlim,'ylim',newylim)
                else
                    set(open_axes(i),'ylim',newylim)
                end
            end
        end
    case 'zoomouty'
        if isempty(ud.Objects.fdax)
            return
        end

        % Convert object array of handles to a vector of handles.
        open_axes = obj2vect(ud.Objects.fdax,'h');
        
          for i=1:length(open_axes)
            ylim = get(open_axes(i),'ylim');
            ylim = .5*[3 -1]*ylim' + [0 diff(ylim)*2];
            ylimbound = ud.Objects.fdax(i).ylimbound;
            if ~isstr(ylimbound)
                ylim = [max(ylim(1),ylimbound(1)) min(ylim(2),ylimbound(2))];
            end
            objUD = get(open_axes(i),'userdata');
            if strcmp(objUD.aspectmode,'equal')
                % to zoom out y when aspectmode is equal, need to zoom out both x and y
                xlim = get(open_axes(i),'xlim');
                newxlim = .5*[3 -1]*xlim' + [0 diff(xlim)*2];
                xlimbound = ud.Objects.fdax(i).xlimbound;
                if ~isstr(xlimbound)
                    newxlim = [max(newxlim(1),xlimbound(1)) min(newxlim(2),xlimbound(2))];
                end
                apos = get(open_axes(i),'Position');
                [newxlim,newylim] = newlims(apos,newxlim,ylim);
                set(open_axes(i),'xlim',newxlim,'ylim',newylim)
            else
                set(open_axes(i),'ylim',ylim)
            end
        end
    case 'zoominx'
        if isempty(ud.Objects.fdax)
            return
        end

        % Convert object array of handles to a vector of handles.
        open_axes = obj2vect(ud.Objects.fdax,'h');

        for i=1:length(open_axes)
            xlim = get(open_axes(i),'xlim');
            newxlim = .25*[3 1]*xlim' + [0 diff(xlim)/2];
            if diff(newxlim) > 0
                objUD = get(open_axes(i),'userdata');
                if strcmp(objUD.aspectmode,'equal')
                    % to zoom in x when aspectmode is equal, need to zoom in both x and y
                    ylim = get(open_axes(i),'ylim');
                    newylim = .25*[3 1]*ylim' + [0 diff(ylim)/2];
                    if diff(newylim) <= 0
                        newylim = ylim;
                    end
                    apos = get(open_axes(i),'Position');
                    [newxlim,newylim] = newlims(apos,newxlim,newylim);
                    set(open_axes(i),'xlim',newxlim,'ylim',newylim)
                else
                    set(open_axes(i),'xlim',newxlim)
                end
            end
        end
    case 'zoomoutx'
        if isempty(ud.Objects.fdax)
            return
        end

        % Convert object array of handles to a vector of handles.
        open_axes = obj2vect(ud.Objects.fdax,'h');

        for i=1:length(open_axes)
            xlim = get(open_axes(i),'xlim');
            xlim = .5*[3 -1]*xlim' + [0 diff(xlim)*2];
            xlimbound = ud.Objects.fdax(i).xlimbound;
            if ~isstr(xlimbound)
                xlim = [max(xlim(1),xlimbound(1)) min(xlim(2),xlimbound(2))];
            end
            objUD = get(open_axes(i),'userdata');
            if strcmp(objUD.aspectmode,'equal')
                % to zoom out y when aspectmode is equal, need to zoom out both x and y
                ylim = get(open_axes(i),'ylim');
                newylim = .5*[3 -1]*ylim' + [0 diff(ylim)*2];
                ylimbound = ud.Objects.fdax(i).ylimbound;
                if ~isstr(ylimbound)
                    newylim = [max(newylim(1),ylimbound(1)) min(newylim(2),ylimbound(2))];
                end
                apos = get(open_axes(i),'Position');
                [newxlim,newylim] = newlims(apos,xlim,newylim);
                set(open_axes(i),'xlim',newxlim,'ylim',newylim)
            else
                set(open_axes(i),'xlim',xlim)
            end

        end
        
    case 'passband'
        if isempty(ud.Objects.fdax)
            return
        end

        % Convert object array of handles to a vector of handles.
        open_axes = obj2vect(ud.Objects.fdax,'h');
        
        for i=1:length(open_axes)
            xlimpassband = ud.Objects.fdax(i).xlimpassband;
            if ~isstr(xlimpassband)
                set(open_axes(i),'xlim',xlimpassband)
            end
            ylimpassband = ud.Objects.fdax(i).ylimpassband;
            if ~isstr(ylimpassband)
                set(open_axes(i),'ylim',ylimpassband)
            end
        end
    end
    
%------------------------------------------------------------------------
%filtdes('help')
%  callback of help btn.
% filtdes('help','topics')
%  Callback of 'Help Topics' menu 
% filtdes('help','whatsthis')
%  Callback of 'What's this?' menu
case 'help'

    fig = gcf;
    ud = get(fig,'userdata');
    if ud.pointer ~= 2   % if not in help mode
    
        if ud.pointer == 3  % module specific mode
        % need to leave mod. specific mode
            ud.modeObject.value = 0;
            str = ud.modeObject.leavemodecallback;
            if ~isempty(str)
                feval(ud.currentModule,str,ud.modeObject)
            end
            ud = get(fig,'userdata');
        elseif ud.pointer == 0 & ~isempty(ud.defaultModeObject)
            ud.defaultModeObject.value = 0;
        end

        % enter help mode
        h1 = ud.Objects.fdspec(:).h;
        if length(h1)~=1
            h1 = [h1{:}];
        end
        h2 = ud.Objects.fdmeas(:).h;
        if length(h2)~=1
            h2 = [h2{:}];
        end
        saveEnableControls = [ud.ht.apply
                              ud.ht.revert
                              ud.ht.filtMenu
                              ud.ht.autoDesign
                              ud.ht.FsEdit
                              ud.ht.modulePopup
                              ud.toolbar.overlay
                              h1(:)
                              h2(:)];
        ax = ud.Objects.fdax(:).h;
        if length(ax)~=1
            ax = [ax{:}];
        end
        titleStr = 'Filter Designer Help';
        helpFcn = 'fdhelpstr';
        spthelp('enter',fig,saveEnableControls,ax,titleStr,helpFcn,1)
        
        if nargin > 1  % Called from menu
           set(ud.toolbar.whatsthis,'state','on')
           if strcmp(varargin{2},'topics')
              spthelp('exit')  % just need to exit help mode;
                               %displays general help by default
           end
        end
   
     else
        spthelp('exit')
        ud = get(fig,'userdata');
        if ~isempty(ud.defaultModeObject)  % return to 'default mode'
                                           % if defined
            ud.defaultModeObject.value = 1;
        end
    end

% -------------------------------------------------------------------------
% struc = filtdes('filt')
%   retrieve filter structure from tool
case 'filt'
    shh = get(0,'showhiddenhandles');
    set(0,'showhiddenhandles','on');

    % first, find the tool
    fig = findobj('type','figure','tag','filtdes');
    if isempty(fig)
        set(0,'showhiddenhandles',shh)
        error('No Filter Design Tool is open - can''t get filter.')
    end
    ud=get(fig,'Userdata');

    if nargout >= 1, varargout{1} = ud.filt; end

    set(0,'showhiddenhandles',shh)
    
% -------------------------------------------------------------------------
% [b,a,Fs] = filtdes('getfilt')
%   retrieve filter coefficients from tool
case 'getfilt'
    shh = get(0,'showhiddenhandles');
    set(0,'showhiddenhandles','on');

    % first, find the tool
    fig = findobj('type','figure','tag','filtdes');
    if isempty(fig)
        set(0,'showhiddenhandles',shh)
        error('No Filter Design Tool is open - can''t get coefficients.')
    end
    ud=get(fig,'Userdata');

    Fs = ud.filt.Fs;     % sampling frequency
    b = ud.filt.tf.num;
    a = ud.filt.tf.den;
    if nargout >= 1, varargout{1} = b; end
    if nargout >= 2, varargout{2} = a; end
    if nargout >= 3, varargout{3} = Fs; end

    set(0,'showhiddenhandles',shh)
    
%------------------------------------------------------------------------
% errstr = filtdes('setprefs',panelName,p)
% Set preferences for the panel with name panelName
% Inputs:
%   panelName - string; must be 'filtdes'
%              (see sptprefp for definitions)
%   p - preference structure for this panel
%     p has fields:
%         .nfft   - string - number of points in frequency response 
%                   between 0 and Fs
%         .grid   - can be 0 (grid off) or 1 (grid on), applies to
%                   all fdax objects (both xgrid and ygrid)
%         .AutoDesignInit - initial value for AutoDesign flag
%         .zoomFlag - stay in zoom mode after zoom
case 'setprefs'
    errstr = '';
    panelName = varargin{2};
    p = varargin{3};
    arbitrary_obj = {'arb' 'obj'};
    nfft = evalin('base',p.nfft,'arbitrary_obj');
    if isequal(nfft,arbitrary_obj)
        errstr = 'Sorry, the FFT Length you entered could not be evaluated';
    elseif isempty(nfft) | (round(nfft)~=nfft | nfft<=0 | ~isreal(nfft))
        errstr = ['The FFT Length must be a positive integer.'];
    end
    varargout{1} = errstr;
    if ~isempty(errstr)
        return
    end
    fig = findobj(allchild(0),'tag','filtdes');
    if ~isempty(fig)
        ud = get(fig,'userdata');
        for i=1:length(ud.Objects.fdax)
            if p.grid
                set(ud.Objects.fdax(i),'xgrid','on','ygrid','on')
            else
                set(ud.Objects.fdax(i),'xgrid','off','ygrid','off')
            end
        end
        old_nfft = ud.prefs.nfft;
        ud.prefs.nfft = nfft;
        ud.prefs.grid = p.grid;
        ud.prefs.tool.zoompersist = p.zoomFlag;  
        ud.prefs.AutoDesignInit = p.AutoDesignInit;
        set(fig,'userdata',ud)
        if ud.prefs.nfft ~= old_nfft
            % redesign filter
            filtdes('apply')
        end
    end
    
%------------------------------------------------------------------------
%gridVal = filtdes('grid',fig)
%  returns 'on' or 'off' depending on value of preferences
%  for grids.
%  Input:  fig - handle of filtdes, optional; found with findobj if
%                not passed
case 'grid'
    if nargin > 1
        fig = varargin{2};
    else
        fig = findobj(allchild(0),'tag','filtdes');
    end
    ud = get(fig,'userdata');
    if ud.prefs.grid 
        varargout{1} = 'on';
    else
        varargout{1} = 'off';
    end    
    
%------------------------------------------------------------------------
%nfft = filtdes('nfft',fig)
%  returns nfft, frequency response length
%  Input:  fig - handle of filtdes, optional; found with findobj if
%                not passed
case 'nfft'
    if nargin > 1
        fig = varargin{2};
    else
        fig = findobj(allchild(0),'tag','filtdes');
    end
    ud = get(fig,'userdata');
    varargout{1} = ud.prefs.nfft;

%------------------------------------------------------------------------
%filtdes('resize')
%  filtdes portion of filtdes figure's resizefcn.
case 'resize'
    fig = findobj('tag','filtdes');
    ud = get(fig,'userdata');
    fp = get(fig,'position');
    
    minsize = [516 402];   % minimum [width height], in pixels
    if fp(3)<minsize(1) | fp(4)<minsize(2)
       % figure is too small - resize to minimum size
       w = max(minsize(1),fp(3));
       h = max(minsize(2),fp(4));
       fp = [fp(1) fp(2)+fp(4)-h w h];
       set(fig,'position',fp)
    end
    
    switch computer
    case 'PCWIN'
        popTweak  = [0 3 0 0];
        editTweak = [0 0 0 3];
        txtTweak  = [0 0 0 0];
    case 'MAC2'
        popTweak  = [0 0 0 0];
        editTweak = [0 0 0 0];
        txtTweak  = [0 0 0 0];
    otherwise
        popTweak  = [0 -1 0 2];
        editTweak = [0  0 0 0];
        txtTweak  = [0 -5 0 6];
    end
 
    specWidth = 150;
    
    sz = ud.sz;
    toolbar_ht = sz.ih;
    sfp = [0 0 specWidth fp(4)-toolbar_ht];
    mfp = [fp(3)-specWidth  0  specWidth fp(4)-toolbar_ht];
    afp = [specWidth 0 fp(3)-2*specWidth fp(4)-toolbar_ht];
    tb2fp = [0 sfp(2)+sfp(4) fp(3) toolbar_ht]; % toolbar2 frame position

    % position frames, spec & meas labels, and revert and apply
    set(ud.ht.specFrame,'position',sfp)
    set(ud.ht.axFrame,'position',afp)
    set(ud.ht.measFrame,'position',mfp);
    set(ud.ht.tb2Frame,'position',tb2fp);
    set(ud.ht.specLabel,'position',[sfp(1)+2 sfp(2)+sfp(4)-(sz.uh+sz.fus) ...
                                       sfp(3)-4 sz.uh]);
    set(ud.ht.measLabel,'position',[mfp(1)+2 mfp(2)+mfp(4)-(sz.uh+sz.fus) ...
                                       mfp(3)-4 sz.uh]);
    set(ud.ht.autoDesign,'position',...
        [sfp(1)+2  sfp(2)+2+(sz.uh+sz.fus) sfp(3)-3 sz.uh]+popTweak)
    set(ud.ht.revert,'position',[sfp(1)+2 sfp(2)+2 sfp(3)/2-3 sz.uh]);
    set(ud.ht.apply,'position',[sfp(1)+4+(sfp(3)/2-3) sfp(2)+2 sfp(3)/2-3 sz.uh]);
      
    % position filter selection popup and its label
    set(ud.ht.filtMenuLabel,'position',...
        [sz.fus fp(4)-(sz.ih-sz.uh-sz.lh)/3-sz.lh ...
         specWidth-2*sz.fus sz.lh]+txtTweak)
    set(ud.ht.filtMenu,'position',...
        [sz.fus+2*sz.fus fp(4)-2*(sz.ih-sz.uh-sz.lh)/3-sz.lh-sz.uh ...
         specWidth-3*sz.fus sz.uh]+popTweak)
    
    % position other items in 2nd toolbar:
    algLW = 201;
    set(ud.ht.FsLabel,'position',...
        [tb2fp(1)+specWidth+2*sz.fus ...
         tb2fp(2)+tb2fp(4)-(sz.ih-sz.uh-sz.lh)/3-sz.lh sz.lw sz.lh]+txtTweak)
    set(ud.ht.FsEdit,'position',...
        [tb2fp(1)+specWidth+4*sz.fus ...
         tb2fp(2)+(sz.ih-sz.uh-sz.lh)/3 sz.lw-2*sz.fus sz.uh]+editTweak)
    set(ud.ht.moduleLabel,'position',...
        [tb2fp(1)+specWidth+sz.lw+6*sz.fus...
            tb2fp(2)+tb2fp(4)-(sz.ih-sz.uh-sz.lh)/3-sz.lh ...
            algLW sz.lh]+txtTweak)
    set(ud.ht.modulePopup,'position',...
        [tb2fp(1)+specWidth+sz.lw+8*sz.fus ...
         tb2fp(2)+(sz.ih-sz.uh-sz.lh)/3 algLW-2*sz.fus sz.uh]+popTweak)

    % reposition objects: by simply reassigning their positions, they are
    %  positioned relative to the frames that contain them
    for i = 1:length(ud.Objects.fdspec)
        ud.Objects.fdspec(i).position = ud.Objects.fdspec(i).position;
    end
    for i = 1:length(ud.Objects.fdax)
        ud.Objects.fdax(i).position = ud.Objects.fdax(i).position;
    end
    for i = 1:length(ud.Objects.fdmeas)
        ud.Objects.fdmeas(i).position = ud.Objects.fdmeas(i).position;
    end

otherwise  % evaluate local function
    if (nargout == 0)
        feval(varargin{:});
    else
        [varargout{1:nargout}] = feval(varargin{:});
    end
   
end

%----------------------------------------------------------------------------------
%            ...  SUBFUNCTIONS BELOW THIS POINT...
        
function d = segmentDistance(p,xd,yd)
% returns distance from pt to segment from (xd(1),yd(1)) to (xd(2),yd(2))
% This is the distance from the closest point on the segment, which
% is either the perpendicular distance, or the distance from one of the
% end points of the segment.
% 
% Assumes p is a row

[xd,ind] = sort(xd);
yd = yd(ind);

if max(isnan(xd))==1 | max(isnan(yd))==1 
    % Line segment is the 'invisible' part of the specs line (data is set
    % to NaNs).  Avoid dividing by NaNs; causes warnings on PCWIN.
    d = sqrt(sum(  (p([1 1],:)' - [xd(:)'; yd(:)']).^2  ));
    d = min(d);
elseif diff(xd)==0  % slope is infinite
    if p(2)>=min(yd) & p(2)<=max(yd)
        d = abs(xd(1)-p(1));
    else
        d = sqrt(sum(  (p([1 1],:)' - [xd(:)'; yd(:)']).^2  ));
        d = min(d);    
    end
elseif diff(yd)==0   % slope is zero
    if p(1)>=xd(1) & p(1)<=xd(2)
        d = abs(yd(1)-p(2));
    else
        d = sqrt(sum(  (p([1 1],:)' - [xd(:)'; yd(:)']).^2  ));
        d = min(d);    
    end
else
    m1 = diff(yd)/diff(xd);  % slope of line connecting (xd(1),yd(1)), (xd(2),yd(2))
    b1 = yd(1)-xd(1)*m1;    
    
    m2 = -1/m1;              % slope and y-intercept of perpendicular line
    b2 = p(2)-m2*p(1);       % which passes through p
    
    % find intersection of two lines
    p_int = [m1 -1; m2 -1]\[-b1; -b2];
    
    % is p_int on the line segment?
    if (p_int(1) > xd(1)) & (p_int(1) < xd(2))
        d = sqrt(sum((p-p_int').^2));
    else
        d = sqrt(sum(  (p([1 1],:)' - [xd(:)'; yd(:)']).^2  ));
        d = min(d);
    end
end

%----------------------------------------------------------------------------------
function [vertexFlag,dist,ind,segdist,segind] = ...
      closestpoint(pt,h,xscale,yscale,xd,yd)
% Find distance to closest point on line from pt
% Inputs:
%   pt - current point, in axes units
%   h - line handle
%   xscale - number of pixels per axes x-unit
%   yscale - number of pixels per axes y-unit
%   xd - line's xdata
%   yd - line's ydata
% Outputs:
%   vertexFlag == 1 if closest point is a vertex of the line,
%              == 0 if closest point is a segment of the line
%   dist - distance in pixels from vertex if vertexFlag is 1
%   ind - index of vertex if vertexFlag is 1
%   segdist - distance in pixels from segment if vertexFlag is 0
%   segind - starting index of segment if vertexFlag is 0

    xd1 = xd*xscale;
    yd1 = yd*yscale;
    pt1 = pt.*[xscale yscale];
    
    % find index of closest vertex:
    [dist_sq,ind] = min((xd1-pt1(1)).^2 + (yd1 - pt1(2)).^2);
    dist = sqrt(dist_sq);
    
    segdist = 100;
    segind = [];
    
    % now determine if this is a segment click or a vertex click
    % NOTE: does not account for line thickness or markersize
    if dist < 3.5 | length(xd)==1 | ...
          strcmp(get(h,'linestyle'),'none')
        %  this is close enough to be a vertex click
        vertexFlag = 1;
    else 
        %  must be a segment
        vertexFlag = 0;
        % ASSUMPTION: line doesn't double back on itself or cross over itself.
        %   This means that the closest vertex is also one of the 
        %   endpoints of the closest segment
        if ind == 1
            segind = 1;   % "segment index"
            segdist = segmentDistance(pt1,xd1([1 2]),yd1([1 2]));
        elseif ind == length(xd1)
            segind = length(xd1)-1;
            segdist = segmentDistance(pt1,xd1([end-1 end]),yd1([end-1 end]));
        else % two closest segments
            segind = [ind-1 ind];
            segdist(1) = segmentDistance(pt1,xd1([ind-1 ind]),yd1([ind-1 ind]));
            segdist(2) = segmentDistance(pt1,xd1([ind ind+1]),yd1([ind ind+1]));
            if segdist(1)<=segdist(2)
                segdist = segdist(1);
                segind = ind-1;
            else
                segdist = segdist(2);
                segind = ind;
            end
        end        
    end

%----------------------------------------------------------------------------------
function lrbt = hgrect2lrbt(r)
%Convert handle graphics rect (hgrect) in [left bottom width height]
% format to Left-Right-Bottom-Top (lrbt) format [left right bottom top]
    lrbt = [r(1) r(1)+r(3) r(2) r(2)+r(4)];

%----------------------------------------------------------------------------------    
function uiwaitforButtonUp(fig)
% wait for buttonup event
    save_wbuf = get(fig,'windowbuttonupfcn');
    set(fig,'windowbuttonupfcn','uiresume');
    uiwait(fig)
    set(fig,'windowbuttonupfcn',save_wbuf)

%----------------------------------------------------------------------------------
function filt = importFiltNoLineinfo(filt,selectFilt)
% imports filt struct into sptool, but does not overwrite the filter's
% .lineinfo field
% Inputs:
%   selectFilt - flag to determine if filter will be selected in sptool
%         optional; defaults to 0

    if nargin < 2
        selectFilt = 0;
    end
    f = sptool('Filters',0);
    if ~isempty(f)
        filtInd = find(strcmp({f.label},filt.label));
        if ~isempty(filtInd)
            filt.lineinfo = f(filtInd).lineinfo;
        end
    end
    sptool('import',filt,selectFilt)

%----------------------------------------------------------------------------------
function [newxlim,newylim] = newlims(apos,xlim,ylim);
% Get the limits when aspectmode is 'equal'
% This function was copied from signal/private/fvzoom.m
%  and also exists in signal/private/fvresize.m and
%  @fdax/setpos.m

dx = diff(xlim);
dy = diff(ylim);

if dx * apos(4)/apos(3) >= dy   % Snap to the requested x limits, expand y to fit
   newxlim = xlim;
   newylen = apos(4)/apos(3) * dx;
   newylim = mean(ylim) + [-newylen/2 newylen/2];
else
   newylim = ylim;
   newxlen = apos(3)/apos(4) * dy;
   newxlim = mean(xlim) + [-newxlen/2 newxlen/2];
end

if diff(newxlim) <= 0
   newxlim = xlim;
end
if diff(newylim) <= 0
   newylim = ylim;
end

%----------------------------------------------------------------------------------
function ud = create_toolbar(fig)
% CREATE_TOOLBAR Creates the toolbar for the Filter Designer
%

ud = get(fig,'userdata');
ut = uitoolbar(fig);

% MAT-file containing a structure with the cdata for each icon.
load siggui_icons
uipushtool('cdata',bmp.print,...
                 'parent',ut,...
                 'clickedcallback','printcomp(''prnt'')' ,...
                 'tooltipstring',xlate('Print...'));
ud.toolbar.printpreview = ...
    uipushtool('cdata',bmp.printpreview,...
                 'parent',ut,...
                 'clickedcallback','printcomp(''prev'')' ,...
                 'tooltipstring',xlate('Print Preview...'));
ud.toolbar.mousezoom = ...
    uitoggletool('cdata',bmp.mousezoom,...
                 'separator','on',...
                 'parent',ut,...
                 'clickedcallback','filtdes(''zoom'',''mousezoom'')',...
                 'tooltipstring',xlate('Mouse Zoom'));
ud.toolbar.fullview = ...
    uipushtool('cdata',bmp.fullview,...
                 'parent',ut,...
                 'clickedcallback','filtdes(''zoom'',''zoomout'')',...
                 'tooltipstring',xlate('Full View (zooms out both axes)')); 
ud.toolbar.zoominy = ...
    uipushtool('cdata',bmp.zoominy,...
                 'parent',ut,...
                 'clickedcallback','filtdes(''zoom'',''zoominy'')',...
                 'tooltipstring',xlate('Zoom In - Y (vertical axis)'));
ud.toolbar.zoomouty = ...
    uipushtool('cdata',bmp.zoomouty,...
                 'parent',ut,...
                 'clickedcallback','filtdes(''zoom'',''zoomouty'')',...
                 'tooltipstring',xlate('Zoom Out - Y (vertical axis)'));
ud.toolbar.zoominx = ...
    uipushtool('cdata',bmp.zoominx,...
                 'parent',ut,...
                 'clickedcallback','filtdes(''zoom'',''zoominx'')',...
                 'tooltipstring',xlate('Zoom In - X (horizontal axis)'));
ud.toolbar.zoomoutx = ...
    uipushtool('cdata',bmp.zoomoutx,...
                 'parent',ut,...
                 'clickedcallback','filtdes(''zoom'',''zoomoutx'')',...
                 'tooltipstring',xlate('Zoom Out - X (horizontal axis)'));
ud.toolbar.passband = ...
    uipushtool('cdata',bmp.passband,...
                 'parent',ut,...
                 'clickedcallback','filtdes(''zoom'',''passband'')',...
                 'tooltipstring',xlate('Passband View (zooms in on Passband)')); 
ud.toolbar.overlay = ...
    uipushtool('cdata',bmp.overlay,...
                 'parent',ut,...
                 'separator','on',...
                 'clickedcallback','filtdes(''overlay'')',...
                 'tooltipstring',xlate('Overlay Spectrum...'));
ud.toolbar.whatsthis = ...
    uitoggletool('cdata',bmp.whatsthis,...
                 'parent',ut,...
                 'clickedcallback','filtdes(''help'')' ,...
                 'tooltipstring',xlate('"What''s This?" Help'));
             
%----------------------------------------------------------------------------------          
function h_vect = obj2vect(obj,field)
% OBJ2VECT converts an object array of handles to a vector of handles.
% (the field is usually a handle, h)

% Get a cell array of handles from the object.
h_cell = get(obj,field);

% Convert the cell array to a vector of handles.
if iscell(h_cell),
	h_vect = [h_cell{:}];
else
    h_vect = h_cell;
end

%------------------------------------------------------------------------------
function mh = filtdes_helpmenu
% Set up a string cell array that can be passed to makemenu to create the Help
% menu for the Filter Designer.
  
% Define specifics for the Help menu in Filter Designer.
toolname      = 'Filter Designer';
toolhelp_cb   = 'filtdes(''help'',''topics'')';
toolhelp_tag  = 'helptopicsmenu';
whatsthis_cb  = 'filtdes(''help'',''whatsthis'')';
whatsthis_tag = 'whatsthismenu';

% Add other Help menu choices that are common to all SPTool clients.
mh=sptool_helpmenu(toolname,toolhelp_cb,toolhelp_tag,whatsthis_cb,whatsthis_tag);

%------------------------------------------------------------------------------
function lclmotionfcn(hcbo, eventStruct, hFig)

global fd_line_motion_message
if ~strcmp(fd_line_motion_message, 'up'),
    fd_line_motion_message = 'motion';
end
uiresume(hFig);

%------------------------------------------------------------------------------
function lclupfcn(hcb, eventStruct, hFig)

global fd_line_motion_message
fd_line_motion_message = 'up';
uiresume(hFig);

% [EOF] filtdes.m
