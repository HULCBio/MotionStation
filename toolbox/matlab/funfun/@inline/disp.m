function disp(obj)
%DISP   DISP for INLINE object.

%   Steven L. Eddins, November 1995
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/15 04:21:23 $

isLoose = strcmp(get(0,'FormatSpacing'),'loose');

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
fprintf('     %s\n', line2);
if (isLoose)
  fprintf('\n');
end
