% GETSEQUENCE ���������\�����v�f�̈�A�̕����̒��o
% SEQ = GETSEQUENCE(SE) �́ASE���\�����v�f�z��̏ꍇ�ASE �̕�������o��
% �����\�����v�f�Q�̌X�̂��̂��܂ނ�����̍\�����v�f�z�� SEQ ���
% ���܂��BSEQ �́ASE �Ɠ����ł����ASEQ �̗v�f�́A�����̌��ʂł͂���܂���B% 
% ���
% -------
% STREL ���A3�s3����傫�������̍\�����v�f�ɕ������܂��BGETSEQUENCE ��
% �g���āA���������\�����v�f�𒊏o���邱�Ƃ��ł��܂��B
%
%       se = strel('square',5)
%       seq = getsequence(se)
%
% �I�v�V����'full'�̐ݒ�� IMDILATE ���g���āA5 �s 5 ��̐����s����\����
% �v�f���쐬���A�c�������ɘA���I�Ɏg���Ă݂܂��傤�B
%
%       imdilate(1,seq,'full')
%
% �Q�l�FIMDILATE, IMERODE, STREL.



% $Revision: 1.1 $
%   Copyright 1993-2002 The MathWorks, Inc.  
