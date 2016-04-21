function  [sys, x0,str, ts]  = sbufscop(t,x,u,flag,scaling,domain,figpos,ylabelstr,rads)
%sbufscop SIMULINK vector scope S-Function.
%	sbufscop is a SIMULINK S-Function that plots the input vector in
%	a Handle Graphics(tm) figure window.  The figure is named and tagged
%	with the full name of the scope block.
%
%	The input vector can be interpreted as a vector of sampled data or 
%	a vector of frequencies.  The calling sequence is:
%	    sbufscop(T,X,U,FLAG,SCALING,DOMAIN,FIGPOS,YLABELSTR,RADS)
%	The first four input arguments T, X, U, and FLAG are the four 
%	required SIMULINK input arguments.  The other parameters are:
%	    SCALING determines the X-axis limits.
%	    DOMAIN specifies whether the input is time or frequency data.
%	    FIGPOS is a position rectangle in pixels which specifies
%	     the position of the scope's figure window.
%	    YLABELSTR is an optional argument that specifies the Y-label.  
%	     Default is 'Magnitude'.
%	    RADS is an optional argument that is used to specify the units 
%	     for the X-axis.  If 1 the X-axis units are in radians or if 0 
%	     (the default if not present) the X-axis units are in hertz (Hz).

%   7/22/94
%   Revised: T. Krauss 20-Sep-94, D. Orofino 1-Feb-97, S. Zlotkin 20-Feb-97
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.25.4.3 $  $Date: 2004/04/12 23:05:27 $


% What's in the Figure userdata:

%		fig_data.hfig              	handle to figure
%		fig_data.blockname         	block name
%		fig_data.hax              		handle to axes
%		fig_data.hline             	handle to line
%		fig_data.freeze            	setting of freeze for y-axis
%		fig_data.memory            	setting of memory
%		fig_data.memory_set_freeze 	setting of freeze before checking memory

%
% What's in the Block userdata:

