//Script to help with the analysis of the distribution of mitotic events with respect to the developing condensates

//Get image details
Image = getTitle();
dir = File.directory();

//make 8-bit
run("8-bit");
run("Green");
run("Enhance Contrast", "saturated=0.35");

//The default settings below appear to work quite well at correcting for drift
run("Correct 3D drift", "channel=1 only=0 lowest=1 highest=1");

//Select drift corrected image and get dimnesions
selectWindow("registered time points");
getDimensions(width, height, channels, slices, frames);

//Save drift corrected image
selectWindow("registered time points");
saveAs("Tiff", dir+Image+"_Drift_Corrected.tif");

//Close the log
if (isOpen("Log")) {
	selectWindow("Log");
	run("Close");
}

//Write the dimensions to the log
print("Filename = "+Image);
print("Width = "+width);
print("Height = "+height);
print("Channels = "+channels);
print("Slices = "+slices);
print("Frames = "+frames);

//Prompt user to define the hair follicles
if (isOpen("ROI Manager")) {
	selectWindow("ROI Manager");
	run("Close");
}

run("Select None");
setTool("oval");
waitForUser("Select Condensates", "Please outline the condensates and add to manager (Ctrl+T) then press OK (Click 'Show All' to preview)");

//save the roi set, make a mask, get coordinates
nFollicles = roiManager("count");
print("Number of Follicles = "+nFollicles);
newImage(Image+"_Follicle_Mask", "8-bit black", width, height, 1);
roiManager("Show All");
roiManager("List");
selectWindow("Overlay Elements of "+Image+"_Follicle_Mask");
saveAs("Text", dir+Image+"_Follicle_Positions.csv");
run("Close");
roiManager("Save", dir+Image+"_Follicle_Positions.zip");
roiManager("Fill");
selectWindow(Image+"_Follicle_Mask");
saveAs("Tiff", dir+Image+"_Follicle_Mask.tif");
run("Close");

//Prompt user to identify and record mitoses
if (isOpen("ROI Manager")) {
	selectWindow("ROI Manager");
	run("Close");
}

run("Select None");
setTool("line");
waitForUser("Select Mitoses", "Please select mitoses and add to manager (Ctrl+T) then press OK");

//save the roi set, make a mask, get coordinates
nMitoses = roiManager("count");
print("Number of Mitoses = "+nMitoses);
newImage(Image+"_Mitoses_Mask", "8-bit black", width, height, 1);
roiManager("List");
selectWindow("Overlay Elements of "+Image+"_Mitoses_Mask");
saveAs("Text", dir+Image+"_Mitoses.csv");
run("Close");
roiManager("Save", dir+Image+"_Mitoses.zip");
roiManager("Fill");
selectWindow(Image+"_Mitoses_Mask");
saveAs("Tiff", dir+Image+"_Mitoses_Mask.tif");
run("Close");

//Save the log
selectWindow("Log");
saveAs("Text", dir+Image+"_Summary.txt");

