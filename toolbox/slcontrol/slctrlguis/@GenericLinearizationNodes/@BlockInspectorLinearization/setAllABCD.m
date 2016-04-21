function setAllABCD(this,J,indx,indu,indy);
% Method to store the blocks linearization in their hidden properties

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $ $Date: 2004/03/24 21:09:29 $

for ct = length(J):-1:1
    allA(:,:,ct) = full(J(ct).A(indx,indx));
    allB(:,:,ct) = full(J(ct).B(indx,indu));
    allC(:,:,ct) = full(J(ct).C(indy,indx));
    allD(:,:,ct) = full(J(ct).D(indy,indu));
end

%% Store the properties
this.allA = allA;
this.allB = allB;
this.allC = allC;
this.allD = allD;
this.indx = indx;
this.indu = indu;
this.indy = indy;