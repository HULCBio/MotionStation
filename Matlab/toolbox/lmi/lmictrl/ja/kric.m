% [K,gfin]=kric(P,r,gama,X1,X2,Y1,Y2,tolred)
%
% �W���̘A�����ԃv�����gP(s)��^���AGAMA > 0�̂Ƃ��ɁA���SHinf�R���g���[
% ��K(s)���v�Z���܂��B���̃R���g���[���́A���𖞑����܂��B
% 
%   * �v�����g������I�Ɉ��艻���܂��B
%   * ���[�v�Q�C����GAMA�ȉ��ɂ��܂��B
% 
% K(s)�́A2��HinfRiccati�������̈��艻��X=X2/X1��Y=Y2/Y1����v�Z�����
% ���B
%
% ����:
%  P           �v�����g��SYSTEM�s��(LTISYS���Q��)�B
%  R           D22�̃T�C�Y�A���Ȃ킿�AR = [ NY , NU ]�B�����ŁA
%                     NY = �ϑ��ʂ̐�
%                     NU = ����ʂ̐�
%  GAMA        �v�������Hinf���\�B
%  X1,X2,...   X = X2/X1��Y = Y2/Y1�́A2��HinfRiccati�������̈��艻��
%              �ł��B
%  TOLRED      �I�v�V����(�f�t�H���g�l= 1.0e-4)�B
%              ���̏ꍇ�A�᎟�������B������܂��B
%              rho(X*Y) >=  (1 - TOLRED) * GAMA^2
% �o��:                                                              
%  K           SYSTEM�s��`���̒��S�R���g���[��
%                                        -1
%                   K(s) = DK + CK (sI-AK)  BK
%  GFIN        �ۏ؂��ꂽ���[�v���\
%              (GAMA�́A���l�I���萫�̗��R�ɂ��AGFIN > GAMA�Ƀ��Z�b�g
%              ����邱�Ƃ�����܂�)
%
% �Q�l�F    HINFRIC.



% Copyright 1995-2002 The MathWorks, Inc. 
