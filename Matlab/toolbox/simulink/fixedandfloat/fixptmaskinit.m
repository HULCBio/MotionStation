%FIXPTMASKINIT may be called by Fixed-Point Blocks with broken links.
%    
% 	FIXPTMASKINIT is a private function used by previous versions of 
%   Fixed-Point Blockset.  If it is being called, the likely cause is that
%   links to Fixed-Point blocks were broken.  These links need to be restored
%   for the model to work properly.  This can be done automatically using
%   FIXPT_RESTORE_LINKS.
%
%    See also FIXPT_RESTORE_LINKS.

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.18 $  
% $Date: 2002/04/10 18:59:23 $

dispstr = sprintf('ERROR\nBROKEN\nLINK');

xFixptSymbol = [];
yFixptSymbol = [];

error([ sprintf( [ '\n'...
        'An obsolete function from the Fixed-Point Blockset has been called.\n' ...
        'A Fixed-Point Block with a broken link is the likely cause.  See\n' ...
        'FIXPT_RESTORE_LINKS for information on restoring the link.\n' ...
        'The current block is\n']) gcb ]);