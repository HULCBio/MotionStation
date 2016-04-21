function resp = cexpr(cc,expr,timeout)
%CEXPR   Executes a C or GEL expression in the Target processor
%  RESP = CEXPR(CC,EXP,TIMEOUT) will execute on the target DSP a 
%   'C' data expression or GEL command defined by EXP. This method
%   can provide access to complex data objects such as structures
%   and arrays.  As defined by the Code Composer syntax, EXP is a
%   string with C syntax where variables are taken  from the local 
%   scope of the DSP processor, while routines are mapped to GEL 
%   functions defined in the DSP project.  The returned value RESP 
%   will follow the C syntax rules.  Most GEL commands do not
%   return a value, in which case RESP will not be set.  The 
%   resolution of DSP variables in the C expression will depend
%   on the scope of the DSP program.  
%
%  RESP = CEXPR(CC,EXP) Same as above, except the timeout value 
%   defaults to the  timeout property specified by the CC object.
%   Use CC.GET to examine the default timeout value.
%
%  Examples
%   >a=cexpr(cc,'x.zz') - Return value of zz field in x structure.
%   >cexpr(cc,'Startup()') - Execute GEL function 'Startup'
%   >cexpr(cc,'x.b=10')    - Set value of x.b in DSP to 10.
%   >cexpr(cc,['x.c[2]=' int2str(z)]) - Set value of x.c[2] 
%      in DSP to the value of MATLAB variable z.
%
%  See also READ, WRITE, ADDRESS.

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.5.4.2 $ $Date: 2004/04/01 16:02:11 $

% Check input parameters
error(nargchk(2,3,nargin));
p_errorif_ccarray(cc);

if ~ishandle(cc),
    error('First Parameter must be a CCSDSP Handle.');
end
% Parse timeout
if( nargin >= 3) & (~isempty(timeout)),
    if ~isnumeric(timeout) | length(timeout) ~= 1,
        error('TIMEOUT parameter must be a single numeric value.');
    end
    dtimeout = double(timeout);
else
    dtimeout = double(get(cc,'timeout'));
end
if( dtimeout < 0)
    error(['Negative TIMEOUT value "' num2str(dtimeout) '" not permitted.']);
end
temp = callSwitchyard(cc.ccsversion,[54,cc.boardnum,cc.procnum,dtimeout,cc.eventwaitms],expr);
if ~isempty(temp)
    resp = temp; 
end
    
% [EOF] cexpr.m
