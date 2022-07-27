function [img,imgRow] = removeNoChange(img,imgRow)

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

