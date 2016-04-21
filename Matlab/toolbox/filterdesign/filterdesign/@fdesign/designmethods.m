%DESIGNMETHODS   Returns the available design methods for design object.
%   D = DESIGNMETHODS(Hs) returns the available design methods for the
%   filter design object Hs and its current 'SpecificationType'. 
%
%   % EXAMPLE: Construct a lowpass object and check its design methods.
%   hs = fdesign.lowpass('N,Fc',10,12000,48000)
%   d1 = designmethods(hs)
%   hs.SpecificationType = 'Fp,Fst,Ap,Ast';
%   d2 = designmethods(hs)
%
%   See also FDESIGN/SETSPECS, FDESIGN/LOWPASS, FDESIGN/BUTTER.


%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:17:19 $



% [EOF]
