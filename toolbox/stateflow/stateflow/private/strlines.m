%STRLINES Convert a string vector to a string matrix (MEX file)
%         M = STRLINES( S1, S2, S3, ... ) returns a string matrix where each
%         row represents a line in concatanation of all the strings arguments
%         passed.
%
%         The definitions of a line are:
%          - A substring terminated with
%                 newline character
%                 carriage return character
%                 formfeed character
%          - A vector string which may be ending with one or more zeros
%          - A row string in a string matrix which may be padded with zeros

%
%	E. Mehran Mestchian
%	Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.11.2.1 $  $Date: 2004/04/15 01:00:48 $
