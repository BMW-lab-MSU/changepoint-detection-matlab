function [img,imgRow] = removeWaveletRows(img,imgRow,data)

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

