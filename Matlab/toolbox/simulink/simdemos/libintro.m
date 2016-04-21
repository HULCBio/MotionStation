%LIBINTRO A quick introduction to the Simulink Libraries.

%   Ned Gulley, 6-21-93
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 5.8 $

% Demo initialization ====================
if ~exist('SlideShowGUIFlag'), figNumber=0; end;

if ssinit(figNumber),
  str= ...                                                        
    ['                                                       '  
     ' Press the "Start" button to see a demonstration of the'  
     ' main block diagram libraries in Simulink.             '];
  ssdisp(figNumber,str);                                          
  if figNumber, return; end
end

% Beginning of the demo ==================

sys='simulink';
eval(sys);

str= ...                                                        
  ['                                                       '  
   ' This is the main Simulink block library. It opens when'  
   ' you type the word "simulink" at the command prompt.   '  
   '                                                       '  
   ' In it are the major block diagram components you will '  
   ' use when you create a Simulink system.                '];
ssdisp(figNumber,str);                                          

if sspause(figNumber), return; end;

str= ...                                                              
  ['                                                             '  
   ' Inside each of the grouped, or composite, blocks across     '  
   ' the "simulink" window are the major block sub-libraries:    '  
   ' Sources, Sinks, Discrete, Linear, Nonlinear, Connections,   '  
   ' and Extras.                                                 '  
   '                                                             '  
   ' A grouped block is simply a block that contains             '  
   ' other blocks inside it. You can see the contents of a       '  
   ' grouped block by double-clicking on it. Try opening up      '  
   ' the system called "Sources" to see what is inside.          '  
   '                                                             '  
   ' Click the "Next" button on the right side of this window    '  
   ' when you are ready to continue.                             '];
ssdisp(figNumber,str);                                                

if sspause(figNumber), return; end;

if exist(sys)==4,
  close_system(sys,0);
end;

sys='sources';
eval(sys);

str= ...                                                            
  ['                                                           '  
   ' Now we will open up a demonstration of each major         '  
   ' library, in turn.                                         '  
   '                                                           '  
   ' During this slide show presentation, you will see the     '  
   ' Simulink systems that demonstrate each library. If you    '  
   ' want to actually run these Simulink demos, you should     '  
   ' stop the slide show by pressing the "Stop" button to the  '  
   ' right. Once you have stopped the slide show, however, you '  
   ' will have to reset it and start again to continue.        '  
   '                                                           '  
   ' For example, these are the blocks of the Sources library. '  
   ' To run the Simulink system called "sources", press the    '  
   ' "Stop" button on this window. Then you can open up some   '  
   ' of the scope blocks and run the system by selecting       '  
   ' "Start" under the "Simulation" menu. End the simulation by'  
   ' selecting "Stop" under the same menu.                     '  
   '                                                           '  
   ' The blocks in the Sources library allow you to generate   '  
   ' a wide variety of signals for use in your simulation.     '];
ssdisp(figNumber,str);                                              

if sspause(figNumber), return; end;

if exist(sys)==4,
  close_system(sys,0);
end;

sys='sinks';
eval(sys);

str= ...                                                              
  ['                                                             '  
   ' The blocks in the Sinks library are useful for storing and  '  
   ' displaying signals as they are generated. The Scope         '  
   ' block in particular is one of the most valuable blocks      '  
   ' in Simulink. It provides the crucial and immediate          '  
   ' feedback necessary to keep a simulation on track.           '];
ssdisp(figNumber,str);                                                

if sspause(figNumber), return; end;

if exist(sys)==4,
  close_system(sys,0);
end;

sys='discrete';
eval(sys);

str= ...                                                         
  ['                                                        '  
   ' The Discrete library contains the blocks used for      '  
   ' simulating discrete systems such as digital controllers'  
   ' or digital signal processing filters.                  '];
ssdisp(figNumber,str);                                           

if sspause(figNumber), return; end;

if exist(sys)==4,
  close_system(sys,0);
end;

sys='linear';
eval(sys);

str= ...                                                              
  ['                                                             '  
   ' The Linear library contains some of the most frequently     '  
   ' used blocks, such as the Gain and Summation blocks.         '  
   '                                                             '  
   ' Also in this library is the all-important integration block.'  
   ' The Transfer Function, Zero-Pole, and State-Space           '  
   ' blocks all perform integration internally as well.          '];
ssdisp(figNumber,str);                                                

if sspause(figNumber), return; end;

if exist(sys)==4,
  close_system(sys,0);
end;

sys='nonlin';
eval(sys);

str= ...                                                             
  ['                                                            '  
   ' The blocks found in the Nonlinear library contribute       '  
   ' largely to the power of Simulink. With these blocks        '  
   ' you can simulate the complex nonlinear effects (such as    '  
   ' backlash and saturation) that put purely linear simulations'  
   ' to shame.                                                  '];
ssdisp(figNumber,str);                                               

if sspause(figNumber), return; end;

if exist(sys)==4,
  close_system(sys,0);
end;

% End of the demo ========================

