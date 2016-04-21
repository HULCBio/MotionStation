function sigdemo2(action,in1,in2);
%SIGDEMO2 Interactive signal demo - 2 : continuous FT of a signal
%   Demonstrates MATLAB's graphic user interface using Handle Graphics
%   while illustrating basic Fourier transform (FT) properties,
%   including modulation.

%   Author: T. Krauss
%   11/3/92, updated 2/9/93
%
%   Adapted for Expo: dlc, 7/21/93
%
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/15 01:20:21 $

%       possible actions:
%         'start'
%         'down'       - in1=1 ==> time_line, in1=2 ==> freq_line
%         'move'
%         'up'
%         'redraw'     
%         'setfreq'    - in1=1 ==> from slider, in1=2 ==> from edit text
%         'info'
%         'done'

if nargin<1,
    action='start';
end;

global SIGDEMO2_DAT

if strcmp(action,'start'),

    %====================================
    % Graphics initialization
    oldFigNumber = watchon;
    figNumber = figure;
    set(gcf, ...
        'NumberTitle','off', ...
        'Name','Modulation Frequency', ...
        'backingstore','off',...
        'Units','normalized');
 
    %====================================
    % Information for all buttons
    top=0.95;
    bottom=0.05;
    left=0.82;
    yInitLabelPos=0.90;
    btnWid = 0.13;
    btnHt=0.08;
    % Spacing between the label and the button for the same command
    btnOffset=0.02;
    % Spacing between the button and the next command's label
    spacing=0.02;
    %bottom=bottom+spacing;
 
    %====================================
    % The CONSOLE frame
    frmBorder=0.02;
    yPos=0.02;
    frmPos=[left-frmBorder bottom-frmBorder btnWid+2*frmBorder ...
            0.9+2*frmBorder];
    h=uicontrol( ...
        'Style','frame', ...
        'Units','normalized', ...
        'Position',frmPos);

    %====================================
    % The INFO button
    uicontrol( ...
        'Style','push', ...
        'Units','normalized', ...
        'Position',[left bottom+btnHt+spacing  btnWid btnHt], ...
        'String','Info', ...
        'Callback','sigdemo2(''info'')');
 
   %========================================
   % The CLOSE button
    done_button=uicontrol('Style','Pushbutton', ...
        'Units','normalized',...
        'Position',[left bottom btnWid btnHt], ...
        'Callback','sigdemo2(''done'')','String','Close');
   %====================================

    bg = get(0,'defaultfigurecolor');
    fg = get(0,'defaultaxesxcolor');

    % Create initial signal
    min_freq = 1;
    max_freq = 5;
    min_amp = .1;
    max_amp = 1;
    amp=0.5;
    freq=2.5;    % hertz
    [t,f,w,F]=tffunc(amp,freq);

    freq_text=uicontrol('Style','text',...
        'Units','normalized',...
        'Position',[.18 .02 .38 .07],...
        'HorizontalAlignment','right',...
        'BackgroundColor',bg,...
        'ForegroundColor',fg,'String','Modulation Frequency (Hertz):');

    uicontrol('style','text',...
        'Units','normalized',...
        'Position',[.14 .07 .02 .05],...
        'HorizontalAlignment','left',...
        'BackgroundColor',bg,...
        'ForegroundColor',fg,'String',num2str(min_freq));

    uicontrol('style','text',...
        'Units','normalized',...
        'Position',[.74 .07 .02 .05 ],...
        'HorizontalAlignment','left',...
        'BackgroundColor',bg,...
        'ForegroundColor',fg,'String',num2str(max_freq));

    freq_field=uicontrol('Style','edit',...
        'Units','normalized',...
        'Position',[.59 .02 .12 .07],...
        'HorizontalAlignment','left',...
        'String',num2str(freq),...
        'BackgroundColor','w',...
        'CallBack','sigdemo2(''setfreq'',2); sigdemo2(''redraw'');');

