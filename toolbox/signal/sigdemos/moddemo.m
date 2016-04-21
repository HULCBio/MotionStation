function moddemo(action,s,ss);
%MODDEMO Demonstrates modulation and demodulation.
%
% This demo lets you experiment with 4 different modulation schemes.
% They are:
% 
%      AM    - amplitude modulation
%      AMSSB - amplitude modulation, single sideband
%      FM    - frequency modulation
%      PM    - phase modulation
% 
% The demo uses MODULATE and DEMOD in the Signal Processing Toolbox to
% implement these schemes.
% 
% The message signal is displayed in the top left plot.  Its modulated
% version is displayed in the middle left plot.  The demodulated version of
% the modulated signal (the "reconstructed" waveform) is displayed in the
% bottom left plot. The popup menus on the upper right of the figure control:
% 
%     - how to display the signals (upper popup)
%        CHOICES:
%        time     - time domain waveform
%        psd      - power spectral density (frequency domain)
%        specgram - spectrogram (time AND frequency domain) [NOT AVAILABLE IN
%                                                            STUDENT EDITION]
%     - which message signal to use (lower popup)
%        CHOICES:
%        speech   - digitized speech waveform, originally sampled at 7418 Hz
%        sine     - 2 seconds worth of 1 Hertz sine wave
%        square   - 2 seconds worth of 1 Hertz square wave
%        triangle - 2 seconds worth of 1 Hertz triangle wave
% 
% Fc and Fs are the carrier and sampling frequencies, respectively, in Hertz.
% 
% In each modulation scheme, a "carrier signal" (cosine) of frequency Fc is
% altered in some way by the message signal:
%     AM    - amplitude of carrier is message signal
%     AMSSB - two carriers (one cosine, one sine) are modulated by the
%             message signal and its Hilbert transform respectively, and
%             added together
%     FM    - instantaneous frequency of carrier is message signal
%     PM    - instantaneous phase of carrier is message signal
% 
% The "Play ..." buttons let you listen to the signals on most computers.
%
% See also CZTDEMO, FILTDEMO, SOSDEMO.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/11/21 15:47:33 $

% Possible actions:
% initialize
% window
% lowpass
% operation
% cutoff
% order

% button callbacks:
% radio
% apply
% info
% close


if nargin<1,
    action='initialize';
end;

