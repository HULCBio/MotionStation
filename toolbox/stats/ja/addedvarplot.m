% ADDEDVARPLOT   �X�e�b�v���C�Y��A�̂��߂̒ǉ����ꂽ�ϐ��̃v���b�g���쐬
%
% ADDEDVARPLOT(X,Y,VNUM,IN) �́AX �̗� VNUM ���̗\���q�Ɖ��� Y �ɑ΂���
% �ǉ����ꂽ�ϐ��v���b�g���쐬���܂��B���̃v���b�g�́A�\���q�Ƃ��Ďg�p
% ������A���f���ɁA���̗\���q��t�������Ƃ��̉e����}�����܂��B
% X �́A�\���q�̒l�ƂȂ�N�sP��̍s��ł��BY �́A�����̒l�ƂȂ� N �̃x�N
% �g���ł��BVNUM �́A�v���b�g�Ŏg�p���邽�߂� X �̗���w�肷��X�J����
% �C���f�b�N�X�ł��BIN �́A�x�[�X���f���Ŏg�p���邽�߂� X �̗���w�肷��
% P �̗v�f�̘_���l�x�N�g���ł��B�f�t�H���g�ł́AIN �̑S�Ă̗v�f�́A�U
% �ł�(���f���͗\���q�������Ă��܂���) �B
%
% ADDEDVARPLOT(X,Y,VNUM,IN,STATS) �́ASTEPWISEFIT �֐��ɂ���č쐬���ꂽ
% �ߎ����ꂽ���f���̌��ʂ��܂ލ\���� STATS ���g�p���܂��BSTATS ���ȗ�
% ���ꂽ�ꍇ�A���̊֐��́A������v�Z���܂��B
%
% �ǉ����ꂽ�ϐ��v���b�g�́A�f�[�^�Ƌߎ����ꂽ���C�����܂݂܂��BX1 �́A
% X �� VNUM ��ł���Ɖ��肵�܂��B�f�[�^�̋Ȑ��́AIN �ɂ���Ďw�肳�ꂽ
% ���̗\���q�̌��ʂ��폜������ɁAY �� X1 ���v���b�g���܂��B�����́A
% �f�[�^�̋Ȑ��̍ŏ����ߎ��ŁA���̌��z�́A���f���Ɋ܂܂�Ă���ꍇ�A
% X1 �����W���ł��B�_���́A�ߎ����ꂽ���C���ɑ΂���95%�̐M����ԂŁA
% X1 �̗L�Ӑ������؂��邽�߂Ɏg�p����܂��B
%
% ���:  Hald �f�[�^�̃X�e�b�v���C�Y��A�����s���A2�Ԗڂ̗�̗\���q��
%        �΂��Ēǉ����ꂽ�ϐ��̃v���b�g���쐬���܂��B
%      load hald
%      [b,se,p,in,stats] = stepwisefit(ingredients,heat);
%      addedvarplot(ingredients,heat,2,in,stats)


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2003/01/07 20:12:48 $
