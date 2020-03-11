//Started work on testing 11th March 2020

//A simple tool to aid in the manual tracking of flourescently labelled cells 
//during pattern fomrtion

//Place Cell_Patterning.ijm in /fiji/macros/toolsets and restart

//Clicking the first button initialises the analysis tool
//Click the second to track a cell
//Use the third to adda new track

//Results are recorded in the same format as the manual tracking tool (http://rsbweb.nih.gov/ij/plugins/track/track.html)

//Global variables for cell tracking
var gtrack = 1;
var number = 1;
var count = 1;
var Image = "";
var x_values = newArray();
var y_values = newArray();
var roi_n = 0;
var com_roi_x = 0; 
var com_roi_y = 0; 
var time_step = 10;//this is the image acquisition rate in minutes
var cal = 0.619;//This is the resolution of the image in micron/px
var sample = 5;
var Image = "";
var dir = "";
var tdir = getDirectory("temp");
var shortest = 100000;
var	xpoints =newArray();
var ypoints =newArray();
var angle = 0;
var euc_dis = 0;
var step = 6;//the size of the window in time steps

macro "Initialize Action Tool - CeefD25D4cD52Dd6CdddD18CfffD00D01D02D03D0cD0dD0eD0fD10D11D1eD1fD20D27D28D2fD30D35D3aD3fD44D4bD53D5cD72D82Da3DacDb4DbbDc0Dc5DcaDcfDd0Dd7DdfDe0De1DeeDefDf0Df1Df2Df3DfcDfdDfeDffCcccDd4CfffD26D39D62D7dD92Db3Dc4Dc6Dd8CdefD22D2dDd2DddCaaaDe7CeffD04D0bD29D37D38D40D45D4fD54D55D64D6cD73D7bD83D8aD8dD99D9cDa8Db0DbfDc9Df4DfbCdefD5bD6aD6bDa9Db7Db8CcdfD14D41Db1CfffD12D1dD21D2eD34D36D43D63D93Dd1DdeDe2DedCdefD05D0aD13D1cD31D3eD50D5fDa0DafDc1DceDe3DecDf5DfaC58cD97CeefD46D47D56D65D84CdeeD9dCbdfDebCbcdDadCeefD49D4aD58D59D5aD67D68D69D6dD7cD8cDa5Da6Db5Db6Dc7Dc8CcefD06D09D60D6fD90D9fDf6Df9C58cD75D76D77D78D79D86D87D88CeefD48D57D66D94D95Da4CddeD24D42Dd5CcdeD3dCbbcD3cDe6C9aaDbdCeeeD2aCbdfD07D08D70D7fD80D8fDf7Df8CaceD96CeffD3bCdddD71CccdDe5CabbDe9C999D7eD8eCdefD8bD9aD9bDaaDabDb9DbaCcdfD1bDe4CbcdDcdDdcCddeD15D51CcdeD1aDa1Dc2Dd3CbbdDaeCaabD9eDdbCeeeDa2CbdeDa7DbeCdddD17D19D81CccdDc3CaabD6eC9aaDccCdefD23D32CcdfD4eCbcdDdaCcdeD2cCaaaDe8CbceD74D85CddeD16D33D61D91CcddD5dDb2CbbbD4dCbcdD5eDeaCdeeDbcDcbDd9CccdD2b"
  {

//remove scale if any
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");

Image = getTitle();
dir = File.directory();
gtrack = 1;
number = 1;
count = 1;
getDimensions(width, height, channels, slices, frames);

if (frames > slices) {
	run("Re-order Hyperstack ...", "channels=[Channels (c)] slices=[Frames (t)] frames=[Slices (z)]");
	}

getDimensions(width, height, channels, slices, frames);

//print(slices);

//prompt for calibration of image
Dialog.create("Please set calibration values");
Dialog.addNumber("Time Step (min):", 10);
Dialog.addNumber("Scale (um/px):", 0.619);
Dialog.addNumber("Number of random cells:", 5);
Dialog.show();
time_step = Dialog.getNumber();
cal = Dialog.getNumber();
sample = Dialog.getNumber();

//Promt user to define the hair follicle condensate in the finale frame
setSlice(slices);
run("Select None");
setTool("oval");
waitForUser("Select Condensate", "Please outline the condensate and press OK");

//save snapshots frame 1 and last
run("Select None");
setSlice(1);
//run("Select All");
//run("Copy");
run("Duplicate...", " ");
run("Restore Selection");
run("RGB Color");
run("Colors...", "foreground=red background=red selection=red");
run("Draw");
run("Select None");
saveAs("Tiff", dir+Image+"_ROI_First.tif");
run("Close");

run("Select None");
setSlice(slices);
//run("Select All");
//run("Copy");
run("Duplicate...", " ");
run("Restore Selection");
run("RGB Color");
run("Colors...", "foreground=red background=red selection=red");
run("Draw");
run("Select None");
saveAs("Tiff", dir+Image+"_ROI_Last.tif");
run("Close");

//get the skeleton of the condensate
selectWindow(Image);
run("Restore Selection");

if (isOpen("Results")){
	selectWindow("Results");
	run("Close");
}

//get all the x and y positions of the pixels in the selection 
getSelectionBounds(x0, y0, width, height); 

for (y=y0; y<y0+height; y++) {
  for (x=x0; x<x0+width; x++) { 
    if (selectionContains(x, y)){ 
     x_values = Array.concat(x_values, x);
     y_values = Array.concat(y_values, y);
     }
  } 
}

get_skel_xy(Image);

//add to the saved images
open(dir+Image+"_ROI_First.tif");
run("Restore Selection");
run("Colors...", "foreground=yellow background=black selection=red");
run("Draw");
run("Select None");
saveAs("Tiff", dir+Image+"_ROI_First.tif");
run("Close");

open(dir+Image+"_ROI_Last.tif");
run("Restore Selection");
run("Colors...", "foreground=yellow background=black selection=red");
run("Draw");
run("Select None");
saveAs("Tiff", dir+Image+"_ROI_Last.tif");
run("Close");

//save log of coordinates
print("X Values");
Array.print(x_values);
print("Y Values");
Array.print(y_values);
selectWindow("Log");
saveAs("Text", dir+Image+"Seelction_Coordinates.txt");

if (isOpen("Log")){
	selectWindow("Log");
	run("Close");
}

//add all cells to the manager
if (isOpen("ROI Manager")){
	selectWindow("ROI Manager");
	run("Close");
}

run("Select None");
setSlice(1);
run("Select All");
run("Copy");
run("Select None");
run("Internal Clipboard");
run("8-bit");
run("Gaussian Blur...", "sigma=1");
run("Find Maxima...", "noise=15 output=[Point Selection]");
getDimensions(width, height, channels, slices, frames);

newImage("Untitled", "8-bit black", width, height, 1);
run("Colors...", "foreground=white background=black selection=cyan");
run("Restore Selection");
run("Draw");
run("Make Binary");
//run("Invert");//////////////////////////////////////////////////////////////////////////////////////////////////CHECK YOU NEED THIS LINE ON YOUR SETUP
run("Analyze Particles...", "exclude add");

selectWindow(Image);
roiManager("Show All");

if (isOpen("Clipboard")){
	selectWindow("Clipboard");
	run("Close");
}

if (isOpen("Untitled")){
	selectWindow("Untitled");
	run("Close");
}

//randomly select 20 ROIS
run("Set Measurements...", "center redirect=None decimal=4");
roiManager("Select All");
roiManager("Measure");


//make sure there are enough rois in the manager
cells = roiManager("count");

if (sample > cells) {sample = cells;} else {}


if (isOpen("ROI Manager")) {
    selectWindow("ROI Manager");
    run("Close");
          }

k=0; 
n=nResults(); 
rois=newArray(n); 

for(i=0;i<n;i++) 
    rois[i]=k++; 

//need to check that if there are less tham roi_n cells it just seslects all
myFisherYates(rois); 

count=1; 
for(i=0;i<sample;i++) { 
    x = getResult("XM", rois[i]); 
    y = getResult("YM", rois[i]); 
    makePoint(x, y);
    roiManager("Add");  
   } 

if (isOpen("Results")) {
    selectWindow("Results");
    run("Close");
          }

selectWindow(Image);
roiManager("Show None");

roiManager("Select", roi_n);/////is it missing the first one?
run("Enlarge...", "enlarge=10");

}
macro "Manual Track MB Tool - CfffD00D01D02D03D04D05D06D07D0bD0cD0dD0eD0fD10D11D12D13D14D15D16D17D19D1bD1cD1dD1eD1fD20D21D22D23D24D25D26D2bD2cD2dD2eD2fD30D31D32D33D34D39D3aD3bD3cD3dD3eD3fD40D41D42D43D50D51D52D53D60D61D62D68D69D6aD70D71D77D78D79D7aD7bD7cD7dD84D87D88D89D8aD8bD8cD8dD8eD8fD91D93D94D97D98D99D9aD9bD9cD9dD9eD9fDa3Da4Da7Da8Da9DaaDabDacDadDaeDafDb0Db1Db2Db3Db4Db8Db9DbaDbbDbcDbdDbeDbfDc0Dc1Dc2Dc3Dc4Dc9DcaDcbDccDcdDceDcfDd0Dd1Dd2Dd3Dd4Dd9DdaDdbDdcDddDdeDdfDe0De1De2De3De4De5DeaDebDecDedDeeDefDf0Df1Df2Df3Df4Df5DfbDfcDfdDfeDffC48dD4dD6cDc8Dd7Dd8De6De7Df6C37dD7fDfaC69eDa5C777D45C58dD6dDc6Dd5C999D27D36D37D38D54D63D64D72D73D74D83C8beD5eD75C48dD6bDb7Dc7Dd6C48dD4eDf7C8aeD49D4aD58D59C888D28D46D55D82C59eD96Db6C9beD57C47dD4fD7eDe8De9Df8Df9C7aeD5fD6fC59dDb5Dc5C8beD5aD66C69dD47D65C69eD76D86Da6C9beD5bD5cD5dD85C7aeD48D4bC59eD4cC59dD67C8beD95C6aeD6e" 
{

run("Restore Selection");

//check there is a selection if not ask to press the new track button
    type = selectionType();
    if (type == -1) {exit("There is no selection have you initialised the image?");}

//some variables
    track = gtrack;
    slice = getSliceNumber();
    
    width = getWidth();
    height = getHeight();
//draws the tracking table
    requires("1.38m");
    title1 = Image+"_Tracking Table";
    title2 = "["+title1+"]";
    f = title2;
    if (isOpen(title1)) {
    }
    else {
        if (getVersion>="1.41g")
            run("Table...", "name="+title2+" width=1000 height=300");
        else
            run("New... ", "name="+title2+" type=Table width=250 height=600");
        print(f, "\\Headings: \tImage_ID\tTrack\tSlice\tX\tY\tFollicle_COMX\tFollicle_COMY\tDistance_from_COM\tInside?");
    }
    run("Colors...", "foreground=white background=white selection=cyan");
    autoUpdate(false);
    getCursorLoc(x, y, z, flags);
    makePoint(x, y);
    wait(250);
    run("Colors...", "foreground=white background=white selection=red");
    run("Enlarge...", "enlarge=15");

	//get nearest distance to the skeleton
	get_s_dist(x, y, xpoints, ypoints);
    dist = shortest;
    
    //is the xy position within the condensate at this time point?
    inside = "No";

    for (i = 0; i < x_values.length; i++) {
       if ((x == x_values[i]) && (y == y_values[i])) {inside = "Yes";} else {}
    //print("inside = "+inside);
    }

    print(f,(number++)+"\t"+Image+"\t"+(track)+"\t"+(slice)+"\t"+(x)+"\t"+(y)+"\t"+com_roi_x+"\t"+com_roi_y+"\t"+dist+"\t"+inside);
        
//advance to next slice
        run("Next Slice [>]");
        selectWindow(Image);
    }