%		block_data.firstcall				flag for first call to function
%		block_data.hfig					handle to figure	
%		block_data.hax						handle to axes
%		block_data.hline					handle to line
%		block_data.scaling				x-axis limits
%		block_data.rads					units for x-axis
%		block_data.domain					domain of input data (time or freq)

	
if isstr(t)
   
   %--------------------------------------------------------------------------
   % sbufscop('action')
   %   Callbacks of scope uicontrols.
   %   Callback of figure's menu item
   
   switch t
      
   case 'namechange',
      % In response to the name change, we must do the following:
      % (1) find the old figure window, only if the block had a GUI 
      % associated with it:

      % Current block is parent to S-function block
      block_name = gcb;
      block_data = get_param(block_name,'userdata');
      if isstruct(block_data),
         
         % (2) change name of figure window (cosmetic)
	      hfig = block_data.hfig;
   	   set(hfig,'name',block_name);
      
	      % (3) update figure's userdata so that the new blockname can be used
   	   % if the figure gets deleted
      	fig_data = get(hfig,'userdata');
	      fig_data.blockname = block_name;
         set(hfig,'userdata',fig_data);
      end      
      
   case 'figdelete',
      % when the figure is closed or deleted, take the same action:
      % set hfig in the block's userdata to null 
      
      % figure's handle visibility has been set off
      % so show all hidden handles, get the figure, 
      % and turn hidden handle back off
      set(0,'showhiddenhandles','on'); hfig = gcbf; set(0,'showhiddenhandles','off');
      
      fig_data = get(hfig,'userdata');
      if hfig ~= fig_data.hfig,
         error('Wrong figure handle, hfig, in figure''s userdata');
      end
      block_name = fig_data.blockname;  % parent to S-fcn
      
      % reset the block's figure handle to null:
      block_data = get_param(block_name,'userdata');
      block_data.hfig = [];
      set_param(block_name, 'userdata',block_data);
      
      set(hfig,'DeleteFcn','');
      delete(hfig);

	case 'figposrecord',
      % record the current position of the figure into the block's mask

      % figure's handle visibility has been set off
      % so show all hidden handles, get the figure, 
      % and turn hidden handle back off
      set(0,'showhiddenhandles','on'); hfig = gcbf; set(0,'showhiddenhandles','off');
            
      % Get the block's name:
      fig_data = get(hfig,'userdata');
      if hfig ~= fig_data.hfig,
         error('wrong hfig in figure data');
      end
      block_name = fig_data.blockname;  % parent to S-fcn
      
      % Record the figure position, as a string, into the appropriate mask dialog:
      figpos = get(hfig,'position');                    % Get the fig position in pixels
      set_param(block_name, 'figpos', mat2str(figpos)); % Record new position
      
    case 'blockdelete'
      % block is being deleted from the model
      % clear out figure's close function
      % delete figure manually
      block_name = gcb;
      block_data = get_param(block_name,'userdata');
     
      if isstruct(block_data),
         hfig = block_data.hfig;
         set(hfig,'DeleteFcn','');
         delete(hfig);
         block_data.hfig = [];
         set_param(block_name,'userdata',block_data);
      end   
      
   case 'blockcopy'
      % block is being copied from the model
      % clear out stored figure handle
      block_name = gcb;

      block_data = get_param(block_name,'userdata');
      if isstruct(block_data),
         block_data.hfig = [];
         set_param(block_name,'userdata',block_data);
      end
      
   case 'freeze',
      % figure's handle visibility has been set off
      % so show all hidden handles, get the figure, 
      % and turn hidden handle back off
      set(0,'showhiddenhandles','on'); hfig = gcf; set(0,'showhiddenhandles','off');

      u = findobj(hfig,'tag','freeze');
      fig_data = get(hfig,'userdata');

      if strcmp(get(u,'checked'),'on'),
         % Turn off freeze:
         set(u,'checked','off');
         fig_data.freeze = 0;
         
         % Unconditionally reset the "memory turned on freeze" flag
         % and turn off Memory if it is on.
         if fig_data.memory,
            if fig_data.memory_set_freeze,
	            fig_data.memory_set_freeze = 0;
               set(hfig,'userdata',fig_data);
            end
            sbufscop('memory'); % turn if off
         else
            if fig_data.memory_set_freeze,
               error('memory_set_freeze should not be on!');
            end            
         end
		 
      else
         % Turn on freeze:
         set(u,'checked','on');
         fig_data.freeze = 1;
      end
      
      set(hfig,'userdata',fig_data);
      
   case 'linestyle',
      % figure's handle visibility has been set off
      % so show all hidden handles, get the figure, 
      % and turn hidden handle back off
      set(0,'showhiddenhandles','on'); hfig = gcf; set(0,'showhiddenhandles','off');

      u = findobj(hfig,'tag','linestyle');
      ch = get(u,'children');
      set(ch,'checked','off');
      style_entry = findobj(ch,'label',[' ' x]);
      set(style_entry, 'checked','on');

      % Store linestyle
      fig_data = get(hfig,'userdata');
      set(fig_data.hline,'linestyle',x);
      
   case 'marker',
      % figure's handle visibility has been set off
      % so show all hidden handles, get the figure, 
      % and turn hidden handle back off
      set(0,'showhiddenhandles','on'); hfig = gcf; set(0,'showhiddenhandles','off');
      
      fig_data = get(hfig,'userdata');
      hline = fig_data.hline;
      % hline = findobj(hfig,'type','line','tag','line');

      u = findobj(hfig,'tag','marker');
      ch = get(u,'children');
      mfill = findobj(ch,'label','Filled');
      
      if strcmp(x,'(fill)'),
         % Fill in marker types:
         fill_on = strcmp(get(mfill,'checked'),'on'); % current status
         
         % Toggle status, and update check-box:
         fill_on=1-fill_on;  % Toggle it
         if fill_on, s='on'; else s='off'; end
         set(mfill,'checked',s);
         
         if fill_on,
            % Get line fill color:
            ch = get(findobj(hfig,'tag','linecolor'),'children');
            ch=findobj(ch,'checked','on');
            c = get(ch,'userdata');
         else
            c='auto';
         end
         set(hline,'markerfacecolor',c);
         
      else
         % Set new marker type:
         ch(find(ch == mfill))=[];                % Remove it from list
         set(ch,'checked','off');                 % Turn off check on ALL marker entries
         marker_submenu = findobj(ch,'label',x);  % Find this marker
         set(marker_submenu, 'checked','on');     % Turn on its check
         
         mrk = get(marker_submenu, 'userdata');
         set(hline,'marker', mrk);
      end
      
      
   case 'linecolor',
      % figure's handle visibility has been set off
      % so show all hidden handles, get the figure, 
      % and turn hidden handle back off
      set(0,'showhiddenhandles','on'); hfig = gcf; set(0,'showhiddenhandles','off');

      ch = get(findobj(hfig,'tag','linecolor'),'children');
      set(ch,'checked','off')
      linecolor_submenu = findobj(ch,'label',x);
      set(linecolor_submenu, 'checked','on')
      
      clr = get(linecolor_submenu,'userdata');
      
      hline = findobj(hfig,'type','line','tag','line');
      set(hline,'color',clr);

   case 'memory',
      % figure's handle visibility has been set off
      % so show all hidden handles, get the figure, 
      % and turn hidden handle back off
      set(0,'showhiddenhandles','on'); hfig = gcf; set(0,'showhiddenhandles','off');

      % In order to "freeze" the axis contents, we cannot allow automatic
      % rescaling of the y-axis; this would cause a complete refresh of the
      % graph window at the time that the rescale occurs, and looks like a random "refresh".
      % To fix this, we automatically freeze y-limits.
      %
      % NOTE: If the user turns OFF the "Freeze y-limits", we must also turn off
      % the memory option.
      %
      % The only problem if: (1) the user turns on memory (and therefore we automatically
      % turn on the freeze), then (2) the user turns OFF memory ... do we turn off freeze?
      % Well, if we turned in ON automatically, then I guess we should also turn it off
      % automatically too, but HOW DO WE KNOW we turned it on automatically. 
      % We'll store a flag in memory_set_freeze flag in the figure's userdata.
      fig_data = get(hfig,'userdata');

      u = findobj(hfig,'tag','memory');
      if strcmp(get(u,'checked'),'on')
         % Turning off Memory:
         
         set(u,'checked','off')
         set(0,'showhiddenhandles','on'); 
         hfig = gcf; 
         refresh(hfig);
         set(0,'showhiddenhandles','off');
         emode = 'xor';
         set(findobj(hfig,'tag','line'),'EraseMode',emode);
         
         fig_data.memory = 0;  % Memory turned off
         
         % Check if memory turned on freeze
         % If so, turn it off, and record that fact
         if fig_data.memory_set_freeze,  % We turned it on
            fig_data.memory_set_freeze = 0;
            set(hfig,'userdata',fig_data);
            
            % Consistency check: if memory set freeze, then freeze
            % had better be on:
            if ~fig_data.freeze,
               error('Memory turned on freeze, but it''s not current on');
            end
            sbufscop('freeze');  % Turn off freeze
         else
				set(hfig,'userdata',fig_data);
         end
         
      else
         % Turning on Memory:
         set(u,'checked','on')
         set(findobj(hfig,'tag','line'),'EraseMode','none');         
         
         fig_data.memory = 1;  % Memory turned on
         
         % Check if Freeze is on
         % If not, record that we turned it on automatically
         %     and turn it on
         if ~fig_data.freeze,
            % Freeze option currently turned off
            fig_data.memory_set_freeze = 1;  % We're turning it on
            set(hfig,'userdata',fig_data);
            sbufscop('freeze');
         else
            set(hfig,'userdata',fig_data);
         end
         
      end
      
   case 'refresh',
      set(0,'showhiddenhandles','on'); 
         hfig = gcf; 
         refresh(hfig);
         set(0,'showhiddenhandles','off');
      
   case 'xaxis',
      % Set the xlim, xlabel, and xdata of the scope
      %   sbufscop('xaxis',x,u)

      % The domain can take on one of three values:
      %   0: time-based real input vector
      %   1: frequency-based real input vector, plot first half of spectrum
      %   2: frequency-based real input vector, plot entire spectrum

      block_name = get_param(gcb,'parent');
      block_data = get_param(block_name,'userdata');
      hfig       = block_data.hfig;
      hax        = block_data.hax;
      hline      = block_data.hline;
      scaling    = block_data.scaling;
      rads       = block_data.rads;
      domain     = block_data.domain;
      
      if (domain == 0),
         % Time-domain:
         xlabel = 'Time';
         if length(u)<2,
            xlimits = [0 scaling];
         else
            xlimits = [0 (length(u)-1)*scaling];
         end
         xdata = 0:scaling:(length(u)-1)*scaling;
      else
         % Frequency domain:
         if (domain == 1),
            xlimits = [0 scaling/2];
         else
            xlimits = [0 scaling];
         end
         xlabel  = 'Frequency (Hz)';
         xdata   = (0:length(u)-1)*scaling/length(u);
         if rads,
            xlabel  = 'Frequency (rad/s)';
            xlimits = 2*pi*xlimits;
            xdata   = 2*pi*xdata;
         end
      end
      set(get(hax,'XLabel'),'String',xlabel);
      set(hax, 'xlim',xlimits);
      set(hline,'XData',xdata, 'YData',u);
      
   otherwise,
      error('Unknown string option passed to sbufscop');
   end
   
   % None of these options change the state:
   sys = [];
   
   return;
   
