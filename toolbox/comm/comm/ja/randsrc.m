% RANDSRC   �O�����Đݒ肵���A���t�@�x�b�g���g���āA�����_���s����쐬
%
% OUT = RANDSRC �́A"-1"��"1"�𓯂��m���ō쐬���܂��B
%
% OUT = RANDSRC(M) �́AM �s M ��̃����_���o�ɍs����쐬���܂��B"-1"��
% "1"�͓����m���Ŕ������܂��B
%    
% OUT = RANDSRC(M,N) �́AM �s N ��̃����_���o�ɍs����쐬���܂��B"-1"��
% "1"�͓����m���Ŕ������܂��B
%
% OUT = RANDSRC(M,N,ALPHABET) �́AALPHABET �Ŏw�肳���A���t�@�x�b�g��
% �g���āAM �s N ��̃����_���s����쐬���܂��B
%
% ALPHABET �́A�s�x�N�g���A�܂��́A2�s�̍s��̂����ꂩ�ł��B:
% �s�x�N�g���FALPHABET ���s�x�N�g���̏ꍇ�AALHABET �̓��e�ɏ]���āA�o��
%             �\�ȗv�f RANDSRC ���`���܂��BALPHABET �̗v�f�́A����
%             �ł����f���ł��\���܂���BALPHABET �̂��ׂĂ̗v�f�������l��
%             �ꍇ�A�m�����z�͈�l�ɂȂ�܂��B
% 2�s�s��   �FALPHABET ��2�s�̍s��̏ꍇ�A1�s�ڂ́i��̂悤�ȁj�\��
%             �o�͂��`���܂��BALPHABET ��2�s�ڂ́A�e�X�Ή�����v�f��
%             �m�����w�肵�܂��B2�s�ڂ̗v�f�S�Ă̘a�́A1�ɂȂ�Ȃ����
%             �Ȃ�܂���B
%
% OUT = RANDSRC(M,N,ALPHABET,STATE) �� RAND �̏�Ԃ� STATE �Ƀ��Z�b�g���܂��B
%
%   ���:
%   >> out = randsrc(2,3)              >> out = randsrc(2,3,[3 4])
%   out =                              out =
%        1    -1    -1                      4     4     3
%       -1    -1     1                      3     3     4
%
%   >> out = randsrc(2,3,[3 4;0 1])    >> out = randsrc(2,3,[3 4;0.8 0.2])
%   out =                              out =
%        4     4     4                      3     3     3
%        4     4     4                      3     4     3
%
% �Q�l:   RAND, RANDINT, RANDERR.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2003/06/23 04:35:07 $
