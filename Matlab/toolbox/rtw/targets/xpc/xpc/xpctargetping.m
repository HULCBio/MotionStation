function result = xpctargetping(varargin)
% XPCTARGETPING - xPC target ping
%
%   XPCTARGETPING ping's the actual xPC target computer and returns either
%   'success' or 'failed'. This primary function can be used to check the
%   proper communication between host and target computer. xpctargetping
%   works for both RS232 and TCP/IP communication. xpctargetping returns
%   'success', only if the xPC Target kernel is loaded and is running and
%   the communication is working properly.
%
%   XPCTARGETPING may be called with 0 arguments, to use the default
%   target, or in one of the two forms:
%
%     XPCTARGETPING('RS232', 'COM1', BAUDRATE)
%
%     XPCTARGETPING('TCPIP', 'IPADDRESS', 'IPPORT')

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.5.2.3 $ $Date: 2004/04/08 21:05:17 $

if nargin
  error(nargchk(3, 3, nargin));
else
    if ~exist(xpcenvdata)
         result='failed';
         disp('xPC Target environment is not initialized.');
        return;
    end
end

tg = xpc(varargin{:});
result = tg.targetping;