//You do not need to click it before you start tracking as gtrack is set to 1 in the first instance.
macro "Add Track Action Tool - CfffD00D01D02D03D04D05D06D07D0bD0cD0dD0eD0fD10D11D12D13D14D15D16D17D19D1bD1cD1dD1eD1fD20D21D22D23D24D25D26D2bD2cD2dD2eD2fD30D31D32D33D34D39D3aD3bD3cD3dD3eD3fD40D41D42D43D50D51D52D53D60D61D62D68D69D6aD70D71D77D78D79D7aD7bD7cD7dD84D87D88D89D8aD8bD8cD8dD8eD8fD91D93D94D97D98D99D9fDa3Da4Da7Da8Db0Db1Db2Db3Db4Db8DbcDc0Dc1Dc2Dc3Dc4DcbDccDcdDd0Dd1Dd2Dd3Dd4DdcDe0De1De2De3De4De5Df0Df1Df2Df3Df4Df5DffC37dD7fC777D45C69dD47D65C777D08D09D0aD18D1aD29D2aD35D44D56D80D81D90D92Da0Da1Da2C48dD6bDb7Dc7Dd6Cbd9DabDbaDbbDceDecC8beD5eD75C582DaeDeaDeeC48dD4dD6cDc8Dd7Dd8De6De7Df6C999D27D36D37D38D54D63D64D72D73D74D83C7aeD48D4bC8b6DadDbeDdbDdeDebDedC59dDb5Dc5C9beD57C361D9dC48dD4eDf7C888D28D46D55D82C69eDa5C58dD6dDc6Dd5Cbd9DacC684Dc9C8aeD49D4aD58D59C8b6DdaC59dD67C9beD5bD5cD5dD85C47dD4fD7eDe8Df8Df9C69eD76D86Da6C8beD5aD66C473De9C7aeD5fD6fC8beD95C473D9cC6aeD6eCdebDcaC8a6DaaC59eD96Db6C59eD4cC695Da9Db9C584D9bDd9C8b6DbdDddC685D9a"
{
run("Colors...", "foreground=white background=black selection=cyan");
//randomly make a slection from manager
    if (roi_n < (roiManager("count"))-1) {
    	roi_n = roi_n + 1;
    	} 
       else {
       	exit("You have tracked all the selected cells");
       }
	
	roiManager("Select", roi_n);
	run("Enlarge...", "enlarge=10");	
    setTool("rectangle");
    gtrack++;
    waitForUser("A new track ("+gtrack+") has been added to the analysis. Please select the tracking button and continue");
    setSlice(1);
}

