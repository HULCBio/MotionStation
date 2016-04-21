function sigdemo1(action,in1,in2);
%SIGDEMO1 Interactive DFT of a signal
%   Illustrates some basic signal processing concepts, such as sampling,
%   aliasing, and windowing.
% 
%   You are seeing discrete samples of a periodic waveform (the upper plot) and
%   the absolute value of its discrete Fourier transform (DFT), obtained using
%   a fast Fourier transform (FFT) algorithm (the lower plot).
% 
%   In the lower plot, frequencies from 0 to 100 Hertz are displayed. The DFT
%   at negative frequencies is a mirror image of the DFT at positive frequen-
%   cies.  The sampling rate is 200 Hertz, which means the "Nyquist frequency"
%   is 100 Hertz.  The DFT at frequencies above the Nyquist frequency is the
%   same as the DFT at lower (negative) frequencies.
% 
%   Click and drag a point on the waveform shown in the upper plot to move that
%   point to a new location. This sets a new fundamental frequency and
%   amplitude.
% 
%   The "Signal" pop-up menu lets you change the shape of the waveform.
% 
%   The "Window" menu lets you select a window function. This window is multi-
%   plied by the time waveform prior to taking the DFT.
% 
%   The fundamental frequency of the waveform is given in the text box. You can
%   change the fundamental frequency by clicking in the text box, editing the
%   number there, and pressing RETURN.  You can also change the fundamental by
%   clicking and dragging on the waveform.

%   Author: T. Krauss
%   11/3/92, updated 2/9/93
%   Adapted for Expo: dlc, 7-93
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2004/04/20 23:20:46 $

%   possible actions:
%     'start'
%     'down'
%     'move'
%     'up'
%     'redraw'
%     'done'
%     'setfreq'
%     'setwindow'
%     'showwind'

if nargin<1,
    action='start';
end;

global SIGDEMO1_DAT
global ADDIT_DAT    % this is for WINDOW pop-up button

if strcmp(action,'start'),

    %====================================
    % Graphics initialization
    oldFigNumber = watchon;
    figNumber = figure;
    set(gcf, ...
        'NumberTitle','off', ...
        'Name','Discrete Fourier Transform', ...
        'backingstore','off',...
        'Units','normalized');

    %====================================
    % Information for all buttons
    labelColor=192/255*[1 1 1];
    top=0.95;
    bottom=0.05;
    left=0.75;
    yInitLabelPos=0.90;
    left = 0.78;
    labelWid=0.18;
    labelHt=0.05;
    btnWid = 0.18;
    btnHt=0.07;
    % Spacing between the label and the button for the same command
    btnOffset=0.003;
    % Spacing between the button and the next command's label
    spacing=0.05;
 
    %====================================
    % The CONSOLE frame
    frmBorder=0.02;
    yPos=0.05-frmBorder;
    frmPos=[left-frmBorder yPos btnWid+2*frmBorder 0.9+2*frmBorder];
    h=uicontrol( ...
        'Style','frame', ...
        'Units','normalized', ...
        'Position',frmPos);
    
    %====================================
    % The SIGNAL command popup button

    btnNumber=1;
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
    labelStr=' Signal';

    % Generic label information
    labelPos=[left yLabelPos-labelHt labelWid labelHt];
    uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position',labelPos, ...
        'HorizontalAlignment','left', ...
        'String',labelStr);

    btnPos=[left yLabelPos-labelHt-btnHt-btnOffset btnWid btnHt];
    popup=uicontrol('Style','Popup','String','sine|square|sawtooth',...
        'Units','normalized',...
        'Position', btnPos, ...
        'CallBack','sigdemo1(''redraw'')');

    %====================================
    % The WINDOW command popup button
    btnNumber=2;
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
    labelStr=' Window';
    popupStr= ' rectangle| triangular| hanning| hamming| chebyshev| kaiser';
    callbackStr= 'sigdemo1(''setwindow'')';

    % Generic label information
    labelPos=[left yLabelPos-labelHt labelWid labelHt];
    uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position',labelPos, ...
        'HorizontalAlignment','left', ...
        'String',labelStr);

    % Generic popup button information
    btnPos=[left yLabelPos-labelHt-btnHt-btnOffset btnWid btnHt];
    winHndl = uicontrol( ...
        'Style','popup', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',popupStr, ...
        'Callback',callbackStr);

  %====================================
    % The FUNDAMENTAL editable text box
    btnNumber=3;
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
    labelPos=[left yLabelPos-labelHt labelWid labelHt];
    freq_text = uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position', labelPos, ...
        'String','Fundamental');

    btnPos=[left+0.02  yLabelPos-labelHt-btnHt-btnOffset ...
            0.5*btnWid+frmBorder  btnHt];
    freq_field = uicontrol( ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position', btnPos, ...
        'BackgroundColor','w',...
        'String',' 5',...
        'CallBack','sigdemo1(''setfreq''); sigdemo1(''redraw'')');

   %====================================
    % The INFO button
    uicontrol( ...
        'Style','push', ...
        'Units','normalized', ...
        'Position',[left bottom+(2*labelHt)+spacing btnWid 2*labelHt], ...
        'String','Info', ...
        'Callback','sigdemo1(''info'')');

   %========================================
   % The CLOSE button
    done_button=uicontrol('Style','Pushbutton', ...
        'Units','normalized',...
        'Position',[left bottom btnWid 2*labelHt], ...
        'Callback','sigdemo1(''done'')','String','Close');
   %====================================

    % Create intial signal
    N=201;     % number of samples
