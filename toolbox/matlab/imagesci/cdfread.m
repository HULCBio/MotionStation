function [data, info] = cdfread(filename, varargin)
%CDFREAD Read the data from a CDF file.
%   DATA = CDFREAD(FILE) reads all of the variables from each record of
%   FILE.  DATA is a cell array, where each row is a record and each
%   column a variable.  Every piece of data from the CDF file is read and
%   returned. 
% 
%   DATA = CDFREAD(FILE, 'RECORDS', RECNUMS, ...) reads particular
%   records from a CDF file.  RECNUMS is a vector of one or more
%   zero-based record numbers to read.  DATA is a cell array with
%   length(RECNUM) number of rows.  There are as many columns as
%   variables.
% 
%   DATA = CDFREAD(FILE, 'VARIABLES', VARNAMES, ...) reads the variables
%   in the cell array VARNAMES from a CDF file.  DATA is a cell array
%   with length(VARNAMES) number of columns.  There is a row for each
%   record requested.
% 
%   DATA = CDFREAD(FILE, 'SLICES', DIMENSIONVALUES, ...) reads specified
%   values from one variable in the CDF file.  The matrix DIMENSIONVALUES
%   is an m-by-3 array of "start", "interval", and "count" values.  The
%   "start" values are zero-based.
%
%   The number of rows in DIMENSIONVALUES must be less than or equal to
%   the number dimensions of the variable.  Unspecified rows are filled
%   with the values [0 1 N] to read every value from those dimensions.
% 
%   When using the 'Slices' parameter, only one variable can be read at a
%   time, so the 'Variables' parameter must be used.
% 
%   [DATA, INF0] = CDFREAD(FILE, ...) also returns details about the CDF
%   file in the INFO structure.
%
%   Note:
%
%     CDFREAD creates temporary files when accessing CDF files.  The
%     current working directory must be writeable.
%
%   Example:
%
%     data = cdfread('example.cdf');
%
%       Read all of the data from the file.
%
%     data = cdfread('example.cdf', ...
%                    'Variable', {'Time'});
%
%       Read just the data from variable "Time".
%
%     data = cdfread('example.cdf', ...
%                    'Variable', {'multidimensional'}, ...
%                    'Slices', [0 1 1; 1 1 1; 0 2 2]);
%
%       Read the first value in the first dimension, the second value in
%       the second dimension, the first and third values in the third
%       dimension, and all of the values in the remaining dimension of
%       the variable "Multidimensional".  This is similar to reading the
%       whole variable into "data" and then using the MATLAB command
%
%         data{1}(1, 2, [1 3], :)
%
%   See also CDFINFO, CDFWRITE.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:03:50 $


%
% Process arguments.
%

if (nargin < 1)
    error('MATLAB:cdfread:inputArguments', ...
          'CDFREAD requires at least one input argument.')
end

if (nargout > 2)
    error('MATLAB:cdfread:outputArguments', ...
          'CDFREAD requires two or fewer output argument.')
end

[args, msg] = parse_inputs(varargin{:});

if (~isempty(msg))
    error('MATLAB:cdfread:inputArguments', '%s', msg)
end

%
% Verify existence of filename.
%

% Get full filename.
fid = fopen(filename);

if (fid == -1)
  
    % Look for filename with extensions.
    fid = fopen([filename '.cdf']);
    
    if (fid == -1)
        fid = fopen([filename '.CDF']);
    end
    
end

if (fid == -1)
    error('MATLAB:cdfread:fileOpen', 'Couldn''t open file (%s).', filename)
else
    filename = fopen(fid);
    fclose(fid);
end

% CDFlib's OPEN_ routine is flakey when the extension ".cdf" is used.
% Strip the extension from the file before calling the MEX-file.

if ((length(filename) > 4) && (isequal(lower(filename((end-3):end)), '.cdf')))
    filename((end-3):end) = '';
end


%
% Get information about the variables.
%

info = cdfinfo(filename);

if (isempty(args.Variables))
    args.Variables = info.Variables(:, 1)';
end

