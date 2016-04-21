function close(varargin)
%CLOSE Close RDTX(tm) channels to the target DSP.
%   CLOSE(R, CHANNEL1, CHANNEL2,...) closes open RTDX channels specified by
%   string names CHANNEL1, CHANNEL2, etc., and as defined in the RTDX object R.
%   Interface handle to the specified channel is released and the channel
%   entry is removed for the RtdxChannel cell array.
%
%   CLOSE(R, CHANNEL) closes a single specified CHANNEL, or if CHANNEL is 
%   'all' or 'ALL', then all open channels are closed.
%
%   See also OPEN

% Copyright 2004 The MathWorks, Inc.
