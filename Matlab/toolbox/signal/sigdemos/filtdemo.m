function [num,den]=filtdemo(action,s);
%FILTDEMO  Demonstrates filter design tools in the Signal Processing Toolbox.
%
%   This demo lets you design lowpass digital filters.  You can set the filter
%   design method, the sampling frequency (Fsamp), the passband and stopband
%   edge frequencies (Fpass and Fstop), the desired amount of ripple in the
%   passband (Rpass) and attenuation in the stopband (Rs), and the filter
%   order, by using the controls on the right of the figure.
% 
%   If you want to enter in a filter order other than the one in the "Auto"
%   field, enter a number in the "Set" field.  You can change between automatic
%   order selection and setting your own filter order by clicking on the "Auto"
%   and "Set" radio buttons.
% 
%   The REMEZ, FIRLS and KAISER methods design linear phase Finite Impulse
%   Response (FIR) filters.
% 
%   The BUTTER, CHEBY1, CHEBY2, and ELLIP methods design Infinite Impulse
%   Response (IIR) filters.
% 
%   FIR filters generally require a much higher order than IIR. The "Auto"
%   filter order option is not available for the FIRLS filter.
% 
%   Note that for IIR filters, the passband magnitude specification is between
%   0 and -Rp decibels, while for FIR filters, it is centered at magnitude 1
%   with equiripples.
%   The popup menu just above the "info" button lets you select a region of the
%   frequency response to view.  You can zoom-in on the passband, the stopband,
%   or look at both bands at once (the "full" view).
% 
%   You can also click and drag the Fpass and Fstop indicators on the figure to
%   change Rpass, Rstop, Fpass or Fstop.
%
%   Once you've designed a filter that you like,
%      [b,a] = filtdemo('getfilt');
%   gives you the filter coefficients.
%
%   See also CZTDEMO, MODDEMO, SOSDEMO.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7.4.3 $  $Date: 2004/04/20 23:20:38 $

%    T. Krauss, 11/15/93

% Possible actions and button callbacks:
%   initialize
%   changemethod
%   setFreqs
%   setRipples
%   dragRp
%   dragRs
%   dragWp
%   dragWs
%   setord
%   radio
%   design
%   axesredraw
%   info
%   closehelp
%   getfilt


if nargin<1,
    action='initialize';
end;

