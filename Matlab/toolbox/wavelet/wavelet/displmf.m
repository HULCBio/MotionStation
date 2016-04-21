function dispSTR = displmf(MF)
%DISPLMF Display a Laurent matrices factorization.
%   S = DISPLMF(MF) returns a string which may be used 
%   to display the Laurent matrices factorization MF.
%   Without output argument, "DISPLMF(MF);" diplays the 
%   string S.
%
%   Example:
%      LS = liftwave('db1');
%      APMF = ls2apmf(LS);
%      displmf(APMF);

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 18-Dec-2002.
%   Last Revision: 26-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:39:33 $

space = ' '; 
dispSTR = '';
for k=1:length(MF)
    tmpSTR = disp(MF{k});
    nbROW_1 = size(dispSTR,1);
    if nbROW_1>0
        nbROW_2 = size(tmpSTR,1);
        if nbROW_1 < nbROW_2
            dispSTR = [dispSTR ; space(ones(nbROW_2-nbROW_1,size(dispSTR,2)))];
        elseif nbROW_2<nbROW_1
            tmpSTR = [tmpSTR   ; space(ones(nbROW_1-nbROW_2,size(tmpSTR,2)))];
        end
    end
    dispSTR = [dispSTR , space(ones(size(tmpSTR,1),2)), tmpSTR];
end
if nargout<1 , disp(' '); disp(dispSTR); end