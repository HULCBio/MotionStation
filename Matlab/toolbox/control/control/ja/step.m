% STEP   LTI ���f���̃X�e�b�v�������v�Z
%
%
% STEP(SYS) �́ALTI ���f��(TF, ZPK,�܂��� SS �̂����ꂩ�ō쐬���ꂽ)SYS ��
% �X�e�b�v�������v���b�g���܂��B�����̓��f���ɑ΂��ẮA�e���̓`�����l������
% �Ɨ����āAstep �R�}���h���K�p����܂��B���Ԕ͈͂Ɖ������v�Z����_���́A
% �����I�ɑI������܂��B
%
% STEP(SYS,TFINAL) �́At = 0 ����A�ŏI���� t = TFINAL �܂ł̃X�e�b�v������
% �V�~�����[�V�������܂��B�T���v�����Ԃ�ݒ肵�Ă��Ȃ����U���ԃ��f���ɑ΂��āA
% TFINAL �̓T���v�����Ƃ��Ĉ����܂��B
%
% STEP(SYS,T) �́A�V�~�����[�V�����Ƀ��[�U�w��̎��ԃx�N�g�� T �𗘗p���܂��B
% ���U���ԃ��f���ɑ΂��āAT �� Ti:Ts:Tf �̌`���ł��B �����ŁATs �̓T���v��
% ���Ԃł��B�A�����ԃ��f���ł́AT �� Ti:dt:Tf �̌`���ŁA�����ŁAdt �́A
% �A�����ԃV�X�e���ɑ΂��闣�U�ߎ��̂��߂̃T���v�����Ԃł��B�X�e�b�v���͂́A
% ��� t = 0 (Ti �Ɋւ炸)�ŗ����オ��Ɖ��肳��܂��B
%
% STEP(SYS1,SYS2,...,T) �́A������ LTI ���f�� SYS1,SYS2,... �̃X�e�b�v������
% 1�̃v���b�g�ɕ\�����܂��B���ԃx�N�g�� T �̓I�v�V�����ł��B
% ���̂悤�ɂ��āA�J���[�A���C���X�^�C���A�}�[�J���w�肷�邱�Ƃ��ł��܂��B
%   step(sys1,'r',sys2,'y--',sys3,'gx').
%
% [Y,T] = STEP(SYS) �́A�o�͉��� Y �ƃV�~�����[�V�����ɗ��p���ꂽ���ԃx�N�g��
% T ���o�͂��܂��B��ʂɂ̓v���b�g�͕\������܂���B
% SYS �� NU����NY �o�͂ŁALT= length(T)�̏ꍇ�AY �� [LT NY NU] �̃T�C�Y�̔z��
% �ł��B �����ŁAY(:,:,j) �� j �Ԗڂ̓��̓`�����l���ɑΉ�����X�e�b�v�����ł��B
%
% [Y,T,X] = STEP(SYS) �́A��ԋ�ԃ��f��SYS�ɑ΂��āASYS ��NX �̏�Ԃ�����
% �ꍇ�ALT*NX*NU �z��̏�Ԃ̋O�� X���o�͂��܂��B
%
% �Q�l : IMPULSE, INITIAL, LSIM, LTIVIEW, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
