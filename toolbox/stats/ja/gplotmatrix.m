% GPLOTMATRIX   ���ʕϐ��ŃO���[�v�����ꂽ�U�z�}�v���b�g�s��
%
% GPLOTMATRIX(X,Y,G) �́AG �ŃO���[�v�����ꂽY �̗�ɑ΂��� X �̗��
% �U�z�}�v���b�g�s����쐬���܂��BX �� P �s M ��ŁAY �� P �s N ��̏ꍇ�A
% GPLOTMATRIX �́A���� N �s M ��̍s����쐬���܂��BG �́A�e�s�����
% �e�_�ɑ΂���}�[�J��J���[��ݒ肵�܂��BY ���ȗ����邩�A[] �Őݒ肷��
% �ꍇ�A�֐��́AX �� X �Ƃ̊֌W���O���t�����܂��BG �́A�e�s����̊e�_��
% ���蓖�Ă�ꂽ�}�[�J�[�ƃJ���[�Œ�`�����O���[�v���ϐ��ŁA�x�N�g���A
% �܂��͕�����̍s��A������̃Z���z��ł��B�܂��AG �́A�O���[�v���ϐ���
% ���ꂼ�ꃆ�j�[�N�Ȍ����ɂ���� X ���̒l���O���[�v�����邽�߂ɁA
% ({G1 G2 G3} �̂悤��) �O���[�v���ϐ��̃Z���z��Ƃ��Ă��\���܂���B
% 
% GPLOTMATRIX(X,Y,G,CLR,MRK,SIZ) �́A�g�p����J���[�A�}�[�J�A�傫����
% �w�肵�܂��BCLR �́A�J���[�̎d�l��ݒ肷�镶����AMRK �́A�}�[�J��
% �d�l��ݒ肷�镶����ł��B���ڍׂȏ��𓾂�ɂ́A"help plot"�Ɠ���
% ���Ă��������B���Ƃ��΁AMRX = 'o+x'�́A�ŏ��̃O���[�v���~�}�[�N�ŁA
% 2�Ԗڂ̃O���[�v���v���X�}�[�N�ŁA3�Ԗڂ�x�}�[�N�ŁA�\�����܂��BSIZ �́A
% �v���b�g�Ŏg�p����}�[�J�̑傫�����w�肵�܂��B�f�t�H���g�ł́A�J���[��
% 'bgrcmyk'�A�}�[�J��'.'�A�}�[�J�̑傫���́Afigure�E�B���h�E�̑傫����
% �v���b�g���Ɉˑ����܂��B
% 
% GPLOTMATRIX(X,Y,G,CLR,MRK,SIZ,DOLEG) �́A�}����쐬���邩�ۂ����R���g
% ���[�����܂��BDOLEG �́A'on'(�f�t�H���g)�܂��́A'off' �̂����ꂩ��
% �ݒ肵�܂��B
% 
% GPLOTMATRIX(X,Y,G,CLR,MRK,SIZ,DOLEG,DISPOPT) �́AX �� Y �̊֌W�̃v���b�g
% �}�̒��ŁA�Ίp���̓h��Ԃ��@���R���g���[�����܂��BDISPOPT �� 'none' 
% �Ƃ���Ƌ󔒂̂܂܂ɂȂ�A'hist'(�f�t�H���g)�Ƃ���ƃq�X�g�O������
% �v���b�g���A'variable' �̏ꍇ�͕ϐ������L�q���܂��B
% 
% GPLOTMATRIX(X,Y,G,CLR,MRK,SIZ,DOLEG,DISPOPT,XNAM,YNAM) �́AX �� Y �ϐ�
% �̖��O�� XNAM �� YNAM ���g���āA�ݒ肵�܂��B���ꂼ��́A�K�؂Ȏ�����
% �L�����N�^�z��ł���K�v������܂��B
% 
% [H,AX,BigAx] = GPLOTMATRIX(...) �́A�쐬�����I�u�W�F�N�g�̃n���h���ԍ�
% ����Ȃ�z��� H �ɏo�͂��A�X�̃T�u���̃n���h���ԍ��� AX �ɁA�T�u��
% ����쐬����傫��(���)���̃n���h���ԍ��� BigAx �ɏo�͂��܂��B
% BigAx �́ACurrentAxes �ƂȂ�A�����ɑ��� TITLE, XLABEL, YLABEL ��
% �����ꂩ�́A���̍s��Ɋւ��Ē����Ɉʒu���܂��B


%   Tom Lane, 5-4-1999
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:12:16 $
