% SIGMA   LTI���f���̓��ْl�v���b�g
%
% SIGMA(SYS) �́ALTI ���f�� SYS(TF,ZPK,SS,FRD �ɂ���č쐬���ꂽ)�̎��g��
% �����ɂ�������ْl(SV)�v���b�g���s���܂��B���g���ш�Ɠ_���͎����I��
% �I������܂��B���U���Ԃł̒��ӎ����ɂ��Ă̏ڍׂ́ABODE ���Q�Ƃ���
% ���������B
%
% SIGMA(SYS,{WMIN,WMAX}) �́AWMIN ���� WMAX �܂ł̎��g��(���W�A��/�b)��
% ������ SV �v���b�g��`���܂��B
%
% SIGMA(SYS,W) �́A���[�U�����W�A��/�b�Ŏw�肵�����g���̃x�N�g�� W ��
% ���p���A���̓_�Ŏ��g���������v�Z���܂��B�ΐ��X�P�[���ł̎��g���x�N�g��
% ���쐬���邽�߂ɂ́ALOGSPACE ���Q�Ƃ��Ă��������B
%
% SIGMA(SYS,W,TYPE)�A�܂��́ASIGMA(SYS,[],TYPE) �́A���̂悤�� TYPE ��
% �l�ɉ����ĕύX���� SV �v���b�g��`���܂��B
% 
%       TYPE = 1     -->     inv(SYS)��SV  
%       TYPE = 2     -->     I + SYS��SV
%       TYPE = 3     -->     I + inv(SYS)��SV 
% 
% ���̏�����p����Ƃ��ɂ́ASYS �͐����s��łȂ���΂����܂���B
%
% SIGMA(SYS1,SYS2,...,W,TYPE) �́A��������LTI���f�� SYS1,SYS2,... ��
% SV ������1�̃v���b�g�ɕ`���܂��B���� W �� TYPE �́A�I�v�V�����ł��B
% sigma(sys1,'r',sys2,'y--',sys3,'gx') �̂悤�ɁA�J���[�A���C���X�^�C��
% �}�[�J���w�肷�邱�Ƃ��ł��܂��B
% 
% SV = SIGMA(SYS,W) �� [SV,W] = SIGMA(SYS) �́A���g�������̓��ْl SV ��
% �o�͂��܂�(�v�Z�����s������g���̃x�N�g�� W ��ݒ肵�Ă��Ȃ��ꍇ�A
% ������܂߂�) ��ʂɃv���b�g�͕`���܂���B�s�� SV �́Alength(W) �̗�
% �������ASV(:,k) �����g�� W(k)�ł̓��ْl��^���܂��B
%
% Robust Control Toolbox�̏����̏ڍׂ́AHELP RSIGMA �ƃ^�C�v���Ă��������B
%
% �Q�l : BODE, NICHOLS, NYQUIST, FREQRESP, LTIVIEW, LTIMODELS.


%	Andrew Grace  7-10-90
%	Revised ACWG 6-21-92
%	Revised by Richard Chiang 5-20-92
%	Revised by W.Wang 7-20-92
%       Revised P. Gahinet 5-7-96
%       Revised A. DiVergilio 6-16-00
%       Revised K. Subbarao 10-11-01
%	Copyright 1986-2002 The MathWorks, Inc. 
