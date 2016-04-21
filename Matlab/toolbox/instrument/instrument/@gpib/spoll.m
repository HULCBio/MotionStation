function out = spoll(obj, val)
%SPOLL Perform serial poll.
%
%   OUT = SPOLL(OBJ) performs a serial poll on the GPIB object, OBJ.
%   OBJ can be an array of GPIB objects. OUT contains the GPIB objects 
%   that are ready for servicing. If no objects are ready for servicing,
%   then OUT is empty.
%
%   If OBJ is an array of GPIB objects, each GPIB object in the array must
%   have the same BoardIndex property value.
%
%   Serial polling is a method for obtaining specific information from 
%   GPIB objects when they request service. When you perform a serial
%   poll, OUT contains the GPIB objects that have asserted their SRQ line.
%
%   OUT = SPOLL(OBJ, VAL) performs a serial poll on the GPIB object, OBJ,
%   and waits until the specified instruments, VAL, have asserted their
%   SRQ line. VAL is a numeric array which contains the indices of the 
%   objects in OBJ which must be ready for servicing before SPOLL returns 
%   control to MATLAB. SPOLL will block for up to the number of seconds 
%   specified by the Timeout property for each OBJ that is specified by
%   VAL.
%
%   An error will be returned if a value specified in VAL does not match
%   an index value in OBJ.
%
%   For example, if OBJ is a four element GPIB array [OBJ1 OBJ2 OBJ3 OBJ4] 
%   and if VAL is set to [1 3], SPOLL will not return until both OBJ1 and 
%   OBJ3 have asserted their SRQ line or until the timeout period, as 
%   specified by the Timeout property, expires. With the same GPIB array, 
%   OBJ, if VAL is set to 5, an error will return since OBJ has a length of 4.
%
%   Example:
%       g1 = gpib('ni', 0, 1);
%       g2 = gpib('ni', 0, 2);
%       fopen([g1 g2]);
%       out1 = spoll(g1);
%       out2 = spoll([g1 g2], 1);
%       out3 = spoll([g1 g2], [1 2])
%       fclose([g1 g2]);
%
%   See also GPIB.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.9.2.3 $  $Date: 2004/01/16 19:58:59 $

% Error if too many output arguments.
if nargout > 2
    error('instrument:spoll:invalidSyntax','Too many output arguments.');
end

% Verify OBJ consists of only gpib objects.
objType = get(obj, {'Type'});
objType = unique(objType);
if ~((length(objType) == 1) && (strcmp(objType, 'gpib')))
	error('instrument:spoll:invalidOBJ', 'OBJ must be a GPIB object or an array of GPIB objects.');
end

% Verify that the objects have the same BoardIndex.
boardIndex = get(obj, {'BoardIndex'});
if length(unique([boardIndex{:}])) ~= 1
    error('instrument:spoll:OBJHaveDifferentBoardIndex','Each object in OBJ must have the same BoardIndex.');
end

% Verify that each object is connected to the hardware.
status = get(obj, {'Status'});
status = unique(status);
if ~((length(status) == 1) && (strcmp(status, 'open')))
    error('instrument:spoll:OBJnotConnected','Each object in OBJ must be connected to the instrument with the FOPEN function.');
end

% wait(i) = 0 indicates no waiting for service
% wait(i) = 1 indicates wait for service
wait = zeros(1,length(obj));
switch (nargin)
case 1
    %wait = zeros(1, length(obj));
case 2
    value = unique(val);
    % Verify that value corresponds to an object in OBJ.
    if max(value) > length(obj)
        error('instrument:spoll:invalidVAL','An index specified in VAL exceeds the size of OBJ.');
    end
    % Indicate which objects should wait for service.
    wait(value)=1;
end

% Get the java objects.
info = struct(obj);
jobject = info.jobject;

% Conduct the serial poll for each object.
line = [];
for i=1:length(jobject),
    try
        line = [line spoll(jobject(i), wait(i))];
    catch
        error('instrument:spoll:opfailed', lasterr);    
    end
end

% Java SPOLL returns:
%   - 2 if object is ready for servicing
%   - 1 if object is not ready for servicing
ind = find(line==2);
if isempty(ind)
    out = [];
else
    out = localIndexOf(obj,{ind});    
end

% *********************************************************************
% Index into an instrument array.
function [result, errflag] = localIndexOf(obj, index1)

% Initialize variables.
errflag = 0;

try
   % Get the field information of the entire object.
   jobj = igetfield(obj, 'jobject');
   type = igetfield(obj, 'type');
   constructor = igetfield(obj, 'constructor');	
   
   if ischar(constructor)
   	   % Ex. obj(1) when obj only contains one element.	
       constructor = {constructor};
   end
   
   % Create the first object and then append the remaining objects.
   if (length([index1{1}]) == 1)
       % This is needed so that the correct classname is assigned
       % to the object.
	   result = feval(constructor{index1{1}(1)}, jobj(index1{:}));
   else
       % The class will be instrument since there are more than 
       % one instrument objects.  
       result = obj;
   	   result = isetfield(result, 'jobject', jobj(index1{:}));
   	   result = isetfield(result, 'type', type(index1{:}));
       result = isetfield(result, 'constructor', constructor(index1{:}));
   end
catch
   lasterr('Index exceeds matrix dimensions.', 'instrument:spoll:exceedsdims');
   result = [];
   errflag = 1;
   return;
end

