function [img,imgRow] = removeEmptyRows(img,imgRow)

% removeEmptyRows Remove rows that only have air / no signal
%
% REQUIRES: img is LiDAR image matrix
%           imgRow is a vector of the rows that exist in the image
% MODIFIES: img
%           imgRow
% EFFECTS:  Removes the insiginificant rows from img and removes the
%           corresponding row number from imgRow.
%           Ex: img = adjusted_data_junecal(1).normalized_data;
%               imgRow = 1:178;
%           If row 2 is removed, img will have 177 rows and imgRow will be
%           the vector [1,3:178]


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