macro "Get Class and Trim Action Tool - CfffD00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD10D11D12D13D14D15D16D17D18D19D1aD1bD1cD1dD1eD1fD20D21D24D25D26D27D28D29D2aD2bD2eD2fD30D3fD40D41D44D45D46D47D48D49D4aD4bD4eD4fD50D51D52D53D54D55D56D57D58D59D5aD5bD5cD5dD5eD5fD60D61D62D64D65D67D68D6aD6bD6dD6eD6fD70D71D72D74D75D77D78D7aD7bD7dD7eD7fD80D81D82D84D85D87D88D8aD8bD8dD8eD8fD90D91D92D94D95D97D98D9aD9bD9dD9eD9fDa0Da1Da2Da4Da5Da7Da8DaaDabDadDaeDafDb0Db1Db2Db4Db5Db7Db8DbaDbbDbdDbeDbfDc0Dc1Dc2Dc4Dc5Dc6Dc7Dc8DcaDcbDccDcdDceDcfDd0Dd1Dd2Dd4Dd5Dd6Dd7Dd8DdaDdbDdcDddDdeDdfDe0De1De2De3De4De5De6De7De8De9DeaDebDecDedDeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffC59dD3bC555D96CbbbDd3C333D6cDa9C7aeD38C666D93Dd9CdefD2dD3eD4dC222D8cDc9C69dD3dC666D66D76Da3Db3C9ceD33C444D69D79Da6C8beD36C777D63D73D83CeefD31C111D9cDacC69dD2cD4cC555D86Dc3C9beD23D34D43C333D99C7aeD37C222D7cDb9C69eD39D3cC8beD32D35CfffD22D42C69eD3aC444D89Db6"
{

//if the results table is empty prompt for a results table

if (isOpen("Results")) {
	getClass();
}

	else {
		//Dialog.create("No Results table");
		waitForUser("There is no Results table open please select a tracking table or press cancel");
		//Dialog.show();
		table = getInfo("window.name");
		//print(table);
		selectWindow(table);
		tdir = getDirectory("temp");
		saveAs("Text", tdir+Image+"Tracking_Results.xls");
		open(tdir+Image+"Tracking_Results.xls");
		getClass();
		}

updateResults();


Dialog.create("Trim Data?");
Dialog.addMessage("If you would like to trim the data on yes press OK, otherwise cancel");
Dialog.show();
track_number = newArray();
t_num = 0;

for (j=0; j<nResults; j++) {
	if ((getResult("Track", j) > t_num)||(getResult("Track", j) < t_num)) {
		t_num = getResult("Track", j);
		track_number = Array.concat(track_number, t_num);	
	}
}

for (i=0; i<track_number.length; i++){
	var flag = true;
	
	for (j=0; j<nResults; j++){
		if (getResult("Track", j) == track_number[i] && getResultString("Inside?", j) == "Yes") {flag = false;}
		if (getResult("Track", j) == track_number[i] && !flag) {setResult("Flag", j, "Delete");}
		}
}

updateResults();

//loop through and delete all the entries flagged "Delete"

deleteChosenRows("Flag", "Delete", "Class", "No-No");
}

macro "Add Summary Stats Action Tool - CfffD00D0eD0fD10D14D15D16D17D18D19D1aD1bD1cD1eD1fD20D24D27D2aD2eD2fD30D34D37D3aD3eD3fD40D44D45D46D47D48D49D4aD4bD4cD4eD4fD50D54D57D5aD5eD5fD60D64D67D6aD6eD6fD70D74D75D76D77D78D79D7aD7bD7cD7eD7fD80D84D87D8aD8eD8fD90D94D97D9aD9eD9fDa0Da4Da5Da6Da7Da8Da9DaaDabDacDaeDafDb0Db4Db7DbaDbeDbfDc0Dc4Dc7DcaDceDcfDd0Dd4Dd5Dd6Dd7Dd8Dd9DdaDdbDdcDdeDdfDe0DeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffC9c9D5bD6bD85D86D95D96C7adD07D61C8adD02C68bD3dCf66D2bD3bC6beD28D29D38D39D55D56D65D66CbcdD01De1C58bDe6CdddD25D26D35D36D58D59D68D69D8bD9bDb5Db6DbbDc5Dc6DcbC7adD03D04D05D06D13D21D23D31D33D41D43D51D53D63D73D83D93Da3Db3Dc3Dd3C9beD12D22D32D42D52D62D72D82D92Da2Db2Dc2Dd2C79cD91Da1Cfd6Db8Db9Dc8Dc9CeeeD8cD9cDbcDccC57aD9dC89cDd1C9bdD11C69cD0aD0bD0cDb1Dc1Cfa7D88D89D98D99CdedD5cD6cC68bD4dDe4De5C79dD08D09D71D81CfccD2cD3cC68cD1dC58bD5dC57bD6dD7dD8dDe7De8De9C8acD0dDedC68cD2dDe3C79cDe2"
{

//prompt to select the results table to summarise
//if (isOpen("Results")) {
  //  selectWindow("Results");
    //run("Close");
          //}

//selectWindow(Image+"_Tracking Table");
//tdir = getDirectory("temp");
//saveAs("Text", tdir+Image+"Tracking_Results.xls");
//open(tdir+Image+"Tracking_Results.xls");

//if the results table is empty prompt for a results table
//prompt for calibration of image
Dialog.create("Please set calibration values");
Dialog.addNumber("Time Step (min):", 10);
Dialog.addNumber("Scale (um/px):", 0.619);
Dialog.show();
time_step = Dialog.getNumber();
cal = Dialog.getNumber();

if (isOpen("Results")) {
	basic_summary();
	per_track_summary();
}

else {
	//Dialog.create("No Results table");
	waitForUser("There is no Results table open please select a tracking table or press cancel");
	//Dialog.show();
	table = getInfo("window.name");
	//print(table);
	selectWindow(table);
	tdir = getDirectory("temp");
	saveAs("Text", tdir+Image+"Tracking_Results.xls");
	open(tdir+Image+"Tracking_Results.xls");
	basic_summary();
	per_track_summary();
	}
}

