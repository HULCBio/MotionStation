function [w,xw,yw,wtxt] = dspwdes(opt,varargin)
% DSPWDES Signal Processing Blockset window design interface

% opt: 1 = recompute new window vector
%      2 = regenerate subsystem contents


% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.15.4.2 $ $Date: 2004/04/12 23:05:21 $

if opt == 1,
   [w,xw,yw,wtxt] = get_window(varargin{:});
else
   reconstruct_block(gcb,varargin{:});
end
return


% -----------------------------
% GET_WINDOW
% -----------------------------
function [w,xw,yw,wtxt] = get_window(varargin)

% If variables in edit boxes are unassigned, set them to "nice" values
wintype=varargin{1};
N=varargin{2}; if isempty(N), N=64; end
Rs=varargin{3}; if isempty(Rs), Rs=50; end
beta=varargin{4}; if isempty(beta), beta=5; end
wsamp=varargin{5};
wmode=varargin{6};


use_samp = (wintype==2) | (wintype==5) | (wintype==6);
if wsamp==1,
   sflag = 'symmetric';
else
   sflag = 'periodic';
end

switch wintype,
  case 1,
    s={'bartlett',N};
  case 2,
    s={'blackman',N,sflag};
  case 3,
    s={'boxcar',N};
  case 4,
    s={'chebwin',N,Rs};
  case 5,
    s={'hamming',N,sflag};
  case 6,
    s={'hanning',N,sflag};
  case 7,
    s={'kaiser',N,beta};
  case 8,
    s={'triang',N};
end

w=feval(s{:});


% For icon:
wtxt=s{1}; xw=(0:N-1)/(N-1)*0.75+0.05; yw=w*.65;

return

% -----------------------------
% RECONSTRUCT_BLOCK
% -----------------------------
function reconstruct_block(blk,varargin)

% wmode (directly from mask):
% 1-Apply window to input
% 2-Generate window
% 3-Generate and apply window

wmode = varargin{6};

% If we're already in the right configuration,
% return without any more work:
if same_config(blk, wmode),
   return;
end

% Delete block contents, retaining ports:
[ip,op,in_mode,out_mode] = delblkc(blk,1);

% -------------------------------
% Determine what outports to add:
% -------------------------------

% Get rid of extra output ports:
if length(op)>2,
   for i=3:length(op), delete_block(op(i)); end
end

switch wmode
case 1,
   % Apply only:
   if out_mode==1,
      % Have what we need - no-op
      set_param(op(1),'position',[135 25 155 45],'port','1');
   elseif out_mode==2,
      % Have a "Win" outport, convert to an "Out" outport
      set_param(op(2),'name','Out','position',[135 25 155 45],'port','1');
   elseif out_mode==3,
      % Have an unneeded "Win" port - delete it
      delete_block(op(2));
      set_param(op(1),'position',[135 25 155 45],'port','1');
   else
      % No known output ports present
      add_block('built-in/Outport',[blk '/Out']);
      set_param([blk '/Out'], 'position',[135 25 155 45],'port','1');
   end

case 2,
   % Generate only:
   if out_mode==2,
      % Have what we need - no-op
      set_param(op(2),'position',[135 80 155 100],'port','1');
   elseif out_mode==1,
      % Have an "Out" outport, convert to a "Win" outport
      set_param(op(1),'name','Win','position',[135 80 155 100],'port','1');
   elseif out_mode==3,
      % Have an unneeded "Out" port - delete it
      delete_block(op(1));
      set_param(op(2),'position',[135 80 155 100],'port','1');
   else
      % No known output ports present
      add_block('built-in/Outport',[blk '/Win']);
      set_param([blk '/Win'], 'position',[135 80 155 100],'port','1');
   end
   
case 3,
   % Apply and generate:
   if out_mode==3,
      % Have what we need - no-op
      set_param(op(1),'position',[135 25 155 45],'port','1');
      set_param(op(2),'position',[135 80 155 100],'port','2');
   elseif out_mode==1,
      % Have an "Out" outport, need a "Win" outport
      add_block('built-in/Outport',[blk '/Win']);
      set_param([blk '/Win'],'name','Win','position',[135 80 155 100],'port','2');
      set_param(op(1),'position',[135 25 155 45],'port','1');
   elseif out_mode==2,
      % Have a "Win" outport, need an "Out" outport
      add_block('built-in/Outport',[blk '/Out']);
      set_param([blk '/Out'],'name','Out','position',[135 25 155 45],'port','1');
      set_param(op(2),'position',[135 80 155 100],'port','2');
   else
      % No known output ports present
      add_block('built-in/Outport',[blk '/Out']);
      set_param([blk '/Out'], 'position',[135 25 155 45],'port','1');
      add_block('built-in/Outport',[blk '/Win']);
      set_param([blk '/Win'], 'position',[135 80 155 100],'port','2');
   end
   
