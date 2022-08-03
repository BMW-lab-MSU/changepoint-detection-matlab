tic 

dataDir = 'data/insect-lidar';
days = ['2022-07-28';'2022-07-29'];

insectPos = {};

for i = 1:2
    folder = dir([dataDir filesep days(i,:)]);
    folder = folder(3:end);
    for j = 1:length(folder)
        load([dataDir filesep days(i,:) filesep folder(j).name filesep 'adjusted_data_junecal.mat']);
        img = adjusted_data_junecal;
        for k = 1:length(img)
            bug = beesAlgorithm(img(k));
            if ~isempty(bug)
                insectPos = [insectPos; {[days(i,:) filesep folder(j).name]} {k} {mat2str(bug)}];
            end
        end
    end
end

writecell(insectPos,'bees_july.txt');

toc
%{
for i = 1:650
    insectPos{i,3} = mat2str(insectPos{i,3});
end

writecell(insectPos,'bees.txt')
%}