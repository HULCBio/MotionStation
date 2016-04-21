function varargout = dspblkdsamp2(action,varargin)
% DSPBLKDSAMP2 Signal Processing Blockset Downsample block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.4.4.2 $ $Date: 2004/04/12 23:06:18 $

if nargin==0, action = 'dynamic'; end

blk   = gcbh;
fullblk = getfullname(blk);

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
   
end
