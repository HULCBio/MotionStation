% function resp = genphase(d,discflg)
%
% ���f�Z�v�X�g����(Oppenheim & Schafer, Digital Signal Processing, pg 
% 501)���g���āA���f���g������RESP�𐶐����܂��B���̃Q�C���́A�����̐���
% ����D�Ɠ������A���̈ʑ��͈���ȍŏ��ʑ��֐��ɑΉ����܂��BD��RESP�̗���
% �Ƃ�VARYING�s��ł��B
%
% DISCFLG==1(�f�t�H���g=0)�̏ꍇ�A���ׂĂ̎��g���f�[�^�́A�P�ʉ~�f�[�^��
% ���ĉ��߂���ARESP�͗��U���ԂƂ��ĉ��߂���܂��BDISCFLG==0�̏ꍇ�A���g
% ���f�[�^�́A�������Ƃ��ĉ��߂���ARESP�͘A�����ԂƂ��ĉ��߂���܂��B
%
% �Q�l: FITMAG, FITSYS, MAGFIT, MSF.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
