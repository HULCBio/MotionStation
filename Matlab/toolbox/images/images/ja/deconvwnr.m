% DECONVWNR  Wiener �t�B���^���g���āA�C���[�W�̍č\�� 
% J = DECONVWNR(I,PSF) �́AWiener �t�B���^�A���S���Y�����g���āA�C���[�W
% I �𕪉����A���ĉ������C���[�W J ���o�͂��܂��B�C���[�W I �́A�^�̃C��
% �[�W�Ɠ_�����x�֐� PSF ���R���{�����[�V�������A�m�C�Y��t���������̂ƍl
% ���܂��B�A���S���Y���́A���肵���C���[�W�Ɛ^�̃C���[�W�̊Ԃ̍����A�C��
% �[�W��m�C�Y�̑��֍s��𗘗p���āA�ŏ����덷�̈Ӗ��ōœK�����܂��B�m
% �C�Y�����݂��Ȃ��ꍇ�AWiener �t�B���^�́A���z�I�ȋt�t�B���^�ɂȂ�܂��B
%
% �č\���̎������ǂ��邽�߂ɁA���̕t���I�ȃp�����[�^��n�����Ƃ��ł���
% ���B
%   J = DECONVWNR(I,PSF,NSR)
%   J = DECONVWNR(I,PSF,NCORR,ICORR), ������
%
% NSR �́A�m�C�Y�ƐM���̃p���[�̔�ł��BNSR �́A�X�J���A�܂��́AI �Ɠ���
% �T�C�Y�̔z��ŁA�f�t�H���g��0�ł��B
%
% NCORR �� ICORR �́A�m�C�Y NCORR �ƃI���W�i���C���[�W ICORR �̎��ȑ��֊�
% ���ł��BNCORR �� ICORR �́A�I���W�i���C���[�W��莟���A�T�C�Y�Ƃ�������
% ���̂ł��BN-������ NCORR �� ICORR �z��́A�e�����̒��̎��ȑ��ւɑΉ���
% �܂��B�x�N�g�� NCORR �A�܂��́AICORR �́APSF ���x�N�g���̏ꍇ�A�ŏ��̎�
% ���Ɏ��ȑ��֊֐���\�킵�܂��BPSF ���z��̏ꍇ�A1�������ȑ��֊֐��́APSF
% �̂��ׂẴV���O���g���łȂ������ɑΏ̐��������āA�O�}����܂��B�X�J�� 
% NCORR�A�܂��́AICORR �́A�m�C�Y�A�܂��́A�C���[�W�̃p���[��\�킵�܂��B
%
% �o�̓C���[�W J �́A�A���S���Y���̒��Ŏg���闣�U�t�[���G�ϊ����N������
% �����M���O���w�����Ă��邱�Ƃɒ��ӂ��Ă��������BDECONVWNR ���R�[������
% �O�ɁAI = EDGETAPER(I,PSF) ���g���āA�����M���O��ቺ�����Ă��������B
%
% �N���X�T�|�[�g
% -------------
% I �� PSF �́A�N���X uint8, uint16, double �̂����ꂩ�ł��A���̓��͂́A
% �N���X double �ŁAJ �� I �Ɠ����N���X�ł��B
%
% ���
% -------
%
%      I = checkerboard(8);
%      noise = 0.1*randn(size(I));
%      PSF = fspecial('motion',21,11);
%      Blurred = imfilter(I,PSF,'circular');
%      BlurredNoisy = im2uint8(Blurred + noise);
%      
%      NSR = sum(noise(:).^2)/sum(I(:).^2);% �m�C�Y�ƃp���[�̔�
%      
%      NP = abs(fftn(noise)).^2;% �m�C�Y�̃p���[
%      NPOW = sum(NP(:))/prod(size(noise));
%      NCORR = fftshift(real(ifftn(NP)));% �m�C�Y�̎��ȑ��֊֐����v�Z�� 
%                                        % ���ёւ�
%      IP = abs(fftn(I)).^2;% �I���W�i���C���[�W�̃p���[
%      IPOW = sum(IP(:))/prod(size(I));
%      ICORR = fftshift(real(ifftn(IP)));% �C���[�W�̎��ȑ��ւ��v�Z���A
%                                        % ���בւ�
%      ICORR1 = ICORR(:,ceil(size(I,1)/2));
%
%      NSR = NPOW/IPOW;% �m�C�Y�ƃp���[�̔�
%      
%      subplot(221);imshow(BlurredNoisy,[]);
%                     title('A = Blurred and Noisy');
%      subplot(222);imshow(deconvwnr(BlurredNoisy,PSF,NSR),[]);
%                     title('deconvwnr(A,PSF,NSR)');
%      subplot(223);imshow(deconvwnr(BlurredNoisy,PSF,NCORR,ICORR),[]);
%                     title('deconvwnr(A,PSF,NCORR,ICORR)');
%      subplot(224);imshow(deconvwnr(BlurredNoisy,PSF,NPOW,ICORR1),[]);
%                     title('deconvwnr(A,PSF,NPOW,ICORR_1_D)');
%
% �Q�l�FDECONVREG, DECONVLUCY, DECONVBLIND, EDGETAPER, PADARRAY, 
%       PSF2OTF, OTF2PSF.



%   Copyright 1993-2002 The MathWorks, Inc.  
