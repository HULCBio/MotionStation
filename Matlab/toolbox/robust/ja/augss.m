% AUGSS   W1,W2,W3 (��ԋ�Ԍ^)��2�|�[�g�v�����g�ւ̊g��
%
%  [TSS_] = AUGSS(SS_G,SS_W1,SS_W2,SS_W3,W3POLY)�܂���
%  [A,B1,B2,C1,C2,D11,D12,D21,D22] = AUGSS(AG,BG,CG,DG,AW1,BW1,CW1,DW1,...
% AW2,BW2,CW2,DW2,AW3,BW3,CW3,DW3,W3POLY)�́A���̂悤�ȏd�ݕt���ɂ�
% ��g�傳�ꂽ�v�����g�̏�ԋ�ԃ��f�����v�Z���܂��B
%
%     W1 = ss_w1 = mksys(aw1,bw1,cw1,dw1); ---- �덷�M��'e'�ɑ΂���d��
%     W2 = ss_w2 = mksys(aw2,bw2,cw2,dw2); ---- ����M��'u'�ɑ΂���d��
%     W3 = ss_w3 + w3poly ---- �o�͐M��'y'�ɑ΂���d��
%   
% ������
%     ss_w3 = mksys(aw3,bw3,cw3,dw3);
%     w3poly := �~���ɕ��ׂ�ꂽ�������s��(�I�v�V��������)
%             = [w3(n),w3(n-1),...,w3(0)]
%               size(w3(i))=size(dw3) (i=0,1,...,n)
%
% ����: 1) ��L�̏d�݊֐��́Ass_w1, ss_w2, ss_w3��mksys([],[],[],[])�Ɛ�
%          �肷�邱�Ƃɂ���č폜����܂��B
%       2) w3poly�́A�ȗ������ƃf�t�H���g��[]�ɂȂ�܂��B
%
% �g�傳�ꂽ�V�X�e���́ATSS_=mksys(A,B1,B2,C1,C2,D11,D12,D21,D22,'tss')
% �ł��B



% Copyright 1988-2002 The MathWorks, Inc. 
