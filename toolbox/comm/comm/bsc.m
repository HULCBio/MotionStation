function [nData, varargout] = bsc(data, p, varargin)
%BSC Model a binary symmetric channel.
%   NDATA = BSC(DATA, P) passes the binary input signal DATA through a
%   binary symmetric channel with error probability P. If the input DATA is
%   a Galois field over GF(2), the Galois field data is passed through the
%   binary symmetric channel.
% 
%   NDATA = BSC(DATA, P, STATE) resets the state of RAND to STATE prior to
%   the generation of the error vector.
% 
%   [NDATA, ERR] = BSC(...) returns the errors introduced by the channel in
%   ERR.
% 
%   Example:
%       data = randint(20, 20);
%       p = 0.2;
%       [nData, err] = bsc(data, p);
%       obsP = sum(err(:))/prod(size(data))
% 
%   See also RAND, AWGN.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/12 23:00:32 $

% Begin error checking ----------------------------------------------------
%
% Number of input arguments
error(nargchk(2, 3, nargin, 'struct'));

% Number of output arguments
error(nargoutchk(0, 2, nargout, 'struct'));

% Check for real binary DATA or field data
if isa(data, 'gf')
    if (~isnumeric(data.x) || ~isreal(data.x) || (data.m ~= 1))
        error('comm:bsc:gfDataReal', ...
            'DATA field data must be binary values.');
    end
else
    if (~isnumeric(data) || ~isreal(data) || ...
        ~isequal((data + ~data), ones(size(data))))
    error('comm:bsc:dataReal', 'DATA must be real binary values.');
    end
end

% Check for real P within range
if (~isnumeric(p) || ~isreal(p) || ~isscalar(p) || ~((0 <= p) && (p <= 1))) 
    error('comm:bsc:pReal', 'P must be a real scalar between 0 and 1.');
end

% Check for valid third argument
if (nargin == 3) 
    state = varargin{1};
    if (~isnumeric(state) || ~isreal(state) || ~isscalar(state) || ... 
            (ceil(state) ~= state))
        error('comm:bsc:stateReal', 'STATE must be a real scalar integer.');
    else
        rand('state', state);
    end
end

% End of input error checking ---------------------------------------------



% Begin output argument processing ----------------------------------------

% Generate uniformly distributed random numbers in the interval (0,1) and
% compare them to the probability P of a channel error. If the generated
% random numbers are smaller, then an error has occurred in the channel.

if isa(data, 'gf')
    err = double(rand(size(data.x)) < p);
    nData = gf(xor(data.x, err));
else
    err = double(rand(size(data)) < p);
    nData = double(xor(data, err));
end

if (nargout == 2)
	varargout{1} = err;
end 

% End output argument processing ------------------------------------------

% EOF - bsc.m
