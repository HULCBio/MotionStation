function varargout = dspblkoverwrite(action)
% DSPBLKOVERWRITE Signal Processing Blockset Overwrite Values block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
%  

if nargin==0, action = 'dynamic'; end

blk = gcb;

switch action
case 'icon'
   puOverWriteDiag = get_param(blk,'OverWriteDiag');
  if strcmp(puOverWriteDiag, 'Submatrix'),
   x1=[.27 .17 .17 .27 NaN .755 .855 .855 .755]; 
   y1=[.92 .92 .1 .1 NaN .92 .92 .1 .1];
   S=8; t=(0:S)'/S*2*pi; a=0.05;
   x=a*cos(t);y=a*sin(t);
   
   xm =[-0.05 -0.03 NaN  0.03  0.05 NaN -0.05 -0.03 NaN 0.03 0.05 NaN -0.04 0.04 NaN -0.04  0.04]';
   ym =[-0.05 -0.05 NaN -0.05 -0.05 NaN 0.05   0.05 NaN 0.05 0.05 NaN -0.05 0.05 NaN  0.05 -0.05]';
   
   xmc=xm*ones(1,4) + ones(size(xm))*[.5 .5 .7 .7];
   ymc=ym*ones(1,4) + ones(size(xm))*[.5 .75 .5 .75];
   
   xc=x*ones(1,5) + ones(size(t))*[.3 .3 .3 .5 .7];
   yc=y*ones(1,5) + ones(size(t))*[.25 .5 .75 0.25 0.25];
   
   xi=[.4 .8 .8 .4 .4]; 
   yi=[.375 .375 .875 .875 .375];   
   
   varargout = {x1,y1,xc,yc,xmc,ymc,xi,yi};
  else
   x1=[.27 .17 .17 .27 NaN .755 .855 .855 .755];
   y1=[.92 .92 .1 .1 NaN .92 .92 .1 .1];
   S=8; t=(0:S)'/S*2*pi; a=0.05;
   x=a*cos(t);y=a*sin(t);
   
   xm =[-0.05 -0.03 NaN  0.03  0.05 NaN -0.05 -0.03 NaN 0.03 0.05 NaN -0.04 0.04 NaN -0.04  0.04]';
   ym =[-0.05 -0.05 NaN -0.05 -0.05 NaN 0.05   0.05 NaN 0.05 0.05 NaN -0.05 0.05 NaN  0.05 -0.05]';
   
   xmc=xm*ones(1,3) + ones(size(xm))*[.3  .5 .7 ];
   ymc=ym*ones(1,3) + ones(size(xm))*[.75 .5 .25];
   
   xc=x*ones(1,6) + ones(size(t))*[.3 .3  .5  .5  .7  .7];
   yc=y*ones(1,6) + ones(size(t))*[.5 .25 .75 .25 .75 .5];
   
   xi=[0.21  0.21 0.665 0.79  0.79   0.335   0.21];  
   yi=[0.845 0.723 0.15  0.15  0.27 0.845 0.845];
   
   varargout = {x1,y1,xc,yc,xmc,ymc,xi,yi};  
  end   
     
