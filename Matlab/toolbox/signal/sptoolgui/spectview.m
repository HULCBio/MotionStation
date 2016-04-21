function varargout = spectview(varargin)
%SPECTVIEW  Spectrum Viewer.
%   This graphical tool for Spectral Analysis lets you create, edit,
%   and analyze the frequency content of digital signals.
%
%   This function is available through the Signal Processing Toolbox
%   GUI (Graphic User Interface).  To use it, type 'sptool'.
%
%   See also SPTOOL, SIGBROWSE, FILTVIEW, FILTDES.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.20 $ $ Date: $

if nargin == 0
    if isempty(findobj(0,'tag','sptool'))
        disp('Type ''sptool'' to start the Signal GUI.')
    else
        disp('To use the Spectrum Viewer, click on a signal in the ''SPTool''')
        disp('and then click on ''Create'' under the ''Spectra'' column.')
    end
    return
elseif ~isstr(varargin{1})
    spinit(varargin{:})   % initialize tool
    return
end

switch varargin{1}

%------------------------------------------------------------------------
%spectview('update',fig)
%spectview('update',fig,s,ind)
%spectview('update',fig,s,ind,newdataFlag)
%spectview('update',fig,s,ind,sptoolfig,msg)
% Callback for when selected signals have changed
% Inputs:
%   fig - figure handle of spectrum viewer
%   s - structure array of spectra
%   ind - index of selected spectra   
%     s,ind together are optional - if omitted, they are obtained from SPTool
%   sptoolfig - figure handle of SPTool (optional)
%   msg - message as passed from SPTool
%    can be 'new', 'value', 'label', 'Fs', 'dup', 'clear'
%    The only real distinction here is between 'new' and the rest;
%      'new' means start from scratch as you cannot count on objects
%      being the same just because they are at the same index position in ind.
%      So 'new' will allocate new lines while anything else will retain any
%      lines that are at the same index location.
case 'update'
    fig = varargin{2};
    ud = get(fig,'userdata');
    
    if nargin > 2
        s = varargin{3};
        ind = varargin{4};
    else
        [s,ind] = sptool('Spectra');
    end
    if nargin > 5
        msg = varargin{6};
    else
        msg = 'new';  % new starts from scratch
    end
    fromScratch = strcmp(msg,'new');
    for i = 1:length(s(ind))
        if isempty(s(ind(i)).lineinfo)
             % assign next available line color and style
               [s(ind(i)).lineinfo,ud.colorCount] = ...
                nextcolor(ud.colororder,ud.linestyleorder,ud.colorCount);
            s(ind(i)).lineinfo.columns = 1;
            % poke back into SPTool
            if nargin > 4
                sptool('import',s(ind(i)),0,varargin{5})
            else
                sptool('import',s(ind(i)))
            end
        end
    end

    magscale = findcstr(get(ud.hand.magscaleMenu,'checked'),'on');
    
    oldLines = ud.lines;
    oldPatches = ud.patches;
    % de-allocate any lines that are no longer visible (save in cache);
    % also delete any such patches:
    patchDeleteList = [];
    for i=1:length(ud.lines)
        if ~any(ud.SPToolIndices(i)==ind) | fromScratch
            % a quick command line test reveals that destroying and creating
            % 100 lines is about twice as slow as setting the visible, tag, 
            % xdata, and ydata of 100 lines.
            ud.linecache.h = [ud.linecache.h; ud.lines(i).h];
            patchDeleteList = [patchDeleteList; ud.patches{i}];
            ud.patches{i} = [];
         end
    end
    % reset line cache:
    set(ud.linecache.h,'visible','off','tag','','xdata',0,'ydata',0)
    delete(patchDeleteList)
        
    N = length(ind);
    if length(ud.lines)>N
        ud.lines(N+1:end) = [];
        ud.patches(N+1:end) = [];
    end

    for i=1:N
        if ~isempty(ud.SPToolIndices) & ~fromScratch
            j = find(ind(i)==ud.SPToolIndices);
        else
            j = [];
        end
        if isempty(j) | ~isequal(s(ind(i)),ud.spect(j))
            % set up fields for panning:
            ud.lines(i).data = s(ind(i)).P;
            ud.lines(i).columns = 1; % all spectra have but one column
            ud.lines(i).Fs = -1;  % panner uses this for unequally spaced
            if ~isempty(s(ind(i)).f)
                ud.lines(i).t0 = s(ind(i)).f(1);% starting "time" for panfcn
            else
                ud.lines(i).t0 = [];
            end
            ud.lines(i).xdata = s(ind(i)).f;  
            xd = s(ind(i)).f;
            yd = s(ind(i)).P;
            yd = spmagfcn(yd,magscale);
            % create patch first so line is on top of it
            ud.patches{i} = [];
            if ~isempty(s(ind(i)).confid)
                if s(ind(i)).confid.enable
                %  assign or create a new patch
                    ud.patches{i} = patch(0,0,...
                      confidPatchColor(s(ind(i)).lineinfo.color),...
                      'edgecolor','none','parent',ud.mainaxes,...
                      'uicontextmenu',ud.contextMenu.u,...
                      'buttondownfcn',['spectview(''linedown'',' ...
                                 num2str(i) ')']);
                    Pc = s(ind(i)).confid.Pc;
                    if ~isempty(Pc)
                        verts = [[xd(:); flipud(xd(:))] ...
                              spmagfcn([Pc(:,1); flipud(Pc(:,2))],magscale)];
                        N = length(verts(:,1));
                        numFaces = N-2;
                        faces = zeros(numFaces,3);
                        faces(1:2:end,1) = (1:numFaces/2)';
                        faces(2:2:end,1) = (2:numFaces/2+1)';
                        faces(1:2:end,2) = (2:numFaces/2+1)';
                        faces(2:2:end,2) = N - (1:numFaces/2)';
                        faces(1:2:end,3) = N - (0:numFaces/2-1)';
                        faces(2:2:end,3) = N - (0:numFaces/2-1)';
                        set(ud.patches{i},'vertices',verts,...
                                 'faces',faces);
                    end
                end
            end
            %assign lines, set xdata and ydata
            [ud.lines(i).h,ud.linecache.h] = assignline(ud.linecache.h,...
                  length(s(ind(i)).lineinfo.columns),ud.mainaxes,...
                  'color',s(ind(i)).lineinfo.color,...
                  'linestyle',s(ind(i)).lineinfo.linestyle,...
                  'visible','on',...
                  'uicontextmenu',ud.contextMenu.u,...
                  'tag',s(ind(i)).label);
            set(ud.lines(i).h,'xdata',xd,'ydata',yd);
        else
        % use old lines (no need to set x and ydata)
            ud.lines(i) = oldLines(j);
            ud.patches{i} = oldPatches{j};
            if ~isempty(ud.patches{i})
               set(ud.patches{i},'buttondownfcn',['spectview(''linedown'',' ...
                                     num2str(i) ')'])
            end
        end
        set(ud.lines(i).h,'buttondownfcn',['spectview(''linedown'',' ...
                                     num2str(i) ')'])
    end
        
    if ~fromScratch
        common = intersect(ud.SPToolIndices,ind);
    else
        common = [];
    end
    ud.SPToolIndices = ind;
    ud.spect = s(ind);
    if ~isempty(ud.spect)
        ud.focusIndex = 1;
    else
        ud.focusIndex = [];
    end
    
    spzoomout(ud,isempty(common),0)  % saves userdata
    ud = get(fig,'userdata');
                
    sptlegend('setstring',{ud.spect.label},{ud.lines.columns},fig)
    spectview('linedown',ud.focusIndex,0,fig,1)
        
