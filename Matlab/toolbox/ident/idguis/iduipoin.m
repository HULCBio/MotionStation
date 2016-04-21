function iduipoin(arg)
%IDUIPOIN Sets and resets the window pointer to watch and arrow
%
%   ARG = 1 means that the pointer is set to 'watch';
%   ARG = 2 means that the pointer is set to 'arrow';
%   ARG = 0 means that no action is taken

%   L. Ljung 4-4-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2001/04/06 14:22:40 $



if arg==0,return, end
win_point=findobj(get(0,'children'),'flat','vis','on');

if arg==1, point='watch';else point='arrow';end
set(win_point,'pointer',point)
