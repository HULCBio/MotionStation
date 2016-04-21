function s = scalevalues(Hq)
%SCALEVALUES  The ScaleValues property of QFILT.
%   S = SCALEVALUES(Hq) returns the scale values of the quantized filter
%   object Hq.  They scale the input to each section of the filter.  The
%   value of the ScaleValues property must be a scalar, or a vector of
%   length NumberOfSections(Hq).  For efficient computation, it is
%   recommended that the scale values be powers of 2.  If S is a scalar,
%   then the input to the first section of the quantized filter is
%   scaled by S.  If S is a vector, then the input to the ith section of
%   the filter is scaled by S(i).
%
%   Example:
%     Hq = qfilt;
%     scalevalues(Hq)
%
%   See also QFILT, QFILT/GET, QFILT/SET.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/14 15:30:01 $

s = Hq.scalevalues;
