function result = ispuma
%ISPUMA True for computers running Mac OS X 10.1.x.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2002/10/17 03:07:17 $

persistent is_puma;

if isempty(is_puma)
    is_puma = false;
    if strcmp(computer, 'MAC')
        [fail, output] = unix('sw_vers | grep ProductVersion');
        if ~fail && any(strfind(output, '10.1'))
            is_puma = true;
        end
    end
end

result = is_puma;
