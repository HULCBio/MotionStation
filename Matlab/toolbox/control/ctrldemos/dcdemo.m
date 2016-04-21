function slide = dcdemo1(slidenum)
%   This demo compares three techniques for tracking setpoint
%   commands and reducing sensitivity to load disturbances:
%     * feedforward command
%     * integral feedback control
%     * LQR regulation
%
%   See "Getting Started:Building Models" for more details about
%   the DC motor model.

%   Authors: P. Gahinet
%   Revised: A. DiVergilio
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.1 $  $Date: 2004/01/03 12:23:42 $

persistent dcm t u cl_ff cl_rloc cl_lqr 

if nargin
    %---Slide code
    cla, legend off
    switch slidenum
    case 1
        %---DC motor image
        set(gca,'Position',[0.035 0.415 0.725 0.54])
        set(gca,'xlim',[.4 10.4],'ylim',[-.15 5.85],'vis','off')
        fs = 10+2*isunix;
        %---Curve parameters
        t = 0:2*pi/128:2*pi;
        x = .3*sin(t);
        y = 1.1*cos(t);
        xh = .3*sin(t(1:(end-1)/2));
        yh = 1.1*cos(t(1:(end-1)/2));
        %---Resistor/Inductor
        resistor('pos',[1.5 5],'size',1.5,'angle',0);
        inductor('pos',[3.25 4.75],'size',1.5,'angle',-90);
        %---Load
        patch('XData',[6.8+x],'YData',[2.25+y],'linewidth',2,'facecolor',[.6 .6 1]);
        patch('XData',[8.3+xh 6.8+xh],'YData',[2.25+yh 2.25-yh],'linewidth',2,'facecolor',[.7 .7 1]);
        text(7.85,2.25,{'Inertial';'Load J'},'FontSize',fs,'FontWeight','b','Ver','middle','Hor','center')
        wire('XData',8.3+2*xh(5:end-5),'YData',2.25+1.5*yh(5:end-5),'linew',1,'color','r','arrow',.3);
        text(8.2,0.65,{'\omega(t)';'Angular velocity'},'FontSize',fs,'Ver','top','Hor','center')
        wire('XData',9.05+2*xh(15:end-15),'YData',2.25-1.5*yh(15:end-15),'linew',1,'color','r','arrow',.3);
        text(9.5,3.7,{'K_{f}\omega(t)';'Viscous';'friction'},'FontSize',fs,'Ver','bottom','Hor','center')
        %---Shaft
        patch('XData',[6.8+xh/4 5.55+xh/4],'YData',[2.25+yh/4 2.25-yh/4],'linewidth',2,'facecolor',[.8 .8 .8]);
        wire('XData',6+xh(15:end-12),'YData',2.25+yh(15:end-12)/1.15,'linew',1,'color','r','arrow',.3);
        text(6.1,1.3,{'\tau(t)';'Torque'},'FontSize',fs,'Ver','top','Hor','center')
        %---DC Motor
        patch('XData',[3.75+x],'YData',[2.25+y],'linewidth',2,'facecolor',[.6 .6 1]);
        patch('XData',[5.55+xh 3.75+xh],'YData',[2.25+yh 2.25-yh],'linewidth',2,'facecolor',[.7 .7 1]);
        text(4.9,2.25,{'DC';'Motor'},'FontSize',fs,'FontWeight','b','Ver','middle','Hor','center')
        %---Wires
        wire('x',[1 3.75 NaN 1 1.5 NaN 3 3.25 3.25 NaN 3.25 3.25 3.75],...
            'y',[1.5 1.5 NaN 5 5 NaN 5 5 4.75 NaN 3.25 3 3])
        %---Ports
        port('x',[1 1 3.25 3.25],'ydata',[1.5 5 1.5 3],'Name','');
        text(1,3.25,{'+';' ';' ';'V_{a}';' ';' ';'-'},'FontSize',fs,'Ver','middle','Hor','right')
        text(3.25,2.25,{'+';'V_{emf}';'-'},'FontSize',fs,'Ver','middle','Hor','right')
        %---Labels
        text(2.25,5.4,'R','FontSize',fs,'Ver','bottom','Hor','center')
        text(3.75,4,'L','FontSize',fs,'Ver','middle','Hor','left')
    case 2
        set(gca,'Position',[0.085+0.015 0.49 0.65-0.015 0.45])
        % Draw DC motor diagram
        DrawDCM
    case 3
        % Leave previous diag.
        set(gca,'Position',[0.085+0.015 0.49 0.65-0.015 0.45])
        DrawDCM
        R = 2.0;  L = 0.5;  Km = 0.1;  Kb = 0.1;  Kf = 0.2;  J = 0.02;
        h1 = tf(Km,[L R]);
        h2 = tf(1,[J Kf]);
        dcm = ss(h2) * [h1,1];           
        dcm = feedback(dcm,Kb,1,1);
    case 4
        % Step response
        axis(gca,'normal');
        dcm1 = dcm(1);
        step(dcm1)
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto','Grid','off');
    case 5
        % Display feedforward structure
        set(gca,'Position',[0.085+0.015 0.49 0.65-0.015 0.45])
        DrawFF
    case 6
        % Simulate FF control
        axis(gca,'normal');
        t = 0:0.1:15;
        w_ref = ones(size(t));
        Td = -0.1 * (t>5 & t<10);
        u = [w_ref;Td];
        Kff = 1/dcgain(dcm(1));
        cl_ff = dcm * diag([Kff,1]);
        set(cl_ff,'InputName',{'w_ref','Td'},'OutputName','w');
        lsim(cl_ff,u,t);
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto','Grid','off');
        set(h.Input,'Visible','off');
        title('Setpoint tracking and disturbance rejection')
        % Highlight disturbance
        wire('x',[5.8 5 NaN 9.2 10],'y',[0.25 0.25 NaN 0.25 0.25],'linewidth',0.5);
        wire('x',[5 5 NaN 10 10],'y',[0.21 0.29 NaN 0.21 0.29],'linewidth',2);
        text(7.5,.25,{'disturbance','T_d = -0.1Nm'},...
            'vertic','middle','horiz','center','color','r','fontsize',8+2*isunix)
    case 7
        % Display feedback structure
        set(gca,'Position',[0.085+0.015 0.49 0.65-0.015 0.45])
        DrawRLOC
    case 8
        % Root locus design
        axis(gca,'normal');
        rlocus(tf(1,[1 0]) * dcm(1))
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto','Grid','off');
        set(h,'FrequencyUnits','rad/sec');
        set(gca,'Xlim',[-15 5],'Ylim',[-15 15]);
    case 9
        % Simulate
        axis(gca,'normal');
        K = 5;
        C = tf(K,[1 0]);
        cl_rloc = feedback(dcm * append(C,1),1,1,1);
        set(cl_rloc,'InputName',{'w_ref','Td'},'OutputName','w');
        lsim(cl_ff,cl_rloc,u,t)
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto','Grid','off');
        set(h.Input,'Visible','off');
        hasbehavior(h.Input.View(1).Curves,'legend',false);
        hasbehavior(h.Input.View(2).Curves,'legend',false);
        title('Setpoint tracking and disturbance rejection')
        legend('feedforward','feedback w/ rlocus',4)
    case 10
        % Show LQR feedback structure
        set(gca,'Position',[0.085+0.015 0.49 0.65-0.015 0.45])
        DrawLQR
    case 11
        % Compute LQR gain (show cost function)
        axis(gca,'normal')
        if isunix, 
            fw = 'normal';
        else
            fw = 'bold';
        end
        set(gca,'xlim',[0 1],'ylim',[0 1],'visible','off')
        text(0,.8,'LQR cost function:','FontSize',12,'FontWeight','bold')
        text(.1,.5,'C = \int_0^\infty (20 q(t)^2 + \omega(t)^2 + 0.01 V_a(t)^2) dt',...
            'FontSize',12,'FontWeight',fw)
        text(.5,.2,'(where q(s) = \omega(s)/s)','FontSize',12,'FontWeight',fw)
    case 12
        % Form closed loop
        DrawLQR
        dc_aug = [1;tf(1,[1 0])] * dcm(1);
        K_lqr = lqry(dc_aug,diag([1 20]),0.01);
        dcmx = augstate(dcm);   % in:Va,Td  out:w,x=(i,w)
        C = K_lqr * append(tf(1,[1 0]),1,1);
        OL = dcmx * append(C,1);
        CL = feedback(OL,eye(3),1:3,1:3);
        cl_lqr = CL(1,[1 4]);
        set(cl_lqr,'InputName',{'w_ref','Td'},'OutputName','w');
    case 13
        % Compare closed-loop Bode diag.
        axis(gca,'normal');set(gca,'xlim',[0 1],'ylim',[0 1]);
        bode(cl_ff,cl_rloc,cl_lqr)
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto');
        set(h.AxesGrid,'XUnits','rad/sec','YUnits',{'dB';'deg'},'Grid','off','Xscale','log');
        ax = getaxes(h.AxesGrid);
    case 14
        % Compare simulation
        axis(gca,'normal');
        lsim(cl_ff,cl_rloc,cl_lqr,u,t)
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto','Grid','off');
        set(h.Input,'Visible','off');
        hasbehavior(h.Input.View(1).Curves,'legend',false);
        hasbehavior(h.Input.View(2).Curves,'legend',false);
        title('Setpoint tracking and disturbance rejection')
        legend('feedforward','feedback (rlocus)','feedback (LQR)',4)
    end
    
    
