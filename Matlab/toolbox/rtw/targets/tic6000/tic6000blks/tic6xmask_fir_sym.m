function varargout = tic6xmask_fir_sym(action)
% TIC6XMASK_FIR_SYM Mask dynamic dialog function for 
% TI C62/C64 DSPLIB FIR_SYM

% Copyright 2001-2003 The MathWorks, Inc.
% $Date: 2004/01/22 18:29:50 $ $Revision: 1.1.6.1 $

% Mapping of mask-values to mask parameters:
% mask_vals{1}  -> Coefficient source selection popup
% mask_vals{2}  -> Filter coefficients edit box
% mask_vals{3}  -> Coefficient frac bits method popup
% mask_vals{4}  -> Coefficient frac bits edit box
% mask_vals{5}  -> Output frac bits method popup
% mask_vals{6}  -> Output frac bits edit box
% mask_vals{7}  -> Initial conditions edit box

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
    maskwsvars = get_param(gcb,'MaskWSVariables');
    ic_arg     = maskwsvars(7).Value;
    if (~isnumeric(ic_arg))
      error('ICs must be numeric.');
    end
    if (~(all(isfinite(ic_arg))))
      error('ICs must be finite numbers, i.e. no Infs or NaNs.');
    end
    args.ics = double(ic_arg);
    if (coeff_from_mask == 1)
      coeffs  = maskwsvars(2).Value;
      c_fbits = maskwsvars(4).Value;
      if (~isnumeric(coeffs))
        error('Filter coefficients must be numeric.');
      end
      if (~(all(isfinite(coeffs))))
        error('Filter coefficients must be finite numbers, i.e. no Infs or NaNs.');
      end
      args.coeffs = double(coeffs);

      if (strcmp(mask_vals{3}, 'Match input x'))
        args.c_fbits = 0;
      else 
        if (strcmp(mask_vals{3}, 'Best precision'))
          args.c_fbits = -max(fixptbestexp(coeffs, 16, 1));
        else  % User-defined
          args.c_fbits = c_fbits;
        end
      end
    else
      args.coeffs = [];
      args.c_fbits = [];
    end
    varargout(1) = {args};
    
   case 'dynamic'
    % handle dynamic dialog switching
    mask_visibles = get_param(gcb,'MaskVisibilities');
    mask_enables = get_param(gcb,'MaskEnables');
    maskwsvars = get_param(gcb,'MaskWSVariables');
    old_mask_visibles = mask_visibles;
    old_mask_enables = mask_enables;
    if (coeff_from_mask == 0)
      mask_visibles{2} = 'off';
      mask_visibles{3} = 'off';
      mask_visibles{4} = 'off';
    else
      mask_visibles{2} = 'on';
      mask_visibles{3} = 'on';
      mask_visibles{4} = 'on';
      if (strcmp(mask_vals{3}, 'User-defined'))
        mask_enables{4} = 'on';
      else
        mask_enables{4} = 'off';      
      end
    end
    if (strcmp(mask_vals{5}, 'User-defined'))
      mask_enables{6} = 'on';
    else
      mask_enables{6} = 'off';      
    end
    if (~isequal(mask_visibles, old_mask_visibles))
      set_param(gcb, 'MaskVisibilities', mask_visibles);
    end
    if (~isequal(mask_enables, old_mask_enables))
      set_param(gcb, 'MaskEnables', mask_enables);
    end
    
   otherwise
    errordlg('Invalid mask helper function argument.');
  end

% [EOF] tic6xmask_fir_sym.m
