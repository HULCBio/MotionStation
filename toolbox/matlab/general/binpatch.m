function status = binpatch(filename, patch_data)
%BINPATCH Patch binary file.
%   BINPATCH('FILENAME', PATCH_DATA) patches the binary file FILENAME
%   with the patch in the PATCH_DATA matrix.  PATCH_DATA is a
%   matrix with three columns for address, old_value, and new_value
%
%   See also FWRITE, FOPEN, FCLOSE, FGETS.

%   Marc Ullman   June 12, 1993
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.11.4.1 $  $Date: 2004/03/17 20:05:07 $

status = -1;
successes = 0;
previous_patches = 0;
mismatches = 0;
num_patches = size(patch_data,1) - 1;

if (any(sum(patch_data) ~= 0))
    fprintf('binpatch error: Patch data is corrupt\n')
    return
end

fid = fopen(filename,'r+');
if (fid == -1)
    fprintf('binpatch error: Unable to open "%s"\n', filename)
    return
end

for i=1:num_patches
    stat = fseek(fid, patch_data(i,1), 'bof');
    if (stat ~= 0)
        fclose(fid);
        fprintf('binpatch error: Seek failed in "%s"\n', filename)
        return
    end

    old_value = fread(fid, 1, 'uchar');
    if (old_value == [])
        fclose(fid);
        fprintf('binpatch error: Failed reading from "%s"\n', filename)
        return
    end
    if (old_value == patch_data(i,3))
        previous_patches = previous_patches + 1;
        fprintf('Address %.8d has already been patched\n', patch_data(i,1))
    elseif (old_value ~= patch_data(i,2))
        mismatches = mismatches + 1;
        fprintf('Patch data differs from input file at address %.8d\n', ...
          patch_data(i,1));
        fprintf('         input file: %.3d         patch data: %.3d\n', ...
          old_value, patch_data(i,2));
    else
        stat = fseek(fid, patch_data(i,1), 'bof');
        if (stat ~= 0)
            fclose(fid);
            fprintf('binpatch error: Seek failed in "%s"\n', filename)
            return
        end    

        count = fwrite(fid, patch_data(i,3), 'uchar');
        if (count == 1)
            successes = successes + 1;
        else
            fclose(fid);
            fprintf('binpatch Error: Failed writing to "%s"\n', filename)
            return
        end
    end
end

stat = fclose(fid);
if (stat ~= 0)
    fprintf('binpatch error: Failed closing "%s"\n', filename)
    return
end

if (previous_patches == num_patches)
    fprintf('\n"%s" was already patched - no changes were necessary\n', ...
      filename)
    status = 2;
elseif (successes + previous_patches == num_patches)
    fprintf('\n"%s" was patched successfully\n', filename)
    status = 1;
elseif (mismatches + previous_patches == num_patches)
    fprintf('\n"%s" was not modified\n', filename)
    status = 0;
else
    fprintf('\n"%s" was only partially patched - it may now be corrupt!\n', ...
      filename)
    status = -1;
end
