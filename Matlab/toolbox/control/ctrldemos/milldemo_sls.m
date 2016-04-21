function slide = milldemo_sls(slidenum)
%MILLDEMO  LQG regulator for a hot steel rolling mill.
%
%   This demo shows how to design a MIMO LQG regulator to 
%   control the horizontal and vertical thickness of a steel 
%   beam.  The LQG regulator consists of a state-feedback 
%   gain and a Kalman filter that estimates the thickness 
%   variations.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/10 06:41:24 $

persistent Px Regx clx Py Regy clxy Pxy dt t wx wxy Regxy hbutton
randn('seed',24);

if nargin
    %---Slide code
    cla, legend off
    switch slidenum
    case 1
        % Beam picture
        set(gca,'Position',[0.035 0.415 0.725 0.54],'ydir','normal')
        set(gca,'xlim',[0 10],'ylim',[0 6],'vis','off')
        sysblock('pos',[4.1 2 1.8 3],'facecolor',[.7 .7 .9])
        sysblock('pos',[3.6 1 2.8 1],'facecolor',[1 1 1])
        sysblock('pos',[3.6 4 2.8 1],'facecolor',[1 1 1])
        sysblock('pos',[2.8 2.5 1.8 1],'facecolor',[1 1 1])
        sysblock('pos',[5.4 2.5 1.8 1],'facecolor',[1 1 1])
        line([3.4 6.6 NaN 3.4 6.6 NaN 3.7 3.7 NaN 6.3 6.3],...
             [1.5 1.5 NaN 4.5 4.5 NaN 2.25 3.75 NaN 2.25 3.75],...
             'linestyle','--','color','k');
        wire('x',[2.5 4.0],'y',[5 4.75],'arrow',.3);
        wire('x',[2.5 3.4],'y',[5 3.1],'arrow',.3);
        text(2.6,5,'rolling cylinders','hor','right','ver','bottom','fontsize',8+2*isunix);
        wire('x',[2.6 4.6],'y',[1.5 2.25],'arrow',.3);
        text(2.7,1.5,'shaped beam','hor','right','ver','top','fontsize',8+2*isunix);
        wire('x',[8 8],'y',[4 5.2],'arrow',.2);
        wire('x',[8 9],'y',[4 4],'arrow',.2);
        text(7.85,5.2,'y','hor','right','ver','middle','fontsize',8+2*isunix);
        text(9,3.9,'x','hor','center','ver','top','fontsize',8+2*isunix);

    case 2
        % Mill stand picture
        set(gca,'Position',[0.035 0.415 0.725 0.54],'ydir','normal')
        set(gca,'xlim',[0 10],'ylim',[0 6],'vis','off')
        sysblock('pos',[3.5 .85 3 4.3],'facecolor',[.9 .9 .9],'linewidth',1)
        t = 0:2*pi/128:2*pi;
        x = .5*sin(t);
        y = .5*cos(t);
        patch('XData',[5+x],'YData',[3.9+y],'linew',3,'edgecolor','k','facecolor','w');
        patch('XData',[5+x],'YData',[2.6+y],'linew',3,'edgecolor','k','facecolor','w');
        patch('xdata',[2.6 4.5 5 7.6 7.6 5 4.5 2.6 2.6],...
              'ydata',3.25+[-.3 -.3 -.12 -.12 .12 .12 .3 .3 -.3],...
              'facecolor',[.7 .7 .9]);
        text(2.6,3.25,'incoming beam  ','hor','right','ver','middle','fontsize',8+2*isunix);
        text(7.6,3.25,'  shaped beam','hor','left','ver','middle','fontsize',8+2*isunix);
        wire('x',[6.7 7.6],'y',[2.8 2.8],'arrow',.2);
        text(7.15,2.6,'x-axis','hor','center','ver','top','fontsize',8+2*isunix);
        x = .8*sin(pi/2-t(20:48));
        y = .8*cos(pi/2-t(20:48));
        wire('XData',5+x,'YData',3.9+y,'linew',1,'color','r','arrow',.22);
        wire('XData',5+x,'YData',2.6-y,'linew',1,'color','r','arrow',.22);
        text(5,1.4,'rolling cylinders','hor','center','ver','middle','fontsize',8+2*isunix);
        text(5,5.3,'Rolling Mill Stand','hor','center','ver','bottom','fontweight','bold','fontsize',8+2*isunix);

    case 3
        % Diagram
        set(gca,'xlim',[0 10],'ylim',[0 6],'vis','off')
        set(gca,'Position',[0.1 0.49 0.64 0.45])
        DrawOpenX;
        
    case 4
        axis(gca,'normal');
        if isunix, 
            fw = 'normal'; fs = 12;
        else
            fw = 'bold'; fs = 10;
        end
        set(gca,'Position',[0.1 0.49 0.64 0.45])
        set(gca,'xlim',[0 1],'ylim',[0 1],'visible','off')
        equation('pos',[0.1,.85],'name','H_x(s)','num','2.4e8','den','s^2 + 72s + 90^2',...
            'anchor','left','fontweight',fw,'fontsize',fs)
        equation('pos',[0.1,.55],'name','F_{ex}(s)','num','3e4 s','den','s^2 + 0.125s + 6^2',...
            'anchor','left','fontweight',fw,'fontsize',fs)
        equation('pos',[0.1,.25],'name','F_{ix}(s)','num','1e4','den','s + 0.05',...
            'anchor','left','fontweight',fw,'fontsize',fs)
        equation('pos',[0.1,-.05],'name','g_x','num','1e-6',...
            'anchor','left','fontweight',fw,'fontsize',fs)
        Hx = tf(2.4e8,[1 72 90^2],'inputname','u-x');      
        Fex = tf([3e4 0],[1 0.125 6^2],'inputn','w-ex');      
        Fix = tf(1e4,[1 0.05],'inputname','w-ix');      
        gx = 1e-6;
        Px = append([ss(Hx) Fex],Fix);
        Px = [-gx gx;1 1] * Px;
        set(Px ,'outputname' , {'x-gap'  'x-force'})

    case 5
        % Bode mag response
        axis(gca,'normal');
        bodemag(Px(:,{'w-ex' , 'w-ix'}))
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto');
        set(h.AxesGrid,'Xunits','rad/sec','Yunits',{'dB';'deg'},'Grid','off');

    case 6
        axis(gca,'normal');
        set(gca,'Position',[0.1 0.49 0.64 0.45])
        set(gca,'xlim',[0 1],'ylim',[0 1],'visible','off')
        DrawLQGX
        
    case 7
        % Compute LQR gain (show cost function)
        if isunix, 
            fw = 'normal';
        else
            fw = 'bold';
        end
        axis(gca,'normal');
        set(gca,'Position',[0.1 0.49 0.64 0.45])
        set(gca,'xlim',[0 1],'ylim',[0 1],'visible','off')
        text(0,.7,'LQR cost function:','FontSize',12+2*isunix,'FontWeight','bold')
        text(.1,.3,'C(u) = \int_0^\infty (\delta(t)^2 + \beta u(t)^2) dt',...
            'FontSize',14+0*isunix,'FontWeight',fw)
        
    case 8
        axis(gca,'normal');
        % LQG reg for x axis
        Kx = lqry(Px('x-gap','u-x'),1,1e-4);
        Ex = kalman(Px('x-force',:),eye(2),1e4);
        Regx = lqgreg(Ex,Kx);
        bode(Regx)
        title('Bode diagram of the LQG regulator');
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto');
        set(h.AxesGrid,'Xunits','rad/sec','Yunits',{'dB';'deg'},'Grid','off');
        set(h.Responses.View,'UnwrapPhase','on');
        
    case 9
        axis(gca,'normal');
        clx = feedback(Px,Regx,1,2,+1); 
        bodemag(Px(1,2:3),'b',clx(1,2:3),'r',{1e-1,1e2})
        title('Open- vs. closed-loop Bode magnitude plot');
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto');
        set(h.AxesGrid,'Xunits','rad/sec','Yunits',{'dB';'deg'},'Grid','off');
        legend('open loop','closed loop',4)
        
    case 10
        axis(gca,'normal');
        dt = 0.01;
        t = 0:dt:30;                             % input time samples
        wx = sqrt(1/dt) * randn(2,length(t));    % sampled driving noise
        lsim(Px(1,2:3),'b',clx(1,2:3),'r',wx,t)
        title('Open- (blue) vs. closed-loop (red) thickness variations');
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto');
        set(h.AxesGrid,'Grid','off');
        set(h.Input,'Visible','off');
        set(gca,'Ylim',[-0.3 0.3]);
        
    case 11
        axis(gca,'normal');
        set(gca,'Position',[0.1 0.49 0.64 0.45])
        set(gca,'xlim',[0 1],'ylim',[0 1],'visible','off')
        % Cross-coupling diagram
        DrawCrossCoupling
        % Design for Y axis
        Hy = tf(7.8e8,[1 71 88^2],'inputname','u-y');     
        Fiy = tf(2e4,[1 0.05],'inputname','w-iy');      
        Fey = tf([1e5 0],[1 0.19 9.4^2],'inputn','w-ey');     
        gy = 0.5e-6;
        Py = append([ss(Hy) Fey],Fiy);
        Py = [-gy gy;1 1] * Py;
        set(Py,'outputn',{'y-gap' 'y-force'})
        ky = lqry(Py(1,1),1,1e-4);
        Ey = kalman(Py(2,:),eye(2),1e4);
        Regy = lqgreg(Ey,ky);
        %cly = feedback(Py,Regy,1,2,+1);
        %bodemag(Py(1,2:3),'b',cly(1,2:3),'r',{1e-1,1e2})
        
    case 12
        axis(gca,'normal');
        set(gca,'Position',[0.1 0.49 0.64 0.45])
        set(gca,'xlim',[0 1],'ylim',[0 1],'visible','off')
        % Cross-coupling diagram
        DrawCrossCoupling
        gxy = 0.1; 
        gyx = 0.4; 
        gy = 0.5e-6;
        gx = 1e-6;
        P = append(Px,Py);                % Append x- and y-axis models
        P = P([1 3 2 4],[1 4 2 3 5 6]);   % Reorder inputs and outputs 
        CC = [eye(2) [0 gyx*gx;gxy*gy 0] ; zeros(2) [1 -gyx;-gxy 1]];
        Pxy = CC * P;
        Pxy.outputn = P.outputn;
        clxy = feedback(Pxy,append(Regx,Regy),1:2,3:4,+1);
        
    case 13
        % Compare simulations
        axis(gca,'normal');
        wy = sqrt(1/dt) * randn(2,length(t));     % y-axis disturbances
        wxy = [wx ; wy];
        lsim(Pxy(1:2,3:6),'b',clxy(1:2,3:6),'r',wxy,t)
        title('Open- (blue) vs. closed-loop (red) thickness variations');
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto');
        set(h.AxesGrid,'Grid','off');
        set(h.Input,'Visible','off');
        set(gca,'Ylim',[-0.3 0.3]);
                
    case 14
        axis(gca,'normal');
        set(gca,'Position',[0.1 0.49 0.64 0.45])
        set(gca,'xlim',[0 1],'ylim',[0 1],'visible','off')
        % MIMO LQG loop
        DrawLQGXY
        Kxy = lqry(Pxy(1:2,1:2),eye(2),1e-4*eye(2));
        Exy = kalman(Pxy(3:4,:),eye(4),1e4*eye(2));
        Regxy = lqgreg(Exy,Kxy);
        clxy = feedback(Pxy,Regxy,1:2,3:4,+1);
        
    case 15
        axis(gca,'normal');
        set(gca,'xlim',[0 1],'ylim',[0 1],'visible','off')
        sigma(Regxy)
        title('Singular values of MIMO LQG regulator');
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto');
        set(h.AxesGrid,'Xunits','rad/sec','Yunits','dB','Grid','off');        
        
    case 16
        axis(gca,'normal');
        lsim(Pxy(1:2,3:6),'b',clxy(1:2,3:6),'r',wxy,t)
        title('Open- (blue) vs. closed-loop (red) thickness variations');
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto');
        set(h.AxesGrid,'Grid','off');
        set(h.Input,'Visible','off');        
        set(gca,'Ylim',[-0.3 0.3]);
        
    end
    
