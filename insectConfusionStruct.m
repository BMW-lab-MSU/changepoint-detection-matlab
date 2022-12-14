% insectConfusionStruct Create struct of the insect identification
%
% Uses the text file insectConbined.txt and reads line by line to store if
% the image was labeled insect or not an insect
%
% s.y stores the actual insect labels
% s.yHat stores the algorithm labels
% Stores insect as 1, not an insect as 0
%
% To see the confusion matrix, use: plotconfusion(s.y,s.yHat)

tic

dataDir = 'data/insect-lidar';
days = ['2020-09-16';'2020-09-17';'2020-09-18';'2020-09-20'];

%% Struct to store info
s.idx = [];  % Counter
s.date = [];
s.time = [];
s.fileNum = [];
s.y = [];    % Human labels
s.yHat = []; % Algorithm labels
        
idx = 1;

%% Open text file and read in first line
% Used to store if the image contains an insect or not using the human
% labels
yInsect = fopen('insectCombined.txt');

insectLine = fgetl(yInsect);

%% Iterate through entire data
for i = 1:4
    folder = dir([dataDir filesep days(i,:)]);
    folder = folder(3:end-1);
    for j = 1:length(folder)
        load([dataDir filesep days(i,:) filesep folder(j).name filesep 'adjusted_data_decembercal.mat']);
        img = adjusted_data_decembercal;
        for k = 1:length(img)
            s.idx = [s.idx,idx];
            idx = idx + 1;
            s.date = [s.date,cellstr(days(i,:))];
            s.time = [s.time,cellstr(folder(j).name)];
            s.fileNum = [s.fileNum,k];

            file = [days(i,:) ',' folder(j).name ',' int2str(k)];
            
            if strcmp(file,insectLine)
                s.y = [s.y,1];
                insectLine = fgetl(yInsect);
            else
                s.y = [s.y,0];
            end
            insectPos = insectAlgorithm(img(k));
            if ~isempty(insectPos)
                s.yHat = [s.yHat,1];
            else
                s.yHat = [s.yHat,0];
            end
            
        end
    end
end

save 'insectStruct' 's' % Change the first argument (insectStruct) to change the file name

toc