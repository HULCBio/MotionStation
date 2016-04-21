function varargout = privfilter(coeff, x, zi, filterstructure, ...
    qcoefficient, qinput, qoutput, qmultiplicand, qproduct, qsum) 
%   For normal filtering:
%   [y,zf] = privfilter(coeff, x, zi, filterstructure, ...
%       qcoefficient, qinput, qoutput, qmultiplicand, qproduct, qsum);
%
%   For state sequence:
%   [y,z,v] = privfilter(coeff, x, zi, filterstructure, ...
%       qcoefficient, qinput, qoutput, qmultiplicand, qproduct, qsum);
%   

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.19 $  $Date: 2002/04/14 15:28:48 $

if isempty(x)
    y = x;
    zf = zi;
    varargout = {y,zf};
    return
end

[n1,n2] = privfiltparams(coeff, filterstructure);
zi = zizeropad(zi, filterstructure, n1,n2);

switch filterstructure
  case {'antisymmetricfir', 'dfantisymmetricfir'}  % 1
    b = deal(coeff{:});
    [varargout{1:max(1,nargout)}] = qdfantisymmetricfirfilter(b,x,zi,qcoefficient,qinput,qoutput,qmultiplicand,qproduct,qsum);
  case 'df1'               % 2
    [b,a] = deal(coeff{:});
    [varargout{1:max(1,nargout)}] = qdf1filter(b,a,x,zi,qcoefficient,qinput,qoutput,qmultiplicand,qproduct,qsum);
  case 'df1t'              % 2
    [b,a] = deal(coeff{:});
    [varargout{1:max(1,nargout)}] = qdf1tfilter(b,a,x,zi,qcoefficient,qinput,qoutput,qmultiplicand,qproduct,qsum);
  case 'df2'               % 2
    [b,a] = deal(coeff{:});
    [varargout{1:max(1,nargout)}] = qdf2filter(b,a,x,zi,qcoefficient,qinput,qoutput,qmultiplicand,qproduct,qsum);
  case 'df2t'              % 2
    [b,a] = deal(coeff{:});
    [varargout{1:max(1,nargout)}] = qdf2tfilter(b,a,x,zi,qcoefficient,qinput,qoutput,qmultiplicand,qproduct,qsum);
  case {'dffir', 'fir'}    % 1  
    b = deal(coeff{:});
    [varargout{1:max(1,nargout)}] = qdffirfilter(b,x,zi,qcoefficient,qinput,qoutput,qmultiplicand,qproduct,qsum);
  case {'dffirt', 'firt'}  % 1  
    b = deal(coeff{:});
    [varargout{1:max(1,nargout)}] = qdffirtfilter(b,x,zi,qcoefficient,qinput,qoutput,qmultiplicand,qproduct,qsum);
  case {'latcallpass','latticeallpass'}    % 1
    k = deal(coeff{:});
    [varargout{1:max(1,nargout)}] = qlatticeallpassfilter(k,x,zi,qcoefficient,qinput,qoutput,qmultiplicand,qproduct,qsum);
  case {'latcmax','latticemaxphase'}       % 1
    k = deal(coeff{:});
    [varargout{1:max(1,nargout)}] = qlatticemaxphasefilter(k,x,zi,qcoefficient,qinput,qoutput,qmultiplicand,qproduct,qsum);
  case 'latticear'         % 1
    k = deal(coeff{:});
    [varargout{1:max(1,nargout)}] = qlatticearfilter(k,x,zi,qcoefficient,qinput,qoutput,qmultiplicand,qproduct,qsum);
  case 'latticearma'       % 2
    [k,v] = deal(coeff{:});
    [varargout{1:max(1,nargout)}] = qlatticearmafilter(k,v,x,zi,qcoefficient,qinput,qoutput,qmultiplicand,qproduct,qsum);
  case 'latticecapc'       % 3
    [k,v,beta] = deal(coeff{:});
    [varargout{1:max(1,nargout)}] = qlatticecapcfilter(k,v,beta,x,zi,qcoefficient,qinput,qoutput,qmultiplicand,qproduct,qsum);
  case 'latticeca'         % 3
    [k,v,beta] = deal(coeff{:});
    [varargout{1:max(1,nargout)}] = qlatticecafilter(k,v,beta,x,zi,qcoefficient,qinput,qoutput,qmultiplicand,qproduct,qsum);
  case 'latticema'         % 1  min phase
    k = deal(coeff{:});
    [varargout{1:max(1,nargout)}] = qlatticemafilter(k,x,zi,qcoefficient,qinput,qoutput,qmultiplicand,qproduct,qsum);
  case 'statespace'        % 4
    [A,B,C,D] = deal(coeff{:});
    [varargout{1:max(1,nargout)}] = qstatespacefilter(A,B,C,D,x,zi,qcoefficient,qinput,qoutput,qmultiplicand,qproduct,qsum);
  case {'symmetricfir', 'dfsymmetricfir'}      % 1
    b = deal(coeff{:});
    [varargout{1:max(1,nargout)}] = qdfsymmetricfirfilter(b,x,zi,qcoefficient,qinput,qoutput,qmultiplicand,qproduct,qsum);
end

if nargout>1
  varargout{2} = zidezeropad(varargout{2},filterstructure,n1,n2);
end
