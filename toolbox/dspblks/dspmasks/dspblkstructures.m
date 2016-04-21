function s = dspblksstructures(filtobj)
%DSPBLKSSTRUCTURES Returns the structures supported by the Digital Filter Block.
%   DSPBLKSSTRUCTURES(FILTOBJ) Returns the structures support by the
%   Digital Filter block for the architecture (fixed vs. float) of FILTOBJ.

%   Author(s): J. Schickler
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/12/06 15:25:39 $

if isa(filtobj, 'qfilt'),
    arith = 'qfilt';
else
    try,
        arith = get(filtobj, 'Arithmetic');
    catch
        arith = 'double';
    end
end

switch lower(arith)
    case {'double', 'single'}
        s = {'Direct-Form I', 'Direct-Form II', 'Direct-Form I Transposed', ...
            'Direct-Form II Transposed, SOS', 'Direct-Form II Transposed', ...
            'Direct-Form FIR', 'Direct-Form FIR Transposed', ...
            'Lattice Autoregressive (AR)', 'Lattice Moving-Average Minimum Phase'};
    case {'fixed', 'custom', 'qfilt'}
        s = {'Direct-Form I', 'Direct-Form II', 'Direct-Form I Transposed', 'Direct-Form II Transposed' ...
             'Direct-Form FIR', 'Direct-Form FIR Transposed', 'Direct-Form II Transposed, SOS'};
    case 'float'
        error(generatemsgid('UnsupportedArithmetic'), ...
            'The Signal Processing Blockset does not support arbitrary floating point arithmetic.')
    otherwise
        error(generatemsgid('UnknownArithmetic'), ...
            'The Signal Processing Blockset does not recognize the ''%s'' arithmetic', arith);
end

% [EOF]