case 'dynamic'
   %  1  - Overwrite diagonal elemnts: OverWriteDiag
   %  2  - Constant: ConstValue
   %  3  - Diagonal span: DiagSpan (All, One, Range)
   %  4  - Starting element: DiagStartMode (First, Index, Offset from last, Last, Offset from middle, Middle)
   %  5  - Starting element index: DiagStartIndex (numeric)
   %  6  - Ending element: DiagEndMode (Index, Offset from last, Last, Offset from middle, Middle)
   %  7  - Ending element index: DiagEndIndex (numeric)
   
   %  8  - Row span: RowSpan (All, One, Range)
   %  9  - Starting row: RowStartMode (First, Index, Offset from last, Last, Offset from middle, Middle)
   %  10 - Starting row index: RowStartIndex (numeric)
   %  11 - Ending row: RowEndMode (Index, Offset from last, Last, Offset from middle, Middle)
   %  12 - Ending row index: RowEndIndex (numeric)
   %
   %  13 - Column span: ColSpan (All, One, Range)
   %  14 - Starting column: ColStartMode (First, Index, Offset from last, Last, Offset from middle, Middle)
   %  15 - Starting column index: ColStartIndex (numeric)
   %  16 - Ending column: ColEndMode (Index, Offset from last, Last, Offset from middle, Middle)
   %  17 - Ending column index: ColEndIndex (numeric)
   %
   orig_mask_enables = get_param(blk,'MaskEnables');
   ena = orig_mask_enables;
   orig_mask_vis = get_param(blk,'MaskVisibilities');
   vis = orig_mask_vis;
   orig_mask_prompts = get_param(blk,'MaskPrompts');
   prompts = orig_mask_prompts;

   
   pu_valFrom2ndIP = get_param(blk,'valFrom2ndIP');
   if strcmp(pu_valFrom2ndIP, 'Second input port'),       
       ena(3) = {'off'};
   else
       ena(3) = {'on'};
   end    

   % Diagonal
   puOverWriteDiag = get_param(blk,'OverWriteDiag');
   if strcmp(puOverWriteDiag, 'Diagonal'),
       vis(4:13) = {'off'};
       ena(4:13) = {'off'};
       
       vis(14:18) = {'on'};
       ena(14:18) = {'on'};       
      
   switch get_param(gcb,'DiagSpan');
   case 'All elements'
       vis(15:18) = {'off'};
       ena(15:18) = {'off'};
   case 'One element'
       vis(15:18) = {'on'};
       ena(15:16) = {'on'};
       ena(17:18) = {'off'};
       prompts(15) = {'Element:             '};
       tempstart_row = {'E'};    
   case 'Range of elements'
       vis(15:18) = {'on'};
       ena(15:18) = {'on'};
       prompts(15) = {'Starting element:'};
       tempstart_row = {'Starting e'};
   end
   if strcmp(ena{15},'on'),
       switch get_param(gcb,'DiagStartMode')
       case {'First', 'Middle'}
           ena(16) = {'off'};
       case 'Last'
           ena(16) = {'off'};
           ena(17) = {'off'};
           ena(18) = {'off'};
       case 'Index'
           ena(16) = {'on'};
           prompts(16) = strcat(tempstart_row,'lement index:');
       case {'Offset from last', 'Offset from middle'}
           ena(16) = {'on'};
           prompts(16) = strcat(tempstart_row,'lement offset:');
       end
   end
   if strcmp(ena{17},'on'),
       switch get_param(gcb,'DiagEndMode')
       case {'Last', 'Middle'}
           ena(18) = {'off'};
       case 'Index'
           ena(18) = {'on'};
           prompts(18) = {'Ending element index:'};
       case {'Offset from last', 'Offset from middle'}
           ena(18) = {'on'};
           prompts(18) = {'Ending element offset:'};
       end
   end

   else
       vis(14:18) = {'off'};
       ena(14:18) = {'off'};
       
       vis(4:13) = {'on'};
       ena(4:13) = {'on'};
   
   % Rows
   switch get_param(gcb,'RowSpan');
   case 'All rows'
       vis(5:8) = {'off'};
       ena(5:8) = {'off'};
   case 'One row'
       vis(5:8) = {'on'};
       ena(5:6) = {'on'};
       ena(7:8) = {'off'};
       prompts(5) = {'Row:             '};
       tempstart_row = {'R'};    
   case 'Range of rows'
       vis(5:8) = {'on'};
       ena(5:8) = {'on'};
       prompts(5) = {'Starting row:'};
       tempstart_row = {'Starting r'};
   end
   if strcmp(ena{5},'on'),
       switch get_param(gcb,'RowStartMode')
       case {'First', 'Middle'}
           ena(6) = {'off'};
       case 'Last'
           ena(6) = {'off'};
           ena(7) = {'off'};
           ena(8) = {'off'};
       case 'Index'
           ena(6) = {'on'};
           prompts(6) = strcat(tempstart_row,'ow index:');
       case {'Offset from last', 'Offset from middle'}
           ena(6) = {'on'};
           prompts(6) = strcat(tempstart_row,'ow offset:');
       end
   end
   if strcmp(ena{7},'on'),
       switch get_param(gcb,'RowEndMode')
       case {'Last', 'Middle'}
           ena(8) = {'off'};
       case 'Index'
           ena(8) = {'on'};
           prompts(8) = {'Ending row index:'};
       case {'Offset from last', 'Offset from middle'}
           ena(8) = {'on'};
           prompts(8) = {'Ending row offset:'};
       end
   end

   % Columns
   %
   switch get_param(gcb,'ColSpan');
   case 'All columns'
       vis(10:13) = {'off'};
       ena(10:13) = {'off'};
   case 'One column'
       vis(10:13) = {'on'};
       ena(10:11) = {'on'};
       ena(12:13) = {'off'};
       prompts(10) = {'Column:             '};
       tempstart_col = {'C'};
   case 'Range of columns'
       vis(10:13) = {'on'};
       ena(10:13) = {'on'};
       prompts(10) = {'Starting column:'};
       tempstart_col = {'Starting c'};
   end
   if strcmp(ena{10},'on'),
       switch get_param(gcb,'ColStartMode')
       case {'First', 'Middle'}
           ena(11) = {'off'};
       case 'Last'
           ena(11) = {'off'};
           ena(12) = {'off'};
           ena(13) = {'off'};
      case 'Index'
           ena(11) = {'on'};
           prompts(11) = strcat(tempstart_col,'olumn index:');
      case {'Offset from last', 'Offset from middle'}
           ena(11) = {'on'};
           prompts(11) = strcat(tempstart_col,'olumn offset:');
      end
   end
   if strcmp(ena{12},'on'),
       switch get_param(gcb,'ColEndMode')
       case {'Last', 'Middle'}
           ena(13) = {'off'};
       case 'Index'
           ena(13) = {'on'};
           prompts(13) = {'Ending column index:'};
       case {'Offset from last', 'Offset from middle'}
           ena(13) = {'on'};
           prompts(13) = {'Ending column offset:'};
       end
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

% [EOF] dspblkoverwrite.m
