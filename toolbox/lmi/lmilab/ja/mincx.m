% [copt,xopt] = mincx(lmis,c,options,xinit,target)
%
% LMI���������܂��B
%
% L (x)  <   R(x)�̐��񉺂ŁAc'*x���ŏ������܂��B
%
% �����ŁAx�́A����ϐ��x�N�g���ł��B
%
% ����:
%  LMIS      �A��LMI����̋L�q�B
%  C         x�Ɠ����T�C�Y�̃x�N�g��(DECNBR���Q��)�B�s��ϐ��Ɋւ��ẮA
%            �ړI�֐�c'*x��ݒ肷�邽�߂ɒ���DEFCX���g���܂��B
%  OPTIONS   �I�v�V����:  5�v�f�̐���p�����[�^�x�N�g���B
%            �f�t�H���g�l�́AOPTIONS(i)=0�̂Ƃ��Ɏg���܂��B
%             OPTIONS(1): �ړI�֐��̍œK�l�̖ڕW���ΐ��x
%                         (�f�t�H���g = 0.01)�B
%             OPTIONS(2): �ő�J��Ԃ���(�f�t�H���g=100)�B
%             OPTIONS(3): �𔼌aR�BR>0�̂Ƃ�x��x'*x < R^2�ɐ������܂��B 
%                         R<0�́A"�����Ȃ�"���Ӗ����܂�(�f�t�H���g=1e9)�B
%             OPTIONS(4): �����lL�B�R�[�h�́A�Ō��L��̌J��Ԃ��̊ԁA��
%                         �I�֐��̒l��OPTIONS(1)�ȉ��Ɍ��������Ƃ��ɏI��
%                         ���܂��B(�f�t�H���g=10)
%             OPTIONS(5): ��[���̂Ƃ��A���s�̉ߒ���\�����܂���B
%                         (�f�t�H���g=0)
%  XINIT     �I�v�V����:  X�ɑ΂��鏉������
%                        (�ݒ肵�Ȃ����[]�ŁA���s�s�\�ȂƂ��͖�������
%                         �܂�)�B
%  TARGET    �I�v�V����:  �ړI�֐��̒l�ɑ΂���^�[�Q�b�g�B
%                         �R�[�h�́A�������������悤�Ȏ��s�\�� x 
%                         �����߂���Ƃ����ɏI�����܂��B
%                               c'*x  < TARGET
%                         (�f�t�H���g=-1e20)
% �o��:
%  COPT      �ړI�֐�c'*x�̑��I�ŏ��l�B
%  XOPT      ����ϐ��x�N�g��x�̍ŏ��l�B�Ή�����s��ϐ��̒l�𓾂邽�߂�
%            �́ADEC2MAT���g���܂��B
%
% �Q�l�F    FEASP, GEVP, DEFCX, DEC2MAT.



% Copyright 1995-2002 The MathWorks, Inc. 
