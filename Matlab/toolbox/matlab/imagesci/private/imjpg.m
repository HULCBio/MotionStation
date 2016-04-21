function [info,msg] = imjpg(filename)
%IMJPG Information about a JPEG file.
%   [INFO,MSG] = IMJPG(FILENAME) reads the header portion of the
%   JPEG file specified by the string FILENAME and returns an 
%   INFO structure with fields that describe the file.  If any
%   error conditions are encountered, INFO is empty and MSG
%   is a nonempty string describing the error.
%
%   See also IMFINFO, IMREAD, IMWRITE.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $ $Date: 2004/02/01 22:04:29 $
%#mex

error('MATLAB:imjpg:missingMEX', 'Missing MEX-file IMJPG');
