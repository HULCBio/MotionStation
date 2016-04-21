function commlib(varargin)
%COMMLIB Open The Communications Blockset.
%
%   COMMLIB opens the latest version of the Communications Blockset.
% 
%   COMMLIB(N) opens version number N of the Communications Blockset, 
%   where N may currently be 1.5 or 3.0.
%
%   COMMLIB N also opens version N.
%
%   The Communications Blockset has the following
%   tree structure:
%
%    COMMLIBV2            Main Library
%      COMMSOURCE2          Communications Sources
%        COMMRANDSRC2         Random Data Sources
%        COMMNOISGEN2         Noise Generators 
%        COMMSEQGEN2          Sequence Generators
%      COMMSINK2            Communications Sinks
%      COMMSRCCOD2          Source Coding
%      COMMEDAC2            Error Detection and Correction
%        COMMCRC2             Cyclic Redundancy Check Coding
%        COMMBLKCOD2          Block Coding
%        COMMCNVCOD2          Convolutional Coding
%      COMMINTERLEAVE2      Interleaving
%        COMMBLKINTRLV2       Block Interleaving
%        COMMCNVINTRLV2       Convolutional Interleaving
%      COMMMOD2             Modulation
%        COMMDIGBBND2         Digital Baseband Modulation
%          COMMDIGBBNDAM2       Digital Baseband Amplitude Modulation
%          COMMDIGBBNDPM2       Digital Baseband Phase Modulation
%          COMMDIGBBNDFM2       Digital Baseband Frequency Modulation
%          COMMDIGBBNDCPM2      Baseband Continuous Phase Modulation
%          COMMDIGBBNDTCM2      Trellis-Coded Modulation 
%        COMMANAPBND2         Analog Passband Modulation
%      COMMFILT2            Communications Filters
%      COMMCHAN2            Channels
%      COMMRFLIB2           RF Impairments
%      COMMSYNC2            Synchronization
%        COMMPHREC2             Carrier Phase Recovery
%        COMMTIMREC2            Timing Phase Recovery
%        COMMSYNCCOMP2          Synchronization Components
%      COMMEQ2              Equalizers
%      COMMSEQUENCE2        Sequence Operations
%      COMMUTIL2            Utility Blocks

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.20.4.3 $ $Date: 2003/07/30 02:48:16 $

error(nargchk(0,1,nargin));

if (nargin == 0)
   v = '3';
else
   v = varargin{1};    
end;

if ischar(v)
	vs = v;
elseif isnumeric(v)
   vs = num2str(double(v));
else
   error(['The Communications Blockset version number must be a string ',...
           'or numeric value.']);
end;

switch vs
case '1.5'
   vs = '1p5';
case {'3','3.0'}
   vs = '2';
otherwise
    error(['Unknown version of the Communications Blockset.']);
end;

model = ['commlibv' vs];

% Attempt to open library:
model = ['commlibv' vs];
try
   open_system(model);
catch
   error(['Could not find Communications Blockset version ',...
           vs ' (' model '.mdl).']);
end

% [EOF]
