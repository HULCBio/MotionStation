function varargout = speditline(varargin)
%SPEDITLINE Edit line's color and style for Signal GUI.
%[lineColor,lineStyle,ok] = speditline(h,label,lineColorOrder,bgColor)
% Inputs:
%    h - handle to line
%    label - string; label for line
%    lineColorOrder - cell array of colors
%    bgColor - background color on which line will be drawn
% Outputs:
%    lineColor - color (either [rgb] triple or string e.g. 'r')
%    lineStyle - string; '-' '--' ':' '-.'
%    ok - ==1 if user hit OK, ==0 if user hit cancel

%   Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.12.4.2 $

if ~isstr(varargin{1})
    action = 'init';
else
    action = varargin{1};
end

switch action
case 'init'
    lineHandle = varargin{1};
    label = varargin{2};
    lineColorOrder = varargin{3};
    bgColor = varargin{4};

    lineStyleOrder = {'solid (-)' 'dashed (--)' 'dotted (:)' 'dash-dot (-.)'};
    
    figname = 'Edit Line';
    okstring = 'OK';
    cancelstring = 'Cancel';
    fus = 8;
    ffs = 8;
    uh = 20;
    uw = 150;
    lfs = 5; %label / frame spacing
    lh = 16; % label height

    maxColorChoices = 7;
    numChoices = min(maxColorChoices,length(lineColorOrder));
    lineColorOrder = lineColorOrder(1:numChoices);
    
    fp = get(0,'defaultfigureposition');
    w = 2*(fus+ffs)+uw;
    h = (numChoices+3)*(fus+uh)+lh+2*fus+uh+lh+fus+uh+lh+uh+fus;
    fp = [fp(1) fp(2)+fp(4)-h w h];  % keep upper left corner fixed

    fig_props = { ...
       'name'                   figname ...
       'resize'                 'off' ...
       'numbertitle'            'off' ...
       'windowstyle'            'modal' ...
       'createfcn'              ''    ...
       'position'               fp   ...
       'closerequestfcn'        'sbswitch(''speditline'',''cancel'')' ...
       'color'                  get(0,'defaultuicontrolbackgroundcolor') ...
       'units'                  'pixels' ...
       'dockcontrols',          'off',...
       'visible'                'off' ...
       };

    fig = figure(fig_props{:});
    
    btn_wid = (fp(3)-2*(fus)-fus)/2;
    ok_btn = uicontrol('style','pushbutton',...
      'units','pixels',...
      'string',okstring,...
      'position',[fus fus btn_wid uh],...
      'callback','sbswitch(''speditline'',''ok'')');
    cancel_btn = uicontrol('style','pushbutton',...
      'units','pixels',...
      'string',cancelstring,...
      'position',[2*fus+btn_wid fus btn_wid uh],...
      'callback','sbswitch(''speditline'',''cancel'')');
    
    lfpos = [ffs fp(4)-ffs-lh/2-fus-uh fp(3)-2*ffs uh+fus+lh/2];
    labelFrame = uicontrol('style','frame',...
         'units','pixels',...
         'position',lfpos);
    labelLabel = framelab(labelFrame,xlate('Name'),lfs,lh);
    labelText = uicontrol('units','pixels',...
              'style','text','string',label,...
          'horizontalalignment','left',...
          'position',[lfpos(1)+fus lfpos(2)+fus uw uh]);

    lspos = [ffs lfpos(2)-lh-uh-fus lfpos([3 4]) ];
    lineStyleFrame = uicontrol('units','pixels',...
              'style','frame',...
         'position',lspos);

    lineStyleLabel = framelab(lineStyleFrame,xlate('Line Style'),lfs,lh);
    
    switch get(lineHandle,'linestyle')
    case '-'
        lineStylePopupVal = 1;
    case '--'
        lineStylePopupVal = 2;
    case ':'
        lineStylePopupVal = 3;
    case '-.'
        lineStylePopupVal = 4;
    otherwise
        % In case line handle has no line style -this should never be execute
        lineStylePopupVal = 1; 
    end

    lineStylePopup = uicontrol('units','pixels',...
        'style','popupmenu',...
        'backgroundcolor','white',...
	    'string',lineStyleOrder,...
 	    'value',lineStylePopupVal,...
  	    'position',[lspos(1)+fus lspos(2)+fus uw uh]);

    lcpos = [ffs 2*fus+uh fp(3)-2*ffs lh/2+(numChoices+3)*(uh+fus)-fus];
    lineColorFrame = uicontrol('units','pixels',...
              'style','frame',...
         'position',lcpos);
    lineColorLabel = framelab(lineColorFrame,xlate('Line Color'),lfs,lh);

    for i = 1:numChoices
        radio(i) = uicontrol('units','pixels',...
              'style','radiobutton',...
           'position',[lcpos(1)+fus lcpos(2)+lcpos(4)-lh/2-i*(fus+uh)+fus uw uh],...
           'value',0,...
           'backgroundcolor',bgColor,...
           'foregroundcolor',lineColorOrder{i},...
           'string',colorString(lineColorOrder{i}),...
           'callback','sbswitch(''speditline'',''radio'')');
    end
    
    radio(numChoices+1) = uicontrol('units','pixels',...
              'style','radiobutton',...
           'position',[lcpos(1)+fus ...
                lcpos(2)+lcpos(4)-lh/2-(numChoices+1)*(fus+uh)+fus uw uh],...
           'value',0,...
           'backgroundcolor',bgColor,...
           'foregroundcolor',[1 0 0],...
           'string','Other',...
           'callback','sbswitch(''speditline'',''radio'')');
           
    indent = 15; % in pixels
    customLabel = uicontrol('units','pixels',...
              'style','text',...
           'position',[lcpos(1)+fus+indent ...
                lcpos(2)+fus+uh uw-indent uh],...
           'horizontalalignment','left',...
           'string','Enter colorspec:');
           
    edit = uicontrol('units','pixels',...
              'style','edit',...
           'position',[lcpos(1)+fus+indent ...
                lcpos(2)+fus-1 uw-indent uh+2],...
           'value',0,...
           'backgroundcolor','w',...
           'horizontalalignment','left',...
           'string','[1 0 0]',...
           'callback','sbswitch(''speditline'',''edit'')');
           
    ind = whichColor(lineColorOrder,get(lineHandle,'color'));
    if isempty(ind)
        set(radio(end),'value',1,'foregroundcolor',get(lineHandle,'color'))
        [str,c,str1] = colorString(get(lineHandle,'color'));
        set(edit,'string',str1)
        set(edit,'enable','on')
        set(customLabel,'enable','on')
    else
        set(radio(ind),'value',1)
        set(edit,'enable','off')
        set(customLabel,'enable','off')
    end
    
    ud.radio = radio;
    ud.edit = edit;
    ud.customLabel = customLabel;
    ud.flag = [];
    
    set(fig,'userdata',ud,'visible','on')
    
    done = 0;
    while ~done
        waitfor(fig,'userdata')

        ud = get(fig,'userdata');
        switch ud.flag
   
        case 'ok'
            value = 1;
            val = get(ud.radio,'value');
            ind = find([val{:}]);
        case 'cancel'
            value = 0;
            ind = 1;
        end
      
        if ind ~= numChoices+1
            err = 0;
            varargout{1} = lineColorOrder{ind};
        else            
            % custom color
            err = 0;
            eval(['c = ' get(ud.edit,'string') ';'],'err=1;')
            if ~err
                u = uicontrol('visible','off');
                eval('set(u,''backgroundcolor'',c)','err=1;')
                delete(u)
            end
            if err
               errstr = {'Cannot evaluate colorspec.  Try either a three' 
                         'element vector (e.g., [1 0 1]), or a color'
                         'string (e.g., ''r''; see "help plot" for'
                         'a complete list).'};
               msgbox(errstr,'Error','error','modal')
            else
                varargout{1} = c;
            end
        end
    
        done = ~err;
        ud.flag = [];
        set(fig,'userdata',ud)
    end
    
    switch get(lineStylePopup,'value')
    case 1
        varargout{2} = '-';
    case 2
        varargout{2} = '--';
    case 3
        varargout{2} = ':';
    case 4
        varargout{2} = '-.';
    end
    varargout{3} = value;
    
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
    
