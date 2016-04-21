function phone(action)
%PHONE  Signal processing and the touch-tone phone.
%
% This window demonstrates the speed and utility of the "pwelch" command in
% the Signal Processing Toolbox.
%
% The touch tone phone pad in the upper right plays the actual tones used by
% a normal phone. The upper plot shows a sample of the time response of the
% sound. The lower plot shows the spectrum associated with the waveform.
%
% Notice that two tones are used to code each number on the dial.

%   Author(s): Ned Gulley, 6-21-93
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $  $Date: 2004/04/20 23:20:44 $

persistent Fs tones t;
if isempty(tones),
    % Generate DTMF tones:
    Fs  = 8000;
    t   = (0:799)/Fs;    % 800 samples at Fs
    pit = 2*pi*t;
    
    fc = [697 770 852 941];
    fr = [1209 1336 1477]; 
    f  = [];
    for c=1:4,
        for r=1:3,
            f = [ f [fc(c);fr(r)] ];
        end
    end
    
    for i=1:size(f,2),
        tones(:,i) = sum(sin(f(:,i)*pit))' / 4;
    end
end

if nargin<1,
    action='initialize';
end

if strcmp(action,'initialize'),
    figNumber=figure( ...
        'Name','Phone Pad', ...
        'NumberTitle','off', ...
        'Backingstore','off', ...
        'Visible','off');
    axHndl1=axes( ...
        'Units','normalized', ...
        'Position',[0.10 0.60 0.60 0.32], ...
        'Drawmode','fast', ...
        'Visible','on');
    axHndl2=axes( ...
        'Units','normalized', ...
        'Position',[0.10 0.10 0.60 0.32], ...
        'Drawmode','fast', ...
        'Visible','on');

    %===================================
    % Information for all buttons
    labelColor=[0.8 0.8 0.8];
    top=0.85;
    left=0.75;
    bottom=0.05;
    xLabelPos=0.75;
    labelWid=0.20;
    labelHt=0.05;
    btnWid=0.20;
    btnHt=0.08;
    % Spacing between the button and the next command's label
    spacing=0.05;
    btnOffset=0;
    
    %====================================
    % The CONSOLE frame
    % Use the frame's userdata to hold the tones matrix
    frmBorder=0.02;
    yPos=bottom-frmBorder;
    frmPos=[left-frmBorder yPos btnWid+2*frmBorder 0.9+2*frmBorder];
    frmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','normalized', ...
        'Position',frmPos, ...
        'BackgroundColor',[0.50 0.50 0.50]);

    %====================================
    % The TONE buttons
    %btnNumber=1;
    %yLabelPos=0.90-(btnNumber-1)*(btnHt+labelHt+spacing);
    labelStr=' Button No.';
    
    for count=1:12,
        btnPos=[xLabelPos+rem(count-1,3)*(btnWid/3) ...
                top-floor((count-1)/3)*(btnWid/3) btnWid/3 btnWid/3];
        if count<10,
            btnStr=num2str(count);
        else
            s = '*0#';
            btnStr = s(count-9);
        end
        uicontrol( ...
            'Style','pushbutton', ...
            'Units','normalized', ...
            'Position',btnPos, ...
            'String',btnStr, ...
            'UserData',count, ...
            'Callback','phone(''tone'')');
    end

    %====================================
    % The SOUND button
    btnNumber=2;
    yPos=top-3*btnHt;
    labelStr='Sound';
    % Setting this checkbox will allow the sound to work
    
    % Generic button information
    btnPos=[left yPos-btnHt btnWid btnHt];
    sndHndl=uicontrol( ...
        'ForegroundColor', [1 1 1], ...
        'BackgroundColor', [0.50 0.50 0.50], ...
        'Style','checkbox', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'Enable','on', ...
        'String',labelStr);

    %====================================
    % The INFO button
    labelStr='Info';
    callbackStr='phone(''info'')';
    infoHndl=uicontrol( ...
        'Style','push', ...
        'Units','normalized', ...
        'Position',[left bottom+btnHt+spacing btnWid btnHt], ...
        'String',labelStr, ...
        'Callback',callbackStr);

    %====================================
    % The CLOSE button
    labelStr='Close';
    callbackStr='close(gcf)';
    closeHndl=uicontrol( ...
        'Style','push', ...
        'Units','normalized', ...
        'Position',[left bottom btnWid btnHt], ...
        'String',labelStr, ...
        'Callback',callbackStr);

    % Initialize the plot with tone number 1
    axes(axHndl1);
    tone=tones(:,1);
    plot1Hndl=plot(t,tone,'Erasemode','background');
    xlabel('Time (sec)');
    ylabel('Signal');
    title('Time Response');
    set(axHndl1,'XLim',[0 0.05],'YLim',[-1 1]);
    axes(axHndl2);
    p = pwelch(tones(:,1),hanning(256),128,256,1);
    f = (0:127)/128 * (Fs/2);
    f=f(1:63);
    p=p(1:63,1);
    plot2Hndl=semilogy(f,p,'Erasemode','background');
    xlabel('Frequency (Hz)');
    ylabel('Signal Power');
    title('Spectrum');
    set(axHndl2,'XLim',[0 2000]);

    % Uncover the figure
    set(figNumber,'Visible','on', ...
        'UserData',[frmHndl infoHndl closeHndl plot1Hndl plot2Hndl sndHndl]);

elseif strcmp(action,'tone'),
    figNumber=watchon;
    hndlList=get(figNumber,'Userdata');
    frmHndl=hndlList(1);
    infoHndl=hndlList(2);
    closeHndl=hndlList(3);
    plot1Hndl=hndlList(4);
    plot2Hndl=hndlList(5);
    sndHndl=hndlList(6);
    %set([closeHndl infoHndl],'Enable','off');

    % ====== Playback the tone here
    % Sampling rate is Fs Hz
    toneChoice=get(gco,'UserData');
    tone=tones(:,toneChoice);
    if get(sndHndl,'Value'),
        sound(tone,Fs);
    end
    p = pwelch(tone,hanning(256),128,256,1);
    f = (0:127)/128 * (Fs/2);
    p=p(1:63,1);
    set(plot1Hndl,'YData',tone);
    set(plot2Hndl,'Ydata',p);
    % ====== End of playing tone

    %set([closeHndl infoHndl],'Enable','on');
    watchoff(figNumber);


elseif strcmp(action,'info'),
    ttlStr=get(gcf,'Name');
    hlpStr= ...              
        ['This window demonstrates the speed and utility of the "pwelch" command in  '
         'the Signal Processing Toolbox.                                             '  
         '                                                                           '  
         'The touch tone phone pad in the upper right plays the actual tones used by '
         'a normal phone. The upper plot shows a sample of the time response of the  '
         'sound. The lower plot shows the spectrum associated with the waveform.     '  
         '                                                                           '  
         'Notice that two tones are used to code each number on the dial.            '];
    helpwin(hlpStr,ttlStr);                              

end    % if strcmp(action, ...

% [EOF] phone.m
