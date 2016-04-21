% [gopt,h2opt,K,Pcl,X] = msfsyn(P,r,obj,region,tol)
%
% �����f��/���ړI��ԃt�B�[�h�o�b�N�V���Z�V�X
%
% ���̏�ԋ�ԕ����������v�����g���^�������
%
%        dx/dt = A  * x + B1  * w + B2  * u
%	 zinf  = C1 * x + D11 * w + D12 * u
%	 z2    = C2 * x + D21 * w + D22 * u
% 
% MSFSYN�́A���̂悤�ȏ�ԃt�B�[�h�o�b�N���䑥u = Kx���v�Z���܂��B
% 
%  * w����zinf�܂ł�RMS�Q�C��G��lOBJ(1)��菬�������܂��B
%  * w����z2�܂ł�H2�m����H��lOBJ(2)��菬�������܂��B
%  * ���̌`���̃g���[�h�I�t����ŏ������܂��B
%              OBJ(3) * G^2 + OBJ(4) * H^2
%  * REGION�ɂ���Đݒ肵��LMI�̈�ɕ��[�v�̋ɂ�z�u���܂��B
%
% ����:
% H2�m�����́AD21=0�ł���ꍇ�ɂ̂ݗL���ł��B
%
% ����:
%  P        LTI�v�����g�A�܂��́A�|���g�s�b�N/�p�����[�^�ˑ��V�X�e��(P-
%           SYS���Q��)�B
%  R        R(1) = �o��z2�̐�    R(2) = �ϑ���u�̐�
%  OBJ      H2/Hinf�ړI�֐���ݒ肷��4�v�f�x�N�g���B
%           OBJ(1)  : w����zinf�܂ł�RMS�Q�C���̏�E(0=����`)�B
%           OBJ(2)  : w����z2�܂ł�H2�m�����̏�E(0=����`)�B
%           OBJ(3:4): Hinf��H2���\�̑��Ώd��(��L���Q��)�B
%  REGION   �I�v�V�����BM�s(2M)��s��[L,M]�́A�ɔz�u�̈��ݒ肵�܂��B
%                { z :  L + z * M + conj(z) * M' < 0 }
%           REGION���쐬���邽�߂ɂ́A�Θb�I�Ȋ֐�LMIREG���g�p���܂��B�f
%           �t�H���g REGION=[]�́A���[�v���萫��ݒ肵�܂��B
%  TOL      �I�v�V����: �ړI�֐��̒l�̖ڕW���ΐ��x(�f�t�H���g = 1e-2)�B
%
% �o��:
%  GOPT     w����zinf�܂ł̕��[�vRMS�̌v�Z���ꂽ���E
%  H2OPT    w����z2�ł̕��[�v��H2�m�����̌v�Z���ꂽ���E
%  K        �œK��ԃt�B�[�h�o�b�N�Q�C��
%  Pcl      u = Kx�ɑ΂�����[�v�V�X�e��
%  X        �œK�g���[�h�I�t��Lyapunov�s��
%
% �Q�l�F    LMIREG, PSYS, HINFLMI.



% Copyright 1995-2002 The MathWorks, Inc. 
