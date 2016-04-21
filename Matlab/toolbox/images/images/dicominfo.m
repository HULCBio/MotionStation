function [info, file] = dicominfo(msgname, varargin)
%DICOMINFO  Read metadata from DICOM message.
%   INFO = DICOMINFO(FILENAME) reads the metadata from the compliant
%   DICOM file specified in the string FILENAME.
%
%   INFO = DICOMINFO(FILENAME, 'dictionary', D) uses the data dictionary
%   file given in the string D to read the DICOM message.  The file in D
%   must be on the MATLAB search path.  The default value is dicom-dict.mat.
%
%   Example:
%
%     info = dicominfo('CT-MONO2-16-ankle.dcm');
%
%   See also DICOMDICT, DICOMREAD, DICOMWRITE.

%   INFO = DICOMINFO(FILE) reads the metadata from the currently open
%   message in the FILE structure.  This syntax allows DICOMREAD to call
%   DICOMINFO without reopening the file.
%
%   [INFO, FILE] = DICOMINFO(FILE) also returns the file structure (FILE)
%   in case the warning information has changed.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.3 $  $Date: 2003/08/23 05:52:13 $


% This function (along with DICOMREAD) implements the M-READ service.
% This function implements the M-INQUIRE FILE service.


% Parse input arguments.
if (nargin < 1)
    eid = 'Images:dicominfo:tooFewInputs';
    error(eid, '%s', 'DICOMINFO requires at least one argument.')
    
end

% Set the dictionary.
args = parse_inputs(msgname, varargin{:});
dicomdict('set_current', args.Dictionary)

% Get the info.
try
    
    [info, file] = get_info(args, msgname, varargin{:});
    
catch
    
    dicomdict('reset_current');
    rethrow(lasterror)
    
end

% Reset the dictionary.
dicomdict('reset_current');



function [info, file] = get_info(args, msgname, varargin)
%GET_INFO  Get the metadata from the DICOM file.


%
% Determine what to do based on whether file struct was passed in.
%

if (isstruct(msgname))
    % Get info on an already opened message.
    
    file = msgname;
    
    % Reset number of warnings.
    file = dicom_warn('reset', file);

    %
    % Extract the metadata.
    %
    
    % Create an Info structure with default values.
    info = dicom_create_meta_struct(file);
    
    % Look for file metadata.
    if (dicom_has_fmeta(file))
        
        [info, file] = dicom_read_fmeta(file, info);
        
    end
    
    % Find the encoding for the remaining metadata.
    file = dicom_set_mmeta_encoding(file, info);
    
    % Extract the message metadata.
    [info, file] = dicom_read_mmeta(file, info);
    
    % Assign the IMFINFO specific values.
    info = dicom_set_imfinfo_values(info, file);
   
else
    % Message string was passed in by user.

    %
    % Create File structure with uninitialized values.
    %
    
    file = dicom_create_file_struct;
    
    file.Messages = msgname;
    file.Location = args.Location;

    % Reset number of warnings.
    file = dicom_warn('reset', file);

    %
    % Get message to read.
    %
    
    file = dicom_get_msg(file);
    
    if (isempty(file.Messages))
        
        if (isequal(file.Location, 'Local'))
            msg = sprintf('File "%s" not found.', msgname);
        else
            msg = 'Query returned no matches.';
        end
        
        eid = 'Images:dicominfo:noFileOrMessagesFound';
        error(eid, '%s', msg)
        
    end
    
    % Create a container for the output.
    info = {};
    
    %
    % Read metadata from each message.
    %
    
    for p = 1:length(file.Messages)
        
        %
        % Open the message.
        %
        
        file = dicom_open_msg(file, 'r');
        
        %
        % Extract the metadata.
        %
        
        % Create an Info structure with default values.
        info{p} = dicom_create_meta_struct(file);
        
        % Look for file metadata.
        if (dicom_has_fmeta(file))
            
            [info{p}, file] = dicom_read_fmeta(file, info{p});
            
        end
        
        % Find the encoding for the remaining metadata.
        file = dicom_set_mmeta_encoding(file, info{file.Current_Message});
        
        % Extract the message metadata.
        [info{p}, file] = dicom_read_mmeta(file, info{p});
        
        % Assign the IMFINFO specific values.
        info{p} = dicom_set_imfinfo_values(info{p}, file);
   
        %
        % Close the message.
        %
        
        file = dicom_close_msg(file);
        
    end  % For
    
    % Remove from cell array if only one structure.
    if (file.Current_Message == 1)
        info = info{1};
    end
    
end  % (isstruct(msgname))



%%%
%%% Function parse_inputs
%%%
function args = parse_inputs(msgname, varargin)

% Set default values
args.Dictionary = dicomdict('get');

% Determine if messages are local or network.
% Currently only local messages are supported.
args.Location = 'Local';

% Parse arguments based on their number.
if (nargin > 1)
    
    paramStrings = {'dictionary'};
    
    % For each pair
    for k = 1:2:length(varargin)
       param = lower(varargin{k});
       
            
       if (~ischar(param))
           eid = 'Images:dicominfo:parameterNameNotString';
           msg = 'Parameter name must be a string';
           error(eid, '%s', msg);
       end

       idx = strmatch(param, paramStrings);
       
       if (isempty(idx))
           eid = 'Images:dicominfo:unrecognizedParameterName';
           msg = sprintf('Unrecognized parameter name "%s"', param);
           error(eid, '%s', msg);
       elseif (length(idx) > 1)
           eid = 'Images:dicominfo:ambiguousParameterName';
           msg = sprintf('Ambiguous parameter name "%s"', param);
           error(eid, '%s', msg);
       end
    
       switch (paramStrings{idx})
       case 'dictionary'

           if (k == length(varargin))
               eid = 'Images:dicominfo:missingDictionary';
               msg = 'No data dictionary specified.';
               error(eid, '%s', msg);
           else
               args.Dictionary = varargin{k + 1};
           end

       end  % switch
       
    end  % for
           
end
