function resp = read_rnumeric(rn,index,timeout)
%READ_NUMERIC Pivate. Retrieves memory area and converts into a numeric array
%  DN = READ_NUMERIC(NN)
%  DN = READ_NUMERIC(NN,[],TIMEOUT) - reads all data from the specified memory 
%  area and converts it into a numeric representation.  Numeric conversion is 
%  controlled by the properties of the NN object.  The output 'DN' will be a 
%  numeric array that has dimensions defined by NN.SIZE, which is the dimensions 
%  array. Each element in the dimensions array contains the size of the array in 
%  that dimension.  If SIZE is a scalar, the output is a column vector of the specified 
%  length. 
%
%  DN = READ_NUMERIC(NN,INDEX)
%  DN = READ_NUMERIC(NN,INDEX,TIMEOUT) - read a subset of the numeric values from
%  the specified numeric array.  Each row of INDEX is applied as a subscript into the 
%  full NN array.  The output DN will be a column vector with one value per entry in the
%  INDEX.  Arrays indices start at 1 and range up the maximum value defined by SIZE.
%  If INDEX is a vector, each row is an single index  that defines one entry
%  from the defined numeric array.  The output DN will be a column vector of values
%  corresponding to the specified indices.   A new TIMEOUT value can be
%  explicitly passed to temporarily modify the default timeout property of the rn object.  
%
% Array properties
% NN.SIZE - Dimensions of output numeric array.  This defines the size of 'DN'
% NN.ARRAYORDER - Defines how sequential memory locations are mapped into matrices.
%   The default is 'col-major', which is the arrangment used by MATLAB.  Alternatively,
%   use 'row-major', which is the memory organization applied in C.
% Numeric representation 
%  NN.REPRESENT - Numeric representation
%    'float' - IEEE floating pointer representation (32 or 64 bits)
%    'signed' - 2's Compliment signed integers
%    'unsigned'- Unsigned binary integer
%    'fract' - Fractional fixed-point, see rn.p
%  NN.WORDSIZE - Number of valid bits in numeric representation.  This
%   property is computed from other properties such as 'storageunitspervalue' and therefore
%   read-only
%  NN.BINARYPT
%  Other properties of NN control the placement and arrangement of
%  the numeric values in memory.
%
%  Changes to the numeric representation are possible by modifying the
%  class properties.  However, the CONVERT method implements the adjusting
%  the properties to implement some common data types.
%
%   See also READ, WRITE, CONVERT, INT32.

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.14.6.3 $  $Date: 2003/11/30 23:11:42 $

error(nargchk(1,3,nargin));
if ~ishandle(rn),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a NUMERIC Handle.');
end
 
% Call base class (registerobj) to get unformatted data
if nargin == 1,
    uidata  = read_registerobj(rn);
    uidata  = reshape(uidata,rn.storageunitspervalue,[]);
    nvalues = prod(rn.size);
elseif nargin == 3 && isempty(index),
    uidata  = read_registerobj(rn,[],timeout);
    uidata  = reshape(uidata,rn.storageunitspervalue,[]);
    nvalues = prod(rn.size);
elseif nargin >= 2,
    % Re-arrange data as described by object
    if nargin == 2,         dtimeout = rn.timeout;
    else                    dtimeout = timeout;
    end
    index    = p_checkerforindex(rn,index);
    index    = p_index2count(rn,index);
    uidata   = read_registerobj(rn,index,dtimeout);
    uidata   = reshape(uidata,rn.storageunitspervalue,[]);
    nvalues  = size(uidata);
    nvalues  = nvalues(2);
end

% Endianness swap (not - necessary)    

% Trim pre/post bytes (if necessary)
% For now, limited to increments of bitsperstorageunit
uidata = ApplyPadding(rn,uidata);

