function slide = jetdemo(slidenum)
%JETDEMO  Yaw damper design for 747 jet aircraft.
%
%   This demo steps through the design of a YAW DAMPER for a 
%   747 aircraft using the classical control design features 
%   in the Control System Toolbox.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.23 $  $Date: 2002/04/10 06:41:17 $

persistent sys sys11 k cloop H

if nargin
    %---Slide code
    cla, legend off
    switch slidenum
    case 1
        % 747 picture
        set(gca,'Position',[0.035 0.415 0.725 0.54])
        [x,map] = imread('b747','jpg');
        image(x), colormap(map); 
        set(gca,'visible','off')
    case 2
        % Display equation
        set(gca,'Position',[0.085+.015 0.49 0.65-.015 0.45])
        axis normal
        set(gca,'xlim',[0 1],'ylim',[0 1],'vis','off','ydir','normal')
        text(0,.85,'Trim model (state space):','fontweight','bold','fontsize',14);
        equation('position',[.5 .55],'name','dx/dt','num','A x + B u',...
            'Anchor','rcenter','fontweight','bold','fontsize',14);
        equation('position',[.5 .3],'name','y','num','C x + D u',...
            'Anchor','rcenter','fontweight','bold','fontsize',14);
    case 3
        axis(gca,'normal');
        set(gca,'Position',[0.085+.015 0.49 0.65-.015 0.45])
        set(gca,'xlim',[0 1],'ylim',[0 1],'vis','off','ydir','normal')
        text(0,.5,'A, B, C, D','fontweight','bold','fontsize',12);
        wire('x',[.25,.45],'y',[.5 .5],'linewidth',2,'arrow',0.05,'color','r');
        text(.3,.6,'ss(..)','fontweight','bold','fontangle','italic','fontsize',10,'color','r');
        equation('position',[.8 .6],'name','dx/dt','num','A x + B u',...
            'Anchor','rcenter','fontweight','bold','fontsize',12);
        equation('position',[.8 .4],'name','y ','num','C x + D u',...
            'Anchor','rcenter','fontweight','bold','fontsize',12);
        % Data
        A=[-.0558 -.9968 .0802 .0415;
            .598 -.115 -.0318 0;
            -3.05 .388 -.4650 0;
            0 0.0805 1 0];
        B=[.00729  0;
            -0.475   0.00775;
            0.153   0.143;
            0      0];
        C=[0 1 0 0;
            0 0 0 1];
        D=[0 0;
            0 0];
        states={'beta' 'yaw' 'roll' 'phi'};
        inputs={'rudder' 'aileron'};
        outputs={'yaw rate' 'bank angle'};
        sys = ss(A,B,C,D,'statename',states,'inputname',inputs,'outputname',outputs);
    case 4
        axis(gca,'normal')
        pzmap(sys)
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto','Grid','off');
        set(h,'FrequencyUnits','rad/sec');
    case 5
        impulse(sys)
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto','Grid','off');
    case 6
        impulse(sys,20)
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto','Grid','off');
    case 7
        sys11 = sys('yaw','rudder');
        bode(sys11)
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto','Grid','off','Xunits','rad/sec');
        set(h.AxesGrid,'Yunits',{'dB';'deg'},'Grid','off','Xscale','log');

    case 8
        rlocus(sys11)
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto','Grid','off');
        set(h,'FrequencyUnits','rad/sec');
    case 9
        rlocus(-sys11)
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto','Grid','off');
        set(h,'FrequencyUnits','rad/sec');
    case 10
        k = 2.85;
        cl11 = feedback(sys11,-k);
        impulse(sys11,'b--',cl11,'r',20)
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto','Grid','off');
        legend('open loop','closed loop',4)
    case 11
        k = 2.85;
        cloop = feedback(sys,-k,1,1);
        impulse(sys,'b--',cloop,'r',20) 
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto','Grid','off');
    case 12
        axis(gca,'normal');
        k = 2.85;
        cloop = feedback(sys,-k,1,1);
        impulse(cloop('bank','aileron'),'r',18)
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto','Grid','off');
    case 13
        axis(gca,'normal');
        set(gca,'Position',[0.085+.015 0.49 0.65-.015 0.45])
        set(gca,'xlim',[0 1],'ylim',[0 1],'vis','off','ydir','normal')        
        text(0,.85,'Washout Filter:','fontweight','bold','fontsize',14);
        equation('position',[.5 .55],'name','H(s)','num','k s','den','s + a',...
            'Anchor','rcenter','fontweight','bold','fontsize',14);
    case 14
        axis(gca,'normal');
        H = zpk(0,-0.2,1);
        oloop = H * (-sys11);
        rlocus(oloop)
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto','Grid','on');
        set(h,'FrequencyUnits','rad/sec');
    case 15
        k = 2.34;
        wof = -k * H;   
        cloop = feedback(sys,wof,1,1);
        impulse(sys,'b--',cloop,'r',20)
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto','Grid','off');
    case 16
        impulse(sys(2,2),'b--',cloop(2,2),'r',20)
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto','Grid','off');
        legend('open loop','closed loop',4)
    end
    
    
