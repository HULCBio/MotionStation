% FBODE   �A�����Ԑ��`�V�X�e���ɑ΂��� Bode ���g������
%
% FBODE(A,B,C,D,IU) �́A�P���� IU ����A����ԋ�ԃV�X�e��(A, B, C, D)��
% ���ׂĂ̏o�͂ɑ΂��� Bode �v���b�g���쐬���܂��BIU �́ABode �����Ɏg�p
% ������͂��w�肷����͂̃C���f�b�N�X�ł��B���g���ш�Ɠ_���́A�����I��
% �I������܂��BFBODE �́ABODE ��荂���ł����A���x��������܂��B
%
% FBODE(NUM,DEN) �́A�������`�B�֐� G(s) = NUM(s)/DEN(s) �ɑ΂��� Bode 
% ���}���쐬���܂��B�����ŁANUM �� DEN �́As �ŕ\�����~�x�L�̏��ɕ��ׂ�
% �������W�����܂�ł��܂��B
%
% FBODE(A,B,C,D,IU,W) �܂��́AFBODE(NUM,DEN,W) �́A���[�U�w��̎��g��
% �x�N�g�� W ���g���܂��B���̃x�N�g���́Arad/sec �P�ʂŁABode �������v�Z
% ����ʒu��\���܂��B�ΐ��Ԋu�̎��g���x�N�g�����쐬����ɂ́ALOGSPACE ��
% �Q�Ƃ��Ă��������B���̂悤�ɁA
%
% 		[MAG,PHASE,W] = FBODE(A,B,C,D,...)
%		[MAG,PHASE,W] = FBODE(NUM,DEN,...) 
%
% ���ӂɈ�����ݒ肷��ƁA���g���x�N�g�� W �ƍs�� MAG �� PHASE(�P�ʂ͓x)
% ���o�͂��܂��B���̍s��́Alength(W) �s�������܂��B�܂��A���̃X�e�[�g
% �����g�ł́A�X�N���[����Ƀv���b�g��\�����܂���B
%
% �Q�l : LOGSPACE,SEMILOGX,MARGIN, BODE.


% 	J.N. Little 12-5-88
%	Revised CMT 8-2-90, ACWG 6-21-92
%	Revised A.Potvin 10-1-94
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.5.4.1 $  $Date: 2003/06/26 16:08:00 $
