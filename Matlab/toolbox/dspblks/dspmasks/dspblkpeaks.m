function [str, dtInfo] = dspblkpeaks(action, outI, outV, pol)
% DSPBLKPEAKS Mask dynamic dialog function for peak finder block
% Copyright 1995-2003 The MathWorks, Inc.
% $Date: 2004/04/12 23:07:02 $ $Revision: 1.1.6.3 $

if nargin==0, action = 'dynamic'; end

blk = gcb;
blkh   = gcbh;

switch action

case 'icon'

    dtInfo = dspGetFixptDataTypeInfo(blkh,1);   

    switch pol,
        case 1,
            str.txt='Maxima';
        case 2,
            str.txt='Minima';
        case 3,
            str.txt='Extrema';
    end;

% Index and Value
if (outI == 1) & (outV == 1)
      str.i1 = 2;  str.s1 = 'Idx';
      str.i2 = 3;  str.s2 = 'Val';
      if (pol == 3)
          str.i3 = 4; str.s3='Pol';
      else
          str.i3 = 1;  str.s3 = '';
      end
end

% Index
if (outI == 1) & (outV == 0)
      str.i1 = 2;  str.s1 = '';
      str.i2 = 2;  str.s2 = 'Idx';
      if (pol == 3)
          str.i3 = 3; str.s3='Pol';
      else
          str.i3 = 1;  str.s3 = '';
      end
end

% Value
if (outI == 0) & (outV == 1)
      str.i1 = 2;  str.s1 = '';
      str.i2 = 2;  str.s2 = 'Val';
      if (pol == 3)
          str.i3 = 3; str.s3='Pol';
      else
                str.i3 = 1;  str.s3 = '';
      end
end

% Count only
if (outI == 0) & (outV == 0)
      str.i1 = 1;  str.s1 = '';
      str.i2 = 1;  str.s2 = '';
      str.i3 = 1;  str.s3 = '';
end

case 'dynamic'
  % Execute dynamic dialogs
  mask_visibles     = get_param(blk, 'MaskVisibilities');
  old_mask_visibles = mask_visibles;
  mask_enables      = get_param(blk, 'MaskEnables');
  old_mask_enables  = mask_enables;
  
  mask_visibles([1:5,7]) = {'on'}; mask_enables([1:5,7]) = {'on'}; 
  puNoiseDetection=get_param(blk, 'NoiseDistinguish');
  mask_visibles([6]) = {puNoiseDetection}; mask_enables([6]) = {puNoiseDetection}; 
  
  puDISTMEASval = get_param(blk, 'additionalParams');
  mask_visibles([9:10]) = {puDISTMEASval}; mask_enables([9:10]) = {puDISTMEASval}; 

  if (~isequal(mask_visibles, old_mask_visibles))
      set_param(blk, 'MaskVisibilities', mask_visibles);
  end
  if (~isequal(mask_enables, old_mask_enables))
      set_param(blk, 'MaskEnables', mask_enables);
  end
end % end of switch statemen

% end of dspblkpeaks.m
