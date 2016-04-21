function varargout = commblkdecimtr(block, action)
% COMMBLKDECIMTR Mask dynamic dialog function for 3-stage decimator block

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2003/01/26 18:45:35 $

%*********************************************************************
% --- Action switch -- Determines which of the callback functions is called
%*********************************************************************

switch(action)
  
  %*********************************************************************
  % Function Name:     init
  % Description:       Main initialization code
  % Inputs:            current block
  % Return Values:     parameter structure with variables for 
  %                    decimator filter blocks
  %********************************************************************
case 'init'
  % --- Set Field index numbers and mask variable data
  setallfieldvalues(block);
  
  % Error checking
  
  % Decimation factor first
  if (isempty(maskDecFactor) | ...
      prod(size(maskDecFactor)) ~= 1 | ...
      maskDecFactor < 1 | ...
      maskDecFactor < round(maskDecFactor) - 1.e-6 | ...
      maskDecFactor > round(maskDecFactor) + 1.e-6 | ...
      ischar(maskDecFactor))
    error('The decimation factor must be a positive integer scalar');
  end;
  maskDecFactor = round(maskDecFactor);
  
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
  if (maskDecFactor/maskTin <= 2*maskFmax)
    error('The decimation factor divided by the input sample time must be greater than twice the maximum signal frequency');
  end;

  % Determine the decimation factors of each of the decimation stages.
  % Break up the overall decimation factor into its prime factors, and combine
  % them into numStages composite factors.
  numStages = 3;
  decFact = findDecFactors(maskDecFactor);

  % Determine the sampling rates, passband edge frequencies, and stopband frequencies
  % of each of the decimating filters.
  FsampIn = 1/maskTin;
  FsOut = FsampIn ./ cumprod(decFact);              % Find the sample rates at the output of each decimator stage
  Fpass = maskFmax./([FsampIn FsOut(1:end-1)]/2);   % Passband edge frequencies are normalized by each filter's input sample rate.
                                                    % They are constrained by the bandwidth of the signal.
  
  Fstop = 1./decFact;               % Stopband edge frequencies are already normalized by FsOut(i)/2.
                                    % They are constrained by the decimation factor.
                                    
  Fstop(find(Fstop==1)) = 0.9999;   % Stopband frequency must be < 1 for remez algorithm
  for i = 1:numStages
    if (Fpass(i) >= Fstop(i))
      error('One of the decimator filter passband edges exceeds its stopband edge.  Choose a higher initial sample rate.');
    end;
  end;
  
  % Estimate order of filters needed to perform decimation.  Assume a perfect lowpass filter,
  % 0.1 dB p-p passband ripple, and 50 dB of stopband attenuation.  There is no constraint on the
  % decimator filter order such that it must exceed the decimation factor.
  rp = 0.1;
  rs = 50; 
  dev = [(10^(rp/20)-1)/(10^(rp/20)+1)  10^(-rs/20)];
  
  for i = 1:numStages
    [order(i),freqBand,mag,weights] = remezord([Fpass(i) Fstop(i)], [1 0], dev);
  end;  

  order(find(order<3)) = 3;           % Filter order must be at least 3 for the remez
                                      % function to work properly

  % Populate the parameter structure
  dec_params.decFact1 = decFact(1);
  dec_params.decFact2 = decFact(2);
  dec_params.decFact3 = decFact(3);
  dec_params.Fpass1   = Fpass(1);
  dec_params.Fpass2   = Fpass(2);
  dec_params.Fpass3   = Fpass(3);
  dec_params.Fstop1   = Fstop(1);
  dec_params.Fstop2   = Fstop(2);
  dec_params.Fstop3   = Fstop(3);
  dec_params.order1   = order(1);
  dec_params.order2   = order(2);
  dec_params.order3   = order(3);

  varargout{1} = dec_params;

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
  
  Cb{idxDecFactor}  = '';
  Cb{idxTin}        = '';
  Cb{idxFmax}       = '';
  
  En{idxDecFactor}  = 'on';
  En{idxTin}        = 'on';
  En{idxFmax}       = 'on';

  Vis{idxDecFactor} = 'on';
  Vis{idxTin}       = 'on';
  Vis{idxFmax}      = 'on';

  % Get the mask Tunable values
  Tunable = get_param(block,'MaskTunableValues');
  Tunable{idxDecFactor}   = 'off';
  Tunable{idxTin}         = 'off';
  Tunable{idxFmax}        = 'off';

  % Set callbacks, enable status, visibilities, and tunable values
  set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities',Vis, ...
            'MaskTunableValues',Tunable);

  % Set the startup values.
  Vals{idxDecFactor}   = '10';
  Vals{idxTin}         = '1/10000';
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
function decFact = findDecFactors(M)
% FINDINTFACTORS  helper function to break down an overall decimation factor into 3 smaller
%                 decimation factors
%
% Description:
%  This function breaks down the overall decimation factor M into a vector of subfactors 
%  contained in the vector decFact.  It does this by finding the prime factors of M, then by
%  exhaustively checking all combinations of multiples of these prime factors, finds the combo
%  with the minimum variance.  This minimum variance combo allows for the easiest decimation
%  filter design.
%
% Inputs:
%   M         the overall decimation factor
%
% Outputs:
%   decFact   a vector of 3 smaller decimation factors, with the minimum variance of any
%             combination of sub-products of factors

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2003/01/26 18:45:35 $
%*************************************************************************************************