% To make indexing info.Variables easier, reorder it to match the values in
% args.Variables and remove unused values. Deblank variable list because
% the intersection is based on the predicate of equality of strings.
% Inconsistent trailing blanks in variable names from args and info may cause
% inadvertent mismatch and consequent failure.
[int, idx1, idx2] = intersect(deblank(args.Variables), ...
                              deblank(info.Variables(:, 1)));

if (length(int) < length(args.Variables))
    
    % Determine which requested variables do not exist in the CDF.
    invalid = setdiff(args.Variables, int);
    
    msg = 'The following requested variables are not in this CDF:';
    msg = [msg sprintf('\n\t%s',invalid{:})];
    
    error('MATLAB:cdfread:variableNotFound', '%s', msg)
    
end

% Remove unused variables.
info.Variables = info.Variables(idx2, :);

% Reorder the variables to match the order of args.Variables.
[tmp, reorder_idx] = sort(idx1);
info.Variables = info.Variables(reorder_idx, :);

if (isempty(args.Records))
    args.Records = find_records(info.Variables);
elseif (any(args.Records < 0))
    error('MATLAB:cdfread:recordNumber', 'Record values must be nonnegative.')
end


%
% Read each variable.
%

if (length(args.Variables) == 1)
    
    % Special cases for single variable.
    
    if (~isempty(args.Slices))
    
        [args.Slices, msg] = parse_slice_vals(args.Slices, info.Variables);

        if (~isempty(msg))
            error('MATLAB:cdfread:sliceValue', '%s', msg)
        end
        
        data = cdfreadc(filename, args.Variables{1}, args.Records, ...
                        args.Slices);
        
    else

        args.Slices = fill_slice_vals([], info.Variables);
        data = cdfreadc(filename, args.Variables{1}, args.Records, ...
                        args.Slices);
        
    end

    % Convert epoch data.
    if (isequal(lower(info.Variables{4}), 'epoch'))
        
        for p = 1:length(data)
            data{p} = convert_epoch(data{p});
        end
        
    end
    
elseif ((~isempty(args.Slices)) && (length(args.Variables) ~= 1))
    
    error('MATLAB:cdfread:sliceValue', 'Specifying variable slices requires just one variable.')
    
else

    % Regular reading.
    
    data = cell(length(args.Records), length(args.Variables));

    for p = 1:length(args.Variables)
        
        args.Slices = fill_slice_vals([], info.Variables(p,:));
    
        if (info.Variables{p, 5}(1) == 'F')
            
            % Special case for variables which don't vary by record.
            tmp = cdfreadc(filename, args.Variables{p}, 0, args.Slices);
            
            % Convert epoch data.
            if (isequal(lower(info.Variables{p, 4}), 'epoch'))
                tmp = convert_epoch(tmp);
            end
            
            data(:, p) = repmat(tmp, length(args.Records), 1);
            
        else
            
            data(:, p) = cdfreadc(filename, args.Variables{p}, ...
                                  args.Records, args.Slices);
            
            % Convert epoch data.
            if (isequal(lower(info.Variables{p, 4}), 'epoch'))
                
                for q = 1:length(data(:, p))
                    data{q, p} = convert_epoch(data{q, p});
                end
                
            end
        
        end
        
    end
    
end



%%%
%%% Function find_records
%%%

function records = find_records(var_details)

% Find which variables to consider.
rec_values = [var_details{:, 3}];
max_record = max(rec_values);

if (isempty(max_record))
  records = [];
else
  records = 0:(max_record - 1);
end



%%%
%%% Function parse_fill_vals
%%%

function [slices, msg] = parse_slice_vals(slices, var_details)

msg = '';

% Find the number of dimensions that the CDF recognizes.  This is given
% explicitly in the variance specification as the number of values to the
% right of the '/' (i.e., the length of the variance string minus two).
vary = var_details{5};
num_cdf_dims = size(vary, 2) - 2;


%
% Check the user-provided slice values.
%

if (num_cdf_dims < size(slices, 1))
    msg = sprintf(['Number of slice rows (%d) exceeds number of' ...
                   ' dimensions (%d) in CDF variable.'], ...
                  size(slices, 1), num_cdf_dims);
    return
end

