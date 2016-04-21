function varargout = dspblksubmatrix(action)
% DSPBLKSUBMATRIX Signal Processing Blockset Submatrix block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.8.4.2 $ $Date: 2004/04/12 23:07:24 $

if nargin==0, action = 'dynamic'; end

blk = gcb;

switch action
case 'icon'
   x1=[.2 .1 .1 .2 NaN .825 .925 .925 .825];
   y1=[.9 .9 .1 .1 NaN .9 .9 .1 .1];
   S=8; t=(0:S)'/S*2*pi; a=0.05;
   x=a*cos(t);y=a*sin(t);
   xc=x*ones(1,9) + ones(size(t))*[.3 .3 .3 .5 .5 .5 .7 .7 .7];
   yc=y*ones(1,9) + ones(size(t))*[.25 .5 .75 .25 .5 .75 .25 .5 .75];
   xi=[.4 .8 .8 .4 .4]; yi=[.375 .375 .875 .875 .375];
   
   varargout = {x1,y1,xc,yc,xi,yi};
     
case 'dynamic'
   %  1 - Row span: RowSpan (All, One, Range)
   %  2 - Starting row: RowStartMode (First, Index, Offset from last, Last, Offset from middle, Middle)
   %  3 - Starting row index: RowStartIndex (numeric)
   %  4 - Ending row: RowEndMode (Index, Offset from last, Last, Offset from middle, Middle)
   %  5 - Ending row index: RowEndIndex (numeric)
   %
   %  6 - Column span: ColSpan (All, One, Range)
   %  7 - Starting column: ColStartMode (First, Index, Offset from last, Last, Offset from middle, Middle)
   %  8 - Starting column index: ColStartIndex (numeric)
   %  9 - Ending column: ColEndMode (Index, Offset from last, Last, Offset from middle, Middle)
   % 10 - Ending column index: ColEndIndex (numeric)
   %
   orig_mask_enables = get_param(blk,'MaskEnables');
   ena = orig_mask_enables;
   orig_mask_vis = get_param(blk,'MaskVisibilities');
   vis = orig_mask_vis;
   orig_mask_prompts = get_param(blk,'MaskPrompts');
   prompts = orig_mask_prompts;

   % Dialog entries with callbacks:
   %  1, 2, 4, 6, 7, 9
   
   % Rows
   %
   switch get_param(gcb,'RowSpan');
   case 'All rows'
       vis(2:5) = {'off'};
       ena(2:5) = {'off'};
   case 'One row'
       vis(2:5) = {'on'};
       ena(2:3) = {'on'};
       ena(4:5) = {'off'};
       prompts(2) = {'Row:             '};
       tempstart_row = {'R'};    
   case 'Range of rows'
       vis(2:5) = {'on'};
       ena(2:5) = {'on'};
       prompts(2) = {'Starting row:'};
       tempstart_row = {'Starting r'};
   end
   if strcmp(ena{2},'on'),
       switch get_param(gcb,'RowStartMode')
       case {'First', 'Middle'}
           ena(3) = {'off'};
       case 'Last'
           ena(3) = {'off'};
           ena(4) = {'off'};
           ena(5) = {'off'};
       case 'Index'
           ena(3) = {'on'};
           prompts(3) = strcat(tempstart_row,'ow index:');
       case {'Offset from last', 'Offset from middle'}
           ena(3) = {'on'};
           prompts(3) = strcat(tempstart_row,'ow offset:');
       end
   end
   if strcmp(ena{4},'on'),
       switch get_param(gcb,'RowEndMode')
       case {'Last', 'Middle'}
           ena(5) = {'off'};
       case 'Index'
           ena(5) = {'on'};
           prompts(5) = {'Ending row index:'};
       case {'Offset from last', 'Offset from middle'}
           ena(5) = {'on'};
           prompts(5) = {'Ending row offset:'};
       end
   end

   % Columns
   %
   switch get_param(gcb,'ColSpan');
   case 'All columns'
       vis(7:10) = {'off'};
       ena(7:10) = {'off'};
   case 'One column'
       vis(7:10) = {'on'};
       ena(7:8) = {'on'};
       ena(9:10) = {'off'};
       prompts(7) = {'Column:             '};
       tempstart_col = {'C'};
   case 'Range of columns'
       vis(7:10) = {'on'};
       ena(7:10) = {'on'};
       prompts(7) = {'Starting column:'};
       tempstart_col = {'Starting c'};
   end
   if strcmp(ena{7},'on'),
       switch get_param(gcb,'ColStartMode')
       case {'First', 'Middle'}
           ena(8) = {'off'};
       case 'Last'
           ena(8) = {'off'};
           ena(9) = {'off'};
           ena(10) = {'off'};
      case 'Index'
           ena(8) = {'on'};
           prompts(8) = strcat(tempstart_col,'olumn index:');
      case {'Offset from last', 'Offset from middle'}
           ena(8) = {'on'};
           prompts(8) = strcat(tempstart_col,'olumn offset:');
      end
   end
   if strcmp(ena{9},'on'),
       switch get_param(gcb,'ColEndMode')
       case {'Last', 'Middle'}
           ena(10) = {'off'};
       case 'Index'
           ena(10) = {'on'};
           prompts(10) = {'Ending column index:'};
       case {'Offset from last', 'Offset from middle'}
           ena(10) = {'on'};
           prompts(10) = {'Ending column offset:'};
       end
   end

   if ~isequal(ena, orig_mask_enables),
       set_param(blk, 'MaskEnables', ena);
   end
   if ~isequal(vis, orig_mask_vis),
       set_param(blk, 'MaskVisibilities', vis);
   end
   if ~isequal(prompts, orig_mask_prompts),
       set_param(blk, 'MaskPrompts', prompts);
   end
end % end of switch statement

% [EOF] dspblksubmatrix.m
