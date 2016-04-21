function audiorecorderreg(lockOrUnlock)
%AUDIOPLAYERREG
% Registers audiorecorder objects with system.
%

%    Author(s): Brian Wherry 
%    Copyright 1984-2003 The MathWorks, Inc.
%    $Revision: 1.1.6.2 $  $Date: 2004/03/30 13:06:40 $ 

if ispc,
	winaudiorecorder(lockOrUnlock);
else
	error('This function is only for use with 32 bit Windows machines.');
end
