function msg = chkfreqtransf(w1,w2)
%CHKFREQTRANSF Check frequency transformations parameters.

%   Author(s): R. Losada
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/14 15:39:30 $

% Initialize error message
msg = '';

% Generate a single array of all values
w = [w1(:);w2(:)];

if any(w > 1) | any(w < 0),
	msg = 'Original and transformed frequency points must lie between 0 and 1.';
	return % Just in case we add further error checking later
end
