function pickfcn(action,varargin)
%PICKFCN Handle callbacks for the current line selection.
%   Assumes signal browser is the current figure.
 
%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.9 $

%   TPK 12/4/95

if nargin<1
    error('pickfcn must have at least one argument')
end

if ~isstr(action)
%pickfcn(i,j)
%   buttondownfcn of line object corresponding to ith variable and
%   its jth column
%
% User has clicked on a line in the main axes.
    fig = gcf;
    ud = get(fig,'userdata');
   
    if ud.pointer == 2  % help mode
        sbhelp('pickfcn',action)
        return
    end

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
       % name of the currently selected signal, and also
       % set visibility of the context menu items based
       % on the current GUI state.
       i = action;
       j = varargin{1};
       sigbrowse('uicontextmenu',i,j)
       return
    end

    var_num = action;
    col = varargin{1};
    col = find(ud.lines(var_num).columns == col);

    panpatch = [];
    if ud.prefs.tool.panner
       panpatch = ud.panner.panpatch;
    end
    invis = [];
    if ud.prefs.tool.ruler
        invis = [ud.ruler.lines ud.ruler.markers ud.ruler.hand.buttons]';
    end
    if strcmp(get(ud.toolbar.complex,'enable'),'on')
        switch get(ud.toolbar.complex,'userdata')
        case 1, xform = 'real';
        case 2, xform = 'imag';
        case 3, xform = 'abs';
        case 4, xform = 'angle';
        end
    else
        xform = 'real';
    end
    if panfcn('Ax',ud.mainaxes,...
           'Bounds',ud.limits,...
           'BorderAxes',ud.mainaxes_border,...
           'PannerPatch',panpatch,...
           'Data',ud.lines,...
           'Immediate',0,...
           'Transform',xform,...
           'InterimPointer','fleur',...
           'Invisible',invis)
        if ud.prefs.tool.ruler
            ruler('newlimits')
        end
    end

    if ud.lines(var_num).h(col) == ud.focusline
        return
    end

else
    switch action 
 
    case 'noMouse'
    %  pickfcn('nomouse',i,j)
    %  pickfcn('nomouse',i,j,fig)
    %     picks the j'th column of the i'th variable
        if nargin < 4
            fig = gcf;
        else
            fig = varargin{3};
        end
        ud = get(fig,'userdata');

        var_num = varargin{1};
        col = varargin{2};
    end
end

% at this point we have col and var_num
%
%  var_num == 0 ==> no variables selected

if var_num == 0 | isempty(ud.lines)    
    ud.focusline = [];
    ud.focusIndex = [];
    set(fig,'userdata',ud);

    if ud.prefs.tool.ruler
        ruler('showlines',fig)
        ruler('newlimits',fig)
        ruler('newsig',fig)
    end

else
    the_line = ud.lines(var_num).h(col);

    num_cols = size(ud.lines(var_num).data,2);

    ud.focusline = ud.lines(var_num).h(col);
    ud.focusIndex = var_num;
    ud.focusColumn = col;
    set(fig,'userdata',ud);

    % reorder children of ud.mainaxes here!    
    bringToFront(fig,ud.lines(var_num).h([col 1:col-1 col+1:end]))
    if ud.prefs.tool.panner
        bringToFront(fig,ud.lines(var_num).ph([col 1:col-1 col+1:end]))
    end
    
    defaultLineWidth = get(0,'defaultlinelinewidth');
    for i=1:length(ud.sigs)
        set(ud.lines(i).h,'linewidth',defaultLineWidth)
        if ud.prefs.tool.panner
             set(ud.lines(i).ph,'linewidth',defaultLineWidth)
        end
    end
    
    if length(ud.lines(var_num).columns)>1
        set(ud.lines(var_num).h(col),'linewidth',2)
        if ud.prefs.tool.panner
            set(ud.lines(var_num).ph(col),'linewidth',2)
        end
    end
      
    sptlegend('setvalue',the_line,var_num,ud.sigs(var_num).lineinfo.columns(col),fig)
    
    if ud.prefs.tool.ruler
        ruler('showlines',fig)
        ruler('newlimits',fig)
        ruler('newsig',fig)
    end
end

function bringToFront(fig,h)
%bringToFront
%  reorders children of parent axis of h so that 
%   the objects with handles in h are just above all the objects
%   except for the ruler lines

   if isempty(h),
       return
   end
   
   ud = get(fig,'userdata');
   ax = get(h(1),'parent');
   ch = get(ax,'children');
   ch = ch(:);
   if ud.prefs.tool.ruler & (ud.mainaxes == ax)
      % make sure ruler lines are on top of stacking order
      h = [ud.ruler.lines(:); ud.ruler.markers(:); h(:)];
   elseif ud.prefs.tool.panner & (ud.panner.panaxes == ax)
      % make sure panner patch is on top of stacking order
      h = [ud.panner.panpatch; h(:)];
   else
      h = h(:);
   end
   
   ch1 = ch;
   for i=1:length(h)
       ch1(find(ch1==h(i))) = [];
   end
   ch1 = [h; ch1(:)];
   if ~isequal(ch,ch1)  % avoid redraw if child order hasn't changed
       set(ax,'children',ch1(:))
   end

