function varargout= dspblknsample(action,varargin)
% DSPBLKNSAMPLE Signal Processing Blockset N-Sample Enable block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.11.4.2 $ $Date: 2004/04/12 23:06:58 $

if nargin==0, action = 'dynamic'; end

blk   = gcbh;
reset = strcmp(get_param(blk,'Reset'),'on');

switch action
case 'icon'
   % Construct block icon:
   
   % Determine string to display in icon
   % This represents the sample count parameter
   eval_cnt = varargin{1};  % evaluated sample count (could be empty if problem occurred)
   lit_cnt  = varargin{2};   % literal sample count string (exactly what user entered)
   
   if isempty(eval_cnt),
      % Problem probably occurred
      cntstr = lit_cnt;
   else
      % have an evaluated expression
      if ~isnumeric(eval_cnt) | prod(size(eval_cnt))~=1,
         cntstr = '?';
      else
         cntstr = num2str(eval_cnt);
      end
   end
   
   % Draw rest of icon:
	S=12; t=(0:S)/S*2*pi; a=0.05; xc=a*cos(t); yc=a*sin(t);
	xc4=[xc+.45 NaN xc+.45 NaN xc+.8];
	yc4=[yc+3/4 NaN yc+1/4 NaN yc+.5];
	xs=[xc(4:9) xc(9)+[-.03 0 -.01] ]*3.5+.8;
	ys=[yc(4:9) yc(9)+[0.01 0 .03 ] ]*3.5+.5;
	x=[ .85 1 NaN .4 .15 .15 NaN .075 .225 .15 .075 NaN  .4 .15 .15 NaN .075 .225 NaN .1 .2 NaN .125 .175 NaN .75 .525 NaN .595 .525 .55];
   y=[ .5 .5 NaN .75 .75 .85 NaN .85 .85 1 .85 NaN  .25 .25 .1 NaN .1 .1 NaN .05 .05 NaN .0 .0 NaN .5 .7 NaN .7 .7 .61];  
   
   % Concat all x/y pairs into a single x and y
   x = [x NaN xs NaN xc4];
   y = [y NaN ys NaN yc4];
   
   if reset,
      pl.side = 'input';
      pl.port = 1;
      pl.label = 'Rst';
   else
      pl.side = 'output';
      pl.port = 1;
      pl.label = '';
   end
   
   
   varargout = {cntstr, x,y, pl};
   
case 'update'
   
   % If triggering not selected, set trigger type to 0.
   % Otherwise, leave trigger type as 1 (rising), 2 (falling), 3 (either)
   TriggerTypei = varargin{1};
   if reset,
      TriggerTypeo = TriggerTypei;
   else
      TriggerTypeo = 0;
   end
   varargout = {TriggerTypeo};
   
   
case 'dynamic'
   % Dynamic dialog callback:
   
   mask_enables = get_param(blk,'maskenables');
   if reset,
      mask_enables{4} = 'on';
      mask_enables{5} = 'off';   
   else
      mask_enables{4} = 'off';
      mask_enables{5} = 'on';
   end
   set_param(blk,'maskenables',mask_enables);
end

% [EOF] dspblknsample.m

