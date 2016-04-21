function zf = zidezeropad(zf,filterstructure,n1,n2)
%ZIDEZEROPAD  Remove zero padding from initial/final conditions.
%   ZIDEZEROPAD(ZF,FILTERSTRUCTURE,N1,N2) removes the zero padding from
%   initial or final condition matrix ZF.  The filter structure is defined
%   by string FILTERSTRUCTURE.  See JAVAFILTER for the definition of the
%   parameters N1 and N2.
%   
%   The initial conditions are zero-padded before calling a Java filter, and
%   they are de-zero-padded afterwards for returning to MATLAB.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/04/14 15:28:10 $

if isempty(zf)
  return
end

if iscell(zf)
  for k=1:length(zf)
    zf{k} = zidezeropad(zf,filterstructure,n1,n2);
  end
end

% Depending on the filter structure, remove zero padding

switch filterstructure
  case {'df1'}
    zf = [zf(2:n1,:);zf(n1+2:end,:)];
  case {'df1t'}
    zf = [zf(1:n2-1,:);zf(n2+1:end-1,:)];
 case {'df2', 'df2t','firt','latticear','latticearma','latticema',...
       'latcallpass','latticeallpass','latcmax','latticemaxphase'}
    zf = zf(1:end-1,:); 
  case {'fir','symmetricfir','antisymmetricfir'}
    zf = zf(2:end,:);
  case {'latticeca','latticecapc'}
    zf = [zf(1:n1,:);zf(n1+2:end-1,:)];
end

