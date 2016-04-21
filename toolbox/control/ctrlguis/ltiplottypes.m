function defs = ltiplottypes(str)
%LTIPLOTTYPES  Return information about built-in LTI plot types.
%
%   NAMES = LTIPLOTTYPES('Name') returns the list of built-in LTI 
%   plot names.
%
%   ALIASES = LTIPLOTTYPES('Alias') returns the list of aliases used
%   to identify built-in LTI plot.

%   Author(s): Kamesh Subbarao
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/04 15:22:41 $

switch str
case 'Alias'
   defs = ...
    {'step';
    'impulse';
    'lsim';
    'initial';
    'bode';
    'bodemag';
    'nyquist';
    'nichols';
    'sigma';
    'pzmap';
    'iopzmap'};
 
case 'Name'
   defs = ...
    {xlate('Step');
     xlate('Impulse');
     xlate('Linear Simulation');
     xlate('Initial Condition');
     xlate('Bode');
     xlate('Bode Magnitude');
     xlate('Nyquist');
     xlate('Nichols');
     xlate('Singular Value');
     xlate('Pole/Zero');
     xlate('I/O Pole/Zero')};
end
