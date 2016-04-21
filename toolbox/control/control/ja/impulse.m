% IMPULSE   LTI ���f���̃C���p���X�������v�Z
%
%
% IMPULSE(SYS) �́A(TF, ZPK �܂��� SS �̂����ꂩ�ō쐬���ꂽ)LTI ���f��
% SYS�̃C���p���X�������v���b�g���܂��B�����̓��f���ɑ΂��āA�e���̓`�����l��
% ���ɓƗ��� impulse �R�}���h���K�p����܂��B���Ԕ͈͂Ɖ������v�Z����_���́A
% �����I�ɑI������܂��B���B���������A���n�ɑ΂��āAt = 0�ł̖�����p���X��
% �������܂��B
%
% IMPULSE(SYS,TFINAL) �́At = 0 ����I������ t = TFINAL �܂ł̃C���p���X����
% ���V�~�����[�V�������܂��B�T���v�����Ԃ��w�肵�Ȃ����U�n�ł́ATFINAL �̓T��
% �v�����Ƃ��Ĉ����܂��B
%
% IMPULSE(SYS,T) �́A�V�~�����[�V�����̂��߂Ƀ��[�U���w�肵�����ԃx�N�g��T ��
% ���p���܂��B���U���ԃ��f���ɑ΂��āAT �� Ti:Ts:Tf �̌`���ł��B �����ŁATs ��
% �T���v�����Ԃł��B�A�����ԃ��f���ɑ΂��āAT �� Ti:dt:Tf �̌`���ŗ^���A�����ŁA
% dt �͘A���V�X�e���ɑ΂��闣�U�ߎ��̃T���v�����ԂɂȂ�܂��B�C���p���X�́A
% ��ɁAt = 0 (Ti �Ɋւ�炸)�ŗ����オ��Ɖ��肵�܂��B
%
% IMPULSE(SYS1,SYS2,...,T) �́A������ LTI ���f�� SYS1,SYS2,... �̃C���p���X
% ������1�̃v���b�g�ŕ\�����܂��B���ԃx�N�g�� T �̓I�v�V�����ł��B
% ���̂悤�ɁA�J���[�A���C���X�^�C���A�}�[�J���e�V�X�e�����Ɏw�肷�邱�Ƃ��ł�
% �܂��B 
%   impulse(sys1,'r',sys2,'y--',sys3,'gx')
%
% ���ӂɏo�͈�����ݒ肵���ꍇ�A[Y,T] = IMPULSE(SYS) �́A�o�͉���Y �ƃV�~�����[
% �V�����ɗ��p���ꂽ���ԃx�N�g��T���o�͂��܂��B��ʂɂ̓v���b�g�͕\�������
% ����BSYS �� NU ���� NY �o�͂ŁALT = length(T)�̏ꍇ�AY �̓T�C�Y
% [LT NY NU] �̔z��ł��B�����ŁAY(:,:,j) �� j �Ԗڂ̓��̓`�����l���ɑΉ�����
%
% ��ԋ�ԃ��f���ɑ΂��āA 
%   [Y,T,X] = IMPULSE(SYS, ...) 
% �́A SYS �� NX �̏�Ԃ����ꍇ�ALT�~NX�~NU �z��ł����Ԃ̋O�� X ���o�͂��܂��B
%
% �Q�l : STEP, INITIAL, LSIM, LTIVIEW, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