%    N=21;
    amp=0.5;
    freq=5;    % hertz
    t0=0;      % seconds
    t1=1;      % seconds
    t=linspace(t0,t1,N)';
    T=(t1-t0)/N;            % sampling rate in seconds
    M=256;     % length of fft
    window=ones(N,1);    % use window to lower side-lobes in the freq. domain
                             % (makes peaks wider)

    min_dB = -40; % freq. domain lower axis limit

    % create axes for time domain and frequency domain plot
    ax_freq=axes('Position',[.12 .14 .6 .3],'XLim',...
             [0 1/(2*T)],'YLim',[min_dB 50]);
    
    val = get(popup,'Value');
     
    % time domain
    f=local_dataSet(val,amp,t,freq);    

    % frequency domain
    [FF,w]=local_fftpsd(f,window,M,min_dB);    

    freq_line=plot(w/2/pi/T,FF,'EraseMode','xor');
    axis([0 1/(2*T)  min_dB 50]);
    grid on;
    ylabel('Magnitude (dB)');
    xlabel('Frequency (Hertz)');

    ax_time=axes('Position',[.12 .58 .6 .3],'XLim',[t0 t1],'YLim',[-1 1]);
    time_line=plot(t,f,'EraseMode','xor');
    axis([t0 t1 -1 1]);
    % (set to xor mode to prevent re-rendering, that is, for speed)
    grid on;
    ylabel('Waveform');
    xlabel('Time (Seconds)');
    text(0.12, 1.55,'  Click and drag waveform to change');
    text(0.12, 1.3,'fundamental frequency and amplitude');

    set(time_line,'ButtonDownFcn','sigdemo1(''down'')');
    SIGDEMO1_DAT = [freq; amp; N; M; min_dB; 0; 0; ...
         time_line; freq_line; freq_field; popup; -1; gcf; t(:); window(:)];
    ADDIT_DAT = winHndl;

    watchoff(oldFigNumber);

elseif strcmp(action,'down'),
    % assumes that a line was clicked 
    time_line=SIGDEMO1_DAT(8);    
    axes(get(time_line,'parent'));     % set the right axes

    % Obtain coordinates of mouse click location in axes units
    pt=get(gca,'currentpoint');
    x=pt(1,1);
    y=pt(1,2);


% find closest vertex of line to mouse click location (call it fixed_x, fixed_y)

    line_x=get(time_line,'XData');
    line_y=get(time_line,'YData');
    units_str = get(gca,'units');  % save normalized state
    set(gca,'units','pixels');     % distance must be in pixels
    p=get(gca,'pos');
    xa=get(gca,'xlim');
    ya=get(gca,'ylim');
    
    dist=((line_x-x)*p(3)/(xa(2)-xa(1))).^2 + ...
         ((line_y-y)*p(4)/(ya(2)-ya(1))).^2;
    [temp,i]=min(dist);
    fixed_x=line_x(i);
    fixed_y=line_y(i);
    set(time_line,'LineStyle','--');

    SIGDEMO1_DAT(6)=fixed_x;
    SIGDEMO1_DAT(7)=fixed_y;

    set(gca,'units',units_str );
    set(gcf,'WindowButtonMotionFcn', 'sigdemo1(''move'')');
    set(gcf,'WindowButtonUpFcn', 'sigdemo1(''up'')');
    % set(gcf,'userdata',u);

