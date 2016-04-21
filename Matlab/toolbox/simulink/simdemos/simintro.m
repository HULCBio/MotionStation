%SIMINTRO A quick introduction to Simulink.

%   Ned Gulley, 6-21-93
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 5.17 $

% Demo initialization ====================
if ~exist('SlideShowGUIFlag'), figNumber=0; end;

if ssinit(figNumber),
  str= ...                                                        
  ['                                                       '  
   ' Press the "Start" button to see a demonstration of how'  
   ' to build and simulate a simple model in Simulink.     '];
  ssdisp(figNumber,str);                                          
  if figNumber, return; end
end

% Beginning of the demo ==================

% ====== Start of Demo

sys='Untitled';
if exist(sys)==4,
  close_system(sys,0);
end;
new_system(sys);
set_param(sys,'Location',[100,100,350,300]);
open_system(sys)
set_param(sys, ...
  'Algorithm',        'FixedStepDiscrete', ...
  'StartTime',        '0.0', ...
  'StopTime',         '10000.', ...
  'MaxStep',          '0.01', ...
  'FixedStep',        '0.01', ...
  'RelTol',           '1e-3', ...
  'SaveTime',         'off',...
  'SaveState',        'off',...
  'SaveOutput',       'off')

str= ...                                                      
  ['                                                       '
   ' This is a demonstration of how to build a simple model'  
   ' using Simulink. We''ll build a model that routes       '  
   ' the output of a Sine Wave Generator to a Scope        '  
   ' block. First we open a new system using the "New..."  '  
   ' option from the Simulink "File" pull-down menu. The   '  
   ' name of this system is "Untitled".                    '];
ssdisp(figNumber,str);                                        

if sspause(figNumber), return; end;

str= ...                                                          
  ['                                                         '  
   ' We will start off with a Sine Wave Generator block      '  
   ' from the "Sources" library. This is one of several block'  
   ' libraries in the main library that appears when you     '  
   ' type "simulink" at the command prompt.                  '];
ssdisp(figNumber,str);                                            

add_block('built-in/Sine Wave',[sys,'/','Sine Wave'])
set_param( ...
  [sys,'/','Sine Wave'],...
  'position',[70,70,90,90])

if sspause(figNumber), return; end;

str= ...                                                          
  ['                                                         '  
   ' Now we drag in a Scope Block from the "Sources" library '  
   ' so we can see the progress of the simulation as it runs.'];
ssdisp(figNumber,str);                                            

if sspause(figNumber), return; end;

add_block('built-in/Scope',[sys,'/','Scope'])
set_param([sys,'/','Scope'],...
  'Vmax','6.000000',...
  'Hmax','40.000000',...
  'position',[170,67,190,93],...
  'Window',[350,100,600,300]);

str= ...                                                       
  ['                                                      '  
   ' The model is nearly complete; it only remains to     '  
   ' draw a line connecting the output of the Sine Wave   '  
   ' Generator to the input of the Scope block.           '];
ssdisp(figNumber,str);                                         

if sspause(figNumber), return; end;

add_line(sys,[95,80;160,80]);

str= ...                                                    
  ['                                                   '  
   ' The model is now complete. Now we can pop open the'  
   ' Scope block and watch the simulation.             '];
ssdisp(figNumber,str);                                      

if sspause(figNumber), return; end;

open_system([sys,'/','Scope'])

str= ...                                                         
  ['                                                        '  
   ' Now we''re ready to run the simulation. Of course, we''re'  
   ' not simulating much here, just re-routing the output of'  
   ' a Sine Wave Generator, so we''ll run it for only 40     '  
   ' seconds of simulated time.                             '];
ssdisp(figNumber,str);                                           

if sspause(figNumber), return; end;

options=simset('solver','FixedStepDiscrete','FixedStep',0.01);
[t,x,y]=sim(sys,39,options);

str= ...                                                              
  ['                                                             '  
   ' For good measure, before we''re done we can double the       '  
   ' frequency of the Sine Wave Generator in order to verify     '  
   ' everything is working properly.                             '  
   '                                                             '  
   ' This would normally be done by double-clicking on the Sine  '  
   ' Wave Generator and replacing the number 1 with 2 in the     '  
   ' frequency text field. Here we are changing it automatically.'];
ssdisp(figNumber,str);                                                

if sspause(figNumber), return; end;

set_param([sys,'/','Sine Wave'], ...
  'frequency','2');

[t,x,y]=sim(sys,39,options);

if sspause(figNumber), return; end;

if exist(sys)==4,
  close_system(sys,0);
end;

% End of the demo ========================
