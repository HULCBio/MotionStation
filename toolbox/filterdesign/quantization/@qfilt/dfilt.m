function Hd = dfilt(Hq)
%DFILT  Convert QFILT object to DFILT object
%   Hd = DFILT(Hq) converts QFILT object Hq to DFILT object Hd.
%
%   If the DFILT structure supports fixed-point, it will be converted and
%   the settings will be mapped.  If the settings cannot be mapped, the
%   DFILT's Arithmetic will be left in 'double'.

%   Author(s): J. Schickler, Thomas A. Bryan
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:25:05 $ 

fstruc = classname(Hq);
c = referencecoefficients(Hq);
s = scalevalues(Hq);
n = nsections(Hq);

if ~iscell(c{1}), c = {c}; end

% The only supported cascade for qfilts in sos.
if n > 1 && any(strcmpi(fstruc, {'df1','df1t','df2','df2t'})) && issos(Hq),
    Hd = feval(str2func(['dfilt.' fstruc 'sos']), cell2sos(c), s);
else
    Hd = createdfilt(c{1}, fstruc);
    
    if isempty(s), s = 1; end
    
    if s(1) ~= 1,
        Hd = [dfilt.scalar(s(1)), Hd];
    end
    
    for indx = 2:length(c),
        if indx < length(s) & s(indx) ~= 1,
            Hd = [Hd, dfilt.scalar(s(indx))];
        end
        Hd = [Hd, createdfilt(c{indx}, fstruc)];
    end
    
    % Cascade at the end to make sure that we end up with a single cascade
    % instead of a cascade of cascades.  Also gets in the correct order.
    if length(Hd) > 1,
        Hd = cascade(Hd);
    end
end

% Pass the filter to the "qfilt2dfilt" method of DFILT which maps the
% quantization settings.  This will be a no-op for most structures, since
% they aren't supported.
Hd.qfilt2dfilt(Hq);

% -------------------------------------------------------------------
function G = createdfilt(coeffs, fstruc)

switch fstruc
case {'df1','df1t','df2','df2t','latticearma','latticear','statespace'}
    G = feval(str2func(['dfilt.' fstruc]),coeffs{:});
case 'latticeca'
    % latticeca: c = {k1,k2,beta}
    G = dfilt.calattice(coeffs{:});
case 'latticecapc'
    % latticecapc: c = {k1,k2,beta}
    G = dfilt.calatticepc(coeffs{:});
case 'latcmax'
    % latcmax:     c = {k}
    G = dfilt.latticemamax(coeffs{:});
case 'latticema'
    % latticema:     c = {k}
    G = dfilt.latticemamin(coeffs{:});
case 'latcallpass'
    % latcallpass:     c = {k}
    G = dfilt.latticeallpass(coeffs{:});
case 'fir'
    % direct form FIR: c = {num}
    G = dfilt.dffir(coeffs{:});
case 'firt'
    % direct form transposed FIR: c = {num}
    G = dfilt.dffirt(coeffs{:});
case 'symmetricfir',
    % symmetric direct form FIR: c = {num}
    G = dfilt.dfsymfir(coeffs{:});
case 'antisymmetricfir'
    % antisymmetric direct form FIR: c = {num}
    G = dfilt.dfasymfir(coeffs{:});
otherwise
    error('Unrecognized filter structure.')
end

% [EOF]
