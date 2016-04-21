% tsys = stransp(sys)
%
% Given the SYSTEM matrix SYS of a system of realization
% (A,B,C,D,E),  STRANSP returns the system of realization
% (A',C',B',D',E').
%
% This function also works for polytopic or parameter-
% dependent systems.
%
%
% See also   LTISYS, PDLSTAB, PDLPERF.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function tsys = stransp(sys)

if nargin ~=1,
  error('usage: tsys = stransp(sys)');
end

if ispsys(sys),

   [pdtype,nv]=psinfo(sys);
   s=[];
   for j=1:nv, s=[s stransp(psinfo(sys,'sys',j))]; end

   pdtype=1+strcmp(pdtype,'aff');
   tsys=psys(psinfo(sys,'par'),s,pdtype);


elseif islsys(sys),

   [a,b,c,d,e]=ltiss(sys);
   tsys=ltisys(a',c',b',d',e');

else

   error('SYS must be a SYSTEM matrix or a PPD system');

end
