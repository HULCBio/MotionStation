function sosdemo(action,s);
%SOSDEMO Second Order Sections Demonstration for the Signal Processing Toolbox.
% 
% This demo lets you examine the internal structure of a digital filter.
%
% It designs a Butterworth, Chebyshev type I or II, or elliptic digital
% filter of the specified "order" and with the specified cutoff frequencies.
% 
% "Order" specifies the filter order for lowpass filters, and half the filter
% order for bandpass filters.
%  
% "Filter cutoffs" can be a two element vector for bandpass filters, or a
% scalar for lowpass filters.
%
% The function ZP2SOS transforms a digital filter into "second order sections" form.
%
% It groups pairs of poles and zeros together so that the cascade of the
% second order filters (or "sections") is equivalent to the original filter.
% 
% ZP2SOS pairs the pole-zero pairs, orders them, and scales them, so that in 
% certain fixed point implementations the cascade filter avoids overflow and
% has minimal noise gain.
%
% The "Up" and "Down" options tell ZP2SOS which way to order the sections:
%     "Up"   - places pole-zero pairs with poles closest to the unit circle
%              (high "Q" filters) at end of cascade.
%     "Down" - places pole-zero pairs in the opposite order.
% The slider at the bottom of the figure lets you choose one of the responses
% to highlight or display. You can also highlight a response by clicking on it.
%
% The four toggle switches on the right have the following effects:
% "Show all" - shows all of the sections at once or just the selected one.
% "3-D plot" - allows you change from a 3-D to a 2-D view.
% "Cascade"  - with this turned on, the n-th response is the cascade of
%              sections 1 through n. If turned off, the n-th response is
%              simply the response of section n.
% "Grid"     - toggles grid on and off.
% 
% See also CZTDEMO, FILTDEMO, MODDEMO.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/11/21 15:47:31 $

% Possible actions:
% initialize
% createplot
% viewtoggle
% filter
% grids
% slide
% showtoggle
% clickline
% puttitle
% order
% cutoff
% closehelp
% info

% button callbacks:
% info


if nargin<1,
    action='initialize';
end;

if strcmp(action,'createplot'), % create and plot Second order sections
    set(gcf,'Pointer','watch');
    hndlList=get(gcf,'Userdata');
    upHndl = hndlList(1);
    filterHndl = hndlList(2);
    orderHndl = hndlList(3);
    cutoffHndl = hndlList(4);
    btn1Hndl = hndlList(5);
    btn2Hndl = hndlList(6);
    slideHndl = hndlList(7);
    leftHndl = hndlList(8);
    rightHndl = hndlList(9);
    cascadeHndl = hndlList(12);
    gridHndl = hndlList(13);

    v = get(filterHndl,'value');
    op = get(filterHndl,'string'); op = deblank(op(v,:));
    n = get(orderHndl,'UserData');
    wn = get(cutoffHndl,'UserData');
    section = get(slideHndl,'value');
    v = get(upHndl,'value');
    updown = get(upHndl,'String'); updown = deblank(updown(v,:));
    cascade = get(cascadeHndl,'value');
    gr = get(gridHndl,'value');

    sos = get(filterHndl,'UserData');

    set(gcf,'nextplot','add')

    % Now plot response
    ax = newplot; 
    np = 256; m = size(sos,1);
    h = []; H = zeros(np,m);
    [H(:,1),F] = freqz(sos(1,1:3),sos(1,4:6),np,2);
    for i=2:m,
      if cascade,
          H(:,i) = H(:,i-1).*freqz(sos(i,1:3),sos(i,4:6),np,2);
      else
          H(:,i) = freqz(sos(i,1:3),sos(i,4:6),np,2);
      end
    end
    warnsave = warning;  % turn off "Log of zero" messages
    warning('off')
    H = 20*log10(abs(H));
    warning(warnsave)
    max_pt = max(max(H));
    for i=1:m,
       cb = sprintf('sosdemo(''lineclick'',%g)',i);
       h=[h,line((i)*ones(np,1),F,H(:,i),'color',linecolor(1),'buttondownfcn',cb)];
    end
    set(h(section),'color',linecolor(2));
    if get(btn1Hndl,'value')==0,
        invis = 1:m; invis(section) = []; set(h(invis),'visible','off');
    end
    if get(btn2Hndl,'value')==1, 
        view(60,30) 
        zlim = get(gca,'zlim');
        set(gca,'zlim',[zlim(1) max(max_pt,10) ],...
             'xlim',[1 m+.01],'ylim',[0 1])
    else 
        view(90,0)
        zlim = get(gca,'zlim');
        set(gca,'zlim',[zlim(1) max(max_pt,10) ],...
             'xlim',[1 m+.01],'ylim',[0 1])
    end
    
    if gr, grid on, else grid off, end
    axis(axis)

    set(rightHndl,'String',int2str(m),'UserData',m)
    set(slideHndl,'Max',m,'Value',section)

    sosdemo('puttitle')

    xlabel('Section'), ylabel('Frequency'), zlabel('Magnitude (dB)')
    set(gca,'UserData',h)
    set(gcf,'handlevisibility','callback')
    set(gcf,'Pointer','arrow');
    return

