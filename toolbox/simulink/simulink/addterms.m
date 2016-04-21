function addterms(sys)
%ADDTERMS  Add terminators to unconnected ports in a model.
%   ADDTERM(SYS) adds Terminator and Ground blocks to the unconnected
%   ports in the Simulink block diagram SYS.
%
%   See also SLUPDATE.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.13.2.4 $

%
% use handles, they're easier and faster to deal with...
%
sys=get_param(sys,'Handle');

%
% locate all the blocks in this system, prune out the sys handle
% as it may be a subsystem and will be included in the results of
% find_system
%
b=find_system(sys,'SearchDepth',1,'Type','block');
b(find(b==sys),:)=[];

%
% get the list of lines for this layer in the hierarchy
%
l=get_param(sys,'Lines');

%
% for each block, test its input and output ports for connections,
% if not connected add a Ground to the input ports and a Terminator to
% the output ports
%
for i=1:size(b,1),
  portHandles = get_param(b(i),'PortHandles');
  % Treat all enable + trigger + Action input ports the same they will be checked
  % against the dst of the line
  inputPortHandles = portHandles.Inport;
  triggerPortHandles = portHandles.Trigger;
  enablePortHandles = portHandles.Enable;
  actionPortHandles = portHandles.Ifaction;
  inputPortHandles = [inputPortHandles , triggerPortHandles, enablePortHandles, actionPortHandles];
  numInputs=size(inputPortHandles, 2);
  % Here deal with output port which includes state ports
  statePortHandles = portHandles.State;
  outputPortHandles = portHandles.Outport;
  outputPortHandles = [outputPortHandles, statePortHandles];
  numOutputs=size(outputPortHandles, 2);

  for port=1:numInputs,
    if ~BlockInputIsConnected(b(i), inputPortHandles(port), l),
      AddGroundToInputPort(b(i), inputPortHandles(port));
    end
  end

  for port=1:numOutputs,
    if ~BlockOutputIsConnected(b(i), outputPortHandles(port), l),
      AddTerminatorToOutputPort(b(i), outputPortHandles(port));
    end
  end

  %
  % if this block is a subsystem, recurse on it to add terminators
  % to the blocks in it's layer
  %
  if strcmp(get_param(b(i),'BlockType'),'SubSystem'),
    addterms(b(i));
  end

end

% end addterms

%
%=============================================================================
% BlockInputIsConnected
% Test that a specific block input port is connected.  The array of lines
% for the system that the block lives in is required.
%=============================================================================
%
function connected=BlockInputIsConnected(block,blockPortHandle,lines)

connected = ~isempty(get_param(blockPortHandle,'siggenportname'));
if connected,
  return;
end

for i=1:size(lines,1),
  lineInfo = lines(i).Handle;
  line = get_param(blockPortHandle,'Line');
  %
  % the line is not a branch parent if the Branch field is empty,
  % in that case, all that needs to be done is to test for the
  % destination block/port of this line to be connected to the
  % specified block.
  %
  if isempty(lines(i).Branch),
    if ((lines(i).DstBlock==block) &&  ...
        lineInfo == line)
      connected = 1;
    end
  else
    connected=BlockInputIsConnected(block, blockPortHandle,lines(i).Branch);
  end

  if connected,
    break;
  end
end

% end BlockInputIsConnected

%
%=============================================================================
% AddGroundToInputPort
% Connect a Ground block to a specific input port on a block.
%=============================================================================
%
function AddGroundToInputPort(block, portHandle)

%
% need the parent system
%
sys = get_param(block,'Parent');

%
% need the port position to place the Ground block
%
%portPos=get_param(block,'InputPorts');
portPos = get_param(portHandle,'Position');

%
% the Ground position will start as [0 0 10 10] and be modifed
% down below
%
position=[0 0 10 10];

%
% Determine if the port is on the left/right side or if it is on the 
% top/bottom of the block
%
Port = GetPortLocation(block, portPos, 'input');

%
% need the block orientation to help in placing the Ground
%
DefOrient = get_param(block,'Orientation');

switch get_param(block,'Orientation')

  case 'left',
    if Port.Down
      DefOrient = 'up';
    end
    position(1) = position(1) + portPos(1) + 10 - 15*Port.Down;
    position(2) = position(2) + portPos(2) -  5 + 15*Port.Down;
    position(3) = position(3) + portPos(1) + 10 - 15*Port.Down;
    position(4) = position(4) + portPos(2) -  5 + 15*Port.Down;

  case 'right',
    if Port.Top
      DefOrient = 'down';
    end
    position(1) = position(1) + portPos(1) - 20 + 15*Port.Top;
    position(2) = position(2) + portPos(2) -  5 - 15*Port.Top;
    position(3) = position(3) + portPos(1) - 20 + 15*Port.Top;
    position(4) = position(4) + portPos(2) -  5 - 15*Port.Top;

  case 'up',
    if Port.Left
      DefOrient = 'right';
    end
    position(1) = position(1) + portPos(1) -  5 - 15*Port.Left;
    position(2) = position(2) + portPos(2) + 10 - 15*Port.Left;
    position(3) = position(3) + portPos(1) -  5 - 15*Port.Left;
    position(4) = position(4) + portPos(2) + 10 - 15*Port.Left;

  case 'down'
    if Port.Right
      DefOrient = 'left';
    end
    position(1) = position(1) + portPos(1) -  5 + 15*Port.Right;
    position(2) = position(2) + portPos(2) - 20 + 15*Port.Right;
    position(3) = position(3) + portPos(1) -  5 + 15*Port.Right;
    position(4) = position(4) + portPos(2) - 20 + 15*Port.Right;

end



