% @Author: kb
% @Date:   2018-10-30T14:57:53+08:00
% @Last modified by:   kb
% @Last modified time: 2018-10-31T14:58:39+08:00



%% 心理物理曲线拟合
tic
%% 准备工作环境
% 清理
clear, clc
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

%% 数据导入
% 设定目标数据
data_file_behv = cell2mat(kb_ls(fullfile(pwd,'raw_data','sub*.csv')));
rawData = readtable(data_file_behv);

%% 添加按键识别变量，设置初始值为0
rawData.ButtonPush = zeros(length(rawData.participant_id),1); % 0 = less;1=more
% 按键读取
for i=1:length(rawData.participant_id)
    if rawData.NumCondition(i)<=3 && rawData.ACC(i)==1 % small num with right resp = less button; acc = 1 mean right response
        rawData.ButtonPush(i)=0;
    elseif rawData.NumCondition(i)<=3 && rawData.ACC(i)==0 % small num with wrong resp = more button
        rawData.ButtonPush(i)=1;
    elseif rawData.NumCondition(i)>3 &&rawData.ACC(i)==1 % bigger num with right resp = more button
        rawData.ButtonPush(i)=1;
    elseif rawData.NumCondition(i)>3 && rawData.ACC(i)==0 % bigger num with wrong resp = less button
        rawData.ButtonPush(i)=0;
    end
end

%% 清理数据
% RT must bigger than 100 ms
targetData = rawData(rawData.RT>=100,:);
% [fout01,xout1,~,~] = ksdensity(targetData.RT,'function','pdf','NumPoints',10000);
% [fout0,xout,~,~] = ksdensity(targetData.RT,'function','cdf','NumPoints',10000);
% [c index] = min(abs(fout0-0.95));
% subplot(2,1,1)
% H1 = area(xout(1:index),fout01(1:index));
% set(H1(1),'FaceColor',[250,128,114]./255);
% H1.EdgeColor='r';
% hold on
% plot(xout1,fout01,'Color','r');
% xlim([0,7000])
% xlabel('RT(ms)');
% ylabel('Density');
% grid on
% hold off
%
% subplot(2,1,2)
% H2=area(xout(1:index),fout0(1:index));
% set(H2(1),'FaceColor',[250,128,114]./255);
% H2.EdgeColor='r';
% grid on
% hold on
% plot(xout,fout0,'Color','r');
% xlim([0,7000]);
% xlabel('RT(ms)');
% ylabel('Cumulative Density');
% hold off
% % uplimit
% uplimit = xout(index);
% title(['Uplimit(95%) = ' sprintf('%04.1f',uplimit) ' ms']);
% print('uplimitDecide','-dpng','-r300');
% close all
% % screen data
% targetData = targetData(targetData.RT < uplimit,:);
%targetData = rawData;
% response info

