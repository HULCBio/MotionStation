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

% Copyright 2000-2004 The MathWorks, Inc.
% $Revision: 1.20.2.4 $ $Date: 2004/04/08 20:46:48 $

if (nargin ~= 1) & (nargin ~= 3) & (nargin ~=4),
    error('The number of input arguments must be one, three or four.');
end
if nargin == 1,
    bufferLength = 1024;
    numBuffers = 4;
    imodeRtdx = 1;
else
    if ~isnumeric(bufferLength) | ...
            ~isreal(bufferLength) | ...
            (bufferLength<0) | (bufferLength ~= floor(bufferLength)),
        error('The specified buffer length must be a positive integer value.');
    end
    if (bufferLength<1024) | (bufferLength>2^31-1),
        error(sprintf(['The specified buffer length is out of bounds.'...
                '  Must be 1024 bytes or greater.']));
    end
    if ~isnumeric(numBuffers) | ...
            ~isreal(numBuffers) | ...
            (numBuffers<0) | (numBuffers ~= floor(numBuffers)),
        error('The specified number of buffers must be a positive integer value.');
    end 
end
if nargin == 4,
    if (numBuffers<4) | (numBuffers>2^31-1),
        error(sprintf(['The specified number of buffers is out of bounds.'...
                '  Must be 4 buffers or more.']));
    end
    if ~ischar(modeRtdx),
         error('The specified number of buffers must be a positive integer value.'); 
    end
    imodeRtdx = strmatch(modeRtdx,['continuous    ';'non-continuous']);  % 1 = cont, 2= non
else
    imodeRtdx = 1;    
end
callSwitchyard(r.ccsversion,[100,r.boardnum,r.procnum,0,0],bufferLength,numBuffers,imodeRtdx);

% [EOF] configure.m