if (any(slices(:,1) < 0))
    
    msg = 'Slice indices must be nonnegative.';
    return
    
elseif (any(slices(:,2) < 1))
    
    msg = 'Slice interval values must be positive.';
    return
    
elseif (any(slices(:,3) < 1))
    
    msg = 'Slice count values must be positive.';
    return
    
end

for p = 1:size(slices,1)
    
    % Indices are zero-based.
    max_idx = var_details{2}(p) - 1;
    last_requested = slices(p,1) + (slices(p,3) - 1) * slices(p,2);
    
    if (last_requested > max_idx)
        
        msg = sprintf(['Slice values for dimension %d exceed maximum' ...
                       ' index (%d).'], p, max_idx);
        return
        
    end
end


%
% Append unspecified slice values.
%
slices = fill_slice_vals(slices, var_details);



%%%
%%% Function fill_slice_vals
%%%

function slices = fill_slice_vals(slices, var_details)

dims = var_details{2};
vary = var_details{5};
num_cdf_dims = size(vary, 2) - 2;

if (num_cdf_dims > size(slices, 1))
    
    % Fill extra dimensions.
    for p = (size(slices, 1) + 1):(num_cdf_dims)
        slices(p, :) = [0 1 dims(p)];
    end
    
elseif (num_cdf_dims == 0)
    
    % Special case for scalar values.
    slices = [0 1 1];
    
end



%%%
%%% Function parse_inputs
%%%

function [args, msg] = parse_inputs(varargin)

% Set default values
args.Variables = {};
args.Records = [];
args.Slices = [];

msg = '';

% Parse arguments based on their number.
if (nargin > 0)
    
    paramStrings = {'variables'
                    'records'
                    'slices'};
    
    % For each pair
    for k = 1:2:length(varargin)
       param = lower(varargin{k});
       
            
       if (~ischar(param))
           msg = 'Parameter name must be a string.';
           return
       end

       idx = strmatch(param, paramStrings);
       
       if (isempty(idx))
           msg = sprintf('Unrecognized parameter name "%s".', param);
           return
       elseif (length(idx) > 1)
           msg = sprintf('Ambiguous parameter name "%s".', param);
           return
       end
    
       switch (paramStrings{idx})
       case 'variables'
           
           if (k == length(varargin))
               msg = 'No variables specified.';
               return
           else
               
               args.Variables = varargin{k + 1};
               
               if (~iscell(args.Variables))
                   args.Variables = {args.Variables};
               end
               
               for p = 1:length(args.Variables)
                   if (~ischar(args.Variables{p}))
                       msg = 'All variable names must be strings.';
                       return
                   end
               end
           end
           
       case 'records'
           
           if (k == length(varargin))
               msg = 'No records specified.';
               return
           else
               
               records = varargin{k + 1};
               
               if ((~isa(records, 'double')) || ...
                   (length(records) ~= numel(records)) || ...
                   (any(rem(records, 1))))
                   
                   msg = 'Record list must be a vector of integers.';
                   
               end
               
               args.Records = records;
           end
           
       case 'slices'
           
           if (k == length(varargin))
               msg = 'No slice values specified.';
               return
           else
               
               slices = varargin{k + 1};
               
               if ((~isa(slices, 'double')) || ...
                   (size(slices, 2) ~= 3) || ...
                   (~isempty(find(rem(slices, 1) ~= 0))))
                   
                   msg = 'Variable slice values must be n-by-3 array of integers.';
                   return
               end
               
               args.Slices = slices;
           end
       end  % switch
    end  % for
end  % if (nargin > 1)



function epoch_objs = convert_epoch(epoch_nums)
%CONVERT_EPOCH   Convert numeric epoch values to CDFEPOCH objects.

% Note: MATLAB datenums are the number of days since 00-Jan-0000, while the
%       CDF epoch is the number of miliseconds since 01-Jan-0000. 

% Convert values from miliseconds to MATLAB serial dates.
ml_nums = (epoch_nums ./ (24 * 3600 * 1000)) + 1;

% Convert MATLAB serial dates to CDFEPOCH objects.
epoch_objs = cdfepoch(ml_nums);
