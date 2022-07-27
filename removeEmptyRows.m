function [img,imgRow] = removeEmptyRows(img,imgRow)

emptyRow = [];
imgAvg = mean(mean(img));
equalParts = [1:128; 129:256; 257:384; 385:512; 513:640; 641:768; 769:896; 897:1024];

% Split up each row into pieces and average them, if under threshold then
% consider it empty space
for row = 1:size(img,1)
    averages = [];
    for i = 1:8
        averages = [averages mean(img(row,equalParts(i,:)))];
    end
    if sum(averages < 0.9*imgAvg) == 8
        emptyRow = [emptyRow row];
    end
end

img(emptyRow,:) = [];
imgRow(emptyRow) = [];

end

