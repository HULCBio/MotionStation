function [genPolyDec, numBits, iniStatesDec, numChecksums] = ...
    commblkcrcgen(genPoly, iniStates, numChecksums)
%COMMBLKCRCGEN Mask function for CRC generator and CRC
% syndrome detector blocks for parameter checking.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/04/12 23:02:51 $

% Check the Generator Polynomial parameter
if ~( isvector(genPoly) && ~isempty(genPoly) )
    error('The generator polynomial parameter must be a vector.');
end

if min(genPoly) < 0
    error('Invalid generator polynomial parameter values.');
elseif genPoly(end) == 0  % Positive powers case
    % Check for repeated values
    if length(unique(genPoly)) ~= length(genPoly) 
        error('Invalid generator polynomial parameter values.');
    end
    % Check for sorted descending order
    if any(fliplr(sort(genPoly))~=genPoly)
        error('Invalid generator polynomial parameter values.');
    end
    % Convert to binary vector representation
    len = max(genPoly)+1;
    tmp = zeros(1, len);
    tmp(len-genPoly) = 1;
    genPoly = tmp;
end

% Now, genPoly is a binary vector
if any(genPoly~=1 & genPoly~=0)
    error('The generator polynomial parameter must be a binary vector.');
end
if ((genPoly(1) == 0) | (genPoly(end) == 0))
    error('Invalid generator polynomial parameter values.');
end

% Check the Degree of polynomial
numBits = length(genPoly)-1;
if numBits > 32
    error('Only generator polynomials of degree 32 or less are allowed.');
end

% Convert to decimal value
if ( isscalar(genPoly) & (genPoly == 1) )
    genPolyDec = 0;     % numBits = 0
else 
    genPolyDec = bi2de(genPoly(2:end),'left-msb'); % without the leading implicit bit
end

% Check the Initial States parameter
if ~( isvector(iniStates) && ~isempty(iniStates) )
    error('The initial states parameter must be a scalar or a vector of size equal to the degree of the generator polynomial.');
end
if any(iniStates~=1 & iniStates~=0)
    error('The initial states parameter values must be binary.');
end
if length(iniStates) == 1 % scalar expansion
    iniStates = iniStates*ones(1,numBits);
elseif length(iniStates) ~= numBits
    error('The initial states parameter must be a scalar or a vector of size equal to the degree of the generator polynomial.');
end

% Convert to decimal value
if isempty(iniStates)
    iniStatesDec = 0;     % numBits = 0
else 
    iniStatesDec = bi2de(iniStates, 'left-msb');
end

% Check the number of Checksums parameter
if ( isempty(numChecksums) | ~isreal(numChecksums) | isinf(numChecksums) | ...
    (numChecksums <= 0) | (floor(numChecksums) ~= numChecksums) | ...
    ~isscalar(numChecksums) )
    error('The checksums per frame parameter must be an integer scalar greater than 0.');
end

% [EOF]
