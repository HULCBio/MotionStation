% NYQPLOT �́A���g���֐��� Nyquist ���}���v���b�g���܂��B
%
%    NYQPLOT(M)
%   NYQPLOT(M,SD)
%   NYQPLOT(M,W)
%   NYQPLOT(M,SD,W)
%
% �����ŁAM �́AIDPOLY, IDSS, IDARX, GREYBOX �Ɠ��l�ɁA���胋�[�`��(ETFE
% �� SPA ���܂�)�œ�����AIDMODEL �I�u�W�F�N�g�A�܂��́AIDFRD �I�u�W�F
% �N�g�̂ǂ��炩�ł��B
%
% SD ���[�����傫���ꍇ�A�W���΍� SD �ɑΉ������M���̈悪�A�v�Z������
% �g��10�_���Ƀv���b�g(*�Ń}�[�N)����A�S�̂Ƃ��āA�ȉ~��\�����܂��B
%
% W �́AIDMODELs �p�ɐݒ肵�����g���ł��BW ���x�N�g���̏ꍇ�A���g���֐�
% �́AW �̒l�ɑ΂��āA�v���b�g����܂��BW = {WMIN,WMAX}�̏ꍇ�AWMIN �� 
% WMAX �̊Ԃ̎��g����Ԃ��J�o�[����܂��B
%
% �����̃��f���Ɋւ�����g���֐����v���b�g����ɂ́ANYQPLOT(M1,M2,...,Mn)
% ���g���܂��BNYQPLOT(M1,'r',M2,'y--',M3,'gx') ���g���āA�J���[�A���C���A
% �}�[�N��ݒ肷�邱�Ƃ��ł��܂��B�}�[�J�ɂ��ẮAHELP PLOT ���Q�Ƃ���
% ���������B
% 
% �v���b�g���ꂽ�ȉ~�ɂǂ̂��炢�̕s�m�������^����邩�́A�}�[�J'r*-25' 
% ���g���Ă��������B25�́A�s�m�����̈�̕\���Ɋւ��āA25�_���̎��g���_�\
% �����Ӗ����A*�́A�����̓_�̃}�[�N�A'r'�̓v���b�g�̃J���[���w�肵�܂��B
% �M����Ԃ� �Ή�����W���΍� SD ��\������ɂ́ANYQPLOT(M1,..Mn,SD) ��
% �g���܂��B
%
% �f�t�H���g���[�h�́A���f�� Mi �ŕ\�������e���͂Əo�͂̂��ׂĂ̑g�ɑ�
% ���� Nyquist ���}�𓯎��ɃV�~�����[�V�������A�v���b�g������̂ł��B��
% ���̑g�����݂���ꍇ�AENTER ���g���āA���̐}�̕\�����s�����Ƃ��ł���
% ���B�����}��ɂ��ׂẴv���b�g�𓾂�ɂ́ANYQPLOT(M,SD,'same') ���g��
% �܂��B
%
% �Q�l�F BODEPLOT, FFPLOT.

% $Revision: 1.2 $ $Date: 2001/03/01 22:56:43 $
%   Copyright 1986-2001 The MathWorks, Inc.
