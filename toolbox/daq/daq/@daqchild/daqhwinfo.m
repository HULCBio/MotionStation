function out = daqhwinfo(obj)
%DAQHWINFO Return information on the available hardware.
%
%    OUT = DAQHWINFO returns a structure, OUT, which contains data acquisition
%    hardware information.  This information includes the toolbox version,
%    MATLAB version and installed adaptors.
%
%    OUT = DAQHWINFO('ADAPTOR') returns a structure, OUT, which contains 
%    information related to the specified adaptor, ADAPTOR.
%
%    OUT = DAQHWINFO('ADAPTOR','Property') returns the adaptor information for
%    the specified property, Property. Property must be a single string. OUT is
%    a cell array.
%
%    OUT = DAQHWINFO(OBJ) where OBJ is any data acquisition device object, 
%    returns a structure, OUT, containing hardware information such as adaptor, 
%    board information and subsystem type along with details on the hardware
%    configuration limits and number of channels/lines.  If OBJ is an array 
%    of device objects then OUT is a 1-by-N cell array of structures where 
%    N is the length of OBJ.   
%
%    OUT = DAQHWINFO(OBJ, 'Property') returns the hardware information for the 
%    specified property, Property.  Property can be a single string or a cell
%    array of strings.  OUT is a M-by-N cell array where M is the length of OBJ 
%    and N is the length of 'Property'.
%
%    Example:
%      out = daqhwinfo
%      out = daqhwinfo('winsound')
%      ai  = analoginput('winsound');
%      out = daqhwinfo(ai)
%      out = daqhwinfo(ai, 'SingleEndedIDs')
%      out = daqhwinfo(ai, {'SingleEndedIDs', 'TotalChannels'})
%
%    See also DAQHELP.
%

%    MP 4-16-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.12.2.4 $  $Date: 2003/08/29 04:40:11 $

ArgChkMsg = nargchk(0,1,nargin);
if ~isempty(ArgChkMsg)
    error('daq:daqhwinfo:argcheck', ArgChkMsg);
end

if nargout > 1
   error('daq:daqhwinfo:argcheck', 'Too many output arguments.')
end

error('daq:daqhwinfo:invalidtype', 'Wrong object type passed to DAQHWINFO. Use the object''s parent.');
