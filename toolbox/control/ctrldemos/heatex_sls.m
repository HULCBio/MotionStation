function slide = heatex_sls(slidenum)
%HEATEX_SLS  Slide show for DETAILS button in heat exchanger demo

%   Authors: N. Hickey
%   Revised: A. DiVergilio, E. Yarrow
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/10 06:41:15 $

if nargin
    cla;
    axis(gca,'normal');
    set(gca,'Position',[0.085 0.49 0.65 0.45],'xlim',[0 1],'ylim',[0 1])
    switch slidenum
    case 1
        localDrawLoop(1);
        set(findobj(allchild(gcf),'flat','Type','uicontrol','String','Info'),'Visible','off')
    case 2
        localDrawLoop(2);
    case 3
        localPlotStepData(0);
    case 4
        localPlotStepData(1);
    case 5
        localDrawLoop(8);
    case 6
        localPlotResponses('Margins');
    case 7
        localDrawLoop(3);
    case 8
        localDrawLoop(5);
    case 9
        localDrawLoop(6);
    case 10
        localDrawLoop(4);
    case 11
        localDrawLoop(7);
    case 12
        localPlotResponses('ClosedLoopRegulator');
    case 13
        localPlotResponses('ClosedLoopServoRegulator');
    end
    
elseif nargout<1
    %---Start demo
    fg = playshow(mfilename);
    set(fg,'Name','Details on the Heat Exchanger Demo','DoubleBuffer','on');
    
else
    %---Construct slides
    slidenum = 0;
    %========== Slide 1 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' This demo illustrates the design of feedback and feedforward controllers'
        ' to control the temperature of a chemical reactor using a heat exchanger.'
        ' '
        ' The control system under consideration is shown above. The control'
        ' objective is to maintain the temperature of the reactor at a constant'
        ' setpoint by varying the amount of steam supplied to the heat exchanger'
        ' via the control valve. This must be done while the reactor is subject'
        ' to step changes in the temperature of the liquid inlet flow.'
        };
    %========== Slide 2 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Your first step is to design a PI FeedBack (FB) controller.'
        ' '
        ' The parameters of the controller are obtained from analyzing the time'
        ' domain data acquired from a step test on the plant. This test involves'
        ' injecting a step disturbance into the plant input and then measuring the'
        ' plant response over time.'
        };
    %========== Slide 3 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' The plot above shows the increase in plant temperature due to a step '
        ' increase in the inlet flow temperature. The values t1 and t2 are found'
        ' where the response attains 28.3% and 63.2% of its final value. You can use'
        ' t1 and t2 to approximate the time constant tau, and dead time theta,'
        ' of the plant:'
        ' '
        ' >> t1 = 21.8, t2 = 36.0'
        ' >> tau = 3/2 * ( t2 - t1 )'
        ' >> theta = t2 - tau'
        };
    %========== Slide 4 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' You can now use tau and theta to create a first-order plus dead time,'
        ' model, of the heat exchanger, Gp:'
        ' '
        ' >> Gp = tf( 1, [tau 1], ''InputDelay'', theta )'
        ' '
        ' You can use the STEP command to compare this model with the measured'
        ' data:'
        ' '
        ' >> step( Gp )'
        };
    %========== Slide 5 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' You use the relationships above to obtain the parameters for the'
        ' PI controller, Gc:'
        ' '
        ' >> Kc = 0.859 * (theta / tau)^-0.977'
        ' >> tauc = ( tau / 0.674 ) * ( theta / tau )^0.680'
        ' >> Gc  = Kc * tf( [ tauc  1 ], [ tauc  0 ] )'
        };
    %========== Slide 6 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' You can examine the stability of your design by plotting its open-loop'
        ' frequency response with the MARGIN command:'
        ' '
        ' >> margin( Gc * Gp )'
        ' '
        ' The plot above indicates acceptable gain and phase margins.  Note that'
        ' the design has high gain at low frequencies which provides good setpoint'
        ' control. In addition, the lower gain at high frequencies will suppress'
        ' high frequency noise in the system.'
        };
    %========== Slide 7 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' The next step is to design the Feedforward controller Gff for your system. '
        ' A first-order plus dead time is used as disturbance model:'
        ' '
        '    Gd = exp( -35s ) / ( 25s  +  1 )' 
        ' '  
        ' which you can specify as'
        ' '
        ' >> Gd = tf( 1, [ 25  1 ], ''InputDelay'', 35 )'
    };
    %========== Slide 8 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' The Feedforward controller Gff is calculated to cancel the effects of input '
        ' disturbances on the plant output. '
         ' '
        };
    %========== Slide 9 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' The controller gain ( Kff ) and time delay ( thetaff ) are not known exactly,'
        ' and it is therefore necessary to make them tunable parameters. To avoid an'
        ' exact cancellation, the calculated value of thetaff is increased by 5 seconds.'
        ' '
        ' >> Kff = 1'
        ' >> thetaff = 25.3'
        ' >> Gff = - Kff * tf( [ 21.3  1], [ 25  1], ''InputDelay'', thetaff )'
        
        };
    %========== Slide 10 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Now that you have designed both the Feedback and Feedforward'
        ' controllers, the next stage is to analyze the response of the'
        ' complete system.'
        ' '
        };
    %========== Slide 11 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' In order to analyze closed-loop systems containing delays, you will need to'
        ' use the frequency response data (FRD) model type. You can construct the'
        ' closed-loop system with:'
        ' '
        ' >> w = logspace( -2, 1, 100 )'
        ' >> Gp = frd( Gp, w )'
        ' >> Gol = Gc * Gp'
        ' >> Gcl = [  Gd + Gp * Gff  ,  Gol ] / ( 1 + Gol )'
    };
    %========== Slide 12 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' You can examine the closed-loop frequency response of the Feedforward' 
        ' system (regulator control) using the BODE command:'
        ' '
        ' >> bode( Gcl ( 1 ) )'
        ' '
        ' Your design attenuates low-frequency signals, thereby reducing'
        ' sensitivity to input disturbances.'
        ' '
        ' Note how the phase response rolls off sharply due to the dead time.'
        };
    %========== Slide 13 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' You can examine the closed-loop frequency response of the Feedback'
        ' system (setpoint control) using the BODE command:'
        ' '
        ' >> bode( Gcl ( 2 ) )'
        ' '
        ' The low-frequency response of your design, is close to unity, with an acceptable'
        ' 3dB peak at 0.1 rad/sec.  The bandwidth is large enough to reject the'
        ' low frequency output disturbances.'
        ' '
        ' You have successfully completed a heat-exchanger design.'
        };    