% Convert adjusted array of 'valid' au into numeric values
switch (rn.represent), 
case {'fract','signed'}
    validaus  = size(uidata);  % Not storageunitspervalue (padding!!)
    validaus  = validaus(1);    
    conversion_method = 1;
    % Get scale factor
	if any(strcmp(rn.procsubfamily,{'R1x','R2x','C6x'})) %Rxx,C6x
        maxposbit = 2^(rn.wordsize-1)-1; 
        maxpos    = 2^(rn.wordsize)-1;
		scale     = 2.^(0:rn.wordsize:rn.wordsize*validaus-1)';
        [maxposbit,maxpos,scale,conversion_method] = ...
            C6xSigned_SpecialCase(rn,validaus,maxposbit,maxpos,scale,conversion_method);
	elseif any(strcmp(rn.procsubfamily,{'C54x','C55x','C28x'})), 
        maxposbit = 2^(rn.bitsperstorageunit-1)-1; 
        maxpos    = 2^(rn.bitsperstorageunit)-1;
		scale     = 2.^(0:rn.bitsperstorageunit:rn.bitsperstorageunit*validaus-1)';
        [maxposbit,maxpos,scale,conversion_method] = ...
            C54xSigned_SpecialCase(rn,validaus,maxposbit,maxpos,scale,conversion_method);        
    end
    % Convert to (final) signed integer
    if conversion_method==1,    
        fdata = ConvertRaw2SingedInt_m1(uidata,nvalues,validaus,maxposbit,maxpos,scale);
    else                        
        fdata = ConvertRaw2SingedInt_m2(uidata,nvalues,validaus,maxposbit,maxpos,scale);
    end
    % If fractional, adjust the binary point
    fdata = AdjustBinaryPoint(fdata,rn.represent,rn.binarypt);
    
case {'ufract','unsigned'}
    validaus = size(uidata);  % Not storageunitspervalue (padding!!)
    validaus = validaus(1);
    % Convert to (final) unsigned integer
    fdata = ConvertRaw2UnsingedInt(rn,uidata,validaus,nvalues);
    % If fractional, adjust the binary point
    fdata = AdjustBinaryPoint(fdata,rn.represent,rn.binarypt);
    
case 'float', 
    fdata = ConvertRaw2IeeeFloatingPt(rn,nvalues);
    
otherwise  
    error(generateccsmsgid('UnknownRepresentation'),['Unexpected numeric representation: ''' rn.represent]);
end

% Reshape data such that its consistent with the array-order property
if length(rn.size) > 1 & ((nargin == 1) | (nargin == 3 & isempty(index))),  % Non-indexed
    if strcmp(rn.arrayorder,'row-major'),
       rowmajdim = [rn.size(2) rn.size(1) rn.size(3:end)];
       resp = permute(reshape(fdata,rowmajdim),[2 1]);
    else
       resp = reshape(fdata,rn.size);
    end
else   % Indexed - Don't bother try to shape it
    resp = fdata;
end

%----------------------------------------
function fdata = ConvertRaw2SingedInt_General(uidata,nvalues,validaus,maxposbit,maxpos,scale)
% A more general way of converting any type of Signed int but slow.
% See specific implementation
len = length(maxpos);
for iv=1:nvalues, % do for all elements (registers are always one-element)
   uival = double(uidata(:,iv))';
   if uival(validaus) > maxposbit,  % Negative number
       if len==1,
           uival = maxpos-uival;
       else  % special cases, code below is more general but slow
           for j=1:len-1
              uival(j) = maxpos(1)-uival(j);
           end
           uival(len) = maxpos(2)-uival(len);
       end
       fdata(iv) = uival*scale;
       fdata(iv) = -1*(fdata(iv)+1);
   else % Positive number
      fdata(iv) = uival*scale;
   end 
end 
%--------------------------------------------------
function fdata = ConvertRaw2SingedInt_m1(uidata,nvalues,validaus,maxposbit,maxpos,scale)
% Very specific implementation of ConvertRaw2SingedInt_General for
% symbols with wordsize<=32
iv = 1;
uival = double(uidata(:,iv))';
if uival(validaus) > maxposbit,  % Negative
   uival     = maxpos-uival;
   fdata(iv) = uival*scale;
   fdata(iv) = -1*(fdata(iv)+1);
else % Positive 
  fdata(iv) = uival*scale;
end 

%----------------------------------------
function fdata = ConvertRaw2SingedInt_m2(uidata,nvalues,validaus,maxposbit,maxpos,scale)
% Very specific implementation of ConvertRaw2SingedInt_General for
% symbols with wordsize>32
iv = 1;
uival = double(uidata(:,iv))';
if uival(validaus) > maxposbit,  % Negative
   uival(1)  = maxpos(1)-uival(1); 
   uival(2)  = maxpos(2)-uival(2); 
   fdata(iv) = uival*scale;
   fdata(iv) = -1*(fdata(iv)+1);
