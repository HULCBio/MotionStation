function [x,y] = dspcsum
% DSPCSUM Complex sum block helper function for Signal Processing Blockset


% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.11.4.2 $ $Date: 2004/04/12 23:05:15 $

blk = gcb;
x=[]; y=[];

% Get signs string:
s = deblank(get_param(blk,'Inputs'));
s_orig = s;
N = length(s);
if N==0,
  warning('Invalid string in "List of signs"');
  [x,y]=cplxico2; return;
end

% Translate string to all +/- characters
% - If +/- string, leave it
% - If #, convert to string of +'s
if s(1)~='+' & s(1)~='-',
  N=str2double(s);
  if isnan(N),
    warning('Invalid string in "List of signs"');
    [x,y]=cplxico2; return;
  end
  s='+'; s=s(ones(1,N));
end

% Set string into sum block:
set_param([blk '/Sum'],'Inputs',s_orig);

% Add ports as appropriate (N ports)
fix_ports(blk);

% Get complex port icons:
[x,y]=cplxico2;

% Append block port icons (+ and - signs)
% If a single +, get alternate icon
orient = get_param(blk,'orientation');
for i=1:N,
  [xi,yi]=port_label(s(i),N+1-i,N,orient);

  x=[x NaN xi]; y=[y NaN yi];  % Concatenate to icon
end

return


% -----------------------------
% Rotate and place port labels:
% -----------------------------
function [xo,yo] = port_label(sig,port_idx,num_ports,orient)
% PORT_LABEL
% sig = sign symbol, "+" or "-"
% port_idx = port index, 1:num_ports
% orient = orientation string

if (num_ports == 1),
  % Construct "Sigma" symbol
  % This symbol does NOT rotate
  xo = [75 75 25 55 25 75 75];
  yo = [65 75 75 50 25 25 35];

  % Tack on minus sign if required:
  if (sig=='-'),
    xo = [xo NaN 23 33];
    yo = [yo NaN 50 50];
  end

  return
end

% Construct + or - sign for 'right' orientation:
if sig=='-',
  xs = [24 36];
  ys = [ 0  0];
else
  xs = [24 36 0   30   30];
  ys = [ 0  0 0 -7.5  7.5];
end

if num_ports==1,
  ys = ys + 50*port_idx;
elseif num_ports==2,
  ys = ys + 100*(2*(port_idx-1)+1)/(num_ports+2);
else
  ys = ys + 100*port_idx/(num_ports+1);
end

% Handle orientations other than 'right':
switch orient
case 'up'   % bottom-to-top
  xx = xs;  xs = ys;  ys = xx;   % swap x and y 
  xs = 100 - xs;
case 'down' % top-to-bottom
  xx = xs;  xs = ys;  ys = xx;   % swap x and y 
  xs = 100 - xs;
  ys = 100 - ys;
case 'left' % right-to-left
  xs = 100 - xs;
end
xo=xs; yo=ys;

% Use NaN's for plus sign:
% (Avoid arithmetic on NaN's above for VAX, etc)
if sig=='+',
  xo(3)=NaN; yo(3)=NaN;
end

return


function fix_ports(blk)
% FIX_PORTS

% Delete any ports which are no longer connected
% Add additional ports as required
% Assumptions:
% - Users have NOT changed the subsystem contents
% - Subsystem contains:
%      1) sum block (named 'Sum')
%      2) Inports named "In#", #=1,2,...
%      3) One outport named "Out".
%      4) Potentially Sum1, Join, and Split blocks

% Determine # of required ports
% Query sum block for # of input ports
sblk = [blk '/Sum'];
nreq_inp = get_param(sblk,'Ports');
nreq_inp=nreq_inp(1);

% Determine # and handles of input ports:
blks = find_system(blk,'LookUnderMasks','all', 'FollowLinks','on', ...
                       'BlockType', 'Inport');
hblks = get_param(blks,'handle');
hblks = [hblks{:}];
ncurr_inp = length(hblks);
nxs_inp = ncurr_inp - nreq_inp;  % excess # inports

% Delete all lines:
lins = get_param(blk,'Lines');
if ~isempty(lins),
  delete_line([lins.Handle]);
end

% Delete unnecessary inports
if (nxs_inp>0),
  for i=1:nxs_inp,
    delete_block(hblks(nreq_inp+i));
  end
elseif (nxs_inp<0),
  % Add required inports
  for i=1:-nxs_inp,
    j = num2str(ncurr_inp+i);
    nam = [blk '/In' j];
    add_block('built-in/Inport',nam);
    set_param(nam,'Port',j);
  end
end

% Delete Sum1/Split/Join blocks, if present
b = find_system(blk,'LookUnderMasks','all', 'FollowLinks','on', ...
    'Name', 'Sum1');
if ~isempty(b), delete_block(b{:}); end
b = find_system(blk,'LookUnderMasks','all', 'FollowLinks','on', ...
    'Name', 'Split');
if ~isempty(b), delete_block(b{:}); end
b = find_system(blk,'LookUnderMasks','all', 'FollowLinks','on', ...
    'Name', 'Join');
if ~isempty(b), delete_block(b{:}); end
               
if (nreq_inp == 1),
	% Now, if there is only ONE input to the sum block, then we
	% are attempting to sum across the vector.  This would be bad,
	% since the real and complex would get summed.  Instead,
	% add another sum block, a split block, and a join block:
   add_block('built-in/Mux',  [blk '/Join' ]);
   set_param([blk '/Join'], 'Inputs', '2');
   add_block('built-in/Demux', [blk '/Split']);
   set_param([blk '/Split'], 'Outputs', '2');
   
   add_block('built-in/Sum', [blk '/Sum1']);
   s=get_param([blk '/Sum'], 'Inputs');   % Copy the Sum block setting ...
   set_param([blk '/Sum1'], 'Inputs', s); % ... into the Sum1 block.
      
   % Connect inport to split, outport to join, etc:
   add_line(blk, 'In1/1',   'Split/1');
   add_line(blk, 'Join/1',  'Out/1');
   add_line(blk, 'Split/1', 'Sum/1');
   add_line(blk, 'Split/2', 'Sum1/1');
   add_line(blk, 'Sum/1',   'Join/1');
   add_line(blk, 'Sum1/1',  'Join/2');
 
else
   % The usual interconnections:
   % Connect Sum to Out
	add_line(blk, 'Sum/1', 'Out/1');
	% Connect added inports to Sum
	for i=1:nreq_inp,
	  j = num2str(i);
	  add_line(blk, ['In' j '/1'], ['Sum/' j]);
	end
end

return