elseif nargout<1
    %---Start demo
    fg = playshow(mfilename);
    set(fg,'Name','Disturbance Rejection Demo','doublebuffer','on');
    
    
else
    %---Construct slides
    slidenum = 0;
    
    %========== Slide 1 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' In armature-controlled DC motors, the applied voltage Va controls'
        ' the angular velocity w of the shaft.'
        ' '
        ' This demo shows two techniques for reducing the sensitivity of w'
        ' to load variations (changes in the torque opposed by the motor'
        ' load).'
    };
    
    
    %========== Slide 2 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' A simplified model of the DC motor is shown above. The torque Td'
        ' models load disturbances. You must minimize the speed variations'
        ' induced by such disturbances.'
        ' '
        ' For this example, the physical constants are:'
        '    R = 2.0;                % Ohms'
        '    L = 0.5;                % Henrys'
        '    Km = Kb = 0.1;      % torque and back emf constants'
        '    Kf = 0.2;               % Nms'
        '    J = 0.02;               % kg.m^2/s^2'
    };
    
    %========== Slide 3 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' First construct a state-space model of the DC motor with'
        ' two inputs (Va,Td) and one output (w):'
        ' '
        ' >> h1 = tf(Km,[L R]);                      % armature'
        ' >> h2 = tf(1,[J Kf]);                        % eqn of motion'
        ' '
        ' >> dcm = ss(h2) * [h1 , 1];              % w = h2 * (h1*Va + Td)'
        ' >> dcm = feedback(dcm,Kb,1,1);    % close back emf loop'
        ' '
        ' Note: Compute with the state-space form to minimize the model order.'
    };
    
    %========== Slide 4 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Plot the angular velocity response to a step change in voltage Va:'
        ' '
        ' >> step(dcm(1))'
        ' '
        ' Right-click on the plot and select "Characteristics:Settling Time"'
        ' to display the settling time.'
    };
    
    %========== Slide 5 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' You can use this simple feedforward control structure to command'
        ' the angular velocity w to a given value w_ref. '
        ' '
        ' The feedforward gain Kff should be set to the reciprocal of the'
        ' DC gain from Va to w'
        ' '
        ' >> Kff = 1/dcgain(dcm(1))'
        ' '
        ' Kff ='
        '             4.1000'
    };
    
    %========== Slide 6 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' To evaluate the feedforward design in the face of load'
        ' disturbances, simulate the response to a step command w_ref=1'
        ' with a disturbance Td = -0.1Nm  between t=5 and t=10 seconds:'
        ' '
        ' >> t = 0:0.1:15;'
        ' >> Td = -0.1 * (t>5 & t<10);       % load disturbance'
        ' >> u = [ones(size(t)) ; Td];          % w_ref=1 and Td'
        ' '
        ' >> cl_ff = dcm * diag([Kff,1]);       % add feedforward gain'
        ' >> lsim(cl_ff,u,t)'
    };
    
    %========== Slide 7 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Clearly feedforward control handles load disturbances poorly.'
        ' Next try the feedback control structure shown above. '
        ' '
        ' To enforce zero steady-state error, use integral control of'
        ' the form'
        ' '
        '       C(s) = K/s'
        ' '
        ' where K is to be determined.'
    };
    
    %========== Slide 8 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' To determine the gain K, you can use the root locus technique'
        ' applied to the open-loop  1/s * transfer(Va->w): '
        ' '
        ' >> rlocus(tf(1,[1 0]) * dcm(1))'
        ' '
        ' Click on the curves to read the gain values and related info.'
        ' A reasonable choice here is K = 5.  Note that the SISO Design'
        ' Tool offers an integrated GUI to perform such designs '
        ' (help sisotool for details).'
    };
    
    %========== Slide 9 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Compare this new design with the initial feedforward design'
        ' on the same test case:'
        ' '
        ' >> K = 5;'
        ' >> C = tf(K,[1 0]);            % compensator K/s'
        ' '
        ' >> cl_rloc = feedback(dcm * append(C,1),1,1,1);'
        ' >> lsim(cl_ff,cl_rloc,u,t)'
        ' '
        ' The root locus design is better at rejecting load disturbances.'
    };
    
    %========== Slide 10 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' To further improve performance, try designing a linear quadratic'
        ' regulator (LQR) for the feedback structure shown above.  '
        ' '
        ' In addition to the integral of error, the LQR scheme also uses the'
        ' state vector x=(i,w) to synthesize the driving voltage Va.  The'
        ' resulting voltage is of the form'
        ' '
        '       Va = K1 * w + K2 * w/s + K3 * i' 
        ' '
        ' where i is the armature current.'
    };
    
    %========== Slide 11 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' For better disturbance rejection, use a cost function that penalizes'
        ' large integral error, e.g., the cost function C shown above.'
        ' '
        ' The optimal LQR gain for this cost function is computed as follows:'
        ' '
        ' >> dc_aug = [1 ; tf(1,[1 0])] * dcm(1);'
        '                                  % add output w/s to DC motor model'
        ' '
        ' >> K_lqr = lqry(dc_aug,[1 0;0 20],0.01);'
    };
    
    %========== Slide 12 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Next derive the closed-loop model for simulation purposes: '
        ' '
        ' >> P = augstate(dcm);                            % inputs:Va,Td  outputs:w,x'
        ' >> C = K_lqr * append(tf(1,[1 0]),1,1);     % compensator including 1/s'
        ' >> OL = P * append(C,1);                       % open loop'
        ' '
        ' >> CL = feedback(OL,eye(3),1:3,1:3);     % close feedback loops'
        ' >> cl_lqr = CL(1,[1 4]);                % extract transfer (w_ref,Td)->w'
    };
    
    %========== Slide 13 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' This plot compares the closed-loop Bode diagrams for the three'
        ' designs'
        ' '
        ' >> bode(cl_ff,cl_rloc,cl_lqr)'
        ' '
        ' Click on the curves to identify the systems or inspect the data.'
    };
    
    %========== Slide 14 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Finally we compare the three designs on our simulation test case:'
        ' '
        ' >> lsim(cl_ff,cl_rloc,cl_lqr,u,t)'
        ' '
        ' Thanks to its additional degrees of freedom, the LQR compensator'
        ' performs best at rejecting load disturbances (among the three'
        ' designs discussed here).'
    };
    
