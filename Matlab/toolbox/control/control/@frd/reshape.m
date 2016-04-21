function sys = reshape(sys,varargin)
%RESHAPE  Reshape array of LTI models
%
%   SYS = RESHAPE(SYS,S1,S2,...,Sk) reshapes the LTI array SYS
%   into a S1-by-S2-by...-Sk array of LTI models.  There must
%   be S1*S2*...*Sk models to begin with.
% 
%   SYS = RESHAPE(SYS,[S1 S2 ... Sk]) is the same thing.
%
%   See also SIZE, NDIMS, LTIMODELS.

%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/12/04 01:25:56 $

ni = nargin;
if ni<2,
    error('Not enough inputs.')
elseif ni==2,
    newdims = varargin{1};
else
    newdims = [varargin{:}];
end

% Perform RESHAPE operation
sizes = size(sys);

if prod(newdims)~=prod(sizes(3:end)),
    error('In RESHAPE operations, the number of LTI models must not change.')
else
    sizeRD = size(sys.ResponseData);
    sys.ResponseData = reshape(sys.ResponseData,[sizeRD(1:3), newdims]);
end

