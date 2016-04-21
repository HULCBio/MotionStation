% [gopt,h2opt,K,R,S] = hinfmix(P,r,obj,region,dkbnd,tol)
%
% �ɔz�u�����t����H2/Hinf�����V���Z�V�X
%
% ���̏�ԋ�ԕ������ŕ\�������LTI�v�����gP����͂��܂��B
%
% 	 dx/dt = A  * x + B1  * w + B2  * u
%	  zinf = Ci * x + Di1 * w + Di2 * u
%	   z2  = C2 * x + D21 * w + D22 * u
%           y  = Cy * x + Dy1 * w + Dy2 * u
% 
% HINFMIX�́A���𖞑�����o�̓t�B�[�h�o�b�N�R���g���[��u = K(s)*y���v
% �Z���܂��B
% 
%  * w����zinf�܂ł�RMS�Q�C��G���lOBJ(1)��菬�����B
%  * w����z3�܂ł�H2�m����H���lOBJ(2)��菬�����B
%  * ���̌^�̃g���[�h�I�t����ŏ����B
%              OBJ(3) * G^2 + OBJ(4) * H^2
%  * REGION�Őݒ肵��LMI�̈�ɕ��[�v�̋ɂ�ݒ�B
%
% ����:
%  P        LTI�v�����g�B
%  R        z2, y, u�̒�����\�킷1�s3��x�N�g���B
%  OBJ      H2/Hinf�ړI�֐���ݒ肷��4�v�f�x�N�g��:
%           OBJ(1)  : w����zinf�܂ł�RMS�Q�C���̏�E(0=����`)�B
%           OBJ(2)  : w����z2�܂ł�H2�m�����̏�E(0=����`)�B
%           OBJ(3:4): Hinf�����H2���\�̑��Ώd��(��L���Q��)�B
%  REGION   �I�v�V�����BM�s(2M)��s��[L,M]�́A�ɔz�u�̂��߂̗̈��ݒ肵
%           �܂��B
%                { z :  L + z * M + conj(z) * M' < 0 }
%           REGION���쐬���邽�߂ɂ́A�Θb�I�֐�LMIREG���g���܂��B�f�t�H
%           ���gREGION=[]�́A���[�v���萫��ݒ肵�܂��B
%  DKBND    �I�v�V����: K(s)�̐ÓI�Q�C��DK�̃m�����̋��E
%           (100=�f�t�H���g�B0�́A�����Ƀv���p�ȃR���g���[���ł�)�B
%  TOL      �I�v�V����: �ړI�l�ɑ΂���ڕW���ΐ��x(�f�t�H���g=1e-2)
%
% �o��:
%  GOPT     w����zinf�ɂ����ĕۏ؂��ꂽ���[�vRMS�Q�C���B
%  H2OPT    w����z2�ɂ����ĕۏ؂��ꂽ���[�vH2�m�����B
%  K        �œK�o�̓t�B�[�h�o�b�N�R���g���[���B
%  R,S      LMI�̉������ł̉��B
%
% �Q�l�F    LMIREG, HINFLMI, MSFSYN.



% Copyright 1995-2002 The MathWorks, Inc. 
