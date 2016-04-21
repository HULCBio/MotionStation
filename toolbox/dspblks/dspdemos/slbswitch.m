function [x,y,str] = slbswitch(command)
%SLBSWITCH Binary Switch helper function for Simulink.

% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.2 $ $Date: 2002/05/07 14:21:46 $

blk = gcbh;
mdl = bdroot(blk);
dirty = get_param(mdl,'dirty');
state = get_param(blk,'state');
x=[]; y=[]; str='';

if nargin>0,
  switch lower(command)
   case 'open'
    if strcmp(get_param(mdl,'BlockDiagramType'),'library') & ...
          strcmp(get_param(mdl,'Lock'),'on'),
      errordlg(['Boolean Switch block must be placed in a model or ' ...
                'unlocked library in order to operate.'])
    else
      set_param(blk,'dblClick','1');
      set_param(mdl,'dirty',dirty);
    end
    return
   case 'init'
    % Initialize value of constant block:
    set_const_blk_state(blk, state);
      
  end
end

doubleClick = (get_param(blk,'dblClick') == '1');

% --- toggle state:
%
% The block's open function (double click on block) sets
% action='1', and we only toggle state if that occurs.
% Reset it to '0' whenever that happens.
if doubleClick,
  set_param(blk,'dblClick','0'); % Reset dblClick flag
  if state=='1',                 % Toggle state
     state='0';
  else
     state='1';
  end
  set_param(blk,'state',state);   % Store new state
  
  % Change value of constant block:
  set_const_blk_state(blk, state);
end

% --- setup icon:
% If block is in '1' state, show "falling edge" as next transition
% and vice-versa.
x = [0 NaN 100 NaN 20 50 50 80 NaN 40 50 60];
str = state;
if state=='1',
    y = [0 NaN 100 NaN 90 90 10 10 NaN 60 40 60];  % falling
else
    y = [0 NaN 100 NaN 10 10 90 90 NaN 40 60 40];  % rising
end

% --- restore the dirty flag:
set_param(mdl,'dirty',dirty);


% ----------------------------------------------------------------
function set_const_blk_state(blk, state)
% set_const_blk_state(blk, state)
%   Function to set the output parameter field for the Constant
%   block that's "underneath" the current block handle blk.
%   The block 'blk/Constant' will have it's output parameter field
%   set to 'boolean(state)', where state is '0' or '1'.

  % Change value of constant block:
  const = ['boolean(' state ')'];
  set_param([getfullname(blk) '/Constant'],'Value',const);
  

% [EOF] slbswitch.m
