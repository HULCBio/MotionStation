function [result, err] = dataddg_preapply_callback(dlgH)

% Copyright 2003 The MathWorks, Inc.

  result = 1;
  err = [];
  
  if ~ishandle(dlgH)
    return;
  end
  
  h = dlgH.getDialogSource;
  if ~isa(h, 'Stateflow.Data')
    return;
  end
  
  % Remove the tag (if any) identifying this as an intermediate object
  if ~isempty(findstr(h.Tag, '_DDG_INTERMEDIATE_'))
      h.tag = '';
  end
  
  stateOutput = sf('get',h.Id, '.outputState');
  
  if ~stateOutput
    dataType = h.DataType;
    
    % If data type is fixed point, commit all fixed point settings
    if (strcmp(dataType, 'fixpt') == 1)
      err = save_fixpt_settings(dlgH, h);
    end  
  end
 
  if err
    result = 0;
  end
  
%----------------------------------------------------------------------------------------
function err = save_fixpt_settings(dlgH, h)

  % Get new fixed point data from the dialog
  scalingMode = dlgH.getWidgetValue('scaling_popup_tag'); % 0 based index
  scalingEdit = dlgH.getWidgetValue('scaling_edit_tag');
 
  % validate the data and if correct, commit it to data dictionary
  [slope,exponent,bias,err] = string_to_scaling(scalingEdit, scalingMode+1);
  
  if isempty(err)
    sf('set',h.Id, ...
       'data.fixptType.slope', slope, ...
       'data.fixptType.exponent', exponent, ...
       'data.fixptType.bias', bias, ...
       'data.dlgFixptMode', scalingMode+1);
  end
  
%----------------------------------------------------------------------------------------
function [slope,exponent,bias,err] = string_to_scaling(string,mode)
  
% mode == 1   interpret as fraction length
% mode == 2   interpret as slope or [slope bias]
% otherwise error

%set up default values
slope = 1.0;
exponent = 0;
bias = 0.0;

err = [];
try
    scaling = evalin('base',[ '[' string ']' ]);
catch
    err = 'Could not evaluate FixPt field';
    return;
end

if isempty(scaling)
    % blank string => use default values
    return;
end

% otherwise must be a finite real matrix of length 1 or 2
if ~isreal(scaling) | any(isnan(scaling)) | any(isinf(scaling))
    err = 'FixPt field must be a finite real matrix of length 1 or 2';
    return;
end

switch mode
    case 1
        % fraction length must be a single integer
        if length(scaling) > 1 | fix(scaling) ~= scaling
            err = 'Fraction Length must be a single integer';
            return;
        end
        exponent = -scaling;
    case 2
        % slope   or   [slope  bias]
        if length(scaling) > 2
            err = 'Slope cannot have length greater than 2';
            return;
        end
        % slope must be positive
        if scaling(1) <= 0.0
            err = 'Slope must be greater than 0';
            return;
        end
        [slope, exponent] = log2(scaling(1));
        % log2 is almost right - produces 0.5 <= slope < 1
        % we need 1.0 <= slope < 2
        slope = slope * 2;
        exponent = exponent - 1;
        if length(scaling) > 1
            bias = scaling(2);
        end
    otherwise
        error('bogus case');
end
