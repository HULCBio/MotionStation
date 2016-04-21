function configure(r, bufferLength, numBuffers, modeRtdx)
%CONFIGURE Define the size and number of RDTX(tm) channel buffers.
%   CONFIGURE(R, LENGTH, NUMBER, MODE) sets the LENGTH in bytes of each RTDX
%   channel buffer and the NUMBER of channel buffers.  The operating MODE is 
%   defined by a string as either 'continuous' or 'non-continuous'.
%
%   CONFIGURE(R, LENGTH, NUMBER) sets the LENGTH in bytes of each RTDX
%   channel buffer and the NUMBER of channel buffers.  The MODE is set to
%   'continuous' by default. 
%
%   CONFIGURE configures channel buffers using the defaults of LENGTH = 1024 
%   bytes, NUMBER = 4 buffers, MODE = 'continuous'.
%
%  Example
%  > configure(r,64000,4,'non-continuous');
%
%  See also RTDX, ENABLE, OPEN.

% Copyright 2004 The MathWorks, Inc.
