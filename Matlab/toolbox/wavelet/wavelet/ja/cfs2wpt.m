% CFS2WPT   �W������E�F�[�u���b�g�p�P�b�g�c���[���\�z
%
% CFS2WPT �́A�E�F�[�u���b�g�p�P�b�g�c���[�Ɗ֘A�����͐M���A�܂���
% �C���[�W���\�z���܂��B
%
% [T,X] = CFS2WPT(WNAME,SIZE_OF_DATA,TN_OF_TREE,ORDER,CFS) �́A�E�F�[�u
% ���b�g�p�P�b�g�c���[ T �Ɗ֘A�����͐M���A�܂��̓C���[�W X ���o�͂�
% �܂��B
%
%   WNAME �́A��͂Ɏg�p����E�F�[�u���b�g���ł��B
%   SIZE_OF_DATA �́A��͐M���A�܂��̓C���[�W�̑傫���ł��B
%   TN_OF_TREE �́A�c���[�̏I�[�m�[�h�C���f�b�N�X���܂ރx�N�g���ł��B
%   ORDER �́A�M���ɑ΂���2�A�C���[�W�ɑ΂���4�ł��B
%   CFS �́A�I���W�i���M���A�܂��̓C���[�W���č\�����邽�߂ɁA�g�p����
%       �W�����܂񂾃x�N�g���ł��B
%
% CFS �́A�I�v�V�����ł��BCFS2WPT ���ACFS ���̓p�����[�^�Ȃ��Ŏg��ꂽ
% �ꍇ�A���ׂẴc���[�W����(X ����ł��邱�Ƃ��Ӗ�����)��ɂȂ�܂����A
% �E�F�[�u���b�g�p�P�b�g�c���[�\�� (T) �͐�������܂��B
%
% ���:
%     load detail
%     t = wpdec2(X,2,'sym4');
%     cfs = read(t,'allcfs');
%     noisyCfs = cfs + 40*rand(size(cfs));
%     noisyT = cfs2wpt('sym4',size(X),tnodes(t),4,noisyCfs);
%     plot(noisyT)
%
%     t = cfs2wpt('sym4',[1 1024],[3 9 10 2]',2);
%     sN = read(t,'sizes',[3,9]);
%     sN3 = sN(1,:); sN9 = sN(2,:);
%     cfsN3 = ones(sN3);
%     cfsN9 = randn(sN9);
%     t = write(t,'cfs',3,cfsN3,'cfs',9,cfsN9);
%     plot(t)


%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Aug-2001.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2003/04/18 18:11:52 $
