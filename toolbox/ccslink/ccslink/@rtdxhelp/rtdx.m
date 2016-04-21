function h = rtdx(bpnum,apiversion)
%RTDX Construct RTDX(tm) (Real-Time Data Exchange) object.
%   R = RTDX(DSPTASK) returns a handle to an RTDX object constructed 
%   by inheriting the Code Composer Studio(R) (CCS) API class 'DspTask' 
%   defined in the CCSDSP object.  The handle to 'DspTask' interface is 
%   traversed to get the 'Rtdx' class interface.  'Rtdx' handle is used to get 
%   handles to 'RtdxChannel' interfaces by the OPEN method.  This constructor 
%   defines the object properties data structure to store RTDX and RTDX channel
%   handles and other identifying attributes.
%   
%   BPNUM - 2 element Vector of board
%
%   Public read-only properties (use GET):
%   
%   .numChannels       number of open RTDX channels
%   .RtdxChannel{i,1}  channel name of i-th channel, 1 <= i <= numChannels
%   .RtdxChannel{i,3}  read/write mode ('w'/'r') of i-th channel
%   .procType          integer specifying DSP type (e.g., C62, C67, C54)
%
%   Public read/write properties (use GET/SET):
%
%   .timeOut           global time out value in seconds used for RTDX accesses
%
%   Private properties (no direct access to users):
%
%   .Rtdx              handle to ActiveX RtdxChannel sub-class
%   .RtdxChannel{i,2}  interface handle to i-th channel
%
%   Accesses to Texas Instruments(tm) (TI) CCS and target TI DSPs via RTDX are 
%   initiated by the instantiation of MATLAB objects of class CCSDSP and RTDX.  
%   Once the objects are constructed, various remote automation tasks may be 
%   performed by calling predefined object methods, which get, manage, and 
%   release necessary CCS API interfaces through Windows ActiveX.  The list of 
%   supported methods can be displayed typing "help rtdx" at the MATLAB command
%   command line.
%
%   See also @CCSDSP/CCSDSP

% Copyright 2004 The MathWorks, Inc.
