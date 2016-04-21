function [n1,n2] = javafilter(coeff, filterstructure);
%JAVAFILTER Java filter object.
%   [JFILT,N1,N2] = JAVAFILTER(COEFF, FILTERSTRUCTURE, QMULTIPLICAND, QPRODUCT, QSUM,
%   REALFLAG) returns the Java filter object associated with FILTERSTRUCTURE
%   with quantized coefficients for a single section in cell-array COEFF.  If
%   REALFLAG==1, then construct a Real filter; otherwise, construct a Complex
%   filter.  The quantizer objects QMULTIPLICAND, QPRODUCT, QSUM are the multiplicand
%   quantizer, the product quantizer, and the sum quantizer, respectively.
%
%   The definition of the parameters N1 and N2 depend on the filter structure
%   by the following table:
%
%    FILTERSTRUCTURE         N1                N2
%    df1, df1t, df2, df2t    length(b)         length(a)
%    latticearma             length(lattice)   length(ladder)
%    latticeca, latticecapc  length(lattice1)  length(lattice2)
%    otherwise               n/a               n/a

%   Thomas A. Bryan, 20 July 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.15 $  $Date: 2002/04/14 15:28:43 $


n1=0; n2=0;

% $$$ % Get the Java quantizers in the MATLAB-quantizer objects
% $$$ jqmultiplicand = get(qmultiplicand,'quantizer');
% $$$ jqproduct = get(qproduct,'quantizer');
% $$$ jqsum = get(qsum,'quantizer');

% Filter topology
switch filterstructure
  case {'df1', 'df1t', 'df2', 'df2t'}  % Two vectors
     b = coeff{1};
     a = coeff{2};
    n1 = length(b);
    n2 = length(a);
% $$$     if realflag
% $$$       [b,a] = privrealtojava(b,a);
% $$$     else
% $$$       [b,a] = privcomplextojava(b,a);
% $$$     end
% $$$     jfilt = javaObject(['com.mathworks.toolbox.filterdesign.',...
% $$$           upper(filterstructure(1)),lower(filterstructure(2:end))],...
% $$$         b,a,jqmultiplicand,jqproduct,jqsum);
  case {'latticearma'}
     lattice = coeff{1};
     ladder = coeff{2};
    n1 = length(lattice);
    n2 = length(ladder);
% $$$     if realflag
% $$$       [lattice,ladder] = privrealtojava(lattice,ladder);
% $$$     else
% $$$       [lattice,ladder] = privcomplextojava(lattice,ladder);
% $$$     end
% $$$     jfilt = javaObject(['com.mathworks.toolbox.filterdesign.',...
% $$$           upper(filterstructure(1)),lower(filterstructure(2:end))],...
% $$$         lattice,ladder,jqmultiplicand,jqproduct,jqsum);
  case {'latticeca', 'latticecapc'}
     lattice1 = coeff{1};
     lattice2 = coeff{2};
     beta = coeff{3};
    n1 = length(lattice1);
    n2 = length(lattice2);
% $$$     if realflag
% $$$       [lattice1,lattice2] = privrealtojava(lattice1,lattice2);
% $$$     else
% $$$       [lattice1,lattice2] = privcomplextojava(lattice1,lattice2);
% $$$       beta = javaObject('com.mathworks.toolbox.filterdesign.Complexscalar', ...
% $$$           real(beta),imag(beta));
% $$$     end
% $$$     jfilt = javaObject(['com.mathworks.toolbox.filterdesign.',...
% $$$           upper(filterstructure(1)),lower(filterstructure(2:end))],...
% $$$         lattice1,lattice2,beta,jqmultiplicand,jqproduct,jqsum);
  case {'fir', 'firt', 'latticema', 'latticear', ...
          'latcmax','latticemaxphase','latcallpass','latticeallpass',...
          'symmetricfir','antisymmetricfir'}   
% $$$     % One vector
% $$$     b = coeff{1};
% $$$     if realflag
% $$$       b = privrealtojava(b);
% $$$     else
% $$$       b = privcomplextojava(b);
% $$$     end
% $$$     jfilt = javaObject(['com.mathworks.toolbox.filterdesign.',...
% $$$           upper(filterstructure(1)),lower(filterstructure(2:end))],...
% $$$         b,jqmultiplicand,jqproduct,jqsum);
  case 'statespace' % Four matrices
% $$$     A = coeff{1};
% $$$     B = coeff{2};
% $$$     C = coeff{3};
% $$$     D = coeff{4};
% $$$     if realflag
% $$$       [A,B,C,D] = privrealtojava(A,B,C,D);
% $$$     else
% $$$       [A,B,C,D] = privcomplextojava(A,B,C,D);
% $$$     end
% $$$     jfilt = javaObject(['com.mathworks.toolbox.filterdesign.',...
% $$$           upper(filterstructure(1)),lower(filterstructure(2:end))],...
% $$$         A,B,C,D,jqmultiplicand,jqproduct,jqsum);
  otherwise
    error(['Invalid quantized filter FilterStructure: ',filterstructure])
end

