function slide = margindemo_sls(slidenum)
%MARGINDEMO_SLS  Slide show for INFO button in margin demo.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/10 06:41:20 $

persistent H

if nargin
    %---Slide code
    switch slidenum
    case 1
        set(gca,'Position',[0.085 0.49 0.65 0.45])
        DrawLoop;
        set(findobj(allchild(gcf),'flat','type','uicontrol','string','Info'),...
            'visible','off')
    case 2
        cla, axis normal
        H = tf([.2  .3  1],[1 .2  1 0]);
        rlocus(H);
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto','Grid','off');
        set(h,'FrequencyUnits','rad/sec');
        set(gca,'Xlim',[-1 0.3],'Ylim',[-3 3]);
    case 3
        cla, axis normal
        H1 = 0.1*H;  H2 = H;   H3 = 30*H;
        bode(H1,H2,H3);
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto');
        set(h.AxesGrid,'XUnits','rad/sec','YUnits',{'dB';'deg'},'Grid','off','Xscale','log');
        title('Stability Margins for K = 0.1, 1, 30');

    end
    
    
elseif nargout<1
    %---Start demo
    fg = playshow(mfilename);
    set(fg,'Name','Details on the Stability Margin Demo');
    
    
else
    %---Construct slides
    slidenum = 0;
    
    %========== Slide 1 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' This demo illustrates the concept of stability margins and its '
        ' relation with the closed-loop time response characteristics.'
        ' '
        ' The SISO feedback loop under consideration is shown above.'
        ' Use the "Loop Gain" slider to modify the gain K and see how '
        ' this affects the stability margins and closed-loop responses. '
        ' '
        ' Notice how smaller margins result in more overshoot and '
        ' oscillations in the closed-loop step response.'
    };
    
    %========== Slide 2 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' The closed loop is stable for small values of the gain K, then '
        ' becomes unstable, and regains stability for large values of K.'
        ' This behavior is best explained by looking at the root locus:'
        ' '
        ' >> H = tf([.2  .3  1],[1 .2  1 0])'
        ' >> rlocus(H)'
        ' '
        ' The root locus traces the closed-loop pole trajectories as K varies.'
        ' Click on the locus curve and move the black square to trace the gain'
        ' values.'
    };
    
    %========== Slide 3 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Using the right-click menus of the Bode Response Plot, you'
        ' can plot and compare the stability margins for the three gain values'
        ' '
        '     K = 0.1, 1, 30'
        ' '
        ' Richt-click on ''Characteristics -> Stability (Minimum Crossing)'' to see the'
        ' margins, then hold the mouse over the dots to read off the margin values.'
        ' Note that the gain margin is positive for H1 (K=0.1) and negative for'
        ' H3 (K=30). Stability is lost by increasing the gain in the first'
        ' case, and decreasing the gain in the second case.'
    };
    
    
end

%%%%%%%%%%%%%%%%%

function DrawLoop
% Draws feedback loop with plant data
cla, axis equal
ax = gca;
set(ax,'visible','off','xlim',[-4 21],'ylim',[0 10])
y0 = 7;  x0 = 0;
wire('x',x0+[-3 -1],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text(x0-3,y0,'r  ','horiz','right','fontweight','bold');
sumblock('position',[x0-0.5,y0],'label',{'+140','-240'},'radius',.5,...
    'LabelRadius',1.5,'fontsize',15);
wire('x',x0+[0 2],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text(x0+1,y0+1,'e','horiz','center','fontweight','bold');
sysblock('position',[x0+2 y0-1.5 3 3],'name','K',...
    'fontweight','bold','facecolor',[.8 1 1]);
wire('x',x0+[5 7.5],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text(x0+6,y0+1,'u','horiz','left','fontweight','bold');
sysblock('position',[x0+7.5 y0-2.5 9 5],'name','Plant',...
    'num','0.2 s^2 + 0.3 s + 1','den','s^3 + 0.2 s^2 + s',...
    'fontweight','bold','facecolor',[1 1 .9],'fontsize',10);
wire('x',x0+[16.5 20],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text(x0+20,y0,'  y','horiz','left','fontweight','bold');
wire('x',x0+[18 18 -0.5 -0.5],'y',y0+[0 -6 -6 -0.5],'parent',ax,'arrow',0.5);
text(x0+9,-1,'SISO Feedback Loop','hor','center','fontweight','bold','fontsize',12);
