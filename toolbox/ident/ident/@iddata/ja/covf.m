% COVF �́A�f�[�^�s��̋����U�֐����v�Z���܂��B
%   R = COVF(DATA,M)
%
%   DATA : IDDATA �f�[�^�I�u�W�F�N�g�AHelp IDDATA ���Q��   
%
%   M: �ő�x�� - 1�ŁA�����U�֐��Ő��肳��܂��B
%   Z �́A�o��-���̓f�[�^�FZ = [Data.OutputData, Data.InputData].
%   R : Z �̋����U�֐��A�v�f R((i+(j-1)*nz,k+1) �́AE Zi(t) * Zj(t+k)�Ƃ�
%       ��܂��B
%       R �̃T�C�Y�́Anz^2 x M �ł��B
% ���f���f�[�^ z �ɑ΂��āARESHAPE(R(:,k+1),nz,nz) = E z(t)*z'(t+k) �Ƃ�
% ��܂�(z' �́A���f����]�u�ł�)�B
%
% nz<3 �ɑ΂��āAFFT �A���S���Y�����g���A�������T�C�Y�ɐ���������܂��B
% nz>2 �ɑ΂��āA���ژa���v�Z������@���g���܂�(COVF2)
%
% �������̃g���[�h�I�t�́A
% 
%   R = COVF(Z,M,maxsize)
% 
% �ɂ��^�����܂��B
%
% �Q�l�F IDPROPS ALGORITHM  �I�v�V�����̗��p�@�Ɋւ��āB

%   L. Ljung 10-1-86,11-11-94


%   Copyright 1986-2001 The MathWorks, Inc.