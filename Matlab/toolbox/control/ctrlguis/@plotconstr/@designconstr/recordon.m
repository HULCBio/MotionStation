function T = recordon(Constr)
%RECORDON  Starts recording Edit Constraint transaction.

%   Authors: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $ $Date: 2002/04/10 05:12:31 $

T = ctrluis.transaction(Constr,'Name','Edit Constraint',...
    'OperationStore','on','InverseOperationStore','on');

