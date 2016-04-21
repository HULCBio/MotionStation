function slide=eydemosh
%This is a slideshow file for use with playshow.m and makeshow.m
%Too see it run, type 'playshow eydemosh', 
%
%WARNING: This is an obsolete function and may be removed in the future.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.11 $
if nargout<1,
  playshow eydemosh
else
  %========== Slide 1 ==========

  slide(1).code={
   'x = randint(200,2,4);',
   'y = [[0 0]; rcosflt(x, 1, 10)];',
   'Fd = 1; Fs = 10; offset=4;',
   'eyescat(y(:,1), Fd, Fs, offset);' };
  slide(1).text={
   'You can use MATLAB command EYESCAT to plot the eye-pattern plot or scatter plot. In this slide, the following commands are used:',
   '',
   ' x = randint(300,2,4);',
   'y = [[0 0]; rcosflt(x, 1, 10)];',
   'Fd = 1; Fs = 10; offset=4;',
   'eyescat(y(:,1), Fd, Fs, offset);'};

  %========== Slide 2 ==========

  slide(2).code={
   'Fd = Fd/4;',
   'eyescat(y(:,1), Fd, Fs, offset);' };
  slide(2).text={
   'You can use one plot to see multiple eye time frames by simply setting Fd=Fd/Multiple_number. For example, use the following command to see four eye time frames in a same plot.',
   '',
   'Fd4 = Fd/4;',
   'eyescat(y(1,:), Fd4, Fs, offset);'};

  %========== Slide 3 ==========

  slide(3).code={
   'Dpoint = ''.'';',
   'eyescat(y, Fd, Fs, 1, Dpoint);' };
  slide(3).text={
   'You can also use the same comand for scatter plot by adding a fifth variable into the functions call. The fifth variable specify the characters in the scatter plot. The commands used in this slide are:',
   '',
   'Dpoint = ''.'';',
   '% with offset at the center of the "eyes".',
   'offset = 1;',
   'eyescat(y, Fd, Fs, offset, Dpoint);',
   '',
   'You may adjust offset in the eyescat plots.'};
end