function mm = convert(mm,datatype,siz)
%CONVERT  Configures properties for predefined target data types
%   CONVERT(MM,TYPE) - Defines the numeric representation to be
%   applied to the register object MM.  The TYPE input defines 
%   some common data types.  This method adjusts the properties
%   of MM object to match the specified TYPE.  As a result,
%   future READ/WRITE operations will apply the appropriate
%   data conversion to implement the numeric representation.
%   For uncommon datatypes, it is possible to directly modify
%   the MM properties, but generally it is better to use the CONVERT
%   method.
% 
%   CONVERT(MM,TYPE,SIZE) - Does an additional reshaping - adjusts the 
%   'size' property - of the MM object.
%
%   Note: SIZE is always 1 for bit fields.
%
%   See also CAST, COPY.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.8.6.2 $ $Date: 2003/11/30 23:06:25 $

error(nargchk(2,3,nargin));
if ~ishandle(mm),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a BITFIELD Handle.');
end
if ~ischar(datatype),
     error(generateccsmsgid('InvalidInput'),'Second Parameter must be a string.');
end
if nargin==3
	if ~isnumeric(siz),
         error('Third Parameter must be numeric.');
    else
        if isempty(siz),
            siz = mm.size;
        elseif any(siz<1)==1 || prod(siz)~=1,
            error(['Invalid bit field size [' num2str(siz) '], size must always be equivalent to 1. ']);
        else
            siz = 1;
        end
    end    
end

% Change to specified datatype
mm.prepad  = 0;  % Modified later, if necessary
mm.postpad = 0;

switch datatype
    
case {'int', 'signed int'} 
    if any(strcmp(mm.procsubfamily,{'C6x','R1x','R2x'})), % C6000, Rxx
        totalbits  = 32;
    elseif any(strcmp(mm.procsubfamily,{'C54x','C55x','C28x'})), % C5000, C2800
        totalbits  = 16;        
    end
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'signed';
    
case 'unsigned int',
    if any(strcmp(mm.procsubfamily,{'C6x','R1x','R2x'})), % C6x, Rxx
        totalbits  = 32;
    elseif any(strcmp(mm.procsubfamily,{'C54x','C55x','C28x'})), % C5000, C2800
        totalbits  = 16;
    end
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'unsigned';
    
otherwise,
    error(generateccsmsgid('DataTypeNotSupported'),['Type ''' datatype ''' is not supported. ANSI C specifies that bit fields must be of type int or unsigned int. ']);
    
end

% reshape size (to 1)
if nargin==3, 
    set(mm,'size',siz); 
end  

% [EOF] convert.m