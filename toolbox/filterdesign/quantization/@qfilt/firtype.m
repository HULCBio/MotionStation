function filtertype = firtype(Hq)
%FIRTYPE  Determine the type (1-4) of a linear phase FIR filter.
%   T = FIRTYPE(F) determines the type (1 through 4) of an FIR filter
%   object F.  The filter must be real and have linear phase.
%
%   Type 1 through 4 are defines as follows:
%      
%     - Type 1: Even order symmetric coefficients.
%     - Type 2: Odd order symmetric coefficients.
%     - Type 3: Even order antisymmetric coefficients.
%     - Type 4: Odd order antisymmetric coefficients.
%
%   If F has multiple sections, all sections must be real FIR filters with
%   linear phase.  For this case, T is a cell array containing the type
%   of each section.
%
%   See also QFILT/ISFIR, QFILT/ISLINPHASE.

%   Author(s): R. Losada
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/05/04 04:17:07 $ 

error(nargchk(1,2,nargin));

if ~isfir(Hq),
    error('The filter must be FIR.');
end

if ~islinphase(Hq),
    error('All sections of the filter must have linear phase.');
end

if ~isreal(Hq),
    error('The filter must have real coefficients.');
end

% Create a dfilt so we use its method
H = qfilt2dfilt(Hq);
if isa(H,'dfilt.cascade')
    
    for i = 1:nsections(H)
        filtertype{i} = firtype(H.Section(i));
    end
else
    filtertype = firtype(H);
end


	