numGrounds=size(find_system(sys,'SearchDepth',1,'BlockType','Ground'),1);
blocknumber = numGrounds + 1;
ground = sprintf('Ground_%d', blocknumber);

while ~isempty(find_system(sys,'SearchDepth',1,'Name',ground))
    % there is a name clash
    % keep on incrementing the number until there is no name clash
    blocknumber = blocknumber + 1;
    ground = sprintf('Ground_%d', blocknumber);
end

add_block('built-in/Ground',[sys '/' ground],...
          'Position',position,...
          'ShowName','off', ...
          'Orientation', DefOrient);

%GroundPortPos = get_param([sys '/' ground],'OutputPorts'); obsolete usage of OutputPorts
GroundPortHandles = get_param([sys '/' ground],'PortHandles');
GroundPortPos = get_param(GroundPortHandles.Outport,'Position');

add_line(sys,[GroundPortPos;portPos]);

% end AddGroundToInputPort

%
%=============================================================================
% BlockOutputIsConnected
% Test that a specific block input port is connected.  The array of lines
% for the system that the block lives in is required.
%=============================================================================
%
function connected=BlockOutputIsConnected(block,blockPortHandle,lines)
connected=0;
for i=1:size(lines,1),
   lineInfo = lines(i).Handle;
   line = get_param(blockPortHandle,'Line');

  %
  % the line is not a branch parent if the Branch field is empty,
  % in that case, all that needs to be done is to test for the
  % destination block/port of this line to be connected to the
  % specified block.
  %
  if ((lines(i).SrcBlock==block) &&...
    isequal(line, lineInfo))
    connected = 1;
  end
end

% end BlockOutputIsConnected

%
%=============================================================================
% AddTerminatorToOutputPort
% Connect a Terminator block to a specific output port on a block.
%=============================================================================
%
function AddTerminatorToOutputPort(block, portHandle)

%
% need the parent system
%
sys = get_param(block,'Parent');

%
% need the port position to place the Ground block
%
%portPos=get_param(block,'OutputPorts');
portPos = get_param(portHandle, 'Position');

%
% Determine if the port is on the left/right side or if it is on the 
% top/bottom of the block
%
Port = GetPortLocation(block, portPos, 'output');

%
% the Ground position will start as [0 0 10 10] and be modifed
% down below
%
position=[0 0 10 10];

%
% need the block orientation to help in placing the Terminator
%
DefOrient = get_param(block, 'Orientation');
switch get_param(block,'Orientation')

  case 'left',
    if Port.Down
      DefOrient = 'down';
    end
    position(1) = position(1) + portPos(1) - 20 + 15*Port.Down;
    position(2) = position(2) + portPos(2) -  5 + 15*Port.Down;
    position(3) = position(3) + portPos(1) - 20 + 15*Port.Down;
    position(4) = position(4) + portPos(2) -  5 + 15*Port.Down;

  case 'right',
    if Port.Top
      DefOrient = 'up';
    end
    position(1) = position(1) + portPos(1) + 10 - 15*Port.Top;
    position(2) = position(2) + portPos(2) -  5 - 15*Port.Top;
    position(3) = position(3) + portPos(1) + 10 - 15*Port.Top;
    position(4) = position(4) + portPos(2) -  5 - 15*Port.Top;

  case 'up',
    if Port.Left
      DefOrient = 'left';
    end
    position(1) = position(1) + portPos(1) -  5 - 15*Port.Left;
    position(2) = position(2) + portPos(2) - 20 + 15*Port.Left;
    position(3) = position(3) + portPos(1) -  5 - 15*Port.Left;
    position(4) = position(4) + portPos(2) - 20 + 15*Port.Left;

  case 'down'
    if Port.Right
      DefOrient = 'right';
    end
    position(1) = position(1) + portPos(1) -  5 + 15*Port.Right;
    position(2) = position(2) + portPos(2) + 10 - 15*Port.Right;
    position(3) = position(3) + portPos(1) -  5 + 15*Port.Right;
    position(4) = position(4) + portPos(2) + 10 - 15*Port.Right;

end

numTerms=size(find_system(sys,'SearchDepth',1,'BlockType','Terminator'),1);
blocknumber = numTerms+1;
term=sprintf('Terminator_%d', blocknumber);

while ~isempty(find_system(sys,'SearchDepth',1,'Name',term))
    % there is a name clash
    % keep on incrementing the number until there is no name clash
    blocknumber = blocknumber + 1;
    term=sprintf('Terminator_%d', blocknumber);
end

add_block('built-in/Terminator',[sys '/' term],...
          'Position',position,...
          'ShowName','off',...
          'Orientation', DefOrient);

%TermPortPos = get_param([sys '/' term],'InputPorts'); obsolete usage of InputPorts
TermPortHandles = get_param([sys '/' term],'PortHandles');
TermPortPos = get_param(TermPortHandles.Inport,'Position');

add_line(sys,[portPos;TermPortPos]);

% end AddTerminatorToOutputPort

function Port = GetPortLocation(block, portPos, side)
%
% Determine the Orientation of the Port w.r.t the block itself
%
BlockPos = get_param(block, 'Position');

if strcmp(side, 'input')
  offset   = 5;
else
  offset = -5;
  BlockPos = BlockPos([3 4 1 2]);
end

if (BlockPos(1) == (portPos(1) + offset))
  Port.Top = 0;
else
  Port.Top = 1;
end
if (BlockPos(2) == (portPos(2) + offset))
  Port.Right = 0;
else
  Port.Right = 1;
end
if (BlockPos(3) == (portPos(1) - offset))
  Port.Down = 0;
else
  Port.Down = 1;
end
if (BlockPos(4) == (portPos(2) - offset))
  Port.Left = 0;
else
  Port.Left = 1;
end