elseif strcmp(action,'initialize'),
    shh = get(0,'ShowHiddenHandles');
    set(0,'ShowHiddenHandles','on')
    figNumber=figure( ...
        'Name','Second Order Sections Demo', ...
        'handlevisibility','callback',...
        'IntegerHandle','off',...
        'NumberTitle','off');

    %==================================
    % Set up the axes
    axes( ...
        'Units','normalized', ...
        'Position',[0.10 0.22 0.60 0.7], ...
        'XTick',[],'YTick',[], ...
        'Box','on');
    set(figNumber,'defaultaxesposition',[0.10 0.22 0.60 0.7])

    %=================================
    % Set up the scroll bar
    sbBottom=0.1;
    sbLeft=0.05;
    barHeight = 0.04; 
    barWidth = .675;
    textWidth = barWidth/2;
    scrollPos = [sbLeft sbBottom barWidth barHeight];
    callbackStr = 'sosdemo(''slide'')';
    slideHndl = uicontrol( ...
         'Style','slider', ...
        'Units','normalized', ...
         'Position',scrollPos, ...
         'Value',6, ...
         'userdata',6, ...
         'min',1, ...
         'max',6, ...
        'Interruptible','off', ...
        'Callback',callbackStr);
    % Left and right range indicators
    c = get(gcf,'Color');
    if [.298936021 .58704307445 .114020904255]*c'<.5,
      fgColor = [1 1 1];
    else
      fgColor = [0 0 0];
    end
    rangePos = [sbLeft sbBottom-barHeight textWidth barHeight];
    leftHndl = uicontrol( ...
		'Style','text', ...
        'Units','normalized', ...
		'Position',rangePos, ...
		'Horiz','left', ...
		'Background',c, ...
        'Foreground',fgColor, ...
		'String','1');
    rangePos = [sbLeft+barWidth/2 sbBottom-barHeight textWidth barHeight];
    rightHndl = uicontrol( ...
		'Style','text', ...
        'Units','normalized', ...
		'Position',rangePos, ...
		'Horiz','right', ...
		'Background',c, ...
        'Foreground',fgColor, ...
		'String','6');

    %====================================
    % Information for all buttons (and menus)
    labelColor=[0.8 0.8 0.8];
    yInitPos=0.90;
    menutop=0.95;
    top=0.4;
    left=0.785;
    btnWid=0.175;
    btnHt=0.06;
    textHeight = 0.05;
    textWidth = 0.07;

    % Spacing between the button and the next command's label
    spacing=0.025;
    
    %====================================
    % The CONSOLE frame
    frmBorder=0.019; frmBottom=0.04; 
    frmHeight = 0.92; frmWidth = btnWid;
    yPos=frmBottom-frmBorder;
    frmPos=[left-frmBorder yPos frmWidth+2*frmBorder frmHeight+2*frmBorder];
    h=uicontrol( ...
        'Style','frame', ...
        'Units','normalized', ...
        'Position',frmPos, ...
	'BackgroundColor',[0.5 0.5 0.5]);

    %====================================
    % The UPDOWN Menu
    menuNumber=1;
    yPos=menutop-(menuNumber-1)*(btnHt+spacing);
    labelStr='Up|Down';
    callbackStr='sosdemo(''filter'')';

    % Generic button information
    btnPos=[left yPos-btnHt btnWid btnHt];
    upHndl=uicontrol( ...
        'Style','popupmenu', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'Interruptible','on', ...
        'Callback',callbackStr);

    %====================================
    % The FILTER Menu
    menuNumber=2;
    yPos=menutop-(menuNumber-1)*(btnHt+spacing);
    labelStr='Butter|Cheby1|Cheby2|Ellip';
    callbackStr='sosdemo(''filter'');';

    % Generic button information
    btnPos=[left yPos-btnHt btnWid btnHt];
    filterHndl=uicontrol( ...
        'Style','popupmenu', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'Interruptible','on', ...
        'Value',3,...   % chebyshev type 2
        'Callback',callbackStr);

    %===================================
    % Filter order
    top = yPos - btnHt - spacing;
    labelWidth = frmWidth-textWidth-.01;
    labelBottom=top-textHeight;
	labelLeft = left;
    labelRight = left+btnWid;
    labelPos = [labelLeft labelBottom labelWidth textHeight];
    h = uicontrol( ...
		'Style','text', ...
        'Units','normalized', ...
		'Position',labelPos, ...
        'Horiz','left', ...
        'String','Order:', ...
        'Interruptible','off', ...
		'BackgroundColor',[0.5 0.5 0.5], ...
        'ForegroundColor','white');
	% Text field
    textPos = [labelRight-textWidth labelBottom textWidth textHeight];
    callbackStr = 'sosdemo(''order'')';
    orderHndl = uicontrol( ...
		'Style','edit', ...
        'Units','normalized', ...
		'Position',textPos, ...
		'Horiz','right', ...
		'Background','white', ...
        'Foreground','black', ...
		'String','6','Userdata',6, ...
        'callback',callbackStr);

    %===================================
    % Filter cutoff
    top = yPos - 2*btnHt - 2*spacing;
    labelWidth = frmWidth-textWidth-.01;
    labelBottom=top-textHeight;
    labelLeft = left;
    labelRight = left+btnWid;
    %labelPos = [labelLeft labelBottom labelWidth textHeight];
    labelPos = [labelLeft labelBottom btnWid textHeight];
    h = uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position',labelPos, ...
        'Horiz','left', ...
        'String','Cutoffs:', ...
        'Interruptible','off', ...
        'BackgroundColor',[0.5 0.5 0.5], ...
        'ForegroundColor','white');
	% Text field
    %textPos = [labelRight-1.5*textWidth labelBottom 1.5*textWidth textHeight];
    textPos = [labelLeft labelBottom-btnHt btnWid textHeight];
    callbackStr = 'sosdemo(''cutoff'')';
    cutoffHndl = uicontrol( ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',textPos, ...
        'Horiz','right', ...
        'Background','white', ...
        'Foreground','black', ...
        'String','[0.4 0.7]','Userdata',[.4 .7], ...
        'callback',callbackStr);

    top = labelBottom-4*spacing;

    %====================================
    % button 1
    btnNumber=1;
    yPos=top-(btnNumber-1)*(btnHt+spacing);
    labelStr='Show all';
    callbackStr='sosdemo(''showtoggle'');';

    % Generic button information
    btnPos=[left yPos-btnHt btnWid btnHt];
    btn1Hndl=uicontrol( ...
        'Style','checkbox', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'Value',1, ...
        'Callback',callbackStr);

    %====================================
    % button 2
    btnNumber=2;
    yPos=top-(btnNumber-1)*(btnHt+spacing);
    labelStr='3-D plot';
    callbackStr='sosdemo(''viewtoggle'');';

    % Generic button information
    btnPos=[left yPos-btnHt btnWid btnHt];
    btn2Hndl=uicontrol( ...
        'Style','checkbox', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'Value',1, ...
        'Callback',callbackStr);

    %====================================
    % button 3
    btnNumber=3;
    yPos=top-(btnNumber-1)*(btnHt+spacing);
    labelStr='Cascade';
    callbackStr='sosdemo(''createplot'');';

    % Generic button information
    btnPos=[left yPos-btnHt btnWid btnHt];
    btn3Hndl=uicontrol( ...
        'Style','checkbox', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'Value',1, ...
        'Callback',callbackStr);

    %====================================
    % button 4
    btnNumber=4;
    yPos=top-(btnNumber-1)*(btnHt+spacing);
    labelStr='Grid';
    callbackStr='sosdemo(''grids'');';

    % Generic button information
    btnPos=[left yPos-btnHt btnWid btnHt];
    btn4Hndl=uicontrol( ...
        'Style','checkbox', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'Value',1, ...
        'Callback',callbackStr);

    %====================================
    % The INFO button
    labelStr='Info';
    callbackStr='sosdemo(''info'')';
    helpHndl=uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[left frmBottom+btnHt+spacing btnWid btnHt], ...
        'String',labelStr, ...
        'Callback',callbackStr);

    %====================================
    % The CLOSE button
    labelStr='Close';
    callbackStr='close(gcf)';
    closeHndl=uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',[left frmBottom btnWid btnHt], ...
        'String',labelStr, ...
        'Callback',callbackStr);

    hndlList=[ upHndl filterHndl orderHndl cutoffHndl btn1Hndl btn2Hndl ...
               slideHndl leftHndl rightHndl helpHndl closeHndl btn3Hndl ...
               btn4Hndl];
    set(figNumber, ...
	'Visible','on', ...
	'UserData',hndlList);

    sosdemo('filter')
    set(0,'ShowHiddenHandles',shh)
    return