if strcmp(action,'initialize'),
    shh = get(0,'ShowHiddenHandles');
    set(0,'ShowHiddenHandles','on')
    figNumber=figure( ...
        'Name','Lowpass Filter Design Demo', ...
        'handlevisibility','callback',...
        'IntegerHandle','off',...
        'NumberTitle','off',...
        'Tag','filtdemo');

    %==================================
    % Set up the frequency response axes
    axes( ...
        'Units','normalized', ...
        'Position',[0.10 0.1 0.60 0.8], ...
        'XTick',[],'YTick',[], ...
        'Box','on');
    set(figNumber,'defaultaxesposition',[0.10 0.1 0.60 0.80])
    freqzHnd = subplot(1,1,1);
    set(gca, ...
        'Units','normalized', ...
        'Position',[0.10 0.1 0.60 0.8], ...
        'XTick',[],'YTick',[], ...
        'Box','on');

    %====================================
    % Information for all buttons (and menus)
    labelColor=[0.8 0.8 0.8];
    yInitPos=0.90;
    menutop=0.95;
    btnTop = 0.6;
    top=0.75;
    left=0.785;
    btnWid=0.175;
    btnHt=0.06;
    textHeight = 0.05;
    textWidth = 0.06;
    % Spacing between the button and the next command's label
    spacing=0.019;

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
    % The Filter Design Routine Selection Menu
    btnNumber=1;
    yPos=menutop-(btnNumber-1)*(btnHt+spacing);
    btnPos=[left yPos-btnHt btnWid btnHt];
    labelStr='FIRPM|FIRLS|KAISER|BUTTER|CHEBY1|CHEBY2|ELLIP';
    callbackStr='filtdemo(''changemethod'');';
    methodHndl=uicontrol( ...
        'Style','popupmenu', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'Interruptible','on', ...
        'Callback',callbackStr);

    
    %===================================
    % Sampling frequency label 
    btnNumber=1;
    yPos=menutop-(btnNumber-1)*(btnHt+spacing);
    top = yPos - btnHt - spacing;
    labelWidth = frmWidth-textWidth-.01;
    labelBottom=top-textHeight;
    labelLeft = left;
    labelPos = [labelLeft labelBottom labelWidth textHeight];
    h = uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
	'Position',labelPos, ...
        'Horiz','left', ...
        'String','Fsamp', ...
        'Interruptible','off', ...
        'BackgroundColor',[0.5 0.5 0.5], ...
        'ForegroundColor','white');

    %===================================
    % Passband edge frequency label 
    btnNumber=2;
    yPos=menutop-(btnNumber-1)*(btnHt+spacing);
    top = yPos - btnHt - spacing;
    labelWidth = frmWidth-textWidth-.01;
    labelBottom=top-textHeight;
    labelLeft = left;
    labelPos = [labelLeft labelBottom labelWidth textHeight];
    h = uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position',labelPos, ...
        'Horiz','left', ...
        'String','Fpass', ...
        'Interruptible','off', ...
        'BackgroundColor',[0.5 0.5 0.5], ...
        'ForegroundColor','white');

    %===================================
    % Stopband edge frequency label and text field
    btnNumber=3;
    yPos=menutop-(btnNumber-1)*(btnHt+spacing);
    top = yPos - btnHt - spacing;
    labelWidth = frmWidth-textWidth-.01;
    labelBottom=top-textHeight;
    labelLeft = left;
    labelPos = [labelLeft labelBottom labelWidth textHeight];
    h = uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
	'Position',labelPos, ...
        'Horiz','left', ...
        'String','Fstop', ...
        'Interruptible','off', ...
        'BackgroundColor',[0.5 0.5 0.5], ...
        'ForegroundColor','white');
	% Text field
    textPos = [labelLeft+labelWidth-.015 labelBottom textWidth+.025 5*.85*textHeight];
    callbackStr = 'filtdemo(''setFreqs'')';
    str = sprintf('2000\n\n500\n\n600');
    mat = [2000; 500; 600];
    FreqsHndl = uicontrol( ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',textPos, ...
        'Max',2, ... % makes this a multiline edit object
        'Horiz','right', ...
        'Background','white', ...
        'Foreground','black', ...
        'String',str,'Userdata',mat, ...
        'callback',callbackStr);

    %===================================
    % passband ripple label
    btnNumber=4;
    yPos=menutop-(btnNumber-1)*(btnHt+spacing);
    top = yPos - btnHt - spacing;
    labelWidth = frmWidth-textWidth-.01;
    labelBottom=top-textHeight;
    labelLeft = left;
    labelPos = [labelLeft labelBottom labelWidth textHeight];
    h = uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
	'Position',labelPos, ...
        'Horiz','left', ...
        'String','Rpass', ...
        'Interruptible','off', ...
        'BackgroundColor',[0.5 0.5 0.5], ...
        'ForegroundColor','white');

    %===================================
    % stopband attenuation label and text field
    btnNumber=5;
    yPos=menutop-(btnNumber-1)*(btnHt+spacing);
    top = yPos - btnHt - spacing;
    labelWidth = frmWidth-textWidth-.01;
    labelBottom=top-textHeight;
    labelLeft = left;
    labelPos = [labelLeft labelBottom labelWidth textHeight];
    h = uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
	'Position',labelPos, ...
        'Horiz','left', ...
        'String','Rstop', ...
        'Interruptible','off', ...
        'BackgroundColor',[0.5 0.5 0.5], ...
        'ForegroundColor','white');
	% Text field
    textPos = [labelLeft+labelWidth labelBottom textWidth 3*.85*textHeight];
    textPos = [labelLeft+labelWidth-.015 labelBottom textWidth+.025 3*.85*textHeight];
    callbackStr = 'filtdemo(''setRipples'')';
    str = sprintf('3\n\n50');
    mat = [3;50];
    RipplesHndl = uicontrol( ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',textPos, ...
        'Max',2, ... % makes this a multiline edit object
        'Horiz','right', ...
        'Background','white', ...
        'Foreground','black', ...
        'String',str,'Userdata',mat, ...
        'callback',callbackStr);

    %====================================
    % Filter Order text label 
    btnNumber=6;
    yPos=menutop-(btnNumber-1)*(btnHt+spacing);
    top = yPos - btnHt - spacing;
    labelWidth = frmWidth-.01;
    labelBottom=top-textHeight;
    labelLeft = left;
    labelPos = [labelLeft labelBottom labelWidth textHeight];
    h = uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
	'Position',labelPos, ...
        'Horiz','center', ...
        'String','Order', ...
        'Interruptible','off', ...
        'BackgroundColor',[0.5 0.5 0.5], ...
        'ForegroundColor','white');

    %====================================
    % Estimate radio button and text field
    btnTop = labelBottom-spacing;
    btnNumber=8;
    yPos=menutop-(btnNumber-1)*(btnHt+spacing)+.02;
    labelStr='Auto:';
    callbackStr='filtdemo(''radio'',1)';
    btnPos=[left yPos-btnHt btnWid*.6 btnHt];
    btn1Hndl=uicontrol( ...
        'Style','radiobutton', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'value',1,'Userdata',1, ...
        'Callback',callbackStr, ...
        'Background',[.5 .5 .5], ...
        'Foreground','white');
    yPos=menutop-(btnNumber-1)*(btnHt+spacing);
    textPos=[left+btnWid*.62 yPos-btnHt btnWid*.45 btnHt];
    ord1Hndl = uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position',textPos, ...
        'String','22','Userdata',[22 -1], ...
        'Background',[.5 .5 .5], ...
        'Foreground','white');

    %====================================
    % Specify radio button and text field
    btnTop = labelBottom-spacing;
    btnNumber=9;
    yPos=menutop-(btnNumber-1)*(btnHt+spacing)+.02;
    labelStr='Set:';
    callbackStr='filtdemo(''radio'',2);';
    btnPos=[left yPos-btnHt btnWid*.6 btnHt];
    btn2Hndl=uicontrol( ...
        'Style','radiobutton', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'value',0, ...
        'Callback',callbackStr, ...
        'Background',[.5 .5 .5], ...
        'Foreground','white');
    % btnTop = labelBottom-spacing;
    yPos=menutop-(btnNumber-1)*(btnHt+spacing) + .02;
    textPos=[left+btnWid*.62 yPos-btnHt btnWid*.45 btnHt];
    %top = yPos - btnHt - spacing;
    %labelWidth = frmWidth-textWidth-.01;
    %labelBottom=top-textHeight;
    %labelLeft = left;
    %textPos = [labelLeft+labelWidth labelBottom textWidth textHeight];
    callbackStr = 'filtdemo(''setord'')';
    ord2Hndl = uicontrol( ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',textPos, ...
        'Horiz','right', ...
        'Background','white', ...
        'Foreground','black', ...
        'String','22','Userdata',22, ...
        'callback',callbackStr);

    %====================================
    % View Popup - Menu 
    labelStr='Full view|Passband|Stopband';
    callbackStr='filtdemo(''axesredraw'');';
    viewHndl=uicontrol( ...
        'Style','popupmenu', ...
        'Units','normalized', ...
        'Position',[left frmBottom+2*(btnHt+spacing) btnWid btnHt], ...
        'String',labelStr, ...
        'Interruptible','on', ...
        'Callback',callbackStr);

    %====================================
    % The INFO button
    labelStr='Info';
    callbackStr='filtdemo(''info'')';
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

    fhndlList=[freqzHnd 0 0 FreqsHndl RipplesHndl ...
              0 viewHndl btn1Hndl btn2Hndl ord1Hndl ord2Hndl ...
              helpHndl closeHndl methodHndl];
    set(figNumber, ...
	'Visible','on', ...
	'UserData',fhndlList);

    set(gcf,'Pointer','watch');
    drawnow

    axes(freqzHnd)
    
    set(freqzHnd,'Userdata',[])
    filtdemo('design')
    set(gcf,'Pointer','arrow','handlevisibility','callback');
    set(0,'ShowHiddenHandles',shh)
    return

