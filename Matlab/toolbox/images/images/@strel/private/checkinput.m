function checkinput(A, classes, attributes, function_name, ...
                    variable_name, argument_position)
%CHECKINPUT Check validity of array.
%   CHECKINPUT(A,CLASSES,ATTRIBUTES,FUNCTION_NAME,VARIABLE_NAME, ...
%   ARGUMENT_POSITION) checks the validity of the array A and issues a
%   formatted error message if it is invalid.
%
%   CLASSES is either a space separated string or a cell array of strings
%   containing the set of classes that A is expected to belong to.  For
%   example, CLASSES could be 'uint8 double' if A can be either uint8 or
%   double.  CLASSES could be {'logical' 'cell'} if A can be either logical
%   or cell.  The string 'numeric' is interpreted as an abbreviation for all
%   the numeric classes.
%
%   ATTRIBUTES is either a space separated string or a cell array of strings
%   containing the set of attributes that A must satisfy.  To see the list of
%   valid attributes, see the subfunction init_table below.  For example, if
%   ATTRIBUTES is {'real' 'nonempty' 'finite'}, then A must be real and
%   nonempty, and it must contain only finite values.
%
%   FUNCTION_NAME is a string containing the function name to be used in the
%   formatted error message.
%
%   VARIABLE_NAME is a string containing the documented variable name to be
%   used in the formatted error message.
%
%   ARGUMENT_POSITION is a positive integer indicating which input argument
%   is being checked; it is also used in the formatted error message.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.5 $  $Date: 2003/08/01 18:10:17 $

% Input arguments are not checked for validity.

check_classes(A, classes, function_name, variable_name, argument_position);

check_attributes(A, attributes, function_name, variable_name, ...
                 argument_position);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = is_numeric(A)

numeric_classes = {'double' 'uint8' 'uint16' 'uint32' 'int8' ...
                   'int16' 'int32' 'single'};

tf = false;
for p = 1:length(numeric_classes)
    if isa(A, numeric_classes{p})
        tf = true;
        break;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = expand_numeric(in)
% Converts the string 'numeric' to the equivalent cell array containing the
% names of the numeric classes.

out = in(:);

idx = strmatch('numeric', out, 'exact');
if (length(idx) == 1)
    out(idx) = [];
    numeric_classes = {'uint8', 'int8', 'uint16', 'int16', ...
                       'uint32', 'int32', 'single', 'double'}';
    out = [out; numeric_classes];
end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function check_classes(A, classes, function_name, ...
                       variable_name, argument_position)

if isempty(classes)
    return
end

if ischar(classes)
    if isempty(classes)
        % Work around bug in strread.
        classes = {};
    else
        classes = strread(classes, '%s');
    end
end

is_valid_type = false;
for k = 1:length(classes)
    if strcmp(classes{k}, 'numeric')
      if is_numeric(A)
        is_valid_type = true;
        break;
      end
    elseif isa(A, classes{k})
      is_valid_type = true;
      break;
    end
end

if ~is_valid_type
    messageId = sprintf('Images:%s:%s', function_name, 'invalidType');
    classes = expand_numeric(classes);
    validTypes = '';
    for k = 1:length(classes)
        validTypes = [validTypes, classes{k}, ', '];
    end
    validTypes(end-1:end) = [];
    message1 = sprintf('Function %s expected its %s input argument, %s,', ...
                       upper(function_name), ...
                       num2ordinal(argument_position), ...
                       variable_name);
    message2 = 'to be one of these types:';
    message3 = sprintf('Instead its type was %s.', class(A));
    error(messageId, '%s\n%s\n\n  %s\n\n%s', message1, message2, validTypes, ...
          message3);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function check_attributes(A, attributes, function_name, ...
                          variable_name, argument_position)

if ischar(attributes)
    if isempty(attributes)
        % Work around bug in strread.
        attributes = {};
    else
        attributes = strread(attributes, '%s');
    end
end

table = init_table;

for k = 1:length(attributes)
    if strcmp(attributes{k}, '2d')
        tableEntry = table.twod;
    else
        tableEntry = table.(attributes{k});
    end
    
    if ~feval(tableEntry.checkFunction, A)
        messageId = sprintf('Images:%s:%s', function_name, ...
                            tableEntry.mnemonic);
        message1 = sprintf('Function %s expected its %s input argument, %s,', ...
                           upper(function_name), num2ordinal(argument_position), ...
                           variable_name);
        message2 = sprintf('to be %s.', tableEntry.endOfMessage);
        error(messageId, '%s\n%s', message1, message2);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_real(A)

try
    tf = isreal(A);
catch
    tf = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_even(A)

try
    tf = ~any(rem(double(A(:)),2));