otherwise,
   error('Unknown window mode selected');
end

   
% -------------------------------
% Determine what inports to add:
% -------------------------------

% Get rid of extra input ports:
if length(ip)>1,
   for i=2:length(ip), delete_block(ip(i)); end
end

switch wmode
case {1,3},
   % Apply only, or Apply and Generate:
   if in_mode == 1,
      % Have what we need - no-op
      set_param(ip(1),'position',[20 25 40 45],'port','1');
   else
      % Need an In port:
      add_block('built-in/Inport',[blk '/In']);
      set_param([blk '/In'],'position',[20 25 40 45],'port','1');
   end
      
case 2,
   % Generate only:
   if in_mode == 1,
      % Have an unneeded In port
      delete_block(ip(1));
   else
      % Have what we need (which is no In port) - no-op
   end
end


% ---------------------------------------
% Add Gain and Constant blocks as needed:
% ---------------------------------------

if wmode==1 | wmode==3,
   % Apply only, or Apply and Generate
   add_block('built-in/Gain',[blk '/Gain']);
   set_param([blk '/Gain'],'gain','w','position',[75 20 105 50]);
end

if wmode==2 | wmode==3,
   % Generate only:
   add_block('built-in/Constant',[blk '/Constant']);
   set_param([blk '/Constant'],'value','w','position',[80 80  100 100]);
end

% ---------------
% Connect blocks:
% ---------------

if wmode==1 | wmode==3,
   % Connect In to Gain to Out
   add_line(blk, 'In/1', 'Gain/1');
   add_line(blk, 'Gain/1', 'Out/1');
end

if wmode==2 | wmode==3,
   % Connect Constant to Win
   add_line(blk, 'Constant/1', 'Win/1');
end

return


% -----------------------------
% SAME_CONFIG
% -----------------------------
function same = same_config(blk,desired_mode)

% modes (directly from mask):
% 1-Apply window to input
% 2-Generate window
% 3-Generate and apply window

num_in  = length(find_system(blk,'LookUnderMasks','on', ...
   'FollowLinks','on', 'blocktype','Inport'));
num_out = length(find_system(blk,'LookUnderMasks','on', ...
   'FollowLinks','on', 'blocktype','Outport'));

% Determine "current" mode
if     (num_in ==0), curr_mode=2;
elseif (num_out==2), curr_mode=3;
else                 curr_mode=1;
end

% Compare with "desired" mode:
same = (curr_mode == desired_mode);

return;


% -----------------------------
% DELBLKC
% -----------------------------
function [ip,op,in_mode,out_mode] = delblkc(blk,skip_ports)
%DELBLKC Delete blocks and lines in a subsystem
%   delblkc(blk) deletes all blocks and lines in the subsystem blk.
%   If blk is not a subsystem, returns without errors.
%
%   delblkc(blk, 1) retains inport and outport blocks, only.
%
%   [ip,op]=delblkc(blk, 1) returns handles to each inport and outport block
%   remaining in blk.
%
%  in_mode: 0 if 'In' port not found
%           1 if 'In' port found
% out_mode: 0 if neither 'Out' nor 'Win' port found
%           1 if 'Out' port found
%           2 if 'Win' port found
%           3 if both ports found
%   

ip=[]; op=[];

t=get_param(blk,'blocktype');
if ~strcmp(t,'SubSystem'),
  return;
end

% Get blocks and lines:
% Set followlinks on so that if the block
blks = find_system(blk,'LookUnderMasks','on','FollowLinks','on');
hblks = get_param(blks(2:end),'handle');
hblks = [hblks{:}];

lins = get_param(blk,'Lines');
hlins = [lins.Handle];

in_mode = 0; out_mode = 0;

if nargin>1 & skip_ports,
   % Delete all blocks EXCEPT inports and outports:
   for i=1:length(hblks),
      port = strcmp(get_param(hblks(i),'blocktype'),{'Inport','Outport'});
      if ~any(port),
         delete_block(hblks(i));
      else
         if port(1),  % Inport
            if strcmp(get_param(hblks(i),'name'),'In'),
               in_mode = 1;
            end
            ip=[ip hblks(i)];
            
         else         % Outport
            if strcmp(get_param(hblks(i),'name'),'Out'),
               op(1)=hblks(i);  % Out outport
               out_mode=out_mode+1;   % At least mode 1: Apply
            elseif strcmp(get_param(hblks(i),'name'),'Win'),
               op(2)=hblks(i);  % Win outport
               out_mode=out_mode+2;   % At least mode 2: Generate
            else
               % Someone messed with block - record extra ports
               if length(op)<2, op(2)=0; end
               op=[op hblks(i)];
            end
         end
      end
   end
else
   % Delete all blocks:
   for i=1:length(hblks),
      delete_block(hblks(i));
   end
end

% Delete all lines:
delete_line(hlins);

return

% [EOF] dspwdes.m