end


%%%%%%%%%%%%%%%%%%%%%%
% localPlotResponses %
%%%%%%%%%%%%%%%%%%%%%%
function localPlotResponses(response)
% Plot the desired responses

% slide 3
t1 = 21.8; t2 = 36;
tau = 3/2*(t2 - t1);
theta = t2 - tau;

% slide 4
Gp = tf(1,[tau 1],'InputDelay',theta);

% slide 5
Kc = 0.859 * (theta / tau)^-0.977;
tauc = ( tau / 0.674 ) * ( theta / tau )^0.680;
Gc = Kc*tf([tauc 1],[tauc 0]);

% slide 7
Gd = tf(1,[25 1],'InputDelay',35);

% slide 9
Kff = 1.0;
thetaff = 25.3;
Gff = -Kff*tf([21.3 1],[25 1],'InputDelay',thetaff);

% slide 11s
w = logspace(-2,1,100);
Gp = frd(Gp,w);
Gol = Gc*Gp;
Gcl = [Gd + Gp*Gff, Gol]/(1 + Gol);

switch response
case 'Step'
    % used in slide 4
    step(tf(1,[tau 1],'InputDelay',theta),'b',[0:1:200]);
    h = gcr;
    set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto');
case 'Margins'
    % used in slide 5
    margin(Gc*Gp);
    h = gcr;
    set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto');
    set(h.AxesGrid,'XUnits','rad/sec','YUnits',{'dB';'deg'},'Grid','on');
    ax = getaxes(h.AxesGrid);
    set(ax(1),'Xlim',[0.01 1],'Ylim',[-30 30]);
    set(ax(2),'Xlim',[0.01 1],'Ylim',[-360 45]);
case 'ClosedLoopRegulator'
    bode(Gcl(1));
    h = gcr;
    set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto');
    set(h.AxesGrid,'XUnits','rad/sec','YUnits',{'dB';'deg'},'Grid','on');
    ax = getaxes(h.AxesGrid);
    set(ax(1),'Xlim',[0.01 1],'Ylim',[-60 10]);
    set(ax(2),'Xlim',[0.01 1],'Ylim',[-540 180]);
