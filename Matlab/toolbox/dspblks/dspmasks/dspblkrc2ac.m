function [si,so, icontxt] = dspblkrc2ac(action,perr_spec)
% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.1 $ $Date: 2002/07/26 15:14:59 $
if nargin==0, action='dynamic'; end
blk = gcbh;
output = get_param(blk,'conversion');  

switch action
case 'icon'
   % Input port labels:
   i = 1;
   so(1).port = 1;
   so(1).txt = 'AC';
   si(i).port = 1;
   switch output
   case 'LPC to autocorrelation'       
       si(i).txt = 'A';
       icontxt = 'LPC to\n AC';
       
   case 'RC to autocorrelation'
       si(i).txt = 'K';
       icontxt = 'RC to\n AC';
       
   end

   if (perr_spec == 2)
     i = i + 1;
     si(i).port = 2;
     si(i).txt = 'P';
   end
   for j=i+1:2, si(j)=si(i); end
   
case 'dynamic'
   mask_visibles = get_param(blk,'MaskVisibilities');			
   if (strcmp(output, 'RC to autocorrelation'))
       mask_visibles{3} = 'off';
   else 
       mask_visibles{3} = 'on';
   end
   set_param(blk,'MaskVisibilities',mask_visibles);
       
end

% [EOF] dspblkrc2lpc.m