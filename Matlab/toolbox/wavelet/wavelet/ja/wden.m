% WDEN�@�@ �E�F�[�u���b�g���g���������I��1�����̎G������
% WDEN �́A�E�F�[�u���b�g���g���āA1�����̐M�����玩���I�ɎG���������s���܂��B
%
% [XD,CXD,LXD] = WDEN(X,TPTR,SORH,SCAL,N,'wname') �́A�E�F�[�u���b�g�W���ɃX���b
% �V���z�[���h�������s���ē���ꂽ���͐M�� X �̎G�����������o�[�W���� XD ���o��
% ���܂��B�t���I�ȏo�͈��� [CXD,LXD] �́A�G�������������M��XD�̃E�F�[�u���b�g��
% ���\���ł��B
%
% ������ TPTR �́A�X���b�V���z�[���h��@�̑I�𑥂��܂�ł��܂��B
%   'rigrsure' �́AStein's Unbiased Risk �̌�����p���܂��B
%   'heursure' �́A�ŏ��̃I�v�V�����̕ό`��p���܂��B
%   'sqtwolog' �́Asqrt(2*log(.))�X���b�V���z�[���h��p���܂��B
%   'minimaxi' �́A�~�j�}�b�N�X�X���b�V���z�[���h��p���܂��B
%    (���ڍׂɂ��ẮATHSELECT ���Q��)�B
% SORH ('s' or 'h') �́A�\�t�g�X���b�V���z�[���h��p���邩�A�܂��̓n�[�h�X���b�V
% ���z�[���h��p���邩��ݒ肵�܂�(���ڍׂɂ��ẮAWTHRESH ���Q��)�B
% 
% SCAL �́A��@�I�X���b�V���z�[���h�̍ăX�P�[�����O���`���܂��B
%   'one' �́A�ăX�P�[�����O���s���܂���B
%   'sln' �́A�ăX�P�[�����O�ɁA�ŏ��̃��x���W�������ɂ������x���G���̒P�ꐄ���
%             �p���܂��B
%   'mln' �́A�ăX�P�[�����O�Ƀ��x���G���̃��x���Ɉˑ����������p���܂��B
% 
% �E�F�[�u���b�g�����̓��x�� N �ōs���A'wname' �͊�]���钼���E�F�[�u���b�g��
% ���O���܂񂾕�����ł��B
%
% [XD,CXD,LXD] = WDEN(C,L,TPTR,SORH,SCAL,N,'wname') �́A��q�Ɠ����I�v�V�������g
% ���ē����o�͈������o�͂��܂��B�������A���x�� N �ŁA'wname' �����E�F�[�u���b�g
% ���g���ĎG�����������M���̓��̓E�F�[�u���b�g�����\�� [C,L] ���璼�ړ�����
% �_���قȂ�܂��B
%
% �Q�l�F THSELECT, WAVEDEC, WDENCMP, WFILTERS, WTHRESH.



%   Copyright 1995-2002 The MathWorks, Inc.