elseif strcmp(action,'move'),
    % u = get(gcf,'userdata');
    freq=SIGDEMO1_DAT(1);
    amp=SIGDEMO1_DAT(2);
    N=SIGDEMO1_DAT(3);
    M=SIGDEMO1_DAT(4);
    min_dB=SIGDEMO1_DAT(5);
    fixed_x=SIGDEMO1_DAT(6);
    fixed_y=SIGDEMO1_DAT(7);
    time_line=SIGDEMO1_DAT(8);
    freq_line=SIGDEMO1_DAT(9);
    freq_field=SIGDEMO1_DAT(10);
    popup=SIGDEMO1_DAT(11);
    t=SIGDEMO1_DAT(14:14+N-1);
    window=SIGDEMO1_DAT(14+N:14+N+N-1);
    
    % Avoid divide by zero warnings
    if fixed_y==0,
        fixed_y=eps;
    end
    
    pt=get(gca,'currentpoint');
    x=pt(1,1);
    y=pt(1,2);
    
    % Avoid divide by zero warnings
    if x==0,
        x=eps;
    end
    
    amp1=y/fixed_y*amp;
    if (abs(amp1)>1.0),
       amp1=1.0*sign(amp1);
    end;
    if (abs(amp1)<0.05),
       amp1=0.05*sign(amp1);
    end;
    if (amp1 == 0),
        amp1=0.05;
    end;
    freq1=fixed_x/x*freq;

    val = get(popup,'Value');
    % time domain
    f=local_dataSet(val,amp1,t,freq1);

    set(time_line,'YData',f);
    % frequency domain
    [FF,w]=local_fftpsd(f,window,M,min_dB);

    set(freq_line,'YData',FF);
    set(freq_field,'String',num2str(freq1));

elseif strcmp(action,'up'),
    pt=get(gca,'currentpoint');
    x=pt(1,1);
    y=pt(1,2);

    set(gcf,'WindowButtonMotionFcn','');
    set(gcf,'WindowButtonUpFcn','');

    % u=get(gcf,'userdata');
    freq=SIGDEMO1_DAT(1);
    amp=SIGDEMO1_DAT(2);
    fixed_x=SIGDEMO1_DAT(6);
    fixed_y=SIGDEMO1_DAT(7);

    if fixed_y==0,
        fixed_y=eps;
    end

    amp1=y/fixed_y*amp;
    if (abs(amp1)>1.0),
       amp1=1.0*sign(amp1);
    end;
    if (abs(amp1)<0.05),
       amp1=0.05*sign(amp1);
    end;
    freq1=fixed_x/x*freq;

    set(SIGDEMO1_DAT(8),'linestyle','-');
    SIGDEMO1_DAT(1)=freq1;  % set amplitude and frequency
    SIGDEMO1_DAT(2)=amp1;
    % set(gcf,'userdata',u);
    sigdemo1('redraw');

elseif strcmp(action,'done'),
    % close the figure window that is showing the window fnction:
    % u = get(gcf,'userdata');
    if (SIGDEMO1_DAT(12)~=-1),
        close(SIGDEMO1_DAT(12));
    end;
    close(gcf);
    clear global SIGDEMO1_DAT
    clear global ADDIT_DAT

elseif strcmp(action,'redraw'),
    % recomputes time and frequency waveforms and updates display
    % u = get(gcf,'userdata');
    freq=SIGDEMO1_DAT(1);
    amp=SIGDEMO1_DAT(2);
    N=SIGDEMO1_DAT(3);
    M=SIGDEMO1_DAT(4);
    min_dB=SIGDEMO1_DAT(5);
    time_line=SIGDEMO1_DAT(8);
    freq_line=SIGDEMO1_DAT(9);
    freq_field=SIGDEMO1_DAT(10);
    popup=SIGDEMO1_DAT(11);
    t=SIGDEMO1_DAT(14:14+N-1);
    window=SIGDEMO1_DAT(14+N:14+N+N-1);
    val = get(popup,'Value');

    % time domain
    f=local_dataSet(val,amp,t,freq);

    set(time_line,'YData',f);

    % frequency domain
    [FF,w]=local_fftpsd(f,window,M,min_dB);

    set(freq_line,'YData',FF);
    set(freq_field,'String',num2str(freq));

    drawnow;

elseif strcmp(action,'setwindow'),
    % u = get(gcf,'userdata');
    winHndl = ADDIT_DAT;
    in1 = get(winHndl,'Value');
    in2 = 30;
    N=SIGDEMO1_DAT(3);

    if (in1==1),
        window = boxcar(N);
    elseif (in1==2),
        window = triang(N);
    elseif (in1==3),
        window = hanning(N);
    elseif (in1==4),
        window = hamming(N);
    elseif (in1==5),
        window = chebwin(N,30);
    elseif (in1==6),
        window = kaiser(N,4);
    end;

    SIGDEMO1_DAT(14+N:14+N+N-1)=window;
    % set(gcf,'userdata',u);
    sigdemo1('redraw');
    if (SIGDEMO1_DAT(12)~=-1),
        sigdemo1('showwind');
    end;