elseif nargout<1
    %---Start demo
    fg = playshow(mfilename);
    set(fg,'Name','Steel Rolling Mill Demo','doublebuffer','on');    
    
else
    %---Construct slides
    slidenum = 0;
    
    %========== Slide 1 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' A rectangular beam of hot metal is shaped by a rolling mill as'
        ' sketched above.'
        ' '
        ' This demo shows how to control the beam thickness using SISO and'
        ' MIMO LQG techniques.  It also demonstrates the benefits of MIMO'
        ' feedback over independent SISO loops when there is significant'
        ' cross-coupling between the horizontal and vertical axes.'
    };    
    
    %========== Slide 2 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' The desired shape is impressed by two pairs of rolling cylinders'
        ' (one per axis) positioned by hydraulic actuators. The gap between'
        ' the two cylinders is called the roll gap.'
        ' '
        ' The goal is to maintain the x and y thickness between specified'
        ' tolerances.  Thickness variations come primarily from variations in'
        ' thickness/hardness of the incoming beam (input disturbance), and'
        ' eccentricities of the rolling cylinders'
    };
    
    %========== Slide 3 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' The open-loop model for the x or y axes is shown above.  The'
        ' eccentricity and input thickness disturbances are modeled as white'
        ' noise w_e and w_i driving band-pass and low-pass filters,'
        ' respectively.'
        ' '
        ' Feedback control is necessary to counter such disturbances.  Because'
        ' the roll gap delta can''t be measured close to the stand, the rolling'
        ' force f is used for feedback.'
    };
    
    %========== Slide 4 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Using the model data above, create an open-loop state-space model'
        ' of the x-axis:'
        ' '
        ' >> Hx = tf(2.4e8 , [1  72  90^2] , ''inputname'' , ''u-x'')'
        ' >> Fex = tf([3e4 0] , [1 0.125 6^2] , ''inputnname'' , ''w-ex'')'
        ' >> Fix = tf(1e4 , [1 0.05] , ''inputname'' , ''w-ix'')'
        ' >> gx = 1e-6'
        ' >> Px = [-gx gx;1 1] * append([ss(Hx) Fex],Fix)'
        ' '
        ' Note: Convert Hx to state space to keep the model order minimal.'
    };
    
    %========== Slide 5 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Plot the frequency response magnitude from the normalized disturbances'
        ' w_e and w_i to the outputs:'
        ' '
        ' >> set(Px , ''outputname'' , {''x-gap''  ''x-force''})'    
        ' >> bodemag(Px(: , {''w-ex'' , ''w-ix''}))'
        ' '
        ' Note the peak at 6 rad/sec corresponding to the (periodic) eccentricity'
        ' disturbance.'
    };
    
    %========== Slide 6 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' You can design an LQG regulator to attenuate the thickness variations '
        ' due to the eccentricity and input thickness disturbances w_e and w_i.'
        ' '
        ' LQG regulators generate actuator commands u = -K x_e where x_e is'
        ' an estimate of the state vector x derived from available measurements'
        ' of the rolling force f.'
        ' '
        ' You must design the state-feedback gain K and the Kalman filter E(s)'
        ' estimating x.'
    };
    
    %========== Slide 7 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Use LQRY to calculate the state-feedback gain K.  The gain K is'
        ' chosen to minimize a cost function of the form shown above.'
        ' '
        ' Use the parameter beta to trade off performance and control effort.'
        ' For beta = 1e-4, the optimal gain is obtained by'
        ' '
        ' >> Pxdes = Px(''x-gap'',''u-x'')            % u -> x gap'
        ' >> Kx = lqry(Pxdes,1,1e-4)'
    };
    
    %========== Slide 8 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Next use KALMAN to design a Kalman estimator E(s) for the plant '
        ' state vector.  Set the measurement noise covariance to 1e4 to limit'
        ' the high frequency gain:'
        ' '
        ' >> Ex = kalman(Px(''x-force'',:),eye(2),1e4)'
        ' '
        ' The LQG regulator Regx is assembled from Kx and Ex by'
        ' '
        ' >> Regx = lqgreg(Ex,Kx)'
        ' >> bode(Regx) '
    };
    
    %========== Slide 9 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Compare the open-loop vs. closed-loop responses to eccentricity'
        ' and input thickness disturbances:'
        ' '
        ' >> clx = feedback(Px,Regx,1,2,+1)         % +1 -> positive feedback'
        ' >> bodemag(Px(1,2:3),''b'',clx(1,2:3),''r'',{1e-1,1e2})'
        ' '
        ' The disturbances have been attenuated by about 20dB.'
    };
 
    %========== Slide 10 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Compare the disturbance-induced thickness variations with and '
        ' without the LQG regulator:'
        ' '
        ' >> dt = 0.01'
        ' >> t = 0:dt:30'                         
        ' >> wx = sqrt(1/dt) * randn(2,length(t))    % sampled driving noise'
        ' >> lsim(Px(1,2:3),''b'',clx(1,2:3),''r'',wx,t)'
    };
    
    %========== Slide 11 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' You can design a similar LQG regulator for the y axis. Treating each'
        ' axis separately is valid as long as they are fairly decoupled.  Yet'
        ' rolling mills have some amount of cross-coupling between axes,'
        ' because an increase in force along x compresses the material and'
        ' causes a relative decrease in force along the y axis.'
        ' '
        ' Cross-coupling effects are modeled as shown above with gxy=0.1'
        ' and gyx=0.4'
    };
        
    %========== Slide 12 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' To study the effect of cross-coupling on decoupled SISO loops,'
        ' derive a two-axis model Pxy and close the x- and y-axis loops'
        ' using the previously designed LQG regulators:'
        ' '
        ' >> Pxy = CC * append(Px,Py)     % CC = cross-coupling matrix'
        ' >> feedin = 1:2                       % select controls u-x, u-y'
        ' >> feedout = 3:4                      % select meas. x-force, y-force'
        ' >> clxy = feedback(Pxy,append(Regx,Regy),feedin,feedout,+1)'
    };
        
    %========== Slide 13 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Now simulate the x- and y-thickness variations for the two-axis model:'
        ' '
        ' >> wy = sqrt(1/dt) * randn(2,length(t))     % y-axis disturbances'
        ' >> wxy = [wx ; wy]'
        ' >> lsim(Pxy(1:2,3:6),''b'',clxy(1:2,3:6),''r'',wxy,t)'
        ' '
        ' Note the high thickness variations along the x axis.  Treating each'
        ' axis separately is inadequate and you must perform a joint-axis, MIMO'
        ' design to correctly handle cross-coupling effects.'
    };
    
    %========== Slide 14 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Designing a MIMO LQG regulator for the two-axis model follows the'
        ' exact same steps as the previous SISO designs:'
        ' '
        ' >> Kxy = lqry(Pxy(1:2,1:2),eye(2),1e-4*eye(2))'
        ' >> Exy = kalman(Pxy(3:4,:),eye(4),1e4*eye(2))'
        ' >> Regxy = lqgreg(Exy,Kxy)'
        ' >> clxy = feedback(Pxy,Regxy,1:2,3:4,+1)'
    };
    
    %========== Slide 15 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Look at the singular values (principal gains) of the MIMO regulator:'
        ' '
        ' >> sigma(Regxy)'
        ' '
        ' Note the two peaks at 6 rad/sec and 9.4 rad/sec (dominant frequencies'
        ' of the eccentricity disturbances for the x and y axes, respectively).'
    };
    
    %========== Slide 16 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Finally compare the disturbance-induced thickness variations with and'
        ' without the MIMO LQG regulator:'
        ' '
        ' >> lsim(Pxy(1:2,3:6),''b'',clxy(1:2,3:6),''r'',wxy,t)'
        ' '
        ' The MIMO design has cured the performance loss due to cross-coupling'
        ' and the disturbance attenuation levels now match those obtained for'
        ' each individual axis.'
    };
    
