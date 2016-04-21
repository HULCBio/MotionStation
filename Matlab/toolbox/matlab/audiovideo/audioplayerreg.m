function audioplayerreg(lockOrUnlock)
%AUDIOPLAYERREG
% Registers audioplayer objects with system.
%

%    Author(s): Brian Wherry 
%    Copyright 1984-2003 The MathWorks, Inc.
%    $Revision: 1.1.6.2 $  $Date: 2004/03/30 13:06:39 $ 

if ispc,
	winaudioplayer(lockOrUnlock);
else
	error('This function is only for use with 32 bit Windows machines.');
end