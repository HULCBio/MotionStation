% COVAR   LTI���f���̔��F�m�C�Y���͂ɑ΂��鉞���̋����U
%
% P = COVAR(SYS,W) �́ALTI���f�� SYS ���K�E�X���z���锒�F�m�C�Y���͂�
% ����ė�N����Ƃ��A�o�͋����U P = E[yy'] ���v�Z���܂��B�m�C�Y�̑傫�� 
% W �́A�A���n�̂Ƃ��A
% 
%   E[w(t)w(tau)'] = W delta(t-tau)  (delta(t) = Dirac delta)
%
% �ŁA���U�n�̂Ƃ��́A
%
%   E[w(k)w(n)'] = W delta(k,n)  (delta(k,n) = Kronecker delta)
%
% �Œ�`����܂��B�s����ȃV�X�e����[���łȂ����B�������A�����ԃ��f��
% �́A������̏o�͋����U�ɂȂ邱�Ƃɒ��ӂ��Ă��������B
%
% [P,Q] = COVAR(SYS,W) �́ASYS ����ԋ�ԃ��f���̏ꍇ�A��ԋ����U 
% Q = E[xx'] ���o�͂��܂��B
%
% SYS ���A[NY NU S1 ... Sp] �̎���������LTI���f���̔z��̏ꍇ�A�z�� P 
% �́A[NY NY S1 ... Sp] �̎���������
% 
%   P(:,:,k1,...,kp) = COVAR(SYS(:,:,k1,...,kp))
% 
% �ł��B
%
% �Q�l : LTIMODELS, LYAP, DLYAP.


%   Clay M. Thompson  7-3-90
%       Revised by Wes Wang 8-5-92
%       P. Gahinet  7-22-96
%   Copyright 1986-2002 The MathWorks, Inc. 