case 'ClosedLoopServoRegulator'
    bode(Gcl(2));
    h = gcr;
    set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto');
    set(h.AxesGrid,'XUnits','rad/sec','YUnits',{'dB';'deg'},'Grid','on');
    ax = getaxes(h.AxesGrid);
    set(ax(1),'Xlim',[0.01 1],'Ylim',[-30 10]);
    set(ax(2),'Xlim',[0.01 1],'Ylim',[-540 90]);

end

    
%%%%%%%%%%%%%%%%%
% localDrawLoop %
%%%%%%%%%%%%%%%%%
function localDrawLoop(n)
% Draws feedback loop with plant data
cla, axis equal
ax = gca;
set(ax,'visible','off','xlim',[-5 20],'ylim',[1 16])
y0 = 6;  x0 = -1.5;
yt = y0+8;
yb = y0-4;
tx = x0+9;
ty = 0;
fs = 12+2*isunix;

switch n
case {1,2,3,4}
    %---The plant
    sysblock('position',[x0+12 y0-1.5 3 3],'Num','Gp','Name','Plant Model','facecolor','y','fontsize',10);
    wire('x',x0+[15 17.5],'y',[y0 y0],'parent',ax,'arrow',0.5);
    sumblock('position',[x0+18 y0],'label',{'+140','+40'},'radius',.5,'LabelRadius',1.5,'fontsize',15);
    wire('x',x0+[18.5 21],'y',[y0 y0],'parent',ax,'arrow',0.5);
    text(x0+21,y0,'  y','horiz','left');
    %---The disturbance block
    wire('x',x0+[-3 12],'y',[yt yt],'parent',ax,'arrow',0.5);
    sysblock('position',[x0+12 yt-1.5 3 3],'Num','Gd','Name','Disturbance Model','facecolor','y','fontsize',10);
    wire('x',x0+[15 18 18],'y',[yt yt y0+.5],'parent',ax,'arrow',.5);
    text(x0-3,yt,'d  ','horiz','right');
    text(x0-3.8,yt-1,{'disturbance';'input'},'Hor','center','Ver','top');
    switch n
    case 1  % Open Loop
        %---The input
        text(x0-3,y0,'r  ','horiz','right');
        text(x0-3.8,y0-1,'setpoint','Hor','center','Ver','top');
        wire('x',x0+[-3 12],'y',[y0 y0],'parent',ax,'arrow',0.5);
        text(tx,ty,'Open Loop System','fontsize',12,'fontweight','bold','Hor','center');
    case 2  % Feedback
        %---The input
        text(x0-3,y0,'r  ','horiz','right');
        text(x0-3.8,y0-1,'setpoint','Hor','center','Ver','top');
        wire('x',x0+[-3 -1],'y',[y0 y0],'parent',ax,'arrow',0.5);
        sumblock('position',[x0-0.5 y0],'label',{'+140','-240'},'radius',.5,'LabelRadius',1.5,'fontsize',15);
        wire('x',x0+[0 2],'y',[y0 y0],'parent',ax,'arrow',0.5);
        text(x0+1,y0+1,'e','horiz','center');
        sysblock('position',[x0+2 y0-1.5 3 3],'Num','Gc','Name','PI Controller','fontsize',10,'facecolor','c');
        wire('x',x0+[5 12],'y',[y0 y0],'parent',ax,'arrow',0.5);
        text(x0+6,y0+1,'u','horiz','left');
        wire('x',x0+[19.75 19.75 -0.5 -0.5],'y',[y0 yb yb y0-0.5],'parent',ax,'arrow',0.5);
        text(tx,ty,'Feedback Control Loop','fontsize',12,'fontweight','bold','Hor','center');
    case 3  % Feedforward
        sysblock('position',[x0+2 yt-4.2 3 3],'num','Gff','Name','FF Controller','fontsize',10,'facecolor','c');
        wire('x',x0+[0 0 2],'y',[yt yt-2.7 yt-2.7],'parent',ax,'arrow',0.5);
        wire('x',x0+[5 7 7 12],'y',[yt-2.7 yt-2.7 y0 y0],'parent',ax,'arrow',0.5);
        text(tx,ty,'Feedforward Control Loop','fontsize',12,'fontweight','bold','Hor','center');
    case 4  % Feedback & Feedforward
        %---The input
        text(x0-3,y0,'r  ','horiz','right');
        text(x0-3.8,y0-1,'setpoint','Hor','center','Ver','top');
        %---Feedback
        wire('x',x0+[-3 -1],'y',[y0 y0],'parent',ax,'arrow',0.5);
        sumblock('position',[x0-0.5 y0],'label',{'+140','-240'},'radius',.5,'LabelRadius',1.5,'fontsize',15);
        wire('x',x0+[0 2],'y',[y0 y0],'parent',ax,'arrow',0.5);
        text(x0+1,y0+1,'e','horiz','center');
        sysblock('position',[x0+2 y0-1.5 3 3],'Num','Gc','Name','PI Controller','fontsize',10,'facecolor','c');
        wire('x',x0+[5 6.5],'y',[y0 y0],'parent',ax,'arrow',0.5);
        wire('x',x0+[7.5 12],'y',[y0 y0],'parent',ax,'arrow',0.5);
        text(x0+10.25,y0+1,'u','horiz','center');
        wire('x',x0+[19.75 19.75 -0.5 -0.5],'y',[y0 yb yb y0-0.5],'parent',ax,'arrow',0.5);
        sumblock('position',[x0+7 y0],'label',{'+140','-40'},'radius',.5,'LabelRadius',1.5,'fontsize',15);
        %---Feedforward
        sysblock('position',[x0+2 yt-4.2 3 3],'num','Gff','Name','FF Controller','fontsize',10,'facecolor','c');
        wire('x',x0+[0 0 2],'y',[yt yt-2.7 yt-2.7],'parent',ax,'arrow',0.5);
        wire('x',x0+[5 7 7],'y',[yt-2.7 yt-2.7 y0+.5],'parent',ax,'arrow',0.5);
        text(tx,ty,'Feedback and Feedforward Control Loop','fontsize',12,'fontweight','bold','Hor','center');
    end
