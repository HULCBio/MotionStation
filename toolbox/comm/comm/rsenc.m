function code = rsenc(msg, N, K, varargin)
%RSENC Reed-Solomon encoder.
%   CODE = RSENC(MSG,N,K) encodes the message in MSG using an (N,K) Reed-
%   Solomon encoder with the narrow-sense generator polynomial. MSG is a Galois 
%   array of symbols over GF(2^m). Each K-element row of MSG represents a 
%   message word, where the leftmost symbol is the most significant symbol. If N 
%   is smaller than 2^m-1, then RSENC uses a shortened Reed-Solomon code. Parity
%   symbols are at the end of each word in the output Galois array code. 
%   
%   CODE = RSENC(MSG,N,K,GENPOLY) is the same as the syntax above, except that a 
%   nonempty value of GENPOLY specifies the generator polynomial for the code. 
%   In this case, GENPOLY is a Galois row vector that lists the coefficients, in 
%   order of descending powers, of the generator polynomial. The generator 
%   polynomial must have degree N-K. To use the default narrow-sense generator 
%   polynomial, set GENPOLY to [].
%   
%   CODE = RSENC(...,PARITYPOS) specifies whether RSENC appends or prepends the 
%   parity symbols to the input message to form code. The string PARITYPOS can 
%   be either 'end' or 'beginning'. The default is 'end'.
%
%   Examples:
%      n=7; k=3;                        % Codeword and message word lengths
%      m=3;                             % Number of bits per symbol
%      msg  = gf([5 2 3; 0 1 7],m)      % Two k-symbol message words
%      code = rsenc(msg,n,k)            % Two n-symbol codewords
%
%      genpoly = rsgenpoly(n,k);        % Default generator polynomial
%      code2 = rsenc(msg,n,k,genpoly);  % code and code1 are the same codewords
%
%      nS = n-1;  kS = k-1;
%      msgS  = gf([5 2;0 1],m);
%      codeS = rsenc(msgS,nS,kS);       % Shortened (6,2) Reed-Solomon code
%  
%   See also RSDEC, GF, RSGENPOLY.

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.5.4.4 $  $Date: 2004/04/12 23:01:21 $ 

% Initial checks
error(nargchk(3,5,nargin));

% Number of optional input arguments
nvarargin = nargin - 3;

% Fundamental checks on parameter data types
if ~isgfobject(msg)
   error('MSG must be a Galois array.');
end
if isempty(N) || ~isnumeric(N) || ~isscalar(N) || ~isreal(N) || N~=floor(N) || N<3
    error('N must be a real integer scalar equal to or larger than 3.');
end
if isempty(K) || ~isnumeric(K) || ~isscalar(K) || ~isreal(K) || K~=floor(K) || K<1
    error('K must be a real positive integer scalar.');
end

% Find fundamental parameters m and t
M = msg.m;
t = (N-K)/2;
T2 = 2*t;       % number of parity symbols

[m_msg, n_msg] = size(msg);

% Check mandatory parameters : msg, N, K, t

% --- msg
if isempty(msg.x)
    error('MSG must be a nonempty Galois array.');
end;

if N > 65535,
    error('N must be between 3 and 65535.');
end

% --- width of msg
if K ~= n_msg
    error('MSG must be either a K-element row vector or a matrix with K columns.');
end

% --- msg.m and its relationship with N
if M < 3
    error('Symbols in MSG must all have 3 or more bits.');
end
if N > 2^M-1
    error('N must not be greater than (2^MSG.m-1).');
end

% --- t
if floor(t)~=t || t<1,
    error('N and K must differ by a positive even integer.');
end

% Find out if shortened code is required
shortened = (2^M-1) - N;

% Value set indicators (used for the optional parameters)
genpolySet   = 0;
parityposSet = 0;

% Set default values
genpoly   = rsgenpoly(N+shortened,K+shortened,msg.prim_poly);
paritypos = 'end';

% Place-holders for the numeric and string index values
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
            if(~parityposSet)
                parityposSet = 1;
                paritypos = lower(varargin{strArg(num)});
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

% --- genpoly
if genpolySet 
    if ~isequal(msg.prim_poly,genpoly.prim_poly)
        error('MSG and GENPOLY must be Galois arrays with the same prim_poly field.');
    end
    
    if ~isequal(M,genpoly.m)
        error('MSG and GENPOLY must be Galois arrays with the same m field.');
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

% Shortened RS code - append zeros to the front of input msg
if shortened > 0
    msgZ = [zeros(m_msg, shortened) msg];
else
    msgZ = msg;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         %
%        ENCODING         %
%                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Pre-allocate memory
% Each row is a 2t-long register for parity symbols for the same row of msg
parity = gf(zeros(m_msg,T2),M,msg.prim_poly);

% First element (Coeff of X^T2) not used in algorithm.  (Always monic)
genpoly = genpoly(2:T2+1);

% Encoding
% Each row gives the parity symbols for each message word
for j=1:size(msgZ,2),
    parity = [parity(:,2:T2) zeros(m_msg,1)] + (msgZ(:,j)+parity(:,1))*genpoly;
end

% Make codeword by appending / prepending parity to msg
switch paritypos
   case 'end'
      code = [msg parity];    
   case 'beginning'
      code = [parity msg];    
end;

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

% -- end of rsenc --
