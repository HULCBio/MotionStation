function [si,so,icontxt] = dspblkrc2lpc(action, perr, stability)
% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.1 $ $Date: 2002/07/26 15:15:02 $

if nargin==0, action='dynamic'; end
blk = gcbh;
output = get_param(blk,'conversion');  

switch action
case 'icon'
   % Input port labels:
   si(1).port = 1;
   % Output port labels:
   i = 1;
   so(i).port = 1;
   switch output
   case 'RC to LPC'       
       si(1).txt = 'K';
       so(i).txt = 'A';
       icontxt = 'RC to\n LPC';
   case 'LPC to RC'
       si(1).txt = 'A';
       so(i).txt = 'K';
       icontxt = ' LPC \nto RC';
   end
       
   if perr ,
      i=i+1;
      so(i).port = i;
      so(i).txt = 'P';
   end
   if stability
       i = i+1;
       so(i).port = i;
       so(i).txt  = 'S';
   end
 
   for j=i+1:3, so(j)=so(i); end
   
case 'dynamic'
   mask_visibles = get_param(blk,'MaskVisibilities');			
   if (strcmp(output, 'RC to LPC'))
       mask_visibles{4} = 'off';
   else 
       mask_visibles{4} = 'on';
   end
   set_param(blk,'MaskVisibilities',mask_visibles);
   
end

% [EOF] dspblkrc2lpc.m
