% function code = indvcmp(mat1,mat2,errcrit)
%
% 2��VARYING�s��̓Ɨ��ϐ��f�[�^���r���܂��B
%     CODE = 0; �Ɨ��ϐ��f�[�^���قȂ�
%     CODE = 1; �Ɨ��ϐ��f�[�^�������A�܂��͗��҂�CONSTANT�s��
%     CODE = 2; �_�����قȂ�
%     CODE = 3; ���Ȃ��Ƃ�1�̍s��VARYING�łȂ��A�܂���CONSTANT�łȂ�
%
%     ERRCRIT - 1�s2��̃I�v�V�����s��ŁA���Ό덷�Ɛ�Ό덷�͈̔͂�v�f
% �Ƃ��Ă��܂��B���Ό덷�́A�Ɨ��ϐ��̌덷�̑傫����1e-9���傫�����ǂ�
% ���̃e�X�g�Ɏg���A��Ό덷�͈̔͂́A�����菬�����Ɨ��ϐ��l�ɑ΂���
% �g���܂��B�f�t�H���g�l�́A���ꂼ��1e-6��1e-13�ł��B
%
% �Q�l: GETIV, SORTIV, VUNPCK, XTRACT, XTRACTI.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