elseif strcmp(action,'showwind'),
    % u=get(gcf,'userdata');
    oldfig=gcf;
    N=SIGDEMO1_DAT(3);
    t=SIGDEMO1_DAT(14:14+N-1);
    window=SIGDEMO1_DAT(14+N:14+N+N-1);
    if (SIGDEMO1_DAT(12)==-1),
        SIGDEMO1_DAT(12)=figure;

        axes('Position',[.15 .62 .8 .3]);
        line1=plot(t,window); 
        title('Window function');
        xlabel('time (seconds)');
        grid on;
        ylabel('Window');

        axes('Position',[.15 .2 .8 .3]);
        W=fft(window,1024);
        line2=plot((0:(1/1024):(.5-(1/1024)))*N,20*log10(abs(W(1:512)))); 
        set(gca,'xlim',[0 N/2]);
        xlabel('Frequency (Hz)');
        ylabel('Magnitude (dB)');
        grid on;
        windclose=uicontrol('Style','Pushbutton','Units','Normalized',...
            'Position',[.85 .02 .12 .08],...
            'Callback',['THEHAND=get(gcf,''userdata'');'...
            'close; figure(THEHAND(1)); global SIGDEMO1_DAT, '...
            'SIGDEMO1_DAT(12)=-1; clear THEHAND SIGDEMO1_DAT'],...
            'String','Close');
        set(gcf,'userdata',[oldfig line1 line2]);
        % set(oldfig,'userdata',u);
        
    else
        figure(SIGDEMO1_DAT(12));
        lines=get(gcf,'userdata');
        set(lines(2),'ydata',window);
        W=fft(window,1024);
        set(lines(3),'ydata',20*log10(abs(W(1:512))));
        drawnow
    end

elseif strcmp(action,'setfreq'),
    x = str2double(get(SIGDEMO1_DAT(10),'string'));
    if isnan(x),   % handle the non-numeric case
        set(SIGDEMO1_DAT(10),'string',num2str(SIGDEMO1_DAT(1)));
    else
        SIGDEMO1_DAT(1)=x;
    end;

elseif strcmp(action,'info'),
    ttlStr = 'Discrete Fourier Transform'; 

    hlpStr= ...                                              
        ['You are seeing discrete samples of a periodic waveform (the upper plot) and'
         'the absolute value of its discrete Fourier transform (DFT), obtained using '
         'a fast Fourier transform (FFT) algorithm (the lower plot).                 '  
         '                                                                           '  
         'In the lower plot, frequencies from 0 to 100 Hertz are displayed. The DFT  '
         'at negative frequencies is a mirror image of the DFT at positive frequen-  '
         'cies.  The sampling rate is 200 Hertz, which means the "Nyquist frequency" '  
         'is 100 Hertz.  The DFT at frequencies above the Nyquist frequency is the   '
         'same as the DFT at lower (negative) frequencies.                           '    
         '                                                                           '
         'Click and drag a point on the waveform shown in the upper plot to move that'
         'point to a new location. This sets a new fundamental frequency and         '
         'amplitude.                                                                 '  
         '                                                                           '  
         'The "Signal" pop-up menu lets you change the shape of the waveform.        '  
         '                                                                           '  
         'The "Window" menu lets you select a window function. This window is multi- '
         'plied by the time waveform prior to taking the DFT.                        '  
         '                                                                           '  
         'The fundamental frequency of the waveform is given in the text box. You can' 
         'change the fundamental frequency by clicking in the text box, editing the  '
         'number there, and pressing RETURN.  You can also change the fundamental by '
         'clicking and dragging on the waveform.                                     '];

     helpwin(hlpStr, ttlStr);

end

%-------------------------------------------------------------
function [FF,w] = local_fftpsd(f,window,M,min_dB)
% LOCAL_FFTPSD Calculates the Power Spectral Density estimate 
%              via the FFT.
%

    F=fft(window.*f,2*M);
    F=F(1:M);
    w=(0:M-1)*pi/M;
    indxs = find(F==0);
    F(indxs) = eps;        % Avoid warning of divide by zero
    FF=20*log10(abs(F));
    ind=find(FF<min_dB);
    FF(ind)=NaN*ones(size(ind)); % put NaN's in where
         % min_dB shows up - this is to work around no clipping in xor mode
         
%-------------------------------------------------------------              
function f = local_dataSet(val,amp,t,freq)
% LOCAL_DATASET - Calculates the test data set based on the signal
%                 the user selected in the popupmenu.

    if (val == 1),
        f=amp*sin(freq*t*2*pi);
    elseif (val == 2),   % square wave
        tt=freq*t*2*pi;
        tmp=rem(tt,2*pi);
        f=amp*(2*rem((tt<0)+(tmp>pi | tmp<-pi)+1,2)-1);
    elseif (val == 3),   % sawtooth
        tt=freq*t*2*pi;
        f=amp*((tt < 0) + rem(tt,2*pi)/2/pi - .5)*2;
    end;
