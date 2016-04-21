function LS = filt2ls(LoD,HiD,LoR,HiR,outTYPE)
%FILT2LS Filters to lifting scheme.
%   LS = FILT2LS(LoD,HiD,LoR,HiR) returns the lifting 
%   scheme LS associated to the four input filters LoD, 
%   HiD, LoR and HiR which are supposed to verify the 
%   perfect reconstruction condition.
%     
%   See also LS2FILT, LSINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Jul-2003.
%   Last Revision: 17-Jul-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:39:37 $

if nargin < 5
    flagONE = true;
    outTYPE = 'd_one';
else
    outTYPE = lower(outTYPE);
    switch outTYPE
        case 'd_one' , flagONE = true;
        case 'p_one' , flagONE = true;
        otherwise    , flagONE = false;
    end
end

[Ha,Ga,Hs,Gs,PRCond,AACond] = filters2lp('b',LoR,LoD);
[LS_d,LS_p] = lp2ls(Hs,Gs,'t');
switch outTYPE(1)
    case 'd' , LS = LS_d;
    case 'p' , LS = LS_p;
    otherwise , LS = cat(1,LS_d,LS_p);          
end

if flagONE % Only one LS!
    OK = isequal(LS{1},'d') || isequal(LS{1},'p');
    if ~OK % test for Lazy
        OK = size(LS,1)==1 &&  isequal(LS{1},1) && isequal(LS{2},1);
        if ~OK , LS = LS{1}; end
    end
end
