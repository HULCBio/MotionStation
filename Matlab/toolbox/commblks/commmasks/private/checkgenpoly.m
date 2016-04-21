function [genPoly, eStr] = checkgenpoly(genPoly, eStr)
%CHECKGENPOLY  Checks for valid generator polynomial input and converts
%   if needed to a binary vector representation.
%
%   Should be a binary vector with leading and trailing ones or a vector
%   ending with 0 and indicating positive powers. 

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/12 23:03:09 $

emsg  = 'Invalid generator polynomial parameter values.';

% Check the polynomial parameter values - numeric vector only
if ~( isvector(genPoly) && ~isempty(genPoly) && ~isscalar(genPoly) )
    eStr.emsg  = emsg; eStr.ecode = 1; return;
end

if min(genPoly) < 0
    eStr.emsg  = emsg; eStr.ecode = 1; return;
elseif genPoly(end) == 0  % Positive powers case
    % Check for repeated values
    if length(unique(genPoly)) ~= length(genPoly) 
        eStr.emsg  = emsg; eStr.ecode = 1; return;
    end
    % Check for sorted descending order
    if any(fliplr(sort(genPoly))~=genPoly)
        eStr.emsg  = emsg; eStr.ecode = 1; return;
    end
    % Convert to binary vector representation
    len = max(genPoly)+1;
    tmp = zeros(1, len);
    tmp(len-genPoly) = 1;
    genPoly = tmp;
end

% Now genPoly is in the binary vector representation
% Should have leading and trailing ones
if ((genPoly(1) == 0) | (genPoly(end) == 0)),
    eStr.emsg  = emsg; eStr.ecode = 1; return;
end

% Only 1's and 0's allowed
if any(genPoly~=1 & genPoly~=0)
    eStr.emsg  = emsg; eStr.ecode = 1; return;
end

% [EOF]
