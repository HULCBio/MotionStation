% CSAPI   �ߓ_�łȂ��[�_���������L���[�r�b�N�X�v���C�����
%
% PP  = CSAPI(X,Y)  �́A�ߓ_�ł͂Ȃ��[�_�������g���ė^����ꂽ�f�[�^ 
% (X,Y) �ւ�(pp-�^��)�L���[�r�b�N�X�v���C����Ԃ��o�͂��܂��B
% ��Ԃ́A�f�[�^�T�C�g X(j) �ŁA�^����ꂽ�f�[�^�l Y(:,j), j=1:length(X) 
% �Ɉ�v���܂��B�f�[�^�l�́A�X�J���A�x�N�g���A�s��A�܂���N�����z��ł��B
% �����T�C�g�̃f�[�^�_�́A���ω�����܂��B
% �O���b�h�����ꂽ�f�[�^�ւ̕�Ԃɂ��ẮA�ȉ����Q�Ƃ��Ă��������B
%
% CSAPI(X,Y,XX) �́AFNVAL(CSAPI(X,Y),XX) �Ɠ����ł��B
%
% ���Ƃ���, 
%
%      values = csapi([-1:5]*(pi/2),[-1 0 1 0 -1 0 1], linspace(0,2*pi));
%
% �́A���̋�ԑS�̂Ő����֐��ɑ΂��ċ����قǓK�؂ōׂ������^���܂��B
%
% �܂��A�ȉ��̂悤�ɁA��`�̃O���b�h��Ńf�[�^�l���Ԃ��邱�Ƃ��\�ł��B
%
% PP = CSAPI({X1, ...,Xm},Y) �́Aji=1:length(Xi) �� i=1:m �ɑ΂��āA
% �f�[�^�T�C�g (X1(j1), ..., Xm(jm)) �Ńf�[�^�l Y(:,j1,...,jm) �Ɉ�v
% ����m�_��(pp-�^��)�L���[�r�b�N�X�v���C����Ԃ��o�͂��܂��B
% �e Xi �̗v�f�����ʂ���Ȃ���΂Ȃ�܂���B���R���̃x�N�g�� d �ŁA�֐���
% �X�J���l�̂Ƃ��Ɏ󂯓���邱�Ƃ̂ł����� d �Ƃ��āAY �́A
% [d,length(X1),...,.length(Xm)] �̑傫���łȂ���΂Ȃ�܂���B
%
% CSAPI({X1, ...,Xm},Y,XX) �́AFNVAL(CSAPI({X1,...,Xm},Y),XX) �Ɠ����ł��B
%
% ���Ƃ��΁A���̍\���́A2�ϐ��֐����Ԃ����}���쐬���܂��B
%
%      x = -1:.2:1; y=-1:.25:1; [xx, yy] = ndgrid(x,y); 
%      z = sin(10*(xx.^2+yy.^2)); pp = csapi({x,y},z);
%      fnplt(pp)
%
% �����ŁANDGRID �̑���� MESHGRID ���g�p����ƁA�G���[�ɂȂ�܂��B
%
% �Q�l : CSAPE, SPAPI, SPLINE, NDGRID.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
