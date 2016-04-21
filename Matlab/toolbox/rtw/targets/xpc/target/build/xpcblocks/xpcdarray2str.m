function str=xpcdarray2str(v)

% XPCDARRAY2STR - Private function for displaying double arrays as strings

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.3 $ $Date: 2002/03/25 04:12:09 $


if length(v)==0
  str='';
  return
end

if length(v)==1
  str=num2str(v(1));
  return
end

if length(v)==2
  str=[num2str(v(1)),',',num2str(v(2))];
  return
end

cand=v(2)-v(1);
if (v(3)-v(2))~=cand
  str=[num2str(v(1)),',',xpcdarray2str(v(2:end))];
  return;
end

start=v(1);
i=4;
if length(v)==3
 if cand==1
    str=[num2str(start),':',num2str(v(i-1))];
   else
    str=[num2str(start),':',num2str(cand),':',num2str(v(i-1))];
   end
   return
end

while 1
  if i<=length(v) & (v(i)-v(i-1))==cand
    i=i+1;
  else
    if cand==1
      tmp=[num2str(start),':',num2str(v(i-1))];
    else
      tmp=[num2str(start),':',num2str(cand),':',num2str(v(i-1))];
    end
    if (i-1)==length(v)
       str=tmp;
       return
    else
       str=[tmp,',',xpcdarray2str(v(i:end))];
       return
    end
  end
end