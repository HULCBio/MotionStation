function commblksqtimrec2(numSymb, sampPerSymb)
%COMMBLKSQTIMREC2 Mask function for the Squaring Timing Recovery block.
%
% The function checks for the validity of the block parameters.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/09 17:36:26 $

% Check parameters
if ( ~isscalar(numSymb) || floor(numSymb)~=numSymb || numSymb<1 )
	error(['The symbols per frame parameter must be an integer scalar ',...
            'greater than 0.']);
end

if ( ~isscalar(sampPerSymb) || floor(sampPerSymb)~=sampPerSymb || sampPerSymb<2 )
	error(['The samples per symbol parameter must be an integer scalar',...
           ' greater than 1.']);
end

if (sampPerSymb<4)
	warning('commblks:commtimrec2:sampPerSymbGrtEq4', ...
		'The samples per symbol parameter should be greater than or equal to 4.');
end

return;

% [EOF]
