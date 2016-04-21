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

% Copyright 2004 The MathWorks, Inc.