end

%------------------- Local Function

function DrawDCM
% Draws DC motor diagram
axis equal
ax = gca;
set(ax,'visible','off','xlim',[0 25],'ylim',[0 14],'ydir','normal')
y0 = 9;  x0 = 0;
if isunix
    fs = 10;
    fw = 'normal';
else
    fs = 10;
    fw = 'bold';
end
wire('x',x0+[0 2],'y',y0+[0 0],'parent',ax,'arrow',0.5);
sumblock('position',[x0+2.5,y0],'label','-240','labelradius',1.5,...
    'parent',ax,'radius',.5,'fontsize',fs+4,'fontweight',fw);
wire('x',x0+[3 4.5],'y',y0+[0 0],'parent',ax,'arrow',0.5);
sysblock('position',[x0+4.5 y0-2 5 4],'name','Armature',...
    'num','K_m','den','Ls + R',...
    'parent',ax,'fontsize',fs,'fontweight',fw,'facecolor',[1 1 .9]);
wire('x',x0+[9.5 11],'y',y0+[0 0],'parent',ax,'arrow',0.5);
sumblock('position',[x0+11.5,y0],'radius',.5,'label',{},...
    'parent',ax);
wire('x',x0+[11.5 11.5],'y',y0+[2.5 0.5],'parent',ax,'arrow',0.5);
wire('x',x0+[12 13.5],'y',y0+[0 0],'parent',ax,'arrow',0.5);
sysblock('position',[x0+13.5 y0-2 5 4],'name','Load',...
    'num','1','den','Js + K_f',...
    'parent',ax,'fontsize',fs,'fontweight',fw,'facecolor',[1 1 .9]);
