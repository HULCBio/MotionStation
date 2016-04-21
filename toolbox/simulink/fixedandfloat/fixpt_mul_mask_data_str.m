function str = fixpt_mul_mask_data_str(curBlock,MatrixMult)
%FIXPT_MUL_MASK_DATA_STR is for internal use only by the Fixed Point Blockset


% $Revision: 1.4 $  $Date: 2002/04/10 18:59:08 $
%
% Copyright 1994-2002 The MathWorks, Inc.
%

str =[];
if MatrixMult == 1
  cr = sprintf('\n');
  str = ['Matrix' cr 'Multiply'];
end
