function xpcwwwenable
%XPCWWWENABLE Enable the use of the xPC Target WWW Interface.
%
%   XPCWWWENABLE has to be used in the BootFloppy and DOSLoader (Embedded
%   Option) modes to enable access to the target system via the xPC Target WWW
%   Interface. If you are not sure whether or not you have access, you
%   should execute this function.
%
%   The reason this is required is that the target system only maintains
%   one TCP/IP connection, which is used either via MATLAB or by the WWW
%   Interface. Consequently, if the connection is in active use by MATLAB,
%   the Internet Browser will not be able to connect until the previous
%   connection times out. Running XPCWWWENABLE resets the connection and
%   permits a new one to be established.
%
%   To access the target system over the WWW interface, you should use
%   either Microsoft Internet Explorer (version 4.0 or higher) or Netscape
%   Navigator (version 4.5 or higher). Javascript should be enabled for
%   proper functioning of the WWW interface. The URL to connect to is
%
%      http://<target IP address>:<target port>/
%
%   For example, if you have assigned the IP address 192.168.0.1 to the
%   target system, and are using port 22222 (the default), you would point
%   the WWW browser to the URL
%
%      http://192.168.0.1:22222/
%
%   The IP address and Port values are stored in the xPC environment
%   properties TcpIpTargetAddress and TcpIpTargetPort (accessible through
%   the MATLAB commands GETXPCENV.
%
%   See also GETXPCENV.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.4 $ $Date: 2002/03/25 04:23:25 $

if strcmp(xpctargetping,'failed')
    error('Target system not accessible from host: Target may not be accessible by WEB interface');
end

if strcmp(xpcgate('getname'),'loader')
    error('Target system not loaded with an application: Target will not be accessible by WEB interface');
end

xpctargetping;
close(xpc);
