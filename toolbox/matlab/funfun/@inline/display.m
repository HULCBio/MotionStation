function display(obj)
%DISPLAY Display an INLINE object.

%   Steven L. Eddins, August 1995
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/15 04:21:32 $

isLoose = strcmp(get(0,'FormatSpacing'),'loose');

line1 = sprintf('%s =', inputname(1));

if (obj.isEmpty)
  line2 = 'Inline function (empty)';
else
  line2 = sprintf('Inline function:\n     %s(', inputname(1));
  for k = 1:(obj.numArgs-1)
    line2 = sprintf('%s%s,', line2, deblank(obj.args(k,:)));
  end
  line2 = sprintf('%s%s)', line2, deblank(obj.args(obj.numArgs,:)));
  line2 = sprintf('%s = %s', line2, obj.expr);
end

if (isLoose)
  fprintf('\n');
end
fprintf('%s\n', line1);
if (isLoose)
  fprintf('\n');
end
fprintf('     %s\n', line2);
if (isLoose)
  fprintf('\n');
end
