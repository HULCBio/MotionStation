% function [pk,indepv,vindex] = pkvnorm(matin,p)
%
%   Find peak value of the norm of a VARYING matrix, also
%   returns the value of the INDEPENDENT VARIABLE at the peak,
%   along with the index of the INDEPENDENT VARIABLE. The second
%   input argument determines the particular norm, using the same
%   convention as MATLAB's NORM command.
%
%   See also: NORM, VNORM, and VSVD.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [pk,iv,vindex] = pkvnorm(matin,p)
 if nargin == 0
   disp(['usage: [pk,iv,vindex] = pkvnorm(matin,p)']);
   return
 end
 [mtype,mrows,mcols,mnum] = minfo(matin);
 if nargin == 1
   p = 2;
 end
 if mtype == 'cons'
   pk = norm(matin,p);
   vindex = [];
   iv = [];
 elseif mtype == 'vary'
    if mrows>1 | mcols>1
        pk = -inf;
        npts = mnum;
        ff = (npts+1)*mrows;
        pt = 1:mrows:ff;
        ptm1 = pt(2:npts+1)-1;
        val = zeros(npts,1);
        for i=1:npts
            val(i) = norm(matin(pt(i):ptm1(i),1:mcols),p);
        end
        [pk,idx] = max(val);
        pk = pk(1);
        vindex = idx(1);
        iv = matin(vindex,mcols+1);
    else
        [pk,idx] = max(abs(matin(1:mnum,1)));
        pk = pk(1);
        vindex = idx(1);
        iv = matin(vindex,mcols+1);
    end
 elseif mtype == 'syst'
   error('PKVNORM is not defined for SYSTEM matrices')
   return
 else
   pk = [];
   vindex = [];
   iv = [];
 end
%
%