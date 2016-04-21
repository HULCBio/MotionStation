function Gain = getloopgain(LoopData)
%GETLOOPGAIN  Gets the loop gain value.
%
%   Returns value GAIN such that GAIN * LoopData.getopenloop
%   is the current open-loop model.

%   Author(s): P. Gahinet
%   Copyright 1986-2001 The MathWorks, Inc. 
%   $Revision: 1.6 $ $Date: 2001/09/28 21:31:11 $

% Loop gain defined as the compensator gain in its current format
Gain = LoopData.Compensator.getgain('mag');