elseif strcmp(action,'viewtoggle'),
    v = get(gco,'value');
    hndlList = get(gcf,'UserData');
    m = floor(get(hndlList(7),'max')); % number of sections
    if v==1
        view(60,30) 
    else 
        view(90,0)
    end
    return

elseif strcmp(action,'slide'),
    v = get(gco,'value');
    max_v = get(gco,'max');
    min_v = get(gco,'min');
    old_v = get(gco,'UserData');
    if round(v)==old_v,
        v = old_v + ( 2*( (old_v-v)<0 ) - 1 );
        if v>max_v, v = max_v; end
        if v<min_v, v = min_v; end
    else
        v = round(v);
    end
    set(gco,'value',v,'userdata',v);
    h = get(gca,'UserData');
    hndlList = get(gcf,'UserData');
    if get(hndlList(5),'value')==1, % Show all
      set(h,'color',linecolor(1))
      set(h(v),'color',linecolor(2))
    else
      set(h,'visible','off','color',linecolor(1))
      set(h(v),'visible','on','color',linecolor(2))
    end
    set(gco,'value',v);
    sosdemo('puttitle')
    return

elseif strcmp(action,'puttitle')
    hndlList = get(gcf,'UserData');
    v = get(hndlList(7),'value');  % section selection
    cascade = get(hndlList(12),'value');
    if cascade
      title( sprintf( ...
       'Cumulative Cascade Responses (through section %g highlighted)', v))
    else
      title( sprintf( ...
       'Response of Individual Sections (section %g highlighted)', v))
    end
    return

