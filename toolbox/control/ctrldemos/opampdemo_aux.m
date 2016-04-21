function slide = opampdemo_aux(slidenum)
%OPAMPDEMO  Feedback Amplifier Demo.
%
%   OPAMPDEMO demonstrates the design of a non-inverting feedback
%   amplifier circuit using the Control System Toolbox.  This design
%   is built around the operational amplifier (op amp), a standard
%   building block of electrical feedback circuits.
%
%   This tutorial demonstrates how a real electrical system can be
%   designed, modeled, and analyzed using the tools provided by the
%   Control System Toolbox.
%
%   Several important topics are covered:
%      - Creating LTI models
%      - Viewing system responses (BODE, STEP, etc.)
%      - Constructing feedback networks (FEEDBACK)
%      - System sensitivity analysis
%      - Stability margin analysis
%      - Compensator design & analysis (feedback lead compensation)
%      - Using LTI arrays

%   Authors: A. DiVergilio
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.1.2.1 $  $Date: 2004/04/19 01:13:36 $

tag = ['SLIDE' num2str(slidenum)];

%---Common layout parameters
p = localParameters;
ax = gca;

%---Slides
switch slidenum
    case 1
        localCanvas(ax)
        delete(findobj(get(gcbf,'Children'),'flat','UserData','DeleteMe'));
        axis(ax,'equal');
        text('Parent',ax,'String','Ideal Op Amp','Position',[.5 .8],...
            'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','middle','Tag',tag);
        opamp('Parent',ax,'Position',[.2 .3 .6 .2],'FaceColor',[1 1 .9],'FontSize',p.fs2,'FontWeight',p.fw2,...
            'Name','a','ShowTerminals',1,'Label',{'Vp','Vn','Vo'},'Info2','Vo = a(Vp - Vn)','Tag',tag);
        
    case 2
        cla
        axis(ax,'normal'); set(ax,'XLim',[0 1],'YLim',[0 1]);
        text('Parent',ax,'Position',[0 0.8],'String','Open-Loop Transfer Function:',...
            'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','left','Ver','bottom','Tag',tag);
        equation('Parent',ax,'Position',[.25 .6],'Name','a(s)','Num','a_{0}','Den','(1 + s/\omega_1)(1 + s/\omega_2)',...
            'Color',[.8 0 0],'Anchor','left','FontSize',p.fs3,'Tag',tag);
        
    case 3
        axis(ax,'normal'); set(ax,'XLim',[0 1],'YLim',[0 1]);
        text('Parent',ax,'Position',[0 0.8],'String','Open-Loop Transfer Function:',...
            'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','left','Ver','bottom','Tag',tag);
        equation('Parent',ax,'Position',[.25 .6],'Name','a(s)','Num','a_{0}','Den','(1 + s/\omega_1)(1 + s/\omega_2)',...
            'Anchor','left','FontSize',p.fs3,'Tag',tag);
        equation('Parent',ax,'Position',[.25 0.30],'Name','a_{0}','Num','10^{5}',...
            'Color',[.8 0 0],'Anchor','left','FontSize',p.fs3,'Tag',tag);
        equation('Parent',ax,'Position',[.25 0.15],'Name','\omega_{1}','Num','10^4',...
            'Color',[.8 0 0],'Anchor','left','FontSize',p.fs3,'Tag',tag);
        equation('Parent',ax,'Position',[.25 0.00],'Name','\omega_{2}','Num','10^6',...
            'Color',[.8 0 0],'Anchor','left','FontSize',p.fs3,'Tag',tag);
        
    case 4
        axis(ax,'normal'); set(ax,'XLim',[0 1],'YLim',[0 1]);
        text('Parent',ax,'Position',[0 0.8],'String','Open-Loop Transfer Function:',...
            'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','left','Ver','bottom','Tag',tag);
        equation('Parent',ax,'Position',[.25 .6],'Name','a(s)','Num','a_{0}','Den','(1 + s/\omega_1)(1 + s/\omega_2)',...
            'Anchor','left','FontSize',p.fs3,'Tag',tag);
        equation('Parent',ax,'Position',[.25 0.30],'Name','a_{0}','Num','10^{5}',...
            'Anchor','left','FontSize',p.fs3,'Tag',tag);
        equation('Parent',ax,'Position',[.25 0.15],'Name','\omega_{1}','Num','10^4',...
            'Anchor','left','FontSize',p.fs3,'Tag',tag);
        equation('Parent',ax,'Position',[.25 0.00],'Name','\omega_{2}','Num','10^6',...
            'Anchor','left','FontSize',p.fs3,'Tag',tag);
        text('Parent',ax,'Position',[0.9 0],'String',{'LTI','Object'},...
            'FontSize',p.fs2,'FontWeight',p.fw2,'Color',[.8 0 0],'Hor','center','Ver','middle','Tag',tag);
        wire('Parent',ax,'XData',[0.58 0.78],'YData',[0.12 0.02],'Color',[.8 0 0],'ArrowSize',p.as*1.5,'Tag',tag);
        wire('Parent',ax,'XData',[0.65 0.8],'YData',[0.3 0.1],'Color',[.8 0 0],'ArrowSize',p.as*1.5,'Tag',tag);
        
    case 5
        reset(ax)
        a = p.a;
        bode(a,'r',p.Frequency1)
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto');
        set(h.AxesGrid,'XUnits','rad/sec','YUnits',{'dB';'deg'},'Grid','off','Xscale','log');
        ax = getaxes(h.AxesGrid);
        set(ax(1),'Ylim',[0 110]);
        set(ax(2),'Ylim',[-180 0]);
        
    case 6
        a = p.a;
        a_norm = p.a_norm;
        step(a_norm,'r',p.Time1)
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto','Grid','off');
        title('Normalized Open-Loop Step Response');
        ylabel('Normalized Amplitude');
        set(gca,'Ylim',[0 1.1]);
        pa = double(getaxes(h.AxesGrid));
        equation('Parent',pa(1),'Position',[1.4e-4 .6],'Num','step(a)','Den','dcgain(a)',...
            'FontSize',p.fs1,'FontWeight',p.fw1,'Color',[0 0 0],'Anchor','left','Tag',tag);
        
    case 7
        localCanvas(ax)
        axis(ax,'equal'); set(ax,'XLim',[0 1.2],'YLim',[0 1.2]);
        x = 0.7;
        y = 0.8;
        opamp('Parent',ax,'Position',[x-.6 y-.1 .6 .2],'FaceColor',[1 1 .9],...
            'FontSize',p.fs2,'FontWeight',p.fw2,'Name','a','Tag',tag);
        resistor('Parent',ax,'Position',[x-.30 y-.35],'Size',.25,'Tag',tag);
        text('Parent',ax,'String','R2','Position',[x-0.30+.2 y-.42],...
            'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','center','Ver','top','Tag',tag);
        resistor('Parent',ax,'Position',[x-.45 y-.40],'Size',.25,'Angle',-90,'Tag',tag);
        text('Parent',ax,'String','R1','Position',[x-0.38 y-.40-.2],...
            'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left','Ver','middle','Tag',tag);
        wire('Parent',ax,'XData',x+[-.75 -.6 NaN -.6 -.6 -.3 NaN -.45 -.45 NaN -.05 .05 .05 NaN 0 .2 NaN -.45 -.45],...
            'YData',y+[.1 .1 NaN -.1 -.35 -.35 NaN -.35 -.40 NaN -.35 -.35 0 NaN 0 0 NaN -.65 -.7],'Tag',tag);
        ground('Parent',ax,'Position',[x-.45 y-.70],'Size',.14,'Tag',tag);
        line('Parent',ax,'LineStyle','--','LineWidth',1,'Clipping','off',...
            'XData',x+[-.55 0 0 -.55 -.55],'YData',y+[-.68 -.68 -.25 -.25 -.68],'Tag',tag);
        text('Parent',ax,'String',' Feedback network, b(s)','Position',[x y-.6],...
            'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','left','Ver','middle','Tag',tag);
        xx = x + [-.75 -.6 .2];
        yy = y + [.1 -.225 0];
        line('Parent',ax,'LineWidth',2,'LineStyle','none','Marker','o','MarkerSize',6,...
            'MarkerFaceColor','w','XData',xx([1 3]),'YData',yy([1 3]),'Tag',tag);
        text('Parent',ax,'String','Vp  ','Position',[xx(1) yy(1)],...
            'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle','Tag',tag);
        text('Parent',ax,'String','Vn ', 'Position',[xx(2) yy(2)],...
            'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle','Tag',tag);
        text('Parent',ax,'String','  Vo','Position',[xx(3) yy(3)],...
            'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left', 'Ver','middle','Tag',tag);
        
    case {8,9}
        cla
        if (slidenum==8)
            axis(ax,'equal'); set(ax,'XLim',[0 1],'YLim',[0 1]);
        end
        y1 = 0.65;
        y2 = 0.15;
        x1 = -0.1;
        x2 = 1.04;
        rw1 = .74;
        rw2 = .4;
        xstart = x1-.2;
        xend = x2+.15;
        sumblock('Parent',ax,'Position',[x1 y1],'Radius',p.sbr,'LabelRadius',3*p.sbr,'Tag',tag);
        sysblock('Parent',ax,'Position',[(x2+x1)/2-rw1/2 y1-.15 rw1 .30],...
            'Name','op amp, a(s)','Numerator','a_{0}','Denominator','(1+s/\omega_{1})(1+s/\omega_{2})',...
            'FaceColor',[1 1 .9],'FontSize',p.fs1,'FontWeight',p.fw1,'Tag',tag);
        sysblock('Parent',ax,'Position',[(x2+x1)/2-rw2/2 y2-.15 rw2 .30],...
            'Name','feedback network, b(s)','Numerator','R1','Denominator','R1 + R2',...
            'FaceColor',[1 1 .9],'FontSize',p.fs1,'FontWeight',p.fw1,'Tag',tag);
        wire('Parent',ax,'XData',[xstart x1-p.sbr],         'YData',[y1 y1],         'ArrowSize',p.as,'Tag',tag);
        wire('Parent',ax,'XData',[x1+p.sbr (x2+x1)/2-rw1/2],'YData',[y1 y1],         'ArrowSize',p.as,'Tag',tag);
        wire('Parent',ax,'XData',[(x2+x1)/2+rw1/2 xend],    'YData',[y1 y1],         'ArrowSize',p.as,'Tag',tag);
        wire('Parent',ax,'XData',[x2 x2 (x2+x1)/2+rw2/2],   'YData',[y1 y2 y2],      'ArrowSize',p.as,'Tag',tag);
        wire('Parent',ax,'XData',[(x2+x1)/2-rw2/2 x1 x1],   'YData',[y2 y2 y1-p.sbr],'ArrowSize',p.as,'Tag',tag);
        text('Parent',ax,'String','Vp ','Position',[xstart y1],...
            'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle','Tag',tag);
        text('Parent',ax,'String','Vn ','Position',[x1 y2],...
            'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle','Tag',tag);
        text('Parent',ax,'String',' Vo','Position',[xend y1],...
            'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left', 'Ver','middle','Tag',tag);
        if (slidenum==9)
            text('Parent',ax,'String',{'Vo/Vp = 10','(dc)'},'Position',[x2+.05 y1+.14],...
                'Color',[.8 0 0],'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','center','Ver','middle','Tag',tag);
            text('Parent',ax,'String',{'R1 = 10000','R2 = 90000'},'Position',[x2-.18 y2-.14],...
                'Color',[.8 0 0],'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','left','Ver','middle','Tag',tag);
        end
        
    case {10,11}
        reset(ax)
        a = p.a;
        A = p.A;
        bode(a,'r',A,'b',p.Frequency1)
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto');
        set(h.AxesGrid,'XUnits','rad/sec','YUnits',{'dB';'deg'},'Grid','off','Xscale','log');
        pa = getaxes(h.AxesGrid);
        set(pa(1),'Ylim',[0 110]);
        set(pa(2),'Ylim',[-180 0]);
        
        if slidenum==10
            text('Parent',pa(1),'Position',[2e5 80],'String','Open-Loop Gain (a)',...
                'Hor','left','Ver','bottom','FontSize',p.fs1,'Tag',tag);
            text('Parent',pa(1),'Position',[2e3 27],'String','Closed-Loop Gain (A)',...
                'Hor','left','Ver','bottom','FontSize',p.fs1,'Tag',tag);
        elseif slidenum==11
            CC = [1 0 1];
            %---Logarithmic arrows:  dd=log2(x2)-log2(x1); x3=pow2(log2(x2)+dd);
            line('Parent',pa(1),'LineWidth',2,'Color',CC,'XData',[2e3 2e3],'YData',[25 95],'Tag',tag);
            patch('Parent',pa(1),'EdgeColor',CC,'FaceColor',CC,'XData',[1.6e3 2e3 2.5e3],'YData',[40 25 40],'Tag',tag);
            line('Parent',pa(1),'LineWidth',2,'Color',CC,'XData',[2e3 1e7],'YData',[10 10],'Tag',tag);
            patch('Parent',pa(1),'EdgeColor',CC,'FaceColor',CC,'XData',[7e6 1e7 7e6],'YData',[2 10 18],'Tag',tag);
            text('Parent',pa(1),'Position',[2e3 82],'String',' Reduced LF gain',...
                'Hor','left','Ver','top','FontSize',p.fs1,'Tag',tag);
            text('Parent',pa(1),'Position',[1.3e5 24],'String','Increased system bandwidth',...
                'Hor','center','Ver','bottom','FontSize',p.fs1,'Tag',tag);
        end
        
    case 12
        localCanvas(ax)
        axis(ax,'normal'); set(ax,'XLim',[0 1],'YLim',[0 1]);
        text('Parent',ax,'Position',[0 0.8],'String','Loop Gain:',...
            'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','left','Ver','bottom','Tag',tag);
        equation('Parent',ax,'Position',[.5 .6],'Name','L(s)','Num','a(s)b(s)',...
            'Anchor','equal','FontSize',p.fs3,'Tag',tag);
        
    case 13
        cla
        text('Parent',ax,'Position',[0 0.8],'String','System Sensitivity:',...
            'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','left','Ver','bottom','Tag',tag);
        equation('Parent',ax,'Position',[.5 0.6],'Name','S','Num','\deltaA/A','Den','\deltaa/a',...
            'Anchor','equal','FontSize',p.fs3,'Tag',tag);
        equation('Parent',ax,'Position',[.5 0.3],'Name',' ','Num','1','Den','1 + a(s)b(s)',...
            'Anchor','equal','FontSize',p.fs3,'Tag',tag);
        equation('Parent',ax,'Position',[.5 0.0],'Name',' ','Num','1','Den','1 + L(s)',...
            'Anchor','equal','FontSize',p.fs3,'Tag',tag);
        
    case 14
        reset(ax)
        A = p.A;
        S = p.S;
        bodemag(A,'b',S,'g',p.Frequency1)
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto');
        set(h.AxesGrid,'XUnits','rad/sec','YUnits',{'dB';'deg'},'Grid','off','Xscale','log');
        pa = getaxes(h.AxesGrid);
        set(pa(1),'Ylim',[-90 50]);
        
        text('Parent',pa(1),'Position',[3e4 15],'String',{'Closed-Loop Gain','(A)'},...
            'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','center','Ver','top','Tag',tag);
        text('Parent',pa(1),'Position',[2e6 -45],'String',{'System','Sensitivity','(S)'},...
            'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','center','Ver','top','Tag',tag);
        
    case 15
        A = p.A;
        step(A,'b',p.Time2)
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto','grid','off');
        title('Closed-Loop Step Response');
        pa = getaxes(h.AxesGrid);
        text('Parent',pa(1),'Position',[2.4e-6 15],'String','Excessive ringing  \rightarrow  poor phase margin',...
            'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','left','Ver','middle','Tag',tag);
        
    case 16
        L = p.L;
        margin(L)
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto');
        set(h.AxesGrid,'XUnits','rad/sec','YUnits',{'dB';'deg'},'Grid','off','Xscale','log');
        pa = getaxes(h.AxesGrid);
        set(pa(1),'Ylim',[-10 90]);
        set(pa(2),'Ylim',[-180 0]);
        
        text('Parent',pa(1),'Position',[6e5 50],'String','Loop Gain (L)',...
            'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','left','Ver','bottom','Tag',tag);
        
    case 17
        localCanvas(ax)
        axis(ax,'equal'); set(ax,'XLim',[0 1.2],'YLim',[0 1.2]);
        x = 0.8;
        y = 0.8+.08;
        dd = 0.2;
        text('Parent',ax,'Position',[x-1.1 y-.3],'String',{'Feedback','Lead','Compensation'},...
            'FontSize',p.fs2,'FontWeight',p.fw2,'Color',[.8 0 0],'Hor','center','Ver','middle','Tag',tag);
        opamp('Parent',ax,'Position',[x-.6 y-.1 .6 .2],'FaceColor',[1 1 .9],...
            'FontSize',p.fs2,'FontWeight',p.fw2,'Name','a','Tag',tag);
        capacitor('Parent',ax,'Position',[x-.30 y-.35+.02],'Size',.25,'Color',[.8 0 0],'Tag',tag);
        text('Parent',ax,'String','C','Position',[x-0.30+.2 y-.42+.02],...
            'FontSize',p.fs2,'FontWeight',p.fw2,'Color',[.8 0 0],'Hor','center','Ver','top','Tag',tag);
        resistor('Parent',ax,'Position',[x-.30 y-.35-dd],'Size',.25,'Tag',tag);
        text('Parent',ax,'String','R2','Position',[x-0.30+.2 y-.42-dd],...
            'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','center','Ver','top','Tag',tag);
        resistor('Parent',ax,'Position',[x-.45 y-.40-dd],'Size',.25,'Angle',-90,'Tag',tag);
        text('Parent',ax,'String','R1','Position',[x-0.38 y-.40-.2-dd],...
            'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left','Ver','middle','Tag',tag);
        wire('Parent',ax,'XData',x+[-.75 -.6 NaN -.6 -.6 -.3 NaN -.45 -.45 NaN -.05 .05+.05 .05+.05 NaN 0 .2+.05 NaN -.45 -.45],...
            'YData',y+[.1 .1 NaN -.1 -.35-dd -.35-dd NaN -.35-dd -.40-dd NaN -.35-dd -.35-dd 0 NaN 0 0 NaN -.65-dd -.7-dd],'Tag',tag);
        wire('Parent',ax,'Color',[.8 0 0],'XData',x+[-.35 -.35 -.3 NaN -.05 0 0],...
            'YData',y+[-.35-dd -.35+.02 -.35+.02 NaN -.35+.02 -.35+.02 -.35-dd],'Tag',tag);
        ground('Parent',ax,'Position',[x-.45 y-.70-dd],'Size',.14,'Tag',tag);
        line('Parent',ax,'LineStyle','--','LineWidth',1,...
            'XData',x+[-.55 0.05 0.05 -.55 -.55],'YData',y+[-.68-dd -.68-dd -.25 -.25 -.68-dd],'Tag',tag);
        text('Parent',ax,'String',' Feedback network, b(s)','Position',[x+.05 y-.6-dd],...
            'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','left','Ver','middle','Tag',tag);
        xx = x + [-.75 -.6 .2+.05];
        yy = y + [.1 -.225-dd 0];
        line('Parent',ax,'LineWidth',2,'LineStyle','none','Marker','o',...
            'MarkerSize',6,'MarkerFaceColor','w','XData',xx([1 3]),'YData',yy([1 3]),'Tag',tag);
        text('Parent',ax,'String','Vp  ','Position',[xx(1) yy(1)],...
            'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle','Tag',tag);
        text('Parent',ax,'String','Vn ', 'Position',[xx(2) yy(2)],...
            'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle','Tag',tag);
        text('Parent',ax,'String','  Vo','Position',[xx(3) yy(3)],...
            'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left', 'Ver','middle','Tag',tag);
        
    case 18
        cla
        axis(ax,'equal'); set(ax,'XLim',[0 1],'YLim',[0 1]);
        y1 = 0.65;
        y2 = 0.15;
        x1 = -0.1;
        x2 = 1.04;
        rw1 = .74;
        rw2 = .56;
        xstart = x1-.2;
        xend = x2+.15;
        sumblock('Parent',ax,'Position',[x1 y1],'Radius',p.sbr,'LabelRadius',3*p.sbr,'Tag',tag);
        sysblock('Parent',ax,'Position',[(x2+x1)/2-rw1/2 y1-.15 rw1 .30],...
            'Name','op amp, a(s)','Numerator','a_{0}','Denominator','(1+s/\omega_{1})(1+s/\omega_{2})',...
            'FaceColor',[1 1 .9],'FontSize',p.fs1,'FontWeight',p.fw1,'Tag',tag);
        sysblock('Parent',ax,'Position',[(x2+x1)/2-rw2/2 y2-.15 rw2 .30],...
            'Name',{'feedback network,','b(s)'},'Gain','K ','Numerator','1 + \tau_{z} s','Denominator','1 + \tau_{p} s',...
            'FaceColor',[1 1 .9],'FontSize',p.fs1,'FontWeight',p.fw1,'Tag',tag);
        wire('Parent',ax,'XData',[xstart x1-p.sbr],         'YData',[y1 y1],         'ArrowSize',p.as,'Tag',tag);
        wire('Parent',ax,'XData',[x1+p.sbr (x2+x1)/2-rw1/2],'YData',[y1 y1],         'ArrowSize',p.as,'Tag',tag);
        wire('Parent',ax,'XData',[(x2+x1)/2+rw1/2 xend],    'YData',[y1 y1],         'ArrowSize',p.as,'Tag',tag);
        wire('Parent',ax,'XData',[x2 x2 (x2+x1)/2+rw2/2],   'YData',[y1 y2 y2],      'ArrowSize',p.as,'Tag',tag);
        wire('Parent',ax,'XData',[(x2+x1)/2-rw2/2 x1 x1],   'YData',[y2 y2 y1-p.sbr],'ArrowSize',p.as,'Tag',tag);
        text('Parent',ax,'String','Vp ','Position',[xstart y1],...
            'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle','Tag',tag);
        text('Parent',ax,'String','Vn ','Position',[x1 y2],...
            'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle','Tag',tag);
        text('Parent',ax,'String',' Vo','Position',[xend y1],...
            'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left', 'Ver','middle','Tag',tag);
        text('Parent',ax,'String',{'K_{ } = R1 / (R1 + R2)','\tau_{z} = R2 \cdot C','\tau_{p} = K \cdot \tau_{z}'},...
            'Position',[x2-.2 y2-.19],'Color',[.8 0 0],'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','left','Ver','middle','Tag',tag);
        
    case 19
        cla
        x1 = .3;
        y1 = 0;
        dx = .03;
        dy = .03;
        w = .6;
        h = .6;
        text('Parent',ax,'Position',[x1-2.5*dx+w/2 0.8],'String','LTI Model Array:  b\_array(s)',...
            'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','bottom','Tag',tag);
        sysblock('Parent',ax,'Position',[x1-4*dx y1+4*dy w h],'FaceColor',[1 1 .9],'Tag',tag);
        sysblock('Parent',ax,'Position',[x1-3*dx y1+3*dy w h],'FaceColor',[1 1 .9],'Tag',tag);
        sysblock('Parent',ax,'Position',[x1-2*dx y1+2*dy w h],'FaceColor',[1 1 .9],'Tag',tag);
        sysblock('Parent',ax,'Position',[x1-1*dx y1+1*dy w h],'FaceColor',[1 1 .9],'Tag',tag);
        sysblock('Parent',ax,'Position',[x1-0*dx y1+0*dy w h],'FaceColor',[1 1 .9],'Tag',tag,...
            'Name','(n x 1 array)','Num','b\_array(:,:,n)','FontSize',p.fs1,'FontWeight',p.fw1);
        
    case 20
        reset(ax)
        A = p.A;
        A_array = p.A_array;
        step(A,'b:',A_array,'b',p.Time3)
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto','grid','off');
        title('Closed-Loop Step Response (Compensated)');
        set(gca,'Ylim',[0 14]);
        pa = double(getaxes(h.AxesGrid));
        
        CC = [1 0 1];
        ln = line('Parent',pa(1),'LineStyle','-','Color',CC,'XData',[.25e-6 .32e-6],'YData',[12 5],'Tag',tag);
        patch('Parent',pa(1),'EdgeColor',CC,'FaceColor',CC,'XData',[.32e-6 .29e-6 .34e-6],'YData',[5 5.6 5.8],'Tag',tag);
        text('Parent',pa(1),'Position',[.32e-6 4.9], 'String','   Increasing C',...
            'Color',CC,'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','center','Ver','top','Tag',tag);
        text('Parent',pa(1),'Position',[.20e-6 13.2],'String','0 pF',...
            'Color',CC,'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','right','Ver','middle','Tag',tag);
        text('Parent',pa(1),'Position',[.34e-6 12],  'String','1 pF',...
            'Color',CC,'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','center','Ver','bottom','Tag',tag);
        text('Parent',pa(1),'Position',[.38e-6 7.8], 'String','3 pF',...
            'Color',CC,'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','left','Ver','top','Tag',tag);
        
    case 21
        localCanvas(ax)
        reset(ax)
        set(ax,'XLim',[0.8 3.6],'YLim',[45 60],'Box','on','FontSize',p.fs1)
        set(get(ax,'XLabel'),'String','Compensation Capacitor, C (pF)','FontSize',p.fs1);
        set(get(ax,'YLabel'),'String','Phase Margin (deg)','FontSize',p.fs1);
        ln = line('Parent',ax,'LineStyle','-','Color',[0 .65 0],'XData',p.C*1e12,'YData',p.Pm);
        text('Parent',ax,'Position',[2.2 58],'String','\leftarrow Peak Phase Margin @ C = 2pF',...
            'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','left','Ver','middle','Tag',tag);
        
    case 22
        A = p.A;
        A_comp = p.A_comp;
        step(A,'b:',A_comp,'b',p.Time2)
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto','grid','off');
        title('Closed-Loop Step Response');
        pa = double(getaxes(h.AxesGrid));
        
        text('Parent',pa(1),'Position',[2.5e-6 15],'String',' Uncompensated response (0 pF)',...
            'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','left','Ver','middle','Tag',tag);
        line('Parent',pa(1),'XData',[2.5e-6 1.75e-6],'YData',[15 13.6],'Tag',tag);
        text('Parent',pa(1),'Position',[2.5e-6 5],'String',' Compensated response (2 pF)',...
            'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','left','Ver','middle','Tag',tag);
        line('Parent',pa(1),'XData',[2.5e-6 3.5e-7],'YData',[5 8.25],'Tag',tag);
        
    case 23
        a = p.a;
        A = p.A;
        A_comp = p.A_comp;
        bode(a,'r',A,'b:',A_comp,'b',p.Frequency1)
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto');
        set(h.AxesGrid,'XUnits','rad/sec','YUnits',{'dB';'deg'},'Grid','off','Xscale','log');
        pa = getaxes(h.AxesGrid);
        set(pa(1),'Ylim',[0 110]);
        set(pa(2),'Ylim',[-180 0]);
        
        text('Parent',pa(2),'Position',[1.30e4 -35],'String','a(s)',...
            'Hor','left','Ver','middle','FontSize',p.fs1,'Tag',tag);
        text('Parent',pa(2),'Position',[1.15e7 -35],'String','A(s)',...
            'Hor','left','Ver','middle','FontSize',p.fs1,'Tag',tag);
        text('Parent',pa(2),'Position',[1.70e6 -35],'String','A_comp(s)',...
            'Interp','none','Hor','right','Ver','middle','FontSize',p.fs1,'Tag',tag);
        
    case 24
        localCanvas(ax)
        axis(ax,'normal'); set(ax,'XLim',[0 1],'YLim',[0 1]);
        text('Parent',ax,'Position',[0 0.8],'String','Final Component Values:',...
            'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','left','Ver','bottom','Tag',tag);
        equation('Parent',ax,'Position',[.25 0.60],'Name','R1','Num','10 kOhm',...
            'Anchor','equal','FontSize',p.fs3,'Tag',tag);
        equation('Parent',ax,'Position',[.25 0.45],'Name','R2','Num','90 kOhm',...
            'Anchor','equal','FontSize',p.fs3,'Tag',tag);
        equation('Parent',ax,'Position',[.25 0.30],'Name','C', 'Num','2 pF',...
            'Anchor','equal','FontSize',p.fs3,'Tag',tag);      
