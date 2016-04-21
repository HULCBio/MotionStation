function s = filterstructure(Hq,fullname)
%FILTERSTRUCTURE  Filter structure of a quantized filter.
%   S = FILTERSTRUCTURE(Hq) returns the value of the FILTERSTRUCTURE property of
%   quantized filter object Hq.  Filter structure can be one of the following
%   strings:
%                'df1' : Direct form I
%               'df1t' : Direct form I transposed
%                'df2' : Direct form II
%               'df2t' : Direct form II transposed
%                'fir' : Direct form FIR
%               'firt' : Direct form FIR transposed
%       'symmetricfir' : Direct form symmetric FIR
%   'antisymmetricfir' : Direct form antisymmetric FIR
%          'latticear' : Lattice AR
%     'latticeallpass' : Lattice allpass
%          'latticema' : Lattice MA min. phase
%    'latticemaxphase' : Lattice MA max. phase
%        'latticearma' : Lattice ARMA
%          'latticeca' : Lattice coupled-allpass 
%        'latticecapc' : Lattice coupled-allpass power-complementary 
%         'statespace' : State-space
%     
%   The default is 'df2t'.
%
%   S = FILTERSTRUCTURE(Hq,'full') returns the full name for the filter
%   structure.  
%
%   Example:
%     Hq = qfilt;
%     filterstructure(Hq)
%     filterstructure(Hq,'full')
%
%   See also QFILT, QFILT/GET, QFILT/SET, QFILT/REFERENCECOEFFICIENTS,
%   QFILTCONSTRUCTION. 

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/04/14 15:32:41 $

s = Hq.filterstructure;

if nargin>1 & ~isempty(fullname)
  switch s
    case 'df1', 
      s = 'Direct form I';
    case 'df1t',
      s = 'Direct form I transposed';
    case 'df2', 
      s = 'Direct form II';
    case 'df2t', 
      s = 'Direct form II transposed';
    case 'fir', 
      s = 'Direct form FIR';
    case 'firt', 
      s = 'Direct form FIR transposed';
    case 'symmetricfir', 
      s = 'Direct form symmetric FIR';
    case 'antisymmetricfir', 
      s = 'Direct form antisymmetric FIR';
    case 'latticear', 
      s = 'Lattice AR';
    case {'latcallpass', 'latticeallpass'}
      s = 'Lattice allpass';
    case 'latticema', 
      s = 'Lattice MA min. phase';
    case {'latcmax', 'latticemaxphase'}
      s = 'Lattice MA max. phase';
    case 'latticearma', 
      s = 'Lattice ARMA';
    case 'latticeca', 
      s = 'Lattice coupled-allpass';
    case 'latticecapc', 
      s = 'Lattice coupled-allpass power-complementary';
    case 'statespace', 
      s = 'State-space';
  end
end