elseif strcmp(action,'lineclick'),
    h = get(gca,'UserData');
    hndlList = get(gcf,'UserData');
    if get(hndlList(5),'value')==1, % Show all
      set(h,'color',linecolor(1))
      set(h(s),'color',linecolor(2))
    else
      set(h,'visible','off','color',linecolor(1))
      set(h(s),'visible','on','color',linecolor(2))
    end
    set(hndlList(7),'value',s,'userdata',s);
    sosdemo('puttitle')
    return

elseif strcmp(action,'showtoggle'),
    v = get(gco,'value');
    h = get(gca,'UserData');
    hndlList = get(gcf,'UserData');
    hlast = floor(get(hndlList(7),'value')); % Slider value
    if v==1,
      set(h,'visible','on')
    else
      set(h,'visible','off')
      set(h(hlast),'visible','on')
    end      
    return

elseif strcmp(action,'order'),
    v = get(gco,'UserData');
    s = get(gco,'String');
    vv = eval(s,num2str(v));
    if vv<1, vv = v; end
    vv = round(vv);
    set(gco,'Userdata',vv,'String',num2str(vv))
    sosdemo('filter')
    return

elseif strcmp(action,'cutoff'),
    v = get(gco,'UserData');
    s = get(gco,'String');
    if length(v) == 1,
        vv = eval(s,num2str(v));
    else
        vv = eval(s,['[' num2str(v(1)) ' ' num2str(v(2)) ']']);
    end
    if any(vv<0 | vv>1), vv = v; end
    if length(vv)>1, if diff(vv)<0, vv = v; end, end
    vv = round(vv*100)/100;
    if length(vv) == 2
     set(gco,'Userdata',vv, ...
         'String', [ '[' num2str(vv(1)) ' ' num2str(vv(2)) ']' ] )
    else
      set(gco,'Userdata',vv,'String', [ '[' num2str(vv(1)) ']' ] )
    end
    if ~all(v == vv), sosdemo('filter'), end
    return