%    freq_slider=uicontrol('Style','slider','Position',[.15 .12 .6 .04],...
    freq_slider=uicontrol('Style','slider',...
        'Units','normalized',...
        'Position',[.12 .12 .6 .04],...
        'Value',freq,'Max',max_freq,'Min',min_freq,...
        'Callback','sigdemo2(''setfreq'',1); sigdemo2(''redraw'');');
   
    %  frequency domain
%    ax_freq=axes('Position',[.15 .28 .8 .26],'XLim',[-8 8],'YLim',[-.5 2]);
    ax_freq=axes('Position',[.12 .28 .6 .26],'XLim',[-8 8],'YLim',[-.5 2]);
    freq_line=plot(w,F,'EraseMode','xor');
    axis([-8 8 -.5 2]);
    grid on;
    ylabel('Magnitude');
    xlabel('Frequency (Hertz)');

    % time domain
%    ax_time=axes('Position',[.15 .66 .8 .26],'XLim',[-1 1],'YLim',[-1 1]);
    ax_time=axes('Position',[.12 .66 .6 .26],'XLim',[-1 1],'YLim',[-1 1]);
    time_line=plot(t,f,'EraseMode','xor');
    % (set to xor mode to prevent re-rendering, that is, for speed)
    axis([-1 1 -1 1]);
    grid on;
    ylabel('Waveform');
    xlabel('Time (Seconds)');
    title('Click and drag waveforms to change frequency and amplitude');

    set(time_line,'ButtonDownFcn','sigdemo2(''down'',1)');
    set(freq_line,'ButtonDownFcn','sigdemo2(''down'',2)');
    drawnow;

    SIGDEMO2_DAT = [freq; amp; min_freq; max_freq; min_amp; max_amp; 0; 0; ...
         time_line; freq_line; freq_field; freq_slider; ax_time; ax_freq ];
     
    watchoff(oldFigNumber);

elseif strcmp(action,'down'),
    % assumes that a line was clicked 

    if (in1==1),
        line_handle = SIGDEMO2_DAT(9);
        ax = SIGDEMO2_DAT(13);
    else   % assume in1 == 2 otherwise (might not be true)
        line_handle = SIGDEMO2_DAT(10);
        ax = SIGDEMO2_DAT(14);
    end;

    if (ax~=gca),
        axes(ax);
        drawnow discard;
    end;

    % Obtain coordinates of mouse click location in axes units
    pt=get(gca,'currentpoint');
    x=pt(1,1);
    y=pt(1,2);

    % find closest point on line to mouse click loc (call it fixed_x, fixed_y)
    line_x=get(line_handle,'XData');
    line_y=get(line_handle,'YData');
    dist=(line_x-x).^2 + (line_y-y).^2;
    [temp,i]=min(dist);
    fixed_x=line_x(i);
    fixed_y=line_y(i);

    set(line_handle,'LineStyle','--');
    drawnow;

    SIGDEMO2_DAT(7)=fixed_x;
    SIGDEMO2_DAT(8)=fixed_y;

    set(gcf,'WindowButtonMotionFcn', sprintf('sigdemo2(''move'',%g)',in1));
    set(gcf,'WindowButtonUpFcn', sprintf('sigdemo2(''up'',%g)',in1));

elseif strcmp(action,'move'),
    freq=SIGDEMO2_DAT(1);
    amp=SIGDEMO2_DAT(2);
    min_freq=SIGDEMO2_DAT(3);
    max_freq=SIGDEMO2_DAT(4);
    min_amp=SIGDEMO2_DAT(5);
    max_amp=SIGDEMO2_DAT(6);
    fixed_x=SIGDEMO2_DAT(7);
    fixed_y=SIGDEMO2_DAT(8);
    time_line=SIGDEMO2_DAT(9);
    freq_line=SIGDEMO2_DAT(10);
    freq_field=SIGDEMO2_DAT(11);
    freq_slider=SIGDEMO2_DAT(12);

    pt=get(gca,'currentpoint');
    x=pt(1,1);
    y=pt(1,2);

    amp1=y/fixed_y*amp;
    if (amp1>max_amp ),
       amp1=max_amp ;
    end;
    if (amp1<min_amp ),
       amp1=min_amp ;
    end;
    if (in1==1),
        freq1=fixed_x/x*freq;
    else
        freq1=x/fixed_x*freq;
    end;
    if (freq1>max_freq),
       freq1=max_freq;
    end;
    if (freq1<min_freq),
       freq1=min_freq;
    end;

    [t,f,w,F]=tffunc(amp1,freq1);
    set(time_line,'YData',f);
    set(freq_line,'YData',F);
    set(freq_field,'String',num2str(freq1));
    set(freq_slider,'Value',freq1);

elseif strcmp(action,'up'),
    freq=SIGDEMO2_DAT(1);
    amp=SIGDEMO2_DAT(2);
    min_freq=SIGDEMO2_DAT(3);
    max_freq=SIGDEMO2_DAT(4);
    min_amp=SIGDEMO2_DAT(5);
    max_amp=SIGDEMO2_DAT(6);
    fixed_x=SIGDEMO2_DAT(7);
    fixed_y=SIGDEMO2_DAT(8);

    pt=get(gca,'currentpoint');
    x=pt(1,1);
    y=pt(1,2);

    amp1=y/fixed_y*amp;
    if (amp1>max_amp ),
       amp1=max_amp ;
    end;
    if (amp1<min_amp ),
       amp1=min_amp ;
    end;
    if (in1==1),
        freq1=fixed_x/x*freq;
    else
        freq1=x/fixed_x*freq;
    end;
    if (freq1>max_freq),
       freq1=max_freq;
    end;
    if (freq1<min_freq),
       freq1=min_freq;
    end;

    set(gcf,'WindowButtonMotionFcn','');
    set(gcf,'WindowButtonUpFcn','');

    set(SIGDEMO2_DAT(9),'linestyle','-');
    set(SIGDEMO2_DAT(10),'linestyle','-');
    SIGDEMO2_DAT(1)=freq1;  % set amplitude and frequency
    SIGDEMO2_DAT(2)=amp1;

    sigdemo2('redraw');

elseif strcmp(action,'redraw'),
    freq=SIGDEMO2_DAT(1);
    amp=SIGDEMO2_DAT(2);

    set(SIGDEMO2_DAT(11),'string',num2str(freq));
    set(SIGDEMO2_DAT(12),'value',freq);

    [t,f,w,F]=tffunc(amp,freq);
    set(SIGDEMO2_DAT(9),'YData',f);
    set(SIGDEMO2_DAT(10),'YData',F);

    drawnow;

elseif strcmp(action,'setfreq'),
    if (in1==1),    % set from slider
        SIGDEMO2_DAT(1)=get(SIGDEMO2_DAT(12),'value');
    else  % set from edit text
        min_freq=SIGDEMO2_DAT(3);
        max_freq=SIGDEMO2_DAT(4);
        freq=str2double(get(SIGDEMO2_DAT(11),'string'));
        if isnan(freq),    % handle non-numeric input into field
            set(SIGDEMO2_DAT(11),'string',num2str(SIGDEMO2_DAT(1)));
        else
            if (freq>max_freq),
                freq=max_freq;
            end;
            if (freq<min_freq),
               freq=min_freq;
            end;
            SIGDEMO2_DAT(1)=freq;
        end
    end

elseif strcmp(action,'info'),
    ttlStr='Modulation Frequency';
 
    hlpStr= ...                                              
        ['You are seeing a representation of a continuous function (the upper plot)  '
         'and its Fourier transform (the lower plot). The function is a Gaussian     '
         'pulse multiplied, or "modulated", by a cosine of a particular frequency.   '
         'This demonstration lets you change the modulation frequency, as well as the'
         'amplitude of the function, and immediately see those changes in both       '
         'domains.                                                                   '    
         '                                                                           '
         'Click and drag a point on the waveform shown in either plot to move that   '
         'point to a new location. This sets a new modulation frequency and          '
         'amplitude.                                                                 '  
         '                                                                           '  
         'The modulation frequency of the waveform is given in the text box beneath  '
         'the plots. This number is updated when you click and drag either waveform. '
         'You can also change the modulation frequency by clicking in the text box,  '  
         'editing the number there, and pressing RETURN or moving the pointer outside'
         'of the box.                                                                '  
         '                                                                           '  
         'The sliding control above the text box monitors changes in the modulation  '
         'frequency. By clicking and dragging the control, you can also set the      '
         'modulation frequency.                                                      '];
 
     helpwin(hlpStr, ttlStr);

elseif strcmp(action,'done'),
    close(gcf);
    clear global SIGDEMO2_DAT

end
