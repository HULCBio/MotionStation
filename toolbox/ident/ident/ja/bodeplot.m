% BODEPLOT �́A�`�B�֐��A�܂��́A�X�y�N�g���� Bode ���}���v���b�g���܂��B
%     BODEPLOT(M)  
%     BODEPLOT(M,SD) 
%     BODEPLOT(M,W) 
%     BODEPLOT(M,SD,W)
%
% �����ŁAM �́AIDPOLY, IDSS, IDARX, GREYBOX �Ɠ��l�ɁA���胋�[�`��(ETFE
%  �� SPA ���܂�)�œ�����AIDMODEL �I�u�W�F�N�g�A�܂��́AIDFRD �I�u�W
% �F�N�g�̂ǂ��炩�ł��B
%
% SD ���[�����傫���ꍇ�A�W���΍� SD �ɑΉ������M����Ԃ����_���ŕ\��
% ����܂��B
%
% W �́AIDMODELs �p�̎��g����ݒ肵�܂��BW ���x�N�g���̏ꍇ�A���g���֐�
% �́AW �̒l�ɑ΂��ăv���b�g����܂��BW = {WMIN,WMAX}�̏ꍇ�AWMIN �� W-
% MAX �̊Ԃ̎��g����Ԃ��J�o�[����܂��B
%
% �����̃��f���̎��g���֐����v���b�g����ɂ́ABODEPLOT(M1,M2,...,Mn) ��
% �g���܂��BBODEPLOT(M1,'r',M2,'y--',M3,'gx') �ōs���悤�ɁA�J���[�A���C
% ���A�}�[�J��ݒ肷�邱�Ƃ��ł��܂��B
%   
% �O���X�y�N�g�����v���b�g����ɂ́ABODEPLOT(M(:,'noise')) ���g���܂��B
%
% �M���͈͂�\������ɂ́A�Ή�����W���΍� SD ���g���āABODEPLOT(M1,..Mn
% ,SD) ���g���܂��B
%
% �f�t�H���g���[�h�́A���f�� Mi �Ɋ܂܂�Ă��郂�f���̊e����/�o�͂̑g��
% �΂��āA�U���ƈʑ��̐}�𓯎��ɕ\��������̂ł��B�X�y�N�g���ɑ΂��ẮA
% �ʑ����ȗ�����܂��B�����̑g�����݂���ꍇ�AENTER ���g���āA���̐}��
% �\�����s�����Ƃ��ł��܂��B�U���̂݁A�܂��́A�ʑ��݂̂�\������ɂ́ABO
% DEPLOT(M,SD,'A') �A�܂��́ABODEPLOT(M,SD,'P') ���g���܂��B�����}�̒���
% ���ׂẴv���b�g��\������ɂ́ABODEPLOT(M,SD,C,'same') ���g���܂��B��
% ���ŁAC �́A���ꂼ��A�U���A�ʑ��A���̗����A���Ӗ�����A'A','P','B' ��
% �ݒ肵�܂�(�����̏ꍇ�A�f�t�H���g�ł́ASD �͏ȗ�����܂�)�B
%
% �Q�l�F FFPLOT, NYQPLOT.

% $Revision: 1.2 $ $Date: 2001/03/01 22:56:26 $
%   Copyright 1986-2001 The MathWorks, Inc.