elseif strcmp(action,'changemethod'),
    v = get(gco,'value');  % 1 = REMEZ, 2 = FIRLS, 3 = KAISER,
                           % 4 = BUTTER, 5 = CHEBY1, 6 = CHEBY2, 7 = ELLIP
    fhndlList = get(gcf,'UserData');
    if v == 2
        set(fhndlList(8),'enable','off')
        set(fhndlList(8),'value',0,'userdata',2);
        set(fhndlList(9),'value',1)
    else
        set(fhndlList(8),'enable','on')
        set(fhndlList(8),'value',1,'userdata',1);
        set(fhndlList(9),'value',0)
    end
    filtdemo('design')
    return

elseif strcmp(action,'setFreqs'),
    v = get(gco,'Userdata');
    str = get(gco,'String');
    ind = find(abs(str)<32);
    str(ind) = 32*ones(size(ind));
    str = str';
    vv = eval(['[' str(:)' ']'],'-1')';
    if vv == -1
        vv = v;
    elseif length(vv)~=3
        vv = v;
    elseif any(vv<0)    | vv(2)>=vv(3) | vv(2)>=vv(1)/2 | ...
           vv(3)>=vv(1)/2
        vv = v;
    end
    vv = round(vv*10)/10;
    str = sprintf('%g\n\n%g\n\n%g',vv(1),vv(2),vv(3));
    set(gco,'Userdata',vv,'String',str)
    if any(vv~=v)
        filtdemo('design')
    else
        filtdemo('axesredraw')
    end
    return

elseif strcmp(action,'setRipples'),
    v = get(gco,'Userdata');
    str = get(gco,'String');
    ind = find(abs(str)<32);
    str(ind) = 32*ones(size(ind));
    str = str';
    vv = eval(['[' str(:)' ']'],'-1')';
    if vv == -1
        vv = v;
    elseif any(vv<=0) | length(vv)~=2
        vv = v;
    end
    str = sprintf('%g\n\n%g',vv(1),vv(2));
    set(gco,'Userdata',vv,'String',str)
    if any(vv~=v)
        filtdemo('design')
    else
        filtdemo('axesredraw')
    end
    return

elseif strcmp(action,'dragRp'),
    % s = 1 ==> down, s = 2 ==> mouse motion, s = 3 ==> mouse up
    if s == 1   % down
        fhndlList=get(gcf,'Userdata');
        freqs = get(fhndlList(4),'UserData');  
        Wp = freqs(2);                   % passband frequency
        ripples = get(fhndlList(5),'UserData');
        Rp = ripples(1);                 % passband ripple
        method = get(fhndlList(14),'value');
        hndlList=get(gca,'Userdata');
        the_line = hndlList(2);
        set(the_line,'erasemode','xor')
        pt = get(gca,'currentpoint');
        pt_x = pt(1,1);  pt_y = pt(1,2);
        if (method > 3)&(pt_y > -Rp/2)
            return   % don't drag the 0 dB line in IIR case
        end
        % how many pixels wide is the Wp line?
        set(gca,'units','pixels'); 
        pos = get(gca,'position'); 
        set(gca,'units','normalized');
        xl = get(gca,'xlim');
        Wp_in_pixels =  Wp*pos(3)/diff(xl);
        % use right-most 5 pixels, or one fifth of them, which ever is smaller
        width = min(round(Wp_in_pixels/5),5);
        if pt_x < Wp-width/pos(3)*diff(xl)
            set(gcf,'windowbuttonmotionfcn','filtdemo(''dragRp'',2)')
            set(gcf,'windowbuttonupfcn','filtdemo(''dragRp'',3)')
        else
            set(gcf,'windowbuttonmotionfcn','filtdemo(''dragWp'',2)')
            set(gcf,'windowbuttonupfcn','filtdemo(''dragWp'',3)')
        end
    elseif s == 2   % motion
        fhndlList=get(gcf,'Userdata');
        method = get(fhndlList(14),'value');
        hndlList=get(gca,'Userdata');
        the_line = hndlList(2);
        pt = get(gca,'currentpoint');
        pt_y = pt(1,2);
        if method<=3    % FIR case
            if pt_y > 6.02, pt_y = 6.02; end
            if pt_y >= 0
                dev = 10^(pt_y/20)-1;
            else
                dev = 1-10^(pt_y/20);
            end
            above = 20*log10(1+dev);
            below = 20*log10(1-dev);
        else   % IIR case
            if pt_y > 0, pt_y = 0; end
            above = 0; below = pt_y;
        end
        set(the_line,'Ydata',[above above NaN below below]);
        drawnow
    elseif s == 3    % up
        fhndlList=get(gcf,'Userdata');
        method = get(fhndlList(14),'value');
        pt = get(gca,'currentpoint');
        pt_y = pt(1,2);
        if method<=3    % FIR case
            if pt_y > 6.02, pt_y = 6.02; end
            if pt_y >= 0
                dev = 10^(pt_y/20)-1;
            else
                dev = 1-10^(pt_y/20);
            end
            above = 20*log10(1+dev);
            below = 20*log10(1-dev);
        else   % IIR case
            if pt_y > 0, pt_y = 0; end
            above = 0; below = pt_y;
        end
        Rp = above - below;
        set(gcf,'windowbuttonmotionfcn','')
        set(gcf,'windowbuttonupfcn','')
        old_ripples = get(fhndlList(5),'UserData');
        rips = [Rp; old_ripples(2)];
        str = sprintf('%g\n\n%g',rips(1),rips(2));
        set(fhndlList(5),'Userdata',rips,'String',str)
        if Rp ~= old_ripples(1)
            filtdemo('design')
        else
            filtdemo('axesredraw')
        end
    end
    return

elseif strcmp(action,'dragRs'),
    % s = 1 ==> down, s = 2 ==> mouse motion, s = 3 ==> mouse up
    if s == 1   % down
        fhndlList=get(gcf,'Userdata');
        freqs = get(fhndlList(4),'UserData');
        Wp = freqs(2);                   % passband frequency
        Ws = freqs(3);
        hndlList=get(gca,'Userdata');
        the_line = hndlList(3);
        set(the_line,'erasemode','xor')
        pt = get(gca,'currentpoint');
        pt_x = pt(1,1);
        % how many pixels wide is the Ws line?
        set(gca,'units','pixels'); 
        pos = get(gca,'position'); 
        set(gca,'units','normalized');
        xl = get(gca,'xlim');
        Ws_in_pixels =  Ws*pos(3)/diff(xl);
        % use left-most 5 pixels, or one fifth of them, which ever is smaller
        width = min(round(Ws_in_pixels/5),5);
        if pt_x > Ws+width/pos(3)*diff(xl)
            set(gcf,'windowbuttonmotionfcn','filtdemo(''dragRs'',2)')
            set(gcf,'windowbuttonupfcn','filtdemo(''dragRs'',3)')
        else
            set(gcf,'windowbuttonmotionfcn','filtdemo(''dragWs'',2)')
            set(gcf,'windowbuttonupfcn','filtdemo(''dragWs'',3)')
        end
    elseif s == 2   % motion
        hndlList=get(gca,'Userdata');
        the_line = hndlList(3);
        pt = get(gca,'currentpoint');
        set(the_line,'Ydata',[pt(1,2) pt(1,2)])
        drawnow
    elseif s == 3    % up
        pt = get(gca,'currentpoint');
        Rs = max(0,-pt(1,2));
        set(gcf,'windowbuttonmotionfcn','')
        set(gcf,'windowbuttonupfcn','')
        fhndlList=get(gcf,'Userdata');
        old_ripples = get(fhndlList(5),'UserData');
        rips = [old_ripples(1); Rs];
        str = sprintf('%g\n\n%g',rips(1),rips(2));
        set(fhndlList(5),'Userdata',rips,'String',str)
        if Rs ~= old_ripples(2)
            filtdemo('design')
        else
            filtdemo('axesredraw')
        end
    end
    return

elseif strcmp(action,'dragWp'),
    % s = 1 ==> down, s = 2 ==> mouse motion, s = 3 ==> mouse up
    if s == 2   % motion
        fhndlList=get(gcf,'Userdata');
        freqs = get(fhndlList(4),'UserData');  
        Wp = freqs(2);                   % passband frequency
        Ws = freqs(3);                   % stopband frequency
        hndlList=get(gca,'Userdata');
        the_line = hndlList(2);
        pt = get(gca,'currentpoint');
        pt_x = pt(1,1);
        if pt_x > Ws, pt_x = Ws; elseif pt_x < 0, pt_x = 0; end
        set(the_line,'Xdata',[0 pt_x NaN 0 pt_x]);
        drawnow
    elseif s == 3    % up
        fhndlList=get(gcf,'Userdata');
        old_freqs = get(fhndlList(4),'UserData');  
        old_Wp = old_freqs(2);               % passband frequency
        Ws = old_freqs(3);                   % stopband frequency
        pt = get(gca,'currentpoint');
        pt_x = pt(1,1);
        if pt_x >= Ws, pt_x = old_Wp; end
        Wp = pt_x;
        Wp = round(Wp*10) / 10;
        set(gcf,'windowbuttonmotionfcn','')
        set(gcf,'windowbuttonupfcn','')
        freqs = [old_freqs(1); Wp; old_freqs(3)];
        str = sprintf('%g\n\n%g\n\n%g',freqs(1),freqs(2),freqs(3));
        set(fhndlList(4),'Userdata',freqs,'String',str)
        if Wp ~= old_Wp
            filtdemo('design')
        else
            filtdemo('axesredraw')
        end
    end
    return


elseif strcmp(action,'dragWs'),
    % s = 1 ==> down, s = 2 ==> mouse motion, s = 3 ==> mouse up
    if s == 2   % motion
        fhndlList=get(gcf,'Userdata');
        freqs = get(fhndlList(4),'UserData');  
        Fs = freqs(1);                   % sampling frequency
        Wp = freqs(2);                   % passband frequency
        Ws = freqs(3);                   % stopband frequency
        hndlList=get(gca,'Userdata');
        the_line = hndlList(3);
        pt = get(gca,'currentpoint');
        pt_x = pt(1,1);
        if pt_x < Wp, pt_x = Wp; elseif pt_x > Fs/2, pt_x = Fs/2; end
        set(the_line,'Xdata',[pt_x Fs/2]);
        drawnow
    elseif s == 3    % up
        fhndlList=get(gcf,'Userdata');
        freqs = get(fhndlList(4),'UserData');  
        Fs = freqs(1);                   % sampling frequency
        Wp = freqs(2);                   % passband frequency
        old_Ws = freqs(3);               % stopband frequency
        pt = get(gca,'currentpoint');
        pt_x = pt(1,1);
        if pt_x < Wp | pt_x > Fs/2
            pt_x = old_Ws; 
        end
        Ws = pt_x;
        Ws = round(Ws*10) / 10;
        set(gcf,'windowbuttonmotionfcn','')
        set(gcf,'windowbuttonupfcn','')
        freqs = [freqs(1); freqs(2); Ws];
        str = sprintf('%g\n\n%g\n\n%g',freqs(1),freqs(2),freqs(3));
        set(fhndlList(4),'Userdata',freqs,'String',str)
        if Ws ~= old_Ws
            filtdemo('design')
        else
            filtdemo('axesredraw')
        end
    end
    return

elseif strcmp(action,'setord'),
    hndlList=get(gcf,'Userdata');
    v = get(gco,'Userdata');
    s = get(gco,'String');
    vv = eval(s,num2str(v(1)));
    if vv<3, vv = v; end
    set(gco,'Userdata',vv,'String',num2str(vv))
    if vv~=v
        set(hndlList(8),'value',0,'userdata',2)  % switch radio buttons
        set(hndlList(9),'value',1)  
        filtdemo('design')
    else
        if get(hndlList(8),'userdata') == 1
            set(hndlList(8),'value',0,'userdata',2)  % switch radio buttons
            set(hndlList(9),'value',1) 
            filtdemo('design')
        end
    end
    return

elseif strcmp(action,'radio'),
    hndlList=get(gcf,'Userdata');
    for i=8:9,
      set(hndlList(i),'value',0) % Disable all the buttons
    end
    set(hndlList(s+7),'value',1) % Enable selected button
    old_one = get(hndlList(8),'Userdata');
    set(hndlList(8),'Userdata',s) % Remember selected button
    if s~=old_one 
        filtdemo('design')
    else
        filtdemo('axesredraw')
    end
    return

elseif strcmp(action,'design'), % Design filter
    set(gcf,'Pointer','watch');

% get handles
    axHndl=gca;
    fhndlList=get(gcf,'Userdata');
    freqzHndl = fhndlList(1);
    FreqsHndl = fhndlList(4);
    RipplesHndl = fhndlList(5);
    viewHndl = fhndlList(7);
    btn1Hndl = fhndlList(8);
    btn2Hndl = fhndlList(9);
    ord1Hndl = fhndlList(10);
    ord2Hndl = fhndlList(11);
    methodHndl = fhndlList(14);

    colors = get(gca,'colororder'); 

% initialize variables
    freqs = get(FreqsHndl,'UserData');  
    Fs = freqs(1);                   % sampling frequency
    Wp = freqs(2);                   % passband frequency
    Ws = freqs(3);                   % stopband frequency
    ripples = get(RipplesHndl,'UserData');
    Rp = ripples(1);                 % passband ripple
    Rs = ripples(2);                 % stopband attenuation
    
% Estimate order !
    % 1 = REMEZ, 2 = FIRLS, 4 = BUTTER, 5 = CHEBY1, 6 = CHEBY2, 7 = ELLIP, 
    %  3 = KAISER
    method = get(methodHndl,'value');
    if method == 1
        % compute deviations and estimate order
        devs = [ (10^(Rp/20)-1)/(10^(Rp/20)+1)  10^(-Rs/20) ];
        n = firpmord([Wp Ws],[1 0],devs,Fs);
        n = max(3,n);
        wn = -1;
        max_n = 2000;  reasonable_n = 500;
    elseif method == 3
        devs = [ (10^(Rp/20)-1)/(10^(Rp/20)+1)  10^(-Rs/20) ];
        alfa = -min(20*log10(devs));
        if alfa > 50,
            beta = .1102*(alfa - 8.7);
        elseif alfa >= 21,
            beta = .5842*((alfa-21).^(.4)) + .07886*(alfa-21);
        else
            beta = 0;
        end
        n = ceil((alfa - 8)/(2.285*(Ws-Wp)*2*pi/Fs));
        n = max(1,n);
        wn = beta;
        max_n = 2000;  reasonable_n = 500;
    elseif method == 4
        [n,wn]=buttord(Wp*2/Fs,Ws*2/Fs,Rp,Rs);
        n = max(1,n);
        max_n = 60;  reasonable_n = 30;
    elseif method == 5
        [n,wn]=cheb1ord(Wp*2/Fs,Ws*2/Fs,Rp,Rs);
        n = max(1,n);
        max_n = 30;  reasonable_n = 15;
    elseif method == 6
        [n,wn]=cheb2ord(Wp*2/Fs,Ws*2/Fs,Rp,Rs);
        n = max(1,n);
        max_n = 30;  reasonable_n = 15;
    elseif method == 7
        [n,wn]=ellipord(Wp*2/Fs,Ws*2/Fs,Rp,Rs);
        n = max(1,n);
        max_n = 25;  reasonable_n = 12;
    end

    % set order field
    if method == 2   % can't estimate !
        set(ord1Hndl,'Userdata',[-1 -1],'String','-')
    else
        set(ord1Hndl,'Userdata',[n wn],'String',num2str(n))
    end

% determine which order to use: estimated or specified
    estim = get(btn1Hndl,'UserData');
    order = get(ord1Hndl,'UserData'); % use estimated Filter order
    wn = order(2);    % use estimated cutoff even for "specified order" case
    order = order(1);
    if estim ~= 1
        order = get(ord2Hndl,'UserData'); % use specified Filter order
    elseif (n>max_n)|(isnan(n))|(isinf(n))
        set(ord2Hndl,'UserData',reasonable_n,'string',num2str(reasonable_n))
        set(btn1Hndl,'value',0,'userdata',2)  % switch radio buttons
        set(btn2Hndl,'value',1)
        order = get(ord2Hndl,'UserData'); % use specified Filter order
    end

% Create desired frequency response and weight vector for FIR case
    f = [0 Wp Ws Fs/2]/Fs*2;
    m = [1  1  0 0];
    devs = [ (10^(Rp/20)-1)/(10^(Rp/20)+1)  10^(-Rs/20) ];
    w = [1 1]*max(devs)./devs;

    drawnow

% Design filter
    if method==1,
      b = firpm(order,f,m,w); a = 1;
      title_str = sprintf('Order %g FIR Filter designed with REMEZ',order);
    elseif method==2,
      b = firls(order,f,m,w); a = 1;
      title_str = sprintf('Order %g FIR Filter designed with FIRLS',order);
    elseif method==3, % Kaiser window
      b = fir1(order,(Wp+(Ws-Wp)/2)*2/Fs,kaiser(order+1,wn)); a = 1;
      title_str = sprintf('Order %g FIR Filter designed with FIR1 and KAISER',order);
    elseif method==4, % butterworth
      [b,a] = butter(order,wn);
      title_str = sprintf('Order %g Butterworth IIR Filter',order);
    elseif method==5, % chebyshev type I
      [b,a] = cheby1(order,Rp,wn);
      title_str = sprintf('Order %g Chebyshev Type I IIR Filter',order);
    elseif method==6, % chebyshev type II
      [b,a] = cheby2(order,Rs,wn);
      title_str = sprintf('Order %g Chebyshev Type II IIR Filter',order);
    elseif method==7, % elliptic
      [b,a] =ellip(order,Rp,Rs,wn);
      title_str = sprintf('Order %g Elliptic IIR Filter',order);
    end
    [H,F] = freqz(b,a,max( 2048,nextpow2(5*max(length(b),length(a))) ),Fs);
    H = 20*log10(abs(H));
    axes(freqzHndl)
    axhndlList = get(freqzHndl,'UserData');
    if isempty(axhndlList)   % first time - happens at initialization phase
        % initialize the axes
        above = 20*log10(1+devs(1));
        below = 20*log10(1-devs(1));
        hndl = plot(F,H,[0 Wp NaN 0 Wp],[above above NaN below below], ...
                    [Ws Fs/2],[-Rs -Rs]);
        set(gcf,'handlevisibility','callback')
        if length(a) > 1
            set(hndl(1),'color',colors(1,:),'userdata',[b; a])  % save filter 
            % coefficients in userdata of line
        else
            set(hndl(1),'color',colors(1,:),'userdata',b) 
        end
        set(hndl(2:3),'color',colors(min(size(colors,1),2),:),'linewidth',2)
        set(hndl(2),'buttondownfcn','filtdemo(''dragRp'',1)')
        set(hndl(3),'buttondownfcn','filtdemo(''dragRs'',1)')
        grid on
        axhndlList = hndl;
        set(freqzHndl,'UserData',axhndlList)
        set(freqzHndl,'xlim',[0 Fs/2],'ylim',[-Rs*(1.5) max(2*Rp,Rs*.1)])
        xlabel('Frequency (Hz)')
        ylabel('Magnitude (dB)')
    else
        if length(a) > 1
            set(axhndlList(1),'UserData',[b; a])
        else
            set(axhndlList(1),'UserData',[b])
        end 
        filtdemo('axesredraw')
    end
    title(title_str)

    set(gcf,'Pointer','arrow');
    return

elseif strcmp(action,'axesredraw'), % redraw axes
    set(gcf,'Pointer','watch');
    axHndl=gca;
    fhndlList=get(gcf,'Userdata');
    freqzHndl = fhndlList(1);
    FreqsHndl = fhndlList(4);
    RipplesHndl = fhndlList(5);
    viewHndl = fhndlList(7);
    btn1Hndl = fhndlList(8);
    btn2Hndl = fhndlList(9);
    ord1Hndl = fhndlList(10);
    ord2Hndl = fhndlList(11);
    methodHndl = fhndlList(14);

    colors = get(gca,'colororder'); 
    
    order = get(ord1Hndl,'UserData'); % estimated Filter order
    wn = order(2);
    order = order(1);
    if get(btn1Hndl,'userdata') ~= 1
        order = get(ord2Hndl,'UserData'); % use specified Filter order
    end
    freqs = get(FreqsHndl,'UserData');  
    Fs = freqs(1);                   % sampling frequency
    Wp = freqs(2);                   % passband frequency
    Ws = freqs(3);                   % stopband frequency
    ripples = get(RipplesHndl,'UserData');
    Rp = ripples(1);                 % passband ripple
    Rs = ripples(2);                 % stopband attenuation
    method = get(methodHndl,'value'); 

    % Create desired frequency response and weight vector
    f = [0 Wp Ws Fs/2]/Fs*2;
    m = [1  1  0 0];
    devs = [ (10^(Rp/20)-1)/(10^(Rp/20)+1)  10^(-Rs/20) ];
    w = [1 1]*max(devs)./devs;

    axes(freqzHndl)
    axhndlList = get(freqzHndl,'UserData');
    h = get(axhndlList(1),'userdata');
    if size(h,1) > 1
        b = h(1,:); a = h(2,:);
    else
        b = h; a = 1;
    end
    [H,F] = freqz(b,a,max( 2048,nextpow2(5*max(length(b),length(a))) ),Fs);
    H = 20*log10(abs(H));
    set(axhndlList(1),'Xdata',F,'Ydata',H);
    if method >= 1 & method <= 3      % FIR case
        above = 20*log10(1+devs(1)); below = 20*log10(1-devs(1));
    else
        above = 0; below = -Rp;
    end
    set(axhndlList(2),'Ydata',[above above NaN below below],...
                      'Xdata',[0 Wp NaN 0 Wp],'erasemode','normal')
    set(axhndlList(3),'Ydata',[-Rs -Rs],'XData',[Ws Fs/2],'erasemode','normal')
    viewmode = get(viewHndl,'value');  % 1 == full, 2 == passband, 3 == stopbnd 
    if viewmode == 1
        xlim = [0 Fs/2];
        ymin = min(22*log10(1-devs(1)),-Rs*(1.5));
        ymax = max(2*20*log10(1+devs(1)),Rs*.1);
    elseif viewmode == 2
        if method >= 1 & method <= 3      % FIR case
            ymax = max(max(H(find(F<Wp))),20*log10(1+devs(1)))*1.1;
            ymin = min(min(H(find(F<Wp))),20*log10(1-devs(1)))*1.1;
        else  % IIR
            ymax = max(max(H(find(F<Wp)))*1.1,.1*Rp);
            ymin = min(min(H(find(F<Wp)))*1.1,-1.1*Rp);
        end
        xlim = [0 Wp+.2*(Ws-Wp)];
    elseif viewmode == 3
        ymax = max(max(H(find(F>Ws)))*.9,-Rs*.9);
        ymin = min(max(H(find(F>Ws))), -Rs*1.6);
        xlim = [Ws-.2*(Ws-Wp) Fs/2];
    end
    set(freqzHndl,'xlim',xlim)
    if all(finite([ymin ymax]))
        set(freqzHndl,'ylim',[ymin ymax])
    else
        disp('filtdemo: Response is Inf or NaN')
        set(freqzHndl,'ylimmode','auto')
    end
    xlabel('Frequency (Hz)')
    ylabel('Magnitude (dB)')

    set(gcf,'Pointer','arrow');
    return

elseif strcmp(action,'info'),
    set(gcf,'pointer','arrow')
	ttlStr = get(gcf,'name');
	hlpStr= [...
 'This demo lets you design lowpass digital filters.  You can set the filter '
 'design method, the sampling frequency (Fsamp), the passband and stopband   '
 'edge frequencies (Fpass and Fstop), the desired amount of ripple in the    '
 'passband (Rpass) and attenuation in the stopband (Rs), and the filter      '
 'order, by using the controls on the right of the figure.                   '
 '                                                                           '
 'If you want to enter in a filter order other than the one in the "Auto"    '
 'field, enter a number in the "Set" field.  You can change between automatic'
 'order selection and setting your own filter order by clicking on the "Auto"'
 'and "Set" radio buttons.                                                   '
 '                                                                           '
 'The REMEZ, FIRLS and KAISER methods design linear phase Finite Impulse     '
 'Response (FIR) filters.                                                    '
 '                                                                           '
 'The BUTTER, CHEBY1, CHEBY2, and ELLIP methods design Infinite Impulse      '
 'Response (IIR) filters.                                                    '
 '                                                                           '
 'FIR filters generally require a much higher order than IIR. The "Auto"     '
 'filter order option is not available for the FIRLS filter.                 '
 '                                                                           '
 'Note that for IIR filters, the passband magnitude specification is between '
 '0 and -Rp decibels, while for FIR filters, it is centered at magnitude 1   '
 'with equiripples.                                                          '
 'The popup menu just above the "info" button lets you select a region of the'
 'frequency response to view.  You can zoom-in on the passband, the stopband,' 
 'or look at both bands at once (the "full" view).                           '
 '                                                                           '
 'You can also click and drag the Fpass and Fstop indicators on the figure to'
 'change Rpass, Rstop, Fpass or Fstop.                                       '
 ];

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
            '; filtdemo(''closehelp'',[' num2str(myFig) ' '  num2str(gcf) '])'];
          set(ch(i),'callback',callbackStr)
          return
        end
      end
    end
    return

elseif strcmp(action,'closehelp'),
    % Restore help's close button callback behind helpfun's back
    ch = get(s(2),'ch');
    for i=1:length(ch),
      if strcmp(get(ch(i),'type'),'uicontrol'),
        if strcmp(lower(get(ch(i),'String')),'close'),
          callbackStr = get(ch(i),'callback');
          k = findstr('; filtdemo(',callbackStr);
          callbackStr = callbackStr(1:k-1);
          set(ch(i),'callback',callbackStr)
          break;
        end
      end
    end
    ch = get(0,'ch');
    if ~isempty(find(ch==s(1))), figure(s(1)), end % Make sure figure exists

elseif strcmp(action,'getfilt')
    shh = get(0,'ShowHiddenHandles');
    set(0,'ShowHiddenHandles','on');
    
    % See if any figures are open, if so, see if it's filtdemo
    ch = get(0,'ch');
    indx=[];
    if ~isempty(ch),
        chTags = get(ch,'Tag');
        indx = find(strcmp(chTags,'filtdemo'));
    end
    
    if isempty(indx),
        filtdemo;
        hFig = gcf;
    else
        hFig = ch(indx);
    end        
    fhndlList=get(hFig,'Userdata');        
    set(0,'ShowHiddenHandles',shh)
    freqzHndl = fhndlList(1);
    axhndlList = get(freqzHndl,'UserData');
    h = get(axhndlList(1),'userdata');
    if size(h,1) > 1
        num = h(1,:); den = h(2,:);
    else
        num = h; den = 1;
    end
else
  disp(sprintf( ...
     'filtdemo: action string ''%s'' not recognized, no action taken.',action))
end    % if strcmp(action, ...lose all


