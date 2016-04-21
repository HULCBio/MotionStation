% DNYQUIST   ���U���Ԑ��`�V�X�e���ɑ΂��� Nyquist���g������
%
% DNYQUIST(A,B,C,D,Ts,IU) �́A���� IU ����V�X�e��
%                                                    -1
%      x[n+1] = Ax[n] + Bu[n]    G(w) = C(exp(jwT)I-A) B + D  
%      y[n]   = Cx[n] + Du[n]    RE(w) = real(G(w)), IM(w) = imag(G(w))
%
% �̂��ׂĂ̏o�͂܂ł� Nyquist���}���쐬���܂��B���g���͈̔͂Ɠ_���́A
% �����I�ɋ��܂�܂��B
%
% DNYQUIST(NUM,DEN,Ts) �́A�������`�B�֐� G(z) = NUM(z)/DEN(z) �ɑ΂��� 
% Nyquist���}���쐬���܂��B�����ŁANUM �� DEN �́A�������̌W���� z ��
% �~�x�L�̏��ɕ��ׂ����̂ł��B
%
% DNYQUIST(A,B,C,D,Ts,IU,W) �܂��́ADNYQUIST(NUM,DEN,Ts,W) �́ANyqusit
% �������v�Z������g���_�������x�N�g�� W ��ݒ肵�܂��B�P�ʂ́Arad/sec 
% �ł��B�G���A�W���O�́ANyquist ���g��(pi/Ts)��荂�����g���Ő����܂��B
% ���ӂɏo�͈�����ݒ肵�Ȃ��ꍇ�A
% 
%    [RE,IM,W] = DNYQUIST(A,B,C,D,Ts,...)
%    [RE,IM,W] = DNYQUIST(NUM,DEN,Ts,...) 
% 
% �v�Z�������g���x�N�g�� W �ƍs�� RE �� IM ���o�͂��܂��B�����́A
% �o�͐��Ɠ����񐔂������Alength(W) �ɓ������s���������Ă��܂��B�X�N���[��
% ��Ƀv���b�g�\�����s���܂���B
%
% �Q�l : LOGSPACE,MARGIN,DBODE, DNICHOLS.


%   J.N. Little 10-11-85
%   Revised A.C.W.Grace 8-15-89, 2-12-91, 6-21-92
%   Revised Clay M. Thompson 7-9-90, AFP 10-1-94, PG 6-24-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:53 $
