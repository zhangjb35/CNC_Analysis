%%  Curve Fit of the behv data
% zero the world
clear, clc
restoredefaultpath; %% set a clean path
% addpath('/home/jinbo/.matlab/R2012b'); % for linux server only
project_dir = pwd;% change to tfr_prep dir firsts
home_dir = fullfile(project_dir, 'data', 'behv');
matlab_dir = fullfile(project_dir, 'toolbox');
fuction_dir = fullfile(project_dir, 'functions');

addpath(genpath(fullfile(matlab_dir, 'modelfree1.1')));  %% initialize modelfree package
addpath(genpath(fuction_dir));

%% tutorial
% load(fullfile(matlab_dir,'modelfree1.1','examplesMatlab','example_06.mat'),'-mat');
% figure; plot( x, r ./ m, 'k.'); axis([0.9 8.1 0.45 1.05]); axis square;
% 
% %% For the Gaussian cumulative distribution function (black curve)
% degpol = 1; % Degree of the polynomial
% guessing = 1/2; % guessing rate
% lapsing = 0; % lapsing rate
% b = binomfit_lims( r, m, x, degpol, 'probit', guessing, lapsing );
% numxfit = 199; % Number of new points to be generated minus 1
% xfit = [min(x):(max(x)-min(x))/numxfit:max( x ) ]';
% % Plot the fitted curve
% pfit = binomval_lims( b, xfit, 'probit', guessing, lapsing );
% hold on, plot( xfit, pfit, 'k' );
% %% For the Weibull function (red curve)
% initK = 2; % Initial power parameter in Weibull/reverse Weibull model
% [ b, K ] = binom_weib( r, m, x, degpol, initK, guessing, lapsing);
% % Plot the fitted curve
% pfit = binomval_lims( b, xfit, 'weibull', guessing, lapsing, K );
% hold on, plot( xfit, pfit, 'r' );
% %% For the reverse Weibull function (green curve):
% [ b, K ] = binom_revweib( r, m, x, degpol, initK, guessing, lapsing);
% % Plot the fitted curve
% pfit = binomval_lims( b, xfit, 'revweibull', guessing, lapsing, K );
% hold on, plot( xfit, pfit, 'g' );
% %% For the local linear fit (blue curve):
% bwd_min = -min( diff( x ) ); % data is decreasing
% bwd_max = max( x ) - min( x );
% bwd = bandwidth_cross_validation( r, m, x, [ bwd_min, bwd_max ] );
% % Plot the fitted curve
% bwd = bwd(3); % choose the third estimate, which is based on cross-validated deviance
% pfit = locglmfit( xfit, r, m, x, bwd );
% hold on, plot( xfit, pfit, 'b' );

%% application
%% prep data
%
data_file_behv = cell2mat(kb_ls(fullfile(pwd,'data','behv','*.csv')));
rawData = readtable(data_file_behv);
%% prep data for each subject
rawData.ButtonPush = zeros(length(rawData.participant_id),1); % 0 = less;1=more
% Determin Button Pushed
for i=1:length(rawData.participant_id)
    if rawData.NumCondition(i)<=3 && rawData.ACC(i)==1 % small num with right resp = less button
        rawData.ButtonPush(i)=0;
    elseif rawData.NumCondition(i)<=3 && rawData.ACC(i)==0 % small num with wrong resp = more button
        rawData.ButtonPush(i)=1;
    elseif rawData.NumCondition(i)>3 &&rawData.ACC(i)==1 % bigger num with right resp = more button
        rawData.ButtonPush(i)=1;
    elseif rawData.NumCondition(i)>3 && rawData.ACC(i)~=0 % bigger num with wrong resp = less button
        rawData.ButtonPush(i)=0;
    end
end
%%
% response info
[rightSet,numerlSet,groupName] = grpstats(rawData.ButtonPush,{rawData.participant_id,rawData.SoundCondition,rawData.NumCondition},{'sum','numel','gname'});
for i=1:length(unique(rawData.participant_id))
    xSets(:,i) = [15;16;18;22;24;27];% stimulus levels
    mSets(:,i) = repmat(20,size(xSets(:,i))); %
