% BLKPROC   �C���[�W�ɑ΂���u���b�N�����̎��s
% B = BLKPROC(A,[M N],FUN) �́A�C���[�W A �����ꂼ�� M �s N ��̃u���b�N
% �ɖ��Ăɕ������A���̌X�Ɋ֐� FUN ��K�p���邱�ƂŁA�C���[�W A ������
% ���܂��B���̏ꍇ�A�K�v�ɉ����āAA �Ƀ[����t�����܂��BFUN �́A�C�����C
% ���֐��A�֐������܂ޕ�����A�܂��́A���������܂ޕ�����ł��\���܂���B
% FUN�́AM �s N ��̃u���b�N X ��ŋ@�\���A�s��A�x�N�g���A�X�J���̂���
% �ꂩ�ł���Y���o�͂��܂��B
% 
%    Y = FUN(X)
% 
% BLKPROC �́AY �� X �Ɠ����傫���ł���K�v�͂���܂���B�������AY �� X 
% �Ɠ����傫���̏ꍇ�̂݁AB �� A �Ɠ����傫���ɂȂ�܂��B
% 
% B = BLKPROC(A,[MN],FUN,P1,P2,...) �́A�t���I�ȃp�����[�^ P1,P2,...,�� 
% FUN �ɓn���܂��B
% 
% B = BLKPROC(A,[MN],[MBORDERNBORDER],FUN,...) �́A�u���b�N���ӂ̏d�Ȃ�
% ��Ԃ��`���܂��BBLKPROC �́A�I���W�i���� M �s N �����Ɖ������� M-
% BORDER�A���ƉE������ NBORDER �����g�����A���ʁA(M+2*MBORDER) �s (N+2
% *NBORDER) ��̑傫���ɂȂ�܂��BBLKPROC �́A�K�v�ȏꍇ�ɂ� A �̎��͂�
% �[����t�����܂��BFUN �́A�g�������u���b�N��ŋ@�\���܂��B
% 
% B = BLKPROC(A,'indexed',...) �́AA �̃N���X���Alogical�Auint8�A�܂��́A
% uint16 �ł���ꍇ�ɂ�0���AA �̃N���X�� double �ł���ꍇ�ɂ�1��t��
% ���āAA ���C���f�b�N�X�t���C���[�W�Ƃ��ď������܂��B
% 
% �N���X�T�|�[�g
% -------------
% ���̓C���[�W A �́AFUN ���T�|�[�g����N���X�ł��邱�Ƃ��K�v�ł��BB ��
% �N���X�́AFUN ����o�͂����N���X�Ɉˑ����܂��B
% 
% ���
% -------
% ���̗��́A8�s8��̃u���b�N���̃s�N�Z���ɁA�����̕W���΍���ݒ肷
% �邽�߂� BLKPROC ���g���܂��B
%  
%  I = imread('alumgrns.tif');
%  I2 = blkproc(I,[8 8],'std2(x)*ones(size(x))');
%  imshow(I)
%  figure, imshow(I2,[])
% 
% �Q�l�FCOLFILT, FUNCTION_HANDLE, NLFILTER, INLINE.



%   Copyright 1993-2002 The MathWorks, Inc.
