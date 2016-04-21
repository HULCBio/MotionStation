function chan = ricianchan(varargin);
%RICIANCHAN   Construct a Rician fading channel object.
%   CHAN = RICIANCHAN(TS, FD, K) constructs a frequency-flat ("single
%   path") Rician fading channel object.  TS is the sample time of the
%   input signal, in seconds.  FD is the maximum Doppler shift, in Hertz.
%   K is the Rician K-factor.  You can model the effect of the channel CHAN
%   on a signal X by using the syntax Y = FILTER(CHAN, X).  Type 'help
%   channel/filter' for more information.
%
%   CHAN = RICIANCHAN(TS, FD, K, TAU, PDB) constructs a frequency-selective
%   ("multiple path") fading channel object that models the first discrete
%   path as a Rician fading process and each of the remaining discrete
%   paths as an independent Rayleigh fading process.  TAU is a vector of
%   path delays, each specified in seconds.  PDB is a vector of average
%   path gains, each specified in dB.
%
%   CHAN = RICIANCHAN sets the maximum Doppler shift to 0 and the K-factor
%   to 1.  This is a static frequency-flat channel (see below).  In this
%   trivial case, the sample time of the signal is unimportant.
%
%   The Rayleigh fading channel object has the following properties:
%             ChannelType: 'Rayleigh'
%       InputSamplePeriod: Input signal sample period (s)
%         MaxDopplerShift: Maximum Doppler shift (Hz)
%                 KFactor: Rician K-factor for first path (scalar)
%              PathDelays: Discrete path delay vector (s)
%           AvgPathGaindB: Average path gain vector (dB)
%      NormalizePathGains: Normalize path gains (0 or 1)
%               PathGains: Current complex path gain vector
%      ChannelFilterDelay: Channel filter delay (samples)
%    ResetBeforeFiltering: Resets channel state every call (0 or 1)
%     NumSamplesProcessed: Number of samples processed
%
%   To access or set the properties of the object CHAN, use the syntax
%   CHAN.Prop, where 'Prop' is the property name (for example, 
%   CHAN.KFactor = 10).  To view the properties of an object CHAN, 
%   type CHAN.
%
%   If MaxDopplerShift is 0 (the default), the channel object CHAN models a
%   static channel.  The first path comes from a Rician distribution, and
%   the remaining paths come from a Rayleigh distribution.  Use the syntax
%   RESET(CHAN) to generate a new channel realization.  Type 
%   'help channel/reset' for more information.
%    
%   For information on other properties, type 'help rayleighchan'.
%
%   See also RAYLEIGHCHAN, CHANNEL/FILTER, CHANNEL/RESET.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:01:18 $

% This function is a wrapper for an object constructor (channel.rayleigh)

error(nargchk(0, 5, nargin));
if nargin==1 || nargin==2
    error('comm:ricianchan:numargs', ...
        'Number of arguments must be 0, 3, 4, or 5.');
end
chan = channel.rician(varargin{:});
