% function [out,err] = sortiv(in,sortflg,nored,epp)
%
%   If the INDEPENDENT VARIABLE is not monotonically increasing,
%   then the INDEPENDENT VARIABLE is reordered accordingly and
%   return to OUT. SORTFLG = 0 (default) sorts the INDEPENDENT
%   VARIABLE in increasing order and SORTFLG = 1 sorts in
%   decreasing order. NORED = 0 (default) does not
%   reduce the number of INDEPENDENT VARIABLEs even if there
%   are repeated ones. Setting NORED to a nonzero value causes
%   repeated INDEPENDENT VARIABLEs to be collapsed down if
%   their corresponding matrices are the same, if they are
%   not an error message is displayed and only the first
%   INDEPENDENT VARIABLE and corresponding matrix is kept.
%   The output argument ERR which is nominally 0, is set to 1
%   if an error message is displayed. EPP is used to test for
%   closeness of two INDEPENDENT VARIABLEs and the matrices
%   associated them. Its default values is [1e-9; 1e-9]. SORTIV
%   can be used with TACKON to mesh together frequency responses
%   or time responses.
%
%   See also: GETIV, INDVCMP, SORT, TACKON, XTRACT, and XTRACTI.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.4 $ $Date: 2004/04/10 23:40:51 $


function [out,err] = sortiv(in,sortflg,nored,epp)
if nargin < 1
    disp('usage: [out,err] = sortiv(in,sortflg,nored,epp)');
    return
end
if nargin == 1
    sortflg = 0;
    nored = 0;
    epp = [1e-9; 1e-9];
end
if nargin == 2
    nored = 0;
    epp = [1e-9; 1e-9];
end
if nargin == 3
    epp = [1e-9; 1e-9];
end
[mtype,mrows,mcols,mnum] = minfo(in);
if mtype == 'cons'
    out = in;
elseif mtype == 'vary'
    ivin = in(1:mnum,mcols+1);
    [ivout,ind] = sort(ivin);
    if sortflg ~= 0
        ivout = flipud(ivout);
        ind = flipud(ind);
    end
    out = [];
    ivcnt = [];
    err = 0;
    if nored ~= 0
        j = 1;
        ivcnt(1) = ivout(1);
        out = [out ; in((ind(1)-1)*mrows+1:ind(1)*mrows,1:mcols)];
        for i=2:mnum  
            if abs(ivout(i)-ivout(i-1)) < epp(1,1)
                tmp1 = in((ind(i)-1)*mrows+1:ind(i)*mrows,1:mcols);
                tmp2 = in((ind(i-1)-1)*mrows+1:ind(i-1)*mrows,1:mcols);
                if norm(abs(tmp1-tmp2)) > epp(2,1)
                    if err ~= 1
                        disp(' two iv''s have the same value but different matrices')
                        err = 1;
                    end
                end
            else
                j = j + 1;
                ivcnt(j) = ivout(i);
                out = [out ; in((ind(i)-1)*mrows+1:ind(i)*mrows,1:mcols)];
            end
        end
    else
        for i=1:mnum
            ivcnt(i) = ivout(i);
            out = [out ; in((ind(i)-1)*mrows+1:ind(i)*mrows,1:mcols)];
        end
    end
    out = vpck(out,ivcnt);
elseif mtype == 'syst'
    disp('SORTIV not defined for SYSTEM matrices')
    return
else
    out = [];
end
%
%