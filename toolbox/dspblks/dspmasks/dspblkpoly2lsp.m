function [si,so] = dspblkpoly2lsp(action, RootStatus)
% DSPBLKPOLY2LSF Mask helper function for Poly to LSF conversion block.


% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.5 $ $Date: 2002/04/14 21:01:29 $

if nargin==0, action='dynamic'; end
blk = gcbh;
output = get_param(blk,'output');  

switch action
case 'dynamic'
   mask_enables = get_param(blk,'maskenables');			
   useLastLSP   = get_param(blk,'lastLSP');
   needCorrection = get_param(blk,'correction');
   mask_enables{6} = 'on';
   mask_enables{7} = 'on';
   if (strcmp(needCorrection, 'off'))
       mask_enables{6} = 'off';
       mask_enables{7} = 'off';
   else 
       if strcmp(useLastLSP, 'off'),
           mask_enables{7} = 'off';
       end
   end
   set_param(blk,'maskenables',mask_enables);
  
case 'icon'
   % Input port labels:

   si(1).port = 1;
   si(1).txt = 'Poly';
   
   
   % Output port labels:
   i = 1;
   so(i).port = 1;
   switch output
   case 'LSP in range (-1 1)'       
       so(i).txt = 'LSP';
   case 'LSF normalized in range (0 0.5)'
       so(i).txt = 'LSFn';
   otherwise 
       so(i).txt = 'LSFr';
   end
       
   if RootStatus,
      i=i+1;
      so(i).port = i;
      so(i).txt = 'Status';
   end
   
   for j=i+1:2, so(j)=so(i); end
end

% [EOF] dspblkpoly2lsp.m
