function deintrlved = algdeintrlv(data, num, type, varargin)
%ALGDEINTRLV Restore ordering of symbols permuted using an algebraically derived permutation table.
%   DEINTRLVED = ALGDEINTRLV(DATA, NUM, 'takeshita-costello', K, H)
%   restores the original ordering of the elements in DATA using the
%   inverse of a permutation table that is algebraically derived using the
%   Takeshita-Costello method. The number of elements, NUM, must be a power
%   of 2. The multiplicative factor, K, must be an odd integer less than
%   NUM, and the cyclic shift, H, must be a nonnegative integer less than
%   NUM.
%
%   DEINTRLVED = ALGDEINTRLV(DATA, NUM, 'welch-costas', ALPHA) uses the
%   Welch-Costas method. NUM must be chosen such that NUM+1 is prime, and
%   the primitive element, ALPHA, is an integer, A, between 1 and NUM that
%   represents a primitive element of the finite field GF(NUM+1). 
%
%   See also ALGINTRLV.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2004/04/12 23:00:19 $

% --- Initial Checks for input arguments
if isempty(data)
    error('comm:algdeintrlv:DataIsEmpty','DATA cannot be empty.')
end

error(nargchk(4,5,nargin))              % Checks number of input arguments

% --- Initialize and check parameters for Takeshita-Costello method
if(strcmpi(type,'Takeshita-Costello'))
    if (nargin < 5)
        error('comm:algdeintrlv:CostelloTooManyInp','Not enough input arguments.')
    end
    k = varargin{1};                    % Obtain Multiplicative factor 
    h = varargin{2};                    % Obtain Cyclic shift 
end

% --- Initialize and check parameters for Welch-Costas
if(strcmpi(type,'Welch-Costas'))
    if (nargin > 4)
        error('comm:algdeintrlv:WelchTooManyInp','Too many input arguments.')
    end
    alpha  = varargin{1};               % Obtain Primitive element
end

% --- Checks if NUM is an integer
if(num ~= round(num))
    error('comm:algdeintrlv:ElemIsNotAnInt','Number of elements must be an integer.');
end

% --- Computes new indices for DATA based on Takeshita-Costello algorithm
if(strcmpi(type,'Takeshita-Costello'))
    if(num ~= 2.0^round(log(num)/log(2)))
        error('comm:algdeintrlv:NumIsNotAPowerOfTwo','Number of elements must be a power of 2.');
    end 
    
    if(mod(k,2) == 0)
        error('comm:algdeintrlv:KIsNotOdd','Multiplicative factor must be an odd integer.');     
    end
    
    if (k < 0)
        error('comm:algdeintrlv:KIsNotAPositiveInt','Multiplicative factor must be greater than zero.'); 
    end
    
    if(h ~= round(h))  
        error('comm:algdeintrlv:HIsNotAnInt','Cyclic shift must be an integer.');
    end
    
    if(h < 0)
        error('comm:algdeintrlv:HIsNotAPositiveInt','Cyclic shift must be greater than or equal to zero.');
    end
    
    if(h >= num)
        error('comm:algdeintrlv:HIsGtrThanNum','Cyclic shift must be less than Number of elements.');     
    end
    
    m = 0:num-1;
    c = rem((k*m.*(m+1)/2),num)+1;
    d = [c(2:end) c(1)];
    [u,v] = sort(c);
    int_table = d(v);
    
    if(h > 0)
        int_table = [int_table(h+1:end) int_table(1:h)];   % New indices based on Takeshita-Costello method
    end
    
    % --- Computes new indices for DATA based on Welch-Costas algorithm       
elseif(strcmpi(type,'Welch-Costas'))
    if ~isprime(num + 1)                % Checks if number of elements plus one is a prime number
        error('comm:algdeintrlv:NumPlusOneIsNotPrime','Number of elements plus one must be prime.');
    end
    
    if alpha >= num                     % Checks if the primitive element is less than number of elements
        error('comm:algdeintrlv:AlphaIsGtrThanNum','Primitive element must be less than Number of elements.');
    end       
    pf = factor(num);
    z = alpha*ones(size(pf)); 
    for n = 2:pf(end)
        z(n<=pf) = mod(z(n<=pf)*alpha,num+1);
    end
    
    % --- Checks if the primitive element is valid
    for m = 1:2^length(pf)-2,
        sel = de2bi(m,length(pf));
        xpf = pf.*sel;
        xpf(xpf==0) = 1;
        xpp = prod(xpf);
        [mx, lx] = max(xpf);
        prd = 1;
        for n=1:xpp/mx
            prd = mod(prd*z(lx),num+1);
        end
        if prd == 1
            error('comm:algdeintrlv:InvalidAlpha','Specified value is not a primitive element.');
        end
    end
    
    y = zeros(1,num);
    y(1) = 1; 
    for i = 2:num, 
        y(i) = mod(y(i-1)*alpha,num+1);
    end       
    int_table = y;                      % New indices based on Welch-Costas method
else                                    % Returns an error if the type is invalid
    error('comm:algdeintrlv:InvalidType','TYPE must be either ''takeshita-costello'' or ''welch-costas''');
end

% --- Rearrange sequence of symbols   
deintrlved = deintrlv(data,int_table');

% -- end of algdeintrlv ---

    