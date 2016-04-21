function obj = daqchild
%DAQCHILD Construct daqchild object.
%
%    DAQCHILD is the base class from which aichannel, aochannel
%    and dioline objects are derived from.  It is used to allow these
%    objects to inherit common methods.
%
%    See also AICHANNEL, AOCHANNEL, DIOLINE.
%

%    MP 3-25-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.9.2.4 $  $Date: 2003/08/29 04:40:09 $

% Create an empty dummy object
obj.store={};
obj=class(obj,'daqchild');