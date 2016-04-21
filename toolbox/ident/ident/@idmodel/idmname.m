function idm = idmname(idm,data)
%IDMNAME  Sets Names in IDMODEL inherited from an IDDATA objects

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2001/04/06 14:22:12 $

idm.OutputName = pvget(data,'OutputName');
idm.InputName =  pvget(data,'InputName');
idm.InputUnit =  pvget(data,'InputUnit');
idm.OutputUnit = pvget(data,'OutputUnit');
idm.TimeUnit = pvget(data,'TimeUnit');
 