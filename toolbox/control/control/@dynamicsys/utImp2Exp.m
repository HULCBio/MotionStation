function B = utImp2Exp(A,yidx,uidx)
% Metadata management for IMP2EXP

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:12:59 $
L.type = '()';
L.subs = {':' yidx};
tmpout = subsref(A,L);
L.subs = {':' uidx};
tmpin = subsref(A,L);
B = dynamicsys(length(yidx),length(uidx));
B.InputGroup = tmpin.InputGroup;
B.InputName = tmpin.InputName;
B.OutputGroup = tmpout.InputGroup;
B.OutputName = tmpout.InputName;

