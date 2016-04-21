function varargout = commblkfadingchan(block,varargin)
% COMMBLKFADINGCHAN Rayleigh/Rician channel helper function.

% Copyright 1996-2002 The MathWorks, Inc.

% --- Mask parameters
% Fd
% LOSFd
% K
% simTs
% delayVec
% gainVecdB
% normGain
% Seed
%
% Exit code assignments:
% 0 = No error/warning
% 1 = Error
% 2 = Warning

% --- Initial checks
error(nargchk(9,9,nargin));

% --- Input parameter assignments
Fd          = varargin{1}(:).';
LOSFd       = varargin{2};
K           = varargin{3};
simTs       = varargin{4}(:).';
delayVec    = varargin{5};
gainVecdB   = varargin{6};
normGain    = varargin{7};
Seed        = varargin{8}(:).';

% --- Exit code and error message definitions
ecode = 0;
emsg  = '';

% --- Define the parameter structure
params.nPaths       = [];
params.Seed         = [];

% --- Fading profile related parameters
params.dopplerSos   = [];
params.interp1Num   = [];
params.interp1      = [];
params.interp2Num   = [];
params.interp2      = [];
params.intFactor    = [];
params.startDelay   = [];
params.maxPathWidth = [];

% --- Gain and delay parameters
params.sampleDelayVec = [];
params.gainVecLin     = [];

% --- Rician related parameters
params.K = [];
params.LOSFd = [];

% --- Determine how this block is being used
blkMode = determineMode(block);

% --- Number of paths is determined by the length of the delay, gain, LOSFd and K vectors
%     Scalar expansion rules apply.
switch(blkMode)
   case 'RAYLEIGH'
      if(any([ismatrix(delayVec) ismatrix(gainVecdB)]))
         emsg  = 'The Gain and delay parameters must be either scalar or vector entries.';
         ecode = 1;
      end;
   case 'RICIAN'
      if(any([ismatrix(K) ismatrix(delayVec) ismatrix(gainVecdB)]))
         emsg  = 'K-factor, gain and delay parameters must be scalars.';
         ecode = 1;
      end;
otherwise
      if(any([ismatrix(LOSFd) ismatrix(K) ismatrix(delayVec) ismatrix(gainVecdB)]))
         emsg  = 'The Line-of-Sight, K-factor, gain and delay parameters must be either scalar or vector entries.';
         ecode = 1;
      end;
end;

% --- Parameter checks
if(~ecode)
   % --- Ensure parameters that may be vectors are all rows
   LOSFd     = LOSFd(:).';
   K         = K(:).';
   delayVec  = delayVec(:).';
   gainVecdB = gainVecdB(:).';
   
   % --- Core parameter checks
   if(any([~isreal(Fd) (any(Fd <= 0)) (length(Fd)~=1)]))
      emsg  = 'The Doppler frequency must be a non-negative scalar.';
      ecode = 1;
   elseif(any([~isreal(simTs) (any(simTs <= 0)) (length(simTs)~=1)]))
      emsg  = 'The sample time must be a real scalar greater than zero.';
      ecode = 1;
   elseif(any([~isreal(Seed) ((Seed-floor(Seed)) ~= 0) (ndims(Seed) > 2) (size(Seed,1)>1) (size(Seed,2)>1)]))
      emsg  = 'The seed must be a real integer scalar.';
      ecode = 1;
   end;
   
   switch(blkMode)
   case 'RAYLEIGH'
      % --- Rayleigh specific parameter checks
      if(any([~isreal(delayVec) (any(delayVec < 0))]))
         emsg  = 'The delay parameter must be a non-negative scalar or vector.';
         ecode = 1;
      elseif(~isreal(gainVecdB))
         emsg  = 'The gain parameter must be a real scalar or vector.';
         ecode = 1;
      elseif( any([~isreal(LOSFd) (any(LOSFd ~= 0))]))
         emsg  = 'The Line-of-Sight Doppler frequency must be zero for a Rayleigh channel.';
         ecode = 1;
      elseif(any([~isreal(K) (any(K ~= 0))]))
         emsg  = 'The K-factor parameter must be zero for a Rayleigh channel.';
         ecode = 1;
      end;
   case 'RICIAN'
      % --- Rician specific parameter checks
      if(any([~isreal(LOSFd) isvector(LOSFd)]))
         emsg  = 'The Line-of-Sight Doppler frequency must be a real scalar.';
         ecode = 1;
      elseif(any([~isreal(K) (any(K < 0)) isvector(K)]))
         emsg  = 'The K-factor parameter must be a non-negative scalar.';
         ecode = 1;
      elseif(any([~isreal(delayVec) (any(delayVec < 0)) isvector(delayVec)]))
         emsg  = 'The delay parameter must be a non-negative scalar.';
         ecode = 1;
      elseif(any([~isreal(gainVecdB) isvector(gainVecdB)]))
         emsg  = 'The gain parameter must be a real scalar.';
         ecode = 1;
      end;
   case 'STAND_ALONE'
      % --- General mode parameter checks
      if(any([~isreal(delayVec) (any(delayVec < 0))]))
         emsg  = 'The delay parameter must be a non-negative scalar or vector.';
         ecode = 1;
      elseif(~isreal(gainVecdB))
         emsg  = 'The gain parameter must be a real scalar or vector.';
         ecode = 1;
      elseif(~isreal(LOSFd))
         emsg  = 'The Line-of-Sight Doppler frequency must be a real scalar or vector.';
         ecode = 1;
      elseif(any([~isreal(K) (any(K < 0))]))
         emsg  = 'The K-factor parameter must be a non-negative scalar or vector.';
         ecode = 1;
      end;

   otherwise
      error('Unknown internal mode encountered.');
   end;
   