macro "Vector Windows Action Tool - CfffD00D01D02D03D04D05D09D0aD0eD0fD10D11D12D13D14D15D19D1aD1eD1fD20D21D22D23D24D25D29D2eD2fD30D31D32D33D34D35D36D39D3cD3dD3eD3fD40D41D42D43D44D45D46D47D4bD4cD4dD4eD4fD50D51D52D53D54D55D56D57D5aD5bD5cD5dD5eD5fD60D61D62D63D64D65D66D6bD6cD6dD6eD6fD70D71D72D73D74D7cD7dD7eD7fD80D81D82D83D84D88D8cD8dD8eD8fD90D91D92D93D94D9cD9dD9eD9fDa0Da1Da2Da3Da4Da5DaaDabDacDadDaeDafDb0Db1Db2Db3Db4Db8Db9DbaDbbDbcDbdDbeDbfDc0Dc1Dc2Dc3Dc8Dc9DcaDcbDccDcdDceDcfDd0Dd9DdaDdbDdcDddDdeDdfDe0De4De5De9DeaDebDecDedDeeDefDf0Df4Df5Df9DfaDfbDfcDfdDfeDffC47bDe6Cf55D18D27CabdD97Dd8Df6Cf33D7aD89D99C78bDa6Cf88D98CaceD0bD75D95Ce23D8bD9aC58cD1dCf66D38Cc9bD58Cf55Df2C8acDe7Cf99De2CfddD37D6aCc79Db7C48cD2bD2cD77D87Cf66D07D16CaceD3bCf44De3C69dD3aCf99D08D26D8aDc4CcdfD78Ce34Db6C58dD0cD85Cf77D28D48CfbbD17Dd1Cf55Dd2De1C9bdDd6CfaaDf3CfeeDd5C47bDe8Df7C79bD96C58dD1bD76Cf67D7bDa8Dd4CcabDc6Cf55D79Dd3C9adD1cCf99D06Ca8bD49Cf66D9bCaceD0dD2dCf45D69Dc5C79cDc7CddfD67Cc56D59CfccDb5C9bdD86CfaaDf1CeffD2aC58cD68C8adD4aCe55Da7CabdDf8CfffDa9"{
	
//looping through tracking data and calcualting the angle from com euclidean and speed for hour long windows

//prompt for the window size required and confirm the time step
//prompt for calibration of image
Dialog.create("Please specicify the window size");
Dialog.addNumber("Time Step (min):", time_step);
Dialog.addNumber("Window length (min):", (step*time_step));
Dialog.show();
time_step = Dialog.getNumber();
step = Dialog.getNumber();
step = step/time_step;
prefix = step*time_step;

//calculate distance for each step
for (i=0; i<nResults; i++) {
	if (getResult("Track", i) == getResult("Track", i-1)) {
		x = getResult("X", i);
		y = getResult("Y", i);
		x1 = getResult("X", i-1);
		y1 = getResult("Y", i-1);
		if (x > x1) {x2 = x - x1;} else {x2 = x1 - x;}
        if (y > y1) {y2 = y - y1;} else {y2 = y1 - y;}
        dist = (sqrt((x2*x2)+(y2*y2)))*cal;
        speed = dist/time_step;
        setResult(prefix+"-min Distance (um)", i, dist);
        setResult(prefix+"-min Speed (um/min)", i, speed);
	}
		
}

//get the track numbers in an array to use as the index

track_number = newArray();
t_num = 0;

for (w=0; w<nResults; w++) {
	if ((getResult("Track", w) > t_num)||(getResult("Track", w) < t_num)) {
		t_num = getResult("Track", w);
		track_number = Array.concat(track_number, t_num);	
	}
}

//Array.print(track_number);

//get the centre of the follicle as x2 and y2
//x2 = getResult("Follicle_COMX", 1);
//y2 = getResult("Follicle_COMY", 1);

for (i=0; i<track_number.length; i++){
	
	values_x = newArray();
	values_y = newArray();
	values_x2 = newArray();
	values_y2 = newArray();
	j_values = newArray();
	the_angle = newArray();
	euc_dis_a = newArray();
	euc_speed = newArray();
	distance = newArray();
	a_distance = newArray();
	//persitence = newArray();
	
	for (j=0; j<nResults; j++) {
		
		if (getResult("Track", j) == track_number[i]){
			x_val = getResult("X", j);
			values_x = Array.concat(values_x, x_val);
			x2_val = getResult("Follicle_COMX", j);
			values_x2 = Array.concat(values_x2, x2_val);
			y_val = getResult("Y", j);
			values_y = Array.concat(values_y, y_val);
			y2_val = getResult("Follicle_COMX", j);
			values_y2 = Array.concat(values_y2, y2_val);
			j_values = Array.concat(j_values, j);
			dist = getResult("Distance_(um)", j);
			distance = Array.concat(distance, dist);
		}
		
	}
	
	for (d=0; d<values_x.length-step; d++){

		//the first x, y positions are x and y
		x = values_x[d];
		y = values_y[d];

		//the first COM positions are x2 and y2
		x2 = values_x2[d];
		y2 = values_y2[d];

		//the forward x, y  positions are x1 and y1
		x1 = values_x[d+step];
		y1 = values_y[d+step];

		//put results in array and call function
		xarray = newArray(x,x1,x2);
		yarray = newArray(y,y1,y2);

		//Array.print(xarray);
		//Array.print(yarray);
		
		law_of_cosines(xarray, yarray);
		the_angle = Array.concat(the_angle, angle);
		euc_dis_a = Array.concat(euc_dis_a, euc_dis);
		euc_speed = Array.concat(euc_speed, (euc_dis/(step*time_step)));
	
		accumulated = 0;
		count = 0;
		
		while (count <= step){
			//accumulated = accumulated + distance[d+1] + distance[d+2] + distance[d+3] + distance[d+4] + distance[d+5] + distance[d+6]; 
			accumulated = accumulated + distance[d+count];
			//print("Count = "+(d+count));	
			count++;
			//print(accumulated);
		}

		a_distance = Array.concat(a_distance, accumulated);
	
	}
	
//loop through all results and write the window

for (r=0; r<nResults; r++) {
	setResult("Most Recent Window (min)", r, (step*time_step));
}
	
	//Array.print(a_distance);
	//stop
//write back to the results table
	for (n=0; n<j_values.length-step; n++) {
		index = j_values[n];
		//setResult("Window (min)", index, (step*time_step));
		setResult(prefix+"-min Euc. Angle", index, (the_angle[n]));
		setResult(prefix+"-min Euc. Dis (um)", index, (euc_dis_a[n]));
		setResult(prefix+"-min Euc. Speed (um/min)", index, (euc_speed[n]));
		//print(a_distance[n]);
		setResult(prefix+"-min Acc. Dis (um)", index, (a_distance[n]));
		//setResult("1hr Persistence", index, (persistence[n]));
	}

}
//get speed

for (c=0; c<nResults; c++) {
	if (getResult(prefix+"-min Acc. Dis (um)", c)>0) {
		d = getResult(prefix+"-min Acc. Dis (um)", c);
		sp = d/(step*time_step);
		setResult(prefix+"-min Acc. Speed (um/min)", c, sp);
	}
}
//get the persistence

for (h=0; h<nResults; h++) {
	persistence = (getResult(prefix+"-min Euc. Dis (um)", h)) / (getResult(prefix+"-min Acc. Dis (um)", h));
	setResult(prefix+"-min Pers", h, persistence);
}

//negatively number a track from the final timepoint
//get the slices into an array

i = 0;
j = 0;


for (i=0; i<track_number.length; i++){

slices = newArray();

for (j=0; j<nResults; j++) {
		
		if (getResult("Track", j) == track_number[i]){
			slices = Array.concat(slices, getResult("Slice", j));
		}
	}
Array.getStatistics(slices, min, max, mean, stdDev);
Array.reverse(slices);

for (j=0; j<nResults; j++) {
		
		if ((getResult("Track", j) == track_number[i])&(max>step)){
			setResult("-Index", j, (max-step));
			max = max-1;
		}
	}

}
}

