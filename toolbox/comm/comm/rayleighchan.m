function chan = rayleighchan(varargin);
%RAYLEIGHCHAN   Construct a Rayleigh fading channel object.
%   CHAN = RAYLEIGHCHAN(TS, FD) constructs a frequency-flat ("single path")
%   Rayleigh fading channel object.  TS is the sample time of the input
%   signal, in seconds.  FD is the maximum Doppler shift, in Hertz.   You
%   can model the effect of the channel CHAN on a signal X by using the
%   syntax Y = FILTER(CHAN, X).  Type 'help channel/filter' for more
%   information.
%
%   CHAN = RAYLEIGHCHAN(TS, FD, TAU, PDB) constructs a frequency-selective
%   ("multiple path") fading channel object that models each discrete path
%   as an independent Rayleigh fading process.  TAU is a vector of path
%   delays, each specified in seconds.  PDB is a vector of average path
%   gains, each specified in dB.
%
%   CHAN = RAYLEIGHCHAN sets the maximum Doppler shift to zero.  This is a
%   static frequency-flat channel (see below).  In this trivial case, the
%   sample time of the signal is unimportant.
%
%   The Rayleigh fading channel object has the following properties:
%             ChannelType: 'Rayleigh'
%       InputSamplePeriod: Input signal sample period (s)
%         MaxDopplerShift: Maximum Doppler shift (Hz)
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
%   CHAN.MaxDopplerShift = 50).  To view the properties of an object CHAN,
%   type CHAN.
%
%   If MaxDopplerShift is 0 (the default), the channel object CHAN models a
%   static channel that comes from a Rayleigh distribution.  Use the syntax
%   RESET(CHAN) to generate a new channel realization.  Type 'help
%   channel/reset' for more information.
%    
%   If NormalizePathGains is 1 (default value 0), the fading processes are
%   normalized such that the total power of the path gains, averaged over
%   time, is 1.
%
%   PathGains is initialized to a random channel realization.  After the
%   channel filter function processes a signal, PathGains holds the last
%   complex path gains of the underlying fading processes.
%
%   For frequency-selective fading, the channel is implemented as a finite
%   impulse response (FIR) filter with uniformly spaced taps and an
%   automatically computed delay given by ChannelFilterDelay.  Note,
%   however, that the underlying complex path gains may introduce
%   additional delay.
%
%   If ResetBeforeFiltering is 1 (the default), the channel state is reset
%   each time you call the channel filter function.  Otherwise, the fading
%   process maintains continuity over calls (type 'help channel/filter' for
%   more information).  For instance, PathGains and NumSamplesProcessed are
%   reset every call if ResetBeforeFiltering is 1; otherwise they begin
%   with their previous values.
%
%   See also RICIANCHAN, CHANNEL/FILTER, CHANNEL/RESET.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/09 17:35:21 $

% This function is a wrapper for an object constructor (channel.rayleigh)

error(nargchk(0, 4, nargin));
if nargin==1
    error('comm:rayleighchan:numargs', ...
        'Number of arguments must be 0, 2, 3, or 4.');
end
chan = channel.rayleigh(varargin{:});
