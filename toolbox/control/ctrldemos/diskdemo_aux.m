function slide = diskdemo_aux(slidenum)
%DISKDEMO  Digital servo control of a hard-disk drive.
%
%   This demo shows how to use the Control System Toolbox to design 
%   a digital servo controller for a disk drive read/write head.

%   Author: P. Gahinet 8/2000
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/15 23:07:37 $

% Acknowledgment: The model and data for this demo are taken from Chapter 14
% of "Digital Control of Dynamic Systems," by Franklin, Powell, and Workman.

switch slidenum
    case 1
        % Disk drive picture
        set(gca,'visible','on', ...
            'XTick',[],'YTick',[],'box','on','Ylim',[.1 1.1],'Xlim',[0 1])
        axis square, hold on
        dskwheel(.5,.6,.3);
        dskwheel(0.2109,0.2670,0.05);
        x=[0.2487,0.5563,0.5685,0.2701,0.2518]-0.05;
        y=[0.2853,0.3980,0.3736,0.2457,0.2853];
        fill(x,y,'w');
        plot(0.5,0.5,'k.','MarkerSize',20);
        title('Disk Platen - Read/Write Head');
        
    case 2
        % Model
        cla
        axis normal
        set(gca,'xlim',[0 1],'ylim',[0 1],'vis','off','ydir','normal')
        text(-.05,.9,'Disk Drive Model:','fontweight','bold','fontsize',14);
        text(-.02,.4,'G(s) = G_{r}(s) G_{f}(s)','Hor','left','fontsize',12+2*isunix,'fontweight','b')
        equation('position',[.42 .6],'name','G_r(s)','gain','e^{-1e-5 s}',...
            'num','1e6','den','s(s+12.5)',...
            'Anchor','left','fontsize',10+2*isunix,'color','r');
        equation('position',[.42 .2],'name','G_f(s)','Sigma',1,'SigmaBounds',{'i=1','4'},...
            'num','\omega_j (a_j s + b_j  \omega_j)',...
            'den','s^2 + 2 \zeta_{ j} \omega_j s + \omega_j^2',...
            'Anchor','left','fontsize',10+2*isunix,'color','r');
        
    case 3
        % Model data
        cla
        axis normal
        set(gca,'xlim',[0 1],'ylim',[0 1],'vis','off','ydir','normal')
        text(-.05,.9,'Model Data:','fontweight','bold','fontsize',14);
        text(.05,.6,'(a_1,b_1,\zeta_1,\omega_1) = (.0000115,-.00575,.05,70)','fontsize',10+2*isunix,'color','b');
        text(.05,.4,'(a_2,b_2,\zeta_2,\omega_2) = (0,.0230,.005,2200)','fontsize',10+2*isunix,'color','b');
        text(.05,.2,'(a_3,b_3,\zeta_3,\omega_3) = (0,.8185,.05,4000)','fontsize',10+2*isunix,'color','b');
        text(.05,.0,'(a_4,b_4,\zeta_4,\omega_4) = (.0273,.1642,.005,9000)','fontsize',10+2*isunix,'color','b');
        
    case 4
        h = gcr; set(h.AxesGrid,'Xunits','Hz');
        set(gca,'xlim',[1 1e5]);
        
    case 5
        cla
        set(gca,'xlim',[0 1],'ylim',[0 1],'vis','off','ydir','normal')        
        LocalDrawLoop
        
    case 6
        set(gca,'xlim',[0 1],'ylim',[0 1],'vis','off','ydir','normal')     
        text(-.05,.9,'Design Specs:','fontweight','bold','fontsize',14);
        text(.05,.65,'Open-loop gain > 20dB at 100 Hz','fontsize',10+2*isunix,'color','r');
        text(.05,.5,'Bandwidth > 800 Hz','fontsize',10+2*isunix,'color','r');
        text(.05,.35,'Gain margin > 10 dB','fontsize',10+2*isunix,'color','r');
        text(.05,.2,'Phase margin > 45 deg','fontsize',10+2*isunix,'color','r');
        text(.05,.05,'Peak closed-loop gain < 4 dB','fontsize',10+2*isunix,'color','r');
        
    case 7
        h = gcr; set(h.AxesGrid,'Xunits','Hz');
        set(gca,'xlim',[1 1e5]);
        
    case 8
        h = gcr; set(h.AxesGrid,'Grid','on');
        set(gca,'Xlim',[-1.5 1.5],'Ylim',[-1 1])
        
    case 10
        h = gcr; set(h.AxesGrid,'Grid','on');        
        set(gca,'Xlim',[-1.25 1.25],'Ylim',[-1.2 1.2])

    case 11
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto','Grid','off');
        
    case 12
        h = gcr;
        set(h.AxesGrid,'XUnits','Hz','YUnits',{'dB';'deg'},'Grid','on');
        ax = getaxes(h.AxesGrid);
        set(ax(1),'Xlim',[1e2 1e4],'Ylim',[-40 20]);
        set(ax(2),'Xlim',[1e2 1e4],'Ylim',[-450 360]);
        
    case 13
        h = gcr; set(h.AxesGrid,'XUnits','Hz','Grid','on');
        
    case 14
        h = gcr; set(h.AxesGrid,'XUnits','Hz','Grid','on'); 
        ax = getaxes(h.AxesGrid);
        set(ax(1),'Xlim',[1e2 1e4],'Ylim',[-40 30]);
        set(ax(2),'Xlim',[1e2 1e4],'Ylim',[-450 360]);
      
    case 15
        h = gcr; set(h.AxesGrid,'XUnits','Hz','Grid','on');
        set(gca,'Xlim',[1e2 1e4]);

    case 16
        cla
        set(gca,'xlim',[0 1],'ylim',[0 1],'vis','off','ydir','normal')     
        text(-.05,.9,'Parameter Variations:','fontweight','bold','fontsize',14);
        text(.05,.6,'\omega_2 = 2200 \pm 10%','fontsize',10+2*isunix,'color','r');
        text(.05,.4,'\omega_3 = 4000 \pm 20%','fontsize',10+2*isunix,'color','r');
        text(.05,.2,'\zeta_2 = 0.005 \pm 50%','fontsize',10+2*isunix,'color','r');
        text(.05,.0,'\zeta_3 = 0.05 \pm 50%','fontsize',10+2*isunix,'color','r');
        
    case 17
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto');
        set(h.AxesGrid,'XUnits','Hz','YUnits',{'dB';'deg'},'Grid','on');
        set(gca,'Xlim',[8e2 8e3]);
    end