else

   % Next line just for compatibility with Signal Processing Blockset V1.0a blocks:
   if nargin<9, rads=1; end

   % Dispatch:
   switch flag,
      
   case 0,
      [sys,x0,str,ts]=mdlInitializeSizes(t,x,u,flag,scaling,domain,figpos,ylabelstr,rads);
      
   case 2,
      sys=mdlUpdate(t,x,u,flag,scaling,domain,figpos,ylabelstr,rads);
      
   otherwise,
      sys=[];
   end
end
% end of sbufscop

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts] = mdlInitializeSizes(t,x,u,flag,scaling,domain,figpos,ylabelstr,rads)

sizes = simsizes;
sizes.NumOutputs     = 0;
sizes.NumInputs      = -1;
sizes.NumSampleTimes = 1;
str = []; 

sys = simsizes(sizes);
x0  = [];
ts  = [-1 0];       % inherited sample time

block_name = get_param(gcb,'parent');
block_data = get_param(block_name,'userdata');
block_data.firstcall = 1;
set_param(block_name,'userdata',block_data);

%end mdlinitializeSizes

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,x,u,flag,scaling,domain,figpos,ylabelstr,rads)

%--------------------------------------------------------------------------
% sys = sbufscop(t,x,u,2)
%   FLAG 2: Return discrete states.
%   This is also used to update the scope during SIMULATION.
%

