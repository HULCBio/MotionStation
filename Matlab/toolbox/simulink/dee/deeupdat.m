function deeupdat
%DEEUPDAT Update a DEE block.
%   DEEUPDAT reconstructs a DEE block based upon the equations
%   entered in the DEE editor.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.19 $
%   Revised Karen D. Gondoly 7-12-96


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get handles and check inputs in syseditor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get handle to the syseditor's figure window
fig = gcf;

set(fig,'HandleVisibility','callback');

% set mouse pointer to watch
set(fig,'Pointer','Watch');
drawnow

% get handles for edit blocks and status field
controlhands = get(fig,'UserData');
se = controlhands(1);
so = controlhands(2);
ic = controlhands(3);
ni = controlhands(4);
st = controlhands(5);             % status handle
tseto = controlhands(6);
ticto = controlhands(7);

if length(controlhands) > 11,
  bh = controlhands(12);
else
  bh = [];
end

set(st,'String','Status: working...');   % set status string to working...
drawnow;

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

if BadHandle, % check for missing block and/or system.
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

  blockname    = get_param(figtitle,'name');
  if isempty(blockname),
    BlockMissing = 1;
  end

  if BlockMissing, % give up for now (a destroy callback for blocks will fix all this).
    set(st,'String',['Status: block, ''',figtitle,''', is missing.']);
    set(fig,'Pointer','Arrow');
    drawnow;
    return
  end

  % So, the system is here, the block is here, we just have a BadHandle.
  % Well, we can fix that...
  toast;
  return
end

parent    = get_param(bh,'parent');
sysname = [parent,'/',blockname];
set(fig,'Name',sysname);

% check to make sure the block hasn't been deleted, renamed or closed
theblockname = get_param(sysname,'Mask Display');
if isempty(theblockname),
  errstr = ['The DEE block, "',sysname,'" has been renamed, deleted, or closed.'];
  errstr = str2mat(errstr,'     ','You can:','  i) change the block name back (if only the name has changed)','  ii) reopen the system (if it''s closed)','  iii) select the Rebuild button to rebuild the block from scratch');

  set(st,'String',['Status: "',sysname,'" NOT FOUND.']);
  errordlg(errstr,'DEE Error');
else

set(fig,'HandleVisibility','callback');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get values from the edit blocks
sestring = get(se,'String');      % state derivative equations
sostring = get(so,'String');      % system output equations
icstring = get(ic,'String');      % initial conditions
nistring = get(ni,'String');      % number of inputs

% make sure that the inputs are valid
if str2num(nistring) < 0,
  nistring = '0';
  set(ni,'String',nistring);
end

%
% remove rows that have nothing but spaces and white space in them for
% sestring, icstring, sostring, nistring
%

empties = cell(size(sestring));
for i=1:length(sestring),
  empties{i} = isempty(deblank(sestring{i}));
end
nonempties=[1:length(sestring)];
nonempties([empties{:}])=[];
sestring=sestring(nonempties(:));

empties = cell(size(sostring));
for i=1:length(sostring),
  empties{i} = isempty(deblank(sostring{i}));
end
nonempties=[1:length(sostring)];
nonempties([empties{:}])=[];
sostring=sostring(nonempties(:));

empties = cell(size(icstring));
for i=1:length(icstring),
  empties{i} = isempty(deblank(icstring{i}));
end
nonempties=[1:length(icstring)];
nonempties([empties{:}])=[];
icstring=icstring(nonempties(:));

empties=find(nistring==' ' | nistring==0);
nonempties=[1:length(nistring)];
nonempties(empties(:))=[];
nistring=nistring(nonempties);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get new dimensions for the strings and check to see if there is an
%    initial condition for each state, check that # of inputs is defined, and
%    update the totals for the edit fields
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[numse,secols] = size(sestring);
[numic,iccols] = size(icstring);
[numso,socols] = size(sostring);
[numni,nicols] = size(nistring);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check to see if the number of initial conditions is equal to
%   the number of state equations.
%   If numse > numic, then pad with zeros
%   If numse < numic, then give appropriate error in status field
%   If numse = numic, then leave it alone
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define the error strings for the status field
errorstr1 = 'Status:  # of initial conditions > # of states';
errorstr2 = 'Status:  # of inputs undefined';
errorstr3 = 'Simulation running, cannot alter system structure.';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update total readouts located at the bottom of the edit field
%  for the system equation and initial condition blocks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(tseto,'String',['Number of states = ',num2str(numse)]);
set(ticto,'String',['Total = ',num2str(numic)]);


% affect status field
if (numse < numic),
  set(st,'String',errorstr1);
  set(fig,'Pointer','Arrow');
  drawnow;
  return
elseif (numse > numic),

  if isempty(icstring),
     holdicstring={};
  else
     holdicstring=icstring;
  end;
  icstring=cell(size(sestring));
  icstring(1:numic)=holdicstring;
  for i = (numic+1):numse,
      icstring(i) = {'0'};
  end % for i

  [numic,iccols] = size(icstring);
  set(ic,'String',icstring);
  set(st,'String','Status:  READY');
elseif numse==numic,
  set(st,'String','Status:  READY');
end

if (isempty(nistring) | isempty(str2num(nistring))),
  set(st,'String',errorstr2);
  set(fig,'Pointer','Arrow');
  drawnow;
  return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get total number of inputs to the mux block required for the construction
%   of the system
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(nistring)
  numni = str2num(nistring);
else
  numni = 0;
end
muxputs = numni + numse;
if (muxputs==0)
  muxputs = 1;
end
muxputs = num2str(muxputs);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get old nums and strings.  The reason that the old system has to be
% rederived is that there is no other record of what it is other than
% itself.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[oldsestring,oldicstring,oldsostring,oldnistring,oldnumse,oldnumso,oldnumni]...
 = getsys(sysname);

% Error check for simulation running state.
StaticUpdate = 0;
switch get_param(bdroot(sysname),'SimulationStatus'),
  case { 'initializing','running','paused','terminating' },
    if ((oldnumse~=numse) | (oldnumso~=numso) | (oldnumni~=numni)),
      errordlg(errorstr3,'DEE Error','on');

      % Reset strings to maintain WYSIWYG.
      set(se,'String',oldsestring);
      set(ic,'String',oldicstring);
      set(so,'String',oldsostring);
      set(ni,'String',oldnistring);

      set(st,'String','Status:  READY');
      set(fig,'Pointer','Arrow');
      drawnow;
      return
    else
      StaticUpdate = 1;
    end

  otherwise
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Before you do anything, DELETE ALL THE LINES CONNECTING BLOCKS.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    LocalDeleteAllLines(sysname);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  update the edit fields to reflect the new strings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(se,'String',sestring);
set(ic,'String',icstring);
set(so,'String',sostring);
set(ni,'String',nistring);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update total readouts located at the bottom of the edit field
%  for the system equation and initial condition blocks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(tseto,'String',['Number of states = ',num2str(numse)]);
set(ticto,'String',['Total = ',num2str(numic)]);

%*************************************************************************
% convert x(i) values in sestring into u(n+i) values for the ith Fcn
%         block for state equations
%*************************************************************************
if ~isempty(nistring),
  inputoffset = str2num(nistring);
else
  inputoffset = 0;
end

newsestring=cell(size(sestring));
for i=1:numse,
  newsestring{i}=parseit(sestring{i},inputoffset,st);
end


%*************************************************************************
% convert x(i) values in sostring into u(n+i) values for the ith Fcn
%         block for output equations
%*************************************************************************

newsostring=cell(size(sostring));
for i=1:numso,
  newsostring{i} = parseit(sostring{i},inputoffset,st);
end


%*************************************************************************
% Build the Simulink system based on the specs entered into the syseditor
%    control panel
%*************************************************************************


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% stuff the new strings into the UserData matricies for the edit fields
%       respectfully.  This is done for the Undo option.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(se,'UserData',oldsestring);
set(so,'UserData',oldsostring);
set(ic,'UserData',oldicstring);
set(ni,'UserData',oldnistring);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check to make sure that there are inputs and outputs, and if there is
% not input port / output port, then set the corresponding oldnumni
% and oldnumso to be 0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
checkinput  = find_system(sysname,'SearchDepth',1,'BlockType','Inport');
checkoutput = find_system(sysname,'SearchDepth',1,'BlockType','Outport');
checkstate  = find_system(sysname,'SearchDepth',1,'BlockType','Integrator');

if isempty(checkinput),
  oldnumni = 0;
end
if isempty(checkoutput),
  oldnumso = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define the numbers that control the reconstruction method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
secheck = numse - oldnumse;
socheck = numso - oldnumso;
nicheck = numni - oldnumni;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reset the number of SysMux ports to current desired value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set_param([sysname,'/SysMux'], 'inputs',muxputs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if nicheck > 0 then add more SysInports
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nicheck > 0,
  for i = (oldnumni+1):numni,
    add_block('built-in/Inport',[sysname,'/','SysInport',num2str(i)]);
  end

  for i = 1:numni,
    index = num2str(i);
    set_param([sysname,'/','SysInport',index],'Port',index);
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if nicheck < 0 then cut a few
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif nicheck < 0,
  for i = oldnumni:-1:(numni+1),
    index = num2str(i);
    delete_block([sysname,'/SysInport',index]);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Position the SysMux nicely so the system won't be altogether ugly.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pos=[100 max([numni,numse]+2)*50];

pos=[pos, pos(1)+50, pos(2)+(10*(numni+numse))];

set_param([sysname,'/','SysMux'],'Position',pos);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% hook the SysInports back up to the SysMux
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~StaticUpdate,
  for i = 1:numni,
    index = num2str(i);
    pos=[20 i*50 45 i*50+25];
    set_param([sysname,'/','SysInport',index],'Position',pos);
    add_line(sysname,['SysInport',index,'/1'],['SysMux','/',index]);
  end % for i
end % if ~StaticUpdate

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% foreach state equation, create a Fcn block and an 1/s block, connect them
% up to the appropriate port on the SysMux block , set the appropriate
% expression in the Fcn block and set the initial conditions of the 1/s
% blocks to the corresponding values in icstring.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if secheck > 0,
  for i = (oldnumse+1):numse,
    statenum = num2str(i);
    muxstatenum = num2str(i+numni);
    statename = ['x',statenum];
    intname = ['Integ',statenum];
    add_block('built-in/Fcn',[sysname,'/',statename]);
    add_block('built-in/Integrator',[sysname,'/',intname]);
  end
elseif secheck < 0,
  for i=oldnumse:-1:(numse+1);
    index = num2str(i);
    delete_block([sysname,'/','x',index]);
    delete_block([sysname,'/','Integ',index]);
  end
end

for i = 1:numse,
  % connect them all up
  statenum = num2str(i);
  muxstatenum = num2str(i+numni);
  statename = ['x',statenum];
  intname = ['Integ',statenum];
  set_param([sysname,'/',statename],'Expr',newsestring{i});
  set_param([sysname,'/',intname],'InitialCondition',icstring{i});

  if ~StaticUpdate,
    set_param([sysname,'/',statename],'Position',[300,i*50 330 i*50+20]);
    set_param([sysname,'/',intname  ],'Position',[400,i*50 430 i*50+20]);

    add_line(sysname,'SysMux/1',[statename,'/1']);
    add_line(sysname,[statename,'/1'],[intname,'/1']);
    add_line(sysname,[intname,'/1'],['SysMux/',muxstatenum]);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add Fcn blocks and output blocks that don't exist or delete extra ones
% that do not belong anymore
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if socheck > 0,
  for i = (oldnumso+1):numso,
    index = num2str(i);
    add_block('built-in/Fcn',[sysname,'/','y',index]);
    add_block('built-in/Outport',[sysname,'/','Port',index]);
  end
elseif socheck < 0,
  for i = oldnumso:-1:(numso+1),
    index = num2str(i);
    delete_block([sysname,'/','y',index]);
    delete_block([sysname,'/','Port',index]);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% foreach output equation, augment the appropriate Fcn block to reflect the
%     equation and set the output port numbers (and connect it up).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:numso,
  index = num2str(i);
  set_param([sysname,'/','y',index],'Expr',newsostring{i});
  set_param([sysname,'/','Port',index],'Port',num2str(i));

  if ~StaticUpdate,
    pos=[300,(max([numni,numse])+2+i)*50];
    pos=[pos pos+[30 20]];
    set_param([sysname,'/','y',index],'Position',pos);
    pos=[400,(max([numni,numse])+2+i)*50];
    pos=[pos pos+20];
    set_param([sysname,'/','Port',index],'Position',pos);

    add_line(sysname,'SysMux/1',['y',index,'/1']);
    add_line(sysname,['y',index,'/1'],['Port',index,'/1']);
  end
end

end % end check for deleted, renamed, or closed DEE block.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change the figure pointer back to an arrow and draw it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(fig,'Pointer','Arrow');
drawnow;


%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% LocalDeleteAllLines - temporary workaround until the 'Lines' parameter
% is implemented in Simulink 2
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalDeleteAllLines(sys)

%%%%% Added by kdg to accommodate new 'Lines' parameters %%%%%

lines=get_param(sys,'lines');

while ~isempty(lines);
   endpoint=lines(1).Points(1,:);
   delete_line(sys,endpoint);
   lines=get_param(sys,'lines');
end