macro "Summarise Windows Action Tool - CfffD00D0eD0fD10D14D15D16D17D18D19D1aD1bD1cD1eD1fD20D24D27D2aD2eD2fD30D34D37D3aD3eD3fD40D44D45D46D47D48D49D4aD4bD4cD4eD4fD50D54D57D5aD5eD5fD60D64D67D6aD6eD6fD70D74D75D76D77D78D79D7aD7bD7cD7eD7fD80D84D87D8aD8eD8fD90D94D97D9aD9eD9fDa0Da4Da5Da6Da7Da8Da9DaaDabDacDaeDafDb0Db4Db7DbaDbeDbfDc0Dc4Dc7DcaDceDcfDd0Dd4Dd5Dd6Dd7Dd8Dd9DdaDdbDdcDdeDdfDe0DeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffC9c9D5bD6bD85D86D95D96C7adD07D61C8adD02C68bD3dCf66D2bD3bC6beD28D29D38D39D55D56D65D66CbcdD01De1C58bDe6CdddD25D26D35D36D58D59D68D69D8bD9bDb5Db6DbbDc5Dc6DcbC7adD03D04D05D06D13D21D23D31D33D41D43D51D53D63D73D83D93Da3Db3Dc3Dd3C9beD12D22D32D42D52D62D72D82D92Da2Db2Dc2Dd2C79cD91Da1Cfd6Db8Db9Dc8Dc9CeeeD8cD9cDbcDccC57aD9dC89cDd1C9bdD11C69cD0aD0bD0cDb1Dc1Cfa7D88D89D98D99CdedD5cD6cC68bD4dDe4De5C79dD08D09D71D81CfccD2cD3cC68cD1dC58bD5dC57bD6dD7dD8dDe7De8De9C8acD0dDedC68cD2dDe3C79cDe2"
{
	summarise_windows();
}

//ADD//FUNCTIONS//BELOW//THIS//LINE////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////
//Function return the angle from two arrays
//angle of interest must be at xarray[0], yarray[0]

function law_of_cosines(xarray,yarray){
	//a distances
	xd_a = xarray[0] - xarray[1];
	yd_a = yarray[0] - yarray[1];
	a = (sqrt((xd_a*xd_a)+(yd_a*yd_a)))*cal;//x,y to x1,y1
	euc_dis = a;//check this is always consistent???????????????????????????????

	//b distances
	xd_b = xarray[0] - xarray[2];
	yd_b = yarray[0] - yarray[2];
	b = (sqrt((xd_b*xd_b)+(yd_b*yd_b)))*cal;//x,y to x2,y2

	//c distances
	xd_c = xarray[1] - xarray[2];
	yd_c = yarray[1] - yarray[2];
	c = (sqrt((xd_c*xd_c)+(yd_c*yd_c)))*cal;//x1,y1 to x2, y2

	if (a == 0){angle=0;} //to avoid NaN error
		else {
			//calculate
			radian = acos(((a*a)+(b*b)-(c*c))/(2*(a*b)));
			angle = radian*(180/PI);
			}

}


function deleteChosenRows(column, tag, column2, class) {
	//deletes rows that have tag in column unless they have class in column 2
	//get the column headings in array

	//deleteChosenRows("Flag", "Delete", "Class", "No-No");
	
	headings = split(String.getResultsHeadings);

	if (isOpen("Log")) {
		selectWindow("Log");
		run("Close");
	}

	//print to log
	Array.print(headings);

	for (i=0; i<nResults; i++) {
		linevalues = newArray();
		if (getResultString(column, i) == tag && getResultString(column2, i) != class) {
		}
		else {
			for (j=0; j<headings.length; j++) {
				value = getResultString(headings[j], i);
				linevalues = Array.concat(linevalues, value);
			}
			Array.print(linevalues);
		}
	}

	tdir = getDirectory("temp");
	selectWindow("Log");
	saveAs("Text", tdir+"Log.csv");
	open(tdir+"Log.csv");

	if (isOpen("Log")) {
		selectWindow("Log");
		run("Close");
	}
}


function getClass() {

	///Is there a results table containing the column heading Inside?

	if (isOpen("Results") && getResultString("Inside?", 0) == "Yes" || getResultString("Inside?", 0) == "No") {

		//get the class (e.g. no-yes)
		track_number = newArray();
		t_num = 0;

		for (j=0; j<nResults; j++) {
			if ((getResult("Track", j) > t_num)||(getResult("Track", j) < t_num)) {
				t_num = getResult("Track", j);
				track_number = Array.concat(track_number, t_num);	
			}
		}

		for (i=0; i<track_number.length; i++){

			j_values = newArray();
			for (j=0; j<nResults; j++) {
		
				if (getResult("Track", j) == track_number[i]){
					j_values = Array.concat(j_values, j);
				}	
			}

			//get the class
			tminclass = j_values[0];
			tmaxclass = j_values[j_values.length-1];
			class1 = getResultString("Inside?", tminclass);
			class2 = getResultString("Inside?", tmaxclass);
			class = class1+"-"+class2;

			//write back the class
			for (n=0; n<j_values.length; n++) {
				index = j_values[n];
				setResult("Class", index, class);
			}
		}
	}
}

