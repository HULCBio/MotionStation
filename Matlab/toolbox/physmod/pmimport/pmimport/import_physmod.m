function import_physmod (varargin)
%IMPORT_PHYSMOD  Import a Physical Modeling XML file into Physical Modeling
%
%  IMPORT_PHYSMOD(FILENAME) imports a Physical Modeling XML-formatted file 
%  into Physical Modeling. 
%
%  IMPORT_PHYSMOD('-license') prints the third-party license terms for 
%  use of the import utility.
%
%  IMPORT_PHYSMOD(FILENAME, OPTION1, VALUE1, OPTION2, VALUE2, ...) uses
%  the specified option-value pairs when importing.  Options and values are
%  the following:
%
%    'Direction' (diagram growth direction):  either 'LR' (diagram grows
%    from left to right) or 'TB' (diagram grows from top to bottom)
%    Default: 'LR'
%    
%    'FontSize': font size in pixels for the block labels
%    Default: 10

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/16 22:17:48 $



pmiu_import(varargin{:});


% [EOF physmod_import.m]


