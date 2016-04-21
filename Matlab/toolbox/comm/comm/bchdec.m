function [decoded, cnumerr,ccode] = bchdec(coded,N,K, varargin);
%BCHDEC BCH decoder.
%   DECODED = BCHDEC(CODE,N,K) attempts to decode the received signal in CODE 
%   using an (N,K) BCH decoder with the narrow-sense generator 
%   polynomial. CODE is a Galois array of symbols over GF(2).
%   Each N-element row of CODE represents a corrupted systematic codeword, 
%   where the parity symbols are at the end and the leftmost symbol is the most
%   significant symbol. 
%   
%   In the Galois array DECODED, each row represents the attempt at decoding the 
%   corresponding row in CODE. A decoding failure occurs if a row of CODE 
%   contains more than T errors, where T is the number of correctable errors
%   as returned from BCHGENPOLY. In this case, BCHDEC forms the 
%   corresponding row of DECODED by merely removing N-K symbols from the end of 
%   the row of CODE.
%   
%   DECODED = BCHDEC(...,PARITYPOS) specifies whether the parity symbols in CODE 
%   were appended or prepended to the message in the coding operation. The string 
%   PARITYPOS can be either 'end' or 'beginning'. The default is 'end'. If 
%   PARITYPOS is 'beginning', then a decoding failure causes BCHDEC to remove 
%   N-K symbols from the beginning rather than the end of the row.
%   
%   [DECODED,CNUMERR] = BCHDEC(...) returns a column vector CNUMERR, each element
%   of which is the number of corrected errors in the corresponding row of CODE. 
%   A value of -1 in CNUMERR indicates a decoding failure in that row in CODE.
%   
%   [DECODED,CNUMERR,CCODE] = BCHDEC(...) returns CCODE, the corrected version of
%   CODE. The Galois array CCODE is in the same format as CODE. If a decoding 
%   failure occurs in a certain row of CODE, then the corresponding row in CCODE
%   contains that row unchanged.
%
%   See also BCHENC. 

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.1.6.5 $  $ $ 

error(nargchk(3,4,nargin));

% Fundamental checks on parameter data types
if ~isa(coded,'gf')
   error('CODE must be a Galois array.');
end

if(coded.m~=1)
    error('Code must be in GF(2).');
end

[m_code, n_code] = size(coded);

% Check mandatory parameters : code, N, K, t

% --- code
if isempty(coded.x)
    error('CODE must be a nonempty Galois array.');
end;

% --- width of code
if N ~= n_code
    error('CODE must be either a N-element row vector or a matrix with N columns.');
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

% get the number of errors we can correct 
t = bchnumerr(N,K);
     
M = log2(N+1);
% bring the coded word into the extension field
coded = gf(coded.x,M);
[m_code, n_code] = size(coded);

for j=1:m_code,    
    % Call to core algorithm BERLEKAMP
    [coded(j,:) cnumerr(j)] = berlekamp(coded(j,:),N,K,t,1,'bch');
end

% bring back to gf(2)
ccode = gf(coded.x);

switch parityPos
   case 'end'
      decoded = ccode(:,1:K);    
   case 'beginning'
      decoded = ccode(:,N-K+1:end);    
end;




