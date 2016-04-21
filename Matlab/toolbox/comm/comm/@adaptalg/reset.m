function reset(alg)
%RESET  Reset adaptive algorithm object.
%  RESET(ALG) resets the adaptive algorithm object ALG, initializing all
%  states.  
%  
%   See also LMS, SIGNLMS, NORMLMS, VARLMS, RLS, CMA, DFE, EQUALIZE,
%   EQUALIZER/RESET.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/09 17:34:25 $

msg = sprintf([...
    'To reset an adaptive algorithm object ALG, use RESET(ALG), \n',...
    'where ALG is an adaptive algorithm object.\n', ...
    'For more information, type ''help adaptalg/reset'' in MATLAB.']);
error(msg)