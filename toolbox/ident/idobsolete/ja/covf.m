% COVF  �f�[�^�s��ɑ΂��鋤���U�֐��̐���
% 
%   R = COVF(Z, M)
%
%   Z : N �s nz ��̍s��f�[�^�B�T�^�I�ɁAZ = [y u]�B
%
%   M : �����U�֐������肳���(�ő�x�� - 1)�B
%
%   R : Z �̋����U�֐��B�v�f R((i+(j-1)*nz, k+1) ���AE[Zi(t) * Zj(t+k)]
%       �ƂȂ�܂��B�]���āAR �̃T�C�Y�� nz^2 �s M ��ƂȂ�܂��B���f��
%       �f�[�^ z �ɑ΂��āA
%       RESHAPE(R(:,k+1), nz, nz) = E[z(t)*z'(t+k)] (z' �͕��f����]�u)�B
%
% nz<3 �̏ꍇ�AFFT �A���S���Y�������p����A�������T�C�Y���ߖ񂳂�܂��B
% nz>2 �̏ꍇ�A���ژa���v�Z������@��(CONVF2 ��)���p����܂��B
%
% �������̐ߖ�̂��߂ɁA���̂悤�Ɏ��s���܂��B
% 
%      R = COVF(Z, M, maxsize)
% 
% ���̃I�v�V�����̗��p�@�Ɋւ��ẮAAUXVAR ���Q�Ƃ��Ă��������B

%   Copyright 1986-2001 The MathWorks, Inc.
