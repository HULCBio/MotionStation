function out = randsrc(varargin);
%RANDSRC Generate random matrix using prescribed alphabet.
%   OUT = RANDSRC generates a "-1" or "1" with equal probability.
%
%   OUT = RANDSRC(M) generates an M-by-M random bipolar matrix.
%   "-1" and "1" occur with equal probability.
%
%   OUT = RANDSRC(M,N) generates an M-by-N random bipolar matrix.
%   "-1" and "1" occur with equal probability.
%
%   OUT = RANDSRC(M,N,ALPHABET) generates an M-by-N random matrix, using the
%   alphabet specified in ALPHABET.
%
%   ALPHABET can be either a row vector or a two-row matrix:
%   Row     : If ALPHABET is a row vector then the contents of ALPHABET define
%   Vector    which possible elements RANDSRC can output.  The elements of
%             ALPHABET may be either real or complex.  If all entries of
%             ALPHABET are distinct, then the probability distribution is
%             uniform.
%   Two-Row : If ALPHABET is a two-row matrix, the first row defines the
%   Matrix    possible outputs (as above).  The second row of ALPHABET
%             specifies the probability for each corresponding element.  The
%             elements of the second row must sum to one.
%
%   OUT = RANDSRC(M,N,ALPHABET,STATE) resets the state of RAND to STATE.
%
%   Examples:
%   » out = randsrc(2,3)               » out = randsrc(2,3,[3 4])
%   out =                              out =
%        1    -1    -1                      4     4     3
%       -1    -1     1                      3     3     4
%
%   » out = randsrc(2,3,[3 4;0 1])     » out = randsrc(2,3,[3 4;0.8 0.2])
%   out =                              out =
%        4     4     4                      3     3     3
%        4     4     4                      3     4     3
%
%   See also RAND, RANDINT, RANDERR.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/03/27 00:09:24 $

% Basic function setup.
error(nargchk(0,4,nargin));

% --- Placeholder for the signature string.
sigStr = '';
m = [];
n = [];
alpha = [];
state = [];

% --- Identify string and numeric arguments
for i=1:nargin
   if(i>1)
      sigStr(size(sigStr,2)+1) = '/';
   end;
   % --- Assign the string and numeric flags
   if(isnumeric(varargin{i}))
      sigStr(size(sigStr,2)+1) = 'n';
   else
      error('Only numeric arguments are accepted.');
   end;
end;

% --- Identify parameter signitures and assign values to variables
switch sigStr
   % --- randsrc
   case ''

   % --- randsrc(m)
   case 'n'
      m		= varargin{1};

	% --- randsrc(m, n)
	case 'n/n'
      m		= varargin{1};
      n		= varargin{2};

	% --- randsrc(m, n, alpha)
	case 'n/n/n'
      m		= varargin{1};
      n  	= varargin{2};
      alpha = varargin{3};

	% --- randsrc(m, n, alpha, state)
	case 'n/n/n/n'
      m		= varargin{1};
      n		= varargin{2};
      alpha = varargin{3};
      state = varargin{4};

   % --- If the parameter list does not match one of these signatures.
   otherwise
      error('Syntax error.');
end;

if isempty(m)
   m = 1;
end
if isempty(n)
   n = m;
end
if isempty(alpha)
   alpha = [-1, 1];
end

% Typical error-checking.
if (~isfinite(m)) | (~isfinite(n))
   error('Matrix dimensions must be finite.');
elseif (floor(m) ~= m) | (floor(n) ~= n) | (~isreal(m)) | (~isreal(n))
   error('Matrix dimensions must be real integers.');
elseif (m < 0) | (n < 0)
   error('Matrix dimensions must be positive.');
elseif (length(m) > 1) | (length(n) > 1)
   error('Matrix dimensions must be scalars.');
end

ar = size(alpha,1);
ac = size(alpha,2);

if ar > 2
   error('The ALPHABET parameter cannot contain more than two rows.');

% If the alphabet probabilities are explicitly defined.
elseif ar == 2

   aprob = alpha(2,:);

   % Error-check the probabilities.
   if (~isreal(aprob)) | (~isfinite(aprob)) | max(aprob < 0) | max(aprob > 1)
      error('The ALPHABET probability elements must be real numbers between zero and one.');
   elseif (abs(sum(aprob) - 1) > sqrt(eps))
      error('Sum of ALPHABET probability elements must equal one.');
   end

   % 'prob' is used to facilitate assigning the random elements to the output.
   % Ex: if the second row of the alphabet input parameter
   %     is [0.3 0.4 0.3] then 'prob' would be set to [0.3 0.7 1.0].
	prob = cumsum(aprob);

else

   % Define the 'prob' vector if the probabilities are not given in the function call.
   prob = (1:ac) / ac;

end

% Set the initial state if specified.
if ~isempty(state)
   rand('state', state);
end

% Generate the random matrix.
r = rand(m,n);

% 'idx' is used to place the alphabet elements in the output matrix.
idx = ones(m,n);

% Use the random matrix 'r' to determine which alphabet element to use
% in the output matrix.
% Ex: if the alphabet parameter is {'a' 'b' 'c' 'd'}, the 'idx' matrix
%     will contain integers from one to four after this loop has run.
for i = 1:ac
   idx = idx + (r >= prob(i));
end

alphabet = alpha(1,:);

% Assign alphabet elements to the output matrix as specified by 'idx'.
out = alphabet(idx);

% A special case, if the m and n parameters specify a column vector.
if n == 1
   out = out(:);
end

% [EOF] randsrc.m
