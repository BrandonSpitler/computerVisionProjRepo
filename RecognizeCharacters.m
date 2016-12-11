function [output, minVector] = RecognizeCharacters(imageFileName)
%TwoPassAlgorithm
% First pass to detect boundaries of letters
% Second pass to label letters
image = imread(imageFileName);
originalImage = image;
%image =  double(image);
image = rgb2gray(image);
image(image < 128) = 1;
image(image >= 128) = 0; % Pay attention to the order
image = logical(image); % Casting
%image  = im2bw(image,0);
[height,width] = size(image);
windowSize = 3;
pixelsAround = (windowSize - 1)/2;
ConnectedList = zeros(height,width);
OC = zeros(height,width);
%rename all non zero pixels
counter = 1;
for c = 1:1:height
    for b = 1:1:width
        if(image(c,b) == 1)
            ConnectedList(c,b) = counter;
            OC(c,b) = counter;
            counter = counter + 1;
        end    
    end
end
%col,row loops
%changes all unique values to max of 8 neighbors
function outcome = sweep() 
    flag = 0;
    for y = 1 + pixelsAround:1:height-pixelsAround
        for x = 1 + pixelsAround:1:width-pixelsAround
            %inner window loops
            if(ConnectedList(y,x) ~= 0)
                max = ConnectedList(y,x);
                for z = -pixelsAround:1:pixelsAround
                    for t = -pixelsAround:1:pixelsAround
                        if(ConnectedList(y+z,x+t) > max)
                            max = ConnectedList(y+z,x+t);
                            flag = 1;
                        end
                    end
                end
                ConnectedList(y,x) = max;
            end
        end
    end
    outcome = flag;
end
%while there is a pixel val changed. loop until no pixel is changed on pass
cflag = 1;
while (cflag ~= 0)
    result = sweep();
    cflag = result;
end
%find min x,y and max x,y of each letter
numberVector = [];
minVector = [];
dots = [];
diff = 0;
for m = 1:1:height
    for  n = 1:1:width
        if(ConnectedList(m,n) ~= 0)
            val = ConnectedList(m,n);
            check = any(numberVector==val);
            if(check == 0)
            numberVector = vertcat(numberVector,val);
            indexMinY = m;
            indexMinX = n;
            indexMaxY = m;
            indexMaxX = n;
            %disp(indexMinY);
            %disp(indexMinX);
            for q = 1:1:height
                for l = 1:1:width
                    if(val == ConnectedList(q,l))
                        if(q < indexMinY)
                            indexMinY = q;
                        end
                        if(l < indexMinX)
                            indexMinX = l;
                        end
                        if(q > indexMaxY)
                            indexMaxY = q;
                        end
                        if(l > indexMaxX)
                            indexMaxX = l;
                        end
                    end
                end
            end
            %find extensions like dot on any character
            check1 = any(dots==val);
            for c = indexMaxY:1:indexMaxY+12 % RANGE to search for dot above. if letter are closer manually change this or else labels will be wrong
                for d = indexMinX:1:indexMaxX
                    check2 = any(dots==ConnectedList(c,d));
                    if(ConnectedList(c,d) ~= 0 && ConnectedList(c,d) ~= val)
                        if(check1 == 0)
                            if (check2 == 0)
                                dots = vertcat(dots,[val ;ConnectedList(c,d)]);
                                break;
                            end
                        end
                    end
                end
            end
            vector = [indexMinY indexMinX indexMaxY indexMaxX];
            minVector = vertcat(minVector,vector);
            end
        end
    end
end
% loops to create points in picture
figure
imshow(originalImage);
hold on;
[row,col] = size(minVector);
LetterCoords = [];
% all non two part character label
for d=1:1:row
    checkDots = any(dots==numberVector(d,1));
    if(checkDots == 0)
         widthOfX = minVector(d,4) - minVector(d,2);
         heightOfX = minVector(d,3) - minVector(d,1);
         PosX = minVector(d,2);
         PosY = minVector(d,1); 
         r = rectangle('position',[PosX PosY widthOfX heightOfX],'LineWidth',1);
         LetterCoords = vertcat(LetterCoords,minVector(d,:));
         set(r,'edgecolor','red');
    end  
end
% all two part character label
lenDots = size(dots);
for c=1:2:lenDots
         r1 = find(numberVector==dots(c));
         r2 = find(numberVector==dots(c+1));
         widthOfX1 = minVector(r2,4) - minVector(r2,2);
         widthOfX2 = minVector(r1,4) - minVector(r1,2);
         widthOfX = 0;
         xMax = 0;
         if(widthOfX1 > widthOfX2)
             widthOfX = widthOfX1;
             xMax = minVector(r2,4);
         else
             widthOfX = widthOfX2;
             xMax = minVector(r1,4);
         end
         heightOfX = minVector(r2,3) - minVector(r1,1);
         yMax = minVector(r2,3);
         PosX1 = minVector(r2,2);
         PosX2 = minVector(r1,2);
         PosX = 0;
         if PosX1 < PosX2
            PosX = PosX1;
         else
            PosX = PosX2;
         end
         PosY = minVector(r1,1); 
         r = rectangle('position',[PosX PosY widthOfX heightOfX],'LineWidth',1);
         LetterCoords = vertcat(LetterCoords,[PosY PosX  yMax  xMax]);
         set(r,'edgecolor','red'); 
end
[r,c] = size(dots());
%plot(LetterCoords(39,2),LetterCoords(39,1),'r+', 'MarkerSize', 10);
%plot(LetterCoords(39,4),LetterCoords(39,3),'r+', 'MarkerSize', 10);
disp(size(LetterCoords)) % count of every label;
output = LetterCoords; % output is set of MinY MinX YMax XMax - these points can be used to extract each pixel box(use meshgrid maybe) to compare to letter image
end



%Brandon Stuff Here

%read in letter
