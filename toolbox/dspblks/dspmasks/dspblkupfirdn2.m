function varargout = dspblkupfirdn2(action, varargin)
% DSPBLKUPFIRDN Mask dynamic dialog function for FIR rate conversion block

% Copyright 1995-2003 The MathWorks, Inc.
% $Date: 2004/04/12 23:07:34 $ $Revision: 1.2.4.3 $

if nargin==0, action = 'dynamic'; end
blk = gcbh;   % Cache handle to block

switch action
case 'setup'
    % Input arguments for setup case:
    % dspblkupfirdn('setup', h,L,M)
    
    h = varargin{1};        
    [M,N] = size(h);
    if (M ~= 1 & N ~= 1)
        error('The filter coefficients must be a non-empty vector');
    end
    L = varargin{2};
    if isempty(L) | (L < 1) | (fix(L) ~= L)
        error('Interpolation factor must be a positive integer');
    end
    M = varargin{3};
    if isempty(M) | (M < 1) | (fix(M) ~= M)
        error('Decimation factor must be a positive integer');
    end
    
    [g,a,b]=gcd(L,M); Li=L/g; Mi=M/g;
    while a>0  % This should happen in at most one step.
        a=a-Mi;  
        b=b+Li;
    end
    
    % n0 and n1 are constructed such that -n0*Li + n1*Mi = 1
    n0=abs(a);  % a must now be negative or zero, as desired
    n1=b;       % b must now be positive
    
    if (g > 1),
        msg = sprintf(['Integer conversion factors are \nnot ' ...
                'relatively prime.\n' ...
                'Converting ratio %d/%d to %d/%d.'], ...
            L,M,Li,Mi);
        warning(msg);
    end
    
    % Might need to zero-pad the filter coeffs
    len = length(h);
    if (rem(len, Li*Mi) ~= 0)
        nzeros = Li*Mi - rem(len, Li*Mi);
        h = [h(:); zeros(nzeros,1)];
    end
    
    % Filter coefficients are arranged into Li interpolation groups.  
    % Each interpolation group contains Mi decimation polyphase subfilters; 
    % the order of these Mi decimation subfilters is ncols. 
    % There is a total of Li*Mi polyphase filters.
    % At every input sample, all of the Li interpolation filters are executed
    % while only 1 of the Mi decimation sub-filters in each interpolation group
    % is executed.
    % The filter memory bank is arranged as follows:
    % 1. All coeffs from any of one of the Li*Mi subfilters belong to the same column
    % 2. There are Mi groups of columns.
    % 3. Each of the above Mi groups of columns contains Li columns.
    % Using these memory arrangements, the coef pointer in the C code is incremented
    % once with each input sample and resets itself when all the polyphase subfilters 
    % are executed.
    len = length(h);
    ncols = len / (Li*Mi);
    h = (reshape(h, Li*Mi, ncols)).';   % implements rule 1
    hh = [];

    for k=1:Mi                          % implements rules 2 and 3
        hh = [h(:,(k-1)*Li+1:k*Li) hh];
    end
    
    % used for drawing icon
    if (Li == 1)
        str = ['x[' num2str(Mi) 'n]'];
    elseif (Mi == 1)
        str = ['x[n/' num2str(Li) ']'];
    else
        str = ['x[' num2str(Mi) 'n/' num2str(Li) ']'];
    end
    
    % Gather up outputs
    varargout = {hh,Li,Mi,n0,n1,str};
        
otherwise
    error('unhandled case');
end

% end of dspblkupfirdn2.m
