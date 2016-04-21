function varargout = rsdec(code,N,K,varargin)
%RSDEC Reed-Solomon decoder.
%   DECODED = RSDEC(CODE,N,K) attempts to decode the received signal in CODE 
%   using an (N,K) Reed-Solomon decoder with the narrow-sense generator 
%   polynomial. CODE is a Galois array of symbols over GF(2^m), where m is the
%   number of bits per symbol. Each N-element row of CODE represents a 
%   corrupted systematic codeword, where the parity symbols are at the end and 
%   the leftmost symbol is the most significant symbol. If N is smaller than 
%   2^m-1, then RSDEC assumes that CODE is a corrupted version of a shortened 
%   code.
%   
%   In the Galois array DECODED, each row represents the attempt at decoding the 
%   corresponding row in CODE. A decoding failure occurs if a row of CODE 
%   contains more than (N-K)/2 errors. In this case, RSDEC forms the 
%   corresponding row of DECODED by merely removing N-K symbols from the end of 
%   the row of CODE.
%   
%   DECODED = RSDEC(CODE,N,K,GENPOLY) is the same as the syntax above, except 
%   that a nonempty value of GENPOLY specifies the generator polynomial for the 
%   code. In this case, GENPOLY is a Galois row vector that lists the 
%   coefficients, in order of descending powers, of the generator polynomial. 
%   The generator polynomial must have degree N-K. To use the default narrow-
%   sense generator polynomial, set GENPOLY to [].
%   
%   DECODED = RSDEC(...,PARITYPOS)specifies whether the parity symbols in CODE 
%   were appended or prepended to the message in the coding operation. The string 
%   PARITYPOS can be either 'end' or 'beginning'. The default is 'end'. If 
%   PARITYPOS is 'beginning', then a decoding failure causes RSDEC to remove 
%   N-K symbols from the beginning rather than the end of the row.
%   
%   [DECODED,CNUMERR] = RSDEC(...) returns a column vector CNUMERR, each element
%   of which is the number of corrected errors in the corresponding row of CODE. 
%   A value of -1 in CNUMERR indicates a decoding failure in that row in CODE.
%   
%   [DECODED,CNUMERR,CCODE] = RSDEC(...) returns CCODE, the corrected version of
%   CODE. The Galois array CCODE is in the same format as CODE. If a decoding 
%   failure occurs in a certain row of CODE, then the corresponding row in CCODE
%   contains that row unchanged.
%
%   Example:
%      n=7; k=3;                          % Codeword and message word lengths
%      m=3;                               % Number of bits per symbol
%      msg  = gf([7 4 3;6 2 2;3 0 5],m)   % Three k-symbol message words
%      code = rsenc(msg,n,k);             % Two n-symbol codewords
%      % Add 1 error in the 1st word, 2 errors in the 2nd, 3 errors in the 3rd
%      errors = gf([3 0 0 0 0 0 0;4 5 0 0 0 0 0;6 7 7 0 0 0 0],m);
%      codeNoi = code + errors
%      [dec,cnumerr] = rsdec(codeNoi,n,k) % Decoding failure : cnumerr(3) is -1
%
%   See also RSENC, GF, RSGENPOLY.

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.6.4.5 $  $Date: 2004/04/12 23:01:19 $ 

% Initial checks
error(nargchk(3,5,nargin));

% Number of optional input arguments
nvarargin = nargin - 3;

% Fundamental checks on parameter data types
if ~isa(code,'gf')
   error('CODE must be a Galois array.');
end
if isempty(N) || ~isnumeric(N) || ~isscalar(N) || ~isreal(N) || N~=floor(N) || N<3
    error('N must be a real integer scalar equal to or larger than 3.');
end
if isempty(K) || ~isnumeric(K) || ~isscalar(K) || ~isreal(K) || K~=floor(K) || K<1
    error('K must be a real positive integer scalar.');
end

% Find fundamental parameters m and t
M = code.m;
t = (N-K)/2;
T2 = 2*t;       % number of parity symbols

[m_code, n_code] = size(code);

% Check mandatory parameters : code, N, K, t

% --- code
if isempty(code.x)
    error('CODE must be a nonempty Galois array.');
end;

if N > 65535,
    error('N must be between 3 and 65535.');
end

% --- width of code
if N ~= n_code
    error('CODE must be either a N-element row vector or a matrix with N columns.');
end

% --- code.m and its relationship with N
if M < 3
    error('Symbols in CODE must all have 3 or more bits.');
end
if N > 2^M-1
    error('N must not be greater than (2^CODE.m-1).');
end

% --- t
if floor(t)~=t || t<1,
    error('N and K must differ by a positive even integer.');
end

% Find out if shortened code is required
shortened = (2^M-1) - N;

