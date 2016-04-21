function varargout = sptlegend(varargin)
%SPTLEGEND  SPTool Legend facility for picking one of multiple items.
%
% sptlegend(fig,callback,newColorCallback)
%    initializes sptlegend (call after zoombar)
%    adds .legend field to userdata of figure with handle fig.
% Inputs:
%    fig - figure in which to install legend
%    callback - string; when a change occurs to the legend pick, sptlegend
%      will eval this string
%    newColorCallback - string; this function will be called when the line
%      style and/or line color have changed; calling sequence:
%          feval(newColorCallback,'newColor',lineColor,lineStyle)
%      Before calling this, this function will set the style and color of
%      ud.focusline

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.10 $

if nargin == 0
    action = 'init';
    fig = gcf;
    callback = '';
elseif ~isstr(varargin{1})
    action = 'init';
    fig = varargin{1};
    if nargin >= 2
        callback = varargin{2};
    else
        callback = '';
    end
else
    action = varargin{1};
end
% "Globals" - defined each time function is called
pw = 90;  % popup width
bw = 65;  % button width
maxPopupEntries = 24;

switch action
case 'init'    
    ud = get(fig,'userdata');

    leg.callback = callback;
    if nargin > 2
        leg.newColorCallback = varargin{3};
    else
        leg.newColorCallback = '';
    end
   
    ud.legend = leg;
    set(fig,'userdata',ud)

%--------------------------------------------------------------------
% sptlegend('popup')
%  Callback of popupmenu. 
%  NOTE: NOW THIS IS THE CALLBACK OF THE UIPUSHTOOL FOR LINE
%  SELECTION!!! - TPK  5/29/99
case 'popup'
    fig = gcf;
    ud = get(fig,'userdata');

    if ud.pointer==2   % help mode
        spthelp('exit','select_pushtool')
        return
    end

    ud_s = get(ud.toolbar.select,'userdata');
    legendList = ud_s.string;
    val = ud_s.value;
    columns = ud_s.columns;  % cell array of index vectors
    i = ud_s.i;  % position within sptool list
    j = ud_s.j;  % column within array signal
    ind = 0;
    for ii=1:i-1
        ind = ind+length(columns{ii});
    end
    ind = ind + find(columns{i}==j);
    %  User selected "More..." so put up listdlg
    [val,ok] = listdlg('Name','Select a trace:',...
         'SelectionMode','Single',...
         'ListString',legendList,...
         'OKString','OK',...
         'InitialValue',ind);
    if ~ok | val==ud_s.value
         % user cancelled or picked the same signal, so just return
        return
    end

    set(ud.toolbar.select,'tooltipstring',...
           sprintf('Select Trace...\nCurrently Selected: %s',legendList{val}))
    
    searchVal = 0;
    i=0;
    j=0;
    while searchVal < val
        i=i+1;
        searchVal = searchVal + length(columns{i});
    end
    j = length(columns{i}) - searchVal + val;

    % Store new state information:
    ud_s.i = i;
    ud_s.j = j;
    ud_s.value = val;
    set(ud.toolbar.select,'userdata',ud_s)

    evalin('base',ud.legend.callback)
    
%--------------------------------------------------------------------
% [i,j] = sptlegend('value',fig)
%   return which matrix and column is currently selected
%   fig is optional - defaults to gcf
case 'value'
    if nargin > 1
        fig = varargin{2};
    else
        fig = gcf;
    end
    ud = get(fig,'userdata');
    ud_s = get(ud.toolbar.select,'userdata');
    i = ud_s.i;  % position within sptool list
    j = ud_s.j;  % column within array signal

    varargout{1} = i;
    if nargout > 1
        varargout{2} = j;
    end
    
%--------------------------------------------------------------------
% sptlegend('setvalue',lineHandle,i,j,fig)
%   set which matrix and column is currently selected
%   also set color and linestyle of legendline to that of lineHandle
%   j is optional and defaults to 1
%   fig is optional and defaults to gcf
%
%  NOTE: (TPK, 5/29/99)  THE LEGENDLINE no longer exists
%     with the toolbar implementation, so the lineHandle 
%     parameter is ignored.
case 'setvalue'
    lineHandle = varargin{2};
    i = varargin{3};
    if nargin < 4
        j = 1;
    else
        j = varargin{4};
    end
    if nargin < 5
        fig = gcf;
    else
        fig = varargin{5};
    end
    
    ud = get(fig,'userdata');
    ud_s = get(ud.toolbar.select,'userdata');
    columns = ud_s.columns;  % cell array of index vectors
    
    legendList = ud_s.string;
    if ~isempty(legendList) & ~isempty(i)
        ind = 0;
        for ii=1:i-1
            ind = ind+length(columns{ii});
        end
        ind = ind + find(columns{i}==j);

        ud_s.value = ind;
        ud_s.i = i;
        ud_s.j = j;
        set(ud.toolbar.select,'userdata',ud_s)

        set(ud.toolbar.select,'enable','on')
        set(ud.toolbar.lineprop,'enable','on')
        set(ud.toolbar.select,'tooltipstring',...
           sprintf('Select Trace...\nCurrently Selected: %s',legendList{ind}))
        
    else
        set(ud.toolbar.select,'enable','off')
        set(ud.toolbar.lineprop,'enable','off')
        set(ud.toolbar.select,'tooltipstring',...
           sprintf('Select Trace...\nCurrently Selected: <none>'))
    end

