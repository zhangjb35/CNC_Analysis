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

%% make some data
data =    [...
    0.0010,   0.5000,   90.0000;...
    0.0015,   0.5556,   90.0000;...
    0.0020,   0.4889,   90.0000;...
    0.0025,   0.4889,   90.0000;...
    0.0030,   0.5778,   
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

%% make some data
data =    [...
    0.0010,   0.5000,   90.0000;...
    0.0015,   0.5556,   90.0000;...
    0.0020,   0.4889,   90.0000;...
    0.0025,   0.4889,   90.0000;...
    0.0030,   0.5778,   90.0000;...
    0.0035,   0.5889,   90.0000;...
    0.0040,   0.6889,   90.0000;...
    0.0045,   0.7111,   90.0000;...
    0.0050,   0.8444,   90.0000;...
    0.0060,   0.8778,   90.0000;...
    0.0070,   0.9778,   90.0000;...
    0.0080,   1.0000,   90.0000;...
    0.0100,   1.0000,   90.0000];
%% convert data to lagency format for psignfit
data(:,2) = round(data(:,2).*data(:,3));

%% Convert the options and call psignifit 4:
options = PsignifitLegacyOptionsConverter('shape', 'Weibull', 'n_intervals', 2, 'conf', [0.023 0.977], 'runs', 1999);
result = psignifit(data, options);

plotOptions = struct;
plotOptions.CIthresh = 'true';
plotOptions.aspectRatio = 'true';

plotPsych(result, plotOptions);


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
    % log([15,16,18,22,24,27])
    xSets(:,i) = [2.7,2.8,2.9,3.1,3.2,3.3];% stimulus levels
    mSets(:,i) = repmat(20,size(xSets(:,i))); %
end
rSets = reshape(rightSet,[6,5,22]);

%%
for i=1:22
    for j=1:5
        x = xSets(:,i);
        m = mSets(:,i);
        r = rSets(:,j,i);
        
        data = [x,r,m];
        options = struct;
        options.sigmoidName = 'norm';   % choose a cumulative Gaussian as the sigmoid
        options.expType     = 'YesNo';
        result = psignifit(data,options);
        
        options = PsignifitLegacyOptionsConverter('shape', 'cumulative gaussian','expType','YesNo', 'conf', [0.023 0.977], 'runs', 1999)
        result = psignifit(data, options);
        
        plotOptions = struct;
        plotOptions.CIthresh = 'true';
        plotOptions.aspectRatio = 'true';
        
        plotPsych(result, plotOptions);90.0000;...
    0.0035,   0.5889,   90.0000;...
    0.0040,   0.6889,   90.0000;...
    0.0045,   0.7111,   90.0000;...
    0.0050,   0.8444,   90.0000;...
    0.0060,   0.8778,   90.0000;...
    0.0070,   0.9778,   90.0000;...
    0.0080,   1.0000,   90.0000;...
    0.0100,   1.0000,   90.0000];
%% convert data to lagency format for psignfit
data(:,2) = round(data(:,2).*data(:,3));

%% Convert the options and call psignifit 4:
options = PsignifitLegacyOptionsConverter('shape', 'Weibull', 'n_intervals', 2, 'conf', [0.023 0.977], 'runs', 1999);
result = psignifit(data, options);

plotOptions = struct;
plotOptions.CIthresh = 'true';
plotOptions.aspectRatio = 'true';

plotPsych(result, plotOptions);


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
    % log([15,16,18,22,24,27])
    xSets(:,i) = [2.7,2.8,2.9,3.1,3.2,3.3];% stimulus levels
    mSets(:,i) = repmat(20,size(xSets(:,i))); %
end
rSets = reshape(rightSet,[6,5,22]);

%%
for i=1:22
    for j=1:5
        x = xSets(:,i);
        m = mSets(:,i);
        r = rSets(:,j,i);
        
        data = [x,r,m];
        options = struct;
        options.sigmoidName = 'norm';   % choose a cumulative Gaussian as the sigmoid
        options.expType     = 'YesNo';
        result = psignifit(data,options);
        
        options = PsignifitLegacyOptionsConverter('shape', 'cumulative gaussian','expType','YesNo', 'conf', [0.023 0.977], 'runs', 1999)
        result = psignifit(data, options);
        
        plotOptions = struct;
        plotOptions.CIthresh = 'true';
        plotOptions.aspectRatio = 'true';
        
        plotPsych(result, plotOptions);

        X_25_ind(i,j) = getThreshold(result,0.25);
        X_50_ind(i,j)= getThreshold(result,0.50);
        X_75_ind(i,j) = getThreshold(result,0.75);
        disp([num2str(i),'-',num2str(j), '#done']);
        clear result
    end
end