case 5  % Equations to derive FeedForward control law
    text(x0-6,y0+7.0,'The dependency of the output y on the input d is:','horiz','left','fontsize',fs);
    text(x0+1,y0+4.0,'y  =  [ Gp * Gff + Gd ] * d','horiz','left','fontsize',fs,'Color',[.8 0 0]);
    text(x0-6,y0+0.0,'Perfect disturbance rejection (y = 0) requires:','horiz','left','fontsize',fs);
    equation('Pos',[x0-1 y0-3.5],'Anchor','left','Name','Gff','Num','-Gd','Den','Gp','Color',[.8 0 0],'fontsize',fs);
    equation('Pos',[x0+5 y0-3.5],'Anchor','left','Name',' ','Num','-21.3s - 1','Den','25s + 1','Color',[.8 0 0],'fontsize',fs, ...
                 'Gain2','e^{-20.3 s}');
case 6  % FeedForward control law parameters
    text(x0-7,y0+7,'Parameterized Feedforward controller:','horiz','left','fontsize',fs);
    equation('Pos',[x0+1.5 y0+3],'Anchor','equal','Name','Gff','Gain','-Kff','Num','21.3 s + 1','Den','25 s + 1',...
        'Gain2','e^{-\theta_{ff} s}','Color',[.8 0 0],'fontsize',fs);
    text(x0-6,y0-2,'Kff    is the tunable parameter, FeedForward Gain','horiz','left','fontsize',fs,'Color',[0 0 .8]);
    text(x0-6,y0-4,'\theta_{ff}     is the tunable parameter, FeedForward Delay','horiz','left','fontsize',fs,'Color',[0 0 .8]);
case 7  % Equations to derive MISO closed-loop system
    text(x0-6,y0+7.5,'The closed-loop transfer functions:','horiz','left','fontsize',fs);
    text(x0-2,y0+2.0,'y =','horiz','left','fontsize',fs);
    equation('Pos',[x0+4 y0+2.0],'Anchor','center','Num','Gd + Gp Gff','Den','1 + Gp Gc','Color',[.8 0 0],'fontsize',fs);
    text(x0+4,y0-0.5,'regulator control','hor','center','Ver','top','fontsize',fs-2,'Color',[.8 0 0]);
    text(x0+8,y0+2.0,'d    +','horiz','left','fontsize',fs);
    text(x0+19,y0+2.0,'r','horiz','left','fontsize',fs);
    equation('Pos',[x0+15 y0+2.0],'Anchor','center','Num','Gp Gc','Den','1 + Gp Gc','Color',[0 0 .8],'fontsize',fs);
    text(x0+15,y0-0.5,'setpoint control','hor','center','Ver','top','fontsize',fs-2,'Color',[0 0 .8]);
