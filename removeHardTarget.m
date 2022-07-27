function [img,imgRow] = removeHardTarget(img,imgRow,imgAvg)

% removeHardTarget Remove rows that contain a hard target or brighter spots
%
% REQUIRES: img is LiDAR image matrix
%           imgRow is a vector of the rows that exist in the image
% MODIFIES: img
%           imgRow
% EFFECTS:  Removes the bright rows from img and removes the corresponding
%           row number from imgRow.
%           Ex: img = adjusted_data_junecal(1).normalized_data;
%               imgRow = 1:178;
%           If row 2 is removed, img will have 177 rows and imgRow will be
%           the vector [1,3:178]

equalParts = [1:128; 129:256; 257:384; 385:512; 513:640; 641:768; 769:896; 897:1024];

% Crop actual hard point out
hardpts = 0;

for row = 1:size(img,1)
    averages = [];
    for i = 1:8
        averages = [averages mean(img(row,equalParts(i,:)))];
    end
    if sum(averages > 0.8) == 8
        hardpts = row;
        break
    end
end

if hardpts ~= 0
    img = img(1:hardpts,:);
end

% Remove any other bright spots
hardpts = [];

for row = 1:size(img,1)
    averages = [];
    for i = 1:8
        averages = [averages mean(img(row,equalParts(i,:)))];
    end
    if sum(averages > 2.25*imgAvg) == 8    % Check this threshold
        hardpts = [hardpts row];
    end
end


img(hardpts,:) = [];
imgRow(hardpts) = [];

end

