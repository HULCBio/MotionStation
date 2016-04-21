function boo = isSettling(this,DC)
% Checks if the step response if close to sellting or diverging.
% Used to assess stability for systems with delayed dynamics.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:25:43 $
factor = 0.5;
y = this.Amplitude;
[ns,ny,nu] = size(y);
DCrow = reshape(DC,1,ny*nu);
gaps = abs(DCrow-y(ns,:));  % gaps between final values and DC values
scale = abs(DCrow) + 0.1*reshape(max(abs(y),[],1),1,ny*nu);
boo = all(gaps < factor * scale);
