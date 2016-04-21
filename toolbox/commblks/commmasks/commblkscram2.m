function [M, poly, ini_sta] = commblkscram2(M, poly, ini_sta)
%COMMBLKSCRAM2 Helper function for the Scrambler-Descrambler blocks.
%
% The function checks for the validity of the inputs.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2003/12/01 18:59:37 $

% Check the initial state parameter
if ~( isvector(ini_sta) && ~isempty(ini_sta) )
    error(['The initial states must be a scalar or a vector of length',...
            ' equal to the order of the scramble polynomial.']);
end
if ( max(ini_sta)>=M || min(ini_sta)<0 )
    error(['The initial state values must be in the range ',...
           '[0, Calculation base-1].']);
end

% Check the polynomial parameter values
if ~( isvector(poly) && ~isempty(poly) )
    error('Invalid scramble polynomial parameter values.');
end
if max(poly)>=2
    error('Invalid scramble polynomial parameter values.');
elseif min(poly)<0
    if any(poly==1)
        error('Invalid scramble polynomial parameter values.');
    end
    tmp = zeros(1, abs(min(poly))+1);
    for i = 1:length(poly), tmp(abs(poly(i))+1) = 1; end
    poly = tmp;
end
% Now poly is in the binary vector representation 
if ((poly(1) == 0) || (poly(end) == 0)),
    error('Invalid scramble polynomial parameter values.');
end

s = length(poly)-1;
if ~( (length(ini_sta) == s) || (length(ini_sta) == 1) )
    error(['The initial states must be a scalar or a vector of length',...
            ' equal to the order of the scramble polynomial.']);
end

return

% [EOF]
