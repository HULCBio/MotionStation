% ISTRELLIS   ���͂��L���ȃg�����X�\���̂ł��邩�ۂ����`�F�b�N
%
% [ISOK, STATUS] = ISTRELLIS(S) �́A���� S ���L���ȃg�����X�\���̂�����
% ���邩�ۂ����`�F�b�N���܂��B���͂��L���ȃg�����X�\���̂̏ꍇ�AISOK ��
% 1���ASTATUS �ɂ͋󕶎�����o�͂��܂��B����AISOK ��0�̏ꍇ�ASTATUS �ɂ́A
% S ���Ȃ��L���łȂ��g�����X�Ȃ̂������������񂪕\������܂��B
%
% �g�����X�\���̂́A���̃t�B�[���h�������Ă��܂��B
%
%      numInputSymbols,  (���̓V���{���̐�)
%      numOutputSymbols, (�o�̓V���{���̐�)
%      numStates,        (��Ԑ�)
%      nextStates,       (���̏�ԍs��)
%      outputs,          (�o�͍s��)
%    
% ���͂� k �r�b�g�ŁA�o�͂� n �r�b�g�ŕ\����ꍇ�AnumInputSymbols = 2^k 
% �ŁAnumOutputSymbols = 2^n �ƂȂ�܂��B�t�B�[���h numStates �́A��Ԑ�
% ���X�g�A���܂��B�t�B�[���h 'nextStates' ��'outputs' �́A'numStates' �s
% 'numInputSymbols' ������s��ł��B
%
% 'nextStates' �s��̒��̊e�v�f�́A0��(numStates-1)�̊Ԃ̐����ł��B
% 'nextStates' �s��� (s,u) �v�f�A���Ȃ킿�As �Ԗڂ̍s�� u �Ԗڂ̗��
% �v�f�́A�X�^�[�g������Ԃ�(s-1)�ŁA���̓r�b�g��10�i���\��(u-1)�̂Ƃ��A
% ���̏�Ԃ��`������̂ł��B10�i���ւ̕ϊ����s���ɂ́A�ŏ��̓��̓r�b�g
% ���ŏ�ʃr�b�g�iMSB�j�Ƃ��Ďg���܂��B���Ƃ��΁A'nextStates' �s���2�Ԗ�
% �̗�́A�ŐV�̓��͂� 1 �ŁA���̓��͂� 0 �̏ꍇ�A���̏�Ԃ��X�g�A���܂��B
%  
% 'output' �s���(s,u)�v�f�́A�X�^�[�g�̏�Ԃ�(s-1)�ŁA���̓r�b�g��10�i��
% (u-1)�̏ꍇ�̏o�͂��`���܂��B10�i���ւ̕ϊ����s���ɂ́A�ŏ��̏o�̓r�b�g
% �� MSB �Ƃ��Ďg���Ă��������B
% 
% �Q�l�F POLY2TRELLIS.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2003/06/23 04:34:57 $

