function constellation = squareqamconst(M, varargin)
% SQUAREQAMCONST Return an ordered square QAM constellation
% CONSTELLATION = SQUAREQAMCONST(M) returns the square QAM constellation
% for each value of M. 
%
% CONSTELLATION = SQUAREQAMCONST(M, INI_PHASE) returns the square QAM constellation,
% rotated by INI_PHASE (rad).

%    Copyright 1996-2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2003/02/14 20:51:04 $ 

if(nargin>2)
    error('Too many inputs.');
end

% check M
if( ~isnumeric(M) || ceil(log2(M)) ~= log2(M) || log2(M) < 0 )
    error('comm:sqaureQAMConst:Mpower','M must be in the form of M = 2^K, where K is a non-negative integer. ');
end

if(nargin == 1 || isempty(varargin{1}) )
    ini_phase = 0;
else
    ini_phase = varargin{1};
    if( ~isnumeric(ini_phase) || ~isscalar(ini_phase) || ~isreal(ini_phase) )
        error('comm:sqaureQAMConst:INI_PHASE','INI_PHASE must be a real scalar');
    end
end

%trivial case, M = 2;
if(log2(M) ==1)
    constellation = [-1 1];
    constellation = constellation.*exp(j*ini_phase);
    return
end 

if( log2(M)/2 ~= floor(log2(M)/2) && log2(M) >3)
    % Cross constellation The following algorithm for the cross
    % constellation was converted to M from the C S-function scomapskmod.c
    % Compute log2(M) for bit input 
    nbits  = log2(M);
    constellation = zeros(1,M);	
    nIbits = (nbits + 1) / 2;
    nQbits = (nbits - 1) / 2;
    mI = 2^nIbits;
    mQ = 2^nQbits;
    for(i = 0:M-1)
        I_data  = fix(i/2^nQbits);
        Q_data = bitand( i, fix(((M-1)/(2^nIbits))));
        cplx_data = (2 * I_data + 1 - mI) + j*(-1 * (2 * Q_data + 1 - mQ));
        %if(M>8)
            I_mag = abs(floor(real(cplx_data)));
            if(I_mag > 3 * (mI / 4))
                Q_mag = abs(floor(imag(cplx_data)));
                I_sgn = sign(real(cplx_data));
                Q_sgn = sign(imag(cplx_data));
                if(Q_mag > mQ/2)
                    cplx_data = I_sgn*(I_mag - mI/2) + j*( Q_sgn*(2*mQ - Q_mag));
                else
                    cplx_data = I_sgn*(mI - I_mag) + j*(Q_sgn*(mQ + Q_mag));
                end 
            end 
            
            %end
        constellation(i+1) =  real(cplx_data) + j*imag(cplx_data);
    end 
    
else % Regular square QAM
    
    % Get the QAM points, for 1 quadrant, expand to all 4 quadrants.
    Const = idealQAMConst(M);
    newConst = [Const; conj(Const); -Const; -conj(Const) ];
    
    % sort 
    constellation = zeros(1,M);
    for k = 1:M
        % find the elements with the smallest real component
        ind1 = find(real(newConst) == min(real(newConst)));
        % of those, find the element with the largest imaginary component
        tmpArray = -j*inf * ones(size(newConst));
        tmpArray(ind1) = newConst(ind1);
        ind2 = find(imag(tmpArray) == max(imag(tmpArray)));
        
        constellation(k)= newConst(ind2);
        %get rid of the old point
        newConst(ind2) = [];
    end
end

% rotate the constellation by the phase rotation.
constellation = constellation.*exp(j*ini_phase);

%EOF
