%  [K,gfin]=dkcen(P,r,gama,X1,X2,Y1,Y2,tolred)
%
% ���U���ԃv�����gP��^���AGAMA > 0�̂Ƃ��ADKCEN�́A���̂悤�Ȓ��SHinf
% �f�B�W�^���R���g���[��K(s)���v�Z���܂��B
% 
%   * �v�����g������I�Ɉ��艻���܂��B
%   * ���[�v�Q�C���� GAMA �ȉ��ɂ��܂��B
% 
% ���̃R���g���[���́A2��HinfRiccati�������̈��艻��X,Y(�ÓT�I�ȃA�v��
% �[�`)�A�܂��́ARicati�s�����̉�X,Y(LMI�A�v���[�`)���g���Čv�Z����܂��B
%
% ����:
%  P         �v�����g��SYSTEM�s��(LTISYS���Q��)�B
%  R         D22�̃T�C�Y�A���Ȃ킿�AR = [ NY , NU ]�ł��B�����ŁA
%                   NY = �ϑ��ʂ̐�
%                   NU = ����ʂ̐�
%  GAMA      �v�������Hinf���\�B
%  X1,X2,..  Riccati�A�v���[�`: X = X2/X1��Y = Y2/Y1�́A2��Riccati����
%            ���̈��艻���ł��B
%            LMI�A�v���[�`    : X = X2/X1��Y = Y2/Y1�́A2��HinfRicca-
%                               ti�s�����̉��ł��B
%  TOLRED    �I�v�V����(�f�t�H���g�l=1.0e-4)�B
%            ���̏ꍇ�A�᎟���������s����܂��B
%                    rho(X*Y) >=  (1 - TOLRED) * GAMA^2
% �o��:                                                              -1
%  K         �p�b�N���ꂽ�`���̒��S�R���g���[��K(s) = DK + CK (zI-AK)  BK
%  GFIN      �ۏ؂��ꂽ���[�v���\(GAMA�́A���l�̈���̗��R�ɂ��A
%            GFIN > GAMA �Ƀ��Z�b�g����܂�)�B
%
% �Q�l�F    DHINFRIC.



% Copyright 1995-2002 The MathWorks, Inc. 
