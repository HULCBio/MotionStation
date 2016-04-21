function initialize(c, coutlineHandle)
%INITIALIZE initializes persistent data

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:19 $

%note that this sets the 'initialized' bit on

d=rgstoredata(c, '', 'initialize' );
d.initialized=logical(1);
rgstoredata(c,d,'set');
