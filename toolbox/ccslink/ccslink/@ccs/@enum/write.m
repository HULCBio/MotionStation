function resp = write(en,index,data)
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2003/11/30 23:08:09 $

error(nargchk(2,3,nargin));
if ~ishandle(en),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be an ENUM Handle.');
end
if nargin==2,   
    data = index;
elseif nargin==3 & isempty(index)
    index = 1;
end

if ischar(data) || iscellstr(data),  
    if nargin==2,   write_enum(en,data);
    else            write_enum(en,index,data);
    end
elseif isnumeric(data),
    CheckIfValid(en.value,data);
    if nargin==2,   write_numeric(en,data);
    else            write_numeric(en,index,data);
    end
else    
    error(generateccsmsgid('InvalidInput'),'Second Parameter must be a numeric or string (enum label)');
end

%-----------------------------
function CheckIfValid(value,data)
siz = size(data);
chk = zeros(siz);
for i=1:length(value)
    chk = chk + (data==value(i));
end
if sumall(chk,length(siz))~=prod(siz)
    warning(generateccsmsgid('UndefinedInputData'),'Input data contains at least one value that does not match any defined enumerated value.');
end

%----------------------------------
function o = sumall(o,dims)
for i=1:dims
    o = sum(o,i);
end

% WRITE.M