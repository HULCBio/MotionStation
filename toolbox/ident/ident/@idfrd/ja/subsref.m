% SUBSREF �́AIDFRD ���f���p��subsref ���\�b�h�ł��B
%    
%      H(Outputs,Inputs) �́AI/O �`�����l���̃T�u�Z�b�g��I�����܂��B
%      H.Fieldname �́AGET(MOD,'Filedname') �Ɠ����ł��B
% �����̕\���́AH(1,[2 3]).inputname �A�܂��́Asqueeze(H.cov(25,2,3,:,:))
% �̂悤�ȁA�T�u�X�N���v�g�Q�ƂƂ��Đ������L�@�𗘗p�ł��܂��B
% 
% �`�����l���Q�Ƃ́A�`�����l������ԍ��Őݒ肳��܂��B
% 
%     H('velocity',{'power','temperature'})
% 
% �P�o�̓V�X�e���ɑ΂��āAH(ku) �͓��̓`�����l�� ku ��I�����A�P���̓V�X
% �e���ɑ΂��āAH(ky) �́A�o�� ky ��I�����܂��B
%
% H('measured') �́A���肳�ꂽ���̓`�����l����I�����A�m�C�Y���͂𖳎���
% �܂��B�����āAResponseData �� CovarianceData �݂̂��L�[�v���܂��B
%
% H('noise') �́ASpectrumData �� NoiseCovariance �𒊏o���܂��B



%   Copyright 1986-2001 The MathWorks, Inc.