wire('x',x0+[18.5 22],'y',y0+[0 0],'parent',ax,'arrow',0.5);
wire('x',x0+[20 20 13],'y',y0+[0 -7 -7],'parent',ax,'arrow',0.5);
sysblock('position',[x0+10 y0-8.5 3 3],'name','K_b',...
    'parent',ax,'fontsize',fs,'fontweight',fw,'facecolor',[1 1 .9]);
wire('x',x0+[10 2.5 2.5],'y',y0+[-7 -7 -0.5],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0 y0],'string','V_a ',...
    'horiz','right','fontsize',fs,'fontweight',fw);
text('parent',ax,'pos',[x0+22 y0],'string',' \omega',...
    'horiz','left','fontsize',fs+4,'fontweight',fw);
text('parent',ax,'pos',[x0+11.5 y0+3],'string','T_d',...
    'vertic','bottom','horiz','center','fontsize',fs,'fontweight',fw);
text('parent',ax,'pos',[x0+4 y0-7.5],'string','V_{emf}',...
    'vertic','top','fontsize',fs,'fontweight',fw);


function DrawFF
% Draws feedforward structure
axis equal
ax = gca;
set(ax,'visible','off','xlim',[0 16],'ylim',[0 10],'ydir','normal')
y0 = 7;  x0 = 0;
if isunix
    fs = 10;
    fw = 'normal';
