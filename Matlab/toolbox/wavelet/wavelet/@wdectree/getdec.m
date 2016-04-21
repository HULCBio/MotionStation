function A = getdec(t,option)
%GETDEC Get decomposition components.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi  12-Feb-2003.
%   Last Revision: 11-Jul-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/03/15 22:38:51 $ 

tn  = leaves(t);
lev = treedpth(t);
d = read(t,'data',tn);

NA = 2^lev;
A  = d{1}/NA;
mA = max(max(abs(A)));
for k = 2:3:length(d)
    A = wkeep2(A,size(d{k}));
    A = [ A , normCFS(d{k},mA); normCFS(d{k+1},mA) , normCFS(d{k+2},mA) ];
end
%--------------------------------------
function Y = normCFS(X,mA,option)

mX = max(max(abs(X)));
Y  = mA*(1-abs(X)/mX);
%--------------------------------------