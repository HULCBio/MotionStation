function varargout = dspblkupfir2(action,varargin)
% DSPBLKUPFIR Mask dynamic dialog function for FIR interpolation block

% Copyright 1995-2003 The MathWorks, Inc.
% $Date: 2004/04/12 23:07:33 $ $Revision: 1.10.6.3 $
if nargin==0, action = 'dynamic'; end
blk = gcbh;   % Cache handle to block

switch action
case 'setup'
    % Input arguments for setup case:
    % dspblkupfir('setup', h,L,framing)
    
    h = varargin{1};
    L = varargin{2};
    outputBufInitCond = varargin{3};

    [M,N] = size(h);
    if (M ~= 1 && N ~= 1)
        error('The filter coefficients must be a non-empty vector');
    end
    if (isempty(L) || L < 1 || fix(L) ~= L)
        error('Interpolation factor must be a real, scalar integer value > 0');
    end

    if(~isempty(h) && ~isempty(L))

        % Need to reshuffle the coefficients into phase order
        len = length(h);
        if (rem(len, L) ~= 0)
            nzeros = L - rem(len, L);
            h = [h(:); zeros(nzeros,1)];
        end
        len = length(h);
        nrows = len / L;
        % Re-arrange the coefficient 
        h = reshape(h, L, nrows).';
        
        %Scale the initial conditions by 1/L
        %This is put in to maintain backward compatibility
        outputBufInitCond = outputBufInitCond ./L;
    end    
    
    varargout = {h,outputBufInitCond};
    
otherwise
    error('unhandled case');
end

% end of dspblkupfir.m