end

%%%%%%%%%%%%%%%
% localCanvas %
%%%%%%%%%%%%%%%
function localCanvas(ax)
%---Reset axes properties for use as a drawing canvas
delete(findobj(allchild(ax),'flat','Serializable','on'));
reset(ax);
set(ax,'Visible','off','XLim',[0 1],'YLim',[0 1],...
    'DefaultLineClipping','off','DefaultTextClipping','off','DefaultPatchClipping','off');

%%%%%%%%%%%%%%%%%%%
% localParameters %
%%%%%%%%%%%%%%%%%%%
function p_out = localParameters
%---Parameters/systems used in demo
persistent p;
if isempty(p)
    if ispc
        p.fs1 = 8;
        p.fs2 = 10;
        p.fs3 = 12;
    else
        p.fs1 = 10;
        p.fs2 = 12;
        p.fs3 = 14;
    end
    p.fw1 = 'normal';
    p.fw2 = 'bold';
    p.fw3 = 'bold';
    p.as = .05;  %---Arrow size
    p.sbr = .04; %---Sumblock radius
    p.s = tf('s');
    p.a0 = 1e5;
    p.w1 = 1e4;
    p.w2 = 1e6;
    p.R1 = 10e3;
    p.R2 = 90e3;
    p.Frequency1 = logspace(3,8,256);
    p.Time1 = [0:.01:1]*6e-4;
    p.Time2 = [0:.005:1]*1.0e-5;
    p.Time3 = [0:.005:1]*1.5e-6;
    p.a = p.a0/(1+p.s/p.w1)/(1+p.s/p.w2);
    p.a_norm = p.a/dcgain(p.a);
    p.b = p.R1/(p.R1+p.R2);
    p.A = feedback(p.a,p.b);
    p.L = p.a*p.b;
    p.S = feedback(1,p.L);
    p.K = p.R1/(p.R1+p.R2);
    p.C = [1:.2:3]*1e-12;
    for n = 1:length(p.C)
        b_array(:,:,n) = tf([p.K*p.R2*p.C(n) p.K],[p.K*p.R2*p.C(n) 1]);
    end
    p.b_array = b_array;
    p.A_array = feedback(p.a,p.b_array);
    p.L_array = p.a*p.b_array;
    [p.Gm,p.Pm,p.Wcg,p.Wcp] = margin(p.L_array);
    p.A_comp = p.A_array(:,:,6);
end
p_out = p;
