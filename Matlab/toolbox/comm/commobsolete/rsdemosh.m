function slide=rsdemosh
%This is a slideshow file for use with playshow.m and makeshow.m
%Too see it run, type 'playshow rsdemosh',
% 
%WARNING: This is an obsolete function and may be removed in the future.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.13 $
if nargout<1,
  playshow rsdemosh
else
  %========== Slide 1 ==========

  slide(1).code={
   'fid = fopen(''rstemp.tst'', ''r'');',
   'x  = fread(fid, inf, ''char'');',
   'fclose(fid);',
   'p = plot(1,1);',
   'pp = get(p, ''parent'') ;',
   'delete(p);   axis(''off'');',
   'p = get(pp,''position''); p(1)=p(1)-.05; p(3)=p(3)+.05;',
   'h_ui = uicontrol(''Style'', ''edit'', ''Max'', 2, ''Unit'',''normalized'', ''position'',p, ''ForegroundColor'',[0 0 1], ''BackgroundColor'', [.9 .9 .9], ''HorizontalAlignment'',''left'',''String'', setstr(x''));',
   'hand(1) = uicontrol(''Style'',''edit'', ''Max'',2,''Unit'',''normal'',''position'', [p(1)+.03,p(2)+.01,p(3)/6,p(4)/6], ''ForegroundColor'',[1 1 1],''BackgroundColor'', [0 0 1],''String'',''original text'');',
   'hand(2) = uicontrol(''Style'',''edit'', ''Max'',2,''Unit'',''normal'',''position'', [p(1)+.03+p(3)/4,p(2)+.01,p(3)/6,p(4)/6], ''ForegroundColor'',[1 1 1],''BackgroundColor'', [.6 .6 1],''String'',''encoded text'');',
   'hand(3) = uicontrol(''Style'',''edit'', ''Max'',2,''Unit'',''normal'',''position'', [p(1)+.03+p(3)/2,p(2)+.01,p(3)/6,p(4)/6], ''ForegroundColor'',[1 1 1],''BackgroundColor'', [.6 .6 1],''String'',[''w noise encoded text'']);',
   'hand(4) = uicontrol(''Style'',''edit'', ''Max'',2,''Unit'',''normal'',''position'', [p(1)+.03+p(3)*3/4,p(2)+.01,p(3)/6,p(4)/6], ''ForegroundColor'',[1 1 1],''BackgroundColor'', [.6 .6 1],''String'',''decoded text'');',
   '' };
  slide(1).text={
   'This example codes an ASCII text file using Reed-Solomon code.  The example reads in a text file "rstemp.tst" as shown in the above window. The code word length and the message length used in the coding is specified as in the above text.',
   '',
   'The next three slides show the text encoded with Reed-Solomon code; the encoded text with noise; and the decoded text. The decoded text should be the same as the original data, which correct the errors caused by the noise.'};

  %========== Slide 2 ==========

  slide(2).code={
   'rsencof rstemp.tst temp.cod',
   'fid = fopen(''temp.cod'', ''r'');',
   'x = fread(fid, inf, ''char'');',
   'fclose(fid);',
   '',
   'set(h_ui,''String'',setstr(x''));',
   'set(hand(1:4),''BackGroundColor'',[.6 .6 1]);',
   'set(hand(2),''BackGroundColor'',[0 0 1]);' };
  slide(2).text={
   'Use the following command to code the text from the input "rstemp.tst" file and to save the coded text into the output "temp.cod" file.',
   '',
   'rsencof rstemp.tst temp.cod',
   '',
   'The coded text is shown as above. Please note that some strange characters are added in the coded text as the result of the encoding process.'};

  %========== Slide 3 ==========

  slide(3).code={
   'tmp = find(x==10);',
   'if isempty(tmp), tmp = find(x==13); tmp = tmp(1:4:length(tmp))''; end',
   'if ~isempty(tmp), tmp(length(tmp)) = 0; end',
   'for i = 1:length(tmp), x(tmp(i)+1:tmp(i)+2) = abs(''$$''); end;',
   '',
   'fid = fopen(''temp.noi'',''w'');',
   'fwrite(fid, x, ''char'');',
   'set(h_ui, ''String'', setstr(x''));',
   'set(hand(1:4),''BackGroundColor'',[.6 .6 1]);',
   'set(hand(3),''BackGroundColor'',[0 0 1]);' };
  slide(3).text={
   'In data transmission or in data storage, noises are usually added to the data message. In the text shown above, we have replaced some characters in the text shown in the previous slide with some "$" characters. The text is saved into file "temp.noi" in your currect directory.',
   '',
   'You can try to edit the file "temp.noi" youself. Please note that you can replace characters. You should not delete or add characters.'};

  %========== Slide 4 ==========

  slide(4).code={
   'rsdecof temp.noi temp.dec',
   'fid = fopen(''temp.dec'', ''r'');',
   'x = fread(fid, inf, ''char'');',
   'fclose(fid);',
   'set(h_ui,''String'', setstr(x''));',
   'set(hand(1:4),''BackGroundColor'',[.6 .6 1]);',
   'set(hand(4),''BackGroundColor'',[0 0 1]);' };
  slide(4).text={
   'Use the following command to decode the coded text file with noise "temp.noi" into the decoded file "temp.dec".',
   '',
   'rsdecof temp.noi temp.dec',
   '',
   'If the error number is less than the correction capability, there should have no error in the decoded text.'};
end