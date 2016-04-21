function symtab=symbol(cc)
%SYMBOL Reads the target's entire symbol table from Code Composer(R).
%  S = SYMBOL(CC) Returns the entire symbol table as an array of 
%  structures for the most recently loaded program.  This method
%  is only applicable after loading the target's program file.  If 
%  the symbol table does not exist, a warning is generated and S is 
%  empty. The element 'address' in the returned structure array can 
%  be used directly as an input to the address field of CC.READ and 
%  CC.WRITE.
%
%  Return value:
%  S(n).name        - String with symbol name
%  S(n).address(1)  - Address offset of symbol
%  S(n).address(2)  - Page of symbol
%
%  See also DEC2HEX, LOAD, ADDRESS.

% Copyright 2000-2004 The MathWorks, Inc.
% $Revision: 1.12.4.3 $ $Date: 2004/04/08 20:45:55 $

error(nargchk(1,1,nargin));
p_errorif_ccarray(cc);

if ~ishandle(cc),
    error('First Parameter must be a CCSDSP Handle.');
end
symtab = callSwitchyard(cc.ccsversion,[19,cc.boardnum,cc.procnum,0,0]);

% [EOF] symbol.m