%------------------------------------------------------------------------
% spectview('magscale',scaling,fig,setprefFlag)
%  callback of magscale menu; changes scaling
% Inputs:
%   scaling - string; either 'db' or 'lin'
%   fig - optional - figure handle of spectrum viewer - defaults to gcf
%   setprefFlag - optional - 1 ==> set preferences in sptool (default), 
%                            0 ==> don't 
case 'magscale'
    scaling = varargin{2};
    if nargin < 3
        fig = gcf;
    else
        fig = varargin{3};
    end
    if nargin < 4
        setprefFlag = 1;
    else
        setprefFlag = varargin{4};
    end
   
    ud = get(fig,'userdata');
    
    old = findcstr(get(ud.hand.magscaleMenu,'checked'),'on');

    switch scaling
    case 'db'
        checks = {'on' 'off'};
    case 'lin'
        checks = {'off' 'on'};
  %  case 'log'
  %      checks = {'off' 'off' 'on'};
    end
    set(ud.hand.magscaleMenu,{'checked'},checks')

    new = findcstr(checks,'on');
    if ~isequal(old,new)
        for i=1:length(ud.spect)
            yd = ud.lines(i).data;
            yd = spmagfcn(yd,new);
            set(ud.lines(i).h,'ydata',yd);
            if ~isempty(ud.spect(i).confid) & ...
               ud.spect(i).confid.enable
                Pc = ud.spect(i).confid.Pc;
                if ~isempty(Pc)
                    verts = get(ud.patches{i},'vertices');
                    verts(:,2) = spmagfcn([Pc(:,1); flipud(Pc(:,2))],new);
                    set(ud.patches{i},'vertices',verts);
                end
            end
        end
        spzoomout(ud,0)
        if new == 3
            set(ud.mainaxes,'yscale','log')
        else
            set(ud.mainaxes,'yscale','linear')
        end
        if setprefFlag
            p = sptool('getprefs','spectview');
            p.magscale = new;
            sptool('setprefs','spectview',p)
        end
     end
    
%------------------------------------------------------------------------
% spectview('freqscale',scaling,fig,setprefFlag)
%  callback of freqscale menu; changes scaling
% Inputs:
%   scaling - string; either 'lin' or 'log'
%   fig - optional - figure handle of spectrum viewer - defaults to gcf
%   setprefFlag - optional - 1 ==> set preferences in sptool (default), 
%                            0 ==> don't
case 'freqscale'
    scaling = varargin{2};
    if nargin < 3
        fig = gcf;
    else
        fig = varargin{3};
    end
    if nargin < 4
        setprefFlag = 1;
    else
        setprefFlag = varargin{4};
    end

    ud = get(fig,'userdata');
    switch scaling
    case 'lin'
        checks = {'on' 'off'};
    case 'log'
        checks = {'off' 'on'};
    end
    old = findcstr(get(ud.hand.freqscaleMenu,'checked'),'on');
    set(ud.hand.freqscaleMenu,{'checked'},checks')
    new = findcstr(checks,'on');
    if ~isequal(old,new)
        range = findcstr(get(ud.hand.freqrangeMenu,'checked'),'on');
        if new == 2 & range == 3 % can't display negative values!
            set(ud.hand.freqrangeMenu(1),'checked','on')
            set(ud.hand.freqrangeMenu(3),'checked','off')
            spectview('freqrange','half',fig,0)
        end
        if new == 2
            set(ud.mainaxes,'xscale','log')
            if ud.prefs.tool.ruler
                % Make sure that x-axes lower limit is not 0            
                xlim = setLogscaleLims(ud.mainaxes,ud.lines,'xlim');
                set(ud.mainaxes,'xlim',xlim)
                ud.limits.xlim = xlim;
                set(fig,'userdata',ud)
                ruler('newlimits',fig)
            end
        else
            set(ud.mainaxes,'xscale','linear')
            if ud.prefs.tool.ruler & old == 2   % Change xlim(1) back to 0
                xlim = get(ud.mainaxes,'xlim');
                xlim(1) = 0;
                set(ud.mainaxes,'xlim',xlim)
                ud.limits.xlim = xlim;
                set(fig,'userdata',ud)
                ruler('newlimits',fig)
            end
        end
        if setprefFlag
            p = sptool('getprefs','spectview');
            p.freqscale = new;
            p.freqrange = findcstr(get(ud.hand.freqrangeMenu,'checked'),'on');
            sptool('setprefs','spectview',p)
        end
    end

%------------------------------------------------------------------------
% spectview('freqrange',range,fig,setprefFlag)
%  callback of freqrange menu; changes range
% Inputs:
%   range - string; either 'half', 'whole' or 'neg'
%   fig - optional - figure handle of spectrum viewer - defaults to gcf
%   setprefFlag - optional - 1 ==> set preferences in sptool (default), 
%                            0 ==> don't
case 'freqrange'
    range = varargin{2};
    if nargin < 3
        fig = gcf;
    else
        fig = varargin{3};
    end
    if nargin < 4
        setprefFlag = 1;
    else
        setprefFlag = varargin{4};
    end
    ud = get(fig,'userdata');
    
    switch range
    case 'half'
        checks = {'on' 'off' 'off'};
    case 'whole'
        checks = {'off' 'on' 'off'};
    case 'neg'
        checks = {'off' 'off' 'on'};
    end
    old = findcstr(get(ud.hand.freqrangeMenu,'checked'),'on');
    new = findcstr(checks,'on');
    if ~isequal(old,new)
        scale = findcstr(get(ud.hand.freqscaleMenu,'checked'),'on');
        if new == 3 & scale == 2 
            % can't display negative values in logscale mode!
            % so don't change range!
            msgbox({'Sorry, you can''t set the range to include negative' ...
                    'frequencies when the Frequency Axis Scaling is logarithmic.'},...
                    'Logarithmic Scaling Conflict','warn','modal')
            return
        end
        set(ud.hand.freqrangeMenu,{'checked'},checks')
        % Zoom out both X and Y;  updates the rulers (default)
        spzoomout(ud,1)
        if setprefFlag
            p = sptool('getprefs','spectview');
            p.freqrange = new;
            sptool('setprefs','spectview',p)
        end
    end


%------------------------------------------------------------------------
% spectview('linedown',ind,mouseFlag,fig,forceFlag)
%  buttondownfcn callback of line in spectrum viewer
%  Inputs:
%     ind - integer; index of the line which was clicked or selected
%     mouseFlag - binary; == 1 ==> this is a mouse click (default)
%                         == 0 ==> this was from the legend line
%     fig - handle to figure (defaults to gcf)
%     forceFlag - binary; == 1 ==> update even if ud.focusline hasn't changed
%                       defaults to 0
case 'linedown'
    ind = varargin{2};  % which line was clicked
    
    if nargin < 3
        mouseFlag = 1;
    else
        mouseFlag = varargin{3};
    end
    if nargin < 4
        fig = gcf;
    else
        fig = varargin{4};
    end
    if nargin < 5
        forceFlag = 0;
    else
        forceFlag = varargin{5};
    end
    ud = get(fig,'userdata');
    
    if mouseFlag
       % cursor is custom
       if ud.prefs.tool.ruler & strcmp(get(fig,'pointer'),'custom') & ...
             (ud.pointer==0)
           % means that cursor is on top of one of the ruler lines
           ruldown(0)
           return
       end
   
       if justzoom(fig), return, end

       if strcmp(get(fig,'selectiontype'),'alt')
          % In case of a right-click or cntl-click:
          % Change label on context menu to show the
          % name of the currently selected spectrum
          % First, select the filter that was clicked:

          spectview('uicontextmenu',ind)           
          return
       end % of selectiontype == 'alt'
   
       invis = [];
       if ud.prefs.tool.ruler
           invis = [ud.ruler.lines ud.ruler.markers ud.ruler.hand.buttons ...
                [ud.patches{:}] ]';
       end
       if strcmp(get(ud.hand.magscaleMenu(1),'checked'),'on')
           xform = inline('10*log10(x)');
       else
           xform = 'real';
       end
       if panfcn('Ax',ud.mainaxes,...
              'Bounds',ud.limits,...
              'BorderAxes',ud.mainaxes_border,...
              'Data',ud.lines,...
              'Immediate',0,...
              'Transform',xform,...
              'InterimPointer','fleur',...
              'Invisible',invis)
           if ud.prefs.tool.ruler
               ruler('newlimits')
           end
       end
    end     
       
    disableList = [ud.hand.methodPopup
                   ud.hand.methodLabel
                   ud.hand.uicontrol(:)
                   ud.hand.label(:)
                   ud.hand.confidenceCheckbox
                   ud.hand.confidenceEdit
                   ud.hand.inheritPopup
                   ud.toolbar.select];

    ud.focusIndex = ind;
    if ~isempty(ind)
        
       the_line = ud.lines(ind).h;
   
       if isequal(the_line, ud.focusline) & ~forceFlag
           return
       end
       
       ud.focusline = the_line;
   
       % make sure ruler lines are on top of stacking order, and that
       % patches are immediately behind their respective lines

       children = [ud.focusline; ud.patches{ind}];
       for i=[1:ind-1 ind+1:length(ud.lines)]
          children = [children; ud.lines(i).h; ud.patches{i}];
       end
       bringToFront(fig,children)
    
       % Force an initial choice of spectrum method
       choice = 'welch';  % (see spinit.m)
       
       % Select choice if it is available:
       defMethNum = find(strcmp(choice,(lower({ud.methods.methodName}))));
       if isempty(defMethNum)
           defMethNum = 1;  % Use first method listed in popupmenu
       end
       
       applyFlag = 0;
       importFlag = 0;  % need to poke this spectrum back into SPTool?
       % Why are we doing this?  Because it is possible to import 
       % a spectrum object into SPTool without any knowledge of
       % what its 'specs' are... only when the spectview is open
       % and initialized is it possible to know what the .specs
       % field of an imported spectrum is.
       if isempty(ud.spect(ind).specs)  % assign default specs
           %ud.spect(ind).specs.methodNum = defMethNum;
           ud.spect(ind).specs.valueArrays = {ud.methods(defMethNum).default};
           ud.spect(ind).specs.methodName = {ud.methods(defMethNum).methodName};
           ud.spect(ind).specs.methodNum = ...
               length(ud.spect(ind).specs.methodName);

           importFlag = 1;
       elseif isempty(findcstr({ud.methods.methodName},...
                ud.spect(ind).specs.methodName{ud.spect(ind).specs.methodNum}))
           % this spectrum is currently focused on a method
           % which is not available in spectview.
           %  SO, we need to find an entry we know or create one:
           methodNum = findcstr(ud.spect(ind).specs.methodName,...
                                ud.methods(defMethNum).methodName);
           if isempty(methodNum)  % add entry to list of specs for this spect
               ud.spect(ind).specs.methodName{end+1} = ud.methods(defMethNum).methodName;
               ud.spect(ind).specs.valueArrays{end+1} = ud.methods(defMethNum).default;
               ud.spect(ind).specs.methodNum = ...
                          length(ud.spect(ind).specs.methodName);
           else
               ud.spect(ind).specs.methodNum = methodNum;
           end
           applyFlag = 1;
           importFlag = 1;
       end
       if isempty(ud.spect(ind).confid) % assign default confidence specs
           ud.spect(ind).confid.enable = 0;
           ud.spect(ind).confid.level = '.95';
           ud.spect(ind).confid.Pc = [];
           importFlag = 1;          
       end
       if importFlag
           sptool('import',ud.spect(ind))
       end
       
       set(ud.hand.propLabel,...
          'Interpreter','tex',...
          'string','PSD')
           %'backgroundcolor',get(ud.mainaxes,'color'),...
           %'foregroundcolor',ud.spect(ind).lineinfo.color,...
       if isstr(ud.spect(ind).signal)
           updateSignalInfo(ud,'',ud.spect(ind).signal,ud.spect(ind).Fs)
           set(disableList,'enable','off')
           set(ud.hand.applyButton,'enable','off')
       else
           updateSignalInfo(ud,ud.spect(ind).signalLabel,ud.spect(ind).signal,...
                               ud.spect(ind).Fs)
           set(disableList,'enable','on')
           if isempty(ud.spect(ind).P) | applyFlag
               set(ud.hand.applyButton,'enable','on')
           else
               set(ud.hand.applyButton,'enable','off')
           end
       end
       set(fig,'userdata',ud); 
       spectview('fillParams',fig,...
                ud.spect(ind).specs.methodName{ud.spect(ind).specs.methodNum},... 
                ud.spect(ind).specs.valueArrays{ud.spect(ind).specs.methodNum},... 
                ud.spect(ind).confid)
       set(ud.hand.revertButton,'enable','off')
    else
       ud.focusline = [];
       set(fig,'userdata',ud);
       updateSignalInfo(ud,'',[],[])
       set(ud.hand.propLabel,...
           'string','<no selection>')
        %   'backgroundcolor',get(0,'defaultuicontrolbackgroundcolor'),...
        %   'foregroundcolor',get(0,'defaultuicontrolforegroundcolor'),...
       set(disableList,'enable','off')
       set(ud.hand.applyButton,'enable','off')
       set(ud.hand.revertButton,'enable','off')
    end
            
   sptlegend('setvalue',ud.focusline,ud.focusIndex,1,fig)

   if ud.prefs.tool.ruler        
       ruler('showlines',fig)
       ruler('newlimits',fig)
       ruler('newsig',fig)
   end

%------------------------------------------------------------------------
% spectview('mainaxes_down')
%  buttondownfcn of ud.mainaxes
case 'mainaxes_down'
   fig = gcbf;
   ud = get(fig,'userdata');

   i = sptlegend('value',fig);
   spectview('uicontextmenu',i)

%------------------------------------------------------------------------
% spectview('uicontextmenu',ind)
%   Context Menu handler for spectview.
%   Call this function on buttondown of object whose uicontextmenu is 
%   ud.contextMenu.u.
%   ind is the index of the spectrum that is currently selected
%   or that you would like to select
case 'uicontextmenu'

    fig = gcbf;
    ud = get(fig,'userdata');

    ind = varargin{2};

       if strcmp(get(fig,'selectiontype'),'alt')
          % In case of a right-click or cntl-click:
          % Change label on context menu to show the
          % name of the currently selected spectrum
          % First, select the filter that was clicked:
          if (ind~=ud.focusIndex)
              spectview('linedown',ind,0)
              ud = get(fig,'userdata');
          end
          % Now create list of signals that are selected and visible in browser:

          for kk=length(ud.contextMenu.pickMenu)+1:length(ud.spect)
          % create new context menus if necessary
              ud.contextMenu.pickMenu(kk) = uimenu(ud.contextMenu.u);
              ud.contextMenu.changeName(kk) = uimenu(ud.contextMenu.pickMenu(kk));
              ud.contextMenu.Fs(kk) = uimenu(ud.contextMenu.pickMenu(kk));
              ud.contextMenu.lineprop(kk) = uimenu(ud.contextMenu.pickMenu(kk));
          end
          for kk=length(ud.spect)+1:length(ud.contextMenu.pickMenu)
          % hide created but unused context Menus
              set(ud.contextMenu.pickMenu(kk),'visible','off')
          end
          for kk=1:length(ud.spect)
              set(ud.contextMenu.pickMenu(kk),'label',ud.spect(kk).label,'visible','on') 
              if kk==ind
                  set(ud.contextMenu.pickMenu(kk),'checked','on')
              else
                  set(ud.contextMenu.pickMenu(kk),'checked','off')
              end 

              set(ud.contextMenu.changeName(kk),'label',sprintf('Change Name...'),...
                'callback',['sbswitch(''spectview'',''setLabel'',' num2str(kk) ')'])

              if kk~=ind
                  % NOTE: Before we can call sptlegend('button') to change the
                  % linestyle and color, we must select the spectrum; hence the
                  % call to linedown in the lineprop uimenu's callback:
                  set(ud.contextMenu.lineprop(kk),'label',sprintf('Line Properties...'),'callback',...
                     sprintf(['sbswitch(''spectview'',''linedown'',%d,0);' ...
                        'sbswitch(''sptlegend'',''button'')'],kk))
              else
                  % No need to select signal again, since we just did and we
                  % know it is selected
                  set(ud.contextMenu.lineprop(kk),'label',sprintf('Line Properties...'),'callback',...
                     'sbswitch(''sptlegend'',''button'')')
              end

              set(ud.contextMenu.Fs(kk),'callback',...
                sprintf('sbswitch(''spectview'',''setFs'',%d)',kk),...
                'label',sprintf('Sampling Frequency (%g)...',ud.spect(kk).Fs))
          end % for kk=1:length(ud.filt)
   
          %Need to reorder children of ud.contextMenu.u:
          set(ud.contextMenu.u,'children',ud.contextMenu.pickMenu(end:-1:1))
       
          % save userdata since ud.contextMenu may have changed:
          set(fig,'userdata',ud)
           
       end % of selectiontype == 'alt'
    
%------------------------------------------------------------------------
% spectview('changefocus')
%  callback of sptlegend
case 'changefocus'
    i = sptlegend('value');
    spectview('linedown',i,0)
    
%------------------------------------------------------------------------
% spectview('newColor',lineColor,lineStyle)
%  newColorCallback of sptlegend
%  color and linestyle of ud.focusline have already been updated
case 'newColor'
    lineColor = varargin{2};
    lineStyle = varargin{3};
    
    fig = gcf;
    ud = get(fig,'userdata');
    
    ind = ud.focusIndex;
    ud.spect(ind).lineinfo.color = lineColor;
    ud.spect(ind).lineinfo.linestyle = lineStyle;
    %set(ud.hand.propLabel,'foregroundcolor',ud.spect(ind).lineinfo.color)

    if ~isempty(ud.patches{ind})
        set(ud.patches{ind},'facecolor',confidPatchColor(lineColor))
    end

    set(fig,'userdata',ud)

    % poke back into SPTool
    sptool('import',ud.spect(ind))

%------------------------------------------------------------------------
% spectview('setFs',i)
% Callback of 'Sampling Frequency...' menu item of uicontext menu
% of a spectrum
%  Input args:  i = index into ud.spect of current spectrum
%  Added 6/26/99, TPK
case 'setFs'
    i = varargin{2};
    ud = get(gcf,'UserData');
    prompt={'Sampling frequency:'};
    def = {sprintf('%.9g',ud.spect(i).Fs)};
    ud_s = get(ud.toolbar.select,'user');
    title = sprintf('Sampling Frequency for signal "%s" of spectrum "%s"',...
       ud.spect(i).signalLabel,ud_s.string{i});
    lineNo = 1;
    Fs=inputdlg(prompt,title,lineNo,def);
    if isempty(Fs)
        return
    end
    [Fs,err] = validarg(Fs{:},[0 Inf],[1 1],'sampling frequency (or expression)');
    if err ~= 0
         return
    end
    if ud.spect(i).Fs == Fs
        % new Fs is the same as the old one - do nothing!
        return
    end
    % Need to change Fs of SIGNAL linked to this spectrum:
    sptool('changeFs',ud.spect(i).signalLabel,Fs)

%------------------------------------------------------------------------
% spectview('setLabel',i)
% Callback of 'Spectrum: name' menu item of uicontext menu
% of a spectrum
%  Input args:  i = index into ud.spect of current spectra
%  Added 6/26/99, TPK
case 'setLabel'
    i = varargin{2};
    ud = get(gcf,'UserData');
    sptool('newname',ud.spect(i).label)
    
%------------------------------------------------------------------------
% enable = spectview('selection',action,msg,SPTfig)
%  respond to selection change in SPTool
% possible actions are
%    'view', 'create', 'update'
%  view Button is enabled when there is at least one spectrum selected
%  create button is enabled when there is exactly one signal selected
%  update button is enabled when there is exactly one signal & spectrum
%  msg - either 'value', 'label', 'Fs', 'dup', or 'clear'
%         'value' - only the listbox value has changed
%         'label' - one of the selected objects has changed it's name
%         'Fs' - one of the selected objects's .Fs field has changed
%         'dup' - a selected object was duplicated
%         'clear' - a selected object was cleared
case 'selection'
    msg = varargin{3};
    SPTfig = varargin{4};
    switch varargin{2}
    case 'view'
        [spect,ind] = sptool('Spectra',1,SPTfig); % get selected spectra
        % resolve any links at this time:
        spect = resolveLinks(spect,ind,SPTfig);
        
        if ~isempty(ind)
            enable = 'on';
        else
            enable = 'off';
        end
        fig = findobj('type','figure','tag','spectview');
        if ~isempty(fig)
            ud = get(fig,'userdata');
            switch msg
            case {'new','value','dup'}
                if ~isequal(spect(ind),ud.spect)
                    spectview('update',fig,spect,ind,SPTfig,msg)
                end
                changedStruc = sptool('changedStruc',SPTfig);
                if isempty(changedStruc) | ...
                   strcmp(changedStruc.SPTIdentifier.type,'Signal')
                    spectview('hotlink',changedStruc,msg,fig,SPTfig)
                end
                ud = get(fig,'userdata');
                ud.inheritList = newInheritString(ud.hand.inheritPopup,...
                             {spect.label},ud.maxPopupEntries);
                set(fig,'userdata',ud)
            case 'label'
                changedStruc = sptool('changedStruc',SPTfig);
                switch changedStruc.SPTIdentifier.type
                case 'Spectrum'
                    for i=1:length(ind)
                        if ~isequal(ud.spect(i).label,spect(ind(i)).label)
                            % change label of ud.spect(i)
                            ud.spect(i).label = spect(ind(i)).label;
                            ud.inheritList = newInheritString(ud.hand.inheritPopup,...
                                     {spect.label},ud.maxPopupEntries);
                            set(fig,'userdata',ud)
                            sptlegend('setstring',{ud.spect.label},...
                                              {ud.lines.columns},fig,1)
                            break
                        end
                    end
                case 'Signal'
                    spectview('hotlink',changedStruc,msg,fig,SPTfig)
                end
            case 'Fs'
                changedStruc = sptool('changedStruc',SPTfig);
                switch changedStruc.SPTIdentifier.type
                case 'Spectrum'
                    for i=1:length(ind)
                        if ~isequal(ud.spect(i).Fs,spect(ind(i)).Fs)
                            if isstr(ud.spect(i).signal)
                                break
                            end
                            % change Fs of ud.spect(i)
                            newFs = spect(ind(i)).Fs;
                            oldFs = ud.spect(i).Fs;
                            ud.spect(i).f = spect(ind(i)).f;
                            ud.spect(i).Fs = newFs;
                            ud.lines(i).Fs = 1./(ud.spect(i).f(2) - ud.spect(i).f(1));
                            set(ud.lines(i).h,'xdata',ud.spect(i).f)
                            siginfo2Str = sprintf('Fs = %.9g',ud.spect(i).Fs);
                            set(ud.hand.siginfo2Label,'string',siginfo2Str)
                            spzoomout(ud,0,1)
                            break
                        end
                    end
                case 'Signal'
                    spectview('hotlink',changedStruc,msg,fig,SPTfig)
                end
            case 'clear'
                changedStruc = sptool('changedStruc',SPTfig);
                switch changedStruc.SPTIdentifier.type
                case 'Spectrum'  % a spectrum was cleared
                    if isempty(ind)
                        spectview('update',fig,spect,ind,SPTfig,msg)
                    else
                        % first find out which one was deleted
                        rmInd = length(ud.spect);
                        for i = 1:length(ind)
                            if ~strcmp(spect(ind(i)).label,ud.spect(i).label)
                                rmInd = i;
                                break  % found it
                            end
                        end
                        delete(ud.lines(rmInd).h)
                        if ishandle(ud.patches{rmInd})
                            delete(ud.patches{rmInd})
                        end

                        ud.spect(rmInd) = [];
                        ud.lines(rmInd) = [];
                        ud.patches(rmInd) = [];
                
                        ud.SPToolIndices = ind;
            
                        set(fig,'userdata',ud)
                        sptlegend('setstring',{ud.spect.label},...
                                      {ud.lines.columns},fig,1)
       
                        % need to update buttondownfcn's for lines:
                        for i=1:length(ud.spect)
                           set(ud.lines(i).h,...
                               'buttondownfcn',['spectview(''linedown'',' ...
                                         num2str(i) ')'])
                           if ishandle(ud.patches{i})
                              set(ud.patches{i},...
                                 'buttondownfcn',['spectview(''linedown'',' ...
                                           num2str(i) ')'])
                           end
                        end        
               
                        if ud.focusIndex == rmInd
                            % shift focus to first spectrum
                            ud.focusIndex = 1;
                            % save the focusline handle in the userdata struct:
                            ud.focusline = ud.lines(ud.focusIndex).h;
                            spzoomout(ud,0,0)  % saves userdata
                            ud = get(fig,'userdata');
                            spectview('linedown',ud.focusIndex,0,fig,1)
                        else
                            if ud.focusIndex > rmInd
                                ud.focusIndex = ud.focusIndex - 1;
                            end
                            spzoomout(ud,0,0)  % saves userdata
                            if ud.prefs.tool.ruler
                                ruler('showlines',fig)
                            end
                        end    
                    end  % if isempty(ind)
                    ud = get(fig,'userdata');
                    ud.inheritList = newInheritString(ud.hand.inheritPopup,...
                                 {spect.label},ud.maxPopupEntries);
                    set(fig,'userdata',ud)
                case 'Signal'  % a signal was cleared
                    spectview('hotlink',changedStruc,msg,fig,SPTfig)
                end
            end  % switch msg
        end
    case 'create'
        sig = sptool('Signals',0,SPTfig);
        if length(sig) == 1
            enable = 'on';
        else
            enable = 'off';
        end
    case 'update'
        sig = sptool('Signals',0,SPTfig);
        spect = sptool('Spectra',0,SPTfig);
        if length(sig) == 1  &  length(spect) == 1
            enable = 'on';
        else
            enable = 'off';
        end
    end
    varargout{1} = enable;

%------------------------------------------------------------------------
% enable = spectview('action',verb.action,selection)
%  respond to button push in SPTool
% possible actions are
%    'view', 'create' and 'update'
case 'action'
    switch varargin{2}
    case 'view'
        SPTfig = gcf;
        [s,ind] = sptool('Spectra',1,SPTfig);  % get selected spectra
        fig = findobj('type','figure','tag','spectview');
        if isempty(fig)  % create the spectview tool
            spectview(SPTfig)
            fig = gcf;
            ud = get(fig,'userdata');
            ud.SPToolIndices = ind;
            set(fig,'userdata',ud)
        else
            ud = get(fig,'userdata');
        end
        if ~isequal(ud.spect,s(ind))
            spectview('update',fig,s,ind,SPTfig,'new')
            ud = get(fig,'userdata');
            ud.inheritList = newInheritString(ud.hand.inheritPopup,...
                    {s.label},ud.maxPopupEntries);
            set(fig,'userdata',ud)
        end
        % bring spectview figure to front:
        figure(fig)

    case 'create'
        SPTfig = gcf;
        sig = sptool('Signals',0,SPTfig);  % get the selected signal
        [err,errstr,struc] = importspec('make',{1 [] []});
        struc.signal = [size(sig.data) ~isreal(sig.data)];
        struc.signalLabel = sig.label;
        struc.Fs = sig.Fs;
        labelList = sptool('labelList',SPTfig);
        [popupString,fields,FsFlag,defaultLabel] = importspec('fields');
        struc.label = sbswitch('uniqlabel',labelList,defaultLabel);
        fig = findobj('type','figure','tag','spectview');
        if isempty(fig)  % create the spectview tool if not open
            spectview(SPTfig)
            fig = gcf;
        end
        ud = get(fig,'userdata');

        sptool('import',struc,1,SPTfig)  % puts new struc in SPTool AND
                  % focuses spectview on the struc
        
    	  % now bring spectrum viewer to the front:
        figure(fig)
        
    case 'update'
        SPTfig = gcf;
        sig = sptool('Signals',0,SPTfig);  % get the selected signal
        [struc,ind] = sptool('Spectra',1,SPTfig);
        fig = findobj('type','figure','tag','spectview');
        if isempty(fig)  % create the spectview tool if not open
            spectview(SPTfig)
            fig = gcf;
            ud = get(fig,'userdata');
            ud.SPToolIndices = ind;
            set(fig,'userdata',ud)
        else  % bring spectrum viewer to the front:
            figure(fig)
        end
        struc(ind).signal = [size(sig.data) ~isreal(sig.data)];
        struc(ind).signalLabel = sig.label;
        struc(ind).Fs = sig.Fs;
        struc(ind).P = [];
        struc(ind).f = [];
        if ~isempty(struc(ind).confid)
           struc(ind).confid.Pc = [];
        end
        sptool('import',struc(ind),0,SPTfig)
            
        [spect,ind] = sptool('Spectra',1,SPTfig);
        spectview('update',fig,spect,ind,SPTfig,'new')

    end

%------------------------------------------------------------------------
% spectview('hotlink',changedStruc,msg,fig,SPTfig)
case 'hotlink'
    changedStruc = varargin{2};
    msg = varargin{3};
    fig = varargin{4};
    SPTfig = varargin{5};
    
    if strcmp(msg,'value') | strcmp(msg,'dup')
        return
    end
    if strcmp(msg,'new') & isempty(changedStruc)
    % only worry about new in case of overwrite
        return
    end
    
    ud = get(fig,'userdata');
    [spect,spectInd] = sptool('Spectra',1,SPTfig);  % all spectra in tool
    linkedSpect = findcstr({spect.signalLabel},changedStruc.label);
    if isempty(linkedSpect)
        return
    end
    sigs = sptool('Signals',1,SPTfig);
    if ~strcmp(msg,'label')
        ind = findcstr({sigs.label},changedStruc.label);
    else  % need to search for the signal whose label changed!
        ind = [];
        for i=1:length(sigs)
            temp = sigs(i);
            temp.label = changedStruc.label;
            if isequal(temp,changedStruc)
                ind = i;
                break
            end
        end
    end
    
    switch msg
    case 'Fs'
        for i=linkedSpect
            oldFs = spect(i).Fs;
            spect(i).Fs = sigs(ind).Fs;
            if ~isempty(spect(i).f)
                spect(i).f = spect(i).f*spect(i).Fs/oldFs;
            end
            sptool('import',spect(i),0,SPTfig)
        end
    case 'label'
        for i=linkedSpect
            spect(i).signalLabel = sigs(ind).label;
            sptool('import',spect(i),0,SPTfig)
        end
    case 'new'
        if ~isequal(sigs(ind).data,changedStruc.data) | ...
           ~isequal(sigs(ind).Fs,changedStruc.Fs)
            for i=linkedSpect
                spect(i).signal = [size(sigs(ind).data) ~isreal(sigs(ind).data)];
                spect(i).Fs = sigs(ind).Fs;
                spect(i).f = [];
                spect(i).P = [];
                sptool('import',spect(i),0,SPTfig)
            end
        end
    case 'clear'
        for i=linkedSpect
            spect(i).signal = 'none';
            spect(i).signalLabel = '';
            sptool('import',spect(i),0,SPTfig)
        end
    end
    
    spectview('update',fig,spect,spectInd,SPTfig,'new')

%------------------------------------------------------------------------
% spectview('SPTclose',action)
% Spectrum Viewer close request function
%   This function is called when a browser window is closed.
%  action will be:  'view', 'create' or 'update'
%   only closes window on 'view'
%  action is optional; will close tool if left off
case 'SPTclose'
    if nargin==2
        if ~strcmp(varargin{2},'view')
            return
        end
    end
    
    fig = findobj('type','figure','tag','spectview');
    if ~isempty(fig)
        ud = get(fig,'userdata');
        if ~isempty(ud.tabfig)
            delete(ud.tabfig)
        end
        delete(fig)
    end
    
%------------------------------------------------------------------------
% spectview('print')
%  print contents of spectview (assumed in gcf)
case 'print'
    %shh = get(0,'showhiddenhandles');
    %set(0,'showhiddenhandles','on')
    
    %ch = [gcf; findobj(gcf,'type','uicontrol'); findobj(gcf,'type','axes')];
    %save_units = get(ch,'units');
    %set(ch,'units','points');
    %save_resize = get(gcf,'resizefcn');
    %set(gcf,'resizefcn','')
    
    %dlg = pagedlg(gcf);
    %set(dlg,'windowstyle','modal')
    %printdlg(gcf)
    
    %set(gcf,'resizefcn',save_resize);
    %set(ch,{'units'},save_units)
    %set(0,'showhiddenhandles',shh)

%------------------------------------------------------------------------
% spectview('help')
%  Callback of help button in toolbar
% spectview('help','topics')
%  Callback of 'Help Topics' menu 
% spectview('help','whatsthis')
%  Callback of 'What's this?' menu
case 'help'
    fig = gcf;
    ud = get(fig,'userdata');
    if ud.pointer ~= 2   % if not in help mode
        % enter help mode
        markersMenu = findobj(fig,'type','uimenu','tag','markersmenu');
        toolbarBlanks = findobj(get(ud.toolbar.mousezoom,'parent'),'type','uipushtool','tag','blank');
        saveEnableControls = [ud.hand.applyButton
                              ud.hand.revertButton
                              ud.hand.confidenceCheckbox
                              ud.hand.confidenceEdit
                              ud.hand.methodLabel
                              ud.hand.methodPopup
                              ud.hand.inheritPopup
                              ud.hand.label(:)
                              ud.hand.uicontrol(:)
                              ud.toolbar.select
                              ud.toolbar.lineprop  
                              ud.toolbar.vertical  
                              ud.toolbar.horizontal  
                              ud.toolbar.track
                              ud.toolbar.slope 
                              ud.toolbar.peaks
                              ud.toolbar.valleys     
                              markersMenu
                              toolbarBlanks];
        ax = [ud.mainaxes];
        if ud.prefs.tool.ruler
            ax = [ax ud.ruler.hand.ruleraxes];
        end
        titleStr = 'Spectrum Viewer Help';
        helpFcn = 'sphelpstr';
        spthelp('enter',fig,saveEnableControls,ax,titleStr,helpFcn)
        if nargin > 1  % Called from menu
           set(ud.toolbar.whatsthis,'state','on')
           if strcmp(varargin{2},'topics')
              spthelp('exit')  % just need to exit help mode;
                               %displays general help by default
           end
        end

    else
        spthelp('exit')
    end
    
%------------------------------------------------------------------------
% spectview('fillParams',fig,methodName,valueArray,confid)
%   set uicontrol values and strings and enable / visible properties
%   for parameters.
% Inputs:
%   fig - figure handle of spectview tool
%   methodName - string; specifies method with which to fill the uicontols
%   valueArray - cell array which has the value for each parameter
%     (string entry for edit, number for popup or checkbox, cell array for
%      subordinate parameters)
%   confid - structure; .enable == 1 or 0, .level = string, .Pc (optional)
%     is the confidence limits array
case 'fillParams'
    fig = varargin{2};
    methodName = varargin{3};
    valueArray = varargin{4};
    confid = varargin{5};
    
    ud = get(fig,'userdata');
    
    methodNameList = {ud.methods.methodName};
    methodNum = findcstr(methodNameList,methodName);
    
    set(ud.hand.methodPopup,'value',methodNum)
    
    m = ud.methods(methodNum);

    for i=1:length(m.type)
        % is this parameter a subordinate?  Change it if not:
        if isstr(m.type{i})
            changeParamType(m.type{i},...
                            valueArray{i},...
                            m.label{i},...
                            m.popupString{i},...
                            ud.hand.label(i),...
                            ud.hand.uicontrol(i))
        end
    end
    % set types, strings and values of subordinate uicontrols:
    for i=1:length(m.type)
        for j = m.subordinates{i}
            popupVal = valueArray{i};
            if iscell(valueArray{j})
                changeParamType(ud.methods(methodNum).type{j}{popupVal},...
                            valueArray{j}{popupVal},...
                            ud.methods(methodNum).label{j}{popupVal},...
                            ud.methods(methodNum).popupString{j}{popupVal},...
                            ud.hand.label(j),...
                            ud.hand.uicontrol(j))
            else
                changeParamType(ud.methods(methodNum).type{j}{popupVal},...
                            valueArray{j},...
                            ud.methods(methodNum).label{j}{popupVal},...
                            ud.methods(methodNum).popupString{j}{popupVal},...
                            ud.hand.label(j),...
                            ud.hand.uicontrol(j))
            end
        end
    end
    
    for i=length(m.type)+1:length(ud.hand.uicontrol)
        set([ud.hand.label(i) ud.hand.uicontrol(i)],'visible','off')
    end
    
    if m.confidenceFlag
        set(ud.hand.confidenceCheckbox,'visible','on')
        set(ud.hand.confidenceEdit,'visible','on')
        set(ud.hand.confidenceCheckbox,'value',confid.enable)
        set(ud.hand.confidenceEdit,'string',confid.level)
        if confid.enable
            set(ud.hand.confidenceEdit,'enable','on')
        else
            set(ud.hand.confidenceEdit,'enable','off')
        end
    else
        set(ud.hand.confidenceCheckbox,'visible','off')
        set(ud.hand.confidenceEdit,'visible','off')
    end
    
%------------------------------------------------------------------------
% spectview('changeMethod')
%   callback of method popup
%   assumes spectview is current figure
case 'changeMethod'
    fig = gcf;
    ud = get(fig,'userdata');
    ind = ud.focusIndex;
    toolMethodNum = get(ud.hand.methodPopup,'value');
    methodNameList = get(ud.hand.methodPopup,'string');
    name = ud.methods(toolMethodNum).methodName;
    
    methodNum = findcstr(ud.spect(ind).specs.methodName,name);
    if isempty(methodNum)
        % need to add method to spect
        ud.spect(ind).specs.methodName{end+1} = name;
        ud.spect(ind).specs.valueArrays{end+1} = ...
                            ud.methods(toolMethodNum).default;
        methodNum = length(ud.spect(ind).specs.methodName);
        set(fig,'userdata',ud)
    end
    spectview('fillParams',fig,name,ud.spect(ind).specs.valueArrays{methodNum},...
              ud.spect(ind).confid)
    set([ud.hand.applyButton ud.hand.revertButton],'enable','on')
    
%------------------------------------------------------------------------
% spectview('paramChange',paramNum)
%   callback of uicontrol for a parameter
%   assumes spectview is current figure
case 'paramChange'
    paramNum = varargin{2};
    fig = gcf;
    ud = get(fig,'userdata');
    methodNum = get(ud.hand.methodPopup,'value');

    % if this is a popup menu, it might have subordinate parameters:
    if strcmp(get(ud.hand.uicontrol(paramNum),'style'),'popupmenu')
       popupVal = get(ud.hand.uicontrol(paramNum),'value');
       subs = ud.methods(methodNum).subordinates{paramNum};
       % need to update subordinate parameters
       for i=1:length(subs)
           changeParamType(ud.methods(methodNum).type{subs(i)}{popupVal},...
                           ud.methods(methodNum).default{subs(i)}{popupVal},...
                           ud.methods(methodNum).label{subs(i)}{popupVal},...
                           ud.methods(methodNum).popupString{subs(i)}{popupVal},...
                           ud.hand.label(subs(i)),ud.hand.uicontrol(subs(i)))
       end
    end
    
    set([ud.hand.applyButton ud.hand.revertButton],'enable','on')

%------------------------------------------------------------------------
% spectview('apply')
%   callback of apply button
%   assumes spectview is current figure
case 'apply'
    fig = gcf;
    ud = get(fig,'userdata');
    setptr(fig,'watch')
    drawnow
    
    methodNum = get(ud.hand.methodPopup,'value');
    
    numParams = length(ud.methods(methodNum).default);
    valueArray = cell(numParams,1);
    for i=1:numParams
        switch get(ud.hand.uicontrol(i),'style')
        case {'checkbox','radiobutton','popupmenu'}
            valueArray{i} = get(ud.hand.uicontrol(i),'value');
        otherwise
            valueArray{i} = get(ud.hand.uicontrol(i),'string');
        end
    end
    spect = ud.spect(ud.focusIndex);
    spect.specs.methodNum = findcstr(spect.specs.methodName,...
                                      ud.methods(methodNum).methodName);
    if isempty(spect.specs.methodNum)  % spectrum doesn't have this method
        % add this method to spectrum
        spect.specs.methodNum = length(spect.specs.methodName)+1;
        spect.specs.methodName{end+1} = ud.methods(methodNum).methodName;
    end
    spect.specs.valueArrays{spect.specs.methodNum} = valueArray;
    spect.confid.enable = get(ud.hand.confidenceCheckbox,'value');
    spect.confid.level = get(ud.hand.confidenceEdit,'string');
    
    oldFs = FsFromSpect(spect);
    [errstr,spect] = computeSpectrum(ud.methods,spect);
    
    if ~isempty(errstr)
        msgbox(errstr,'Error','error','modal')
    else
        ind = ud.focusIndex;
        magscale = findcstr(get(ud.hand.magscaleMenu,'checked'),'on');
        yd = spmagfcn(spect.P,magscale);
        xd = spect.f;
        set(ud.lines(ind).h,'xdata',xd,'ydata',yd)
        
        if spect.confid.enable & ud.methods(methodNum).confidenceFlag
            Pc = spect.confid.Pc;
            if isempty(ud.patches{ind})
                ud.patches{ind} = patch(0,0,...
                   confidPatchColor(get(ud.lines(ind).h,'color')),...
                   'edgecolor','none','parent',ud.mainaxes,... 
                   'uicontextmenu',ud.contextMenu.u,...
                   'buttondownfcn',['spectview(''linedown'',' ...
                                         num2str(ind) ')']);

                % reorder children:
                bringToFront(fig,[ud.lines(ind).h ud.patches{ind}])
            end
            verts = [[xd(:); flipud(xd(:))] ...
                      spmagfcn([Pc(:,1); flipud(Pc(:,2))],magscale)];
            N = length(verts(:,1));
            numFaces = N-2;
            faces = zeros(numFaces,3);
            faces(1:2:end,1) = (1:numFaces/2)';
            faces(2:2:end,1) = (2:numFaces/2+1)';
            faces(1:2:end,2) = (2:numFaces/2+1)';
            faces(2:2:end,2) = N - (1:numFaces/2)';
            faces(1:2:end,3) = N - (0:numFaces/2-1)';
            faces(2:2:end,3) = N - (0:numFaces/2-1)';
            set(ud.patches{ind},'vertices',verts,...
                         'faces',faces,...
                         'visible','on');
        else
            spect.confid.Pc = [];
            if ~isempty(ud.patches{ind})
                set(ud.patches{ind},'visible','off')
            end
        end
        
        % set up fields for panning:
        ud.lines(ind).data = spect.P;
        ud.lines(ind).Fs = -1;  % panfcn uses -1 for unequally spaced
        ud.lines(ind).t0 = spect.f(1);% starting "time" for panfcn
        ud.lines(ind).xdata = spect.f;  

        ud.spect(ind) = spect;
        set(fig,'userdata',ud)
        
        % Zoom out both X and Y
        spzoomout(ud,~isequal(oldFs,FsFromSpect(spect)))
                
        set([ud.hand.applyButton ud.hand.revertButton],'enable','off')
    
        % poke new spectrum data into SPTool:
        sptool('import',spect)
    end
    setptr(fig,'arrow')

%------------------------------------------------------------------------
% spectview('revert')
%   callback of revert button
%   assumes spectview is current figure
case 'revert'
    fig = gcf;
    ud = get(fig,'userdata');
    spect = ud.spect(ud.focusIndex);
    methodNum = spect.specs.methodNum;
    
    spectview('fillParams',fig,spect.specs.methodName{methodNum},...
         spect.specs.valueArrays{methodNum},spect.confid)
         
    set(ud.hand.revertButton,'enable','off')
    if ~isempty(spect.P)
        set(ud.hand.applyButton,'enable','off')
    end
    
%------------------------------------------------------------------------
% spectview('confidence',flag)
%   callback of Confidence Checkbox and Edit
%   flag is either 'check' or 'edit'
%   assumes spectview is current figure
case 'confidence'
    fig = gcf;
    ud = get(fig,'userdata');
    flag = varargin{2};
    switch flag
    case 'check'
        if get(ud.hand.confidenceCheckbox,'value')
            set(ud.hand.confidenceEdit,'enable','on')
        else
            set(ud.hand.confidenceEdit,'enable','off')
        end
    case 'edit'
        % do nothing
    end
    set([ud.hand.applyButton ud.hand.revertButton],'enable','on')
    
%------------------------------------------------------------------------
% spectview('inherit')
%   callback of Inherit from popupmenu
%   assumes spectview is current figure
case 'inherit'
    fig = gcf;
    ud = get(fig,'userdata');
    v = get(ud.hand.inheritPopup,'value');
    if v == 1
        return
    else
        popupStr = get(ud.hand.inheritPopup,'string');
        popupUd = ud.inheritList;  % get(ud.hand.inheritPopup,'userdata');
        if ~isempty(popupUd) & v==length(popupStr)
           % user selected 'More...'
           [selection,ok] = listdlg('ListString',popupUd,...
             'SelectionMode','single',...
             'PromptString',...
             {'Select a Spectrum from which to inherit properties:'},...  
             'Name','Inherit Properties');
           if ~ok
               return
           end
           label = popupUd{selection};
        else
           label = popupStr{v};
        end
        
        spect = sptool('Spectra');
        ind = findcstr({spect.label},label);
        
        if isempty(spect(ind).specs) % use default method specs
            methodNum = 1;
            methodPopupStr =  get(ud.hand.methodPopup,'string');
            methodName = methodPopupStr{methodNum};
            valueArray = ud.methods(methodNum).default;
        else
            methodNum = spect(ind).specs.methodNum;
            methodName = spect(ind).specs.methodName(methodNum);
            valueArray = spect(ind).specs.valueArrays{methodNum};
        end
        if isempty(spect(ind).confid) % use default confidence specs
            confid.enable = 0;
            confid.level = '.95';
            confid.Pc = [];
        else       
            confid = spect(ind).confid;
        end

        spectview('fillParams',fig,methodName,valueArray,confid)
        
        set([ud.hand.applyButton ud.hand.revertButton],'enable','on')
        
        set(ud.hand.inheritPopup,'value',1);
    end
%------------------------------------------------------------------------
% errstr = spectview('setprefs',panelName,p)
% Set preferences for the panel with name panelName
% Inputs:
%   panelName - string; must be either 'ruler','color', or 'spectview'
%              (see sptprefreg for definitions)
%   p - preference structure for this panel
case 'setprefs'
    errstr = '';
    panelName = varargin{2};
    p = varargin{3};
    switch panelName
    case 'ruler'
        rc = evalin('base',p.rulerColor,'-1');
        if rc == -1
            errstr = 'The Ruler Color you entered cannot be evaluated.';
        elseif ~iscolor(rc)
            errstr = 'The Ruler Color you entered is not a valid color.';
        end
        if isempty(errstr)
            ms = evalin('base',p.markerSize,'-1');
            if ms == -1
                errstr = 'The Marker Size you entered cannot be evaluated.';
            elseif all(size(ms)~=1) | ms<=0 
                errstr = 'The Marker Size you entered must be a real scalar.';     
            end
        end
    case 'color'
        co = evalin('base',p.colorOrder,'-1');
        if co == -1
            errstr = 'The Color Order that you entered cannot be evaluated.';
        else
            if ~iscell(co)
                co = num2cell(co,[3 2]);  % convert to cell array
            end
            for i = 1:length(co)
                if ~iscolor(co{i})
                    errstr = 'The Color Order that you entered is invalid.';
                    break
                end
            end
        end
    
        if isempty(errstr)
            lso = evalin('base',p.linestyleOrder,'-1');
            if lso == -1
                errstr = 'The Line Style Order that you entered cannot be evaluated.';
            else
                if ~iscell(lso)
                    lso = num2cell(lso,[3 2]);  % convert to cell array
                end
                for i = 1:length(lso)
                    if isempty(findcstr({'-' '--' ':' '-.'},lso{i}))
                        errstr = 'The Line Style Order that you entered is invalid.';
                        break
                    end
                end
            end
        end
        
    case 'spectview'
    end
    varargout{1} = errstr;
    if ~isempty(errstr)
        return
    end
    
    fig = findobj('type','figure','tag','spectview');
    if ~isempty(fig)
        ud = get(fig,'userdata');
        newprefs = ud.prefs;
        switch panelName
        case 'ruler'
            markerStr = { '+' 'o' '*' '.' 'x' ...
               'square' 'diamond' 'v' '^' '>' '<' 'pentagram' 'hexagram'}';
            newprefs.ruler.color = p.rulerColor;
            newprefs.ruler.marker = markerStr{p.rulerMarker};
            newprefs.ruler.markersize = p.markerSize;
            
            if ud.prefs.tool.ruler
                rc = evalin('base',newprefs.ruler.color);
                set(ud.ruler.lines,'color',rc);
                set(ud.ruler.markers,'color',rc,'marker',newprefs.ruler.marker,...
                   'markersize',evalin('base',newprefs.ruler.markersize))
                set([ud.ruler.hand.marker1legend ud.ruler.hand.marker2legend],'color',rc)
            end
        case 'color'
            newprefs.colororder = p.colorOrder;
            newprefs.linestyleorder = p.linestyleOrder;
            ud.colororder = num2cell(evalin('base',newprefs.colororder),2);
            ud.linestyleorder = num2cell(evalin('base',newprefs.linestyleorder),2);
        case 'spectview'
            newprefs.tool.ruler = p.rulerEnable;
            newprefs.tool.zoompersist = p.zoomFlag;

           % resize flag
            rbrowse = 0; 
             % enable / disable ruler
            if ud.prefs.tool.ruler~=newprefs.tool.ruler
                if newprefs.tool.ruler
                    % turn ruler on
                    rulerPrefs = sptool('getprefs','ruler');
                    typeStr = {'vertical','horizontal','track','slope'};
                    ud.prefs.ruler.type = typeStr{rulerPrefs.initialType};
                    set(fig,'userdata',ud)
                    ruler('init',fig)
                    ud = get(fig,'userdata');
                    ud.ruler.evenlySpaced = 0;
                    set(fig,'userdata',ud)
                    ruler('showlines',fig)
                    ruler('newlimits',fig)
                    ruler('newsig',fig)
                else
                    ruler('close',fig)
                end
                ud = get(fig,'userdata');
                rbrowse = 1;
            end

            % resize objects if necessary:
            if rbrowse, 
                spresize(0,fig)
                if newprefs.tool.ruler
                    ruler('resizebtns',fig)
                end
            end
            
            switch p.magscale
            case 1   % 'db'
                spectview('magscale','db',fig,0)
            case 2   % 'linear'
                spectview('magscale','lin',fig,0)
            end
            switch p.freqscale
            case 1  % linear
                spectview('freqscale','lin',fig,0)
            case 2  % log
                spectview('freqscale','log',fig,0)
            end
            switch p.freqrange
            case 1  % half
                spectview('freqrange','half',fig,0)
            case 2  % whole
                spectview('freqrange','whole',fig,0)
            case 3  % neg
                spectview('freqrange','neg',fig,0)
            end
        end
        ud.prefs = newprefs;
        set(fig,'userdata',ud)
    end

otherwise
% string not recognized
    disp(sprintf('spectview: %s',varargin{1}))
end


function changeParamType(type,val,label,popupString,labelHand,uicontrolHand)
%Changes type (if necessary) of uicontrolHand ...
% also changes visibility of label, and position, if necessary
% and also, the value of the uicontrol
%Inputs:
%   type - string; may be 'edit' 'popupmenu' 'checkbox' 'radiobutton'
%   val - string or integer; used to set the uicontrol's value
%   label - string; ignored in case type == 'checkbox' or 'radiobutton'
%   popupString - cell array of strings; in case type == 'popupmenu',
%       the uicontrol's string will be set to this
%   labelHand - handle to label
%   uicontrolHand - handle to uicontrol

set(uicontrolHand,'visible','on')
if ~strcmp(type,get(uicontrolHand,'type'))  % need to change type
   uibgcolor = get(0,'defaultuicontrolbackgroundcolor');    
   set(uicontrolHand,'style',type)
   switch type
   case 'edit'
        if isempty(label)
            set(uicontrolHand,'visible','off')
        end
        set(uicontrolHand,'backgroundcolor','w',...
                          'horizontalalignment','left',...
                          'string',val)
        set(labelHand,'visible','on','string',label)
   case {'checkbox','radiobutton'}
        set(uicontrolHand,'backgroundcolor',uibgcolor,...
                          'horizontalalignment','center',...
                          'string',label,...
                          'min',0,'max',1,...
                          'value',val)
        set(labelHand,'visible','off')
   case 'popupmenu'
        set(uicontrolHand,'backgroundcolor','white',...
                          'horizontalalignment','center',...
                          'string',popupString,...
                          'min',1,'max',length(popupString),...
                          'value',val)
        set(labelHand,'visible','on','string',label)
   otherwise
        set(uicontrolHand,'backgroundcolor',uibgcolor,...
                          'horizontalalignment','center')
        set(labelHand,'visible','on','string',label)
   end
   spresize('paramPosition',uicontrolHand)
else  % don't need to change type or position, but still need to
      % change values and strings
   switch type
   case 'edit'
        if isempty(label)
            set(uicontrolHand,'visible','off')
        end
        set(uicontrolHand,'string',val)
        set(labelHand,'visible','on','string',label)
   case {'checkbox','radiobutton'}
        set(uicontrolHand,'value',val,'string',label)
   case 'popupmenu'
        set(uicontrolHand,'string',popupString,'value',val)
        set(labelHand,'visible','on','string',label)
   otherwise
        set(labelHand,'visible','on','string',label)
   end
end

function yd = spmagfcn(yd,magscale);
% Converts yd to dB if magscale == 1
if magscale == 1
   yd = 10*log10(yd);
end

function [errstr,spect] = computeSpectrum(methods,spect);
%computeSpectrum
% Attempts to compute Power Spectrum based on input spect structure
% Inputs:
%    methods - structure array; as returned from spregistry
%    spect - spectrum structure
% Outputs:
%    errstr - empty if no error; otherwise contains string indicating
%             what went wrong
%    spect - updated spectrum structure; spect.f,spect.P, and possibly
%            spect.confid.Pc are changed

    errstr = '';
    methodName = spect.specs.methodName{spect.specs.methodNum};
    ToolMethodNum = findcstr({methods.methodName},methodName);
    valueArray = spect.specs.valueArrays{spect.specs.methodNum};
    
    labels = methods(ToolMethodNum).label;
    for i=1:length(valueArray)
        for j=methods(ToolMethodNum).subordinates{i}
            labels{j} = labels{j}{valueArray{i}};
        end
    end

    for i=1:length(valueArray)
       % evaluate strings
       if isstr(valueArray{i}) & ~isempty(labels{i})
           [valueArray{i},err] = getWorkspaceVariable(valueArray{i});
           if err==1
               errstr = sprintf('Sorry, couldn''t evaluate ''%s''.',labels{i});
               return
           elseif err == 2
               errstr = ...
               sprintf('Sorry, you must specify a value for ''%s''.',labels{i});
               return
           end
       end
    end
    
    sigStruc = sptool('Signals');
    
    sigInd = findcstr({sigStruc.label},spect.signalLabel);
    sigdata = sigStruc(sigInd).data;
    
    if spect.confid.enable & methods(ToolMethodNum).confidenceFlag
        [confidenceLevel,err] = getWorkspaceVariable(spect.confid.level);
        if err==1
           errstr = 'Sorry, couldn''t evaluate the Confidence Level.';
           return
        elseif err == 2
           errstr = 'Sorry, you must specify a Confidence Level.';
           return
        end
        [errstr,spect.P,spect.f,spect.confid.Pc] = ...
             feval(methods(ToolMethodNum).computeFcn,sigdata,spect.Fs,...
                  valueArray,confidenceLevel);
    else
        [errstr,spect.P,spect.f] = ...
             feval(methods(ToolMethodNum).computeFcn,sigdata,spect.Fs,...
                  valueArray);
    end
    
    
function varargout = getWorkspaceVariable(varargin)
%getWorkspaceVariable
% [var,err] = getWorkspaceVariable(varName)
% Returns the var 'varName' in the workspace. 
% err = 2 if the string is empty,
%       1 if there is an error in evaluating the string, 
%       0 if OK
if isempty(varargin{1})
    varargout{1} = [];
    varargout{2} = 2;
    return
end
err = 0;
varargout{1} = evalin('base',varargin{1},'''ARBITRARY_STRING''');
if isequal(varargout{1},'ARBITRARY_STRING')
    err = 1;
end
if err
    varargout{1} = [];
end
varargout{2}=err;


function inheritList = newInheritString(inheritPopup,labelList,maxPopupEntries)
%newInheritString
%  Sets popup string to the given labelList
%  Inputs:
%     inheritPopup - handle to popupmenu
%     labelList - cell array of strings
%     maxPopupEntries - maximum number of entries in a popupmenu
%  On output:
%    String will be
%     {'Inherit from' label1 label2 ... labelN} if N<=maxPopupEntries-1
%      and inheritList will contain []
%    OR
%     {'Inherit from' label1 label2 ... labelM 'More...'} if N>maxPopupEntries-1
%      and inheritList will contain labelList
%      where M = maxPopupEntries-2

N = length(labelList);
if N>maxPopupEntries-1
    set(inheritPopup,'string',{'Inherit from' labelList{1:maxPopupEntries-2} ...
        'More...'})
    inheritList = labelList;
else
    set(inheritPopup,'string',{'Inherit from' labelList{:}})
    inheritList = [];
end

function bringToFront(fig,h)
%bringToFront
%  reorders children of ud.mainaxes so that 
%   the objects with handles in h are just above all the objects
%   except for the ruler lines

   ud = get(fig,'userdata');
   ch = get(ud.mainaxes,'children');
   ch = ch(:);
   if ud.prefs.tool.ruler
      % make sure ruler lines are on top of stacking order
      h = [ud.ruler.lines(:); ud.ruler.markers(:); h(:)];
   else
      h = h(:);
   end
   
   ch1 = ch;
   for i=1:length(h)
       ch1(find(ch1==h(i))) = [];
   end
   ch1 = [h; ch1(:)];
   if ~isequal(ch,ch1)  % avoid redraw if child order hasn't changed
       set(ud.mainaxes,'children',ch1(:))
   end

function c = confidPatchColor(c)
%confidPatchColor 
%  c = confidPatchColor(c) returns the color (an rgb triple) for a 
%  confidence interval corresponding
%  to a line of color c.

    c = .5*c;
    
function spzoomout(ud,xflag,rulerFlag)
% reset limits of mainaxes, and set Full View limits (ud.limits field)
% Inputs:
%   ud - userdata struct
%   xflag - 1 ==> zoom out in x
%           0 ==> keep xlimits the same
%   rulerFlag (optional) - 1 ==> update rulers (default)
%                          0 ==> don't update rulers
% CAUTION: Sets figure userdata !!!!!

    if nargin < 3
        rulerFlag = 1;
    end
    
    fig = get(ud.mainaxes,'parent');
    
    % turn off rulers for limits calculation:
    if ud.prefs.tool.ruler
        h = [ud.ruler.lines(:); ud.ruler.markers(:)];
        set(h,'visible','off')
    end
        
    % zoom out
    set(ud.mainaxes,'ylimmode','auto')
    if isempty(ud.spect)
        xlim = get(ud.mainaxes,'xlim');
        ylim = get(ud.mainaxes,'ylim');
    elseif xflag   % FULL VIEW
        Fs = maxFs(ud.spect);
        checks = get(ud.hand.freqrangeMenu,'checked');
        checkInd = findcstr(checks,'on');
        xlim = xRange(checkInd,Fs);
        ud.limits.xlim = xlim;
        set(ud.mainaxes,'xlim',xlim)
        ylim = get(ud.mainaxes,'ylim');
        ud.limits.ylim = ylim;
    else   % only zoom out Y, but update ud.limits to FULL VIEW
        xlim = get(ud.mainaxes,'xlim');
        Fs = maxFs(ud.spect);
        checks = get(ud.hand.freqrangeMenu,'checked');
        checkInd = findcstr(checks,'on');
        ud.limits.xlim = xRange(checkInd,Fs);
        set(ud.mainaxes,'xlim',ud.limits.xlim);
        ud.limits.ylim = get(ud.mainaxes,'ylim');
        set(ud.mainaxes,'xlim',xlim)
        ylim = get(ud.mainaxes,'ylim');
    end
    scaleChecks = get(ud.hand.freqscaleMenu,'checked');
    scaleCheckInd = findcstr(scaleChecks,'on');
    if scaleCheckInd == 1  % linear scale
        xlim = inbounds(xlim,ud.limits.xlim);
    else                   % log scale
        xlim = inbounds(xlim,ud.limits.xlim,1);
        if ~isempty(get(ud.lines(1).h,'xdata'))
            % Make sure that x-axes lower limit is not 0
            xlim = setLogscaleLims(ud.mainaxes,ud.lines,'xlim');
            set(ud.mainaxes,'xlim',xlim)
            ud.limits.xlim = xlim;
        end
    end
    set(ud.mainaxes,'xlim',xlim,'ylim',ylim)

    set(fig,'userdata',ud)
    
    if ud.prefs.tool.ruler & rulerFlag
        ruler('showlines',fig)
        ruler('newlimits',fig)
        ruler('newsig',fig)
    end

function Fs = maxFs(spect);
%maxFs - finds maximum sampling frequency from struct array of spectra structs
%
        Fs = zeros(length(spect),1);
        for i=1:length(spect)
            Fs(i) = FsFromSpect(spect(i));
        end
        Fs = max(Fs);
        if Fs==0
            Fs = 1;
        end

       
function Fs = FsFromSpect(spect)
     Fs = 0;
     if ~isstr(spect.signal)
        Fs = spect.Fs;
     else
        if ~isempty(spect.f)
            % by multiplying by 2, we can see the entire spectrum when
            % in -Fs/2,Fs/2 range:
            Fs = 2*max(abs(spect.f));
            if Fs==0
                Fs = 1;
            end
        end
     end

function xlim = xRange(checkInd,Fs)
%xRange - returns maximum xlimits given checkInd:
%    checkInd == 1:  [0, Fs/2]
%    checkInd == 2:  [0, Fs]
%    checkInd == 3:  [-Fs/2, Fs/2]
       
        switch checkInd
        case 1    % [0, Fs/2]
            xlim = [0 Fs/2];
        case 2    % [0, Fs]
            xlim = [0 Fs];
        case 3    % [-Fs/2, Fs/2]
            xlim = [-Fs/2 Fs/2];
        end

function updateSignalInfo(ud,signalLabel,datasize,Fs)
%updates Signal area of spectrum viewer

    if isempty(signalLabel)
        set(ud.hand.signalLabel,'string','Signal')
    
        if isstr(datasize)
            set(ud.hand.siginfo1Label,'string','<None>')
        else
            set(ud.hand.siginfo1Label,'string','')
        end
        set(ud.hand.siginfo2Label,'string','')
    
    else
        set(ud.hand.signalLabel,'string',...
                sprintf('Signal: %s', signalLabel))
        m=datasize(1);
        n=datasize(2);
        if ~datasize(end)
            complexStr = 'real';
        else
            complexStr = 'complex';
        end 
        siginfo1Str = sprintf('%g-by-%g %s',m,n,complexStr);
        siginfo2Str = sprintf('Fs = %.9g',Fs);
        set(ud.hand.siginfo1Label,'string',siginfo1Str)
        set(ud.hand.siginfo2Label,'string',siginfo2Str)
    end

    % reposition the signal label after string change:
    slExtent = get(ud.hand.signalLabel,'extent');
    sfp = get(ud.hand.signalFrame,'position');
    set(ud.hand.signalLabel,'position',...
        [sfp(1)+ud.sz.lbs sfp(2)+sfp(4)-ud.sz.lh/2 ...
                       slExtent(3)+2*ud.sz.lbs  ud.sz.lh ]);

function lim = setLogscaleLims(mainaxes,lines,XorYlim)
% SETLOGSCALELIMS - Set lower bound of the X- or Y-limit to a positive
% number in case the axes scale is set to log.
% Inputs:
%   mainaxes - the axes where the rulers are
%   lines - list of handles of all possible lines
%   XorYlim - a string indicating which axes limit to change, 'xlim' or
%             'ylim'
% Outputs:
%   lim - new axes limits; it's either new X-limits or Y-limits, depending
%         on the value of the input string XorYlim
%
    switch XorYlim
    case 'xlim'
        XorYdata = 'xdata';
    case 'ylim'
        XorYdata = 'ydata';
    end

    lim = get(mainaxes,XorYlim);
    for i = 1:length(lines)
        data = get(lines(i).h,XorYdata);
        dataInd = find(data > 0);
        if ~isempty(dataInd)
            posData(i) = data(dataInd(1));
        else
            % Must do something about spectrum with only negative data
        end   
    end
    if lim(1) <= 0 & ~isempty(dataInd),
        lim(1) = min(posData);
    else
        lim = lim;
    end


function spect = resolveLinks(spect,ind,SPTfig)
%resolveLinks  - search for signals linked to selected spectra
%        If a link is found and the signal is not present, or
%        the given signal has the wrong size, the spectrum is
%        updated to reflect the signal information and is imported
%        to the SPTool.
    sigs = sptool('Signals',1,SPTfig);
    if ~isempty(sigs)
        sigLabels = {sigs.label};
    else
        sigLabels = {};
    end
    for i=1:length(spect(ind))
        if ~isempty(spect(ind(i)).signalLabel) 
        % found a link!
            sigInd = findcstr(sigLabels,spect(ind(i)).signalLabel);
            if ~isempty(sigInd)
                sigInfo = [size(sigs(sigInd).data) ~isreal(sigs(sigInd).data)];
            end
            if isempty(sigInd)
            % the signal is not present,  so un-link the signal
                spect(ind(i)).signalLabel = '';
                spect(ind(i)).signal = 'none';
                doImport = 1;
            elseif ~isequal(sigInfo,spect(ind(i)).signal)
            % if spectrum is linked to signal, .signal field of spectrum contains
            % the following 3-element vector:
            %    [size(signal.data,1) size(signal.data,2) ~isreal(signal.data)]
                spect(ind(i)).signal = sigInfo;
                doImport = 1;
            else
                doImport = 0;
            end
            if doImport     % import changed struct to sptool
                sptool('import',spect(ind(i)),0,SPTfig)
            end
        end
    end
    
    
