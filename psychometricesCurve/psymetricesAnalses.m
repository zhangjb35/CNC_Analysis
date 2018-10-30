%% load toolbox
% zero the world
clear, clc
restoredefaultpath; %% set a clean path
% addpath('/home/jinbo/.matlab/R2012b'); % for linux server only
project_dir = pwd;% change to tfr_prep dir firsts
home_dir = fullfile(project_dir, 'data', 'behv');
matlab_dir = fullfile(project_dir, 'toolbox');
fuction_dir = fullfile(project_dir, 'functions');

addpath(genpath(fullfile(matlab_dir, 'psignifit')));  %% initialize modelfree package
addpath(genpath(fuction_dir));

%% prep data
% data file list
data_file_behv = cell2mat(kb_ls(fullfile(pwd,'data','behv','raw','sub*.csv')));
rawData = readtable(data_file_behv);
%% prep data for each subject
rawData.ButtonPush = zeros(length(rawData.participant_id),1); % 0 = less;1=more
% Determin Button Pushed
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

% response info
[rightSet,numerlSet,groupName] = grpstats(rawData.ButtonPush,{rawData.participant_id,rawData.SoundCondition,rawData.NumCondition},{'sum','numel','gname'});
for i=1:length(unique(rawData.participant_id))
    xSets(:,i) = [2.7 2.8 2.9 3.1 3.2 3.3];
    %xSets(:,i) = log([15,16,18,22,24,27]);
    %xSets(:,i) = [15,16,18,22,24,27];% stimulus levels
    mSets(:,i) = repmat(20,size(xSets(:,i))); %
end
rSets = reshape(rightSet,[6,5,22]);
%%
conditionName = {'No Sound','One Soft','One Loud','Multi Soft','Multi Loud'};
conditionNameMarker =  {'Resonse Data No Sound','Resonse Data One Soft','Resonse Data One Loud','Resonse Data Multi Soft','Resonse Data Multi Loud'};
lineUse = {'-.','--','-','--','-'}; % "1=>nosound","2=>one-soft-sound","3=>one-loud-sound","4=>multi-soft-sound","5=>multi-loud-sound"
markShapeUse = {'+','o','*','o','*'};
C1 = rgb('DarkSlateBlue');
C2 = rgb('OrangeRed');
C3 = rgb('OrangeRed');
C4 = rgb('MediumAquamarine');
C5 = rgb('MediumAquamarine');
%ColorUse = {C1,C2,C3,C4,C5};
ColorUse = {'k','r','g','b','m'};

%%
for i=1:22
    fig=figure;
    for j=1:5
        x = xSets(:,i);
        m = mSets(:,i);
        r = rSets(:,j,i);
        
        data = [x,r,m];
        options = struct;
        options.sigmoidName = 'logistic';   % choose a cumulative Gaussian as the sigmoid
        options.expType     = 'YesNo';
        %options.logspace = 1;
        options.fixedPars = NaN(5,1);
        options.fixedPars(3) = 0;
        options.fixedPars(4) = 0;
        %options.expType = 'equalAsymptote';
        result{i,j} = psignifit(data,options);
        
        plotOptions = struct;
        plotOptions.CIthresh = false;
        plotOptions.aspectRatio = true;
        plotOptions.plotPar = true;
        plotOptions.lineColor = ColorUse{j};
        plotPsych(result{i,j}, plotOptions);
        hold on
        
        disp([i,j]);
        
    end
    print(fig,sprintf('Subj_%02d',i),'-dpng','-r300')
    close all
end
save fit_results_fixLapse result -v7.3
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
%%
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

save X25 X25
save X50 X50
save X75 X75

%% output
pse=exp(X50);
upl = mean(pse)+3*std(pse);
dwl = mean(pse)-3*std(pse);
mask = (pse<upl).*(pse>dwl);
pse = pse.*mask;
csvwrite('pse.csv',pse);
jnd=(exp(X75)-exp(X50));
upl = mean(jnd)+3*std(jnd);
dwl = mean(jnd)-3*std(jnd);
mask = (jnd<upl).*(jnd>dwl);
jnd = jnd.*mask;
csvwrite('jnd.csv',jnd);
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