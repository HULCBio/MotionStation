function y=awgn(varargin)
%AWGN Add white Gaussian noise to a signal.
%   Y = AWGN(X,SNR) adds white Gaussian noise to X.  The SNR is in dB.
%   The power of X is assumed to be 0 dBW.  If X is complex, then 
%   AWGN adds complex noise.
%
%   Y = AWGN(X,SNR,SIGPOWER) when SIGPOWER is numeric, it represents 
%   the signal power in dBW. When SIGPOWER is 'measured', AWGN measures
%   the signal power before adding noise.
%
%   Y = AWGN(X,SNR,SIGPOWER,STATE) resets the state of RANDN to STATE.
%
%   Y = AWGN(..., POWERTYPE) specifies the units of SNR and SIGPOWER.
%   POWERTYPE can be 'db' or 'linear'.  If POWERTYPE is 'db', then SNR
%   is measured in dB and SIGPOWER is measured in dBW.  If POWERTYPE is
%   'linear', then SNR is measured as a ratio and SIGPOWER is measured
%   in Watts.
%
%   Example: To specify the power of X to be 0 dBW and add noise to produce
%            an SNR of 10dB, use:
%            X = sqrt(2)*sin(0:pi/8:6*pi);
%            Y = AWGN(X,10,0);
%
%   Example: To specify the power of X to be 0 dBW, set RANDN to the 1234th
%            state and add noise to produce an SNR of 10dB, use:
%            X = sqrt(2)*sin(0:pi/8:6*pi);
%            Y = AWGN(X,10,0,1234);
%
%   Example: To specify the power of X to be 3 Watts and add noise to
%            produce a linear SNR of 4, use:
%            X = sqrt(2)*sin(0:pi/8:6*pi);
%            Y = AWGN(X,4,3,'linear');
%
%   Example: To cause AWGN to measure the power of X, set RANDN to the 
%            1234th state and add noise to produce a linear SNR of 4, use:
%            X = sqrt(2)*sin(0:pi/8:6*pi);
%            Y = AWGN(X,4,'measured',1234,'linear');
%
%   See also WGN, RANDN, and BSC.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/04/12 23:00:22 $ 

% --- Initial checks
error(nargchk(2,5,nargin));

% --- Value set indicators (used for the string flags)
pModeSet    = 0;
measModeSet = 0;

% --- Set default values
reqSNR   = [];
sig      = [];
sigPower = 0;
pMode    = 'db';
measMode = 'specify';
state    = [];

% --- Placeholder for the signature string
sigStr = '';

% --- Identify string and numeric arguments
for n=1:nargin
   if(n>1)
      sigStr(size(sigStr,2)+1) = '/';
   end
   % --- Assign the string and numeric flags
   if(ischar(varargin{n}))
      sigStr(size(sigStr,2)+1) = 's';
   elseif(isnumeric(varargin{n}))
      sigStr(size(sigStr,2)+1) = 'n';
   else
      error('Only string and numeric arguments are allowed.');
   end
end

% --- Identify parameter signatures and assign values to variables
switch sigStr
   % --- awgn(x, snr)
   case 'n/n'
      sig      = varargin{1};
      reqSNR   = varargin{2};

   % --- awgn(x, snr, sigPower)
   case 'n/n/n'
      sig      = varargin{1};
      reqSNR   = varargin{2};
      sigPower = varargin{3};

   % --- awgn(x, snr, 'measured')
   case 'n/n/s'
      sig      = varargin{1};
      reqSNR   = varargin{2};
      measMode = lower(varargin{3});

      measModeSet = 1;

   % --- awgn(x, snr, sigPower, state)
   case 'n/n/n/n'
      sig      = varargin{1};
      reqSNR   = varargin{2};
      sigPower = varargin{3};
      state    = varargin{4};

   % --- awgn(x, snr, 'measured', state)
   case 'n/n/s/n'
      sig      = varargin{1};
      reqSNR   = varargin{2};
      measMode = lower(varargin{3});
      state    = varargin{4};

      measModeSet = 1;

   % --- awgn(x, snr, sigPower, 'db|linear')
   case 'n/n/n/s'
      sig      = varargin{1};
      reqSNR   = varargin{2};
      sigPower = varargin{3};
      pMode    = lower(varargin{4});

      pModeSet = 1;

   % --- awgn(x, snr, 'measured', 'db|linear')
   case 'n/n/s/s'
      sig      = varargin{1};
      reqSNR   = varargin{2};
      measMode = lower(varargin{3});
      pMode    = lower(varargin{4});

      measModeSet = 1;
      pModeSet    = 1;

   % --- awgn(x, snr, sigPower, state, 'db|linear')
   case 'n/n/n/n/s'
      sig      = varargin{1};
      reqSNR   = varargin{2};
      sigPower = varargin{3};
      state    = varargin{4};
      pMode    = lower(varargin{5});

      pModeSet = 1;

   % --- awgn(x, snr, 'measured', state, 'db|linear')
   case 'n/n/s/n/s'
      sig      = varargin{1};
      reqSNR   = varargin{2};
      measMode = lower(varargin{3});
      state    = varargin{4};
      pMode    = lower(varargin{5});

      measModeSet = 1;
      pModeSet    = 1;

   otherwise
      error('Syntax error.');
end   

% --- Parameters have all been set, either to their defaults or by the values passed in,
%     so perform range and type checks

% --- sig
if(isempty(sig))
   error('An input signal must be given.');
end

if(ndims(sig)>2)
   error('The input signal must have 2 or fewer dimensions.');
end

% --- measMode
if(measModeSet)
   if(~strcmp(measMode,'measured'))
      error('The signal power parameter must be numeric or ''measured''.');
   end
end

% --- pMode
if(pModeSet)
   switch pMode
   case {'db' 'linear'}
   otherwise
      error('The signal power mode must be ''db'' or ''linear''.');
   end
end

% -- reqSNR
if(any([~isreal(reqSNR) (length(reqSNR)>1) (length(reqSNR)==0)]))
   error('The signal-to-noise ratio must be a real scalar.');
end

if(strcmp(pMode,'linear'))
   if(reqSNR<=0)
      error('In linear mode, the signal-to-noise ratio must be > 0.');
   end
end

% --- sigPower
if(~strcmp(measMode,'measured'))

   % --- If measMode is not 'measured', then the signal power must be specified
   if(any([~isreal(sigPower) (length(sigPower)>1) (length(sigPower)==0)]))
      error('The signal power value must be a real scalar.');
   end
   
   if(strcmp(pMode,'linear'))
      if(sigPower<0)
         error('In linear mode, the signal power must be >= 0.');
      end
   end

end

% --- state
if(~isempty(state))
   if(any([~isreal(state) (length(state)>1) (length(state)==0) any((state-floor(state))~=0)]))
      error('The State must be a real, integer scalar.');
   end
end

% --- All parameters are valid, so no extra checking is required

% --- Check the signal power.  This needs to consider power measurements on matrices
if(strcmp(measMode,'measured'))
   sigPower = sum(abs(sig(:)).^2)/length(sig(:));

   if(strcmp(pMode,'db'))
      sigPower = 10*log10(sigPower);
   end
end

% --- Compute the required noise power
switch lower(pMode)
   case 'linear'
      noisePower = sigPower/reqSNR;
   case 'db'
      noisePower = sigPower-reqSNR;
      pMode = 'dbw';
end

% --- Add the noise
if(isreal(sig))
   opType = 'real';
else
   opType = 'complex';
end

y = sig+wgn(size(sig,1), size(sig,2), noisePower, 1, state, pMode, opType);
