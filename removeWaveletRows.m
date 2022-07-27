function [img,imgRow] = removeWaveletRows(img,imgRow,data)

% removeEmptyRows Remove rows that have weak frequencies
%
% REQUIRES: img is LiDAR image matrix
%           imgRow is a vector of the rows that exist in the image
% MODIFIES: img
%           imgRow
% EFFECTS:  Removes the rows without frequency from img and removes the
%           corresponding row number from imgRow.
%           Ex: img = adjusted_data_junecal(1).normalized_data;
%               imgRow = 1:178;
%           If row 2 is removed, img will have 177 rows and imgRow will be
%           the vector [1,3:178]

tempWavelet = [];
tempMax = 0;
badRow = [];
fs = 1/mean(diff(data.time));
equalParts = [1:128; 129:256; 257:384; 385:512; 513:640; 641:768; 769:896; 897:1024];


for row = 1:size(img,1)
    tempWavelet = cwt(img(row,:),fs);
    tempWavelet = abs(tempWavelet);
    tempMax = max(max(tempWavelet));
    if tempMax < 0.04
        badRow = [badRow row];
    else
        averages = [];
        for i = 1:8
            averages = [averages mean(mean(tempWavelet(:,equalParts(i,:))))];
        end
        averagesDiff = abs(diff(averages));
        averagesPercentDiff = averagesDiff ./ averages(2:end);
        if sum(averagesPercentDiff < 0.1) == 7
            badRow = [badRow row];
        end
    end
end

img(badRow,:) = [];
imgRow(badRow) = [];

end

