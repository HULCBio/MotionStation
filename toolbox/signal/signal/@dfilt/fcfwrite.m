%FCFWRITE   Write a filter coefficient file.
%   FCFWRITE(H) writes a filter coefficient ASCII-file. H maybe a single 
%   filter object or a vector of objects. A dialog box is displayed to 
%   fill in a file name. The default file name is 'untitled.fcf'. 
%
%   If the Filter Design Toolbox is installed, FCFWRITE(H) can be
%   used to write filter coefficient files for multirate filter
%   objects, MFILTs, and adaptive filter objects, ADAPTFILTs. 
%
%   FCFWRITE(H,FILENAME) writes the file to a disk file called
%   FILENAME in the present working directory.
%
%   The extension '.fcf' will be added to FILENAME if it doesn't already
%   have an extension.
%
%   See also DFILT/INFO, DFILT.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/03/15 22:28:32 $



% [EOF]