if strcmp(action,'initialize'),
    shh = get(0,'ShowHiddenHandles');
    set(0,'ShowHiddenHandles','on');
    
    figNumber=figure( ...
        'Name','Modulation/Demodulation Demo', ...
        'handlevisibility','callback',...
        'IntegerHandle','off',...
        'NumberTitle','off');

    %slightly inflate the figure size to accomodate labels
    figpos = get(figNumber,'Position');
    set(figNumber,'Position',[figpos(1) figpos(2)-80 figpos(3)+50 figpos(4)+80]);
    
    
    %==================================
    % Set up the axes
    origHndl = axes( ...
        'Units','normalized', ...
        'Position',[0.10 0.80 0.60 0.18], ...
        'XTick',[],'YTick',[], ...
        'Box','on');
    modHndl =  axes( ...
        'Units','normalized', ...
        'Position',[0.10 0.3 0.60 0.45], ...
        'XTick',[],'YTick',[], ...
        'Box','on');
    demodHndl = axes( ...
        'Units','normalized', ...
        'Position',[0.10 0.07 .60 0.18], ...
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
    textWidth = 0.12;
    % Spacing between the button and the next command's label
    spacing=0.012;
    
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
    % The DISPLAY Menu
    menuNumber=1;
    yPos=menutop-(menuNumber-1)*(btnHt+spacing);
    labelStr='time|psd|specgram';
    callbackStr='moddemo(''modulate'');';
    
    % Generic button information
    btnPos=[left yPos-btnHt btnWid btnHt];
    dispHndl=uicontrol( ...
        'Style','popupmenu', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'Interruptible','on', ...
        'Callback',callbackStr);

    %====================================
    % The WAVEFORM Menu
    menuNumber=2;
    yPos=menutop-(menuNumber-1)*(btnHt+spacing);
    labelStr='speech|sine|square|triangle';
    callbackStr='moddemo(''changewave'');';
    
    % Generic button information
    btnPos=[left yPos-btnHt btnWid btnHt];
    waveHndl=uicontrol( ...
        'Style','popupmenu', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'Interruptible','on', ...
        'Callback',callbackStr);

    %===================================
    % Carrier frequency label and text field
    top = yPos - btnHt - spacing;
    labelWidth = frmWidth-textWidth-.01;
    labelBottom = top-textHeight;
    labelLeft = left;
    labelPos = [labelLeft labelBottom labelWidth textHeight];
    h = uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position',labelPos, ...
        'HorizontalAlignment','left', ...
        'String','Fc', ...
        'Interruptible','off', ...
        'BackgroundColor',[0.5 0.5 0.5], ...
        'ForegroundColor','white');
	% Text field
    textPos = [labelLeft+labelWidth labelBottom textWidth textHeight];
    callbackStr = 'moddemo(''setFc'')';
    FcHndl = uicontrol( ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',textPos, ...
        'HorizontalAlignment','center', ...
        'Background','white', ...
        'Foreground','black', ...
        'String','400','Userdata',400, ...
        'callback',callbackStr);

    %===================================
    % Sampling frequency label and text field
    labelBottom=top-2*textHeight-spacing;
	labelLeft = left;
    labelPos = [labelLeft labelBottom labelWidth textHeight];
    h = uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position',labelPos, ...
        'String','Fs', ...
        'HorizontalAlignment','left', ...
        'Interruptible','off', ...
        'Background',[0.5 0.5 0.5], ...
        'Foreground','white');
	% Text field
    textPos = [labelLeft+labelWidth labelBottom textWidth textHeight];
    callbackStr = 'moddemo(''setFs'')';
    FsHndl = uicontrol( ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position',textPos, ...
        'HorizontalAlignment','center', ...
        'Background','white', ...
        'Foreground','black', ...
        'String','2000','Userdata',2000, ...
        'Callback',callbackStr);

    %====================================
    % AM radio button
    btnTop = labelBottom-spacing;
    btnNumber=1;
    yPos=btnTop-(btnNumber-1)*(btnHt+spacing);
    labelStr='AM';
    callbackStr='moddemo(''radio'',1,''am'');';

    % Generic button information
    btnPos=[left yPos-btnHt btnWid btnHt];
    btn1Hndl=uicontrol( ...
        'Style','radiobutton', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'value',1,'Userdata','am', ...
        'Callback',callbackStr);

    %====================================
    % AMSSB radio button
    btnTop = labelBottom-spacing;
    btnNumber=2;
    yPos=btnTop-(btnNumber-1)*(btnHt+spacing);
    labelStr='AMSSB';
    callbackStr='moddemo(''radio'',2,''amssb'');';

    % Generic button information
    btnPos=[left yPos-btnHt btnWid btnHt];
    btn2Hndl=uicontrol( ...
        'Style','radiobutton', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'value',0, ...
        'Callback',callbackStr);

    %====================================
    % FM radio button
    btnNumber=3;
    yPos=btnTop-(btnNumber-1)*(btnHt+spacing);
    labelStr='FM';
    callbackStr='moddemo(''radio'',3,''fm'');';
    
    % Generic button information
    btnPos=[left yPos-btnHt btnWid btnHt];
    btn3Hndl=uicontrol( ...
        'Style','radiobutton', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'Callback',callbackStr);

    %====================================
    % PM radio button
    btnNumber=4;
    yPos=btnTop-(btnNumber-1)*(btnHt+spacing);
    labelStr='PM';
    callbackStr='moddemo(''radio'',4,''pm'');';
    
    % Generic button information
    btnPos=[left yPos-btnHt btnWid btnHt];
    btn4Hndl=uicontrol( ...
        'Style','radiobutton', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'Callback',callbackStr);

    %====================================
    % "Play original" button
    btnNumber=5;
    yPos=btnTop-(btnNumber-1)*(btnHt+spacing);
    labelStr='Play orig';
    callbackStr='moddemo(''playsound'',1);';
    
    % Generic button information
    btnPos=[left yPos-btnHt btnWid btnHt];
    playorigHandl=uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'Callback',callbackStr);

    %====================================
    % "Play mod" button
    btnNumber=6;
    yPos=btnTop-(btnNumber-1)*(btnHt+spacing);
    labelStr='Play mod';
    callbackStr='moddemo(''playsound'',2);';
    
    % Generic button information
    btnPos=[left yPos-btnHt btnWid btnHt];
    playmodHndl=uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'Callback',callbackStr);

    %====================================
    % "Play demod" button
    btnNumber=7;
    yPos=btnTop-(btnNumber-1)*(btnHt+spacing);
    labelStr='Play demod';
    callbackStr='moddemo(''playsound'',3);';
    
    % Generic button information
    btnPos=[left yPos-btnHt btnWid btnHt];
    playdemodHndl=uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'Callback',callbackStr);

    %====================================
    % Message box in center of figure - usually invisible
    messageHndl = uicontrol('style','edit',...
          'string','Resampling speech waveform ...',...
          'units','normalized',...
          'position',[.15 .45 .5 .15],...
          'max',2,...
          'visible','off');

    %====================================
    % The INFO button
    labelStr='Info';
    callbackStr='moddemo(''info'')';
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

    hndlList=[origHndl modHndl demodHndl waveHndl ...
              FcHndl FsHndl dispHndl btn1Hndl btn2Hndl btn3Hndl ...
              btn4Hndl messageHndl helpHndl closeHndl];
    set(figNumber, ...
	'Visible','on', ...
	'UserData',hndlList);

    set(gcf,'Pointer','watch');
    drawnow
    moddemo('changewave')
    set(gcf,'Pointer','arrow');
    set(0,'ShowHiddenHandles',shh)
    return

