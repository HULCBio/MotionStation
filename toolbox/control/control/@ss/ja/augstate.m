% AUGSTATE   ��ԋ�ԃ��f���̏o�͂ɏ�Ԃ�t��
%
% ASYS = AUGSTATE(SYS) �́A��ԋ�ԃ��f�� SYS �̏o�͂ɏ�Ԃ�t�����܂��B
% ���ʂ̃��f���́A���̂悤�ɕ\���܂��B
%      .                           .
%      x  = A x + B u   (�܂��́AE x = A x + B u �F�f�X�N���v�^SS�p)
%
%     |y| = [C] x + [D] u
%     |x|   [I]     [0]
%
% ���̃R�}���h�́A�S��ԃt�B�[�h�o�b�N�Q�C��  u = Kx ���g���āA���[�v��
% ����Ƃ��ɗL���ł��B�v�����g���֐� AUGSTATE �Ƌ��ɏ������āAFEEDBACK
% �R�}���h���g���āA���[�v���f���𓱏o���܂��B
%
% �Q�l : FEEDBACK, SS, LTIMODELS.


%       Author(s): A. Potvin, 12-1-95
%       Copyright 1986-2002 The MathWorks, Inc. 
