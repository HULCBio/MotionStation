% IMPULSE   LTI���f���̃C���p���X����
%
% IMPULSE(SYS) �́ALTI���f��(TF, ZPK,�܂��� SS �̂����ꂩ�ō쐬���ꂽ) 
% SYS �̃C���p���X�������v���b�g���܂��B�����̓��f���ɑ΂��ẮA�e����
% �`�����l�����ɓƗ����āAimpulse�R�}���h���K�p����܂��B���Ԕ͈͂Ɖ�����
% �v�Z����_���́A�����I�ɑI������܂��B���ڃt�B�[�h�X���[�����A��
% �V�X�e���ɑ΂��āAt=0 �ł� ������̃p���X����������܂��B
%
% IMPULSE(SYS,TFINAL) �́At=0 ����A�ŏI���� t=TFINAL �܂ł̃C���p���X
% �������V�~�����[�V�������܂��B�T���v�����Ԃ�ݒ肵�Ă��Ȃ����U����
% ���f���ɑ΂��āATFINAL �̓T���v�����Ƃ��Ĉ����܂��B
%
% IMPULSE(SYS,T) �́A�V�~�����[�V�����Ƀ��[�U�w��̎��ԃx�N�g�� T ��
% ���p���܂��B���U���ԃ��f���ɑ΂��āAT �� Ti:Ts:Tf �̌`���ł��B�����ŁA
% Ts �̓T���v�����Ԃł��B�A�����ԃ��f���ł́AT �� Ti:dt:Tf �̌`���ŁA
% �����ŁAdt �́A�A�����ԃV�X�e���ɑ΂��闣�U�ߎ��̂��߂̃T���v������
% �ł��B�C���p���X�́A��� t = 0(Ti �Ɋւ�炸)�ŗ����オ��Ɖ��肳��
% �܂��B
%
% IMPULSE(SYS1,SYS2,...,T) �́A������LTI���f��SYS1,SYS2,... �̃C���p���X
% ������1�̃v���b�g�ɕ\�����܂��B���ԃx�N�g�� T �̓I�v�V�����ł��B
% ���̂悤�ɂ��āA�e�V�X�e���ɑ΂��āA�J���[�A���C���X�^�C���A�}�[�J��
% �w�肷�邱�Ƃ��ł��܂��B
%      impulse(sys1,'r',sys2,'y--',sys3,'gx').
%
% ���ӂɏo�͈�����ݒ肷��ƁA
%      [Y,T] = IMPULSE(SYS) 
% �́A�o�̓x�N�g�� Y �ƃV�~�����[�V�����ɗ��p���ꂽ���ԃx�N�g�� T ���o��
% ���܂��B��ʂɂ̓v���b�g�͕\������܂���BSYS �� NY �o�͂�NU ���� �ŁA
% LT=length(T)�̏ꍇ�AY �� [LT NY NU] �̃T�C�Y�̔z��ł��B�����ŁA
% Y(:,:,j) �́Aj�Ԗڂ̓��̓`�����l���ɑΉ�����C���p���X�����ł��B
%
% ��ԋ�ԃ��f���ɑ΂��āA 
%      [Y,T,X] = IMPULSE(SYS, ...) 
% �́ASYS �� NX�̏�Ԃ����ꍇ�ALT�~NX�~NU�s��ł����� X ���o��
% ���܂��B
%
% �Q�l : STEP, INITIAL, LSIM, LTIVIEW, LTIMODELS.


%	J.N. Little 4-21-85
%	Revised: 8-1-90  Clay M. Thompson, 2-20-92 ACWG, 10-1-94 
%	Revised: P. Gahinet, 4-24-96
%	Revised: A. DiVergilio, 6-16-00
%       Revised: B. Eryilmaz, 10-01-01
%	Copyright 1986-2002 The MathWorks, Inc. 
