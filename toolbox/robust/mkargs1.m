function [flag,narg,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27]=mkargs1(f,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11,i12,i13,i14,i15,i16,i17,i18,i19,i20,i21,i22,i23,i24,i25,i26,i27)
%MKARGS1 Expand input argument created by MKSYS (used by MKARGS).
%
%  [FLAG,NARG,O1,...,ON]= MKARGS1(TY,I1,...,IM) is a subroutine used by
%     MKARGS.  The input argument list I1,...,IM is copied onto the output
%     argument list O1,...ON, expanding each SYSTEM found in the input
%     argument list by inserting its defining matrices in its place in the
%     argument list.  The output argument NARG returns the number of input
%     argument I1,...,IM after expansion of systems.  Any extra output
%     arguments O1,...,ON (in excess of NARG) are returned as NaN's.  If
%     too few output arguments are provided to complete the expansion, the
%     function terminates with an error.
%
%     The optional string TY, if present, specifies the admissible system
%     types for the systems to be encountered in the order in which they
%     are expected, e.g., TY='ss,tss'; an error is produced if systems
%     of other than the specified types are encountered when EVAL(CMD)
%     is executed.
%
%  EXAMPLE:
%     If SS_G = MKSYS(A,B,C,D), W=logspace(-2,2) and Z='foobar', then
%        [O1,O2,O3,O4,O5,O6,O7,O8] = MKARGS1('',Z,SS_G,W)
%     returns NARG=6, O1=Z, O2=A, O3=B, O4=C, O5=D, O6=W, O7=NaN, and O8=NaN.


% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
% All Rights Reserved.

nin=nargin-1;
nout=nargout-1;
j=0;
flag=0;
fflag=0;
nf=0;
kk=0;
ty1='';
if min(size(f))>0,
   fflag=1;            % FFLAG nonzero indicates admissible system types are
   f=[',' f ', '];     % restricted to values in string F.
   f(find(f==' '))=''; % Remove spaces from F.
   ind=find(f==',');   % IND = indices of commas in string F
   nf=max(size(ind))-1;% Number of system types specified in F
end


for k=1:nin,
   eval(['o=i' num2str(k) ';'])
   [i,ty,n]=issystem(o);
   if i,
      kk=kk+1;
      if kk<=nf,
        ty1=f(ind(kk)+1:ind(kk+1)-1);
      end
      if min(size(ty1))>0,
        if ~issame(ty1,ty),
          error(['System type ''' ty ''' encountered where type ''' ty1 ''' expected.'])
        end
      end
      flag=1;
      temp=[];
      for l=j+1:j+n
         j=j+1;
         temp=[temp  ',o' num2str(j)];
      end,
      temp(1)='';  % get rid of leading comma
      eval(['[' temp ']=branch(o);'])
   else,
      j=j+1;
      eval(['o' num2str(j) '=o;'])
   end,
   if j>=nout,
     if j>nout,
        msg=['Unable to expand input argument '...
            num2str(k+1) '--too few output arguments.'];
        error(msg)
     end
   break
   end
end
narg=j;
while j<nout,
   j=j+1;
   eval(['o' num2str(j) '=NaN;'])
end

% -----------End of MKARGS1.M ----------RYC/MGS 1990 (REV. 3/6/92)