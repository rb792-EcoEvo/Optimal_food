function [ ] = plot_bar(X,names,y,width)

    
    X = [0;cumsum(X)];
    n = length(X);
    
    for i = 2:n
        rectangle('Position',[X(i-1) y-width/2 X(i)-X(i-1) width]);
%         plot([X(i-1) X(i-1)], [y-width/2 - 0.05 - (i-2)*0.075, y-width/2 ],':k');        
    end
    for i = 2:n
        text((X(i-1)+X(i))/2, y+width/2 - 0.05 - (i-2)*0.05, char(names(i-1)),'fontsize',9,'HorizontalAlignment','center');
    end
end

