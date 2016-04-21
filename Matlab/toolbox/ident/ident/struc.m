function NN=struc(NA,NB,NK)
%STRUC  generates typical structure matrices for ARXSTRUC and IVSTRUC.
%   NN = STRUC(NA,NB,NK)
%
%   NA, NB and NK are vectors containing the orders na, nb and delays nk
%   to be tested. See HELP ARX for an explanation of na, nb and nk.
%   NN is returned as a matrix containing all combinations of these
%   orders and delays. The function is intended for single input systems
%   only.
%
%   See also ARXSTRUC, IVSTRUC and SELSTRUC for further information

%   L. Ljung 7-8-87
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2001/04/06 14:22:30 $

if nargin < 3
   disp('Usage: ORDERS = STRUC(NA_RANGE,NB_RANGE,NK_RANGE)')
   return
end


r=1;
for ka=NA
        for kb=NB
        for kk=NK
        NN(r,:)=[ka,kb,kk];
        r=r+1;
        end
        end
end
