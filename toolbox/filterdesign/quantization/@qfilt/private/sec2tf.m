function [num,den] = sec2tf(oldstruct,oldsection,scale)
%SECTION2TF  Convert a single section to transfer function.
%    [B,A] = SECTION2TF(FILTERSTRUCTURE,COEF,SCALEVALUE) returns a single
%    transfer function with numerator coefficients in B and denominator
%    coefficients in A, where COEF is a cell array of a single section of
%    coefficients, and SCALEVALUE is the scale value for that section.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/14 15:28:25 $

if nargin<3, scale = []; end

switch oldstruct
  case {'df1','df1t','df2','df2t'}
    num = oldsection{1};
    den = oldsection{2};
  case {'fir','firt','symmetricfir','antisymmetricfir'}
    num = oldsection{1};
    den = 1;
  case 'latticear'
    % oldsection = {k}
    [num,den] = latc2tf(oldsection{1},'allpole');
  case 'latticema'
    % oldsection = {k}
    [num,den] = latc2tf(oldsection{1},'min');
  case {'latcmax', 'latticemaxphase'}
    % oldsection = {k}
    [num,den] = latc2tf(oldsection{1},'max');
  case {'latcallpass', 'latticeallpass'}
    % oldsection = {k}
    [num,den] = latc2tf(oldsection{1},'allpass');
  case 'latticearma'
    % oldsection = {k,v}
    [num,den] = latc2tf(oldsection{:});
  case 'latticeca'
    % oldsection = {k1,k2,beta}
    [num,den] = cl2tf(oldsection{:});
  case 'latticecapc'
    % oldsection = {k1,k2,beta}
    [temp,den,num] = cl2tf(oldsection{:});
  case 'statespace'
    % oldsection = {A,B,C,D}
    [num,den] = ss2tf(oldsection{:});
end

num = dezero(num);
if isempty(num), num = 0; end

if ~isempty(scale)
  num = num*scale;
end
