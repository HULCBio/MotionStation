function tf=pdeisfunc(f)
%PDEISFUNC True if input name is a function.

%       A. Nordmark 7-1-96.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.5.4.1 $  $Date: 2003/11/18 03:11:29 $

tf=0;
if ischar(f) && size(f,1)==1
  if size(f,2)>0
    % We assume function names start with a letter and then is
    % letters/digits/underscores
    il=isletter(f);
    in=abs('0')<=abs(f) & abs(f)<=abs('9') | abs(f)==abs('_'); 
    if il(1) & all(il(2:end) | in(2:end))
      tf=~all(exist(f)-[2 3 5 6]);
    end
  end
end

