function sample=getsample(obj)
%GETSAMPLE Immediately acquire single sample.
%
%    OUT = GETSAMPLE(OBJ) returns a row vector, OUT, containing one 
%    immediate sample of data from each channel contained by the 
%    1-by-1 analog input object, OBJ.  The samples returned are not 
%    removed from the data acquisition engine.
%
%    GETSAMPLE is valid for analog input processes only and can be
%    called when OBJ is not running.
% 
%    GETSAMPLE can be used with sound cards and Agilent Technologies hardware
%    only if the object, OBJ, is running.
%
%    See also DAQHELP, PEEKDATA, GETDATA.
%

%    CP 4-10-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.11.2.4 $  $Date: 2003/08/29 04:40:21 $

error('daq:getsample:invalidtype', 'Wrong object type passed to GETSAMPLE.  Use the object''s parent.');
