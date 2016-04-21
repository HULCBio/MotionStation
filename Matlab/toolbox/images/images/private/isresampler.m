function q = isresampler(R)
%ISRESAMPLER True for valid resampling structure.
%   ISRESAMPLER(R) returns 1 if R is a valid resampler struct, such as
%   one created by MAKERESAMPLER, and 0 otherwise.
% 
%   See also MAKERESAMPLER.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $ $Date: 2003/01/26 05:59:56 $

q = isa(R,'struct') ...
    & isfield(R,'ndims') ...
    & isfield(R,'padmethod') ...
    & isfield(R,'resamp_fcn') ...
    & isfield(R,'rdata');

if q
    q = (length(R) == 1);
end

if q
    q = ~isempty(R.ndims) ...
        & ~isempty(R.resamp_fcn) ...
        & ~isempty(R.padmethod);
end

if q
    q = isa(R.ndims,'double')     ...
        & length(R.ndims) == 1    ...
        & isreal(R.ndims)         ...
        & isa(R.padmethod,'char') ...
        & isa(R.resamp_fcn,'function_handle');
end

if (q & R.ndims ~= Inf)
    q = R.ndims == floor(R.ndims) ...
        & R.ndims >= 1;
end

if q
    q = (length(strmatch(R.padmethod,...
          {'fill','bound','replicate','circular','symmetric'},'exact')) == 1);
end
