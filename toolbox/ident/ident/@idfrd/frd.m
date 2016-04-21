function f = frd(ifr)
%FRD  convert model objects to an LTI/FRD object
%   Requires the Control Systems Toolbox
%   SYS = FRD(MF)
%
%   MF is an IDFRD model, obtained for example by SPA, ETFE or IDFRD.
%   
%   If MF is an IDMODEL object it is first converted to IDFRD. Then the
%   syntax  
%   SYS = FRD(MF,W)
%   allows the frequency vector W also to be defined. If W is omitted a
%   default choice is made.
%
%   SYS is returned as an FRD object.
%
%   Covariance information and spectrum information is not translated.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2001/04/06 14:22:05 $

if ~exist('frd')
   error('This routine required the Control Systems Toolbox.')
end

nu = size(ifr,'Nu');
if nu == 0
   error('FRD cannot describe time series.')
end

 f = frd(ifr.ResponseData,ifr.Frequency,ifr.Ts,'InputDelay',ifr.InputDelay,...
    'Units',ifr.Units,'InputName',ifr.InputName,'OutputName',ifr.OutputName,...
 'Notes',ifr.Notes,'Ts',ifr.Ts);
 
