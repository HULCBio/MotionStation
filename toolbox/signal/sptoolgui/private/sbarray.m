function varargout = sbarray(varargin)
%SBARRAY  Array Signals Display Manager for Signal Browser.
%  [ind,columns] = sbarray(sigs)
%  Inputs:
%     sigs - structure array of array signals
%  Outputs:
%     ind - integer index of the signal in sigs whose column index was changed
%           [] if cancel was hit
%     columns - (non-empty) index vector for sigs(ind)

%   Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.10.4.2 $

if nargin == 0 | ~isstr(varargin{1})
    action = 'init';
else
    action = varargin{1};
end

switch action
%------------------------------------------------------------------------
%  [ind,columns] = sbarray(sigs)
%  Inputs:
%     sigs - structure array of array signals
%  Outputs:
%     ind - integer index of the signal in sigs whose column index was changed
%           [] if cancel was hit
%     columns - (non-empty) index vector for sigs(ind)
case 'init'
    sigs = varargin{1};
    
    figname = 'Column Selection for Array Signals';
    okstring = 'OK';
    cancelstring = 'Cancel';
    fus = 5;  % frame / uicontrol spacing
    ffs = 8;
    uh = 24;  % uicontrol height
    lw = 300; % list width
    bw = 100; % button width
    lfs = 5; %label / frame spacing
    lbs = 3; % label / box spacing
    lh = 16; % label height
    
    fp = get(0,'defaultfigureposition');
    w = 2*ffs+2*fus+lw;
    h = 6*fus+2*lh+5*uh;
    fp = [fp(1) fp(2)+fp(4)-h w h];  % keep upper left corner fixed

    fig_props = { ...
       'name'                   figname ...
       'resize'                 'off' ...
       'numbertitle'            'off' ...
       'windowstyle'            'modal' ...
       'units'                  'pixels' ...
       'createfcn'              ''    ...
       'position'               fp   ...
       'closerequestfcn'        'sbswitch(''sbarray'',''cancel'')'  ...
       'dockcontrols',          'off',...
       'color'                  get(0,'defaultuicontrolbackgroundcolor') ...
       };

    fig = figure(fig_props{:});
    
    cancel_btn = uicontrol('style','pushbutton',...
      'units','pixels',...
      'string',cancelstring,...
      'position',[fp(3)/2-ffs/2-bw fus bw uh],...
      'callback','sbswitch(''sbarray'',''cancel'')');
    ok_btn = uicontrol('style','pushbutton',...
      'units','pixels',...
      'string',okstring,...
      'position',[fp(3)/2+ffs/2 fus bw uh],...
      'callback','sbswitch(''sbarray'',''ok'')');
    
    listFramePos = [ffs fp(4)-fus-lh-3*uh-fus lw+2*fus fus+3*uh+lh/2];
    indexFramePos = [ffs 2*fus+uh lw+2*fus fus+uh+lh/2];
    
    ud.listFrame = uicontrol('units','pixels','style','frame','position',listFramePos);
    ud.indexFrame = uicontrol('units','pixels','style','frame','position',indexFramePos);
    
    ud.listFrameLabel = framelab(ud.listFrame,'Array Signals',lfs,lh);
    ud.indexFrameLabel = framelab(ud.indexFrame,...
                 'Column Index Vector for 1234567890',lfs,lh);
    
    indexLabel(ud.indexFrameLabel,sigs(1).label)
    
    maxLabelLength = 0;
    for i=1:length(sigs)
        maxLabelLength = max(maxLabelLength,length(sigs(i).label));
    end
    formatStr = sprintf('%%%gs   %%s',maxLabelLength);
    ud.listStr = {};
    for i=1:length(sigs)
           [m,n]=size(sigs(i).data);
           if isreal(sigs(i).data)
               complexStr = 'real';
           else
               complexStr = 'complex';
           end
           N = size(sigs(i).data,2);
          % siginfo1Str = sprintf('%g-by-%g %s',m,n,complexStr);
           siginfo1Str = sprintf('%g columns',N);
           newline = sprintf(formatStr,sigs(i).label,siginfo1Str);
           ud.listStr = {ud.listStr{:} newline};
    end
    [fontname,fontsize] = fixedfont;
    ud.list = uicontrol('units','pixels',...
                        'style','listbox','backgroundcolor','w',...
                        'position',listFramePos+[fus fus -2*fus  -fus-lh/2],...
                        'fontname',fontname,...
                        'fontsize',fontsize,...
                        'string',ud.listStr,...
                        'value',1,...
                        'callback','sbswitch(''sbarray'',''list'')');
    
    ud.indexEdit = uicontrol('style','edit',...
           'units','pixels',...
           'backgroundcolor','w',...
           'horizontalalignment','left',...
           'string',index2str(sigs(1).lineinfo.columns),...
           'position',indexFramePos+[fus fus -2*fus  -fus-lh/2]);
    
    ud.sigs = sigs;
    ud.flag = '';    
    set(fig,'userdata',ud)
    
    done = 0;
    while ~done
        waitfor(fig,'userdata')

        ud = get(fig,'userdata');
        err = 0;
        
        switch ud.flag
        case 'ok'
           val = get(ud.list,'value');
           colStr = get(ud.indexEdit,'string');
           arb_obj = {'arbitrary' 'object'};
           columns = evalin('base',colStr,'arb_obj');
           if isequal(columns,arb_obj)
               errstr = {'Sorry, the column index vector you entered' 
                          'could not be evaluated.'};
               msgbox(errstr,'Error','error','modal')
               err = 1;
           end
           N = size(ud.sigs(val).data,2);
           if ~err & (~all(round(abs(columns))==columns) | any(columns<=0))
               errstr = {'Sorry, the column index vector must contain only' 
                         'positive integers.'};
               msgbox(errstr,'Error','error','modal')
               err = 1;
           end
           if ~err & (max(columns) > N)
               errstr = {'Sorry, the selected signal array has only' 
                          [num2str(N) ' columns.']};
               msgbox(errstr,'Error','error','modal')
               err = 1;
           end
           if ~err
               varargout{1} = val;
               varargout{2} = columns;
           end
           
        case 'cancel'
           % do nothing and return
           varargout{1} = [];
           varargout{2} = [];
           
        end
    
        done = ~err;
        ud.flag = [];
        set(fig,'userdata',ud)
    end
    
    delete(fig)
    
case 'ok'
    fig = gcf;
    ud = get(fig,'userdata');
    ud.flag = 'ok';
    set(fig,'userdata',ud)
    
case 'cancel'
    fig = gcf;
    ud = get(fig,'userdata');
    ud.flag = 'cancel';
    set(fig,'userdata',ud)
    
case 'list'
    fig = gcf;
    ud = get(fig,'userdata');

    val = get(ud.list,'value');
    columns = ud.sigs(val).lineinfo.columns;
    
    indexStr = index2str(columns);
    
    set(ud.indexEdit,'string',indexStr)
    
    indexLabel(ud.indexFrameLabel,ud.sigs(val).label)
end

function indexStr = index2str(columns)

    cDiff = diff(columns);
    if max(cDiff)>1
        indexStr = ['[' num2str(columns) ']'];
    else
        if length(columns)==1
            indexStr = num2str(columns);
        else
            indexStr = [num2str(columns(1)) ':' num2str(columns(end))];
        end
    end



function indexLabel(h,label)
    set(h,'string',sprintf('Column Index Vector for %s',label))
    
    ex = get(h,'extent');
    ex(3) = ex(3) + 6;
    pos = get(h,'position');
    set(h,'position',[pos(1) pos(2) ex(3) pos(4)])