elseif strcmp(action,'setFc'),
    hndlList=get(gcf,'Userdata');
    filtHndl = hndlList(6);
    v = get(gco,'Userdata');
    s = get(gco,'String');
    vv = eval(s,num2str(v));
    Fs = get(filtHndl,'UserData');
    if vv<0, vv = v; end
    vv = round(vv);
    if vv>=Fs/2
        waitfor(msgbox({'Sorry, the carrier frequency Fc must be less than'...
                  'half the sampling frequency Fs.'},...
                 'Moddemo Error','error','modal'))
        vv = v;
    end
    set(gco,'Userdata',vv,'String',num2str(vv))
    if vv == v
        return
    end
    moddemo('modulate')

elseif strcmp(action,'setFs'),
    fig = gcf;
    set(fig,'Pointer','watch');
    hndlList=get(fig,'Userdata');
    waveHndl = hndlList(4);
    FcHndl = hndlList(5);
    FsHndl = hndlList(6);
    messageHndl = hndlList(12);

    v = get(gco,'Userdata');
    s = get(gco,'String');
    vv = eval(s,num2str(v));
    if vv<=0, vv = v; end
    Fc = get(FcHndl,'UserData'); % Carrier frequency
    vv = round(vv*10)/10;
    if Fc>=vv/2
        waitfor(msgbox({'Sorry, the sampling frequency Fs must be more than'...
                  'twice the carrier frequency Fc.'},...
                 'Moddemo Error','error','modal'))
        vv = v;
    end
    if vv<30
        waitfor(msgbox(['Sorry, the sampling frequency Fs' ...
                        ' must be at least 30.'],...
                 'Moddemo Error','error','modal'))
        vv = v;
    end
    set(gco,'Userdata',vv,'String',num2str(vv))
    if vv == v
        set(fig,'Pointer','arrow');
        return
    end

    waveform = get(waveHndl,'value');
    if waveform==1,   % speech waveform - have to use resample
        modHndl = hndlList(2);
        w = get(waveHndl,'userdata');
        [p,q] = rat(vv/7418,.0001);
       makeinvislist = [modHndl get(modHndl,'children')' get(modHndl,'ylabel')];
        set(messageHndl,'string',...
          sprintf('Resampling waveform at %g/%g\ntimes original rate ...',p,q));
        set(makeinvislist,'visible','off')
        set(messageHndl,'visible','on')
        drawnow
        load mtlb
        yy = resample(mtlb,p,q);
        tt = (0:length(yy)-1)'/vv;
        set(waveHndl,'userdata',[tt yy]);
        set(messageHndl,'visible','off')
        set(makeinvislist,'visible','on')
        moddemo('modulate')
    else
        Fs = get(FsHndl,'UserData'); % Sampling frequency
        Fc = get(FcHndl,'UserData'); % Carrier frequency
        moddemo('changewave',Fc,Fs)
    end
    return

elseif strcmp(action,'changewave')
% create new waveform and stuff it into userdata of popup,
% then call moddemo('modulate')
    set(gcf,'Pointer','watch');
    axHndl=gca;
    hndlList=get(gcf,'Userdata');
    origHndl = hndlList(1);
    modHndl = hndlList(2);
    demodHndl = hndlList(3);
    waveHndl = hndlList(4);
    FcHndl = hndlList(5);
    FsHndl = hndlList(6);

    waveform = get(waveHndl,'value');
    if waveform==2,
      if nargin<2
          Fc = 400;
          Fs = 2000;
      else
          Fc = s;
          Fs = ss;
      end
      t = (0:1/Fs:2)';
      y = sin(2*pi*t);
    elseif waveform==3,
      if nargin<2
          Fc = 400;
          Fs = 2000;
      else
          Fc = s;
          Fs = ss;
      end
      t = (0:1/Fs:2)';
      y = square(2*pi*t);
    elseif waveform==4,
      if nargin<2
          Fc = 400;
          Fs = 2000;
      else
          Fc = s;
          Fs = ss;
      end
      t = (0:1/Fs:2)';
      y = sawtooth(2*pi*t,.5);
    elseif waveform==1,
      load mtlb
      Fc = 2000;
      Fs = 7418;
      y = mtlb;
      t = (0:length(y)-1)'/Fs;
    end
    set(FcHndl,'string',num2str(Fc),'userdata',Fc);
    set(FsHndl,'string',num2str(Fs),'userdata',Fs);
    
    set(waveHndl,'userdata',[t y])
    moddemo('modulate')

    return

elseif strcmp(action,'playsound'),
    set(gcf,'Pointer','watch');

    hndlList=get(gcf,'Userdata');
    modHndl = hndlList(2);
    waveHndl = hndlList(4);
    FcHndl = hndlList(5);
    FsHndl = hndlList(6);
    btn1Hndl = hndlList(8);
    messageHndl = hndlList(12);

    Fc = get(FcHndl,'UserData'); % carrier frequency
    Fs = get(FsHndl,'UserData'); % Sampling frequency
    method = get(btn1Hndl,'Userdata');
    y = get(waveHndl,'userdata');
    y = y(:,2);

    if s == 1,  % original
        sstr = 'original';
    elseif s == 2,  % modulated
        sstr = 'modulated';
    elseif s == 3,  % demodulated
        sstr = 'demodulated';
    end
    c = computer;
    if (strcmp(c,'SUN4') | strcmp(c,'HP700') | strcmp(c,'HPUX') | strcmp(c,'SOL2'))
        play_Fs = 8192;
    else
        play_Fs = Fs;
    end
    str = sprintf('Playing %s waveform \nat %g Hz ...',sstr,play_Fs);
    set(messageHndl,'string',str)
    makeinvislist = [modHndl get(modHndl,'children')' get(modHndl,'ylabel')];
    set(makeinvislist,'visible','off')
    set(messageHndl,'visible','on')
    drawnow

    if s >= 2   % need to compute modulated or demodulated wave
        if strcmp(method,'fm')
            kf = (Fc/Fs)*pi/2; 
            y1 = modulate(y,Fc,Fs,method,kf);
            if s == 3
                y2 = (1/kf)*demod(y1,Fc,Fs,method);
            end
        elseif strcmp(method,'pm')
            kp = pi/2/max(max(abs(y)));
            y1 = modulate(y,Fc,Fs,method,kp);
            if s == 3
                y2 = (1/kp)*demod(y1,Fc,Fs,method);
            end
        else
            y1 = modulate(y,Fc,Fs,method);
            if s == 3
                y2 = demod(y1,Fc,Fs,method);
            end
        end
    end
    if s == 1
        soundStr = 'soundsc(y,play_Fs)';
    elseif s == 2
        soundStr = 'soundsc(y1,play_Fs)';
    elseif s == 3
        soundStr = 'soundsc(y2,play_Fs)';
    end
    eval(soundStr,'')  % catch errors in case no sound capabilities

    set(messageHndl,'visible','off')
    set(makeinvislist,'visible','on')

    set(gcf,'Pointer','arrow');
    return

elseif strcmp(action,'radio'),
    axHndl=gca;
    hndlList=get(gcf,'Userdata');
    for i=8:11,
      set(hndlList(i),'value',0) % Disable all the buttons
    end
    set(hndlList(s+7),'value',1) % Enable selected button
    set(hndlList(8),'Userdata',ss) % Remember selected button
    moddemo('modulate')
    return

elseif strcmp(action,'modulate'), % modulate, demodulate, and update display
    set(gcf,'Pointer','watch');
    axHndl=gca;
    hndlList=get(gcf,'Userdata');
    origHndl = hndlList(1);
    modHndl = hndlList(2);
    demodHndl = hndlList(3);
    waveHndl = hndlList(4);
    FcHndl = hndlList(5);
    FsHndl = hndlList(6);
    dispHndl = hndlList(7);
    btn1Hndl = hndlList(8);
    btn2Hndl = hndlList(9);
    btn3Hndl = hndlList(10);
    btn4Hndl = hndlList(11);

    set(gcf,'nextplot','add')

    edgecolor = get(gca,'colororder'); edgecolor = edgecolor(1,:);
    
    Fs = get(FsHndl,'UserData'); % Sampling frequency
    Fc = get(FcHndl,'UserData'); % Carrier frequency

    w = get(waveHndl,'userdata');
    t = w(:,1);  y = w(:,2);
    
    method = get(btn1Hndl,'Userdata');

    if strcmp(method,'fm')
        % kf = (Fc/Fs)*2*pi/max(abs(y));
        kf = (Fc/Fs)*pi/2; 
        y1 = modulate(y,Fc,Fs,method,kf);
        y2 = (1/kf)*demod(y1,Fc,Fs,method);
    elseif strcmp(method,'pm')
        kp = pi/2/max(max(abs(y)));
        y1 = modulate(y,Fc,Fs,method,kp);
        y2 = (1/kp)*demod(y1,Fc,Fs,method);
    else
        y1 = modulate(y,Fc,Fs,method);
        y2 = demod(y1,Fc,Fs,method);
    end
    if get(dispHndl,'value')==1,   % time waveform
      axes(origHndl), plot(t,y), grid on
      ylabel('Original')
      axes(modHndl), strips(y1,(length(y1)-1)/8/Fs,Fs), grid on
      ylabel('Modulated')
      axes(demodHndl), plot(t,y2), grid on
      ylabel('Demodulated')
      xlabel('Time (Seconds)')
    elseif get(dispHndl,'value')==2,   % psd
      [Y,f] = psd(y,1024,Fs,500,0,'none');
      [Y1,f] = psd(y1,1024,Fs,500,0,'none');
      [Y2,f] = psd(y2,1024,Fs,500,0,'none');
      Y = 10*log10(Y);
      Y1 = 10*log10(Y1);
      Y2 = 10*log10(Y2);
      axes(origHndl), plot(f,Y), grid on, ylabel('Original')
      axes(modHndl), plot(f,Y1), grid on, ylabel('Modulated')
      axes(demodHndl), plot(f,Y2), grid on, ylabel('Demodulated')
      xlabel('Frequency (Hz)')
      set(hndlList(1:3),'ylim', ...
       [max(max(min([Y Y1 Y2])),-120) max(max([Y Y1 Y2]))],'xlim',[0 Fs/2])
    else  % specgram
      k = 150;
      wind = kaiser(128,5);
      nwind = length(wind);
      noverlap = max(fix((length(y) - k*nwind) / (1-k)),0);
      [b,f,t] = specgram(y,128,Fs,wind,noverlap);
      [b1,f,t] = specgram(y1,256,Fs,wind,noverlap);
      [b2,f,t] = specgram(y2,128,Fs,wind,noverlap);
      Y1 = 10*log10(abs(b1+eps));
      clims = [min(min(Y1)) max(max(Y1))];
      axes(modHndl), imagesc(t,f,Y1), axis xy, colormap(jet)
      ylabel('Modulated')
      axes(origHndl), imagesc(t,f,10*log10(abs(b+eps)),clims) 
      axis xy, colormap(jet)
      ylabel('Original')
      axes(demodHndl), imagesc(t,f,10*log10(abs(b2+eps)),clims)
      axis xy, colormap(jet)
      ylabel('Demodulated')
      xlabel('Time (Seconds)')
    end

    set(gcf,'Pointer', 'arrow')
    return

elseif strcmp(action,'info'),
    set(gcf,'pointer','arrow')
	ttlStr = get(gcf,'Name');
	hlpStr= [...
             'This demo lets you experiment with 4 different modulation schemes.         '
             'They are:                                                                  '
             '                                                                           '
             '     AM    - amplitude modulation                                          '
             '     AMSSB - amplitude modulation, single sideband                         '
             '     FM    - frequency modulation                                          '
             '     PM    - phase modulation                                              '
             '                                                                           '
             'The demo uses MODULATE and DEMOD in the Signal Processing Toolbox to       '
             'implement these schemes.                                                   '
             '                                                                           '
             'The message signal is displayed in the top left plot.  Its modulated       '
             'version is displayed in the middle left plot.  The demodulated version of  '
             'the modulated signal (the "reconstructed" waveform) is displayed in the    '
             'bottom left plot. The popup menus on the upper right of the figure control:'
             '                                                                           '
             '    - how to display the signals (upper popup)                             '
             '       CHOICES:                                                            '
             '       time     - time domain waveform                                     '
             '       psd      - power spectral density (frequency domain)                '
             '       specgram - spectrogram (time AND frequency domain) [NOT AVAILABLE IN'
             '                                                           STUDENT EDITION]'
             '    - which message signal to use (lower popup)                            '
             '       CHOICES:                                                            '
             '       speech   - digitized speech waveform, originally sampled at 7418 Hz '
             '       sine     - 2 seconds worth of 1 Hertz sine wave                     '
             '       square   - 2 seconds worth of 1 Hertz square wave                   ' 
             '       triangle - 2 seconds worth of 1 Hertz triangle wave                 '
             '                                                                           '
             'Fc and Fs are the carrier and sampling frequencies, respectively, in Hertz.'
             '                                                                           '
             'In each modulation scheme, a "carrier signal" (cosine) of frequency Fc is  '
             'altered in some way by the message signal:                                 '
             '    AM    - amplitude of carrier is message signal                         '
             '    AMSSB - two carriers (one cosine, one sine) are modulated by the       '
             '            message signal and its Hilbert transform respectively, and     '
             '            added together                                                 '
             '    FM    - instantaneous frequency of carrier is message signal           '
             '    PM    - instantaneous phase of carrier is message signal               '
             '                                                                           '
             'The "Play ..." buttons let you listen to the signals on most computers.    '];

    myFig = gcf;
    helpwin(hlpStr,ttlStr);

elseif strcmp(action,'closehelp'),
    % Restore close button help behind helpwin's back
    ch = get(gcf,'ch');
    for i=1:length(ch),
      if strcmp(get(ch(i),'type'),'uicontrol'),
        if strcmp(lower(get(ch(i),'String')),'close'),
          callbackStr = get(ch(i),'callback');
          k = findstr('; moddemo(',callbackStr);
          callbackStr = callbackStr(1:k-1);
          set(ch(i),'callback',callbackStr)
          break;
        end
      end
    end
    ch = get(0,'ch');
    if ~isempty(find(ch==s)), figure(s), end % Make sure figure exists

end    % if strcmp(action, ...lose all
