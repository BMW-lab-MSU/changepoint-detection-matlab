function [img,imgRow] = removeHardTarget(img,imgRow,imgAvg)

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

