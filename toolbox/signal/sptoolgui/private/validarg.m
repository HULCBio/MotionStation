function [var,err] = validarg(str,range,strict,labelstr)
%VALIDARG Evals string in base workspace and returns variable if the result
%   is a real double scalar within the specified range.
%   Puts up a dialog with an error message if there is one.
%   Inputs:
%     str - string containing expression to evaluate in base workspace
%     range - 2-elt vector specifying a real double scalar range
%     strict - 2-elt logical vector specifying whether the inequality
%        is strict at the corresponding endpoint.  Use 1 for strict
%        inequality, 0 otherwise.  i.e. range = [3 4], strict = [1 0]
%        means a valid variable has 3 < x <= 4. 
%     labelstr - name of the object being read in, eg 'numerator'
%   Outputs:
%     var - contains data on success
%     err - 0 means no error, 1 means error

%   Copyright 1988-2002 The MathWorks, Inc.
%       $Revision: 1.8 $


    if isempty(str)
        var = [];
        err = 1;
        return
    end

    arb_obj = {'an arbitrary' 'object'};
    var = evalin('base',str,'arb_obj');
    if isequal(var,arb_obj)
        errordlg1(['The ' labelstr ' that you entered ' ...
                  'couldn''t be evaluated.'],'Error')
        var = [];
        err = 1;
    elseif ~strcmp(class(var),'double')
        errordlg1(['The ' labelstr ' that you entered ' ...
                  'is not of class ''double''.'],'Error')
        var = [];
        err = 1;
    elseif prod(size(var)) ~= 1
        errordlg1(['The ' labelstr ' that you entered ' ...
                  'is not a scalar.'],'Error')
        var = [];
        err = 1;
    elseif ~isreal(var)
        errordlg1(['The ' labelstr ' that you entered ' ...
                  'is not a real scalar.'],'Error')
        var = [];
        err = 1;
    elseif var > range(2) | var < range(1)
        errordlg1(['The ' labelstr ' that you entered ' ...
                  'is outside the permissible range of [' ...
                   num2str(range(1)) ',' num2str(range(2)) '].'],...
                  'Error')
        var = [];
        err = 1;
    elseif strict(1) == 1 & var == range(1)
        errordlg1(['The ' labelstr ' must be strictly greater than '...
                   num2str(range(1)) '.'],'Error')
        var = [];
        err = 1;
    elseif strict(2) == 1 & var == range(2)
        errordlg1(['The ' labelstr ' must be strictly less than '...
                   num2str(range(2)) '.'],'Error')
        var = [];
        err = 1;
    else
        err = 0;
    end

function errordlg1(str,title)

   f =  msgbox(str,title,'error','modal');