% Setup argument defaults:
if nargin<9, error('Incorrect number of args'); end

% gcb is the S-fcn block here:
block_name = get_param(gcb,'parent');
block_data = get_param(block_name,'userdata');

% The firstcall is only equal to one on the first call:
if block_data.firstcall,
   
   % Since firstcall is 1, this is a new simulation
   block_data.firstcall = 0;
   set_param(block_name,'userdata',block_data);
   
   % Construct new scope figure window, or bring up old one:
   if ~isfield(block_data,'hfig'),
      hfig = [];              % scope never run before
   else
      hfig = block_data.hfig; % scope already exists
   end
   
   % Establish figure window & line object
   % Determine line erase mode:
   emode = 'xor';
   
   if ~isempty(hfig),
      % Found existing scope figure window:
      
      figure(hfig);                        % Bring window forward
           
      % Determine "memory" setting:
      mh = findobj(hfig, 'tag','memory');  % Handle to memory menu
      if strcmp(get(mh,'checked'),'on'),
         emode = 'none';
      end
      
      fig_data = get(hfig,'userdata');
      
      hax = fig_data.hax;
      if isempty(hax),
         hax = axes('tag','axes');
      end
      
      hline = fig_data.hline;
      delete(hline);        % Delete line if it exists

      mlinestyle = findobj(hfig, ...
         'parent', findobj(hfig,'tag','linestyle'), ...
         'checked', 'on');
      mmarker    = findobj(hfig, ...
         'parent', findobj(hfig, 'tag','marker'), ...
         'checked', 'on');
      mlinecolor = findobj(hfig, ...
         'parent', findobj(hfig, 'tag','linecolor'), ...
         'checked', 'on');
      
      clr = get(mlinecolor,'userdata');
      
      % If marker-fill is checked, remove from mmarker:
      mfill = findobj(mmarker,'label','Filled');
      mmarker(find(mmarker == mfill)) = [];
      mrk = get(mmarker,'userdata');
      if isempty(mfill),
         mrkclr = 'auto';  % No fill for marker
      else
         mrkclr = clr;
      end
      
      % Need to display all hidden handles so that a new figure is not opened:
      % Figure's handle visibility has been set off
      % so show all hidden handles, get the figure, 
      % and turn hidden handle back off
      set(0,'showhiddenhandles','on');
      hline = line('xdata', NaN, 'ydata', NaN, ...
         'EraseMode', emode, ...
         'linestyle', get(mlinestyle, 'tag'), ...
         'marker',    mrk, ...
         'markerfacecolor', mrkclr, ...
         'color',     clr, ...
         'tag',       'line');
      
      set(0,'showhiddenhandles','off');
      
      % Update fig_data 
      fig_data.hline = hline;
      set(hfig,'userdata',fig_data);
      
   else
      
      % Initialize new figure window:
      parent_blockname = block_name;
      hfig  = figure('numbertitle', 'off', ...
         'name',         parent_blockname,...         % 'menubar',      'none',
         'position',     figpos, ...
         'nextplot',     'add',...
         'integerhandle','off',...
         'DeleteFcn',    'sbufscop(''figdelete'');');
      
      hax   = axes('tag','axes','box','on');
      hline = line('xdata',nan, 'ydata',nan, 'EraseMode',emode,'tag','line');

      % Establish settings for all stucture fields:
      fig_data.hfig              = hfig;
      fig_data.blockname         = block_name;      
      fig_data.hax               = hax;
      fig_data.hline             = hline;
      fig_data.freeze            = 0;  % off
      fig_data.memory            = 0;  % off
      fig_data.memory_set_freeze = 0;  % didn't

      % Let figure know about important handles
      set(hfig,'userdata',fig_data);
      
      % Setup OPTIONS menu:
      labels = {'Options', 'Freeze Y-limits', 'Line Style', 'Line Markers', ...
            'Line Color', 'Memory', 'Refresh'};
      
      if strcmp(computer,'PCWIN'),
         % Use "&" for accelerator characters on the PC:
         labels = {'&Options', '&Freeze Y-limits', 'Line &Style', 'Line &Markers', ...
                   'Line &Color', 'Memor&y', '&Refresh', 'Record &Position'};
      else
         labels = {'Options', 'Freeze Y-limits', 'Line Style', 'Line Markers', ...
                   'Line Color', 'Memory', 'Refresh', 'Record Position'};         
      end

      um = uimenu('label',labels{1});
      uimenu(um, 'label',labels{2}, 'callback','sbufscop(''freeze'');', 'tag','freeze');
      lsmenu = uimenu(um, 'label',labels{3}, 'tag','linestyle');
      lmmenu = uimenu(um, 'label',labels{4}, 'tag','marker');
      lcmenu = uimenu(um, 'label',labels{5}, 'tag','linecolor');
      
      uimenu(um, 'label',labels{6}, 'callback','sbufscop(''memory'');', ...
         'tag','memory', 'separator','on');
      
      uimenu(um, 'label',labels{7}, 'callback','sbufscop(''refresh'');', ...
         'tag','refresh');
      
      uimenu(um, 'label',labels{8}, 'callback', 'sbufscop(''figposrecord'');', ...
         'accel','R', 'separator','on');
            
      % Line styles submenu:
      uimenu(lsmenu,'label',' None','tag','None',...
         'callback','sbufscop(''linestyle'',''None'');');
      uimenu(lsmenu,'label',' -','tag','-',...
         'callback','sbufscop(''linestyle'',''-'');',...
         'checked','on')
      uimenu(lsmenu,'label',' --','tag','--',...
         'callback','sbufscop(''linestyle'',''--'');')
      uimenu(lsmenu,'label',' :','tag',':',...
         'callback','sbufscop(''linestyle'','':'');')
      uimenu(lsmenu,'label',' -.','tag','-.',...
         'callback','sbufscop(''linestyle'',''-.'');')
      
      % Line markers submenu:
      uimenu(lmmenu,'label','None','userdata','None',...
         'callback','sbufscop(''marker'',''None'');', ...
         'checked','on');
      uimenu(lmmenu,'label','+','userdata','+',...
         'callback','sbufscop(''marker'',''+'');')
      uimenu(lmmenu,'label','o','userdata','o',...
         'callback','sbufscop(''marker'',''o'');')
      uimenu(lmmenu,'label','*','userdata','*',...
         'callback','sbufscop(''marker'',''*'');')
      uimenu(lmmenu,'label','.','userdata','.',...
         'callback','sbufscop(''marker'',''.'');')
      uimenu(lmmenu,'label','x','userdata','x',...
         'callback','sbufscop(''marker'',''x'');')
      uimenu(lmmenu,'label','Square','userdata','Square',...
         'callback','sbufscop(''marker'',''Square'');')
      uimenu(lmmenu,'label','Diamond','userdata','Diamond',...
         'callback','sbufscop(''marker'',''Diamond'');');
      uimenu(lmmenu,'label','Filled',...
         'separator','on', ...
         'callback','sbufscop(''marker'',''(fill)'');');
      
      % Line colors submenu:
      uimenu(lcmenu,'label','Cyan','userdata','c',...
         'callback','sbufscop(''linecolor'',''Cyan'');',...
         'checked','on')
      uimenu(lcmenu,'label','Magenta','userdata','m',...
         'callback','sbufscop(''linecolor'',''Magenta'');')
      uimenu(lcmenu,'label','Yellow','userdata','y',...
         'callback','sbufscop(''linecolor'',''Yellow'');')
      uimenu(lcmenu,'label','Black','userdata','k',...
         'callback','sbufscop(''linecolor'',''Black'');')
      uimenu(lcmenu,'label','Red','userdata',[1 0 0],...
         'callback','sbufscop(''linecolor'',''Red'');')
      uimenu(lcmenu,'label','Green','userdata',[0 1 0],...
         'callback','sbufscop(''linecolor'',''Green'');')
      uimenu(lcmenu,'label','Blue','userdata',[0 0 1],...
         'callback','sbufscop(''linecolor'',''Blue'');')
      
      % Set line color, style, marker:
      sbufscop('linestyle', '-');
      sbufscop('linecolor', 'Magenta');
      sbufscop('marker',    'None');
   end

   %  Set the ylabel
   if ~isstr(ylabelstr),
      str = 'Magnitude';  % Default Y-label
   else
      str = ylabelstr;
   end
   
   set(get(hax,'YLabel'), 'String',str);

   % Retain the name of the figure window for use when the
   % block's name changes. Name is retained in S-fcn block's
   % user-data:
   block_data.hfig    = hfig;
   block_data.hax     = hax;
   block_data.hline   = hline;
   block_data.scaling = scaling;
   block_data.domain  = domain;  % 0=time, 1=half-freq, 2=full-freq (or vice-versa?)
   block_data.rads    = rads;
   
   set(hfig,'HandleVisibility','off');

   % Set block's user data:
   set_param(block_name, 'UserData', block_data);
   
   % Set block callbacks ONLY IF the block is not linked,
   % i.e., only set callbacks for "old" (DSP v1.0a) blocks.
   % You cannot set the callbacks for linked blocks, since the
   % callbacks are part of the block implementations
   if strcmp(get_param(block_name,'LinkStatus'),'none'),
      set_param(block_name, ...
		'NameChangeFcn','sbufscop(''namechange'');',  ...
                'DeleteFcn',    'sbufscop(''blockdelete'');', ...
                'CopyFcn',      'sbufscop(''blockcopy'');'      );
   end

   % Set the xlabel, xlim, and xdata:
   sbufscop('xaxis',x,u);

	% Return empty state vector, since we're not using any:
	sys = [];     
   
