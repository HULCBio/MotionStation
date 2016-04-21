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

% Copyright 2004 The MathWorks, Inc.
