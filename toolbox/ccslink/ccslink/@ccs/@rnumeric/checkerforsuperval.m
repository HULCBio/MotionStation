function sv = checkerforsuperval(nn,usersSV)
% CHECKERFORSUPERVAL - private function to verify operations on property STORAGEUNITSPERVALUE
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.8.6.2 $  $Date: 2003/11/30 23:11:23 $

if strcmp(nn.procsubfamily,'C6x')
    totalBytes = round((usersSV  * nn.bitsperstorageunit)/32);
    if totalBytes > 2,
        error('C6x Register bit sizes are limited to increments of 32 (32,64,...)');
        return;
    end
elseif strcmp(nn.procsubfamily,'C54x') 
    totalBytes = round((usersSV  * nn.bitsperstorageunit)/16);    
    if totalBytes > 2,
        error('C54x Register bit sizes are limited to increments of 16 (16,32,...)');
        return;
    end
elseif strcmp(nn.procsubfamily,'C55x') 
    totalBytes = round((usersSV  * nn.bitsperstorageunit)/16);    
    if totalBytes > 4,
        error('C55x Register bit sizes are limited to increments of 16 (16,32,...)');
        return;
    end
elseif strcmp(nn.procsubfamily,'C28x') 
    totalBytes = round((usersSV  * nn.bitsperstorageunit)/16);    
    if totalBytes > 2,
        error('C28x Register bit sizes are limited to increments of 16 (16,32,...)');
        return;
    end
elseif any(strcmp(nn.procsubfamily,{'R1x','R2x'})), 
    totalBytes = round((usersSV  * nn.bitsperstorageunit)/32);
    if totalBytes > 2,
        error('Rxx Register bit sizes are limited to increments of 32 (32,64,...)');
        return;
    end
end

if totalBytes < 1,
    error('Numeric bit sizes are limited to byte increments (8,16,24,etc)');
    return;
end

sv = round(usersSV);
nn.wordsize = (sv  * nn.bitsperstorageunit) - nn.postpad - nn.prepad;
nn.numberofstorageunits = sv*prod(nn.size);
% If C5500, do not allow changes in 'numberofstorageunits','regname',...
if ~strcmp(nn.procsubfamily,'C55x')
    regnamelookup(nn,usersSV);
end

%----------------------------------------------
function dummy = regnamelookup(nn,usersSV)

len = length(nn.regname);
if len==0
elseif len>0 & usersSV<len
    nn.regname = nn.regname{1:usersSV};
    if usersSV==1,
        nn.regname = { nn.regname };
    end
elseif usersSV>len
    regnamelist = p_registerlist(nn);
    i = strmatch(nn.regname{end},regnamelist,'exact');
    nn.regname = horzcat(nn.regname,{regnamelist{i+1:i+usersSV-len}});
end