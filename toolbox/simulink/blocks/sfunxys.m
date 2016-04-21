function  [sys, x0]  = sfunxys(t,x,u,flag,ax,offset,ts)
%SFUNXYS an S-function which acts as an X-Y scope using MATLAB's plot function.
%   This M-file is designed to be used in a Simulink S-function block.
%   It stores the last input point using discrete states
%   and then plots this against the most the most recent input.
%   This scope displays circles at the given sample points.
%
%   Set this M-file up in an S-function block with a MUX with two
%   inputs feeding into this block. Set the first function parameter, AX,
%   up as a four element vector which defines the axis of the graph.
%   The second and third parameters, OFFSET and TS, are the offset and sample
%   times which define the interval for plotting 'o's on the graph. 
%
%   See also, SFUNXY, LORENZ.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.19 $
%   Andrew Grace 5-30-91.
%   Revised Wes Wang 4-28-93,8-17-93

if abs(flag) == 2   % A real time hit 
        %add handel here
        h_fig =   x(3);

	if h_fig <= 0
	   % Initialize graph
	   [sl_name,blocks] = get_param;
	   [n_b, m_b]= size(blocks);
	   if n_b < 1
	         error('Cannot delete block while simulating')
	   elseif n_b > 1
	         error('Something wrong in get_param, You don''t have the current Simulink')
	   end;
	   % findout if the graphics window exist
	   ind = find(sl_name == setstr(10));
	   for i = ind
		 sl_name(i) = '_';
	   end;

	   % findout if the graphics window exist
	   Figures = get(0,'Chil');
	   new_figure = 1;
	   for i = 1:length(Figures)
	      if strcmp(get(Figures(i), 'Type'), 'figure')
	         if strcmp(get(Figures(i), 'Name'), sl_name)
	            h_fig = Figures(i);
	            axss = get(h_fig, 'UserData');
	            if length(axss) == 6
	               new_figure = 0;
	               h_axis = axss(1);
	               h_plot1 = axss(2);
	               set(h_axis,'Xlim',ax(1:2),'Ylim',ax(3:4));
	               set(h_plot1,'XData',ax(1),'YData',ax(3));
	            end;
	         end;
	      end;
	   end;
	   if new_figure
	      h_fig = figure('Unit','pixel','Pos',[100 100 400 300], ...
	                'Name',sl_name);;
	      set(0, 'CurrentF', h_fig);
	      if nargin < 5  
	   	disp('Axis not defined; using default axis');
		ax = [ 0 10 0 10];
	      elseif length(ax)~=4
		disp('Axis not defined correctly; it must be a 1x4 vector')
		ax = [ 0 10 0 10];
	      end
	      h_axis = axes('Xlim', ax(1:2), 'Ylim', ax(3:4),'XTickLabels',[],'YTickLabels',[]);
	      h_plot1 =  plot([ax(1),ax(1)],[ax(3) ax(3)],'Erasemode','none');
	      set(h_axis,'NextPlot','add');
	      h_plot1 =  plot([ax(2),ax(2)],[ax(4) ax(4)],'r-','Erasemode','none');
	      set(h_axis,'NextPlot','new','Xlim', ax(1:2), 'Ylim', ax(3:4),'XGrid','on','YGrid','on');
	   end;
	   set(h_fig,'Color',get(h_fig,'Color'));
	   set(Figures,'Nextplot','new');
	   x = [Inf; Inf; h_fig]; 	% Flag to indicate first point
	   set(h_fig, 'UserData', [h_axis, h_plot1, ax]);
	end;

        axss = get(h_fig,'UserData');
        h_plot1 = axss(2);
        h_axiss = axss(1);
        if (min(axss(3:6)==ax) < 1) & (length(ax) == 4)
          set(h_axiss,'Xlim',ax(1:2),'Ylim',ax(3:4))
          set(h_fig, 'UserData', [axss(1:2) ax]);
        end;
        % Use none as Erasemode for fast plotting.
        if (x(1) ~= Inf) 
		set(h_plot1,'XData',[u(1),x(1)],'YData',[u(2),x(2)]);
	end
	sys = [u(1), u(2), x(3)];
        % Is it a sample hit ?
        if round((t - offset)/ts) == (t - offset)/ts
           set(h_plot1,'XData',[x(1),u(1)],'YData',[x(2),u(2)]);
        end
elseif flag == 4
% Return next sample hit
        ns = (t - offset)/ts;  % Number of samples
        sys = offset + (1 + floor(ns + 1000*eps*(1+ns)))*ts;
elseif flag  == 0, 
   sys = [0;2+1;0;2;0;0]; 	% System sizes - 2 discrete states, 2 inputs
   x0 = [Inf; Inf; 0]; 	% Flag to indicate first point
else 
    sys = [];
end
