% EDGETAPER �C���[�W�G�b�W�ɉ������s�A���Ƀe�[�p��^���܂��B
% J = EDGETAPER(I,PSF) �́A�_�����x�֐� PSF ���g���āA�C���[�W I �̃G�b
% �W��s�N���ɂ��܂��B�o�̓C���[�W J �́A�I���W�i���C���[�W I �Ƃ��̕s
% �N���ɂȂ����o�[�W�����̏d�ݕt���a�ŕ\�킹�܂��BPSF �̎��ȑ��֊֐���
% ���肳���d�݂Ɋւ���z��́A���S����I �̂��̂Ɠ������A�G�b�W�̋ߖT
% �ł́AI ��s�N���ɂ����o�[�W�����ɓ������Ȃ���̂ł��B
%
% �֐� EDGETAPER �́A���U�t�[���G�ϊ����g�����A�C���[�W�𖾗ĉ�������@�A
% ���Ƃ��΁ADECONWNR, DECONVREG, DECONVLUCY �ŁA�����M���O�̉e����ጸ
% ���܂��B
%
% PSF �̃T�C�Y���A�C�ӂ̎����̒��̃C���[�W�T�C�Y�̔�����菬�����K�v��
% ����܂��B
%
% �N���X�T�|�[�g  
% -------------
% I �� PSF �́A�N���X uint8, uint16, double �̂����ꂩ�ł��BJ �́AI ��
% �����N���X�ł��B
%
% ���  
%   -------
%      I   = imread('cameraman.tif');
%      PSF = fspecial('gaussian',60,10); 
%      J  = edgetaper(I,PSF);
%      subplot(1,2,1);imshow(I,[]);title('original image');
%      subplot(1,2,2);imshow(J,[]);title('edges tapered');
%
% �Q�l�FDECONVWNR, DECONVREG, DECONVLUCY, PADARRAY, PSF2OTF, OTF2PSF.



%   Copyright 1993-2002 The MathWorks, Inc.  