else
    fs = 10;
    fw = 'bold';
end
wire('x',x0+[0 2],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0 y0],'string','\omega_{ref} ',...
    'horiz','right','fontsize',fs+4,'fontweight',fw);
sysblock('position',[x0+2 y0-1.5 3 3],'name','K_{ff}',...
    'parent',ax,'fontsize',fs,'fontweight',fw,'facecolor',[.8 1 1]);
wire('x',x0+[5 10],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+7 y0+0.5],'string','V_a',...
    'vertic','bottom','horiz','left','fontsize',fs,'fontweight',fw);
sysblock('position',[x0+10 y0-3.5 4 5],'name','DCM',...
    'parent',ax,'fontsize',fs,'fontweight',fw,'facecolor',[1 1 .9]);
wire('x',x0+[8 10],'y',y0-[2 2],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+8 y0-2],'string','T_d ',...
    'horiz','right','fontsize',fs,'fontweight',fw);
wire('x',x0+[14 16],'y',y0-[1 1],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+16 y0-1],'string',' \omega',...
    'horiz','left','fontsize',fs+4,'fontweight',fw);
text('parent',ax,'pos',[x0+8 y0-6],'string','Feedforward Control',...
    'horiz','center','fontweight','bold','fontsize',12);


function DrawRLOC
% Draws root locus feddback structure
axis equal
ax = gca;
set(ax,'visible','off','xlim',[-4 18],'ylim',[-1 9])
y0 = 7;  x0 = 0;
if isunix
    fs = 10;
    fw = 'normal';
else
    fs = 10;
    fw = 'bold';
end
wire('x',x0+[-3 -1],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0-3 y0],'string','\omega_{ref} ',...
    'horiz','right','fontsize',fs+4,'fontweight',fw);