///////////////////////////////////randomise an array

function myFisherYates(array) { 
    
    if(array.length!=0) { 
        
        for (i=0;i<array.length ;i++) { 
            j = floor(random()*(i+1)); 
            temp1 = array[i]; temp2 = array[j]; 
            array[i] = temp2; array[j] = temp1; 
     	   } 
    	} 
	} 
//////////////////////////////return an array of x and y positions for the skeleton of a selection

function get_skel_xy(image) {

	selectWindow(image);
	
	//check for a selection
	sel = selectionType();
	
	if (sel == -1 || sel == 10){
		exit("There is no area selection");
		}
		
		else {
			run("Colors...", "foreground=white background=white selection=cyan");
			getDimensions(width, height, channels, slices, frames);
			newImage("skeleton", "8-bit black", width, height, 1);
			run("Restore Selection");
			run("Cut");
			run("Make Binary");
			run("Skeletonize");

			run("Points from Mask");
			getSelectionCoordinates(xpoints, ypoints);

			if (isOpen("skeleton")) {
				selectWindow("skeleton");
				run("Close");
				}

			selectWindow(image);
			run("Restore Selection");
		}
	}

/////////////////////////////get the shortest distance between x,y and the values in xarray, yarray

function get_s_dist(x, y, xvalues, yvalues) {
	
	//check the arrays are the same length
	if (xvalues.length == yvalues.length){
	
		shortest = 100000;
		for (i=0; i<xvalues.length; i++) {

			xdist = x - xvalues[i];
			ydist = y - yvalues[i];
			dist1 = sqrt((xdist*xdist)+(ydist*ydist));

			if (dist1 < shortest) {
				shortest = dist1;//*cal;
				com_roi_x = xvalues[i];
				com_roi_y = yvalues[i];
			}
		}
		//print("Shortest distnace to centre of ROI = "+shortest+" pixels");
	}
	else {
		exit("The arrays are different lengths are these xy coorinates");
		}
}

///////////////////////////////////////////basic summary(this code is ugly)

