function code = bchenc(msg, N, K, varargin)
%BCHENC BCH encoder.
%   CODE = BCHENC(MSG,N,K) encodes the message in MSG using an (N,K) BCH
%   encoder with the narrow-sense generator polynomial. MSG is a Galois 
%   array of symbols over GF(2). Each K-element row of MSG represents a 
%   message word, where the leftmost symbol is the most significant symbol. 
%   Parity symbols are at the end of each word in the output Galois array CODE. 
%      
%   CODE = BCHENC(...,PARITYPOS) specifies whether BCHENC appends or prepends the 
%   parity symbols to the input message to form CODE. The string PARITYPOS can 
%   be either 'end' or 'beginning'. The default is 'end'.
%   
%   See also BCHDEC, BCHGENPOLY. 

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $ $ 

% Initial checks
error(nargchk(3,4,nargin));

% Number of optional input arguments
nvarargin = nargin - 3;

% % Fundamental checks on parameter data types
if ~isa(msg,'gf')
   error('MSG must be a Galois array.');
end

if(msg.m ~=1)
    error('MSG must be in GF(2).');
end

%set and check the parity position
if(nargin>3)
    parityPos = varargin{1};
else
    parityPos = 'end';
end

if( ~strcmp(parityPos,'beginning') && ~strcmp(parityPos, 'end') )
    error('PARITYPOS must be either ''beginning'' or ''end''  ')
end


[m_msg, n_msg] = size(msg);

if (n_msg ~= K)
    error('The message length must equal K.')
end


% get the generator polynomial
genpoly = bchgenpoly(N,K);

% get the generator matrix
[h, gen] = cyclgen(N, (double(genpoly.x)));

% do the coding
code = msg * gen;

% rearrange parity if necessary
%if(isempty(varargin) || strcmp(lower(varargin{1}), 'beginning'))
if(strcmp(parityPos, 'end'))
    code = [code(:,N-K+1:end), code(:,1:N-K)];
end
    
