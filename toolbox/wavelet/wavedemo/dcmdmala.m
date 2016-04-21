function varargout = dcmdmala(varargin)
%DCMDMALA Demonstrates Mallat algorithm in the Wavelet Toolbox. 
%
% This is a slideshow file for use with wshowdrv.m
% To see it run, type 'wshowdrv dcmdmala', 
%
% See also CONV, DWT, IDWT, DYADDOWN, DYADUP, WFILTERS, WKEEP.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 12-Apr-2001.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.13 $

% DEMALLAT Short demo about basic steps of FWT 1-D.
% Non documented function, demo function file.

% Initialization and Local functions if necessary.
if nargin>0
	action = varargin{1};
	switch action
	  case 'auto'    , wshowdrv('#autoMode',mfilename,'close');
	  case 'gr_auto' , wshowdrv('#gr_autoMode',mfilename,'close');

	  case 'getFigParam'
		figName  = 'Mallat Algorithm (FWT)';
		showType = 'mix6';
		varargout = {figName,showType};
	end
	return
end

if nargout<1,
  wshowdrv(mfilename)
else
  idx = 0;	
  %========== Slide 1 ==========
  idx = idx+1;
  slide(idx).code = {
	  'figHandle = gcf;',
	  'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow;  h = [];',		  	
	  '' };
 
  slide(idx).text = {
	  '',
	  ' Press the "Start" button to see a demonstration of',
	  ' Mallat algorithm in the Wavelet Toolbox.',
	  '',
	  ' This demo uses Wavelet Toolbox functions.',
	  ''};

  %========== Slide 2 ==========
  idx = idx+1;
  slide(idx).code = {
	  's = 2 + kron(ones(1,8),[1 -1]) + ((1:16).^2)/32 + 0.2*randn(1,16);',
	  'h(1) = subplot(3,1,1); plot(s,''r'');',
	  'title(''Original signal s.'');',
	  'set(h(1),''Xlim'',[1 16])',
	  'delete(findobj([subplot(3,2,3);subplot(3,2,4)]));',
	  '' };

  slide(idx).text = {
	  ' % Construct elementary original 1-D signal.',
	  ' ', 
	  '         s = 2 + kron(ones(1,8),[1 -1]) + ...' ,
	  '             ((1:16).^2)/32 + 0.2*randn(1,16);',
	  ''};
  
  %========== Slide 3 ==========
  idx = idx+1;
  slide(idx).code = {
	  '[Lo_D,Hi_D] = wfilters(''db1'',''d'');',
	  'x_fil = 1:length(Lo_D);',
	  'stemCOL = ''y'';',
	  'h(3) = subplot(3,2,3); wdstem(h(3),x_fil,Lo_D,stemCOL);',
	  'xlabel(''Lo_D.'');',
	  'h(4) = subplot(3,2,4); wdstem(h(4),x_fil,Hi_D,stemCOL);',
	  'xlabel(''Hi_D.'');',
	  '' };

  slide(idx).text = {
	  ' % For a given orthogonal wavelet,',
	  ' % compute the two associate',
	  ' % decomposition filters.',
	  ' ',
	  '         [Lo_D,Hi_D] = wfilters(''db1'',''d'');',
	  ''};

  slide(idx).info = 'wfilters';

  %========== Slide 4 ==========
  idx = idx+1;
  slide(idx).code = {
	  'sm = sum(Lo_D);',
	  'h(3) = subplot(3,2,3); xlabel([''Lo_D : sum = '', num2str(sm)]);',
	  '' };

  slide(idx).text = {
	  ' % Lo_D is the decomposition low-pass filter.',
	  ' % Check for sum.',
	  ' ',
	  '         sm = sum(Lo_D);',
	  ''};

  %========== Slide 5 ==========
  idx = idx+1;
  slide(idx).code = {
	  'nrm = norm(Lo_D);',
	  ['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	  'if idxPREV>idxSlide',
	  '   h(3) = subplot(3,2,3); wdstem(h(3),x_fil,Lo_D,stemCOL);',
	  '   h(4) = subplot(3,2,4); wdstem(h(4),x_fil,Hi_D,stemCOL);',
	  '   xlabel(''Hi_D.'');',
	  'end',
	  'h(3) = subplot(3,2,3); xlabel([''Lo_D : norm = '', num2str(nrm)]);',
	  '' };
 
  slide(idx).text = {
	  ' % Lo_D is the decomposition low-pass filter.',
	  ' % Check for square norm.',
	  ' ',
	  '         nrm = norm(Lo_D);',
	  ''};

  %========== Slide 6 ==========
  idx = idx+1;
  slide(idx).code = {
	  'tempo = conv(s,Lo_D);',
	  'set(subplot(3,1,1),''Xticklabel'',[]);',
	  'h(2) = subplot(3,1,2); plot(tempo);',
	  'title(''s and Lo_D convolution.'');',
	  'set(h(2),''Xlim'',[1 length(tempo)]);',
	  'delete(subplot(3,2,5));',
	  '' };

  slide(idx).text = {
	  ' % Compute approx. coef. of s using db1 : first step.',
	  ' % Convolve s and Lo_D the',
	  ' % decomposition low-pass filter.',
	  ' ',
	  '         tempo = conv(s,Lo_D);',
	  ''};

  %========== Slide 7 ==========
  idx = idx+1;
  slide(idx).code = {
	  ['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	  'if idxPREV>idxSlide',
	  '   h(2) = subplot(3,1,2); plot(tempo);',
	  '   title(''s and Lo_D convolution.'');',
	  '   set(h(2),''Xlim'',[1 length(tempo)]);',
	  'end'
	  'ca1 = dyaddown(tempo);',
	  'h(5) = subplot(3,2,5); plot(ca1);',
	  'xlabel(''Approx. coef. : ca1.'');',
	  'set(h(5),''Xlim'',[1 length(ca1)]);',
	  '' };

  slide(idx).text = {
	  ' % Compute approx. coef. of s using db1 : second step.',
	  ' % Decimate convolution result and keep central part.',
	  ' ',
	  '         ca1 = dyaddown(tempo);',
	  ''};

  slide(idx).info = 'dyaddown';

  %========== Slide 8 ==========
  idx = idx+1;
  slide(idx).code = {
	  'h(3) = subplot(3,2,3); wdstem(h(3),x_fil,Lo_D,stemCOL);',
	  'h(4) = subplot(3,2,4); wdstem(h(4),x_fil,Hi_D,stemCOL);',
	  'xlabel(''Hi_D.'');',
	  ''};

  slide(idx).text = {
	  ''};

  %========== Slide 9 ==========
  idx = idx+1;
  slide(idx).code = {
	  'sm = sum(Hi_D);',
	  'h(4) = subplot(3,2,4); xlabel([''Hi_D : sum = '', num2str(sm)]);',
	  ''};

  slide(idx).text = {
	  ' % Hi_D is the decomposition high-pass filter.',
	  ' % Check for sum.',
	  ' ',
	  '         sm = sum(Hi_D);',
	  ''};

  %========== Slide 10 ==========
  idx = idx+1;
  slide(idx).code = {
	  'nrm = norm(Hi_D);',
	  ['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	  'if idxPREV>idxSlide',
	  '   h(3) = subplot(3,2,3); wdstem(h(3),x_fil,Lo_D,stemCOL);',
	  '   h(4) = subplot(3,2,4); wdstem(h(4),x_fil,Hi_D,stemCOL);',
	  'end',
	  'h(4) = subplot(3,2,4); xlabel([''Hi_D : norm = '', num2str(nrm)]);',
	  ''};
  
  slide(idx).text = {
	  ' % Hi_D is the decomposition high-pass filter.',
	  ' % Check for square norm.',
	  ' ',
	  '         nrm = norm(Hi_D);',
	  ''};

  %========== Slide 11 ==========
  idx = idx+1;
  slide(idx).code = {
	  'tempo = conv(s,Hi_D);',
	  'h(2) = subplot(3,1,2); plot(tempo);',
	  'title(''s and Hi_D convolution.'');',
	  'set(h(2),''Xlim'',[1 length(tempo)]);',
	  'delete(subplot(3,2,6));',
	  ''};

  slide(idx).text = {
	  ' % Compute detail coef. of s using db1 : first step.',
	  ' % Convolve s and Lo_D the',
	  ' % decomposition high-pass filter.',
	  ' ',
	  '         tempo = conv(s,Hi_D);',
	  ''};       

  %========== Slide 12 ==========
  idx = idx+1;
  slide(idx).code = {
	  'cd1 = dyaddown(tempo);',
	  
	  ['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	  'if idxPREV>idxSlide',
	  '   h(5) = subplot(3,2,5); plot(ca1);',
	  '   xlabel(''Approx. coef. : ca1.'');',
	  '   set(h(5),''Xlim'',[1 length(ca1)]);',
	  'end',
	  'h(6) = subplot(3,2,6); plot(cd1);',
	  'xlabel(''Detail coef. : cd1.'');',
	  'set(h(6),''Xlim'',[1 length(cd1)]);',
	  ''};

  slide(idx).text = {
	  ' % Compute detail coef. of s using db1 : second step.',
	  ' % Decimate convolution result',
	  ' % and keep central part.',
	  ' ',
	  '         cd1 = dyaddown(tempo);',
	  ''};       

  slide(idx).info = 'dyaddown';

  %========== Slide 13 ==========
  idx = idx+1;
  slide(idx).code = {
	  '[ca1,cd1] = dwt(s,''db1'');',
	  
	  ['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	  'if idxPREV>idxSlide',
	  '   h(1) = subplot(3,1,1); plot(s,''r'');',
	  '   title(''Original signal s.'');',
	  '   set(h(1),''Xlim'',[1 16],''Xtick'',[])',
	  '   tempo = conv(s,Hi_D);',
	  '   h(2) = subplot(3,1,2); plot(tempo);',
	  '   title(''s and Hi_D convolution.'');',
	  '   set(h(2),''Xlim'',[1 length(tempo)]);',
	  'end'
	  
	  'h(5) = subplot(3,2,5); plot(ca1,''g'');',
	  'xlabel(''Approx. coef. : ca1.'');',
	  'set(h(5),''Xlim'',[1 length(ca1)]);',
	  'h(6) = subplot(3,2,6); plot(cd1,''g'');',
	  'xlabel(''Detail coef. : cd1.'');',
	  'set(h(6),''Xlim'',[1 length(cd1)]);',
	  ''};

  slide(idx).text = {
	  ' % This sequence is the one step',
	  ' % discrete wavelet transform of s.',
	  ' % M-file dwt performs it directly.',
	  ' ',
	  '         [ca1,cd1] = dwt(s,''db1'');',
	  ''};       

  slide(idx).info = 'dwt';

  %========== Slide 14 ==========
  idx = idx+1;
  slide(idx).code = {
	  '[Lo_R,Hi_R] = wfilters(''db1'',''r'');',
	  'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow;  h = [];',		  	
	  'h(3) = subplot(3,2,3); wdstem(h(3),x_fil,Lo_R,stemCOL);',
	  'xlabel(''Lo_R.'');',
	  'h(4) = subplot(3,2,4); wdstem(h(4),x_fil,Hi_R,stemCOL);',
	  'xlabel(''Hi_R.'');',
	  'h(1) = subplot(3,2,1); plot(ca1,''g'');',
	  'set(h(1),''Xlim'',[1 length(ca1)]);',
	  'title(''Approx. coef. : ca1.'');',
	  'h(2) = subplot(3,2,2); plot(cd1,''g'');',
	  'title(''Detail coef. : cd1.'');',
	  'set(h(2),''Xlim'',[1 length(cd1)]);',
	  ''};

  slide(idx).text = {
	  ' % Now how to reconstruct ?',
	  ' % For a given orthogonal wavelet,',
	  ' % compute the two associate',
	  ' % reconstruction filters.',
	  ' ',
	  '         [Lo_R,Hi_R] = wfilters(''db1'',''r'');',
	  ''};

  slide(idx).info = 'wfilters';

  %========== Slide 15 ==========
  idx = idx+1;
  slide(idx).code = {
	  'tempo = dyadup(cd1);',
	  'subplot(3,2,3); xlabel('''');',
	  'subplot(3,2,4); xlabel('''');',
	  'h(3) = subplot(3,1,3); plot(tempo);',
	  'xlabel(''Upsampled det. coeff. cd1.'');',
	  'set(h(3),''Xlim'',[1 length(tempo)]);',
	  ''};

  slide(idx).text = {
	  ' % Reconstruct detail : first step.',
	  ' % Upsample cd1 inserting zeros.',
	  ' ',
	  '         tempo = dyadup(cd1);' ,
	  ''};

  slide(idx).info = 'dyadup';

  %========== Slide 16 ==========
  idx = idx+1;
  slide(idx).code = {
	  'tempo = conv(tempo,Hi_R);',
	  'h(3) = subplot(3,1,3); plot(tempo);',
	  'xlabel(''Upsampled detail coeff. and Hi_R convolution.'');',
	  'set(h(3),''Xlim'',[1 length(tempo)]);',
	  ''};

  slide(idx).text = {
	  ' % Reconstruct detail : second step.',
	  ' % Convolves upsampled detail coeff.',
	  ' % and Hi_R reconstruction high-pass filter.',
	  ' ',
	  '         tempo = conv(tempo,Hi_R);',
	  ''};

  %========== Slide 17 ==========
  idx = idx+1;
  slide(idx).code = {
	  'd1 = wkeep(tempo,16);',
	  'h(3) = subplot(3,1,3); plot(d1);',
	  'xlabel(''Reconstructed detail d1.'');',
	  'set(h(3),''Xlim'',[1 length(d1)]);',
	  ''};

  slide(idx).text = {
	  ' % Reconstruct detail : last step.',
	  ' % Take central part of length 16',
	  ' % of upsampled detail coeff. and Hi_R',
	  ' % convolution.',
	  ' ',
	  '         d1 = wkeep(tempo,16);',
	  ''};

  slide(idx).info = 'wkeep';

  %========== Slide 18 ==========
  idx = idx+1;
  slide(idx).code = {
	  'tempo = dyadup(ca1);',
	  'h(3) = subplot(3,1,3); plot(tempo);',
	  'xlabel(''Upsampled approx. coeff. ca1'');',
	  'set(h(3),''Xlim'',[1 length(tempo)]);',
	  ''};

  slide(idx).text = {
	  ' % Using the same line reconstruct',
	  ' % approximation. First step. Upsample',
	  ' % ca1 inserting zeros.',
	  ' ',
	  '         tempo = dyadup(ca1);',
	  ''};

  slide(idx).info = 'dyadup';

  %========== Slide 19 ==========
  idx = idx+1;
  slide(idx).code = {
	  'tempo = conv(tempo,Lo_R);',
	  'h(3) = subplot(3,1,3); plot(tempo);',
	  'xlabel(''Upsampled approx coeff. and Lo_R convolution.'');',
	  'set(h(3),''Xlim'',[1 length(tempo)]);',
	  ''};

  slide(idx).text = {
	  ' % Reconstruct approx. : second step.',
	  ' % Convolves upsampled approx coeff.',
	  ' % and Lo_R reconstruction low-pass filter.',
	  ' ',
	  '         tempo = conv(tempo,Lo_R);', 
	  ''};

  %========== Slide 20 ==========
  idx = idx+1;
  slide(idx).code = {
	  'a1 = wkeep(tempo,16);',
	  
	  ['idxPREV = wshowdrv(''#get_idxSlide'',figHandle); idxSlide = ' int2str(idx) ';'],
	  'if idxPREV>idxSlide',
	  '   h(3) = subplot(3,2,3); wdstem(h(3),x_fil,Lo_R,stemCOL);',
	  '   h(4) = subplot(3,2,4); wdstem(h(4),x_fil,Hi_R,stemCOL);',
	  '   h(1) = subplot(3,2,1); plot(ca1,''g'');',
	  '   set(h(1),''Xlim'',[1 length(ca1)]);',
	  '   title(''Approx. coef. : ca1.'');',
	  '   h(2) = subplot(3,2,2); plot(cd1,''g'');',
	  '   title(''Detail coef. : cd1.'');',
	  '   set(h(2),''Xlim'',[1 length(cd1)]);',
	  'end'
	  
	  'h(3) = subplot(3,1,3); plot(a1);',
	  'xlabel(''Reconstructed approx. a1.'');',
	  'set(h(3),''Xlim'',[1 length(a1)]);',
	  ''};

  slide(idx).text = {
	  ' % Reconstruct approx : last step.',
	  ' % Take central part of length 16',
	  ' % of upsampled approx coeff. and Lo_R',
	  ' % convolution.',
	  ' ',
	  '        a1 = wkeep(tempo,16);',
	  ''};

  slide(idx).info = 'wkeep';

  %========== Slide 21 ==========
  idx = idx+1;
  slide(idx).code = {
	  'a0 = a1 + d1;'
	  'ax = findall(figHandle,''type'',''axes''); delete(ax); drawnow;  h = [];',		  	
	  'h(1) = subplot(3,1,1); plot(s,''r'');',
	  'title(''Original signal s.'');',
	  'set(h(1),''Xlim'',[1 16]);',
	  'pause(1)',
	  'set(h(1),''Xticklabel'',[]);',
	  'h(2) = subplot(3,1,2); plot(1:16,a1,1:16,d1);',
	  'title(''a1 and d1.'');',
	  'set(h(2),''Xlim'',[1 16]);',
	  'pause(1)',
	  'set(h(2),''Xticklabel'',[]);',
	  'h(3) = subplot(3,1,3); plot(a0);',
	  'title(''Reconstructed signal : a0 = a1 + d1.'');',
	  'set(h(3),''Xlim'',[1 16]);',
	  ''};

  slide(idx).text = {
	  ' % Now add a1 and d1 in order to',
	  ' % recover original signal.',
	  ' ',
	  '         a0 = a1 + d1;',
	  ''};

  %========== Slide 22 ==========
  idx = idx+1;
  slide(idx).code = {
	  'a0 = idwt(ca1,cd1,''db1'',16);',
	  'h(3) = subplot(3,1,3); plot(a0,''g'');',
	  'title(''Reconstructed signal a0.'');',
	  'set(h(3),''Xlim'',[1 16]);',
	  ''};

  slide(idx).text = {
      ' % This sequence is the one step',
      ' % inverse discrete wavelet transform of s.',
      ' % M-file idwt performs it directly.',
      ' ',
      '        a0 = idwt(ca1,cd1,''db1'',16);',
      ''};

  slide(idx).info = 'idwt';

  varargout{1} = slide;
end
