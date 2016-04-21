function str = getconstructorfromstructure(struct, reffilt);
%GETCONSTRUCTORFROMSTRUCTURE

%   Author(s): J. Schickler 
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/04/13 00:31:54 $ 

if nargin < 2, reffilt = []; end

str = [];

if isempty(struct), return; end

indx = findstr(lower(struct), ', sos');
if ~isempty(indx), struct(indx:end) = []; end
        
switch struct,
    case 'Direct-Form I',                 str = 'df1';
    case 'Direct-Form II',                str = 'df2';
    case 'Direct-Form I Transposed',      str = 'df1t';
    case 'Direct-Form II Transposed',     str = 'df2t';
    case 'Direct-Form FIR',               str = 'dffir';
    case 'Direct-Form FIR Transposed',    str = 'dffirt';
    case 'Direct-Form Symmetric FIR',     str = 'dfsymfir';
    case 'Direct-Form Antisymmetric FIR', str = 'dfasymfir';
    case 'Lattice Allpass',               str = 'latticeallpass';
    case 'Lattice Moving-Average Minimum Phase', str = 'latticemamin';
    case 'Lattice Moving-Average Maximum Phase', str = 'latticemamax';
    case 'Lattice Autoregressive Moving-Average (ARMA)', str = 'latticearma';
    case 'Coupled-Allpass (CA) Lattice',  str = 'calattice';
    case 'Coupled-Allpass (CA) Lattice with Power-Complementary (PC) Output', str = 'calatticepc';
    case 'State-Space',                   str = 'statespace';
end

% [EOF]
