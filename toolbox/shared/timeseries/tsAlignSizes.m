function [data1out,data2out,s1,s2] = tsAlignSizes(data1,gridfirst1,data2,gridfirst2)

% Copyright 2004 The MathWorks, Inc.

% If the time vector is aligned to differing dimensions, a 'transpose' is
% perfomed so that both time vectors are aligned to the first dimension.
% s1 and s2 are the sizes of the output arrays.

if gridfirst1 == gridfirst1
    data1out = data1;
    data2out = data2;
elseif ~gridfirst1 % Force all data to have time vector gridfirst
    try
       data1out = permute(data1,[ndims(data1) 2:ndims(data1)]);
    catch
        try
            data1out = permute(double(data1),[ndims(data1) 2:ndims(data1)]);
        catch
            errstr = sprintf('%s\n%s','Permute failed for this type of ordinate data object.', ...
                 'Try implementing a double cast method or overloaded addition for this object');
            error('tsAlignSizes:badcast',errstr)
        end
    end
elseif ~gridfirst2 % Force all data to have time vector gridfirst
    try
       data2out = permute(data2,[ndims(data2) 2:ndims(data2)]);
    catch
       try
           data2out = permute(double(data2),[ndims(data2) 2:ndims(data2)]);
       catch
           errstr = sprintf('%s\n%s','Permute failed for this type of ordinate data object.', ...
                'Try implementing a double cast method or overloaded addition for this object');
           error('tsAlignSizes:badcast',errstr)
       end
    end
end
s1 = hdsGetSize(data1);
s2 = hdsGetSize(data2);    
