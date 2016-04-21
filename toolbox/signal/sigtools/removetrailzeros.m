function coeffs = removetrailzeros(coeffs)
%REMOVETRAILZEROS  Remove trailing zeros.
%   C = REMOVETRAILZEROS(C) removes all trailing zeros from vector C.
%   If C is all zeros, then it returns C equal to a single zero. If
%   C is empty, it returns empty.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:50:54 $ 

if isempty(coeffs),
	return
end

indx = max(find(coeffs ~= 0));

if isempty(indx),
	coeffs = 0;
else
	coeffs = coeffs(1:indx);
end

