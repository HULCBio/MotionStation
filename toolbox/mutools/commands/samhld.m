% function discout = samhld(sys,T)
%
%   SAMHLD applies a sample-hold to the input of the continuous
%   time systems SYS, and samples the output, to produce a
%   discrete time system, DISCOUT. The sampling time is the
%   same at the input and output, and is specified by T.
%
%   See also: EXP, EXPM, and TUSTIN.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function discout = samhld(sys,st)
 if nargin < 2
   disp('usage: discout = samhld(sys,st)')
   return
 end

 [systype,sysrows,syscols,sysnx] = minfo(sys);
 if systype == 'cons'
   discout = sys;
 elseif systype == 'vary'
   error('the input matrix should be a SYSTEM or CONSTANT matrix')
   return
 elseif systype == 'syst'
   if sysnx == 0
    discout = sys;
   else
     [a,b,c,d] = unpck(sys);
     ab = [a*st b*st;zeros(syscols,sysnx+syscols)];
     eab = expm(ab);
     ad = eab(1:sysnx,1:sysnx);
     bd = eab(1:sysnx,sysnx+1:sysnx+syscols);
     discout = pck(ad,bd,c,d);
   end
 end
%
%