case 8  % Equations to show ITAE criterion
    str = {'The structure of the PI controller is:'};
    text(x0-6.8,y0+9,str,'Hor','left','Ver','top','FontSize',fs);
    equation('Pos',[x0+5 y0+4.0],'Anchor','center','Name','Gc','Gain','K_{c}','Num','\tau_{c} s + 1','Den','\tau_{c} s','Color',[0.8 0 0],'fontsize',fs);

    str = {'K_{c} and \tau_{c} are calculated from the ITAE tuning criterion:'};
    text(x0-6.8,y0+1,str,'Hor','left','Ver','top','FontSize',fs);
    text(x0+1,y0-3,'K_{c} = 0.859 * ( \theta / \tau )^{-0.977}','horiz','left','fontsize',fs,'color',[0 0 0.8]);
    text(x0+1,y0-6,'\tau_{c} = ( \tau / 0.674 ) * ( \theta / \tau )^{0.680}','horiz','left','fontsize',fs,'color',[0 0 0.8]);
end


%%%%%%%%%%%%%%%%%%%%%
% localPlotStepData %
%%%%%%%%%%%%%%%%%%%%%
function localPlotStepData(action)
% Plot experimental step data
%---Clear/Reset axes
ax = gca;
set(ax,'visible','on');
set(ax,'NextPlot','add');

%---Step data
step_data = [ ...
      0.0000    0.0113    1.0000; ...
     10.0000    0.0162    1.0000; ...
     20.0000    0.1947    1.0000; ...
     30.0000    0.5591    1.0000; ...
     40.0000    0.7050    1.0000; ...
     50.0000    0.7744    1.0000; ...
     60.0000    0.9218    1.0000; ...
     70.0000    0.9208    1.0000; ...
     80.0000    0.9852    1.0000; ...
     90.0000    0.9575    1.0000; ...
    100.0000    1.0546    1.0000; ...
    110.0000    0.9873    1.0000; ...
    120.0000    1.0258    1.0000; ...
    130.0000    0.9930    1.0000; ...
    140.0000    1.0203    1.0000; ...
    150.0000    1.0605    1.0000; ...
    160.0000    0.9637    1.0000; ...
    170.0000    1.0051    1.0000; ...
    180.0000    0.9878    1.0000; ...
    190.0000    0.9876    1.0000; ...
    200.0000    1.0349    1.0000];

h = ltiplot(ax,'step',{''},{''},cstprefs.tbxprefs);
pl = plot(h,step_data(:,1),step_data(:,2));
set(gca,'xlim',[0 200],'ylim',[0 1.2]);

title('Experimental Data from Step Test on Plant');
ylabel('Normalized Response');
grid on;

pa = getaxes(h.Axesgrid);
set(double(pa),'HitTest','off');

% Display Experimental Data
setstyle(get(h,'Responses'),'r-*');

%---Steady-state (norm)
line('Parent',pa, ...
    'XData',[0 200], ...
    'YData',[1 1], ...
    'LineStyle','--', ...
    'Color','m');

%---Plot the t1,t2 lines
line('Parent',pa, ...
    'XData',[36  36 NaN 23  23 NaN 0.0   23  NaN 0.0   36], ...
    'YData',[0.634 0.0  NaN 0.286 0.0  NaN 0.286 0.286 NaN 0.634 0.634], ...
    'LineWidth',2, ...
    'LineStyle','-.', ...
    'Color','b');
text('Parent',pa,'Pos',[22 0.1],'String','  t_1','Horiz','left');
text('Parent',pa,'Pos',[35 0.1],'String','  t_2','Horiz','left');

if action == 1,
    %---Show the step response of the model
    localPlotResponses('Step')
    set(gca,'Xlim',[0 200],'Ylim',[0 1.2]);
    title('Experimental & Simulated Data from Step Test on Plant');
end
