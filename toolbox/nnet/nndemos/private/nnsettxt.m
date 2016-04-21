function nnsettxt(h,t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15,t16,t17,t18,t19,t20)
% NNSETTXT Neural Network Design utility function.

%  NNSETTXT(H,T1,T2,T3,T4,T5,...T7)
%           H  - Handle to first line of linked texts.
%    Ti - Strings.
%  Places strings into text fields.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.7 $
% First Version, 8-31-95.

%==================================================================

% GET FIRST TEXT HANDLE
text_obj = h;

if length(t1) > 10 & all(upper(t1) == t1)
  set(text_obj,'fontweight','bold')
else
  set(text_obj,'fontweight','normal')
end

for i=1:(nargin-1)
  line = deblank(eval(sprintf('t%g',i)));
  set(text_obj,'string',line);
  text_obj = get(text_obj,'userdata');
  if strcmp(text_obj,'end'), return, end
  if length(line) > 0
    set(text_obj,'string','');
    text_obj = get(text_obj,'userdata');
    if strcmp(text_obj,'end'), return, end
  end
end

while ~strcmp(text_obj,'end')
  set(text_obj,'string','')
  text_obj = get(text_obj,'userdata');
end
  