end;

% --- Perform scalar expansion and length checks
if(~ecode)
   lenVec = [length(LOSFd) length(K) length(delayVec) length(gainVecdB)];
   maxLen = max(lenVec);

   vectorPos = find(lenVec > 1); % Vector with of vector parameter positions

   if(isempty(vectorPos))
      nPaths = 1;
   else
      vectorLengths = lenVec(vectorPos(find(vectorPos > 0)));
      if(~all((vectorLengths) == maxLen))
         switch(blkMode)
            case 'RAYLEIGH'
               emsg  = 'The Gain and delay parameters are vectors of different lengths.';
               ecode = 1;
            case 'RICIAN'
               emsg  = 'The K-factor, gain and delay fields must be scalar entries.';
               ecode = 1;
            otherwise
               emsg  = 'The Line-of-Sight Doppler frequency, K-factor, gain and delay parameters are vectors of different lengths.';
               ecode = 1;
         end;
      else
         nPaths = vectorLengths(1); % As the lengths are the same, just choose the first
      end;
   end;

   if(~ecode)
      scalarPos = (lenVec == 1);    % Boolean vector with a 1 where a scalar exists
      % --- Scalars are expanded to rows
      for n=1:length(lenVec)
         if(scalarPos(n))
            switch n
            case 1 % LOSFd
               LOSFd = ones(1,nPaths)*LOSFd;
            case 2 % K
               K = ones(1,nPaths)*K;
            case 3 % delayVec
               delayVec = ones(1,nPaths)*delayVec;
            case 4 % gainVec
               gainVecdB = ones(1,nPaths)*gainVecdB;
            end;
         end;
      end;

   end;

end;


% --- At this point, if ecode==0, all parameters are OK and calculations can continue
varargout{1} = ecode;
varargout{2} = emsg;
varargout{3} = params;

if(ecode)
   return;
end;

% --- If the K-factor is infinite, then the noise power is zero, so don't filter
%     If the Doppler frequency is infinite, then don't filter.

% --- Define the Doppler filter
dopplerFilterDetails = defineDopplerFilter;

if(any([isinf(K) isinf(Fd)]))
   dopplerFilterDetails.Num = 1;
   dopplerFilterDetails.Den = 1;

   actualIntFactor = Inf;  % Here, intFactor will be used to set the width of the profile signal

   startDelay = 0;
   
   interp1    = 1;
   interp1Num = [1 0];
   interp2    = 1;
   interp2Num = [1 0];
   
