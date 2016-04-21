function [a,error_str] = cstrchk(a,Name)
%CSTRCHK Determines if argument is a vector cell of single line strings.

%	P. Gahinet 5-1-96
%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.7.4.1 $  $Date: 2004/04/10 23:16:15 $

error_str = '';
if isempty(a),  
    return
end

if ndims(a)>2 | (~isstr(a) & ~isa(a,'cell')),
    error_str = sprintf([Name ...
            ' must be a 2D array of padded strings (like [''a'' ; ''b'' ; ''c''])\n' ...
            'or a cell vector of strings (like {''a'' ; ''b'' ; ''c''}).']);
    return
elseif isstr(a),
    % A is a 2D array of paded strings
    a = cellstr(a);
end%else
% A is a cell array
if min(size(a))>1,
    error_str = [Name ' must be a cell vector of strings (like {''a'' ; ''b'' ; ''c''}).'];
    return
end
if strcmp(Name,'Unit')
    a = a(:)';
    
else
    a = a(:);
end%was (:)'
for k=1:length(a),
    str = a{k};
    if isempty(str), 
        a{k} = '';
    elseif ~isstr(str) | ndims(str)>2 | size(str,1)>1,
        error_str = ['All cell entries of ' Name ' must be single-line strings'];
        return
    elseif strcmp(Name,'InterSample')&~(strcmp(str,'zoh')|strcmp(str,'foh')|strcmp(str,'bl')) %%LL fill out
        error_str=['InterSample must be one of ''zoh'' (zero order hold) ,''foh'' (first order hold), or ''bl'' (band limited)'];
        return
    elseif strcmp(Name,'Unit')
        if lower(str(1))=='h'
            a{k} = 'Hz';
        elseif lower(str(1))=='r'
            a{k} = 'rad/s';
        else
            error_str=['The frequency unit must be ''rad/s'' or ''Hz''.'];
        end
             
    end
end
%end

% end cstrchk