%--------------------------------------------------------------------
% sptlegend('setstring',labels,columns,fig,retainValueFlag)
%   set the popup choices of the legendPopup
%   labels - cell array of labels
%   columns - cell array of index vectors - optional, defaults to
%       1 for each entry of labels.  If this is an empty cell array,
%       then assume 1 for each label.
%   fig is optional and defaults to gcf
%   retainValueFlag - optional - defaults to 0, determines if the
%      popupmenu's value should be changed
%       == 1 ==> don't change value
%       == 0 ==> set value to 1
%
%  NOTE: (TPK, 5-29-99) THIS FUNCTION IS NOW CHANGED TO USE
%   TOOLBARS.  IN PARTICULAR, the state information in
%   the userdata structure of ud.toolbar.select, and its tooltipstring,
%   are set according to the input parameters.
case 'setstring'
   labels = varargin{2};
   N = length(labels);
   if (nargin >= 3)
       columns = varargin{3};
       if length(columns)==0
           columns = cell(N,1);
           for i=1:N
               columns{i} = 1;
           end
       end
   else
       columns = cell(N,1);
       for i=1:N
           columns{i} = 1;
       end
   end
   if nargin < 4
       fig = gcf;
   else
       fig = varargin{4};
   end
   if nargin < 5
       retainValueFlag = 0;
   else
       retainValueFlag = varargin{5};
   end
   legendStr = {};    
   for i=1:length(labels)
        N = length(columns{i});
        for j=1:N
            if N>1 | ( columns{i}(j) > 1 )
                str = [labels{i} '(:,' num2str(columns{i}(j)) ')'];    
            else
                str = labels{i};
            end
            legendStr = {legendStr{:} str};
        end
   end

   ud = get(fig,'userdata');
   ud_s = get(ud.toolbar.select,'userdata');
   if retainValueFlag
   % Note: the legendStr may have changed, hence it may be
   % impossible to retain the value.
       old_i=ud_s.i; old_j=ud_s.j;  old_val = ud_s.value;
       old_legendStr = ud_s.string;
       new_val = find(strcmp(old_legendStr{old_val},legendStr));
       if isempty(new_val)
           %val = 1; i=1; j=1;
           val = old_val; i=old_i; j=old_j; 
       else
           val = new_val;
           searchVal = 0;
           i=0; j=0;
           while searchVal < val
              i=i+1;
              searchVal = searchVal + length(columns{i});
           end
           j = length(columns{i}) - searchVal + val;
       end
   else
       i=1; j=1; val = 1;
   end
   ud_s.string = legendStr;
   ud_s.columns = columns;
   ud_s.value = val;
   ud_s.i = i;
   ud_s.j = j;
   if length(legendStr) == 0
       set(ud.toolbar.select,'enable','off')
       set(ud.toolbar.lineprop,'enable','off')
       set(ud.toolbar.select,'tooltipstring',...
           sprintf('Select Trace...\nCurrently Selected: <none>'))
   else
      set(ud.toolbar.select,'enable','on')
      set(ud.toolbar.lineprop,'enable','on')
      set(ud.toolbar.select,'tooltipstring',...
           sprintf('Select Trace...\nCurrently Selected: %s',legendStr{val}),...
           'userdata',ud_s)
   end
   if retainValueFlag
       sptlegend('setvalue',[],i,j,fig)
   end
   
%--------------------------------------------------------------------
% sptlegend('button')
%   Edit line colors
%   Assumptions: current figure has ud struct containing
%    valid .focusline (line handle) and .colororder (cell array of
%    colorspecs) and .mainaxes
%
%  NOTE: NOW THIS IS THE CALLBACK OF THE UIPUSHTOOL FOR LINE
%  PROPERTIES!!! - TPK  5/29/99
case 'button'
    fig = gcf;
    ud = get(fig,'userdata');

    if ud.pointer==2   % help mode
        spthelp('exit','lineprop_pushtool')
        return
    end

    ud_s = get(ud.toolbar.select,'userdata');
    val = ud_s.value;
    str = ud_s.string;
    label = str{val};
    
    [lineColor,lineStyle,ok] = speditline(ud.focusline,label, ...
        ud.colororder,'white'); 
    if ok
        %set(ud.legend.legendline,'color',lineColor,'linestyle',lineStyle)
        if ~isempty(ud.focusline)
            if ~strcmp(get(ud.focusline,'linestyle'),'none')
                % Don't change line style markers.
                set(ud.focusline,'linestyle',lineStyle)
            end
            set(ud.focusline,'color',lineColor)
            %set(ud.legend.legendpatch,'facecolor',...
            %    get(get(ud.focusline,'parent'),'color'));
        end
        % also update .lineinfo struct in given structure
        if ~isempty(ud.legend.newColorCallback)
            feval(ud.legend.newColorCallback,'newColor',lineColor,lineStyle)
        end
    end
    
end

