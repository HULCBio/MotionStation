function varargout = dspblkmview(action, varargin)
% DSPBLKMVIEW Signal Processing Blockset matrix viewer block helper function.


% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.6.4.2 $ $Date: 2004/04/12 23:06:56 $

% Params structure fields:
%
% (1) ImageProperties: checkbox
% 2 CMap: Nx3 colormap matrix
% 3 YMin: minimum Z-limit
% 4 YMax: maximum Z-limit
% 5 NumCols: Number of columns in input matrix
% 6 AxisColorbar: checkbox
%
% (7) AxisParams: checkbox
% 8 AxisOrigin
% 9 XLabel
% 10 YLabel
% 11 ZLabel
% 12 FigPos: figure position
% 13 AxisZoom: checkbox

blk = gcb;

switch action
case 'init'

    % Copy all mask entries to structure:
    n = get_param(blk,'masknames');
    s = cell2struct(varargin,n,2);
    varargout{1} = s;
    
    % disp('dspblkmview: need to call DialogApply...');
	sdspmview([],[],[],'DialogApply',s);


case 'dynamic'
   orig_vis = get_param(blk,'maskvisibilities');
   vis = orig_vis;
   
   switch varargin{1}
   case 'ImageParams'
      % Set visibility of main image parameters:
      if strcmp(get_param(blk,'ImageParams'),'on');
         vis(2:6)={'on'};
      else
         vis(2:6)={'off'};
      end
      
   case 'AxisParams'
      % Set visibility of axis parameters:
      if strcmp(get_param(blk,'AxisParams'),'on');
         vis(8:13)={'on'};
      else
         vis(8:13)={'off'};
      end
            
   otherwise
      error('Unknown dynamic dialog callback');
   end
   
   if ~isequal(vis,orig_vis),
      set_param(blk, 'maskvisibilities',vis);
   end
end

% [EOF] dspblkmview.m
