% IS95FWDCHPWRBITEXT IS-95A Fwd Ch Power Bit Extractor
% helper function

% Copyright 2000-2002 The MathWorks, Inc. and ALGOREX, Inc.
% $Revision: 1.7 $ $Date: 2002/04/14 16:32:09 $


switch rateSet
   case 1
   % Rate Set I
   set_param(sprintf([gcb '/IS-95A Fwd Ch\nPower Bit Extractor']),'rateSet','Rate Set I');
   case 2
   % Rate Set II
   set_param(sprintf([gcb '/IS-95A Fwd Ch\nPower Bit Extractor']),'rateSet','Rate Set II');
end;
