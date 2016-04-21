function out = randerr(varargin);
%RANDERR Generate bit error patterns.
%   OUT = RANDERR(M) generates an M-by-M binary matrix with exactly
%   one "1" randomly placed in each row.
%
%   OUT = RANDERR(M,N) generates an M-by-N binary matrix with exactly
%   one "1" randomly placed in each row.
%
%   OUT = RANDERR(M,N,ERRORS) generates an M-by-N binary matrix, with
%   the number of "1"s in any given row determined by ERRORS.
%
%   ERRORS can be either a scalar, row vector or two-row matrix:
%   Scalar  : If ERRORS is a scalar the number of "1"s to place in each
%             row is defined by ERRORS.
%   Vector  : If ERRORS is a row vector, then its elements specify how
%             many "1"s are possible.  Every number of "1"s included in
%             this vector occur with equal probability.
%   Two-Row : If ERRORS is a two-row matrix, the first row specifies how
%   Matrix    many "1"s are possible and the second row specifies the
%             probabilities of each corresponding number of "1"s.  The
%             elements in the second row of ERRORS must sum to one.
%
%   OUT = RANDERR(M,N,ERRORS,STATE) resets the state of RAND to STATE.
%
%   This function can be useful for testing error-control coding.
%
%   Examples:
%   » out = randerr(2,5)               » out = randerr(2,5,2)
%   out =                              out =
%        0    0    0    1    0              0    0    1    0    1
%        1    0    0    0    0              0    1    1    0    0
%
%   » out = randerr(2,5,[1 3])         » out = randerr(2,5,[1 3;0.8 0.2])
%   out =                              out =
%        1    0    1    1    0              0    1    0    0    0
%        1    0    0    0    0              0    0    0    1    0
%
%   See also RAND, RANDSRC, RANDINT.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/03/27 00:09:18 $


% Basic error checking and parameter setup etc.
error(nargchk(1,4,nargin));

% --- Placeholder for the signature string.
sigStr = '';
m = [];
n = [];
err = [];
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
   % --- randerr(m)
   case 'n'
      m		= varargin{1};

	% --- randerr(m, n)
	case 'n/n'
      m		= varargin{1};
      n		= varargin{2};

	% --- randerr(m, n, err)
	case 'n/n/n'
      m		= varargin{1};
      n  	= varargin{2};
      err	= varargin{3};

	% --- randerr(m, n, err, state)
	case 'n/n/n/n'
      m		= varargin{1};
      n		= varargin{2};
      err	= varargin{3};
      state = varargin{4};

   % --- If the parameter list does not match one of these signatures.
   otherwise
      error('Syntax error.');
end;

if isempty(m)
   error('Required parameter empty.');
end
if isempty(n)
   n = m;
end
if isempty(err)
   err = 1;
end

if (~isfinite(m)) | (~isfinite(n))
   error('Input parameters must be finite.');
elseif (floor(m) ~= m) | (floor(n) ~= n) | (~isreal(m)) | (~isreal(n))
   error('Matrix dimensions must be real integers.');
elseif (m <= 0) | (n <= 0)
   error('Matrix dimensions must be positive.');
elseif (length(m) > 1) | (length(n) > 1)
   error('Matrix dimensions must be scalars.');
end

if (~isfinite(err(1,:))) | (~isreal(err(1,:))) | max(floor(err(1,:)) ~= err(1,:)) | max(err(1,:) < 0)
   error('First row of the ERRORS parameter must contain finite real positive integers.');
elseif max(err(1,:) > n)
   error('Cannot place more "1"s in a row than there are elements in the row.');
end

[em, en] = size(err);

% If the probabilities are explicitly defined in the function call.
if (em == 2)

   if (~isreal(err(2,:)))
      error('Second row of the ERRORS parameter must be real.');
   elseif any( (err(2,:) > 1) | (err(2,:) < 0) )
      error('Elements of second row of the ERRORS parameter must be between zero and one.');
   elseif ( abs(sum(err(2,:)) - 1) > sqrt(eps) )
      error('Sum of ERRORS probability elements must equal one.');
   end

	% The 'prob' vector facilitates determining how many ones are to be
	% placed in each row of the output.
	% Example:
	%     If the 2nd row of 'err' is set to [0.1 0.2 0.3 0.4],
	%     then 'prob' will be [0.1 0.3 0.6 1.0].
   prob = cumsum(err(2,:));

% Default to using equal probabilities if not explicitly given.
elseif (em == 1)

   prob = (1:en) / en;

else
   error('ERRORS parameter cannot contain more than two rows.');
end

% Initialize the output matrix to all zeros.
out = zeros(m,n);

% Set the state if specified.
if ~isempty(state)
   rand('state', state);
end

% Now loop through each row of the output matrix.
for i = 1:m,

   % First determine how many ones will be put in each row.
   num = rand(1,1);
   not_done = 1;
   j = 1;
   while not_done
      if ( num < prob(j) )
         num = err(1,j);
         not_done = 0;
      end
      j = j + 1;
   end

   % Now find some random locations to place each one.
	[ignore,p] = sort(rand(1,n));
	out(i,:) = p <= num;

end;

% [EOF] randerr.m

