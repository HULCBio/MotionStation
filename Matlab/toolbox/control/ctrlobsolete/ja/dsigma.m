% DSIGMA   ���U���Ԑ��`�V�X�e���̓��ْl���g������
%
% DSIGMA(A,B,C,D,Ts) (�܂��́A�I�v�V�����Ƃ��āARCT �ł́ASIGMA(SS_,Ts)) 
% �́A�s��̓��ْl�v���b�g���쐬���܂��B
%                                       -1
%                 G(w) = C(exp(jwT)I-A) B + D 
% 
% �����́A���g���̊֐��ł��B���ْl�́ABode ���}�̑傫���̉����� MIMO 
% �V�X�e���Ɋg�債�����̂ł��B���g���͈̔͂Ɠ_���́A�����I�ɑI������܂��B
% �����V�X�e���ɑ΂��āADSIGMA(A,B,C,D,Ts,'inv') �́A�t�s��̓��ْl��
% �쐬���܂��B
%                -1                    -1      -1
%             G (w) = [ C(exp(jwT)I-A) B + D ]
% DSIGMA(A,B,C,D,Ts,W) �܂��́ADSIGMA(A,B,C,D,Ts,W,'inv')  �́A���ْl����
% ���v�Z������g���_�������x�N�g�� W ��ݒ肵�܂��B�P�ʂ́Arad/sec �ł��B
% �G���A�W���O�́ANyquist ���g��(pi/Ts)��荂�����g���Ő����܂��B���ӂ�
% �o�͈�����ݒ肵�Ȃ��ꍇ�A
% 
%        [SV,W] = DSIGMA(A,B,C,D,Ts,...)
%        [SV,W] = SIGMA(SS_,Ts,...)    (Robust Control Toolbox �̃��[�U�p)
% 
% ���g���x�N�g�� W �ƁAMIN(NU,NY)���Ƃ��Alength(W)���s�Ƃ���s�� SV ��
% �o�͂��܂��B�����ŁANU �͓��͐��ANY �͏o�͐��ł��B�X�N���[����Ƀv���b�g
% �\�����s���܂���B���ْl�́A�傫�����ɏo�͂���܂��B
%
% �Q�l : SIGMA, LOGSPACE, SEMILOGX, NICHOLS, NYQUIST, BODE.


%   Clay M. Thompson  7-10-90
%   Revised A.Grace 2-12-91, 6-21-92
%   Revised W.Wang 7/24/92
%   Revised P. Gahinet 5-7-96
%   Revised M. Safonov 9-12-97 & 4-18-98
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:56 $