else % Positive 
  fdata(iv) = uival*scale;
end 
%--------------------------------------
function [maxposbit,maxpos,scale,conversion_method] = C6xSigned_SpecialCase(rn,validaus,maxposbit,maxpos,scale,conversion_method)
if ~(rn.wordsize>rn.bitsperstorageunit),    return;     end;
% Condition created especially for for signed integers with wordsize > 32
if rn.wordsize==64, % 'int64'
    maxposbit = 2^(rn.bitsperstorageunit-1)-1; 
    maxpos    = 2^(rn.bitsperstorageunit)-1;
	scale     = 2.^(0:rn.bitsperstorageunit:rn.bitsperstorageunit*validaus-1)';
else % 'long','signed long'
    maxposbit = 2^(rn.wordsize-rn.bitsperstorageunit-1)-1; 
    maxpos    = [2^(rn.bitsperstorageunit)-1,2^(rn.wordsize-rn.bitsperstorageunit)-1]; % max positive number for[all-low-storageunits, highest-storageunit (padding taken into account)]
	scale     = 2.^(0:rn.bitsperstorageunit:rn.bitsperstorageunit*validaus-1)';
    conversion_method = 2;
end
%--------------------------------------
function [maxposbit,maxpos,scale,conversion_method] = C54xSigned_SpecialCase(rn,validaus,maxposbit,maxpos,scale,conversion_method)
if rn.postpad==0,     return;   end;
% Condition created especially for for int8 where postpad is 8
maxposbit = 2^(rn.wordsize-1)-1; 
maxpos    = 2^(rn.wordsize)-1;
scale     = 2.^(0:rn.wordsize:rn.wordsize*validaus-1)';
%------------------------------
function fdata = AdjustBinaryPoint(fdata,represent,binarypt)
if strcmp(represent,'fract') | strcmp(represent,'ufract'),
    fdata = fdata./ 2^(binarypt);
end 
%------------------------------
function fdata = ConvertRaw2UnsingedInt(rn,uidata,validaus,nvalues)
% Get scale factor
if any(strcmp(rn.procsubfamily,{'R1x','R2x','C6x'})), %Rxx,C6x
    scale = 2.^(0:rn.wordsize:rn.wordsize*validaus-1)';
elseif any(strcmp(rn.procsubfamily,{'C54x','C55x','C28x'})),
    scale = 2.^(0:rn.bitsperstorageunit:rn.bitsperstorageunit*validaus-1)';
end
% Convert to (final) unsigned integer
iv = 1;  % set iv=1 since array of registers are not allowed
% for iv=1:nvalues,
uival = double(uidata(:,iv))';
fdata(iv) = uival*scale;
% end
%-------------------------------
function fdata = ConvertRaw2IeeeFloatingPt(rn,nvalues)
if rn.wordsize == 32, % Single
    bidata = readbin(rn);
    for iv = 1:nvalues,        
        fdata(iv) = bin2float(rn,'single', bidata{iv});
    end
elseif rn.wordsize == 64, % Double 
    bidata = rn.readbin;
    for iv = 1:nvalues,
        fdata(iv) = bin2float(rn,'double',bidata{iv});
    end
else 
    error(generateccsmsgid('InvalidFloatSize'),'Floating point data type limited to 32 and 64 bits on this platform!');
end

%-------------------------------------------
function uidata = ApplyPadding(rn,uidata)
if rn.prepad > 0 |  rn.postpad > 0,
    if rn.prepad + rn.postpad > rn.storageunitspervalue * rn.bitsperstorageunit,
        error(generateccsmsgid('InvalidPrePostPadValue'),' Pre/Post padding exceeds available memory area');
    end    
    % prepad
    uidata(1) = bitshift(uidata(1),-1 * rn.prepad,rn.bitsperstorageunit);
    % postpad
    uidata(end) = bitand( uidata(end),bitshift(2^rn.bitsperstorageunit-1,-rn.postpad,rn.bitsperstorageunit) );
end 
%-------------------------------------------
function uidata = ApplyEndianness(rn,uidata)
if ~strcmp( rn.endianness,'little') & (rn.storageunitspervalue > 1),
    uidata = flipud(uidata);
end

% [EOF] read_rnumeric.m