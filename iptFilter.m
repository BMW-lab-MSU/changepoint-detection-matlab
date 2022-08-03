function insectPos = iptFilter(row,tempSignal,ipt,insectPos)

% This function assumes that there are a maximum of two insects in each
% row. Changes are needed if there's more; no easy way at the moment to be
% able to identify three insects.

signalThresh = 0.4; % prev 0.32

if length(ipt) == 1         % one changepoint
    mean1 = mean(tempSignal(1:ipt));
    mean2 = mean(tempSignal(ipt:end));
    means = [mean1 mean2];
    if sum(means < signalThresh) == 2
%         disp("no bug1")
    elseif sum(means > signalThresh) == 2
%         disp("no bug2")
    else
        if mean1 > mean2
            insectPos = [insectPos; row 1 ipt];
        else
            insectPos = [insectPos; row ipt 1024];
        end
    end
elseif length(ipt) == 2     % two changepoints
    mean1 = mean(tempSignal(1:ipt(1)));
    mean2 = mean(tempSignal(ipt(1):ipt(2)));
    mean3 = mean(tempSignal(ipt(2):end));
    means = [mean1 mean2 mean3];
    if sum(means < signalThresh) == 3
%         disp("no bug3")
    elseif sum(means > signalThresh) == 3
%         disp("no bug4")
    elseif (mean1 < signalThresh) && (mean3 < signalThresh)
        insectPos = [insectPos; row ipt(1) ipt(2)];
    elseif (mean1 > signalThresh) && (mean2 > signalThresh)
        insectPos = [insectPos; row 1 ipt(2)];
    elseif (mean2 > signalThresh) && (mean3 > signalThresh)
        insectPos = [insectPos; row ipt(1) 1024];
    elseif (mean1 > signalThresh) && (mean3 > signalThresh)
        if abs(mean1 - mean3) < 0.1
            insectPos = [insectPos; row 1 ipt(1)];
            insectPos = [insectPos; row ipt(2) 1024];
        end
    else
%         disp("no bug5")
    end
elseif length(ipt) > 2      % 3 or more changepoints
    tempIpt = [1 ipt 1024];
    means = [];
    for i = 1:length(tempIpt) - 1
        means = [means mean(tempSignal(tempIpt(i):tempIpt(i+1)))];
    end
    if sum(means > signalThresh) == length(means)
%         disp("no bug6")
    elseif sum(means < signalThresh) == length(means)
%         disp("no bug7")
    else
        meansDiff = diff(means);
        highs = find(meansDiff < 0);
        if meansDiff(end) > 0
            highs = [highs length(means)];
        end
        meansDiff = abs(meansDiff);
        meanPercentDiff = [];
        
        for i = 1:length(highs)
            if highs(i) == 1
                meanPercentDiff(i,:) = [(means(1)-means(2))/means(1) (means(1)-means(2))/means(1)];
            elseif highs(i) < length(means)
                meanPercentDiff(i,:) = [abs(means(highs(i)-1)-means(highs(i)))/means(highs(i)) abs(means(highs(i)+1)-means(highs(i)))/means(highs(i))];
            else
                meanPercentDiff(i,:) = [(means(end) - means(end-1))/means(end) (means(end) - means(end-1))/means(end)];
            end
        end

        minDiff = min(min(meanPercentDiff));
        iptLength = length(ipt);
        while minDiff < 0.75
            [x,y] = find(meanPercentDiff == minDiff);
            if length(x) > 1
                x = x(1);
            end
            if x == 1
                ipt = ipt(2:end);
                if length(highs) > 1
                    if diff([highs(x) highs(x+1)]) == 1
                        meanPercentDiff(x+1,1) = 0.8;
                    end
                end
                highs(x) = [];
                meanPercentDiff(x,:) = [];
            elseif x == length(highs)
                ipt = ipt(1:end-1);
                if length(highs) > 1
                    if diff([highs(x-1) highs(x)]) == 1
                        meanPercentDiff(x-1,2) = 0.8;
                    end
                end
                highs(x) = [];
                meanPercentDiff(x,:) = [];
            else
                ipt = [ipt(1:x-1) ipt(x+1:end)];
                if length(highs) > 1
                    if (x < length(highs)) && (diff([highs(x) highs(x+1)]) == 1)
                        meanPercentDiff(x+1,1) = 0.8;
                    elseif (x > 1) && (diff([highs(x-1) highs(x)]) == 1)
                        meanPercentDiff(x-1,2) = 0.8;
                    end
                end
                highs(x) = [];
                meanPercentDiff(x,:) = [];
            end
            
            minDiff = min(min(meanPercentDiff));
        end

        if isempty(ipt)
            % do nothing
        elseif length(ipt) == iptLength
            for i = 1:length(highs)
                insectPos = [insectPos; row tempIpt(highs(i)) tempIpt(highs(i)+1)];
            end
        else
            insectPos = iptFilter(row,tempSignal,ipt,insectPos);
        end
    end
end

end

%% Notes
%% 07/11/2022
%{
Changed conditional statements for length(ipt) > 2
%}