%---------------------- Local Functions -----------------------------------


function LocalDrawLoop
% Draws control loop
axis equal
ax = gca;
set(ax,'visible','off','xlim',[-1 18],'ylim',[0 12])
y0 = 7;  x0 = 0;
if isunix, 
    fw = 'normal';
else
    fw = 'bold';
end
wire('x',x0+[0 2],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text(x0,y0,'d ','horiz','right','fontweight',fw);
sumblock('position',[x0+2.5,y0],'label','-235','radius',.5,'fontsize',15);
wire('x',x0+[3 7],'y',y0+[0 0],'parent',ax,'arrow',0.5);
sysblock('position',[x0+7 y0-2 4 4],'name','G(s)',...
    'fontweight','bold','facecolor',[1 1 .9],'fontsize',12+2*isunix);
wire('x',x0+[11 16],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text(x0+16,y0,' PES','horiz','left','fontweight',fw);
wire('x',x0+[14 14 13],'y',y0+[0 -6 -6],'parent',ax);
wire('x',x0+[13 13-.707],'y',y0+[-6 -6+.707],'parent',ax);
wire('x',x0+[12 10.5],'y',y0+[-6 -6],'parent',ax,'arrow',0.5);
sysblock('position',[x0+7.5 y0-7.5 3 3],'name','C(z)',...
    'fontweight','bold','facecolor',[.8 1 1],'fontsize',12+2*isunix);
text(x0+12.5,y0-7,'Ts','horiz','center','fontweight',fw);
wire('x',x0+[7.5 6],'y',y0+[-6 -6],'parent',ax,'arrow',0.5);
sysblock('position',[x0+4 y0-7 2 2],'name','ZOH',...
    'fontweight','bold','facecolor',[1 1 .9],'fontsize',8+2*isunix);
wire('x',x0+[4 2.5 2.5],'y',y0+[-6 -6 -0.5],'parent',ax,'arrow',0.5);

text(-2,11.5,'Digital Servo Loop','horiz','left','fontweight','bold','fontsize',14)
