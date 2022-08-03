% misclassOutput Write false positives, false negatives, and positives to
% text files
%
% Run insectConfusionStruct.m or beesConfusionStruct.m first to get the
% struct s
%
% Rename the file names at the bottom
%
% Press run and everything should be written out to the text files. The
% format is [date],[file name],[image number]

fn = [];
fp = [];
p = [];

for i = 1:length(s.y)
    if s.y(i) == 1 && s.yHat(i) == 0
        fn = [fn;s.date(i) s.time(i) s.fileNum(i)];
    elseif s.y(i) == 0 && s.yHat(i) == 1
        fp = [fp;s.date(i) s.time(i) s.fileNum(i)];
    elseif s.y(i) == 1 && s.yHat(i) == 1
        p = [p;s.date(i) s.time(i) s.fileNum(i)];
    end
end


fnT = array2table(fn);
writetable(fnT,'fnInsect.txt'); % falst negative text file
fpT = array2table(fp);
writetable(fpT,'fpInsect.txt'); % false positive text file
pT = array2table(p);
writetable(pT,'pInsect.txt'); % positive text file

%% Notes
% False negative: (1,0)
% False positive: (0,1)