function out = randbit(m, n, prob, state);
%RANDBIT Binary noise generator.
%    WARNING: This is now an obsolete function.  Use RANDERR instead.

%
%    OUT = RANDBIT(M) generates an M-by-M zeros matrix with a single
%    "1" randomly placed in any bit of each row. 
%
%    OUT = RANDBIT(M,N) generates an M-by-N zero matrix with a single 
%    "1" randomly placed in any bit of each row. 
%
%    OUT = RANDBIT(M,N,PROB) generates an M-by-N zeros matrix with "1"s
%    uniformly distributed in any bit of each row. The probability of "1"
%    appearance is specified in vector PROB. The first element of PROB
%    is the probability of single "1" in each row. The second element of
%    PROB is the probability of two "1"s in each row and so on. The size
%    of vector PROB is the maximum number of "1"s bit in each row.
%    The sum of the PROB cannot be larger than one. 
%
%    OUT = RANDBIT(M,N,PROB,STATE) resets the initial state for
%    the random number generator, where STATE is an integer.
%
%    This function was initially designed to test error-control coding.
%
%    See also RAND, RANDSRC, RANDINT.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.11 $  $Date: 2002/03/27 00:19:52 $ 


% Basic error checking and parameter setup etc.
if nargin < 1
   error('Not enough input arguments.');
elseif isempty(m)
   error('Required parameter empty.');
end

if (nargin < 2) | (isempty(n))
   n = m;
   prob = 1;
elseif (nargin < 3) | (isempty(prob))
   prob = 1;
elseif (nargin > 3) & (~isempty(state))
    rand('state', state');
end

if (~isfinite(m)) | (~isfinite(n)) | (~isfinite(prob))
   error('Input parameters must be finite.');
elseif (floor(m) ~= m) | (floor(n) ~= n) | (~isreal(m)) | (~isreal(n))
   error('Matrix dimensions must be real integers.');
elseif (m <= 0) | (n <= 0)
   error('Matrix dimensions must be positive.');
elseif (~isreal(prob))
   error('Elements of "prob" must be real values.');
elseif any(prob > 1) | any(prob < 0)
   error('Elements of "prob" must be between zero and one.');
end

len_prob = length(prob);

if len_prob > n
   error('The "prob" vector cannot be larger than the number of columns output.');
elseif (sum(prob) - 1 > eps)
   error('Elements of "prob" cannot sum to greater than one.');
elseif (size(prob,1) > 1) & (size(prob,2) > 1)
   error('The "prob" parameter must be a vector.');
end

% Generate an all zeros output matrix, in which ones are placed.
out = zeros(m, n);

% The 'prob2' vector facilitates determining how many ones are to be
% placed in each row of the output.
% Example:
%     If the input parameter 'prob' is set to [0.1 0.2 0.3 0.4],
%     then 'prob2' will be [0.1 0.3 0.6 1.0].
prob2 = prob(1);
for i = 2:len_prob,
   prob2 = [prob2 (prob2(i-1)+prob(i))];
end;


% Now loop through each row of the output matrix.
for i = 1:m,
   
   % First determine how many ones will be put in each row.
   num = rand(1,1);
   place = 1;
   while (num < 1) & (place <= len_prob),
      if num < prob2(place)
         num = place;
      end
      place = place + 1;
   end;
   
   % It is possible to have no ones put in a row.
   if num < 1
      num = 0;
   end;
      
   % If more than n/2 ones are to be placed in a row it is quicker
   % to set the whole row to ones and then place zeros instead.
   if num > (n/2)
      insert = 0;
      out(i,:) = ones(1,n);
      num = n - num;
   else
      insert = 1;
   end;
   
   % Now cycle through and find some random locations to place
   % each one (or zero).
   for j = 1:num,
      
      not_placed = 1;
      while not_placed,
         place = randint(1,1,[1,n]);
         if out(i,place) ~= insert
            out(i,place) = insert;
            not_placed = 0;
         end;
      end;
      
   end;
   
end;

% [EOF] randbit.n 

