function globallog = getgloballog( dolog );
%GETGLOBALLOG is for internal use only by the Fixed Point Blockset

%
%  Check global logging selection
%

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.7 $  
% $Date: 2002/04/10 18:59:43 $

global FixLogPref
	
if length(FixLogPref) == 1
	
	globallog = FixLogPref;
		
else

    % no global log 
    % so use local setting
    globallog = 0;	
	
end
