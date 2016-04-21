function obj = aochannel(h)
%AOCHANNEL Construct analog output channel.
%
%    To create channels, ADDCHANNEL must be used.  If OBJ is an analog
%    output object, then the following will create two channels assigned
%    to hardware channel IDs [1 2]:
%
%       addchannel(OBJ, [1 2])
%
%    See also DAQHELP, ADDCHANNEL.
%

%    CP 4-10-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.10.2.5 $  $Date: 2003/12/04 18:38:29 $

%   OBJ = AOCHANNEL(H) returns an AOchannel object OBJ when
%   passed a numerical handle H.  This constructor is intended
%   to be used by DAQMEX only.
%
%   Object fields
%      .handle     - hidden unique handle from DAQMEX associated with the
%                    channel.
%      .version    - class version number.

nargs = nargin;
if nargs==0 
   error('daq:aochannel:argcheck', 'To create additional channels, use ADDCHANNEL.\nFor help type ''daqhelp addchannel''.')
elseif nargs~=1,
   error('daq:aochannel:argcheck', 'Too many input arguments.')
end

tlbx_version=1.0;

if ~isa(h,'int32'), 
   error('daq:aochannel:argcheck', 'To create additional channels, use ADDCHANNEL.\nFor help type ''daqhelp addchannel''.')
end

%  DAQMEX is calling the constructor and is passing the numerical handle H.
%  Create the object with a DAQCHILD parent and pass it back to DAQMEX.
daqc = daqchild;
obj.handle=h;
obj.version = tlbx_version;
obj = class(obj, 'aochannel', daqc);