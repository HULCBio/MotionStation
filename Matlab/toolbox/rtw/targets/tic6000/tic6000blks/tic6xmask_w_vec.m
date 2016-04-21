function varargout = tic6xmask_w_vec(action)
% TIC6XMASK_W_VEC Mask dynamic dialog function for TI C62/C64 DSPLIB W_VEC blocks

% Copyright 2001-2003 The MathWorks, Inc.
% $Date: 2004/01/22 18:29:54 $ $Revision: 1.1.6.1 $

% Mapping of mask-values to mask parameters:
% mask_vals{1}  -> weights source selection popup
% mask_vals{2}  -> weights edit box

  if nargin == 0, action = 'dynamic'; end

  mask_vals = get_param(gcb,'MaskValues');
  if (strcmp(mask_vals{1}, 'Specify via dialog'))
    weights_from_mask = 1;
  else
    weights_from_mask = 0;
  end
  switch action
   case 'icon'
    % generate icon structure s
    if (weights_from_mask == 0)
      s.i1 = 1; s.s1 = 'X';
      s.i2 = 2; s.s2 = 'Y';
      s.i3 = 3; s.s3 = 'W';
    else
      s.i1 = 1; s.s1 = 'X';
      s.i2 = 2; s.s2 = 'Y';
      % fill in third with something, so that sizes are same
      s.i3 = 1; s.s3 = 'X';
    end
    varargout(1) = {s};
   
   case 'init'
    args.weights_from_mask = weights_from_mask;
    maskwsvars = get_param(gcb,'MaskWSVariables');
    if (weights_from_mask == 1)
      weights = maskwsvars(2).Value;
      if (~isnumeric(weights))
        error('Weights must be numeric.');
      end
      if (~(all(isfinite(weights))))
        error('Weights must be finite numbers, i.e. no Infs or NaNs.');
      end
      args.weights = double(weights);
    else
      args.weights = [];
    end
    varargout(1) = {args};

   case 'dynamic'
    % handle dynamic dialog switching
    mask_visibles = get_param(gcb,'MaskVisibilities');
    old_mask_visibles = mask_visibles;
    if (weights_from_mask == 0)
      mask_visibles{2} = 'off';
    else
      mask_visibles{2} = 'on';
    end
    if (~isequal(mask_visibles, old_mask_visibles))
      set_param(gcb, 'MaskVisibilities', mask_visibles);
    end
   
   otherwise
    errordlg('Invalid mask helper function argument.');
  end

% [EOF] tic6xmask_w_vec.m