sumblock('position',[x0-0.5 y0],'label',{'+140','-240'},'radius',.5,...
    'LabelRadius',1.5,'fontsize',fs+4);
wire('x',x0+[0 2],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+1 y0+0.5],'string','e',...
    'vertic','bottom','horiz','center','fontsize',fs,'fontweight',fw);
sysblock('position',[x0+2 y0-1.5 3 3],'name','C(s)',...
    'num','K','den','s',...
    'parent',ax,'fontsize',fs,'fontweight',fw,'facecolor',[.8 1 1]);
wire('x',x0+[5 9],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+7 y0+0.5],'string','V_a',...
    'vertic','bottom','horiz','center','fontsize',fs,'fontweight',fw);
sysblock('position',[x0+9 y0-3.5 4 5],'name','DCM',...
    'parent',ax,'fontsize',fs,'fontweight',fw,'facecolor',[1 1 .9]);
wire('x',x0+[7.5 9],'y',y0-[2 2],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+7.5 y0-2],'string','T_d ',...
    'horiz','right','fontsize',fs,'fontweight',fw);
wire('x',x0+[13 17],'y',y0-[1 1],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+17 y0-1],'string',' \omega',...
    'horiz','left','fontsize',fs+4,'fontweight',fw);
wire('x',x0+[15 15 -0.5 -0.5],'y',y0+[-1 -5 -5 -0.5],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+6.5 y0-8],'string','Feedback Control',...
    'horiz','center','fontweight','bold','fontsize',12);


function DrawLQR
% Draws root locus feddback structure
axis equal
ax = gca;
set(ax,'visible','off','xlim',[-4 25],'ylim',[-4 9])
y0 = 7;  x0 = 0;
if isunix
    fs = 10;
    fw = 'normal';
else
    fs = 10;
    fw = 'bold';
end
wire('x',x0+[-3 -1],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0-3 y0],'string','\omega_{ref} ',...
    'horiz','right','fontsize',fs+4,'fontweight',fw);
sumblock('position',[x0-0.5,y0],'label',{'+140','-240'},'radius',.5,...
    'parent',ax,'labelradius',1.5,'fontsize',fs+4);
wire('x',x0+[0 2],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+1 y0+0.5],'string','e',...
    'vertic','bottom','horiz','center','fontsize',fs,'fontweight',fw);
sysblock('position',[x0+2 y0-1.5 2.2 3],'name','',...
    'num','1','den','s',...
    'parent',ax,'fontsize',fs,'fontweight',fw,'facecolor',[1 1 .9]);
wire('x',x0+[4.2 7],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+5.6 y0+0.5],'string','q',...
    'vertic','bottom','horiz','center','fontsize',fs,'fontweight',fw);
sysblock('position',[x0+7 y0-3.5 4 5],'name','K_{lqr}',...
    'parent',ax,'fontsize',fs,'fontweight',fw,'facecolor',[.8 1 1]);
wire('x',x0+[11 15],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+13 y0+0.5],'string','V_a',...
    'vertic','bottom','horiz','center','fontsize',fs,'fontweight',fw);
sysblock('position',[x0+15 y0-3.5 4 5],'name','DCM',...
    'parent',ax,'fontsize',fs,'fontweight',fw,'facecolor',[1 1 .9]);
wire('x',x0+[13.5 15],'y',y0-[2 2],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+13.5 y0-2],'string','T_d ',...
    'horiz','right','fontsize',fs,'fontweight',fw);
wire('x',x0+[19 24],'y',y0+[0 0],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+24 y0],'string',' \omega',...
    'horiz','left','fontsize',fs+4,'fontweight',fw);
wire('x',x0+[19 20.5 20.5 5.5 5.5 7],'y',y0+[-2 -2 -5 -5 -2 -2],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+13 y0-5.5],'string','x=(i,\omega)',...
    'vertic','top','horiz','center','fontsize',fs,'fontweight',fw);
wire('x',x0+[22 22 -0.5 -0.5],'y',y0+[0 -8 -8 -0.5],'parent',ax,'arrow',0.5);
text('parent',ax,'pos',[x0+10 y0-11],'string','LQR Control',...
    'horiz','center','fontweight','bold','fontsize',12);
