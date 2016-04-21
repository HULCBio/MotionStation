function [symbolEst, symbolDet, symbolErr] = ...
         equalize(eqobj, inputSig, varargin);
%EQUALIZE   Equalize a signal using an equalizer object.
%   Y = EQUALIZE(EQOBJ, X) processes the baseband signal vector X with
%   equalizer object EQOBJ, and outputs the equalized signal vector Y.  You
%   can construct EQOBJ using either LINEAREQ or DFE.  The signal X is
%   assumed to be sampled at NSAMP samples per symbol, where NSAMP
%   corresponds to the nSampPerSym property of EQOBJ.  The equalizer adapts
%   in decision-directed mode using a detector specified by the signal
%   constellation property in EQOBJ.   
%
%   Y = EQUALIZE(EQOBJ, X, TRAINSIG) uses a training sequence initially to
%   adapt the equalizer. After processing the training sequence, the
%   equalizer adapts in decision-directed mode.  
%
%   [Y, YD] = EQUALIZE(...) returns the vector YD of detected data symbols.
%
%   [Y, YD, E] = EQUALIZE(...) returns the vector E of errors between Y and
%   the reference signal (i.e., training sequence or detected symbols).
%
%   See also LMS, SIGNLMS, NORMLMS, VARLMS, RLS, CMA, LINEAREQ, DFE.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/01/26 23:19:25 $

% 'equalize' is a method associated with equalizer objects (classes
% equalize.lineareq and equalizer.dfe).  For source code, see
% @equalizer/@baseclass/equalize.m (for most error checking) and 
% @equalizer/@lineareq/thisequalize.m (for equalizer operation).

msg = sprintf(['To equalize a signal X, use Y=EQUALIZE(EQOBJ, X) ',...
        'where EQOBJ is an equalizer object.\n', ...
        'For more information, type ''help equalize'' in MATLAB']);
error(msg)