else
   Kf = dopplerFilterDetails.NormalizedBandwidth;
   
   % --- Compute interpolation required
   intFactor = round(dopplerFilterDetails.NormalizedBandwidth/(Fd*simTs));
   
   % --- If the interpolation is too large, then issue a warning
   intLimit = 6500;
   if(intFactor>intLimit)
      blkName = gcb;
      blkName(find(abs(blkName)<32))=' ';
      blkName = [blkName '/Fading Profile/Triggered Rayleigh Profile'];
      
      emsg  = sprintf('%s: \nThe values given for Doppler shift and Sample time have produced an internal \ninterpolation factor greater than %d. This may produce inaccurate results.', blkName, intLimit); 
      ecode = 2;
   end;
   
   % --- Partition interpolation between the two blocks
   maxInt = min(16,floor(sqrt(intFactor)));
   minInt = maxInt/2;
   [interp1,interp2] = splitfactor(intFactor, maxInt, minInt);
   
   actualIntFactor = interp1*interp2;
   
   % --- Design the interpolation filters using Kaiser
   Ts = 1; % Notional sample frequency
   
   % --- Design stage 1
   rp = 1;     % Passband ripple
   rs = 50;    % Stopband ripple
   a = [1 0];  % Desired amplitudes
   
   % --- Compute deviations
   dev = [(10^(rp/20)-1)/(10^(rp/20)+1) 10^(-rs/20)];
   
   % --- Design the filter
   [n,Wn,beta,typ] = kaiserord( Kf*[2 3], a, dev, interp1/Ts);
   interp1Num      = fir1(n, Wn, typ, kaiser(n+1,beta), 'noscale');
   
   % --- Design stage 2
   rp = 1;     % Passband ripple
   rs = 80;    % Stopband ripple
   a = [1 0];  % Desired amplitudes
   
   % --- Compute deviations
   dev = [(10^(rp/20)-1)/(10^(rp/20)+1) 10^(-rs/20)];
   % --- Design the filter
   [n,Wn,beta,typ] = kaiserord( Kf*[2 3]*interp1, a, dev, interp2/Ts);
   interp2Num      = fir1(n, Wn, typ, kaiser(n+1,beta), 'noscale');
   
   % --- Determine startup transient
   D1 = filterdelay(interp1Num);
   D2 = filterdelay(interp2Num);
   
   startDelay = round((((dopplerFilterDetails.Delay*interp1)+D1)*interp2)+D2);
   
   % --- Account for the gains/attenuations required in each stage
   interp1Num = interp1Num*interp1;
   interp2Num = interp2Num*interp2;
end;

% --- If the normalise gain option is chosen, then ensure that the overall
%     gain of the channels is 0dB
gainVecLin = 10.^(gainVecdB/10);
if(normGain)
   gainVecLin = gainVecLin/sum(gainVecLin);
end;

% --- Assign values to the parameter structure
params.nPaths       = nPaths;
params.Seed         = Seed;
params.dopplerSos   = dopplerFilterDetails.sos;  % Doppler SOS matrix
params.interp1Num   = interp1Num;
params.interp1      = interp1;
params.interp2Num   = interp2Num;
params.interp2      = interp2;
params.intFactor    = actualIntFactor;
params.startDelay   = startDelay;

if(isinf(actualIntFactor)) % An infinite interpolation indicates that no filtering or interpolation is required
   params.intFactor    = 1;
   params.maxPathWidth = Inf;
else
   params.maxPathWidth = actualIntFactor*max([1 round(10000/actualIntFactor)]);
end;

params.K     = K;
params.LOSFd = LOSFd;

params.sampleDelayVec = delayVec/simTs;
params.gainVecLin     = gainVecLin;

% --- Assign the output arguments
varargout{1} = ecode;
varargout{2} = emsg;
varargout{3} = params;

% ----------------
% --- Subfunctions
% ----------------

% --- Determine the mode of operation
function blkMode = determineMode(block)
   blkParent     = get_param(block,'Parent');
   blkParentType = get_param(get_param(gcb,'parent'),'type');

   % --- If the block is contained within another block, then check if it's Rayleigh or Rician
   if(strcmp(blkParentType,'block'))
      blkParentMaskType = get_param(get_param(gcb,'parent'),'MaskType');

      if(strcmp(blkParentMaskType,'Multipath Rayleigh Fading Channel'))
         blkMode = 'RAYLEIGH';
      elseif(strcmp(blkParentMaskType,'Rician Fading Channel'))
         blkMode = 'RICIAN';
      else
         blkMode = 'STAND_ALONE';
      end;

   else  % The block is at the top level of a model
         blkMode = 'STAND_ALONE';
   end;

return;


