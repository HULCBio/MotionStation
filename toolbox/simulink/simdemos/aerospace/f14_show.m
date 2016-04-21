function slide=f14_show
% This is a slideshow file for use with playshow.m and makeshow.m.
% To see it run, type f14 at the MATLAB command prompt.  The example will take
% you through the entire design of a digital autopilot for a high angle of
% attack controller.  The text of this show assumes that you have the Control
% System Toolbox, Simulink, Real Time Workshop, and Stateflow.  
% However the example changes depending on which of these tools you have. 
% Obviously, since this  example illustrates a control system design 
% using MATLAB's object oriented  programming features (and in particular, 
% lti objects), the Control System Toolbox  is a significant part of the
% demonstration.  To obtain a demonstration of the  Control System Toolbox,
% contact your sales agent, or visit the MathWorks web site 
% (www.mathworks.com) and request a demo version of the Control System Toolbox

% Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.4.2.2 $  $Date: 2004/04/13 00:34:42 $

  %========== Slide 1 ==========

  slide(1).code={
   ' load f14pix',
   ' image(rgb),axis off',
   ' title(''Demonstration of F14 Digital Flight Control Design'');' };
  slide(1).text={
   '    Welcome to a demonstration of how the Control System Toolbox can be used'
   'to interact with Simulink to design a digital flight controller for the Navy'
   'F14 aircraft.',
   '',
   '    The controller that will be designed will permit the aircraft to operate'
   'at a high angle of attack.',
   '',
   '    Below this window is the Simulink model of the F14.  The control system'
   'in the block labeled "Controllers" can be switched in the model to allow the'
   'user to see the analog autopilot response and then to switch to a design '
   'created using lti objects.  A controller is also included that emulates the '
   'analog design for implementation in an on-board computer.  Take a few moments'
   'to explore this model.'};

  %========== Slide 2 ==========

  slide(2).code={
   'xptext( ''>> f14dat'' );',
   'f14dat' };
  slide(2).text={
   '    First, let''s load the necessary data that will allow the model to run.'
   'In the MATLAB command window you will see that the data needed has been loaded '
   'using the command shown in the window above.  Use "who" or "whos" to see the data.',
   '',
   '    (During most of this demo, we will display the MATLAB commands you should '
   'type in the figure window above.)',
   '',
   '    Also, this demo opens some Simulink models, so you will be clicking back '
   'and forth between the appropriate model window and this window as we proceed.'};

  %========== Slide 3 ==========

  slide(3).code={
   'xptext(''>> f14autopilot'' , ''>> io = getlinio(''''f14autopilot'''');'', ''>> op = operpoint(''''f14autopilot'''');'', ''>> contap = linearize(''''f14autopilot'''',op,io);'');',
   'f14autopilot' };
  slide(3).text={
   '    The commands above open the Simulink f14 autopilot model and find its '
   'linearization.',
   '',
   '    The model can also be linearized in Control and Estimation Tools Manager'
   'launched from f14autopilot Simulink model.  Under "Tools", select the '
   '"Control Design >> Linear Analysis" option.',
   '',
   '    When the Control and Estimation Tools Manager opens, click the Linearize'
   'Model button.  A LTI Viewer be created showing a step plot of the '
   'linearization.  To browse around the LTI Viewer, right click on the graph '
   'window to see your options.',
   '',
   '    For help type "help slcontrol" or "help ltiview" or look at the Control'
   'System Toolbox/Simulink Control Design documentation.'};

  %========== Slide 4 ==========

  slide(4).code={
   'xptext(''>> contap = tf(contap)'',''>> contap=zpk(contap)'');' };
  slide(4).text={
   '   There are three types of lti objects that one can use to develop a linear'
   'model.  These are:',
   '',
   '   State Space (SS), Transfer Function (TF), and Zero,Pole Gain (ZPG) objects.',
   '',
   '   The variable contap is a State Space object.  You can then get one of the'
   'other types with the other commands.  When you create the object in MATLAB, '
   'you can manipulate it using operations like *, +, -, etc.  This is called '
   '"overloading" the MATLAB operators.  Try creating an object of your own and '
   'see what happens when adding, multiplying, etc. with the contap object.',
   '',
   '   To see exactly what is stored in the lti object, type "get(contap)" or '
   '"contap.InputName" for example.'};

  %========== Slide 5 ==========

  slide(5).code={
   'xptext(''>> discap = c2d(contap,0.1,''''zoh'''')'');' };
  slide(5).text={
   ['   Now that you understand what an lti object is, we will use it to design ',...
    'the digital autopilot that will replace the analog autopilot we just ',...
    'explored.  The analog system is coded into the lti object called "contap"',...
    '(for continuous autopliot).'],
   '',
   ['   Our first attempt at converting this to a digital autopilot will use a zero order hold',...
   'with a sample time of 0.1 seconds.  In the Control System Toolbox, the command that',...
   'does the conversion is c2d (for continuous to discrete).  This command recognizes objects',...
   '(is overloaded) so you only need to type the command shown in the window above.'],
   '',
   '   Go to the command window and try it for different object types.',
   ' ',
   ['   Note that the discrete object maintains the type (ss, tf or zpk). ',...
   'To see exactly what is stored in the new discrete lti object, type "get(discap)"']};

  %========== Slide 6 ==========

  slide(6).code={
   'xptext(''>> bode(contap,discap)'');' };
  slide(6).text={
   '   Let''s now compare the design of the digital autopilot with the continuous'
   'autopilot.  We will get a bode plot of the two systems overplotted using the'
   'command above.',
   '',
   '   It should be clear that the systems do not match in phase from 3 rad/sec'
   'to the half sample frequency (the vertical black line) for the pilot stick '
   'input and the angle of attack sensor.  We should see that this design has '
   'poorer response than the analog system.  Go to the Simulink model and start'
   'the simulation (make sure you can see the scope windows).  While the '
   'simulation is running, "throw" the switch labeled "Analog or Digital".  '
   'Throw the switch by double clicking.  Note how the switch icon changes when'
   'it is thrown.',
   '',
   '   Does the simulation verify the conclusion we came to?'};

  %========== Slide 7 ==========

  slide(7).code={
   'xptext(''>> discap1 = c2d(contap,0.1,''''tustin'''')'',''>> bode(contap,discap,discap1)'');' };
  slide(7).text={
   '   Now try different conversion techniques.  Use the "Tustin" transformation.',
   'In the command window type the commands above.',
   '',
   '   It should be clear that the systems still do not match in phase from 3 '
   'rad/sec to the half sample frequency, however the use of the Tustin '
   'transformation is better.  The simulation uses the lti object as it is designed.'
   'To see how the object is used look in the Controllers subsystem by using the'
   'browser or by double clicking the icon.  The lti object is simply a block that'
   'picks up the name of the object form the workspace.  You can change the name '
   'used in the object block to any workspace object.  Try using "discap1".'};

  %========== Slide 8 ==========

  slide(8).code={
   'xptext(''>> discap = c2d(contap,0.05,''''tustin'''')'',''>> bode(contap,discap)'');' };
  slide(8).text={
   '   We know the tustin is better than the zero order hold from the analysis so '
   'far.  We also suspect that the sample time of 0.1 second is too slow.  So let''s'
   'design the autopilot using 0.05 seconds and the tustin transform.  Use the '
   'commands shown above.',
   '',
   '   Make sure you are using the discap object in the lti block in the Controllers'
   'subsystem (check by double clicking on the lti block), and simulate the new design.'
   'Verify that the discrete and continuous designs are essentially the same.'};

  %========== Slide 9 ==========

  slide(9).code={
   ' image(rgb),axis off',
   ' title(''Demonstration of F14 Digital Flight Control Design'');' };
  slide(9).text={
   '   Now that we have a design, we need to implement it in a form that will'
   'include some of the effects that were left out in the linear analysis.  For'
   'example, if you look at the analog autopilot that is in the Controllers '
   'subsystem, you will see a Stateflow block (if you have Stateflow) that stops'
   'the integrator from winding up when the actuator saturates.  It might be '
   'worthwhile to look at how this has been done.',
   '',
   '   Open up the Analog Control subsystem (in Controllers) and then open the '
   'Stateflow model.  The state diagram has two states corresponding to the '
   'integrator stopped and the integrator working properly.  The output of the '
   'states is used to multiply the input of the integrator back in the Simulink block.'};

  %========== Slide 10 ==========

  slide(10).code={
};
  slide(10).text={
     '   The integrator wind-up is one of the practical issues that needs to be '
     'addressed.  Another is the need to eliminate aliased high frequency signals'
     'that will enter at the mesurement points.  These high frequency aliased '
     'signals can be removed by the filters in the autopilot if the filters operate'
     'at a higher sample frequency.  Realizing this, the analog autopilot has been'
     'redone using digital filters and a Stateflow model in the Controllers '
     'subsystem.'
     '',
     '   This new controller is called "DAP Implementation".  Open this model and '
     'browse around.  The filters have a sample time of deltat1 (set to be 1/10 of'
     'deltat).  The zero order holds force these sample times on the various blocks.'};

  %========== Slide 11 ==========

  slide(11).code={
};
  slide(11).text={
   '   The switches in the f14 model are set up so you can switch between the '
   'analog autopilot, the digital lti object and the implementable digital autopilot.',
   '',
   ['   Try simulating the system again and switch among the three autopliot designs. ',...
    'You should see that the designs are not affected by which of the autopilots you use. ',...
    'You can also increase the amplitude of the wind gust and verify that',...
    'the anti-aliasing is working satisfactorily.  To increase the gust amplitude, ',...
    'open the Dryden Wind Gust subsystem and change (by double clicking on the icon) the ',...
    'noise variance of the White Noise that drives the gust simulation.']};

  %========== Slide 12 ==========

  slide(12).code={
   'xptext( ''f14actuator'' );',
   'f14actuator' };
  slide(12).text={
   '    The actuators in the Simulink model use a feature of Simulink called '
   '"Configurable Subsystems" to access a library of actuators.  This library '
   'was opened by the command shown in the window above.',
   '',
   '    To make the simulation change, use the nonlinear actuator instead of the '
   'linear one, double click on the actuator block in the f14 model, and follow the'
   'instructions',
   '',
   '    Note that Simulink must be stopped in order to change the actuator.  You '
   'should also note that the nonlinear actuator has saturations on position and'
   'rate.'};

  %========== Slide 13 ==========
  
  slide(13).code={
     'f14_dap'
     'load f14_dap'
     'plot(rt_tout,rt_yout)'};
  
  slide(13).text={
     '   The autopilot design can be converted to embedded code using Real Time'
     'Workshop, the automatic coding tool for Simulink models.  A separate model'
     'of the digital autopilot, called f14_dap, is open below; it can be coded '
     'using Real Time Workshop (if you have this option).'
     '',
     '   Start the coding by selecting the Tools option on the menu bar.  Under'
     '"Tools", select the "Real Time Workshop" >> "Options".  The dialog box that opens '
     'allows the selection of the target, and the code to be build (use the'
     'Build button).  The default creates an executable file that will run on '
     'your machine.'
     '',
     '   This file, f14_dap.exe, can be run from DOS or from MATLAB by typing '
     '!f14_dap.  The run creates a file called f14_dap.mat that can be loaded '
     'by typing load f14_dap.  '
     '',
     '   Two variables called rt_tout and rt_yout will be in the workspace and '
     'they can be plotted.  The result should look like the graph above.'
     };
  %========== Slide 14 ==========

slide(14).code={
   'image(rgb),axis off'
   'title(''End of F14 Digital Autopilot Demonstration'');'
};
  slide(14).text={
   '   We have come to the end of the f14 control design using the Control System'
   'Toolbox, Simulink Control Design, Simulink, and Stateflow.'};