elseif nargout<1
    %---Start demo
    fg = playshow(mfilename);
    set(fg,'Name','Yaw Rate Control Demo','doublebuffer','on');
    
    
else
    %---Construct slides
    slidenum = 0;
    
    %========== Slide 0 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Press "Start" to step through the design of a "yaw damper" for this 747 jet '
        ' aircraft.  '
        ' '
        ' For more details about this design, refer to "Case Studies" in the on-line'
        ' Help for the Control System Toolbox.'
    };    
    
    %========== Slide 1 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' A simplified trim model of the aircraft during cruise flight has'
        ' four states:'
        ' '
        '      beta (sideslip angle), phi (bank angle), yaw rate, roll rate'
        ' '
        ' and two inputs: the rudder and aileron deflections. '
        ' '
        ' All angles and angular velocities in radians and radians/sec.'
    };    
    
    %========== Slide 2 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Given the matrices A,B,C,D of the trim model, use the SS command to'
        ' create the state-space model in MATLAB:'
        ' '
        ' >> sys = ss(A,B,C,D)'
        ' '
        ' and label the inputs, outputs, and states:'
        ' '
        ' >> set(sys, ''inputname'', {''rudder'' ''aileron''},...'
        '                   ''outputname'', {''yaw rate'' ''bank angle''},...'
        '                   ''statename'', {''beta'' ''yaw'' ''roll'' ''phi''})'
    };
    
    %========== Slide 3 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' This model has a pair of lightly damped poles.  They correspond to what'
        ' is called the Dutch roll mode.  To see these modes, type'
        ' '
        ' >> pzmap(sys)'
        ' '
        ' Right-click and select "Grid" to plot the damping and natural frequency'
        ' values.  You need to design a compensator that increases the damping'
        ' of these two poles.'
    };
    
    %========== Slide 4 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Start with some open loop analysis to determine possible control'
        ' strategies.  The presence of lightly damped modes is confirmed by '
        ' looking at the impulse response:'
        ' '
        ' >> impulse(sys)'
        ' '
        ' To inspect the response over a smaller time frame of 20 seconds, you'
        ' could also type'
        ' '
        ' >> impulse(sys,20)'
    };
    
    %========== Slide 5 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Look at the plot from aileron to bank angle phi.  To show only this'
        ' plot, right-click and choose "I/O Selector", then click on the (2,2) '
        ' entry.'
        ' '
        ' This plot shows the aircraft oscillating around a non-zero bank angle.'
        ' Thus the aircraft turns in response to an aileron impulse.  This '
        ' behavior will be important later.'
    };
    
    %========== Slide 6 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Typically yaw dampers are designed using yaw rate as the sensed output'
        ' and rudder as the input.  Inspect the frequency response for this I/O'
        ' pair:'
        ' '
        ' >> sys11 = sys(''yaw'',''rudder'')    % select I/O pair'
        ' >> bode(sys11)'
        ' ' 
        ' This plot shows that the rudder has a lot of authority around the ' 
        ' lightly damped Dutch roll mode (1 rad/sec).'
    };
    
    %========== Slide 7 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' A reasonable design objective is to provide a damping ratio zeta > 0.35,'
        ' with natural frequency Wn < 1.0 rad/sec.  The simplest compensator is a '
        ' gain.  Use the root locus technique to select an adequate feedback gain '
        ' value:'
        ' '
        ' >> rlocus(sys11)'
    };
    
    %========== Slide 8 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Oops, looks like we need positive feedback!'
        ' '
        ' >> rlocus(-sys11)'
        ' '
        ' This looks better.  Click on the blue curve and move the black square to'
        ' track the gain and damping values.  The best achievable closed-loop'
        ' damping is about 0.45 for a gain of K=2.85'
    };
    
    %========== Slide 9 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Now close this SISO feedback loop and look at the impulse response'
        ' '
        ' >> k = 2.85'
        ' >> cl11 = feedback(sys11,-k)'
        '                % Note: feedback assumes negative feedback by default'
        ' '
        ' >> impulse(sys11,''b--'',cl11,''r'')'
        ' '
        ' The response looks pretty good.'
    };
    
    %========== Slide 10 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Now close the loop around the full MIMO model and see how the response'
        ' from the aileron looks.  The feedback loop involves input 1 and output 1 of'
        ' the plant:'
        ' '
        ' >> cloop = feedback(sys,-k,1,1)'
        ' >> impulse(sys,''b--'',cloop,''r'',20)           % MIMO impulse response'
        ' '
        ' The yaw rate response is now well damped. '
    };
    
    %========== Slide 11 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' When moving the aileron, however, the system no longer continues to'
        ' bank like a normal aircraft, as seen from'
        ' '
        ' >> impulse(cloop(''bank'',''aileron'')'
        ' '
        ' You have over-stabilized the spiral mode.  The spiral mode is typically a'
        ' very slow mode that allows the aircraft to bank and turn without constant'
        ' aileron input.  Pilots are used to this behavior and will not like a design'
        ' that does not fly normally.'
    };
        
    %========== Slide 12 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' You need to make sure that the spiral mode doesn''t move farther into the'
        ' left-half plane when we close the loop.  One way flight control designers'
        ' have fixed this problem is by using a washout filter.'
        ' '
        ' Using the SISO Design Tool (help sisotool), you can graphically tune the'
        ' parameters k and a to find the best combination.  In this demo we choose'
        ' a = 0.2 or a time constant of 5 seconds.'
    };
        
    %========== Slide 13 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Form the washout filter for a=0.2 and k=1'
        ' '
        ' >> H = zpk(0,-0.2,1)'
        ' '
        ' connect the washout in series with your design model, and use the root'
        ' locus to determine the filter gain k:'
        ' '
        ' >> oloop = H * (-sys11)          % open loop'
        ' >> rlocus(oloop)'
        ' >> sgrid'
    };
    
    %========== Slide 14 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' The best damping is now about zeta = 0.305 for k=2.07.  Close the loop'
        ' with the MIMO model and check the impulse response:'
        ' '
        ' >> wof = -k * H            % washout compensator'
        ' >> cloop = feedback(sys,wof,1,1)'
        ' >> impulse(sys,''b--'',cloop,''r'',20)'
    };
    
    %========== Slide 15 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' The washout filter has also restored the normal bank-and-turn behavior'
        ' as seen by looking at the impulse response from aileron to bank angle.'
        ' '
        ' Although it doesn''t quite meet the requirements, this design substantially'
        ' increases the damping while allowing the pilot to fly the aircraft normally.'
    };
end 
