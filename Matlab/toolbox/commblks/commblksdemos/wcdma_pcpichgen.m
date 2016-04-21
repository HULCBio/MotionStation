function wcdma_pcpichgen(antenna, st)
% WCDMA_PCPICHGEN Sets up workspace variables for the Wcdma
% PCPICH block included in the Wcdma application examples.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.2 $  $Date: 2002/04/11 00:49:00 $

% Check Sampling Time  
if  ~isnumeric(st) | isempty(st),
    
    errordlg(['Invalid Sampling Time specified. Sampling Time must be a nonempty ' ...
	  ' positive real number.']);
end

% Check Antenna 
if antenna == 2,
    errordlg(['Transmit Diversity is not currently supported. ' ...
            ' Antenna 2 in P-CPICH Generator can not be selected.']);
end    