% Set "global" parameters
numStages = 3;

% Error checking

% We do not want any single decimation stage to exceed 40, since the filter design gets 
% difficult at that point.  However, a max decimation factor of 64000 enables an IS-136 system to
% be simulated (Rsym = 48 kbps and Fc = 1.8 GHz).
if (M > 64000)
  warning('This decimation factor could cause a complex filter design or an out-of-memory condition.  Consider using a smaller decimation factor.');
end;

primes = factor(M);
vecLen = length(primes);
if (any(primes > 40))
  warning('This decimation factor could cause a complex filter design or an out-of-memory condition.  Consider using an decimation factor with small primes as subfactors.');
end;

% Determine the decimation factors if the length of the prime factor vector is less than the
% number of decimation stages.  For example, if numStages = 3 and M = 3, then the decimation
% factor vector is [1 1 3].
if (vecLen < numStages)
  decFact = [ones(1,(numStages-vecLen)) primes];
  return;
end;

% Shuffle the factors around.  Since the variable testDecFact is found by multiplying contiguous
% sections of the primes vector, this shuffling will increase the chances that a suitable set of
% factors (i.e. a set with all elements < 40) is found.
remainder = mod(vecLen,numStages);        % This is to prepare to use the reshape function
if (remainder ~= 0) 
  primes = [primes ones(1,numStages - remainder)];
end;
vecLen = length(primes);
temp = reshape(primes,3,vecLen/3);
primes = reshape(temp',1,vecLen);
  
% Initialize decimation factors and variance
decFact = [1000 10000 100000];
variance = var(decFact);

% Find the subfactor combination with the minimum variance.  Multiply contiguous sections of the
% primes vector.  (The following code snippet assumes numStages = 3, since it has two loops)
for i = 1:vecLen-2
  for j = i+1:vecLen-1
    testDecFact = [prod(primes(1:i)) prod(primes(i+1:j)) prod(primes(j+1:end))];
    testVar = var(testDecFact);
    if (testVar < variance) 
      decFact = testDecFact;
      variance = testVar;
    end;
  end;
end;
decFact = sort(decFact);    % put in ascending order

if (decFact(numStages) > 40)
  warning('This decimation factor could cause a complex filter design or an out-of-memory condition.  Consider using a smaller decimation factor with small primes as subfactors.');
end;

% end of function findDecFactors

% [EOF] commblkdecimtr.m