function seq = getsequence(se)
%GETSEQUENCE Extract sequence of decomposed structuring elements.
%   SEQ = GETSEQUENCE(SE), where SE is a structuring element array,
%   returns another structuring element array SEQ containing the
%   individual structuring elements that form the decomposition of SE.
%   SEQ is equivalent to SE, but the elements of SEQ have no
%   decomposition. 
%
%   Example
%   -------
%   STREL uses decomposition for square structuring elements larger than
%   3-by-3.  Use GETSEQUENCE to extract the decomposed structuring
%   elements: 
%
%       se = strel('square',5)
%       seq = getsequence(se)
%
%   Use IMDILATE with the 'full' option to see that dilating sequentially
%   with the decomposed structuring elements really does form a 5-by-5
%   square:
%
%       imdilate(1,seq,'full')
%
%   See also IMDILATE, IMERODE, STREL.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.4.4.1 $  $Date: 2003/01/26 05:57:30 $

% Testing notes
% se:          STREL array; individual elements may or may not be
%              decomposed.
%
% seq:         STREL array; individual elements may not be decomposed.
%              That is, length(sequence(seq(k))) must be 1.  seq
%              should be a column vector.

if length(se) > 1
    se = se(:);
    seq = getsequence(se(1));
    for k = 2:length(se)
        seq = [seq; getsequence(se(k))];
    end
elseif isempty(se)
    % A bit of a hack here to return a 1-by-0 strel array.
    seq = strel;
    seq(1) = [];
else
    if isempty(se.decomposition)
        seq = se;
    else
        seq = getsequence(se.decomposition(1));
        for k = 2:length(se.decomposition)
            seq = [seq; getsequence(se.decomposition(k))];
        end
    end
end
