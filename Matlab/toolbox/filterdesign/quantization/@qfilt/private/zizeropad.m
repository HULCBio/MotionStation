function zi = zizeropad(zi,filterstructure,n1,n2)
%ZIZEROPAD  Zero pad from initial conditions.
%   ZIZEROPAD(ZI,FILTERSTRUCTURE,N1,N2) zero pads the initial condition matrix
%   ZI.  The filter structure is defined by string FILTERSTRUCTURE.  See
%   JAVAFILTER for the definition of the parameters N1 and N2.
%   
%   The initial conditions are zero-padded before calling a Java filter, and
%   they are de-zero-padded afterwards for returning to MATLAB.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 2002/04/14 15:28:13 $

if iscell(zi)
  for k=1:length(zi)
    zi{k} = zizeropad(zi{k},filterstructure,n1,n2);
  end
end

o = zeros(1,size(zi,2));
switch filterstructure
  case {'df1'}
    zi = [o;zi(1:n1-1,:);o;zi(n1:end,:)];
  case {'df1t'}
    zi = [zi(1:n2-1,:);o;zi(n2:end,:);o];
 case {'df2', 'df2t','firt','latticear','latticearma','latticema',...
       'latcallpass','latticeallpass','latcmax','latticemaxphase'}
    zi = [zi;o];
  case {'fir','symmetricfir','antisymmetricfir'}
    zi = [o;zi];
  case {'latticeca','latticecapc'}
    zi = [zi(1:n1,:);o;zi(n1+1:end,:);o];
end

