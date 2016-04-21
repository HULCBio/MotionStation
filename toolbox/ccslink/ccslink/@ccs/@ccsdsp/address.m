function addr = address(cc,symname,vscope)
%ADDRESS returns the address of a specified a target symbol
%  A = ADDRESS(CC,SYM,VARSCOPE) returns the address of SYM, which is a
%  string representation of the desired symbol.  If the specified symbol is
%  not found, a warning is generated and A is empty.  Note, this method
%  returns only the first occurrence of the specified symbol (SYM) from the
%  symbol table.  This method is only applicable after loading the desired
%  program file.  The return value A is a 2 element numeric array with the
%  symbol's address offset and page.  This return value can be used
%  directly as an input to the address field of CC.READ and CC.WRITE. 
%
%  VARSCOPE can be 'global' or 'local'. This parameter tells the address
%  method if SYM is a local or a global variable. The 'local' option should
%  only be used when the current scope of the program is the desired
%  function scope.
% 
%  A = ADDRESS(CC,SYM) same as the above, except that VARSCOPE defaults 
%  to 'global'.
%
%  Return value:
%  A(1) - Address offset
%  A(2) - Page
%
%  For example,
%    coefval = cc.read(cc.address('coef'),5,'int32'),
%  returns the first 5 members of a target's array called 'coef'.
%
%  See also DEC2HEX, LOAD, SYMBOL.

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.9.4.3 $ $Date: 2004/04/06 01:04:39 $

error(nargchk(2,3,nargin));
p_errorif_ccarray(cc);

if ~ishandle(cc),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a CCSDSP Handle.');
end

if nargin == 2
    vscope = 'global'; %default
end

if ~ischar(vscope),
    error(generateccsmsgid('InvalidInput'),...
        '??? Address: Specified variable scope parameter must be a string.');
end
if ~any(strcmpi(vscope,{'global','local'}))
    error(generateccsmsgid('InvalidInput'),...
        ['??? Address: Specified variable scope parameter''' vscope ''' must be GLOBAL or LOCAL.']);
end

if strcmpi(vscope,'global')
    addr = callSwitchyard(cc.ccsversion,[18,cc.boardnum,cc.procnum,0,0],symname);
else % local
    symb = callSwitchyard(cc.ccsversion,[60,cc.boardnum,cc.procnum,0,0],symname);
    addr = symb.location;
end
    
if ~isempty(addr) && addr(2)<0
    error(generateccsmsgid('MethodNotApplicable'),...
        ['ADDRESS value cannot be determined. ''' symname ''' must be a local variable or a register variable.']);
end

% [EOF] address.m