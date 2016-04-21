function [hh,Li,Mi,n0,n1,str] = dspblkupfirdn(action, varargin)
% DSPBLKUPFIRDN Mask dynamic dialog function for FIR rate conversion block


% Copyright 1995-2002 The MathWorks, Inc.
% $Date: 2002/04/14 21:00:09 $ $Revision: 1.11 $

if nargin==0,
    action = 'dynamic';   % mask callback
end

switch action
case 'dynamic'
    % Execute dynamic dialogs
        
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
    
    % Need to reshuffle the coefficients into phase order
    len = length(h);
    ncols = len / (Li*Mi);
    h = (reshape(h, Li*Mi, ncols)).';
    hh = [];
    for k=1:Mi
        hh = [h(:,(k-1)*Li+1:k*Li) hh];
    end
    % Scale gain for interpolation
    hh = hh * Li;
    
    if (Li == 1)
        str = ['x[' num2str(Mi) 'n]'];
    elseif (Mi == 1)
        str = ['x[n/' num2str(Li) ']'];
    else
        str = ['x[' num2str(Mi) 'n/' num2str(Li) ']'];
    end
        
otherwise
    error('unhandled case');
end

% end of dspblkupfirdn.m
