function varargout = dicom_warn(msg, varargin)
%DICOM_WARN  Print warning message without backtrace.
%   DICOM_WARN(MSG) prints the warning message MSG without a backtrace.
%
%   FILE = DICOM_WARN(MSG, FILE) prints the warning MSG without a
%   backtrace and also increments the number of warnings issued.  If the
%   number of errors is greater than the maximum allowable, FILE will be
%   closed and an error will be issued.
%
%   FILE = DICOM_WARN('reset', FILE) resets the number of warnings issued
%   to 0 and the maximum number of warnings to INF.
%
%   FILE = DICOM_WARN('reset', FILE, MAX) resets the number of warnings issued
%   to 0 and the maximum number of warnings to MAX.
%
%   See also WARNING.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.3 $  $Date: 2003/08/23 05:54:02 $


if (nargout > 1)
    error('Images:dicom_warn:numberOutputs', 'DICOM_WARN requires 0 or 1 output arguments.')
end

% Turn off backtrace.  Changing the backtrace state doesn't affect any
% other warning states.
orig_backtrace = warning('query', 'backtrace');

warning('off', 'backtrace')

% Check arguments.
switch (nargin)
case 1

    % File-less warning message.
    
    % Don't allow output argument.
    if (nargout > 0)
        error('Images:dicom_warn:outputRequiresFile', 'DICOM_WARN can only return a value if passed a FILE struct.')
    end

    % Display warning.
    if (ischar(msg))

        if (~isequal(lower(msg), 'reset'))
            warning('Images:genericDICOM', msg)
        end
        
    else
        
        warning(orig_backtrace);
        
        error('Images:dicom_warn:inputValues', 'First argument to DICOM_WARN must be a string.')
        
    end
    
    % Done.
    warning(orig_backtrace);
    return
    
case 2
    
    % String and file.
    
    file = varargin{1};
    max = inf;
    
    if (~ischar(msg))

        try
            dicom_close_msg(file)
        catch
        end
        
        error('Images:dicom_warn:inputValues', 'First argument to DICOM_WARN must be a string.')
        
    elseif (~isstruct(file))
        
        error('Images:dicom_warn:inputValues', 'Second argument to DICOM_WARN must be a file structure.')
        
    end
    
case 3
    
    % Reset, file, and max.
    
    file = varargin{1};
    max = varargin{2};
    
    if (~isequal(lower(msg), 'reset'))
        
        try
            dicom_close_msg(file)
        catch
        end
        
        error('Images:dicom_warn:inputValues', 'First argument must be "reset" when three arguments given.')

    elseif (~isstruct(file))
        
        error('Images:dicom_warn:inputValues', 'Second argument to DICOM_WARN must be a file structure.')
       
    elseif ((~isnumeric(max)) || (numel(max) ~= 1))
        
        file = dicom_close_msg(file);
        error('Images:dicom_warn:inputValues', 'Third argument to DICOM_WARN must be a scalar.')
        
    end
    
otherwise
      
    error('Images:dicom_warn:inputValues', 'DICOM_WARN requires 1, 2, or 3 input values.')
    
end

% Allow the counter to be reset.
if (isequal(lower(msg), 'reset'))
    
    file.Warn.Current = 0;
    file.Warn.Max = max;
    
    varargout{1} = file;
    
    return;
    
end
    
% Print the message and increment.
warning('Images:genericDICOM', msg)

file.Warn.Current = file.Warn.Current + 1;

% Revert warning level
warning(orig_backtrace);

% Determine if too many warnings.
if (file.Warn.Current >= file.Warn.Max)
    
    if (~isempty(file))
        file = dicom_close_msg(file);
    end
    
    error('Images:dicom_warn:maxWarningExceeded', 'Maximum warning count reached.  Terminating execution.')
    
end

varargout{1} = file;
