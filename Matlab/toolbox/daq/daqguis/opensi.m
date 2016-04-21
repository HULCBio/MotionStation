function opensi(filename)
%OPENSI Opens a Data Acquisition softscope file.
%
%   OPENSI('FILENAME.SI') opens a Data Acquisition Toolbox softscope
%   file. The softscope file contains the settings of a previous
%   softscope setup. When FILENAME.SI is opened, a softscope configured
%   with the saved settings is created.
%
%   This is a helper function for OPEN.
%
%   Example:
%     open filename.si
%    
%   See also SOFTSCOPE.
%

%   MP 12-13-01
%   Copyright 1998-2003 The MathWorks, Inc. 
%   $Revision: 1.1.2.3 $  $Date: 2003/08/29 04:44:38 $

softscope(filename)