else
   % hfig is non-zero (contains a figure handle)
   % Either this is not the first call to flag 2, OR
   %   the simulation has been restarted with the scope
   % 	 remaining open.
   %
   % Return an empty state vector, since we're not using any:
   sys = [];

   % gcb is the s-fcn block at this point:
   block_name = get_param(gcb,'parent');
   block_data = get_param(block_name,'userdata');
   hfig       = block_data.hfig;
   
   % If the user closed the figure window while the simulation
   % is running, then the handle has been reset to empty.
   % Allow the simulation to continue, but DON'T put up a
   % new figure (or error out)
   if isempty(hfig),
      return;
   end
   
   hax   = block_data.hax;
   hline = block_data.hline;
end

%%%%%%%%%%%%%%%
% Do the following no matter whether it's a new simulation or not:
%
%   Adjust the Y limits.
%   If the ylimits are frozen (checked in the menu), don't change limits.
%   Otherwise, determine the min/max values and update the limits.
%   Note that the axis will always be increased as necessary, but only
%   decreased if the data range has decreased by at least a factor of 2.
set(hax,'ylimmode','manual');

fig_data = get(hfig,'userdata');
if ~fig_data.freeze;
   % Update of Y-limits:

   magMax = max(u); magMin = min(u);
   lims = get(hax,'ylim');
   % Determine if axis needs to be redrawn:
   d = abs(magMax-magMin);
   if d > sqrt(eps),
      % Grow axis whenever data exceeds axis limits.
      % Increase axis by 20 percent in appropriate direction:
      grow=0; shrink=0;
      if magMin < lims(1),
         lims(1) = magMin-abs(magMin*0.2);
         grow=1;
      end
      if magMax > lims(2),
         lims(2) = magMax+abs(magMax*0.2);
         grow=1;
      end
      if grow,
         set(hax,'ylim',lims);
      else
         % Only shrink when difference between max or min and
         % axis limit exceeds dynamic range of data.  In that case,
         % reset axis limit to halfway between old limit and
         % data max or min.
         if abs(lims(2)-magMax) > d,
            lims(2) = (lims(2)+magMax)/2;
            shrink=1;
         end
         if abs(lims(1)-magMin) > d,
            lims(1) = (lims(1)+magMin)/2;
            shrink=1;
         end
         if shrink,
            set(hax,'ylim',lims);
         end
      end
   end
end

% Check for a change in the scaling or units:
if (scaling ~= block_data.scaling) | (rads ~= block_data.rads) | (domain ~= block_data.domain),
   % Record info:
   block_data.scaling = scaling;
   block_data.rads    = rads;
   block_data.domain  = domain;
   set_param(block_name, 'userdata',block_data);
   
   % Adjust the xlim, xlabel, and xdata:
    sbufscop('xaxis',x,u);
end

% Plot the data:
set(hline, 'ydata',u);

%end mdlUpdate

