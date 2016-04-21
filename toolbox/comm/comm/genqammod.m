function y = genqammod(x,const)
%GENQAMMOD General quadrature amplitude modulation
%   Y = GENQAMMOD(X,CONST) outputs the complex envelope of the modulation
%   of the message signal X using quadrature amplitude modulation.  The
%   message signal must consist of integers between 0 and 1 less than the
%   length of CONST. CONST is a one dimensional vector that specifies the
%   signal mapping. For two-dimensional signals, the function treats each
%   column as 1 channel.
%
%   See also GENQAMDEMOD, QAMMOD, QAMDEMOD, PAMMOD, PAMDEMOD.

%    Copyright 1996-2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.2 $  $Date: 2003/07/30 02:47:33 $ 

%Check x,Nsamp, const.
if ( ~isreal(x) || any(any(ceil(x)~=x)) || ~isnumeric(x) ) 
    error('comm:genqammod:Xreal','Elements of input X must be integers in [0, M-1].');
end

%Determine the size of M
M = max(size(const));

% check that X are all integers within range.
if (min(min(x)) < 0)  || (max(max(x)) > (M-1))
    error('comm:genqammod:Xreal','Elements of input X must be integers in [0, M-1].');
end

% check that const is a 1-D vector
if(~isvector(const) || ~isnumeric(const) )
    error('comm:genqammod:const1d','CONST must be a one dimensional vector.');
end

% --- Assure that X, if one dimensional, has the correct orientation --- %
wid = size(x,1);
if(wid ==1)
    x = x(:);
end

% --- constellation needs to have the same orientation as the input -- %
if(size(const,1) ~= size(x,1) )
    const = const(:);
end

% map
y = const(x+1);

% ensure output is a complex data type
y = complex(real(y), imag(y));

% --- restore the output signal to the original orientation --- %
if(wid == 1)
    y = y.';
end

% --- EOF --- %
