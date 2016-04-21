function varargout = commblkintrpltr(block, action)
% COMMBLKINTRPLTR Mask dynamic dialog function for 3-stage interpolator block

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2003/01/26 18:45:39 $

%*********************************************************************
% --- Action switch -- Determines which of the callback functions is called
%*********************************************************************

switch(action)
  
  %*********************************************************************
  % Function Name:     init
  % Description:       Main initialization code
  % Inputs:            current block
  % Return Values:     parameter structure with variables for 
  %                    interpolator filter blocks
  %********************************************************************
case 'init'
  % --- Set Field index numbers and mask variable data
  setallfieldvalues(block);
  
  % Error checking
  
  % Interpolation factor first
  if (isempty(maskIntFactor) | ...
      prod(size(maskIntFactor)) ~= 1 | ...
      maskIntFactor < 1 | ...
      maskIntFactor < round(maskIntFactor) - 1.e-6 | ...
      maskIntFactor > round(maskIntFactor) + 1.e-6 | ...
      ischar(maskIntFactor))
    error('The interpolation factor must be a positive integer scalar');
  end;
  maskIntFactor = round(maskIntFactor);
  
  % Tin, the input sample time
  if (isempty(maskTin) | ...
      prod(size(maskTin)) ~= 1 | ...
      maskTin <= 0 | ...
      ischar(maskTin))
    error('The input sample time must be a real, positive scalar');
  end;
  
  % Fmax, the maximum frequency that contains signal energy
  if (isempty(maskFmax) | ...
      prod(size(maskFmax)) ~= 1 | ...
      maskFmax <= 0 | ...
      ischar(maskFmax))
    error('The maximum signal frequency must be a real, positive scalar');
  end;
  
  % Check for relationships between parameters
  if (1/maskTin <= 2*maskFmax)
    error('The reciprocal of the input sample time must be greater than twice the maximum signal frequency');
  end;
  
  % Determine the interpolation factors of each of the interpolation stages.
  % Break up the overall interpolation factor into its prime factors, and combine
  % them into numStages composite factors.
  numStages = 3;
  intFact = findIntFactors(maskIntFactor);
  
  % Determine the sampling rates, passband edge frequencies, and stopband frequencies
  % of each of the interpolating filters.
  FsampIn = 1/maskTin;
  FsOut = FsampIn * cumprod(intFact);   % Find the sample rates at the output of each interpolator stage
  Fpass = maskFmax./(FsOut/2);          % Passband edge frequencies are normalized by Fsout(i)/2.
                                        % They are constrained by the bandwidth of the signal.
                                        
  Fstop = 1./intFact;                   % Stopband edge frequencies are already normalized by Fsout(i)/2.
                                        % They are constrained only by the interpolation factor.
                                        
  Fstop(find(Fstop==1)) = 0.9999;       % Stopband frequency must be < 1 for remez algorithm
  for i = 1:numStages
    if (Fpass(i) >= Fstop(i))
      error('One of the interpolator filter passband edges exceeds its stopband edge.  Choose a higher initial sample rate.');
    end;
  end;
  
  % Estimate order of filters needed to perform interpolation.  Assume a perfect lowpass filter,
  % 0.1 dB p-p passband ripple, and 50 dB of stopband attenuation.  If remezord determines a filter
  % order that does not exceed the interpolation factor, then decrease the passband ripple until the 
  % filter order does exceed it.
  rp = 0.1 * ones(1,numStages);
  rs = 50 * ones(1,numStages); 
  dev = [(10.^(rp'/20)-1)./(10.^(rp'/20)+1)  10.^(-rs'/20)];
  
  order = ones(1,numStages);
  for i = 1:numStages
    while (order(i) <= intFact(i))
      [order(i),freqBand,mag,weights] = remezord([Fpass(i) Fstop(i)], [1 0], dev(i,:));
      if (order(i) <= intFact(i))
        rp(i) = rp(i)/2;
        dev(i,1) = (10^(rp(i)/20)-1)/(10^(rp(i)/20)+1);
      end;
    end;
  end;
    
  order(find(order<3)) = 3;           % Filter order must be at least 3 for the remez
                                      % function to work properly

  % Populate the parameter structure
  int_params.intFact1 = intFact(1);
  int_params.intFact2 = intFact(2);
  int_params.intFact3 = intFact(3);
  int_params.Fpass1   = Fpass(1);
  int_params.Fpass2   = Fpass(2);
  int_params.Fpass3   = Fpass(3);
  int_params.Fstop1   = Fstop(1);
  int_params.Fstop2   = Fstop(2);
  int_params.Fstop3   = Fstop(3);
  int_params.order1   = order(1);
  int_params.order2   = order(2);
  int_params.order3   = order(3);
 
  varargout{1} = int_params;

% ---- end of case 'init'

%-----------------------------------------------------------------------------
%   Setup/utility functions
%-----------------------------------------------------------------------------

%*****************************************************************************
% Function name:    'default'
% Description:      Set the block defaults (development use only)
% Inputs:           Current block
% Return values:    None
%*****************************************************************************
case 'default'
  % --- Set field index numbers and mask variable data
  setallfieldvalues(block)
  
  Cb{idxIntFactor}  = '';
  Cb{idxTin}        = '';
  Cb{idxFmax}       = '';
  
  En{idxIntFactor}  = 'on';
  En{idxTin}        = 'on';
  En{idxFmax}       = 'on';

  Vis{idxIntFactor} = 'on';
  Vis{idxTin}       = 'on';
  Vis{idxFmax}      = 'on';

  % Get the mask Tunable values
  Tunable = get_param(block,'MaskTunableValues');
  Tunable{idxIntFactor}   = 'off';
  Tunable{idxTin}         = 'off';
  Tunable{idxFmax}        = 'off';

  % Set callbacks, enable status, visibilities, and tunable values
  set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities',Vis, ...
            'MaskTunableValues',Tunable);

  % Set the startup values.
  Vals{idxIntFactor}   = '10';
  Vals{idxTin}         = '1/1000';
  Vals{idxFmax}        = '450';

  % --- update Vals
  MN = get_param(block,'MaskNames');
  for n=1:length(Vals)
     set_param(block,MN{n},Vals{n});
  end;

  % Ensure that the block operates correctly from a library
  set_param(block,'MaskSelfModifiable','on');
  
% ---- end of case 'default'

end;    % end of switch(action) statement  

%************************************************************************************************
function intFact = findIntFactors(L)
% FINDINTFACTORS  helper function to break down an overall interpolation factor into 3 smaller
%                 interpolation factors
%
% Description:
%  This function breaks down the overall interpolation factor L into a vector of subfactors 
%  contained in the vector intFact.  It does this by finding the prime factors of L, then by
%  exhaustively checking all combinations of multiples of these prime factors, finds the combo
%  with the minimum variance.  This minimum variance combo allows for the easiest interpolation
%  filter design.
%
% Inputs:
%   L         the overall interpolation factor
%
% Outputs:
%   intFact   a vector of 3 smaller interpolation factors, with the minimum variance of any
%             combination of sub-products of factors

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2003/01/26 18:45:39 $
%*************************************************************************************************

% Set "global" parameters
numStages = 3;

% Error checking

% We do not want any single interpolation stage to exceed 40, since the filter design gets 
% difficult at that point.  However, a max decimation factor of 64000 enables an IS-136 system to
% be simulated (Rsym = 48 kbps and Fc = 1.8 GHz).
if (L > 64000)
  warning('This interpolation factor could cause a complex filter design or an out-of-memory condition.  Consider using a smaller interpolation factor.');
end;

primes = factor(L);
vecLen = length(primes);
if (any(primes > 40))
  warning('This interpolation factor could cause a complex filter design or an out-of-memory condition.  Consider using an interpolation factor with small primes as subfactors.');
end;

% Determine the interpolation factors if the length of the prime factor vector is less than the
% number of interpolation stages.  For example, if numStages = 3 and L = 3, then the interpolation
% factor vector is [1 1 3].
if (vecLen < numStages)
  intFact = [ones(1,(numStages-vecLen)) primes];
  return;
end;

% Shuffle the factors around.  Since the variable testIntFact is found by multiplying contiguous
% sections of the primes vector, this shuffling will increase the chances that a suitable set of
% factors (i.e. a set with all elements < 40) is found.
remainder = mod(vecLen,numStages);        % This is to prepare to use the reshape function
if (remainder ~= 0) 
  primes = [primes ones(1,numStages - remainder)];
end;
vecLen = length(primes);
temp = reshape(primes,3,vecLen/3);
primes = reshape(temp',1,vecLen);
  
% Initialize interpolation factors and variance
intFact = [1000 10000 100000];
variance = var(intFact);

% Find the subfactor combination with the minimum variance.  Multiply contiguous sections of the
% primes vector.  (The following code snippet assumes numStages = 3, since it has two loops)
for i = 1:vecLen-2
  for j = i+1:vecLen-1
    testIntFact = [prod(primes(1:i)) prod(primes(i+1:j)) prod(primes(j+1:end))];
    testVar = var(testIntFact);
    if (testVar < variance) 
      intFact = testIntFact;
      variance = testVar;
    end;
  end;
end;
intFact = sort(intFact);    % put in ascending order

if (intFact(numStages) > 40)    % Since the vector is sorted, we only need to check the last element
  warning('This interpolation factor could cause a complex filter design or an out-of-memory condition.  Consider using a smaller interpolation factor with small primes as subfactors.');
end;

% end of function findIntFactors

% [EOF] commblkintrpltr.m