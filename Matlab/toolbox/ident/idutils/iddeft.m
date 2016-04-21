function [Tf,Ts] = iddeft(sys,T2)
%IDDEFT Sets default time scales.
%
%   [Tf,Ts] = IDDEFT(SYS);
%
%   SYS: Any Idmodel or LTI model.
%   Tf: A suitable final time for impulse and step responses.
%   Ts: A suitable samling time if SYS is continuous time
%   [Tf,Ts] = IDDEFT(SYS,T) takes a final simulation time T into
%   account when selecting Ts.

%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.2.4.1 $  $Date: 2004/04/10 23:18:33 $

if nargin<2
    T2 = [];
end
Ts1 = pvget(sys,'Ts');
[a,b,c,d] = ssdata(sys);
if Ts1
    np = dtimscale(a,[],c,d,b,Ts1);
    Tf = np*Ts1;
else
    [dum,Tf] = timscale(a,[],c,b,[]);
end

%[a,b,c]=ssdata(sys1);
if nargout > 1
    Ts = timscale(a,[],c,b,T2);
end