function sys=targetsys(m);
%TARGETSYS returns currently looped system

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:55 $

sys=subsref(zslmethods,struct('type','.','subs','System'));