function [s] = dspblkburg2(action)
% DSPBLKBURG2 Signal Processing Blockset Burg block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.6.4.2 $ $Date: 2004/04/12 23:06:05 $


if nargin==0, action = 'dynamic'; end
blk = gcbh;

switch action
case 'icon'
    % Setup port label structure:
    fcn = get_param(blk,'fcn');  % A and K|A|K

    switch fcn
    case 'A and K',
       % 1 input (in)
       % 2 outputs (A,K)
       s.o1 = 1; s.o1s = 'A';
       s.o2 = 2; s.o2s = 'K';  
   
    case 'A',
	    % 1 input (in)
	    % 1 output (A)
       s.o1 = 1; s.o1s = '';
       s.o2 = 1; s.o2s = 'A';  
   
    case 'K',
       % 1 input (in)
	     % 1 output (K)
       s.o1 = 1; s.o1s = '';
       s.o2 = 1; s.o2s = 'K';  
   
    end
    s.o3 = s.o2+1; s.o3s = 'G';

case 'dynamic'

    
   inheritOrder = strcmp(get_param(blk,'inheritOrder'),'on');
   mask_enables = get_param(blk,'maskenables');
   mask_enables_orig = mask_enables;
          
   if inheritOrder,
       mask_enables(3) = {'off'};
   else
      mask_enables(3) = {'on'};
   end
   
   if ~isequal(mask_enables_orig, mask_enables),
       set_param(blk,'maskenables',mask_enables);
   end

end