end
rSets = reshape(rightSet,[6,5,23]);

%% plot at single subject and condition level
conditionName = {'No Sound','One Soft','One Loud','Multi Soft','Multi Loud'};
conditionNameMarker =  {'Resonse Data No Sound','Resonse Data One Soft','Resonse Data One Loud','Resonse Data Multi Soft','Resonse Data Multi Loud'};
lineUse = {'-.','--','-','--','-'}; % "1=>nosound","2=>one-soft-sound","3=>one-loud-sound","4=>multi-soft-sound","5=>multi-loud-sound"
markShapeUse = {'+','o','*','o','*'};
C1 = rgb('DarkSlateBlue');
C2 = rgb('OrangeRed');
C3 = rgb('OrangeRed');
C4 = rgb('MediumAquamarine');
C5 = rgb('MediumAquamarine');
ColorUse = {C1,C2,C3,C4,C5};
for i=1:23
    fig=figure;
    for j=1:5
        x = xSets(:,i);
        m = mSets(:,i);
        r = rSets(:,j,i);
        plot( x, r ./ m, 'Marker',markShapeUse{j},'MarkerFaceColor', 'none','MarkerEdgeColor',ColorUse{j}, 'LineStyle' ,'none','MarkerSize',5,'DisplayName', conditionNameMarker{j}); 
        axis([14.5 27.5 0 1]);
        axis square;
        %% For the Gaussian cumulative distribution function (black curve):
        degpol = 1; % Degree of the polynomial
        guessing = 1/2; % guessing rate
        lapsing = 0; % lapsing rate
        b = binomfit_lims( r, m, x, degpol, 'probit' );
        numxfit = 199; % Number of new points to be generated minus 1
        xfit = [min(x):(max(x)-min(x))/numxfit:max( x ) ]';
        % Plot the fitted curve
        pfit = binomval_lims( b, xfit, 'probit' );
        hold on, plot( xfit, pfit, 'LineStyle' ,lineUse{j},'Color',ColorUse{j},'LineWidth',2,'DisplayName',conditionName{j});
        legend('Location','southeast')
    end
    xticks([15;16;18;20;22;24;27])
    %xticklabels({'-3\pi','-2\pi','-\pi','0','\pi','2\pi','3\pi'})
    yticks([0 0.25 0.50 0.75 1])
    title(['Psychometric Curves of Subj ' sprintf('%02d',i)],'FontSize', 18);
    xlabel('Test numerosity (dots)','FontSize', 18) % x-axis label
    ylabel('Proportion of "more elements"','FontSize', 18) % y-axis label
    print(fig,sprintf('Subj_%02d',i),'-dpng','-r300')
    hold off
    close all
end
% %% For the local linear fit (blue curve):
%     bwd_min = min( diff( x ) ); % data is decreasing
%     bwd_max = max( x ) - min( x );
%     bwd = bandwidth_cross_validation( r, m, x, [ bwd_min, bwd_max ] );
%     % Plot the fitted curve
%     bwd = bwd(3); % choose the third estimate, which is based on cross-validated deviance
%     numxfit = 199; % Number of new points to be generated minus 1
%     xfit = [min(x):(max(x)-min(x))/numxfit:max( x ) ]';
%     pfit = locglmfit( xfit, r, m, x, bwd );
%     hold on, plot( xfit, pfit, 'b' );
%     
% %%  For the Weibull function (red curve):
% 
% [ b, K ] = binom_weib( r, m, x );
% guessing = 0; % guessing rate
% lapsing = 0; % lapsing rate
% % Plot the fitted curve
% pfit = binomval_lims( b, xfit, 'weibull', guessing, lapsing, K );
% hold on, plot( xfit, pfit, 'g' );

%% Extract PSE and JND
%% Grand Average