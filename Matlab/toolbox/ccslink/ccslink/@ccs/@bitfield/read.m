function resp = read(bb,index,timeout)
%READ Retrieves a block of data values from the DSP processor's memory.

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $ $Date: 2003/11/30 23:06:35 $

error(nargchk(1,3,nargin));
if ~ishandle(bb),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a BITFIELD Handle.');
end

if nargin == 1,
    resp = read_bitfield(bb);
elseif nargin == 2,
    if isempty(index),
        index = ones(1,length(bb.size));
    end
    resp = read_bitfield(bb,index);     
else
    resp = read_bitfield(bb,index,timeout);
end

% [EOF] read.m
