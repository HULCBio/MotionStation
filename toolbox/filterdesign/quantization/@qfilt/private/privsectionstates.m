function [Nsections,Nstates] = privsectionstates(structure,coeff)
%PRIVSECTIONSTATES Determine the number of sections and states per section.
%   [NumberOfSections StatesPerSection] = PRIVSECTIONSTATES(STRUCT,COEFF)
%   returns the number of sections and states per section in
%   [NumberOfSections StatesPerSection].  STRUCT is the filter structure, 
%   and COEFF are the coefficients, quantized or unquantized.

%   Author(s): Chris Portal
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.14 $  $Date: 2002/04/14 15:28:22 $

% Determine the number of cascades from the structure, info and coefficients.
if isnumeric(coeff{1})
  coeff = {coeff};
end

Nsections = length(coeff);
Nstates = zeros(1,Nsections);

for k=1:Nsections
  switch structure
    case {'df1' 'df1t'}
      % length(b) + length(a) - 2
      Nstates(k) = length(coeff{k}{1}) + length(coeff{k}{2})-2;
    case 'statespace'
      % size(A,2)
      Nstates(k) = size(coeff{k}{1},2);
    case {'latticema','latcmax','latticemaxphase','latticear','latcallpass','latticeallpass'}
      % length(k)
      Nstates(k) = length(coeff{k}{1});
    case {'latticearma'}
      % max(length(k),length(v)-1)
      Nstates(k) = max(length(coeff{k}{1}),length(coeff{k}{2})-1);
    case {'latticeca', 'latticecapc'}
      Nstates(k) = length(coeff{k}{1}) + length(coeff{k}{2});
    case {'fir','firt','antisymmetricfir','symmetricfir'}
      % length(b)-1
      Nstates(k) = length(coeff{k}{1}) - 1;
    case {'df2','df2t'}
      % max(length(b),length(a)) - 1
      Nstates(k) = max(length(coeff{k}{1}),length(coeff{k}{2}))-1;
  end
end

