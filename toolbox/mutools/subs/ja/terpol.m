%function [freq,mag] = terpol(freqin,magin,npts)
%
% ���̊֐��́A�s��Ԋu�̎��g��/�Q�C���f�[�^FRQIN�����MAGIN���ȉ��̕��@
% �œ��}���܂��B�ŏ��ɁAFREQIN�́A0����΂̊Ԃ̔񕉂̎��g������Ȃ�s�x
% �N�g���ł���Ɖ��肵�܂��B
% 
% 1 <= i <= NPTS�ł���i�ɑ΂���
%    pi*(i-1)/NPTS  <  FREQIN(1)�̏ꍇ�AFREQ(i)  :=  MAG(1)�ɂȂ�܂��B
%    FREQIN(length(FREQIN))  <=  pi*(i-1)/NPTS�̏ꍇ�AMAGOUT((i) =  
%    MAGIN(length(MAGIN))�ɂȂ�܂��B
%    ����FREQIN(i)�̒l�ɂ��ẮA�v���O�����̓f�[�^�_�Ԃ̐��`���}���s��
%    �܂��B

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:32:59 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
