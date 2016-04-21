% [tmin,xopt] = gevp(lmis,nlfc,options,t0,x0,target)
%
% LMI����̉��ŁA��ʉ��ŗL�l�ŏ������(t�̍ŏ���)�������܂��B
%
%             C(x)  <   0
%
%               0   <   Bj(x)           ( j=1,..,NLFC )
%
%            Aj(x)  <   t * Bj(x)       ( j=1,..,NLFC )
%
% �����ŁAx�́A(�X�J����)����ϐ��̃x�N�g���ł��B���̐���Bj(x) > 0���A�K
% �؂ɐݒ肳��Ȃ���΂Ȃ�܂���Bt�ɂ��Ă̘A��LMI�́A�Ō�ɐݒ肳���
% ���B
%
% ����:
%  LMIS      LMI��������V�X�e���̋L�q�B
%  NLFC      ���`��������̐�(t�ɂ��Ă̘A��LMI)�B
%  OPTIONS   �I�v�V����: ����p�����[�^��5�v�f�̃x�N�g���B
%            OPTIONS(i)=0�̂Ƃ��́A�f�t�H���g�l���g���܂��B
%            OPTIONS(1): TMIN�̖ڕW���ΐ��x(�f�t�H���g = 1.0e-2)�B
%            OPTIONS(2): �ő�J��Ԃ���(�f�t�H���g=100)�B
%            OPTIONS(3): �𔼌aR�BR>0�́Ax��x'*x  <  R^2�ɐ��񂵂܂��B
%                         (�f�t�H���g=1e8)
%                        R<0�́A"�����Ȃ�"���Ӗ����܂��B
%            OPTIONS(4): �����lL�B�R�[�h�́At���Ō��L��̌J��Ԃ��̊Ԃ�
%                        OPTIONS(1)�����������Ȃ�ƏI�����܂�(�f�t�H��
%                        �g = 5) �B
%            OPTIONS(5): ��[���̂Ƃ��A���s�̉ߒ��̕\�����s���܂���B
%  T0,X0     �I�v�V����: t,x�ɑ΂��鏉������(���łȂ��Ƃ��͖������܂�)�B
%  TARGET    �I�v�V����: TMIN�ɑ΂���^�[�Q�b�g�B
%                        �R�[�h�́At�����̒l�ȉ��ɂȂ�ƏI�����܂��B
%                        (�f�t�H���g = -1e5)
%
% �o��:
%  TMIN      t�̍ŏ��l�B
%  XOPT      ����ϐ��̃x�N�g��x�̒l�̍ŏ��l�B�Ή�����s��ϐ��̒l�𓾂�
%            �ɂ́ADEC2MAT���g���܂��B
%
% �Q�l�F    FEASP, MINCX, DEC2MAT.



% Copyright 1995-2002 The MathWorks, Inc. 
