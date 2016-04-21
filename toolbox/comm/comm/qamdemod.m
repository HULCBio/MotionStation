function z =  qamdemod(y,M,varargin)
% QAMDEMOD Quadrature amplitude demodulation.
%   Z = QAMDEMOD(Y,M) demodulates the complex envelope Y of a quadrature
%   amplitude modulated signal. M is the alphabet size and must be an
%   integer power of two. The constellation is a rectangular
%   constellation. For two-dimensional signals, the function treats each
%   column as 1 channel.
%
%   Z = QAMDEMOD(Y,M,INI_PHASE) specifies the initial phase (rad) of
%   the modulated signal.
% 
%   See also QAMMOD, GENQAMDEMOD, GENQAMMOD, PAMMOD, PAMDEMOD, MODNORM.

%    Copyright 1996-2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.2 $  $Date: 2003/12/01 18:58:00 $ 

% error checks
if(nargin>3)
    error('comm:qamdemod:numarg','Too many input arguments.');
end

%Check y, Fs, ini_phase
if( ~isnumeric(y))
    error('comm:qamdemod:Ynum','Y must be numeric.');
end

if(~isreal(M) || ~isscalar(M) || M<=0 || (ceil(M)~=M) || ~isnumeric(M) )
    error('comm:qamdemod:Mreal','M must be a positive integer.');
end

if( ~isnumeric(M) || ceil(log2(M)) ~= log2(M))
    error('comm:qamdemod:Mpow2','M must be in the form of M = 2^K, where K is an integer. ');
end
if(nargin==2 || isempty(varargin{1}) )    
    ini_phase = 0;
else
    ini_phase = varargin{1};
    if(~isreal(ini_phase) || ~isscalar(ini_phase)|| ~isnumeric(ini_phase) )
        error('comm:pamdemod:ini_phaseReal','INI_PHASE must be a real scalar.');    
    end
end

const = squareqamconst(M,ini_phase);
z = genqamdemod(y,const);

% EOF