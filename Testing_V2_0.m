clear; close; clc;
%% 

%load Trainednetwork.mat
%load Trainednetwork_only_RGB
%load Trainednetwork_Random_RGB_with_classes.mat
%load Trainednetwork_Random_RGB_with_classes.mat
%load Trainednetwork_GREYSCALE_RGB
load Trainednetwork_MIX.mat

images = imageDatastore('Test', 'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames');

%% Checking actual images
% Shuffle the images to randomize the selection
images = shuffle(images);

% Choose the number of images you want to display, for example, 5
numImagesToShow = 5;

% Determine the number of images available
totalImages = numel(images.Files);
disp(['Total number of images: ', num2str(totalImages)]);

% Ensure you don't try to display more images than available
numImagesToShow = min(numImagesToShow, totalImages);

% Read and display the images with their labels
%%
figure;
for i = 1:numImagesToShow
    % Read the i-th image
    [img, info] = readimage(images, i);
    
    % Create a subplot for each image
    subplot(1, numImagesToShow, i);
    
    % Show image
    imshow(img);
    
    % Get the label for this image
    label = info.Label;
    
    % Title each subplot with the label of the image
    title(char(label));
end
%%

testImgs = images;
resizeTestImgs = augmentedImageDatastore([224 224], testImgs);
%
numImages = numel(testImgs.Files);
disp(['Number of images in the original datastore: ', num2str(numImages)]);
%

numClasses = numel(categories(images.Labels));

%
uniqueClasses = categories(images.Labels);  % Retrieve unique classes
labelCounts = countEachLabel(images);       % Count images per class
disp(labelCounts);                          % Display the counts
%
figure;
%preds = classify(trainedNetwork_1, resizeTestImgs);
preds = classify(net, resizeTestImgs);

IActual = testImgs.Labels;
numCorrect = nnz(preds == IActual);
confusionchart(IActual,preds)
% Display wrong images
figure;
wrongIndices = find(preds ~= IActual);
numWrong = numel(wrongIndices);
for i = 1:numWrong
    subplot(2, numWrong, i);
    img = readimage(testImgs, wrongIndices(i));
    imshow(img);
    title(['Wrong Image' char(IActual(wrongIndices(i)))]);
end

%% Other code
figure;
wrongIndices = find(preds ~= IActual);
numWrong = numel(wrongIndices);
if numWrong > 0
    for i = 1:numWrong  % Iterate through all wrong indices
        subplot(2, ceil(numWrong/2), i);  % Adjust layout dynamically based on the number of wrong images
        img = readimage(testImgs, wrongIndices(i));
        imshow(img);
        
        % Retrieve the file name
        [filepath, name, ext] = fileparts(testImgs.Files{wrongIndices(i)});
        
        % Create the title string with actual and predicted labels
        titleStr = sprintf('File: %s\nActual: %s, Pred: %s', ...
                           [name ext], ... % Filename
                           char(IActual(wrongIndices(i))), ... % Actual label
                           char(preds(wrongIndices(i))));       % Predicted label
        
        title(titleStr, 'Interpreter', 'none');  % Use 'none' to ensure filenames with underscores don't get interpreted as LaTeX
    end
else
    disp('No misclassified images.');
end


%% with file name
figure;
wrongIndices = find(preds ~= IActual);
numWrong = numel(wrongIndices);
if numWrong > 0
    for i = 1:min(numWrong, 10)  % Limit the display to the first 10 misclassified images to avoid overcrowding the figure
        subplot(2, ceil(numWrong/2), i);  % Adjust the subplot layout dynamically
        img = readimage(testImgs, wrongIndices(i));
        imshow(img);

        % Extract file name from the path
        [path, name, ext] = fileparts(testImgs.Files{wrongIndices(i)});
        fileName = [name, ext];  % Concatenate file name and extension

        % Construct the title with file name, actual label, and predicted label
        titleStr = sprintf('File: %s\nActual: %s, Pred: %s', ...
                           fileName, ...  % File name
                           char(IActual(wrongIndices(i))), ...  % Actual label
                           char(preds(wrongIndices(i))));       % Predicted label
        
        title(titleStr, 'Interpreter', 'none');  % Ensure that underscores in filenames are not interpreted as subscript
    end
else
    disp('No misclassified images.');
end

%% Randomly Display 5 Correctly Classified Images

% Find the indices of correctly classified images
correctIndices = find(preds == IActual);

% Ensure there are enough correctly classified images to display
numCorrect = numel(correctIndices);
%if numCorrect < 5
if numCorrect < 1    
    disp(['Only ', num2str(numCorrect), ' images were classified correctly. Displaying all correctly classified images.']);
    numImagesToShow = numCorrect; % Display all correctly classified images if less than 5
else
    %numImagesToShow = 5;  % Set the number of correctly classified images to display
    numImagesToShow = 1;  % Set the number of correctly classified images to display

end

% Randomly select indices from the list of correct ones
randIndices = correctIndices(randperm(numCorrect, numImagesToShow));

% Create a figure to display the images
figure;

for i = 1:numImagesToShow
    % Read the image from the randomly selected correctly classified indices
    img = readimage(testImgs, randIndices(i));
    
    % Create a subplot for each image
    subplot(numImagesToShow, 1, i);
    
    % Show the image
    imshow(img);
    
    % Retrieve the file name for display
    [~, name, ext] = fileparts(testImgs.Files{randIndices(i)});
    fileName = [name, ext];  % Concatenate file name and extension
    
    % Get the label for this image
    label = IActual(randIndices(i));
    
    % Title each subplot with the file name and the label of the image
    title(['File: ', fileName, '\nLabel: ', char(label)], 'Interpreter', 'none');
end


