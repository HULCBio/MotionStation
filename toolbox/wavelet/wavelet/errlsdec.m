function [err,idx] = errlsdec(LSTable,tolerance)
%ERRLSDEC Errors for lifting scheme decompositions.
%   For a cell array of lifting schemes LSTAB (or a single
%   Lifting Scheme LS), 
%       ERR = ERRLSDDEC(LSTAB) ( ERR = ERRLSDDEC(LS) ) 
%   returns the numerical errors between random vectors 
%   and the corresponding reconstructed vectors.
%
%   For each Lifting Scheme LS in LSTAB, random vectors
%   are decomposed and then reconstructed with LS. 
%   The error corresponding to LS is the maximum of errors
%   between a random vector and the corresponding reconstructed
%   one. 
%
%   In addition, [ERR,TABTOL] = ERRLSDDEC(LSTAB,TOL) returns
%   a boolean array TABTOL of the same size as LSTAB. TABTOL 
%   is such that TABTOL(k) is equal to 1 if ERR(k) < TOL
%   and 0 otherwise.
%   ERRLSDDEC(LSTAB) is equivalent to ERRLSDDEC(LSTAB,0).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 30-May-2003.
%   Last Revision 27-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/13 00:39:35 $ 

if nargin<2 , tolerance = 0; end

% Test for a single Lifting Scheme.
cellMODE = ~(isequal(LSTable{1,1},'p') || isequal(LSTable{1,1},'d'));
if ~cellMODE , LSTable = {LSTable}; end

nbTST = 5;
nbVAL = 1000;
nbLS = length(LSTable);
err = zeros(1,nbLS);

level = 4;
for i=1:nbTST
    x = rand(1,nbVAL);
    errTMP = zeros(1,nbLS);
    for k=1:nbLS
        LS = LSTable{k};
        x_InPlace = lwt(x,LS,level);
        xREC = ilwt(x_InPlace,LS,level);
        errorTMP = max(abs(x-xREC));
        if errorTMP>err(k)
            err(k) = errorTMP;
        end
    end
end
idx = err < tolerance;
