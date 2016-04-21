function sldemo_tableplot_comet(BlkObj, logsOut)
%SLDEMO_TABLEPLOT_COMET (demo) 3-D plot inp/out signals on 2-D table surface.
%

% Copyright 1990-2004 The MathWorks, Inc.
% $Revision: 1.1.4.2 $

% --- gather data

hblk = get(BlkObj,'Handle');
one = evalin('base', get_param(hblk,'bp1'));
two = evalin('base', get_param(hblk,'bp2'));
tab = evalin('base', get_param(hblk,'tableData'))';
inp = logsOut.inp.Data;
out = logsOut.out.Data;

% --- draw the surface representing the table data
mesh(two,one,tab')
set(gca,'xlim',[-10, 80])
set(gca,'ylim',[-10, 40])

% --- draw dynamically to see the trace over the surface
hold on
comet3(inp(:,2),inp(:,1), out(:,1));

% --- redraw as a static/zoomable plot
plot3(inp(:,2),inp(:,1), out(:,1));
hold off
rotate3d on

%[EOF] sldemo_tableplot_comet.m