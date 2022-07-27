function [img,imgRow] = removeNoChange(img,imgRow)

% removeNoChange Remove rows that stay relatively the same throughout the
%                image
%
% REQUIRES: img is LiDAR image matrix
%           imgRow is a vector of the rows that exist in the image
% MODIFIES: img
%           imgRow
% EFFECTS:  Removes the constant rows from img and removes the
%           corresponding row number from imgRow.
%           Ex: img = adjusted_data_junecal(1).normalized_data;
%               imgRow = 1:178;
%           If row 2 is removed, img will have 177 rows and imgRow will be
%           the vector [1,3:178]

moreEqualParts = [1:64; 65:128; 129:192; 193:256; 257:320; 321:384;
                  385:448; 449:512; 513:576; 577:640; 641:704; 705:768;
                  769:832; 833:896; 897:960; 961:1024];
noChange = [];

for row = 1:size(img,1)
    averages = [];
    for i = 1:16
        averages = [averages mean(img(row,moreEqualParts(i,:)))];
    end
    averagesDiff = abs(diff(averages));
    averagesPercentDiff = averagesDiff ./ averages(2:end);
    if sum(averagesPercentDiff < 0.05) == 15
        noChange = [noChange row];
    end
end

img(noChange,:) = [];
imgRow(noChange) = [];

end

