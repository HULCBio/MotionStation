function open(varargin)
%OPEN Open RDTX(tm) channels to the target DSP.
%   OPEN(R, CHANNEL1, MODE1, CHANNEL2, MODE2,...) opens new RTDX channels
%   with specified string names CHANNEL1, CHANNEL2, etc. and corresponding 
%   specified read/write modes MODE1, MODE2, etc., and stores these attributes
%   in the RTDX object R.
%       MODE: 'r' or 'R' to configure channel for read, or
%             'w' or 'W' to configure for write
%
%   OPEN(R, CHANNEL, MODE) opens a single, new RTDX channel.
%
%   Note:  Code Composer Studio(R) API will error out if corresponding channel
%   name is not defined and enabled in the target DSP code.
%
%   See also CLOSE

% Copyright 2004 The MathWorks, Inc.
