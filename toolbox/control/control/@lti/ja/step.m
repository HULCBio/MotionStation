% STEP   LTI���f���̃X�e�b�v����
%
% STEP(SYS) �́ALTI ���f��(TF, ZPK,�܂��� SS �̂����ꂩ�ō쐬���ꂽ) SYS 
% �̒P�ʃX�e�b�v�������v���b�g���܂��B�����̓��f���ɑ΂��ẮA�e����
% �`�����l�����ɓƗ����āA1��step �R�}���h���K�p����܂��B���Ԕ͈͂�
% �v�Z�_���́A�����I�ɑI������܂��B
%
% STEP(SYS,TFINAL) �́At = 0 ����A�ŏI���� t = TFINAL �܂ł̃X�e�b�v����
% ���V�~�����[�V�������܂��B�T���v�����Ԃ�ݒ肵�Ă��Ȃ����U���ԃ��f����
% �΂��āATFINAL �̓T���v�����Ƃ��Ĉ����܂��B
%
% STEP(SYS,T) �́A�V�~�����[�V�����Ƀ��[�U�w��̎��ԃx�N�g�� T �𗘗p
% ���܂��B���U���ԃ��f���ɑ΂��āAT �� Ti:Ts:Tf �̌`���ł��B�����ŁATs ��
% �T���v�����Ԃł��B�A�����ԃ��f���ł́AT �� Ti:dt:Tf �̌`���ł��B�����ŁA
% dt �͘A�����ԃV�X�e���ɑ΂��闣�U�ߎ��̂��߂̃T���v�����Ԃł��B�X�e�b�v
% ���͂́A��� t = 0(Ti �Ɋւ炸)�ŗ����オ��Ɖ��肳��܂��B
%
% STEP(SYS1,SYS2,...,T) �́A������LTI���f�� SYS1,SYS2,... �̃X�e�b�v����
% ��1�̃v���b�g�}��ɕ\�����܂��B���ԃx�N�g�� T �̓I�v�V�����ł��B����
% �悤�ɂ��āA�J���[�A���C���X�^�C���A�}�[�J���w�肷�邱�Ƃ��ł��܂��B
% 
%   step(sys1,'r',sys2,'y--',sys3,'gx').
%
% ���ӂɏo�͈�����ݒ肷��ƁA
% 
%   [Y,T] = STEP(SYS)
% 
% �́A�o�͉��� Y �ƃV�~�����[�V�����ɗ��p���ꂽ���ԃx�N�g�� T ���o��
% ���܂��B��ʂɂ̓v���b�g�͕\������܂���BSYS �� NY �o�͂�NU ���͂�
% �����ALT = length(T)�̏ꍇ�AY �� �T�C�Y[LT NY NU] �̔z��ɂȂ�܂��B
% �����ŁAY(:,:,j)�́Aj �Ԗڂ̓��̓`�����l���ɑΉ�����X�e�b�v�����ł��B
%
% ��ԋ�ԃ��f���ɑ΂��āA 
% 
%   [Y,T,X] = STEP(SYS) 
% 
% �́ASYS ��NX�̏�Ԃ����ꍇ�ALT�~NX�~NU�z��̏�� X ���o�͂��܂��B
%
% �Q�l : IMPULSE, INITIAL, LSIM, LTIVIEW, LTIMODELS.


%   Author(s): J.N. Little, 4-21-85
%   Revised:   A.C.W.Grace, 9-7-89, 5-21-92
%   Revised:   P. Gahinet, 4-18-96
%   Revised:   A. DiVergilio, 6-16-00
%   Revised:   B. Eryilmaz, 6-6-01
%   Copyright 1986-2002 The MathWorks, Inc. 
