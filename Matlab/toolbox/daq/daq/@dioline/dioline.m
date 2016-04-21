function obj = dioline(h)
%DIOLINE Construct digital io line.
%
%    To create lines, ADDLINE must be used.  If OBJ is a digital io
%    object, then the following command will create two input lines 
%    assigned to port 0 and hardware line IDs [0 1]:
%
%       addline(obj, 0:1, 0, 'in')
%
%    See also DAQHELP, ADDLINE.
%

%    CP 4-10-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.11.2.5 $  $Date: 2003/12/04 18:38:34 $

%    OBJ = DIOLINE(H) returns an DIOline object OBJ when
%    passed a numerical handle H.  This constructor is intended
%    to be used by DAQMEX only.
%
%    Object fields
%       .handle     - hidden unique handle from DAQMEX associated with the
%                     line.
%       .version    - class version number.

nargs = nargin;
if nargs==0 
   error('daq:dioline:argcheck', 'To create additional lines, use ADDLINE.\nFor help type ''daqhelp addline''.')
elseif nargs~=1,
   error('daq:dioline:argcheck', 'Too many input arguments.')
end

tlbx_version=1.0;

if ~isa(h,'int32')
   error('daq:dioline:argcheck', 'To create additional lines, use ADDLINE.\nFor help type ''daqhelp addline''.')
end

%  DAQMEX is calling the constructor and is passing the numerical handle H.
%  Create the object with a DAQCHILD parent and pass it back to DAQMEX.
obj.handle=h;
obj.version = tlbx_version;

daqc = daqchild;
obj = class(obj, 'dioline', daqc);