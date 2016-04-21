%function [gaml,gamu]=sdhfnorm(sdsys,k,h,delay,tol);
%
% ���̊֐��́A���z�̃T���v���ƃ[�����z�[���h��ʂ��Č������ꂽ���U����
% SYSTEM�s��Ƃ̃t�B�[�h�o�b�N�ɂ����āA�A���nSYSTEM�s���L2�U���m����
% ���v�Z���܂��B
%
% �A�����ԃv�����gSDSYS�́A���̂悤�ɕ�������܂��B
%                        | a   b1   b2   |
%            sdsys    =  | c1   0    0   |
%                        | c2   0    0   |
%
% d�́A�[���łȂ���΂Ȃ�܂���B
%
% ����:
%   SDSYS  - �A������SYSTEM�s��(�v�����g)
%   K      - ���U���ԍs��(�R���g���[��)
%   H      - �R���g���[��K�̃T���v�����O����
%   DELAY  - �R���g���[���̌v�Z��̒x���^����񕉂̐���(�f�t�H���g 0)
%   TOL    - �����̏I�����̏�E�Ɖ��E�̊Ԃ̍�(�f�t�H���g 0.001)
% �o��:
%   GAMU   - �m�����̏�E
%   GAML   - �m�����̉��E
%
%
%	                _________
%	               |         |
%	     z <-------|  sdsys  |<-------- w
%	               |         |
%	      /--------|_________|<-----\
%	      |       __  		 |
%	      |      |d |		 |
%	      |  __  |e |   ___    __    |
%	      |_|S |_|l |__| K |__|H |___|
%	        |__| |a |  |___|  |__|
%	             |y |
%	             |__|
%
% �Q�l: DHFNORM, DHFSYN, DTRSP, H2SYN, H2NORM, HINFFI, HINFNORM,
%       RIC_EIG, RIC_SCHR, SDTRSP, SDHFNORM.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
