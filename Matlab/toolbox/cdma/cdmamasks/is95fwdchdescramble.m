% IS95FWDCHDESRAMBLE IS-95A Fwd Ch Descrambler helper function

% Copyright 2000-2002 The MathWorks, Inc. and ALGOREX, Inc.
% $Revision: 1.13 $ $Date: 2002/04/14 16:31:59 $


switch rateSet
case 1
   % Rate Set I
   set_param(sprintf([gcb '/IS-95A Fwd Ch\nPower Bit Extractor1']),'rateSet','Rate Set I');
   set_param(sprintf([gcb '/IS-95A Fwd Ch\nPower Bit Extractor2']),'rateSet','Rate Set I');
   set_param(sprintf([gcb '/IS-95A Fwd Ch\nPower Bit Extractor3']),'rateSet','Rate Set I');
   set_param(sprintf([gcb '/IS-95A Fwd Ch\nPower Bit Extractor4']),'rateSet','Rate Set I');
case 2
   % Rate Set II
   set_param(sprintf([gcb '/IS-95A Fwd Ch\nPower Bit Extractor1']),'rateSet','Rate Set II');
   set_param(sprintf([gcb '/IS-95A Fwd Ch\nPower Bit Extractor2']),'rateSet','Rate Set II');
   set_param(sprintf([gcb '/IS-95A Fwd Ch\nPower Bit Extractor3']),'rateSet','Rate Set II');
   set_param(sprintf([gcb '/IS-95A Fwd Ch\nPower Bit Extractor4']),'rateSet','Rate Set II');
end;