function basic_summary() {

//get the track numbers in an array to use as the index

track_number = newArray();
t_num = 0;

for (w=0; w<nResults; w++) {
	if ((getResult("Track", w) > t_num)||(getResult("Track", w) < t_num)) {
		t_num = getResult("Track", w);
		track_number = Array.concat(track_number, t_num);	
	}
}

//Get number of tracks (nTracks)
nTracks = track_number.length;

//get track lengths in array and write to results
track_lengths = newArray();

for (a=0; a<track_number.length; a++){
	t_le = 0;
	for (i=0; i<nResults; i++) {
		if (getResult("Track",i) == track_number[a]) {
			t_le = t_le +1;
		}
	}
	track_lengths = Array.concat(track_lengths, t_le);
}

//Array.print(track_lengths);

for (a=0; a<track_number.length; a++){
	for (i=0; i<nResults; i++) {
		if (getResult("Track",i) == track_number[a]) {
			setResult("T_Length", i, track_lengths[a]);
		}
	}
}

//calculated accumulated distance for each step
for (i=0; i<nResults; i++) {
	if (i==0) {//stops it looping between the first/last value if there is only 1 track
		dist = 0;
		speed = 0;
	}
	else {
		if (getResult("Track", i) == getResult("Track", i-1)) {
			x = getResult("X", i);
			y = getResult("Y", i);
			x1 = getResult("X", i-1);
			y1 = getResult("Y", i-1);
			x2 = x-x1;
			y2 = y-y1;
      	  	dist = (sqrt((x2*x2)+(y2*y2)))*cal;
       	 	speed = dist/time_step;     	
		}
	}	
	setResult("Distance_(um)", i, dist);
    setResult("Speed_(um/min)", i, speed);
}

//sum the accumulated disances
setResult("Acc_Dist_(um)", 1 , 0);
for (i=0; i<nResults; i++) {
	if (getResult("Track", i) == getResult("Track", i-1)) {
		summed = (getResult("Distance_(um)", i) + getResult("Acc_Dist_(um)", i-1));
		setResult("Acc_Dist_(um)", i, summed);
  }
}

//euclidean for each step
for (j=0; j<track_number.length; j++){
	values_x = newArray();
	values_y = newArray();
	for (k=0; k<nResults(); k++) {
		if (getResult("Track", k) == track_number[j]){
			values_x = Array.concat(values_x, getResult("X", k));
			values_y = Array.concat(values_y, getResult("Y", k));
		}
	}
	
	x = values_x[0];
	y = values_y[0];
	euc_d = newArray(0);
	
	for (n=0; n<(values_x.length); n++) {	
		x1 = values_x[n];
		y1 = values_y[n];
		if (x > x1) {x2 = x - x1;} else {x2 = x1 - x;}
    	if (y > y1) {y2 = y - y1;} else {y2 = y1 - y;}
		eucdist = (sqrt((x2*x2)+(y2*y2))) * cal;
		euc_d = Array.concat(euc_d, eucdist);
			}

    index = -1;
    for (k=0; k<nResults(); k++) {   	
    	if (getResult("Track", k) == track_number[j]) {
    		index = index + 1;
    		value = euc_d[index];
    		setResult("Euclidean_D_(um)", k, value);		
    	}
    }
}

///persistence
euclidean = newArray();
accumulated = newArray();
persistence= newArray();

for (i=0; i<nResults; i++) {
	euclidean = Array.concat(euclidean, getResult("Euclidean_D_(um)",i));
	accumulated = Array.concat(accumulated, getResult("Acc_Dist_(um)",i));
}

for (j=0; j<euclidean.length; j++) {
	value = euclidean[j] / accumulated[j];
	persistence = Array.concat(persistence, value);
}

for (k=0; k<nResults; k++) {
	value = persistence[k];
	setResult("Persistence", k , value);
	}
	
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

function per_track_summary() {

//draws the summary table
    requires("1.38m");
    title1 = "Summary Table";
    title2 = "["+title1+"]";
    f = title2;
    if (isOpen(title1)) {
    }
    else {
        if (getVersion>="1.41g")
            run("Table...", "name="+title2+" width=1000 height=300");
        else
            run("New... ", "name="+title2+" type=Table width=250 height=600");
        print(f, "\\Headings: \tTrack#\tLength (mins)\tAcc. Dist (um)\tEuc. Dist (um)\tPersistence\tAcc. Velocity (um/min)\tEuc. Velocity (um/min)\tClass\tStart Dist. COM (um)");
    }


//get the track numbers in an array to use as the index

track_number = newArray();
t_num = 0;

for (w=0; w<nResults; w++) {
	if ((getResult("Track", w) > t_num)||(getResult("Track", w) < t_num)) {
		t_num = getResult("Track", w);
		track_number = Array.concat(track_number, t_num);	
	}
}

//Get number of tracks (nTracks)
nTracks = track_number.length;

//get the accumulated distance euclidean distance for each track into arrays

euclidean_distances = newArray();
max_distances = newArray();


for (i=0; i<track_number.length; i++){

//get the x, y values in an array

	values_x = newArray();
	values_y = newArray();
	
	for (j=0; j<nResults; j++) {
		
		if (getResult("Track", j) == track_number[i]){
			x_val = getResult("X", j);
			values_x = Array.concat(values_x, x_val);
			y_val = getResult("Y", j);
			values_y = Array.concat(values_y, y_val);
		}
		
	}

//calculate euclidean distance for track
final_value=values_x.length-1;
x = values_x[0];
y = values_y[0];
x1 = values_x[final_value];
y1 = values_y[final_value];
x2 = x-x1;
y2 = y-y1;

eucdist = (sqrt((x2*x2)+(y2*y2))) * cal;
euclidean_distances = Array.concat(euclidean_distances, eucdist);

}

//Total distance = max value in Acc. Dist (um)
total_distance = 0;
distance = 0;

//get the accumulated distance of each track into an array max_distances


for (i=0; i<track_number.length; i++){

	acc_dist = newArray();

	for (j=0; j<nResults; j++) {
		if (getResult("Track", j) == track_number[i]){
			value = getResult("Acc_Dist_(um)", j);
			acc_dist = Array.concat(acc_dist, value);
			}
		
		}
	//Array.print(acc_dist);
	Array.getStatistics(acc_dist, min, max, mean, stdDev);
	total_distance = max;
	max_distances = Array.concat(max_distances, total_distance);
	}

//get the track lengths into an array

track_lengths = newArray();

var done = false; // used to prematurely terminate loop

for (i=0; i<track_number.length; i++){
	//print(i);
	done = false;
	for (j=0; j<nResults && !done; j++) {
	 	if (getResult("Track", j) == track_number[i]){
	 		track_lengths = Array.concat(track_lengths, (getResult("T_Length", j))*time_step);
	 		done = true; // break 
	 		//print("Break"+j);
	 	}
	}
}

//get the classes into an array

track_class = newArray();

var done = false; // used to prematurely terminate loop

for (i=0; i<track_number.length; i++){
	//print(i);
	done = false;
	for (j=0; j<nResults && !done; j++) {
	 	if (getResult("Track", j) == track_number[i]){
	 		t_cl = getResultString("Class", j);
	 		//print(t_cl);
	 		track_class = Array.concat(track_class, t_cl);
	 		done = true; // break 
	 		//print("Break"+j);
	 	}
	}
}

//get initial distance from array for each track
var done1 = false; // used to prematurely terminate loop
dist_com = newArray();

for (i=0; i<track_number.length; i++){
	//print(i);
	done1 = false;
	for (j=0; j<nResults && !done1; j++) {
	 	if (getResult("Track", j) == track_number[i]){
	 		comd = (getResult("Distance_from_COM", j)*cal);
	 		dist_com = Array.concat(dist_com, comd);
	 		done1 = true; // break 
	 		//print("Break"+j);
	 	}
	}
}

//calculate persistence for track as euclidean/accumulated
track_persistence = newArray();
for (i=0; i<track_number.length; i++){
	pers_t = euclidean_distances[i] / max_distances[i];
	track_persistence = Array.concat(track_persistence, pers_t);
}

//calculate track speeds
track_speed = newArray();
e_track_speed = newArray();

for (i=0; i<track_number.length; i++){
	//print(i);
	dis = max_distances[i];
	dis2 = euclidean_distances[i];
	tim = track_lengths[i];
	speed = (dis/tim);
	e_speed = (dis2/tim);
	//print(speed);
	track_speed = Array.concat(track_speed, speed);
	e_track_speed = Array.concat(e_track_speed, e_speed);
	//Array.print(track_speeds);
}

//Array.print(track_number);//works +maths
//Array.print(max_distances);//works +maths
//Array.print(track_lengths);//works +maths
//Array.print(euclidean_distances);//works
//Array.print(dist_com);//works +maths
//Array.print(track_speed);//works +maths
//Array.print(track_persistence);//works +maths
//Array.print(track_class);//works +maths
//Array.print(inside_end);//works +maths

number  = 0;

for (i=0; i<track_number.length; i++){
//exclude tracks with less than 10 timepoints	
	if ((track_lengths[i]/time_step) < 10) {print("Track "+track_number[i]+" excluded < 10 steps");} else {	
		print(f, (number++)+"\t"+(track_number[i])+"\t"+(track_lengths[i])+"\t"+(max_distances[i])+"\t"+(euclidean_distances[i])+"\t"+(track_persistence[i])+"\t"+(track_speed[i])+"\t"+(e_track_speed[i])+"\t"+track_class[i]+"\t"+(dist_com[i]));
    	}
	}

	
}

function summarise_windows() {
	//draws the summary table
    	requires("1.38m");
    	title1 = "Hourly Summary Table";
   	 	title2 = "["+title1+"]";
  	    f = title2;
  	 	if (isOpen(title1)) {
 	   }
  	  else {
  	      if (getVersion>="1.41g")
   	         run("Table...", "name="+title2+" width=1000 height=300");
   	     else
   	         run("New... ", "name="+title2+" type=Table width=250 height=600");
    	    print(f, "\\Headings: Class\tTime from Entry (mins)\tNumber\tMean Angle\tSE\tMean Euc. Dis (um)\tSE\tMean Euc. Speed (um/min)\tSE\tMean Acc. Dis (um)\tSE\tMean Acc. Speed (um/min)\tSE\tMean Persistence\tSE");//\tMean P/D\tStDev");
   	 }
	
	if (isOpen("Log")){
				selectWindow("Log");
				run("Close");
				}
				
	//print raw data to log for stats
	print("Class",",","Entry_Time",",","E_Angle",",","E_Dis",",","E_Speed",",","A_Dis",",","A_Speed",",","Pers");
	
	//prompt for time step and window to allow for multiple analyses


	//prompt for calibration of image
	Dialog.create("Please set window size and time_step");
	Dialog.addNumber("Time Step (min):", 10);
	Dialog.addNumber("Window (min):", 60);
	Dialog.show();
	time_step = Dialog.getNumber();
	window = Dialog.getNumber();

	//time_step = 10;
	//window = getResult("Window (min)",0);
	t_steps = window/time_step;

	max_length = 0;
	//Max steps
	for (a=0; a<nResults(); a++) {
 	   if (getResult("T_Length",a)>max_length)
  	  {
   	  max_length = getResult("T_Length",a);
   		 	}
   		 	else{};
	}

	hour_index = newArray();
	entry_time = newArray();
	start = 1;
	start1 = 0;
	hour_index = Array.concat(hour_index, start);
	entry_time = Array.concat(entry_time, start1);

	entry = 0;
	while ((entry+(t_steps+1)) < max_length) {
		entry = entry + (t_steps+1);
		hour_index = Array.concat(hour_index,entry);
	}

	//Array.print(hour_index);

	for (q=1; q<hour_index.length; q++) {
		start1 = start1 + window;
		entry_time = Array.concat(entry_time, start1);
	}

	//Array.print(entry_time);

	//hour_index = newArray(1, 7, 14, 21, 28, 35, 42, 49, 56, 63, 70, 77, 84, 91, 98, 105, 112, 119, 126, 133, 140, 147);
	//entry_time = newArray(0, 60, 120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840, 900, 960, 1020, 1080, 1140, 1200, 1260);

	//generate an array with the classes in
	classes = newArray(" No-No", " No-Yes");

	///summarise All


	for (z=0; z<classes.length; z++) {

		for (j=0; j<hour_index.length; j++) {

			//specifiy your arrays here
			n_tracks = 0;//number of tracks in the window
			e_angle = newArray();
			e_distance = newArray();
			e_speed = newArray();
			a_dis = newArray();
			a_speed = newArray();
			pers = newArray();
			pxd = newArray();
	
			for (k=0; k<nResults; k++) {
				if ((getResultString("Class", k) == classes[z]) && (getResult("-Index", k) == hour_index[j])) {
				//poulate your arrays here
				//n_tracks = Array.concat(n_tracks,);
				test_angle1 = getResult(window+"-min Euc. Angle", k);
				test_angle2 = d2s(test_angle1, 0);
				if (test_angle2 == "NaN") {} else {e_angle = Array.concat(e_angle, test_angle1);}
		
				test_e_dis1 = getResult(window+"-min Euc. Dis (um)", k);
				test_e_dis2 = d2s(test_e_dis1, 0);
				if (test_e_dis2 == "NaN") {} else {e_distance = Array.concat(e_distance, test_e_dis1);}
		
				test_e_speed1 = getResult(window+"-min Euc. Speed (um/min)", k);
				test_e_speed2 = d2s(test_e_speed1, 0);
				if (test_e_speed2 == "NaN") {} else {e_speed = Array.concat(e_speed, test_e_speed1);}
		
				test_a_dis1 = getResult(window+"-min Acc. Dis (um)", k);
				test_a_dis2 = d2s(test_a_dis1, 0);	
				if (test_a_dis2 == "NaN") {} else {a_dis = Array.concat(a_dis, test_a_dis1);}
		
				test_a_speed1 = getResult(window+"-min Acc. Speed (um/min)", k);
				test_a_speed2 = d2s(test_a_speed1, 0);
				if (test_a_speed2 == "NaN") {} else { a_speed = Array.concat(a_speed, test_a_speed1);}
		
				//pers1 = getResult(window+"-min Pers", k);
				//pers2 = d2s(pers1, 0);
				//if (pers2 == "NaN") {} else {pers = Array.concat(pers, pers1);}	
		
			//	pxd1 = getResult("P/D", k);
			//	pxd2 = d2s(pxd1, 0);
			//	if (pxd2 == "NaN") {} else {pxd = Array.concat(pxd, pxd1);}		
				}
			}
			//calculate persistece from e_dis and a_speed

			for (b=0; b<e_distance.length; b++) {
			 	pers1 = e_distance[b]/a_dis[b];
			 	pers2 = d2s(pers1, 0);
			 	if (pers2 == "NaN") {
			 		pers1 = 0;
			 		pers = Array.concat(pers, pers1);
			 	} 
			 	else {pers = Array.concat(pers, pers1);}
			}
			
			class = classes[z];
			time_entry = (entry_time[j]);
			nTracks = e_angle.length;
			Array.getStatistics(e_angle, min, max, mean, stdDev);
			mean_angle = mean;
			se_angle = (stdDev)/sqrt(e_angle.length);
			Array.getStatistics(e_distance, min, max, mean, stdDev);
			mean_e_dis = mean;
			se_e_dis = (stdDev)/sqrt(e_distance.length);
			Array.getStatistics(e_speed, min, max, mean, stdDev);
			mean_e_speed = mean;
			se_e_speed = (stdDev)/sqrt(e_speed.length);
			Array.getStatistics(a_dis, min, max, mean, stdDev);
			mean_a_dis = mean;
			se_a_dis = (stdDev)/sqrt(a_dis.length);
			Array.getStatistics(a_speed, min, max, mean, stdDev);
			mean_a_speed = mean;
			se_a_speed = (stdDev)/sqrt(a_speed.length);
			Array.getStatistics(pers, min, max, mean, stdDev);
			mean_pers = mean;
			se_pers = (stdDev)/sqrt(pers.length);
			Array.getStatistics(pxd, min, max, mean, stdDev);
			mean_pxd = mean;
			se_pxd = (stdDev)/sqrt(pxd.length);

			//print raw data to log for stats
			//print("Class", "Entry_Time", "E_Angle", "E_Dis", "E_Speed", "A_Dis", "A_Speed", "Pers");
			
			for (t=0; t<(e_angle.length); t++) {
				
				print(class+","+time_entry+","+e_angle[t]+","+e_distance[t]+","+e_speed[t]+","+a_dis[t]+","+a_speed[t]+","+pers[t]);
			}
			
			print(f, class+"\t"+time_entry+"\t"+nTracks+"\t"+mean_angle+"\t"+se_angle+"\t"+mean_e_dis+"\t"+se_e_dis+"\t"+mean_e_speed+"\t"+se_e_speed+"\t"+mean_a_dis+"\t"+se_a_dis+"\t"+mean_a_speed+"\t"+se_a_speed+"\t"+mean_pers+"\t"+se_pers);//+"\t"+mean_pxd+"\t"+se_pxd); 							//to summary table

			}

		}

}

//Icons used courtesy of: http://www.famfamfam.com/lab/icons/silk/
//Richard Mort 14/04/2016