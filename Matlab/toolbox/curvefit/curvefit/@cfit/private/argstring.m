function line = argstring(names,values,ci,activebounds)
%  Args are coefficient names, coefficient values, and optional
%  coefficient confidence intervals.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.10.2.2 $  $Date: 2004/02/01 21:40:48 $

numnames = size(names,1);

if nargin<4 || length(activebounds)~=numnames
   activebounds = zeros(numnames,1);
end

line = '';
for k = 1:numnames
    value = values{k};
    name = deblank(names(k,:));
    if isa(value,'double') & length(value)==1
        if nargin<3
            line = sprintf('%s       %s = %11.4g\n', line, name, value);
        elseif activebounds(k)
            line = sprintf('%s       %s = %11.4g  (fixed at bound)\n',line,...
                name,value);
        elseif isnan(ci(2,k))
            line = sprintf('%s       %s = %11.4g\n',line,...
                name,value);
        else
            line = sprintf('%s       %s = %11.4g  (%.4g, %.4g)\n', line, ...
                name,value,ci(1,k),ci(2,k));
        end
    elseif isstr(value)
        line = sprintf('%s       %s = %s\n', line, name,value);
    else
        [m,n]=size(value);
        value = sprintf('%sx%s %s', num2str(m), num2str(n) ,class(value));
        line = sprintf('%s       %s = %s\n', line, name,value);
    end
    
end

% Remove trailing newline
lf = sprintf('\n');
idx = (length(line)-length(lf)+1):length(line);
if length(line)>length(lf) && isequal(lf,line(idx))
   line(idx) = [];
end
