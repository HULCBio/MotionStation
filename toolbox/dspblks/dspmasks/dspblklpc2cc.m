function [si,so,icontxt] = dspblklpc2cc(action)
% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.3.6.2 $ $Date: 2004/04/12 23:06:50 $

if nargin==0, action='dynamic'; end
blk = gcbh;
needsize = get_param(blk,'sizecb');  
operation = get_param(blk,'conversion');  
needenergy = get_param(blk,'enerpp');  
outputpower  = get_param(blk,'outpower');

switch action
case 'icon'
   % Input port labels:
   i = 1;
   k = 1;
   si(i).port = 1;
   si(i).txt = '';
   so(k).port = 1;
   so(k).txt = '';
   % Output port labels:
   switch operation
   case 'LPCs to cepstral coefficients'       
       icontxt = 'LPC \nto CC';
       if strcmp(needenergy,'via input port')
           si(i).txt = 'A';
           i = i + 1;
           si(i).port = 2;
           si(i).txt  = 'P';
           so(1).txt = 'CC';
       end
   case 'Cepstral coefficients to LPCs'
       icontxt = ' CC to\n LPC';
       if strcmp(outputpower,'on')
         si(i).txt = 'CC';
         so(k).txt = 'A';  
         k = k + 1;
         so(k).port = 2;
         so(k).txt = 'P';
     end
   end
   for j=i+1:2, si(j)=si(i); end
   for m=k+1:2, so(m)=so(k); end

   
case 'dynamic'
   mask_visibles = get_param(blk,'MaskVisibilities');	
   if (strcmp(operation, 'LPCs to cepstral coefficients'))
       mask_visibles{2} = 'on';
       mask_visibles{3} = 'off';
       mask_visibles{4} = 'on';
       mask_visibles{5} = 'on';
       mask_visibles{6} = 'on';
       if (strcmp(needsize,'on'))
            mask_visibles{5} = 'off';
       else
            mask_visibles{5} = 'on';
       end
   else 
       mask_visibles{2} = 'off';
       mask_visibles{3} = 'on';
       mask_visibles{4} = 'off';
       mask_visibles{5} = 'off';
       mask_visibles{6} = 'off';       
   end
   set_param(blk,'MaskVisibilities',mask_visibles);
   
end

% [EOF] dspblkrlpc2cc.m
