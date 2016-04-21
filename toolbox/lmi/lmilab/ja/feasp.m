% [tmin,xfeas] = feasp(lmis,options,target)
%
% LMI��������V�X�e��LMIS�ɂ���Ē�`���ꂽ����������܂��B��肪
% ���ȂƂ��A�o��XFEAS�́A(�X�J����)����ϐ��̃x�N�g���̉��Ȓl�ł��B
%
% L(x) < R(x)�̌`���̉��肪�^������ƁAFEASP�́A���̕⏕�I�Ȓ[�_
% ���������܂��B
%
%        L(x) < R(x) + t*I�̏������ŁAt���ŏ��ɂ��܂��B
%
% �A��LMI�́A���I�ŏ��lTMIN�����ł���ꍇ�ɂ̂݉��ł��Bt�̃J�����g��
% �ŗǒl�́A�e�X�̌J��Ԃ���FEASP�ɂ���ĕ\������܂��B
%
% ����:
%  LMIS      ����t��LMI�V�X�e�����L�q����z��B
%  OPTIONS   �I�v�V����: 5�v�f�̐���p�����[�^�x�N�g���B
%            �f�t�H���g�l�́AOPTIONS(i)=0�̐ݒ�ɂ���đI������܂��B
%             OPTIONS(1): ���g�p�B
%             OPTIONS(2): �ő�J��Ԃ���(�f�t�H���g=100)�B
%             OPTIONS(3): �𔼌aR�BR>0�́Ax��x'*x  <  R^2�ɐ������܂��B
%                         (�f�t�H���g=1e9)
%                         R<0�́A"�����Ȃ�"���Ӗ����܂��B
%             OPTIONS(4): �����lL > 1�ɐݒ肳�ꂽ�Ƃ��A�Ō��L��̌J���
%                         ����t��1%�ȏ㌸�����Ȃ��Ƌ����I�ɏI�����܂��B
%                         (�f�t�H���g = 10)
%             OPTIONS(5): ��[���̂Ƃ��A���s�̉ߒ��̕\�����s���܂���B
%  TARGET    �I�v�V����:  TMIN�ɑ΂���^�[�Q�b�g�B
%                         �R�[�h�́At�����̒l��菬�����Ȃ�ƏI�����܂��B
%                         (�f�t�H���g=0)
% �o��:
%  TMIN      �I������t�̒l�BLMI�V�X�e���́ATMIN <= 0�Ȃ�Ή��ł��B
%  XFEAS     �Ή�����ŏ��l�BTMIN <= 0�Ȃ�΁AXFEAS��LMI����ɑ΂����
%            �x�N�g���ł��BXFEAS����s��ϐ��̒l�𓾂�ɂ́ADEC2MAT���g
%            ���܂��B
%
% �Q�l�F    MINCX, GEVP, DEC2MAT.



% Copyright 1995-2002 The MathWorks, Inc. 
