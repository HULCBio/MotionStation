function h = rtdx(varargin)
%RTDX - Base constructor for the 'Link for RTDX(tm) Interface'
%  Description of methods available for RTDX Object
%  ---------------------------------------------------------------------
%  CLOSE      Close RDTX channels to the target DSP
%  CONFIGURE  Define the size and number of RDTX channel buffers
%  DISABLE    Disable RDTX interface, or specified channels 
%  DISPLAY    Display RTDX object properties
%  ENABLE     Enable RDTX interface, or specified channels
%  FLUSH      Flush (delete) data in an RDTX channel
%  INFO       Return a list of open RTDX channel names
%  ISENABLED  Query if RTDX interface or RTDX channel is enabled
%  ISREADABLE Query if an RDTX channel is available for reading
%  ISWRITABLE Query if an RDTX channel is available for writing
%  MSGCOUNT   Get number of messages in specified channel queue
%  OPEN       Open RDTX channels to the target DSP
%  READMAT    Read a matrix of data from an RDTX channel
%  READMSG    Read data messages from an RDTX channel
%  REFRESH    Reopens all defined RTDX channels
%  RTDX       Construct RTDX (Real-Time Data Exchange) object
%  WRITEMSG   Write data values to an RTDX channel
%
%  For more information on a given method, use the following syntax:
%  >help rtdxhelp/(method)
%
%  See also GET, SET, CCSDSP.

% $RCSfile: rtdx.m,v $
% $Revision: 1.8.4.2 $ $Date: 2004/04/08 20:47:29 $
% Copyright 2000-2003 The MathWorks, Inc.

h = ccs.rtdx(varargin{:});

