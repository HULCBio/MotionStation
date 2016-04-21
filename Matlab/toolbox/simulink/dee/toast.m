function toast()
%TOAST Destroy the contents of a DEE system.
%   TOAST is used when the uderlying system for the DEE control panel
%   has been corrupted.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.16 $
%   Jay Torgerson
%   Revised Karen D. Gondoly 7-12-96

% get handle to the syseditor's figure window
fig = gcf;
figtitle = get(fig,'Name');
slashind = findstr(figtitle,'/');
the_system_name = figtitle(1:(slashind(1)-1));

% set mouse pointer to watch
set(fig,'Pointer','Watch');
drawnow

% get status handle
controlhands = get(fig,'UserData');
st = controlhands(5);             % status handle
set(st,'String','Status: working...');   % set status string to working...
drawnow;

% get handles for edit blocks and status field
se = controlhands(1);
so = controlhands(2);
ic = controlhands(3);
ni = controlhands(4);
st = controlhands(5);             % status handle
tseto = controlhands(6);
ticto = controlhands(7);
nh = controlhands(11);
if length(controlhands) > 11,
  bh    = controlhands(12);
else
  bh = [];
end

% get system name
figtitle = get(fig,'Name');
BadHandle    = 0;
BlockMissing = 0;
SystemGone   = 0;
if ~isempty(bh),
  trystr   = 'blockname = get_param(bh,''name'');';
  catchstr = 'BadHandle = 1;';
  eval(trystr,catchstr);
else
  BadHandle = 1;
end

if BadHandle,
  slashind = findstr(figtitle,'/');
  the_system_name = figtitle(1:(slashind(1)-1));
  trystr   = 'open_system(the_system_name);';
  catchstr = 'SystemGone = 1;';
  eval(trystr,catchstr);

  if SystemGone,  % give up for now (a destroy callback for blocks will fix all this).
    set(st,'String',['Status: parent system, ''',the_system_name,''', is missing.']);
    set(fig,'Pointer','Arrow');
    return
  end

  blockname   = get_param(figtitle,'name');
  if isempty(blockname),
    BlockMissing = 1;
  end

  if BlockMissing,
    set(st,'String',['Status: block, ''',figtitle,''', is missing.']);
    set(fig,'Pointer','Arrow');
    drawnow;
    return
  end

  parent      = get_param(figtitle,'parent');
  bh          = get_param(figtitle,'handle');
  controlhands(12) = bh;
  set(fig,'UserData',controlhands);
else
  blockname = get_param(bh,'name');
  parent    = get_param(bh,'parent');
end

sysname  = [parent,'/',blockname];
set(fig,'Name',sysname);
figtitle = sysname;

% check that the block is there, if not, make one.
assumed_block_name = get_param(figtitle,'Mask Display');

% Error check for simulation running state.
StaticUpdate = 0;
rootsys = bdroot(sysname);

 SimState=get_param(rootsys,'SimulationStatus');

switch SimState,
  case { 'initializing','running','paused','terminating' },

  errordlg('Cannot rebuild during simulation.','DEE Error','on');
  set(st,'String','Status:  READY');
  set(fig,'Pointer','Arrow');
  drawnow;

  otherwise

if isempty(assumed_block_name),
  set(st,'String','Status: DEE block is not present, building a new one...');
  drawnow;
else
  lines  = get_param(sysname,'lines');
  blocks = get_param(sysname,'blocks');
  [numoflines,junk]  = size(lines);
  [numofblocks,junk] = size(blocks);

  % Waste all lines in the system
  %  i)  First waste all connected lines
  %  ii) Then waste all unconnected (these shouldn't be here, but we're
  %      doing cleanup...).
  %  These steps are broken up to avoid errors when mutltiple lines
  %  eminate from the same block but one of them has no sink block.  By deleting
  %  all connected lines first, you avoid trying to delete the same line twice,
  %  which would cause an error.


%%%%% Added by kdg (11-Jul-96) to account for new get_param('lines') syntax
lines=get_param(sysname,'lines');

while ~isempty(lines);
   endpoint=lines(1).Points(1,:);
   delete_line(sysname,endpoint);
   lines=get_param(sysname,'lines');
end

  % Now, waste all blocks that are not DEE blocks.

    GoodBlocks=[strmatch('SysInport',blocks);
                strmatch('Port',blocks);
                strmatch('SysMux',blocks);
                strmatch('x',blocks);
                strmatch('Integ',blocks);
                strmatch('y',blocks)];

    BadBlocks=[1:1:numofblocks];
    BadBlocks(GoodBlocks)=[];

    for i = 1:length(BadBlocks);
      delete_block([sysname,'/',blocks{BadBlocks(i)}]);
    end % for i

end % if/else isempty(assumed_block_name)

%%%%% End, added by kdg %%%%%


deeupdat;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% deeupdat just blew away your UserDatas, replace them
% so that everything is as though you just brought up the control panel.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sestring = get(se,'String');
icstring = get(ic,'String');
sostring = get(so,'String');
nistring = get(ni,'String');

set(se,'UserData',sestring);
set(ic,'UserData',icstring);
set(so,'UserData',sostring);
set(ni,'UserData',nistring);

end % switch SimState
