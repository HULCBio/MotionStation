function G = qfilt2dfilt(Hq)
%QFILT2DFILT  Convert QFILT object to DFILT object
%   G = QFILT2DFILT(Hq) converts QFILT object Hq to DFILT object G.

%   Author(s): J. Schickler, Thomas A. Bryan
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.22 $  $Date: 2002/11/21 15:36:31 $ 

% If already a dfilt, then return.
if isa(Hq,'dfilt.dfilt'), G = Hq; return, end

% The only other thing we know how to translate is a qfilt, so if it isn't
% that, then error.
if ~isa(Hq,'qfilt'), error('Unrecognized filter type.'); end

fstruc = classname(Hq);
c = referencecoefficients(Hq);
s = scalevalues(Hq);
n = nsections(Hq);

if ~iscell(c{1}), c = {c}; end

% The only supported cascade for qfilts in sos.
if n > 1 && any(strcmpi(fstruc, {'df1','df1t','df2','df2t'})) && issos(Hq),
    G = feval(str2func(['dfilt.' fstruc 'sos']), cell2sos(c), s);
else
    G = createdfilt(c{1}, fstruc);
    
    if isempty(s), s = 1; end
    
    if s(1) ~= 1,
        G = [dfilt.scalar(s(1)), G];
    end
    
    for indx = 2:length(c),
        if indx < length(s) & s(indx) ~= 1,
            G = [G, dfilt.scalar(s(indx))];
        end
        G = [G, createdfilt(c{indx}, fstruc)];
    end
    
    if length(G) > 1,
        G = cascade(G);
    end
end

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
