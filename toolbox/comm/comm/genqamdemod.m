function z = genqamdemod(y,const)
% GENQAMDEMOD General quadrature amplitude demodulation.
%   Z = GENQAMDEMOD(Y,CONST) demodulates the complex envelope Y of a
%   quadrature amplitude modulated signal. CONST is a one dimensional
%   vector that specifies the signal mapping. For two-dimensional signals,
%   the function treats each column as 1 channel.
%
%   See also GENQAMMOD, QAMMOD, QAMDEMOD, PAMMOD, PAMDEMOD.

%    Copyright 1996-2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2003/02/14 20:50:29 $ 


% error checks
if(nargin>2)
    error('comm:genqamdemod:numarg','Too many input arguments.');
end

if( ~isnumeric(y))
    error('comm:genqamdemod:Ynum','Y must be numeric.');
end

% check that const is a 1-D vector
if(~isvector(const) || ~isnumeric(const) )
    error('comm:genqamdemod:const1D','CONST must be a one dimensional vector.');
end

% --- Assure that Y, if one dimensional, has the correct orientation --- %
wid = size(y,1);
if(wid ==1)
    y = y(:);
end

z = zeros(size(y));
for(i = 1:size(y,1) ) 
    for(j = 1:size(y,2) )
        %compute the minumum distance for each symbol
        [tmp, idx] = min(abs(y(i,j) - const));
        z(i,j) = idx-1;
    end
end

% --- restore the output signal to the original orientation --- %
if(wid == 1)
    z = z';
end

