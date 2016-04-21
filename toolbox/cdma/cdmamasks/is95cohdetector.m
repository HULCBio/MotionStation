% IS95COHDETECTOR IS-95A Fwd Ch Coherent Rake Receiver
% helper function

% Copyright 2000-2002 The MathWorks, Inc. and ALGOREX, Inc.
% $Revision: 1.14 $ $Date: 2002/04/14 16:31:49 $


switch rateSet
   case 1
   % Rate Set I
   set_param(sprintf([gcb '/IS-95A Fwd Ch\nDescrambler']),'rateSet','Rate Set I');
   case 2
   % Rate Set II
   set_param(sprintf([gcb '/IS-95A Fwd Ch\nDescrambler']),'rateSet','Rate Set II');
   end;

if mod(384, rake_buff_size)
  error('Wrong Rake Tracking Buffer Size : ERROR');
end