%% 提取需要的数据
[rightSet,numerlSet,groupName] = grpstats(targetData.ButtonPush,{targetData.participant_id,targetData.SoundCondition,targetData.NumCondition},{'sum','numel','gname'});
for i=1:length(unique(targetData.participant_id))
    %xSets(:,i) = [2.7 2.8 2.9 3.1 3.2 3.3]; % 对数等距，log([15,16,18,22,24,27] 近似值
    xSets(:,i) = log([15,16,18,22,24,27]);
    %xSets(:,i) = [15,16,18,22,24,27];% stimulus levels
end
rSets = reshape(rightSet,[6,5,22]);
mSets = reshape(numerlSet,[6,5,22]);

%% 识别 15，16，24，27存在概率水平（50%）反应表现的被试
checkSets = rSets./mSets;
focusSets_12 = checkSets([1,2],:,:);
focusSets_56 = checkSets([5,6],:,:);
checkResult = find(squeeze(sum(sum(focusSets_12 >= 0.5))+sum(sum(focusSets_56 <= 0.5)))==1);

%% 设定变量名称及可能用到的颜色编码
% "1=>nosound","2=>one-soft-sound","3=>one-loud-sound","4=>multi-soft-sound","5=>multi-loud-sound"
conditionName = {'No Sound','One Soft','One Loud','Multi Soft','Multi Loud'};
%conditionNameMarker =  {'Resonse Data No Sound','Resonse Data One Soft','Resonse Data One Loud','Resonse Data Multi Soft','Resonse Data Multi Loud'};
ColorUse = {'g','b','b','r','r'};
LineStyle = {'-',':','-',':','-'};
markerType = {'x','o','s','o','s'};

%% 针对个体进行曲线拟合
for i=1:22
    fig=figure;
    for j=1:5
        x = xSets(:,i);
        m = mSets(:,i);
        r = rSets(:,j,i);
        
        data = [x,r,m];
        options = struct;
        options.sigmoidName = 'norm';  % Gaussian
        options.expType     = 'YesNo';
        %options.logspace = 1; % 数据已经转换
        options.fixedPars = NaN(5,1);
        options.fixedPars(3) = 0; % 上漂移设置为 0
        options.fixedPars(4) = 0; % 下漂移设置为 0
        %options.expType = 'equalAsymptote'; % 期望概率分布对称
        options.estimateType   = 'MAP';
        %         options.borders = nan(5,2);
        %         options.borders(3,:)=[0,.05];
        %         options.borders(4,:)=[0,.05];
        result{i,j} = psignifit(data,options); % 拟合
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
        
        [hline{j},hdataP{j}] = plotPsych(result{i,j}, plotOptions);
        hold on
        %% 标记进度
        disp([i,j]);
        
    end
    % 图形修饰
    legend([hline{1} hline{2} hline{3} hline{4} hline{5}],conditionName{1},conditionName{2},conditionName{3},conditionName{4},conditionName{5},'location','northwest')
    grid on
    pbaspect([6 9 1]);
    %xticks(log([15,16,18,20,22,24,27]));
    xticks(log([15,16,18,20,22,24,27]));
    xticklabels({'15','16','18','20','22','24','27'});
    yticks([0 0.25 0.5 0.75 1]);
    yticklabels({'0','25','50','75','100'});
    xlim([2.7,3.3]);
    ylim([0,1]);
    title(sprintf('Subj %02d',i));
    set(gca,'box','on');
    print(fig,sprintf('Subj_%02d',i),'-dpng','-r300')
    close all
end

% usedIndex = ones(size(result));
% for i=1:22
%     for j=1:5
% %         X25(i,j) = getThreshold(result{i,j},0.25,0);
% %         X50(i,j) = getThreshold(result{i,j},0.5,0);
% %         X75(i,j) = getThreshold(result{i,j},0.75,0);
%         temp = getStandardParameters(result{i,j});
%         for k=1:5
%             if temp(3) >= 0.25 || temp(4) >= 0.25
%                 usedIndex(i,j)=nan;
%             end
%         end
%     end
% end

%% 特征值抽取
for i=1:22
    for j=1:5
        X25(i,j) = getThreshold(result{i,j},0.25,1);
        X50(i,j) = getThreshold(result{i,j},0.5,1);
        X75(i,j) = getThreshold(result{i,j},0.75,1);
        %         temp = getStandardParameters(result{i,j});
        %         for k=1:5
        %             if temp(3) >= 0.25 || temp(4) >= 0.25
        %                 usedIndex(i,j)=nan;
        %             end
        %         end
    end
end
% 备份数据
save X25 X25
save X50 X50
save X75 X75

%% 计算指标
%% PSE
pse=X50;
pse(checkResult,:)=[];
% upl = mean(pse)+2.5*std(pse);
% dwl = mean(pse)-2.5*std(pse);
% mask = (pse<upl).*(pse>dwl);
% pse = pse.*mask;
csvwrite_with_headers('pse.csv',pse, conditionName);
%% JND
jnd=(X75-X25)/2;
jnd(checkResult,:)=[];
% upl = mean(jnd)+2.5*std(jnd);
% dwl = mean(jnd)-2.5*std(jnd);
% mask = (jnd<upl).*(jnd>dwl);
% jnd = jnd.*mask;
csvwrite_with_headers('jnd.csv',jnd, conditionName);
%% WeberFraction
WeberFraction = ((X75-X25)/2)./X50;
WeberFraction(checkResult,:)=[];
% upl = mean(WeberFraction)+2.5*std(WeberFraction);
% dwl = mean(WeberFraction)-2.5*std(WeberFraction);
% mask = (WeberFraction<upl).*(WeberFraction>dwl);
% WeberFraction = WeberFraction.*mask;
csvwrite_with_headers('wb.csv',WeberFraction, conditionName);
%% backup data
% target data
writetable(targetData,'targetData.csv','WriteVariableNames',true);
%% record remove info
save removeSubj.txt checkResult -ascii
%% 备份拟合结果
save fit_results result -v7.3
toc
%% weber 分数检查
%range (3.2958-2.7081)/2/log(20)