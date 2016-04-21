function obj = aichannel(h)
%AICHANNEL Construct analog input channel.
%
%    To create channels, ADDCHANNEL must be used.  If OBJ is an analog
%    input object, then the following command will create two channels
%    assigned to hardware channel IDs [1 2]:
%
%       addchannel(OBJ, [1 2])
%
%    See also DAQHELP, ADDCHANNEL.
%

%    CP 3-26-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.10.2.5 $  $Date: 2003/12/04 18:38:23 $

%   OBJ = AICHANNEL(H) returns an AIchannel object OBJ when
%   passed a numerical handle H.  This constructor is intended
%   to be used by DAQMEX only.
%
%   Object fields
%      .handle     - hidden unique handle from DAQMEX associated with the
%                    channel.
%      .version    - class version number.

nargs = nargin;
if nargs==0 
   error('daq:aichannel:argcheck', 'To create additional channels, use ADDCHANNEL.\nFor help type ''daqhelp addchannel''.');
elseif nargs~=1,
   error('daq:aichannel:argcheck', 'Too many input arguments.')
end

tlbx_version=1.0;

if ~isa(h,'int32') 
   error('daq:aichannel:argcheck', 'To create additional channels, use ADDCHANNEL.\nFor help type ''daqhelp addchannel''.');
end

%  DAQMEX is calling the constructor and is passing the numerical handle H.
%  Create the object with a DAQCHILD parent and pass it back to DAQMEX.
obj.handle = h;
obj.version = tlbx_version;

daqc = daqchild;
obj = class(obj, 'aichannel', daqc);