% GENPARAM ANFIS �w�K�p�̏��������o�V�b�v�֐��p�����[�^�̍쐬
% 
% GENPARAM(DATA,MF_N,MF_TYPE) �́AM �s N ��̌P���f�[�^�s�� DATA ���珉
% ������ MF �p�����[�^���쐬���܂��B�����ŁAM �͌P���f�[�^�y�A�̐��AN ��
% ���͐���1�����������̂ł��B
% 
% MF_N �� MF_TYPE �́A�e���͂� MF ���� MF �^�C�v�����ꂼ��ݒ肷��I�v�V
% �����̈����ł��BMF_N �́A���� N �̃x�N�g���łȂ���΂Ȃ�܂���BMF_N 
% ���X�J���ł���ꍇ�A��������ׂĂ̓��͂֓K�p���܂��B���l�ɁAMF_TYPE ��
% N �s�̕�����s��łȂ���΂Ȃ�܂���BMF_TYPE ���P��̕�����̏ꍇ�A��
% ������ׂĂ̓��͂֓K�p���܂��BMF_N �� MF_TYPE �̃f�t�H���g�l�́A���ꂼ
% ��A2�� 'gbellmf' �ł��B
%
% �쐬���ꂽ MF �̒��S�́A��ɓ��͕ϐ��̗̈扈���ɓ��Ԋu�ŋ�؂��܂��B
% �����ŁA�̈�� DATA �̑Ή������� min �� max �Ԃ̊Ԋu�Ƃ��Č��肵�Ă�
% �܂��B
%
% ��������
% (1) 'sigmf'�A'smf'�A'zmf'��MF�^�C�v�́A�����܂��͉E���̂ǂ��炩���J��
%     ���^�ɂȂ��Ă���̂ŃT�|�[�g����Ă��܂���B
% (2) ���� MF �^�C�v�́A�������͕ϐ��� MF �֊��蓖�Ă��܂��B
%
% ���
%    NumData = 1000;
%    data = [rand(NumData,1) 10*rand(NumData,1)-5 rand(NumData,1)];
%    NumMf = [3 7];
%    MfType = str2mat('trapmf','gbellmf');
%    MfParams = genparam(data,NumMf,MfType);
%    set(gcf,'Name','genparam','NumberTitle','off');
%    NumInput = size(data,2) - 1;
%    range = [min(data)' max(data)'];
%    FirstIndex = [0 cumsum(NumMf)];
%    for i = 1:NumInput;
%       subplot(NumInput,1,i);
%       x = linspace(range(i,1),range(i,2),100);
%       index = FirstIndex(i)+1:FirstIndex(i)+NumMf(i);
%       mf = evalmmf(x,MfParams(index,:),MfType(i,:));
%       plot(x,mf');
%       xlabel(['input ' num2str(i) ' (' MfType(i,:) ')']);
%    end
%
% �Q�l    GENFIS1, ANFIS.



%   Copyright 1994-2002 The MathWorks, Inc. 