% --- Doppler filter definition
function [filterDetails] = defineDopplerFilter

   % --- Poles
   P(1) = 9.9015456438065e-01 + j*  4.500919952989e-02;
   P(2) = 9.9015456438065e-01 + j*(-4.500919952989e-02);
   P(3) = 9.8048448562622e-01 + j*  1.875760592520e-02;
   P(4) = 9.8048448562622e-01 + j*(-1.875760592520e-02);
   P(5) = 9.9652880430222e-01 + j*  5.493839457631e-02;
   P(6) = 9.9652880430222e-01 + j*(-5.493839457631e-02);
   P(7) = 9.9827980995178e-01 + j*  5.666938796639e-02;
   P(8) = 9.9827980995178e-01 + j*(-5.666938796639e-02 );
   
   % --- Zeros
   Z(1) = 9.9835836887360e-01 + j*  5.727641656995e-02;
   Z(2) = 9.9835836887360e-01 + j*(-5.727641656995e-02);
   Z(3) = 9.9744373559952e-01 + j*  7.145611196756e-02;
   Z(4) = 9.9744373559952e-01 + j*(-7.145611196756e-02);
   Z(5) = 9.9440407752991e-01 + j*  1.0564350336790e-01;
   Z(6) = 9.9440407752991e-01 + j*(-1.0564350336790e-01);
   Z(7) = 9.6530824899673e-01 + j*  2.6111298799515e-01;
   Z(8) = 9.6530824899673e-01 + j*(-2.6111298799515e-01);
   
   % --- Determine transfer function
   PVec = [P(1) P(2) P(3) P(4) P(5) P(6) P(7) P(8) ]';
   ZVec = [Z(1) Z(2) Z(3) Z(4) Z(5) Z(6) Z(7) Z(8) ]';
   
   % --- Convert to sos
   sos = zp2sos(ZVec,PVec,1);

   % --- Determine the gain of the filter
   rho    = max(abs(P));
   tol    = 0.1;          
   logtol = log(tol);   
   neff   = round(logtol/log(rho));

   impSeq = zeros(neff,1);
   impSeq(1) = 1;

   H = sosfilt(sos,impSeq);
   sos(1,1:3) = sos(1,1:3)/norm(H); % Remove gain
      
   % --- Set the output struture
   filterDetails.NormalizedBandwidth = 0.009;
   filterDetails.sos   = sos;
   filterDetails.Delay = 400; % Filter delay in samples
return;

% --- Split the requred interpolation into factors
function [factor1, factor2] = splitfactor(N,maxfact,minfact)

faclist = factor(N);
if (max(size(faclist)) == 1)
   N = N+1;
   faclist = factor(N);  
end
factor1 = 1;
factor2 = N;
dir = -1;
step = 0;
while (factor1 < minfact)
   [m, n] = size(faclist);
   num_factors = m*n;
   termlist = [1 faclist];
   for nterms = [2 : num_factors-1]
      termlist = unique([termlist prod(nchoosek(faclist,nterms)')]);
   end
   factor1 = termlist(max(find(termlist<=maxfact)));
   factor2 = N/factor1;
   if (factor1 < minfact)
      dir = -1*dir;
      step = step+1;
      N = N+step*dir;
      if (max(size(factor(N)) == 1))
         dir = -1*dir;
         step = step+1;
         N = N+step*dir;
      end
      faclist = factor(N);
   end  
end
return

% --- Determine the centre of mass of the filter transfer function
function D = filterdelay(h)
   i = 0:length(h)-1;
   D = sum((h.^2).*i)/sum(h.^2);
return

% ------------------
% Utility functions
% ------------------

% --- ISSCALAR
function ecode = isscalar(Vec)
   if(ndims(Vec) == 2)
      if(all([size(Vec,1)>1 size(Vec,2)>1]))
         ecode = 0; % Matrix
      else
         ecode = all([size(Vec,1)==1 size(Vec,2)==1]);
      end;
   else
      ecode = 0;
   end;
return;

% --- ISVECTOR
function ecode = isvector(Vec)
   if(ndims(Vec) == 2)
      if(all([size(Vec,1)>1 size(Vec,2)>1]))
         ecode = 0; % Matrix
      else
         ecode = any([size(Vec,1)>1 size(Vec,2)>1]);
      end;
   else
      ecode = 0;
   end;
return;

% --- ISMATRIX
function ecode = ismatrix(Vec)
   if(ndims(Vec) == 2)
      if(all([size(Vec,1)>1 size(Vec,2)>1]))
         ecode = 1; % Matrix
      else
         ecode = 0;
      end;
   else
      ecode = 1;
   end;
return;