case 'radio'
    fig = gcf;
    ud = get(fig,'userdata');
    set(ud.radio,'value',0)
    set(gcbo,'value',1)
    if gcbo == ud.radio(end)
        set(ud.edit,'enable','on')
        set(ud.customLabel,'enable','on')
    else
        set(ud.edit,'enable','off')
        set(ud.customLabel,'enable','off')
    end
    
case 'edit'
    fig = gcf;
    ud = get(fig,'userdata');

    err = 0;
    eval(['c = ' get(ud.edit,'string') ';'],'err=1;')
    if ~err
        u = uicontrol('visible','off');
        eval('set(u,''backgroundcolor'',c)','err=1;')
        delete(u)
    end
    if err 
        errstr = {'Cannot evaluate colorspec.  Try either a three'
                  'element vector (e.g., [1 0 1]), or a color'
                  'string (e.g., ''r''; see "help plot" for'
                  'a complete list).'};
        msgbox(errstr,'Error','error','modal')
    else
        set(ud.radio(end),'foregroundcolor',c)
    end

end

function [str,c,str1] = colorString(c)
% Returns a string indicating the color of the input
% colorspec... c may have the following forms:
%   'r','g', etc  
%   [1 0 1]  (rgb triple)
    if isstr(c)
    %  convert c to RGB triple
        c = rgbcolor(c);
    end
    
    if isequal(c,[0 0 0])
        c1 = c;
    else
        c1 = c/max(c);
    end
    str = [ '[' num2str(c(1)) ' ' num2str(c(2)) ' ' num2str(c(3)) ']' ];
    str1 = [ '[' num2str(c1(1)) ' ' num2str(c1(2)) ' ' num2str(c1(3)) ']' ];
    
    switch str1
    case '[1 0 0]'
        str = [xlate('Red ') str];
    case '[0 1 0]'
        str = [xlate('Green ') str];
    case '[0 0 1]'
        str = [xlate('Blue ') str];
    case '[1 1 0]'
        str = [xlate('Yellow ') str];
    case '[1 0 1]'
        str = [xlate('Magenta ') str];
    case '[0 1 1]'
        str = [xlate('Cyan ') str];
    case '[1 1 1]'
        if c(1)==1
            str = [xlate('White ') str];
        else
            str = [xlate('Gray ') str];
        end
    case '[0 0 0]'
        str = [xlate('Black ') str];
    end    

function ind = whichColor(lineColorOrder,c)
    
    for ind=1:length(lineColorOrder)
        c1 = rgbcolor(lineColorOrder{ind});
        if isequal(c,c1)
            break
        end
    end

    if ~isequal(c,c1)
        ind = [];
    end
    
function c = rgbcolor(c)
%  converts string 'r','g' etc to rgb triple

    if ~isstr(c)
        return
    end
    
    switch c
    case 'y'
        c = [1 1 0];
    case 'm'
        c = [1 0 1];
    case 'c'
        c = [0 1 1];
    case 'r'
        c = [1 0 0];
    case 'g'
        c = [0 1 0];
    case 'w'
        c = [1 1 1];
    case 'k'
        c = [0 0 0];
    end

