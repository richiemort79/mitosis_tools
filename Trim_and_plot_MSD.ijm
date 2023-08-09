//Use this code to trim a results table to either daughter or mothers and to a range of entries in the track
//It then plots the MSD using time ensemble averaging for the trimmed data

//calibration
timestep = 10; //time in minutes between frames
cal = 0.619; //um per pixel

//choose filter - mother = 1, daughter = 0.
filter = 0;

if (filter == 0) {
	filter_name = "Daughters";
}
	else {
		filter_name = "Mothers";
	}

//which column heading to use as the track index?
track_index = "Track_Index";
//track_index = "Track_Index_Rev"; //for mothers

if (track_index == "Track_Index" ) {
	index_name = "Forwards";
	direction = "+";
}
	else {
		index_name = "Reverse";
		direction = "-";
	}

//choose the range of the entries to use for trimming e.g. 0-18 for upto 180 mins
min_index = 0;
max_index = 18;

//close the log
if (isOpen("Log")) {
	selectWindow("Log");
	run("Close");
}

//save the log open as results as results and do an msd plot
dir = getDir("temp");

//make a title form the parameters
title_plot = "MSD Plot for "+filter_name+" "+index_name+" from "+direction+(min_index*timestep)+" to "+direction+(max_index*timestep);

//save original results table to temp
selectWindow("Results");
saveAs("Text", dir+"Original_Results.csv");

//how many columns in the results table
headings = split(String.getResultsHeadings);

//Print the header
header = "";

for (head=0; head<headings.length; head++) {
  		header = header + headings[head]+",";
  	}
print(header);

//loop through the results table filter each line, write to log and save
for (row=0; row<nResults(); row++){
	line = "";	
	//print(row);
	if (getResult("Seed", row) == filter && getResult(track_index, row) <= max_index && getResult(track_index, row) >= min_index) { 
		
	index = getResult(track_index, row);	
  	//print(index+" Hit");
  	
  	for (column=0; column<headings.length; column++) {
  		line = line + getResultString(headings[column], row) + ",";
  	}
  	print(line);
	}
}

selectWindow("Log");
saveAs("Text", dir+"Results.csv");
run("Close");

selectWindow("Results");
run("Close");

open(dir+"Results.csv");

//get the track numbers in an array to use as the index
track_number = list_no_repeats ("Results", "Track");

//get number of tracks (nTracks)
nTracks = track_number.length;

//Index the tracks numerically will be the same as "Track" if strings are not used
index = 1;

for (l=0; l<nResults; l++) {
	if (l==0) {
		setResult("Index", l, index);
	}
	else if (getResultString("Track", l) == getResultString("Track",l-1)) {
		setResult("Index", l, index);
	}
	else if (getResult("Track", l) != getResult("Track",l-1)) {
		index = index+1;
		setResult("Index", l, index);
	}
}

//Workout the window size from the track lengths and write lengths to table
lengths = get_track_lengths();
Array.getStatistics(lengths, min, max, mean, stdDev);

//The window sizes for analysis range from 1 to max-1
//Calculate squared dispalcement from tracking data for all possible window sizes 

MSD = newArray("0");
time = newArray("0");
divide = 0;
r_total = 0;
distance = 0;

//Iterate through the different window sizes from 1 to maxslice
for (u=1; u<max; u++) {

//For each window iterate through the results table
	for (i=0; i<nResults(); i++){

//If the frame number is less than or equal to the window size
		if (getResult("Step", i) <= u) {}
	
		else { if (getResult("Index", i)>getResult("Index", i-u)) {}
	
		else { if (getResult("T_Length", i)>=u && getResult("Index", i-u)==getResult("Index", i)) {
			x = getResult("X", i);
			x1 = getResult("X", i-u);
			y = getResult("Y", i);
			y1 = getResult("Y", i-u);
			distance = get_pythagoras(x, y, x1, y1, cal);
			r_total = r_total+(distance*distance);	
			divide++;
			}	
		}
	}
}

time = Array.concat(time, u * timestep);	
MSD = Array.concat(MSD, (r_total)/divide);
r_total=0;
divide=0;
}

print(title_plot);
Array.print(time);
Array.print(MSD);

Fit.doFit("Straight Line", time, MSD);
intercept = d2s(Fit.p(0),6);
slope = d2s(Fit.p(1),6);
r2 = d2s(Fit.rSquared,3);

print("slope = "+slope);
print("intercept = "+intercept);
print("R^2 = "+r2);
print("D = "+parseFloat(slope)/4);

//Create Plot
Fit.plot();
Plot.setFrameSize(400, 400);
rename(title_plot);

selectWindow("Results");
run("Close");
open(dir+"Original_Results.csv");
selectWindow("Original_Results.csv");
Table.rename("Original_Results.csv", "Results");

function list_no_repeats (table, heading) {
//Returns an array of the entries in a column without repeats to use as an index

//Check whether the table exists
	if (isOpen(table)) {

//get the entries in the column without repeats
		no_repeats = newArray(getResultString(heading, 0));

		for (i=0; i<nResults; i++) {
			occurence = getResultString(heading, i);
			for (j=0; j<no_repeats.length; j++) {
				if (occurence != no_repeats[j]) {
					flag = 0;
				} else {
						flag = 1;
					}
				}
			
			if (flag == 0) {
				occurence = getResultString(heading, i);
				no_repeats = Array.concat(no_repeats, occurence);	
			}
		}
	} else {
		Dialog.createNonBlocking("Error");
		Dialog.addMessage("No table with the title "+table+" found.");
		Dialog.show();
	}
	return no_repeats;
}


function get_pythagoras(x, y, x1, y1, scale) {
//get the distance between x,y and x1,y1 in the usual way use scale to convert to real world units
	x2 = x - x1;
	y2 = y - y1;
    distance = (sqrt((x2*x2)+(y2*y2)))*scale;
	return distance;
}

function get_track_lengths() {
//get the track lengths in an and array write them to the table
	track_number = list_no_repeats ("Results", "Track");

//get track lengths in array and write to results
	track_lengths = newArray();
	for (a=0; a<track_number.length; a++){
		t_le = 0;
		for (i=0; i<nResults; i++) {
			if (getResultString("Track",i) == toString(track_number[a])) {
				t_le = t_le +1;
			}
		}
		track_lengths = Array.concat(track_lengths, t_le);
	}
		
		for (a=0; a<track_number.length; a++){
			frame=0;
		for (i=0; i<nResults; i++) {
			if (getResultString("Track",i) == toString(track_number[a])) {
				frame=frame+1;
				setResult("T_Length", i, track_lengths[a]);
				setResult("Step", i, frame);
			}
		}
	}

	return track_lengths;
}
