/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: $  $Date: $  */

/***********************************************************************
 Defuzzification methods
 **********************************************************************/

/* return the center of area of combined output MF (specified by mf)
   of output m */
/* numofpoints is the number of partition for integration */
static DOUBLE defuzzCentroid(FIS *fis, int m, DOUBLE *mf, int numofpoints)
{
	DOUBLE min = fis->output[m]->bound[0];
	DOUBLE max = fis->output[m]->bound[1];
	DOUBLE step = (max - min)/(numofpoints - 1);
	DOUBLE total_mf = 0;
	DOUBLE sum = 0;
	int i;

	for (i = 0; i < numofpoints; i++){
		total_mf += mf[i];
       		sum += mf[i]*(min + step*i);
	}
	if (total_mf == 0) {
		PRINTF("Total area is zero in defuzzCentroid() for output %d.\n", m+1);
		PRINTF("Average of the range of this output variable is used as the output value.\n\n");
		return((fis->output[m]->bound[0] + fis->output[m]->bound[1])/2);
	} 
	return(sum/total_mf);
}

/* return the bisector of area of mf */
static DOUBLE defuzzBisector(FIS *fis, int m, DOUBLE *mf, int numofpoints)
{
	DOUBLE min = fis->output[m]->bound[0];
	DOUBLE max = fis->output[m]->bound[1];
	DOUBLE step = (max - min)/(numofpoints - 1); 
	DOUBLE area, sub_area;
	int i;

	/* find the total area */
	area = 0;
	for (i = 0; i < numofpoints; i++)
		area += mf[i];

	if (area == 0) {
		PRINTF("Total area is zero in defuzzBisector() for output %d.\n", m+1);
		PRINTF("Average of the range of this output variable is used as the output value.\n");
		return((fis->output[m]->bound[0] + fis->output[m]->bound[1])/2);
	} 
     
	sub_area = 0;
	for (i = 0; i < numofpoints; i++) {
		sub_area += mf[i];
		if (sub_area >= area/2)
			break;
	}
	return(min + step*i);
}

/* Returns the mean of maximizing x of mf */
static DOUBLE defuzzMeanOfMax(FIS *fis, int m, DOUBLE *mf, int numofpoints)
{
	DOUBLE min = fis->output[m]->bound[0];
	DOUBLE max = fis->output[m]->bound[1];
	DOUBLE step = (max - min)/(numofpoints - 1); 
	DOUBLE mf_max;
	DOUBLE sum;
	int count;
	int i;

	mf_max = fisArrayOperation(mf, numofpoints, fisMax);

	sum = 0;
	count = 0;
	for (i = 0; i < numofpoints; i++)
		if (mf[i] == mf_max) {
			count++;
			sum += i;
		}
	return(min+step*sum/count);
}

/* Returns the smallest (in magnitude) maximizing x of mf */
static DOUBLE defuzzSmallestOfMax(FIS *fis, int m, DOUBLE *mf, int numofpoints)
{
	DOUBLE min = fis->output[m]->bound[0];
	DOUBLE max = fis->output[m]->bound[1];
	DOUBLE step = (max - min)/(numofpoints - 1); 
	DOUBLE mf_max;
	int i, min_index = 0;
	DOUBLE min_distance = pow(2.0, 31.0)-1;
	DOUBLE distance; /* distance to the origin */

	mf_max = fisArrayOperation(mf, numofpoints, fisMax);
	for (i = 0; i < numofpoints; i++)
		if (mf[i] == mf_max) {
			distance = ABS(min + step*i);
			if (min_distance > distance) {
				min_distance = distance;
				min_index = i;
			}
		}
	return(min + step*min_index);
}

/* Returns the largest (in magnitude) maximizing x of mf */
static DOUBLE defuzzLargestOfMax(FIS *fis, int m, DOUBLE *mf, int numofpoints)
{
	DOUBLE min = fis->output[m]->bound[0];
	DOUBLE max = fis->output[m]->bound[1];
	DOUBLE step = (max - min)/(numofpoints - 1); 
	DOUBLE mf_max;
	int i, max_index = 0;
	DOUBLE max_distance = -(pow(2.0, 31.0)-1);
	DOUBLE distance; /* distance to the origin */

	mf_max = fisArrayOperation(mf, numofpoints, fisMax);
	for (i = 0; i < numofpoints; i++)
		if (mf[i] == mf_max) {
			distance = ABS(min + step*i);
			if (max_distance < distance) {
				max_distance = distance;
				max_index = i;
			}
		}
	return(min + step*max_index);
}
