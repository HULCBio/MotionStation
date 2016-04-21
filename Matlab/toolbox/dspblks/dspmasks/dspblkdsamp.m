function varargout = dspblkdsamp(action,varargin)
% DSPBLKDSAMP Signal Processing Blockset Downsample block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.6.4.2 $ $Date: 2004/04/12 23:06:17 $

if nargin==0, action = 'dynamic'; end

blk   = gcbh;
fullblk = getfullname(blk);
frame = strcmp(get_param(blk,'Frame'),'on');

switch action 
case 'icon'
   % Determine string to display in icon
   % This represents the sample count parameter
   eval_fct = varargin{1};  % evaluated sample count (could be empty if problem occurred)
   lit_fct  = varargin{2};   % literal sample count string (exactly what user entered)
   
   if isempty(eval_fct),
      % Problem probably occurred
      fctstr = lit_fct;
   else
      % have an evaluated expression
      if ~isnumeric(eval_fct) | prod(size(eval_fct))~=1,
         fctstr = '?';
      else
         fctstr = num2str(eval_fct);
      end
   end
   x = [0 NaN 1 NaN .3 .3 NaN .2 .3 NaN .3 .4];
   y = [0 NaN 1 NaN .2 .8 NaN .4 .2 NaN .2 .4];
   varargout = {fctstr, x,y};
   
case 'dynamic'
   % Dynamic dialog callback:
   mask_enables = get_param(blk,'maskenables');
   if frame,
      mask_enables{4} = 'off';
      mask_enables{6} = 'on';
      mask_enables{7} = 'on';
   else
      mask_enables{4} = 'on';
      mask_enables{6} = 'off';
      mask_enables{7} = 'off';
   end
   set_param(blk,'maskenables',mask_enables);
end
