function oinfo = info(cc,opt)
%INFO return information about the target DSP processor.
%   ICC = INFO(CC) returns information about the DSP processor in Code
%   Composer Studio(R) which is referenced by CC.  The resulting
%   information is returned as a structure.  The following list
%   describes the elements of the resulting output structure: 
%   Note: If CC contains more than one processor, this method will return 
%   an array containing information on each processor.
%
%   ICC.PROCNAME - String with the name of the DSP processor defined by 
%     the Code Composer setup utility.  In multiprocessor systems, this
%     name reflects the specific processor referenced by the CC object.
%   ICC.ISBIGENDIAN - Boolean value which describes the byte-ordering used
%     by the target DSP.  If the DSP processor is big-endian, this value
%     is true.  Conversely, little-endian processors will produce a false
%     value for this element.
%   ICC.FAMILY  - Decimal integer which represents the processor's
%     family ID, 0-999.  For example, 320 for Texas Instrument's DSPs.
%   ICC.SUBFAMILY - Hexadecimal integer which represents the processor's
%     subfamily ID, 0-3822.  Use DEC2HEX to convert this value to standard
%     notation.  For example, dec2hex(icc.subfamily) produces '67' with
%     the TMS320C6701 DSP.  
%   ICC.REVFAMILY - Decimal value which represents the processor's revision.
%     For example, the TMS320C6711 will produce 11 for this entry.
%   ICC.TIMEOUT - Default timeout used by MATLAB during data transfers to
%     and from Code Composer Studio(R).  All methods that require timeouts
%     have an optional timeout parameter.  If a specific timeout parameter 
%     is omitted by a method call, then this default value is used.
%
%  Example: cc contains 1 processor
%   icc = info(cc);
%   sprintf('My DSP = TMS%03dC%2s%02d\n',...
%      icc.family,dec2hex(icc.subfamily),icc.revfamily)
%
%  Example: cc contains 2 processors
%   icc = info(cc);  % will return a 1x2 array of info struct
%   for i=1:length(icc)
%       sprintf('My DSP %01d = TMS%03dC%2s%02d\n',...
%            i, icc(i).family,dec2hex(icc(i).subfamily),icc(i).revfamily)
%   end
%
%  Note - Code Composer's support for the DSP family information is incomplete. 
%  Thus, some processors will be reported as related members of the same family.
%
%   See also DEC2HEX, DISP.

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.12.6.4 $ $Date: 2004/04/06 01:04:45 $

if nargin==1,
	for k = 1:length(cc)
        oinfo(k) = p_info(cc(k));
	end
elseif nargin==2 && strcmp(opt,'stack') % for private use only
    for k = 1:length(cc)
        oinfo(k) = p_stackinfo(cc(k));
    end
else
    error('Too many input arguments.');
end
%--------------------------
function oinfo = p_info(cc)
% Global Timeout (Object)
oinfo = callSwitchyard(cc.ccsversion,[16,cc.boardnum,cc.procnum,0,0]);
oinfo.timeout = cc.timeout;

%--------------------------
function info = p_stackinfo(cc)
stk = cc.stack;
if stk.numofstackobjs == 0
    stackobjs = [];
else
    stackobjs = stk.stackobjects;
end
TOSaddress = stk.topofstack;
info = struct( 'stackobjects',  stackobjs, ...
               'topofstack',    TOSaddress, ...
               'numofstackobjs',stk.numofstackobjs...
              );

% [EOF] info.m