elseif strcmp(action,'filter'),
    % store the second order sections in the UserData of the filter popup
    set(gcf,'Pointer','watch');

    hndlList=get(gcf,'Userdata');
    upHndl = hndlList(1);
    filterHndl = hndlList(2);
    orderHndl = hndlList(3);
    cutoffHndl = hndlList(4);
    btn1Hndl = hndlList(5);
    btn2Hndl = hndlList(6);
    slideHndl = hndlList(7);
    leftHndl = hndlList(8);
    rightHndl = hndlList(9);
    cascadeHndl = hndlList(12);
    gridHndl = hndlList(13);

    v = get(filterHndl,'value');
    op = get(filterHndl,'string'); op = deblank(op(v,:));
    n = get(orderHndl,'UserData');
    set(slideHndl,'value',n);
    wn = get(cutoffHndl,'UserData');
    v = get(upHndl,'value');
    updown = get(upHndl,'String'); updown = deblank(updown(v,:));
    cascade = get(cascadeHndl,'value');
    gr = get(gridHndl,'value');

    Rpass = 3; Rstop = 30;
    if strcmp(op,'Butter'),
      [z,p,k] = butter(n,wn);
    elseif strcmp(op,'Cheby1'),
      [z,p,k] = cheby1(n,Rpass,wn);
    elseif strcmp(op,'Cheby2'),
      [z,p,k] = cheby2(n,Rstop,wn);
    elseif strcmp(op,'Ellip'),
      [z,p,k] = ellip(n,Rpass,Rstop,wn);
    else
      error('Unknown filter type.');
    end
    sos = zp2sos(z,p,k,lower(updown));

    section = size(sos,1);
    set(slideHndl,'max',section);
    val = min(section,get(slideHndl,'value'));
    set(slideHndl,'value',val,'userdata',val);
    
    set(filterHndl,'UserData',sos)

    sosdemo('createplot')

    set(gcf,'Pointer','arrow');
    return

elseif strcmp(action,'grids'),
    gr = get(gco,'value');
    if gr, grid on, else grid off, end
    return

