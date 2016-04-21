function varargout = dicomdict(command, varargin)
%DICOMDICT  Get or set the active DICOM data dictionary.
%    DICOMDICT('set', DICTIONARY) sets the DICOM data dictionary to the
%    value stored in DICTIONARY, a string containing the filename of the
%    dictionary.  DICOM-related functions will use this dictionary by
%    default, unless a different dictionary is provided at the command
%    line.
%
%    DICTIONARY = DICOMDICT('get') returns a string containing the
%    filename of the stored DICOM data dictionary.
%
%    DICOMDICT('factory') resets the DICOM data dictionary to its default
%    startup value.
%
%    See also dicom-dict.txt, DICOMINFO, DICOMREAD, DICOMWRITE.

%    DICTIONARY = DICOMDICT('get_current') returns the value of the
%    currently active data dictionary.  This may differ from the value
%    returned by DICOMDICT('get') if a dictionary was specified at the
%    command line.
%
%    DICOMDICT('set_current', DICTIONARY) sets the current dictionary.
%    Use this only when a dictionary was specified at the command line.
%
%    DICOMDICT('reset_current') resets the value of the active data
%    dictionary to match the value of the stored data dictionary (either
%    the value stored by DICOMDICT('set', ...) or the default value).

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision $  $Date: 2003/08/01 18:08:45 $

if (nargout > 1)
    error('Images:dicomdict:tooManyOutputs', 'Too many output arguments')
end

persistent dictionary

if (isempty(dictionary))
    dictionary = setup_dictionary;
end

switch (lower(command))
case 'factory'
    
    dictionary = setup_dictionary;
    
case 'get'

    varargout{1} = dictionary.stored_dictionary;
    
case 'set'
    
    dictionary.stored_dictionary = varargin{1};
    dictionary.current_dictionary = dictionary.stored_dictionary;
    
case 'get_current'
    
    varargout{1} = dictionary.current_dictionary;
    
case 'reset_current'
    
    dictionary.current_dictionary = dictionary.stored_dictionary;
    
case 'set_current'
    
    dictionary.current_dictionary = varargin{1};
    
otherwise
    
    error('Invalid command ''%s''.')
    
end

% Prevent clearing the workspace from removing these values.
mlock



function dictionary = setup_dictionary
%SETUP_DICTIONARY  Reset the dictionary to its factory state.

dictionary.stored_dictionary = 'dicom-dict.mat';
dictionary.current_dictionary = dictionary.stored_dictionary;
