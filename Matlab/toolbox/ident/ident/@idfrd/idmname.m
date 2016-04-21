function idm = idmname(idm,data)
%IDMNAME  Sets Names in IDFRD inherited from an IDDATA objects

%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/10 23:16:49 $

idm.OutputName = pvget(data,'OutputName');
idm.InputName =  pvget(data,'InputName');
idm.InputUnit =  pvget(data,'InputUnit');
idm.OutputUnit = pvget(data,'OutputUnit');
%idm.TimeUnit = pvget(data,'TimeUnit');
 