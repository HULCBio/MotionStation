function [x,y] = cplxico2(in_exclude,out_exclude)
%CPLXICO2  Create icons for complex blocks.
%    [X,Y] = CPLXICO2 returns vectors which can be
%    used in a plot command inside a block mask to indicate
%    a complex input or output.
%
%    CPLXICO2(in_exclude, out_exclude) specifies vectors
%    containing a port exclusion index list.  For example,
%    CPLXICO2(1,[]) implies that the 1st input port does NOT
%    have a complex icon, and no output ports are excluded.


%    Copyright 1995-2002 The MathWorks, Inc.
%    $Revision: 1.9 $  $Date: 2002/04/14 20:53:14 $


% Determine number of ports and orientation:
blk    = gcb;
ports  = get_param(blk,'ports');
orient = get_param(blk,'orientation');
units  = get_param(blk,'maskiconunits');  % normalized, autoscale, or pixels

% Build inclusion list:
in_inc=ones(1,ports(1)); out_inc=ones(1,ports(2));
if nargin>0, in_inc(in_exclude)=0; end
if nargin>1, out_inc(out_exclude)=0; end

if ~strcmp(units,'autoscale'),
  error('Mask icon units must be set to "autoscale"');
end

x=[0 NaN 100 NaN ]; y=[0 NaN 100 NaN];  % Initialize output vectors for normalization

for i=1:ports(1),   % Input ports
  if in_inc(i),
    [xr,yr]=port_label('in',i,ports(1),orient);
    x=[x NaN xr]; y=[y NaN yr];
  end
end

for i=1:ports(2),   % Output ports
  if out_inc(i),
    [xr,yr]=port_label('out',i,ports(2),orient);
    x=[x NaN xr]; y=[y NaN yr];
  end
end

% -----------------------------
% Rotate and place port labels:
% -----------------------------
function [xo,yo] = port_label(side,port_idx,num_ports,orient)

% Determine coords for 'right' orientation:
% Note: Index 3 and 6 are merely placeholders.
%       They will be overwritten by NaN's later.
xs = [4 16 0 4 16 0 10 10];
ys = [4 -4 0 -4 4 0 8 -8];

if strcmp(side,'out'), xs = xs + 80; end;
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

% Overwrite NaN's to break up line segments:
xo([3 6])=NaN; yo([3 6])=NaN;

% end of port_label