elseif strcmp(action,'closehelp'),
    % Restore close button help behind helpwin's back
    ch = get(gcf,'ch');
    for i=1:length(ch),
      if strcmp(get(ch(i),'type'),'uicontrol'),
        if strcmp(lower(get(ch(i),'String')),'close'),
          callbackStr = get(ch(i),'callback');
          k = findstr('; sosdemo(',callbackStr);
          callbackStr = callbackStr(1:k-1);
          set(ch(i),'callback',callbackStr)
          break;
        end
      end
    end
    ch = get(0,'ch');
    if ~isempty(find(ch==s)), figure(s), end % Make sure figure exists
   
elseif strcmp(action,'order'),
    v = get(gco,'Userdata');
    s = get(gco,'String');
    vv = eval(s,num2str(v));
    if vv<1, vv = v; end
    vv = round(vv);
    set(gco,'Userdata',vv,'String',num2str(vv))
    sosdemo('filter')
    return

elseif strcmp(action,'info'),
    set(gcf,'pointer','arrow')
    ttlStr = get(gcf,'Name');
	hlpStr = [ ...
                 'This demo lets you examine the internal structure of a digital filter.     '
		         '                                                                           '  
                 'It designs a Butterworth, Chebyshev type I or II, or elliptic digital fil- '
                 'ter of the specified "order" and with the specified cutoff frequencies.    '
		         '                                                                           '  
                 '"Order" specifies the filter order for lowpass filters, and half the filter'
                 'order for bandpass filters.                                                '
		         '                                                                           '  
                 '"Filter cutoffs" can be a two element vector for bandpass filters, or a    '
                 'scalar for lowpass filters.                                                '
		         '                                                                           '  
                 'The function ZP2SOS transforms a digital filter into "second order         '
                 'sections" form.                                                            '
		         '                                                                           '  
                 'It groups pairs of poles and zeros together so that the cascade of the     '
                 'second order filters (or "sections") is equivalent to the original filter. '
		         '                                                                           '  
                 'ZP2SOS pairs the pole-zero pairs, orders them, and scales them, so that in '
                 'certain fixed point implementations the cascade filter avoids overflow and '
                 'has minimal noise gain.                                                    '
		         '                                                                           '  
                 'The "Up" and "Down" options tell ZP2SOS which way to order the sections:   '
                 '    "Up"   - places pole-zero pairs with poles closest to the unit circle  '
                 '             (high "Q" filters) at end of cascade.                         '
                 '    "Down" - places pole-zero pairs in the opposite order.                 '
                 'The slider at the bottom of the figure lets you choose one of the resp-    '
                 'onses to highlight or display. You can also highlight a response by        '
                 'clicking on it.                                                            '
                 '                                                                           '  
                 'The four toggle switches on the right have the following effects:          '
                 '"Show all" - shows all of the sections at once or just the selected one.   '
                 '"3-D plot" - allows you change from a 3-D to a 2-D view.                   '
                 '"Cascade"  - with this turned on, the n-th response is the cascade of sec- '
                 '             tions 1 through n. If turned off, the n-th response is simply '
                 '             the response of section n.                                    '
                 '"Grid"     - toggles grid on and off.                                      '];

    myFig = gcf;
    helpwin(hlpStr,ttlStr);
    return  % avoid fancy, self-modifying code which
    % is killing the callback to this window's close button
    % if you press the info button more than once.
    % Also, a bug on Windows MATLAB is killing the 
    % callback if you hit the info button even once!

    % Protect against gcf changing -- Change close button behind
    % helpwin's back
    ch = get(gcf,'ch');
    for i=1:length(ch),
      if strcmp(get(ch(i),'type'),'uicontrol'),
        if strcmp(lower(get(ch(i),'String')),'close'),
          callbackStr = [get(ch(i),'callback') ...
            '; sosdemo(''closehelp'',' num2str(myFig) ')'];
          set(ch(i),'callback',callbackStr)
          return
        end
      end
    end
    return

end    % if strcmp(action, ...

set(gcf,'pointer','arrow')

function c = linecolor(num)
% LINECOLOR Return the line color of a line
%  Input = 1 or 2, 1 for highlighted, 2 for not highlighted

   co = get(gcf,'defaultaxescolororder');
   c = co(min(num,size(co,1)),:);
