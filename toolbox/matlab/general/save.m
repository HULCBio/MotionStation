%SAVE Save workspace variables to disk. 
%   SAVE FILENAME saves all workspace variables to the binary "MAT-file"
%   named FILENAME.mat.  The data may be retrieved with LOAD.  If FILENAME
%   has no extension, .mat is assumed.  
%
%   SAVE, by itself, creates the binary "MAT-file" named 'matlab.mat'.  It
%   is an error if 'matlab.mat' is not writable.
%
%   SAVE FILENAME X  saves only X.
%   SAVE FILENAME X Y Z  saves X, Y, and Z. The wildcard '*' can be used to
%   save only those variables that match a pattern.
%
%   SAVE FILENAME -REGEXP PAT1 PAT2 can be used to save all variables
%   matching the specified patterns using regular expressions. For more
%   information on using regular expressions, type "doc regexp" at the
%   command prompt.
%
%   SAVE FILENAME -STRUCT S saves the fields of the scalar structure S as
%   individual variables within the file FILENAME.
%   SAVE FILENAME -STRUCT S X Y Z  saves the fields S.X, S.Y and S.Z to
%   FILENAME as individual variables X, Y and Z. 
%
%   ASCII Options:
%   SAVE ... -ASCII  uses 8-digit ASCII form instead of binary regardless
%                    of file extension.
%   SAVE ... -ASCII -DOUBLE  uses 16-digit ASCII form.
%   SAVE ... -ASCII -TABS  delimits with tabs.
%   SAVE ... -ASCII -DOUBLE -TABS  16-digit, tab delimited.
%
%   MAT Options:
%   SAVE ... -MAT        saves in MAT format regardless of extension.
%   SAVE ... -V6         saves a MAT-file that MATLAB 6 can LOAD.
%   SAVE ... -V4         saves a MAT-file that MATLAB 4 can LOAD.
%   SAVE ... -APPEND     adds the variables to an existing file (MAT-file 
%                        only).
%
%   By default, MAT-files created with SAVE are compressed and char arrays are
%   encoded using Unicode. These MAT-files cannot be loaded into versions of
%   MATLAB prior to MATLAB 7.0. The -V6 option disables these features and
%   allows saved MAT-files to load into older versions of MATLAB. To disable
%   these features by default, modify the settings in the General->MAT-Files
%   preferences panel, accessible via the File->Preferences menu item. With
%   compression enabled, saving data that does not compress well takes
%   longer. In this case, the -V6 option may be preferable.
%
%   When using the -V4 option, variables that are incompatible with MATLAB 4
%   are not saved to the MAT-file. For example, ND arrays, structs, cells,
%   etc. cannot be saved to a MATLAB 4 MAT-file. Also, variables with names
%   that are longer than 19 characters cannot be saved to a MATLAB 4
%   MAT-file.
%
%   Use the functional form of SAVE, such as SAVE('filename','var1','var2')
%   when the filename or variable names are stored in strings.
%
%   Examples for pattern matching:
%       save fname a*                % Save variables starting with "a"
%       save fname -regexp ^b\d{3}$  % Save variables starting with "b" and
%                                    %    followed by 3 digits
%       save fname -regexp \d        % Save variables containing any digits
%
%   See also LOAD, WHOS, DIARY, FWRITE, FPRINTF, UISAVE, FILEFORMATS.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.25.4.7 $  $Date: 2004/04/19 01:13:47 $
%   Built-in function.
