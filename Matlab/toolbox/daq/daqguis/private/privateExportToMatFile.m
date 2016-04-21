function privateExportToMatFile(filename, varargin)
%PRIVATEEXPORTTOMATFILE Export channel or measurement information to a MAT-file.
%
%   PRIVATEEXPORTTOMATFILE('FILENAME', 'NAME', DATA,...) assigns the variable
%   NAME the value DATA and save variable NAME to MAT-file, FILENAME.  
%        
%   PRIVATEEXPORTTOMATFILE is a helper function for the softscope function.
%   It is called when the "MAT-File" menu item is selected from the Channel
%   Channel Export Window or from the Measurement Export Window.
%
%   This function should not be used directly by users.
%
%   See also SOFTSCOPE.
%

%   MP 01-03-02
%   Copyright 1998-2003 The MathWorks, Inc. 
%   $Revision: 1.1.2.3 $  $Date: 2003/08/29 04:45:30 $

% Define the variables that need to be saved. 
variableNames = {};
count = 1;
for i=1:2:length(varargin)
    variableNames{count} = varargin{i};
    eval([varargin{i} ' = varargin{i+1};'])
    count = count+1;
end

% Save the variables to the MAT-file.
save(filename, variableNames{:});