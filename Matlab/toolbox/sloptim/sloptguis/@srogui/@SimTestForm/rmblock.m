function rmblock(this,blk)
% Deletes constraint associated with given Simulink block.

%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:45:14 $
%   Copyright 1986-2004 The MathWorks, Inc.
C = findspec(this,get_param(blk,'LogID'));
this.Specs(this.Specs==C,:) = [];
