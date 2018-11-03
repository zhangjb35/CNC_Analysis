% @Author: kb
% @Date:   2018-10-31T11:13:54+08:00
% @Last modified by:   kb
% @Last modified time: 2018-10-31T14:10:35+08:00



tic
%% prep env
% clean
clear, clc, close all
restoredefaultpath; %% set a clean path
% addpath('/home/jinbo/.matlab/R2012b'); % for linux server only
% 设置路经
project_dir = ['/Volumes/Data/Project/CNC_Analysis'];% change to tfr_prep dir firsts
home_dir = fullfile(project_dir, 'data', 'behv');
matlab_dir = fullfile(project_dir, 'toolbox');
fuction_dir = fullfile(project_dir, 'functions');
% 加载需要工具
addpath(genpath(fullfile(matlab_dir, 'psignifit')));  %% initialize modelfree package
addpath(genpath(fuction_dir));

%% get data
targetData = readtable('targetData.csv');
rmDataList = importdata('removeSubj.txt');
%% remove subj do not need
for i=1:length(rmDataList)
    targetData = targetData(targetData.participant_id ~= rmDataList(i),:);
end
%% extract data
[rightSet,numerlSet,groupName] = grpstats(targetData.ButtonPush,{targetData.SoundCondition,targetData.NumCondition},{'sum','numel','gname'});
%xSets(:,i) = [2.7 2.8 2.9 3.1 3.2 3.3]; % 对数等距，log([15,16,18,22,24,27] 近似值
xSets = log([15,16,18,22,24,27]);
%xSets(:,i) = [15,16,18,22,24,27];% stimulus levels
rSets = reshape(rightSet,[6,5]);
mSets = reshape(numerlSet,[6,5]);
%% prep additional info
conditionName = {'No Sound','One Soft','One Loud','Multi Soft','Multi Loud'};
ColorUse = {'g','b','b','r','r'};
LineStyle = {'-',':','-',':','-'};
markerType = {'x','o','s','o','s'};
%% fit
fig=figure;
for j=1:5
    x = xSets';
    m = mSets(:,j);
    r = rSets(:,j);

    data = [x,r,m];
    options = struct;
    options.sigmoidName = 'norm';  % Gaussian
    options.expType     = 'YesNo';
    %options.logspace = 1; % 数据已经转换
    options.fixedPars = NaN(5,1);
    options.fixedPars(3) = 0; % 上漂移设置为 0
    options.fixedPars(4) = 0; % 下漂移设置为 0
    % options.expType = 'equalAsymptote'; % 期望概率分布对称
    options.estimateType   = 'MAP';
    %         options.borders = nan(5,2);
    %         options.borders(3,:)=[0,.05];
    %         options.borders(4,:)=[0,.05];
    result{j} = psignifit(data,options); % 拟合
    %         plotPrior(result{i,j} )
    %         plotMarginal( result{i,j},4);
    %% 绘图检查
    plotOptions = struct;
    plotOptions.CIthresh = false;
    plotOptions.aspectRatio = false;
    plotOptions.plotPar = true;
    plotOptions.lineColor = ColorUse{j};
    plotOptions.dataColor = ColorUse{j};
    plotOptions.linestyle = LineStyle{j};
    plotOptions.marker = markerType{j};
    plotOptions.fontSize = 18;
    [hline{j},hdataP{j}] = plotPsych(result{j}, plotOptions);
    hold on
    %% 标记进度
    disp([j]);
end
% 图形修饰
legend([hline{1} hline{2} hline{3} hline{4} hline{5}],conditionName{1},conditionName{2},conditionName{3},conditionName{4},conditionName{5},'location','northwest')
grid on
pbaspect([16 9 1]);
%xticks(log([15,16,18,20,22,24,27]));
xticks(log([15,16,18,20,22,24,27]));
xticklabels({'log(15)','log(16)','log(18)','log(20)','log(22)','log(24)','log(27)'});
yticks([0 0.25 0.5 0.75 1]);
yticklabels({'0','25','50','75','100'});
xlim([2.7,3.3]);
ylim([0,1])
title('Fitted PF curve (N=19)');
xlabel('Stimuli Levels');
ylabel('Proportion of ''More'' response (%)');
%set(gca,'box','on');
%% change mannually
print(fig,'N19_Subjs','-dpng','-r300')
close all
%% plot
%% expor
%{
%% Grand Average
[GrightSet,GnumerlSet,GgroupName] = grpstats(rawData.ButtonPush,{rawData.SoundCondition,rawData.NumCondition},{'sum','numel','gname'});
GrSets = reshape(GrightSet,[6,5]);
Gx =  [15;16;18;22;24;27];
Gm =  [440;440;440;440;440;440];
% plot
close all
fig=figure;
for j=1:5
    x = Gx;
    m = Gm;
    r = GrSets(:,j);
    data = [x,r,m];
    options = struct;
    options.sigmoidName = 'weibull';   % choose a cumulative Gaussian as the sigmoid
    options.expType     = 'YesNo';
    options.logspace = 1;
    options.fixedPars = NaN(5,1);
    %options.fixedPars(3) = [0:0.05];
    %options.fixedPars(4) = [0:0.05];
    %options.expType = 'equalAsymptote';
    result{j} = psignifit(data,options);

%     plotOptions = struct;
%     plotOptions.CIthresh = 'true';
%     plotOptions.aspectRatio = 'true';
%     plotOptions.lineColor = ColorUse{j};
%     plotOptions
%     [hline{j},hdata{j}] = plotPsych(result{j}, plotOptions);
%     hold on
    X25(j) = getThreshold(result{j},0.25,1);
    X50(j) = getThreshold(result{j},0.5,1);
    X75(j) = getThreshold(result{j},0.75,1);
end
%}
% message = 'Parametric Bootstrap (1) or Non-Parametric Bootstrap? (2): ';
% ParOrNonPar = input(message);
toc
