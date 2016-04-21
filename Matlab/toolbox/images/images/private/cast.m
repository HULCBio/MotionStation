function out = cast(in, datatype, varargin)
%CAST Convert datatypes, expanding and shrinking size of matrices.
%   Y = CAST(X, DATATYPE) convert X to DATATYPE.  If DATATYPE has fewer
%   bits than the class of X, Y will have more elements than X.  If
%   DATATYPE has more bits than the class of X, Y will have fewer
%   elements than X.
%
%   Y = CAST(X, DATATYPE, SWAP) convert X to DATATYPE and perform byte
%   swapping on the result.  If SWAP is nonzero, the result will be
%   swapped.
%
%   Note: DATATYPE must be one of 'UINT8', 'INT8', 'UINT16', 'INT16',
%   'UINT32', 'INT32', 'SINGLE', or 'DOUBLE'.
%
%   Note: If X contains fewer values than are needed to make an output
%   value, the last elements of X will not be used.
%
%   Example:
%
%      X = uint32([1 2 3]);
%      Y = cast(X, 'uint8');
%
%   On little-endian architectures Y will be
%
%      [1   0   0   0   2   0   0   0   3   0   0   0]
%
%      Z = cast(X, 'uint8', 1);
%
%   On little-endian architectures Z will be
%
%      [0   0   0   1   0   0   0   2   0   0   0   3]
%
%   See also CLASS.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.3 $  $Date: 2003/08/23 05:53:34 $

error(nargchk(2, 3, nargin, 'struct'))

if ((nargin == 2) || (isequal(varargin{1}, 0)))
    
    out = castc(in, datatype);
    
else
    
    switch (lower(datatype))
    case {'uint8', 'int8'}
        
    otherwise
        eid = sprintf('Images:%s:byteSwapNotSupported',mfilename);                    
        error(eid,'%s','Byte swapping is only supported for INT8/UINT8 output.')
        
    end
    
    switch (class(in))
    case {'uint8', 'int8'}
        numbytes = 1;
        
    case {'uint16', 'int16'}
        numbytes = 2;
        
    case {'uint32', 'int32', 'single'}
        numbytes = 4;
        
    case {'uint64', 'int64', 'double'}
        numbytes = 8;
        
    end
    
    tmp = castc(in, datatype);
    
    tmp = reshape(tmp, [numbytes (numel(tmp)/numbytes)]);
    tmp = flipud(tmp);

    if (size(in, 1) ~= 1)
        out = reshape(tmp, [numel(tmp) 1]);
    else
        out = reshape(tmp, [1 numel(tmp)]);
    end
    
end
