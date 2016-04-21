function varargout = tic6xmask_iir(action)
% TIC6XMASK_IIR Mask dynamic dialog function for 
% TI C62/C64 DSPLIB IIR block

% Copyright 1995-2003 The MathWorks, Inc.
% $Date: 2004/01/22 18:29:51 $ $Revision: 1.1.6.1 $

% Mapping of mask-values to mask parameters:
% mask_vals{1}  -> Coefficient source selection popup
% mask_vals{2}  -> H1 Filter coefficients edit box
% mask_vals{3}  -> H2 Filter coefficients edit box
% mask_vals{4}  -> Input initial conditions edit box
% mask_vals{5}  -> Output initial conditions edit box

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
      s.i2 = 2; s.s2 = 'AR';
      s.i3 = 3; s.s3 = 'MA';
    else
      s.i1 = 1; s.s1 = '';
      s.i2 = 1; s.s2 = '';
      s.i3 = 1; s.s3 = '';
    end
    varargout(1) = {s};
   
   case 'init'
    args.coeff_from_mask = coeff_from_mask;
    maskwsvars = get_param(gcb,'MaskWSVariables');
    in_ic_arg  = maskwsvars(4).Value;
    out_ic_arg = maskwsvars(5).Value;
    
    if (~isnumeric(in_ic_arg))
      error('Input ICs must be numeric.');
    end
    if (~(all(isfinite(in_ic_arg))))
      error('Input ICs must be finite numbers, i.e. no Infs or NaNs.');
    end
    args.in_ics = double(in_ic_arg);
    
    if (~isnumeric(out_ic_arg))
      error('Output ICs must be numeric.');
    end
    if (~(all(isfinite(out_ic_arg))))
      error('Output ICs must be finite numbers, i.e. no Infs or NaNs.');
    end
    args.out_ics = double(out_ic_arg);
    
    if (coeff_from_mask == 1)
      h1coeffs = maskwsvars(3).Value;
      if (~isnumeric(h1coeffs))
        error('H1 Filter coefficients must be numeric.');
      end
      if (~(all(isfinite(h1coeffs))))
        error('H1 Filter coefficients must be finite numbers, i.e. no Infs or NaNs.');
      end
      args.h1coeffs = double(h1coeffs);
      
      h2coeffs = maskwsvars(2).Value;
      if (~isnumeric(h2coeffs))
        error('H2 Filter coefficients must be numeric.');
      end
      if (~(all(isfinite(h2coeffs))))
        error('H2 Filter coefficients must be finite numbers, i.e. no Infs or NaNs.');
      end
      args.h2coeffs = double(h2coeffs);
    else
      args.h1coeffs = [];
      args.h2coeffs = [];
    end
    varargout(1) = {args};

   case 'dynamic'
    % handle dynamic dialog switching
    mask_visibles = get_param(gcb,'MaskVisibilities');
    old_mask_visibles = mask_visibles;
    if (coeff_from_mask == 0)
      mask_visibles{2} = 'off';
      mask_visibles{3} = 'off';
    else
      mask_visibles{2} = 'on';
      mask_visibles{3} = 'on';
    end
    if (~isequal(mask_visibles, old_mask_visibles))
      set_param(gcb, 'MaskVisibilities', mask_visibles);
    end
   
   otherwise
    errordlg('Invalid mask helper function argument.');
  end

% [EOF] tic6xmask_iir.m
