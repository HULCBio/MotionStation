function varargout = tic6xmask_fir(action)
% TIC6xMASK_FIR Mask dynamic dialog function for TI C64/62 DSPLIB FIR blocks

% Copyright 1995-2003 The MathWorks, Inc.
% $Date: 2004/01/22 18:29:49 $ $Revision: 1.1.6.1 $

% Mapping of mask-values to mask parameters:
% mask_vals{1}  -> Coefficient source selection popup
% mask_vals{2}  -> Filter coefficients edit box
% mask_vals{3}  -> Initial conditions edit box

  if nargin == 0, action = 'dynamic'; end

  mask_vals = get_param(gcb,'MaskValues');
  if (strcmp(mask_vals{1}, 'Specify via dialog'))
    coeff_from_mask = 1;
  else
    coeff_from_mask = 0;
  end
  switch action
   case 'icon'
    % generate icon structure s
    if (coeff_from_mask == 0)
      s.i1 = 1; s.s1 = 'X';
      s.i2 = 2; s.s2 = 'H';
    else
      s.i1 = 1; s.s1 = '';
      s.i2 = 1; s.s2 = '';
    end
    varargout(1) = {s};
   
   case 'init'
    args.coeff_from_mask = coeff_from_mask;
    maskwsvars = get_param(gcb,'MaskWSVariables');
    ic_arg     = maskwsvars(3).Value;
    if (~isnumeric(ic_arg))
      error('ICs must be numeric.');
    end
    if (~(all(isfinite(ic_arg))))
      error('ICs must be finite numbers, i.e. no Infs or NaNs.');
    end
    args.ics = double(ic_arg);
    if (coeff_from_mask == 1)
      coeffs = maskwsvars(2).Value;
      if (~isnumeric(coeffs))
        error('Filter coefficients must be numeric.');
      end
      if (~(all(isfinite(coeffs))))
        error('Filter coefficients must be finite numbers, i.e. no Infs or NaNs.');
      end
      args.coeffs = double(coeffs);
    else
      args.coeffs = [];
    end
    varargout(1) = {args};

   case 'dynamic'
    % handle dynamic dialog switching
    mask_visibles = get_param(gcb,'MaskVisibilities');
    old_mask_visibles = mask_visibles;
    if (coeff_from_mask == 0)
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

% [EOF] tic6xmask_fir.m
