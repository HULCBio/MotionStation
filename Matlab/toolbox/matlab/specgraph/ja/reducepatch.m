% REDUCEPATCH   �p�b�`�̖ʂ̐��̍팸
%
% REDUCEPATCH(P, R) �́A�p�b�`�S�̂̌`��ێ������܂܁A�p�b�` P �̖ʂ�
% �������炵�܂��BR ��1�ȉ��̏ꍇ�A�I���W�i���̖ʂ̈ꕔ���Ƃ��ĉ��߂���
% �܂��B���Ƃ��΁AR ��0.2�̏ꍇ�͖ʂ�20%���ێ�����܂��BR ��1���傫
% ����΁AR �͖ʂ̃^�[�Q�b�g���ɂȂ�܂��B���Ƃ��΁AR��400�̏ꍇ�́A
% �ʂ̐���400�̖ʂ��c��܂Ō��炳��܂��Bpatch�����L����Ă��Ȃ����_��
% �܂ޏꍇ�́A���L����钸�_���ʂ����炷�O�Ɍv�Z����܂��B�p�b�`�̖ʂ�
% �O�p�`�łȂ��ꍇ�́A�ʂ����炷�O�ɎO�p�`�ɂ��܂��B�o�͂����ʂ́A
% ��ɎO�p�`�ł��B 
%
% NFV = REDUCEPATCH(P, R) �́A�팸���ꂽ�ʂƒ��_�̏W�����o�͂��܂����A
% �p�b�` P�� Faces �v���p�e�B�� Vertices �v���p�e�B��ݒ肵�܂���B
% �\���� NFV �͍팸��̖ʂƒ��_���܂݂܂��B
% 
% NFV = REDUCEPATCH(FV, R) �́A�\���� FV ����ʂƒ��_���g�p���܂��B
% 
% REDUCEPATCH(P) �܂��� NFV = REDUCEPATCH(FV) �́A.5�̍팸�����肵�܂��B
%
% REDUCEPATCH(...,'fast') �́A���_�����j�[�N�ŁA���L���ꂽ���_���v�Z
% ���Ȃ��Ɖ��肵�Ă��܂��B
% 
% REDUCEPATCH(...,'verbose') �́A�v�Z�̐i�s�󋵂ɘA��A�R�}���h�E�C���h�E
% �ɏ󋵂�\�����b�Z�[�W��\�����܂��B
% 
% NFV = REDUCEPATCH(F, V, R) �́A�z��F�����V���̖ʂ���ђ��_���g�p���܂��B
% 
% [NF�ANV] = REDUCEPATCH(...) �́A�ʂƒ��_���\���̂̑����2�̔z���
% �o�͂��܂��B
%
% ����: �o�͎O�p�`�̐��́A���ɓ��̖͂ʂ��O�p�`�łȂ������ꍇ�́A�팸�l��
% �w�肵�����̂Ɛ��m�Ɉ�v���܂���B
%
% ���:
% 
%      [x y z v] = flow;
%      fv = isosurface(x, y, z, v, -3);
%      subplot(1,2,1)
%      p = patch(fv);
%      set(p, 'facecolor', [.5 .5 .5], 'EdgeColor', 'black');
%      daspect([1 1 1]); view(3); axis tight
%      title([num2str(length(get(p, 'faces'))) ' Faces'])
%      subplot(1,2,2)
%      p = patch(fv);
%      set(p, 'facecolor', [.5 .5 .5], 'EdgeColor', 'black');
%      daspect([1 1 1]); view(3); axis tight
%      reducepatch(p, .15) % �ʂ� 15% ��ێ� 
%      title([num2str(length(get(p, 'faces'))) ' Faces'])
%
% �Q�l�FISOSURFACE, ISOCAPS, ISONORMALS, SMOOTH3, SUBVOLUME,
%       REDUCEVOLUME.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:05:34 $
