% THSELECT �@�G�������̂��߂̃X���b�V���z�[���h�l�̐ݒ�
% THR = THSELECT(X,TPTR) �́A�������� TPTR �ɂ���`���ꂽ�I��������g���āAX 
% �ɓK�p����X���b�V���z�[���h�l��ݒ肵�܂��B
% 
% ���p�\�ȑI������́ATPTR = 'rigrsure'�AStein's Unbiased Risk Estimate �̌���
% ���g�p���ēK�؂ȃX���b�V���z�[���h�l��I��
%   TPTR = 'heursure'�A��̕��@�̕ό`
%   TPTR = 'sqtwolog'�Asqrt(2*log(length(X))) ���X���b�V���z�[���h�l�Ƃ��Ďg�p
%   TPTR = 'minimaxi'�A�~�j�}�b�N�X�X���b�V���z�[���h
%
% �X���b�V���z�[���h�I�����[���́A���f�� y = f(t) + e �Ɋ�Â��Đݒ肳��Ă��܂��B
% �����ŁAe �͔��F�G�� N(0,1) �ł��B�X�P�[�����O����Ă��Ȃ����A�܂��͔��F�G����
% �Ȃ����̂���舵���ɂ́A�o�̓X���b�V���z�[���h THR ���ăX�P�[�����O���Ďg����
% �Ƃ��ł��܂�(WDEN �� SCAL �p�����[�^���Q��)�B
%
% �Q�l�F WDEN.



%   Copyright 1995-2002 The MathWorks, Inc.