end 


%%%%%%%%%%%%%%%%%%%%

function DrawOpenX
% Draws open-loop model
axis equal
ax = gca;
set(ax,'visible','off','xlim',[6 14],'ylim',[-4 10],'ydir','normal')
y0 = 9;  x0 = 0;
if isunix, 
    fw = 'normal'; fs = 10;
else
    fw = 'bold'; fs = 8;
end
wire('x',x0+[0 1.75],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text(x0,y0,'u  ','horiz','right','fontweight',fw);
sysblock('position',[x0+1.75 y0-1 2.5 2],'name','actuator',...
    'num','H(s)','fontweight',fw,'facecolor',[1 1 .9],'fontsize',fs);
sumblock('position',[x0+6,y0-2],'label',{'+45','+315'},'radius',.3,...
    'LabelRadius',1.2,'fontsize',12);
wire('x',x0+[4.25 6 6],'y',y0+[0 0 -1.7],'parent',ax,'arrow',0.5);

wire('x',x0+[0 1.75],'y',y0+[-4 -4],'parent',ax,'arrow',0.5);
text(x0,y0-4,'w_e ','horiz','right','fontweight',fw);
sysblock('position',[x0+1.75 y0-5 2.5 2],'name','eccentricity',...
    'num','Fe(s)','fontweight',fw,'facecolor',[1 1 .9],'fontsize',fs);
wire('x',x0+[4.25 6 6],'y',y0+[-4 -4 -2.3],'parent',ax,'arrow',0.5);

wire('x',x0+[0 1.75],'y',y0+[-8 -8],'parent',ax,'arrow',0.5);
text(x0,y0-8,'w_i  ','horiz','right','fontweight',fw);
sysblock('position',[x0+1.75 y0-9 2.5 2],'name','input thickness',...
    'num','Fi(s)','fontweight',fw,'facecolor',[1 1 .9],'fontsize',fs);
wire('x',x0+[4.25 11.7],'y',y0+[-8 -8],'parent',ax,'arrow',0.5);

sumblock('position',[x0+12,y0-8],'label',{'+45','+235'},'radius',.3,...
    'LabelRadius',1.2,'fontsize',12);
wire('x',x0+[12.3 19],'y',y0+[-8 -8],'parent',ax,'arrow',0.5);
text(x0+19,y0-8,' f','horiz','left','fontweight',fw);
wire('x',x0+[6.3 11.7],'y',y0+[-2 -2],'parent',ax,'arrow',0.5);
sumblock('position',[x0+12,y0-2],'label',{'+135','+235'},'radius',.3,...
    'LabelRadius',1.2,'fontsize',12);
wire('x',x0+[12.3 14.5],'y',y0+[-2 -2],'parent',ax,'arrow',0.5);
sysblock('position',[x0+14.5 y0-3 2 2],'name','gap to force',...
    'num','gx','fontweight',fw,'facecolor',[1 1 .9],'fontsize',fs);
wire('x',x0+[16.5 19],'y',y0+[-2 -2],'parent',ax,'arrow',0.5);
text(x0+19,y0-2,' \delta','horiz','left','fontweight',fw,'fontsize',12);
wire('x',x0+[9 9 12 12],'y',y0+[-2 -5 -5 -7.7],'parent',ax,'arrow',0.5);
wire('x',x0+[8 8 12 12],'y',y0+[-8 -4 -4 -2.3],'parent',ax,'arrow',0.5);
text(x0+9,y0-1.1,'f_1','horiz','center','fontweight',fw,'fontsize',10);
text(x0+9,y0-9,'f_2','horiz','center','fontweight',fw,'fontsize',10);

x0 = -2;
y0 = -3;
text(x0,y0,'u','horiz','left','color','r','fontsize',fs);
text(x0+2,y0,'command','horiz','left','color','r','fontsize',fs);
text(x0,y0-1.6,'w_e','horiz','left','color','r','fontsize',fs);
text(x0+2,y0-1.4,'eccentricity disturb.','horiz','left','color','r','fontsize',fs);
text(x0,y0-3,'w_i','horiz','left','color','r','fontsize',fs);
text(x0+2,y0-2.8,'input thickness disturb.','horiz','left','color','r','fontsize',fs);

x0 = 13;
text(x0,y0-0.5,'\delta','horiz','left','color','r','fontsize',fs);
text(x0+2,y0-0.5,'thickness gap','horiz','left','color','r','fontsize',fs);
text(x0,y0-2,'f','horiz','left','color','r','fontsize',fs);
text(x0+2,y0-2,'rolling force','horiz','left','color','r','fontsize',fs);


function DrawLQGX
% Draws open-loop model
axis equal
ax = gca;
set(ax,'visible','off','xlim',[1 9],'ylim',[0.5 9.5])
y0 = 0;  x0 = 0;
if isunix, 
    fw = 'normal'; fs = 10;
else
    fw = 'bold'; fs = 8;
end
sysblock('position',[x0+3 y0+5 4 4],'name','Plant',...
    'num','Px','fontweight',fw,'facecolor',[1 1 .9],'fontsize',fs);
wire('x',x0+[0 3],'y',y0+[8 8],'parent',ax,'arrow',0.5);
text(x0,y0+8,'w_e  ','horiz','right','fontweight',fw);
wire('x',x0+[0 3],'y',y0+[7 7],'parent',ax,'arrow',0.5);
text(x0,y0+7,'w_i  ','horiz','right','fontweight',fw);
wire('x',x0+[7 10],'y',y0+[7.5 7.5],'parent',ax,'arrow',0.5);
text(x0+10,y0+7.5,'  \delta','horiz','left','fontweight',fw);

sysblock('position',[x0+3.5 y0 3 3],'name','LQG regulator',...
    'num','Regx','fontweight',fw,'facecolor',[.8 1 1],'fontsize',fs);
wire('x',x0+[7 9 9 6.5],'y',y0+[6 6 1.5 1.5],'parent',ax,'arrow',0.5);
wire('x',x0+[3.5 1 1 3],'y',y0+[1.5 1.5 6 6],'parent',ax,'arrow',0.5);
text(x0+.5,y0+3.5,'u','horiz','right','fontweight',fw);
text(x0+9.5,y0+3.5,'f','horiz','left','fontweight',fw);


function DrawCrossCoupling
% Draws cross coupling
axis equal
ax = gca;
set(ax,'visible','off','xlim',[1 33],'ylim',[2.3 20.2])
if isunix, 
    fw = 'normal'; fs = 10;
else
    fw = 'bold'; fs = 8;
end
sysblock('position',[4 0 5 7],'name','y-axis',...
    'fontweight',fw,'facecolor',[1 1 .9],'fontsize',10);
wire('x',[0 4],'y',[1 1],'parent',ax,'arrow',0.5);
text(0,1,'w_{iy}  ','horiz','right','fontweight',fw);
wire('x',[0 4],'y',[3.5 3.5],'parent',ax,'arrow',0.5);
text(0,3.5,'w_{ey}  ','horiz','right','fontweight',fw);
wire('x',[0 4],'y',[6 6],'parent',ax,'arrow',0.5);
text(0,6,'u_y  ','horiz','right','fontweight',fw);

sysblock('position',[4 11 5 7],'name','x-axis',...
    'fontweight',fw,'facecolor',[1 1 .9],'fontsize',10);
wire('x',[0 4],'y',[12 12],'parent',ax,'arrow',0.5);
text(0,12,'w_{ix}  ','horiz','right','fontweight',fw);
wire('x',[0 4],'y',[14.5 14.5],'parent',ax,'arrow',0.5);
text(0,14.5,'w_{ex}  ','horiz','right','fontweight',fw);
wire('x',[0 4],'y',[17 17],'parent',ax,'arrow',0.5);
text(0,17,'u_x  ','horiz','right','fontweight',fw);

wire('x',[9 13.7],'y',[1 1],'parent',ax,'arrow',0.5);
sumblock('position',[14 1],'label',{'+235'},'radius',.3,...
    'LabelRadius',1.2,'fontsize',12);
wire('x',[14.3 32],'y',[1 1],'parent',ax,'arrow',0.5);
text(32,1,'  \delta_y','horiz','left','fontweight',fw);

wire('x',[9 26.7],'y',[6 6],'parent',ax,'arrow',0.5);
sumblock('position',[27 6],'label',{'+135','-315'},'radius',.3,...
    'LabelRadius',1.2,'fontsize',12);
wire('x',[27.3 32],'y',[6 6],'parent',ax,'arrow',0.5);
text(32,6,'  f_y','horiz','left','fontweight',fw);

wire('x',[9 26.7],'y',[12 12],'parent',ax,'arrow',0.5);
sumblock('position',[27 12],'label',{'-45','+235'},'radius',.3,...
    'LabelRadius',1.2,'fontsize',12);
wire('x',[27.3 32],'y',[12 12],'parent',ax,'arrow',0.5);
text(32,12,'  f_x','horiz','left','fontweight',fw);

wire('x',[9 19.7],'y',[17 17],'parent',ax,'arrow',0.5);
sumblock('position',[20 17],'label',{'+135'},'radius',.3,...
    'LabelRadius',1.2,'fontsize',12);
wire('x',[20.3 32],'y',[17 17],'parent',ax,'arrow',0.5);
text(32,17,'  \delta_x','horiz','left','fontweight',fw);

wire('x',[14 14],'y',[12 10.5-.2],'parent',ax,'arrow',0.5,'color','r');
sysblock('position',[12.5 7.5+.2 3 3-.4],'name','gxy',...
    'fontweight',fw,'facecolor',[1 1 .9],'fontsize',10,'edgecolor','r');
wire('x',[14 14],'y',[7.5+.2 3.5+.3],'parent',ax,'arrow',0.5,'color','r');
sysblock('position',[12.5 2+.2 3 1.5+.1],'name','gy',...
    'fontweight',fw,'facecolor',[1 1 .9],'fontsize',fs,'edgecolor','r');
wire('x',[14 14],'y',[2+.2 1.3],'parent',ax,'arrow',0.5,'color','r');
wire('x',[14 27 27],'y',[4.7 4.7 5.7],'parent',ax,'arrow',0.5,'color','r');

wire('x',[20 20],'y',[6 7.5+.2],'parent',ax,'arrow',0.5,'color','r');
sysblock('position',[18.5 7.5+.2 3 3-.4],'name','gyx',...
    'fontweight',fw,'facecolor',[1 1 .9],'fontsize',10,'edgecolor','r');
wire('x',[20 20],'y',[10.5-.2 14.5-.2],'parent',ax,'arrow',0.5,'color','r');
sysblock('position',[18.5 14.5-.2 3 1.5+.1],'name','gx',...
    'fontweight',fw,'facecolor',[1 1 .9],'fontsize',fs,'edgecolor','r');
wire('x',[20 20],'y',[16-.1 16.7],'parent',ax,'arrow',0.5,'color','r');
wire('x',[20 27 27],'y',[13.5-.2 13.5-.2 12.3],'parent',ax,'arrow',0.5,'color','r');

text(17,20.2,'Coupling between x- and y- axes','horiz','center',...
   'fontweight','bold','fontsize',fs+2);


function DrawLQGXY
% Draws open-loop model
axis equal
ax = gca;
set(ax,'visible','off','xlim',[-3 15],'ylim',[-1 12])
y0 = 0;  x0 = 0;
if isunix, 
    fw = 'normal'; fs = 10;
else
    fw = 'bold'; fs = 8;
end
sysblock('position',[x0+3 y0+5 5 7],'name','Two-Axis Model',...
    'num','Pxy','fontweight',fw,'facecolor',[1 1 .9],'fontsize',fs);
wire('x',x0+[-2 3],'y',y0+[11 11],'parent',ax,'arrow',0.5);
text(x0-2,y0+11,'w_{ex}  ','horiz','right','fontweight',fw);
wire('x',x0+[-2 3],'y',y0+[10 10],'parent',ax,'arrow',0.5);
text(x0-2,y0+10,'w_{ix}  ','horiz','right','fontweight',fw);
wire('x',x0+[-2 3],'y',y0+[9 9],'parent',ax,'arrow',0.5);
text(x0-2,y0+9,'w_{ey}  ','horiz','right','fontweight',fw);
wire('x',x0+[-2 3],'y',y0+[8 8],'parent',ax,'arrow',0.5);
text(x0-2,y0+8,'w_{iy}  ','horiz','right','fontweight',fw);
wire('x',x0+[8 13],'y',y0+[10.5 10.5],'parent',ax,'arrow',0.5);
text(x0+13,y0+10.5,'  \delta_x','horiz','left','fontweight',fw);
wire('x',x0+[8 13],'y',y0+[8.5 8.5],'parent',ax,'arrow',0.5);
text(x0+13,y0+8.5,'  \delta_y','horiz','left','fontweight',fw);

sysblock('position',[x0+3.5 y0-2 4 4],'name','MIMO Regulator',...
    'num','Regxy','fontweight',fw,'facecolor',[.8 1 1],'fontsize',fs);
wire('x',x0+[3.5 0 0 3],'y',y0+[0.5 0.5 6 6],'parent',ax,'arrow',0.5);
text(x0,y0+3.5,'  u_y','horiz','left','fontweight',fw);
wire('x',x0+[3.5 -1 -1 3],'y',y0+[-0.5 -0.5 7 7],'parent',ax,'arrow',0.5);
text(x0-1,y0+3.5,'u_x  ','horiz','right','fontweight',fw);

wire('x',x0+[8 11 11 7.5],'y',y0+[6 6 0.5 0.5],'parent',ax,'arrow',0.5);
text(x0+11,y0+3.5,'f_y  ','horiz','right','fontweight',fw);
wire('x',x0+[8 12 12 7.5],'y',y0+[7 7 -0.5 -0.5],'parent',ax,'arrow',0.5);
text(x0+12,y0+3.5,'  f_x','horiz','left','fontweight',fw);