% Value set indicators (used for the optional parameters)
genpolySet   = 0;
parityPosSet = 0;

% Set default values
genpoly   = rsgenpoly(N+shortened,K+shortened,code.prim_poly);
b         = 1;
parityPos = 'end';

% Placeholders for the numeric and string index values
objArg = [];
strArg = [];

% Set optional parameters
if ~isempty(varargin)
    
    % genpoly : Replace [] with the default value
    if isempty(varargin{1}) 
        if(~isnumeric(varargin{1}))
            error('The default generator polynomial should be marked by [].');
        end;
        varargin{1} = genpoly;
    end;
    
    % Identify string and gf object arguments
    for num=1:nvarargin,
        
        % Assign the gf object and string values
        if(isgfobject(varargin{num}))
            objArg(size(objArg,2)+1) = num;
        elseif(ischar(varargin{num}))
            strArg(size(strArg,2)+1) = num;
        else
            error('Only strings and Galois vectors are allowed as optional parameters.');
        end;
    end;
    
    % Build the gf object argument set
    switch(length(objArg))
    case 0
        % Only 1 optional string argument present.
    case 1
        if(objArg == [1])
            genpoly = varargin{objArg};
            genpolySet = 1;
        else
            error('Illegal syntax.  To specify GENPOLY, it must be provided as the third argument.')
        end;
        
    otherwise
        error(sprintf(['Illegal syntax.\n'...
              'No more than one Galois vector is allowed in the optional parameter list.']))
    end;
    
    % Build the string argument set
    for num=1:length(strArg)
        
        switch lower(varargin{strArg(num)})
        case {'end' 'beginning'}
            if(~parityPosSet)
                parityPosSet = 1;
                parityPos = lower(varargin{strArg(num)});
            else
                error('The parity position must only be set once.');
            end;
        otherwise
            error('Unknown option passed in.');
        end;
    end;

end

% Optional arguments have all been set, either to their defaults or 
% by the values passed in.
% Now perform range and type checks.

% --- genpoly : Find b and also check validity of genpoly
if genpolySet
    if ~isequal(code.prim_poly,genpoly.prim_poly)
        error('CODE and GENPOLY must be Galois arrays with the same prim_poly field.');
    end
    
    if ~isequal(M,genpoly.m)
        error('CODE and GENPOLY must be Galois arrays with the same m field.');
    end
    
    if ~isgfvector(genpoly)
        error('The generator polynomial must be a Galois row vector.');
    end    
           
    if ~isequal(length(genpoly),T2+1)
        error('The generator polynomial must be of degree (N-K).');
    end
    
    [b bEcode] = genpoly2b(genpoly(:)', genpoly.m, genpoly.prim_poly);
    if bEcode
        if isequal(bEcode,2)
            error('The generator polynomial must be monic.')
        else
            error(sprintf(['The generator polynomial must be the product\n'...
                  '(X+alpha^b)*(X+alpha^(b+1))*...*(X+alpha^(b+N-K-1)), where b is an integer.']))
        end
    end
end    

% All parameters are valid at this point, so no extra checking is required.

% Shortened RS code - insert zeros in CODE before decoding
if shortened > 0   
    if strcmp(parityPos,'end')
        % [ZEROS msg parity]
        code = [zeros(m_code, shortened) code];
    else
        % [parity ZEROS msg]
        code = [code(:,1:T2) zeros(m_code, shortened) code(:,T2+1:n_code)];
    end
end

% Pre-allocate memory
% Each element in this column vector holds the number of errors in the corresponding row
errorNumVec = zeros(m_code,1);

% Reed-Solomon Decoding
for j=1:m_code,
    
    % Call to core algorithm BERLEKAMP
    [code(j,:) errorNumVec(j)] = berlekamp(code(j,:),N+shortened,K+shortened,t,b,'rs');
    
end

% Extract message part from the 'corrected' codeword
switch parityPos
   case 'end'
      msg = code(:,1:K+shortened);    
   case 'beginning'
      msg = code(:,T2+1:N+shortened);    
end;

% Shortened RS code - remove inserted zeros from msg
if shortened > 0
    msg = msg(:,shortened+[1:K]);
    if strcmp(parityPos,'end')
        % [ZEROS msg parity]       
        code = code(:,shortened+[1:N]);
    else
        % [parity ZEROS msg]        
        code = code(:,[1:T2, (T2+shortened+1):N+shortened]);
    end
end

% Assign outputs
varargout{1} = msg;
varargout{2} = errorNumVec;
varargout{3} = code;


% ------------------ 
% Helper functions 
% ------------------ 

% --- ISGFOBJECT 
function ecode = isgfobject(my_object) 
if ~strcmp(class(my_object),'gf') 
    ecode = 0; 
else 
    ecode = 1; 
end 
return 
% -- end of rsdec --