catch
    tf = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_vector(A)

try
    tf = (ndims(A) == 2) & (any(size(A) == 1) | all(size(A) == 0));
catch
    tf = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_row(A)

try
    tf = (ndims(A) == 2) & ((size(A,1) == 1) | isequal(size(A), [0 0]));
catch
    tf = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_column(A)

try
    tf = (ndims(A) == 2) & ((size(A,2) == 1) | isequal(size(A), [0 0]));
catch
    tf = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_scalar(A)

try
    tf = all(size(A) == 1);
catch
    tf = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_2d(A)

try
    tf = ndims(A) == 2;
catch
    tf = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_nonsparse(A)

try
    tf = ~issparse(A);
catch
    tf = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_nonempty(A)

try
    tf = ~isempty(A);
catch
    tf = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_integer(A)

try
    A = A(:);
    switch class(A)

      case {'double','single'}
        % In MATLAB 6.5 and earlier, floor(A) isn't support for single
        % A, so convert to double.
        A = double(A);
        tf = all(floor(A) == A) & all(isfinite(A));

      case {'uint8','int8','uint16','int16','uint32','int32','logical'}
        tf = true;

      otherwise
        tf = false;
    end

catch
    tf = false;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_nonnegative(A)

try
    tf = all(A(:) >= 0);
catch
    tf = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_positive(A)

try
    tf = all(A(:) > 0);
catch
    tf = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_nonnan(A)

try
    tf = ~any(isnan(A(:)));
catch
    % if isnan isn't defined for the class of A,
    % then we'll end up here.  If isnan isn't
    % defined then we'll assume that A can't
    % contain NaNs.
    tf = true;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_finite(A)

try
    tf = all(isfinite(A(:)));
catch
    % if isfinite isn't defined for the class of A,
    % then we'll end up here.  If isfinite isn't
    % defined then we'll assume that A is finite.
    tf = true;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = check_nonzero(A)

try
    tf = ~all(A(:) == 0);
catch
    tf = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = init_table

persistent table

if isempty(table)
    table.real.checkFunction        = @check_real;
    table.real.mnemonic             = 'expectedReal';
    table.real.endOfMessage         = 'real';
    
    table.vector.checkFunction      = @check_vector;
    table.vector.mnemonic           = 'expectedVector';
    table.vector.endOfMessage       = 'a vector';
    
    table.row.checkFunction         = @check_row;
    table.row.mnemonic              = 'expectedRow';
    table.row.endOfMessage          = 'a row vector';
    
    table.column.checkFunction      = @check_column;
    table.column.mnemonic           = 'expectedColumn';
    table.column.endOfMessage       = 'a column vector';
    
    table.scalar.checkFunction      = @check_scalar;
    table.scalar.mnemonic           = 'expectedScalar';
    table.scalar.endOfMessage       = 'a scalar';
    
    table.twod.checkFunction        = @check_2d;
    table.twod.mnemonic             = 'expected2D';
    table.twod.endOfMessage         = 'two-dimensional';
    
    table.nonsparse.checkFunction   = @check_nonsparse;
    table.nonsparse.mnemonic        = 'expectedNonsparse';
    table.nonsparse.endOfMessage    = 'nonsparse';
    
    table.nonempty.checkFunction    = @check_nonempty;
    table.nonempty.mnemonic         = 'expectedNonempty';
    table.nonempty.endOfMessage     = 'nonempty';
    
    table.integer.checkFunction     = @check_integer;
    table.integer.mnemonic          = 'expectedInteger';
    table.integer.endOfMessage      = 'integer-valued';
        
    table.nonnegative.checkFunction = @check_nonnegative;
    table.nonnegative.mnemonic      = 'expectedNonnegative';
    table.nonnegative.endOfMessage  = 'nonnegative';
    
    table.positive.checkFunction    = @check_positive;
    table.positive.mnemonic         = 'expectedPositive';
    table.positive.endOfMessage     = 'positive';
    
    table.nonnan.checkFunction      = @check_nonnan;
    table.nonnan.mnemonic           = 'expectedNonNaN';
    table.nonnan.endOfMessage       = 'non-NaN';
    
    table.finite.checkFunction      = @check_finite;
    table.finite.mnemonic           = 'expectedFinite';
    table.finite.endOfMessage       = 'finite';
    
    table.nonzero.checkFunction     = @check_nonzero;
    table.nonzero.mnemonic          = 'expectedNonZero';
    table.nonzero.endOfMessage      = 'non-zero';
    
    table.even.checkFunction        = @check_even;
    table.even.mnemonic             = 'expectedEven';
    table.even.endOfMessage         = 'even';
    
end

out = table;
