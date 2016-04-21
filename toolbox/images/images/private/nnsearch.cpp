/*
 * NNSEARCH MEX-file
 *
 * [D,IDX] = NNSEARCH(TREE,TREE_POINTS,QUERY_POINTS)
 *
 * Search an optimized k-d tree for nearest neighbors.  TREE is a kd-tree 
 * constructed by KDTREE from TREE_POINTS, which is an N-by-M matrix of M 
 * points in N-space.  (This is transposed from the normal convention for
 * efficient processing in this MEX-file.)  QUERY_POINTS is an N-by-P
 * matrix of P points in N-space.  For each of the P query points, NNSEARCH 
 * determines the closest of the TREE_POINTS points, returns that distance in 
 * the corresponding element of D, and returns the index of the nearest point
 * in the corresponding element of L.  D and IDX are both P-by-1 vectors.
 *
 * Note that MEX-file does no error checking on its inputs.  It is the
 * caller's responsibility to provide correct inputs.
 */

/*
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.1 $  $Date: 2003/01/26 06:00:41 $
 */

static char rcsid[] = "$Id";

#include <math.h>
#include "mex.h"

static double infinity;

static int *stack;
static int stack_top;

#define STACK_PUSH(item)  stack[++stack_top] = item
#define STACK_POP         stack[stack_top--]
#define STACK_IS_EMPTY    (stack_top < 0)
#define REINIT_STACK      (stack_top = -1)

/*
 * point_in_bounds
 * Is a point inside the specified box?
 *
 * Inputs
 * ------
 * point        - vector containing num_dims elements
 * lower_bounds - vector containing num_dims elements
 * upper_bounds - vector containing num_dims elements
 * num_dims     - number of input dimensions
 *
 * Return value
 * ------------
 * boolean - true if point is inside the bounds; false otherwise.
 *           "inside" means location is strictly greater than
 *           lower bounds but less than or equal to the upper bounds.
 */
bool point_in_bounds(double *point, 
                     double *lower_bounds, 
                     double *upper_bounds,
                     int num_dims)
{
    int k;
    bool result = true;
    double point_k;
    
    for (k = 0; k < num_dims; k++)
    {
        point_k = point[k];
        if ((point_k <= lower_bounds[k]) || (point_k > upper_bounds[k]))
        {
            result = false;
            break;
        }
    }
    
    return result;
}

/*
 * ball_within_bounds
 * Is a sphere centered at the specified point with a given radius
 * inside the specified box?
 *
 * Inputs
 * ------
 * point          - vector containing num_dims elements
 * lower_bounds   - vector containing num_dims elements
 * upper_bounds   - vector containing num_dims elements
 * num_dims       - number of input dimensions
 * radius_squared - square of the radius of the sphere
 *
 * Return
 * ------
 * true if sphere is strictly within the bounds of the box;
 * false otherwise.
 */
bool ball_within_bounds(double *point, 
                        double *lower_bounds, 
                        double *upper_bounds,
                        double radius_squared, 
                        int num_dims)
{
    bool result = true;
    double radius;
    double point_k;
    int k;

    radius = sqrt(radius_squared);
    
    for (k = 0; k < num_dims; k++)
    {
        point_k = point[k];
        if (((point_k - radius) <= lower_bounds[k]) ||
            ((point_k + radius) >= upper_bounds[k]))
        {
            result = false;
            break;
        }
    }
    
    return result;
}

/*
 * bounds_overlap_ball
 * Does the specified box overlap a sphere with specified center
 * and radius?
 *
 * Inputs
 * ------
 * point          - vector containing num_dims elements
 * lower_bounds   - vector containing num_dims elements
 * upper_bounds   - vector containing num_dims elements
 * num_dims       - number of input dimensions
 * radius_squared - square of the radius of the sphere
 *
 * Return
 * ------
 * true if box overlaps sphere or touches it tangentially; otherwise false.
 */
bool bounds_overlap_ball(double *point, 
                         double *lower_bounds, 
                         double *upper_bounds,
                         double radius_squared, 
                         int num_dims)
{
    double sum = 0.0;
    bool result = true;
    double point_k;
    double lower_k;
    double upper_k;
    int k;

    for (k = 0; k < num_dims; k++)
    {
        point_k = point[k];
        lower_k = lower_bounds[k];
        upper_k = upper_bounds[k];
        if (point_k < lower_k)
        {
            /* Lower than low boundary */
            sum += (point_k - lower_k) * (point_k - lower_k);
            if (sum > radius_squared)
            {
                result = false;
                break;
            }
        }
        else if (point_k > upper_k)
        {
            /* Higher than high boundary */
            sum += (point_k - upper_k) * (point_k - upper_k);
            if (sum > radius_squared)
            {
                result = false;
                break;
            }
        }
    }
    
    return result;
}

/*
 * find_closest_neighbor_in_node
 * For a given query point, find its closest neighbor among the points
 * in the specified k-d tree node.
 *
 * Inputs
 * ------
 * points           - array of all the points contained in the k-d tree.
 * query_point      - vector containing the query point location.
 * node_idx         - indices of points belonging to the specified node.
 * num_total_points - how many points are in the k-d tree.
 * num_node_points  - how many points are in the specified node.
 * num_dims         - dimensionality of the points.
 * 
 * Outputs
 * -------
 * closest_point_dist - distance between the query point and its
 *                      closest node neighbor.
 * closest_point_idx  - index (into the all-points array) of the closest
 *                      node neighbor.
 */
void find_closest_neighbor_in_node(double *points,
                                   double *query_point,
                                   int *node_idx,
                                   int num_total_points,
                                   int num_node_points,
                                   int num_dims,
                                   int *closest_point_idx,
                                   double *closest_point_dist)
{
    double sum;
    double *point;
    double diff;
    int k;
    int d;
    
    *closest_point_dist = infinity;
    *closest_point_idx = -1;
    
    for (k = 0; k < num_node_points; k++)
    {
        sum = 0.0;
        /*
         * Make point be a pointer to the node_id[k]-th point
         * in the array of all k-d tree points.
         */
        point = points + node_idx[k] * num_dims;
        for (d = 0; d < num_dims; d++)
        {
            diff = point[d] - query_point[d];
            sum += diff * diff;
        }
        if (sum < *closest_point_dist)
        {
            *closest_point_idx = node_idx[k];
            *closest_point_dist = sum;
        }
    }
    
}

/*
 * find_insert_node
 * Which box in the k-d tree contains the specified point?
 *
 * Inputs
 * ------
 * point               - query point vector
 * num_dims            - dimensionality of the points
 * num_nodes           - number of nodes in the k-d tree
 * first_terminal_node - first terminal (leaf) node in the k-d tree
 * dimension           - vector of length num_nodes containing
 *                       the split dimensions for each tree node.
 * partition           - vector of length num_nodes containing
 *                       the split location for each tree node.
 *
 * Return
 * ------
 * index of the tree node containing the specified point.
 */
int find_insert_node(double *point, int num_dims,
                     int num_nodes, int first_terminal_node,
                     int *dimension,
                     double *partition)
{
    int node = 0;
    
    while (node < first_terminal_node)
    {
        if (point[dimension[node]] <= partition[node])
        {
            node = 2*node + 1;
        }
        else
        {
            node = 2*node + 2;
        }
    }
    
    return(node);
}

/*
 * search_kdtree
 * Search k-d tree for the nearest neighbor to a given query point.
 *
 * Inputs
 * ------
 * points              - array of all the points in the k-d tree
 * num_points          - number of points in the k-d tree
 * num_dims            - dimensionality of the points
 * num_nodes           - number of nodes in the k-d tree
 * first_terminal_node - first terminal (leaf) node in the k-d tree
 * query_point         - query point vector
 * start_node          - suggested node to look in first; pass in
 *                       a negative number to start from scratch.
 * lower_bounds        - array of lower bounds vectors for each
 *                       tree node
 * upper_bounds        - array of upper bounds vectors for each
 *                       tree node
 * node_idx            - array of node index vectors for each tree node
 * num_points_in_node  - array containing the number of points in each
 *                       tree node
 * dimension           - array containing the split dimension for each
 *                       tree node
 * partition           - array containing the split location for each
 *                       tree node
 * 
 * Outputs
 * -------
 * closest_point_dist  - distance to the closest point found in the tree
 * closest_point_idx   - index of the closest point found
 * found_node          - index of the node in which the closest point was found
 */
void search_kdtree(double *points,
                   int num_points,
                   int num_dims,
                   int num_nodes,
                   int first_terminal_node,
                   double *query_point,
                   int start_node,
                   double **lower_bounds,
                   double **upper_bounds,
                   int **node_idx,
                   int *num_points_in_node,
                   int *dimension,
                   double *partition,
                   int *closest_point_idx,
                   double *closest_point_dist,
                   int *found_node)
{
    int root_node = 0;
    int search_node;
    int left_child;
    int right_child;
    int tmp_closest_point_idx;
    double tmp_closest_point_dist;

    REINIT_STACK;
    *found_node = start_node;

    if (start_node < 0)
    {
        /*
         * Caller didn't provide a suggestion for the insert node,
         * so find it from scratch.
         */
        start_node = find_insert_node(query_point, num_dims,
                                      num_nodes, first_terminal_node,
                                      dimension, partition);
        *found_node = start_node;
    }
    else
    {
        /*
         * Caller provided a suggestion for the insert node; make
         * sure the point is actually inside the suggested node.
         */
        if (! point_in_bounds(query_point, 
                              lower_bounds[start_node],
                              upper_bounds[start_node],
                              num_dims))
        {
            /*
             * The point was not in the suggested node, so find
             * the node from scratch.
             */
            start_node = find_insert_node(query_point, num_dims,
                                          num_nodes, first_terminal_node,
                                          dimension, partition);
            *found_node = start_node;
        }
    }
    
    find_closest_neighbor_in_node(points, query_point, node_idx[start_node], 
                                  num_points, num_points_in_node[start_node],
                                  num_dims, closest_point_idx, 
                                  closest_point_dist);
    
    if (ball_within_bounds(query_point,
                           lower_bounds[start_node],
                           upper_bounds[start_node],
                           *closest_point_dist,
                           num_dims))
    {
        /*
         * We've determined that no point in any other node
         * can be closer than the one we found in this node,
         * so we're done.
         */
        return;
    }

    /*
     * Push the root node on the stack.
     */
    STACK_PUSH(0);

    while (! STACK_IS_EMPTY)
    {
        search_node = STACK_POP;
        if (search_node < first_terminal_node)
        {
            /*
             * Search node is a nonterminal node.  Push its
             * children onto the search stack if their boxes
             * overlap the current search ball.
             */
            left_child = search_node * 2 + 1;
            if (bounds_overlap_ball(query_point,
                                    lower_bounds[left_child],
                                    upper_bounds[left_child],
                                    *closest_point_dist,
                                    num_dims))
            {
                STACK_PUSH(left_child);
            }
            
            right_child = left_child + 1;
            if (bounds_overlap_ball(query_point,
                                    lower_bounds[right_child],
                                    upper_bounds[right_child],
                                    *closest_point_dist,
                                    num_dims))
            {
                STACK_PUSH(right_child);
            }
        }
        else if (search_node != start_node)
        {
            /*
             * Search node is a terminal node that we haven't already
             * searched.  Find the closest point in it and see if it 
             * is closest than the currently recorded closest point.
             */
            find_closest_neighbor_in_node(points,
                                          query_point,
                                          node_idx[search_node],
                                          num_points,
                                          num_points_in_node[search_node],
                                          num_dims,
                                          &tmp_closest_point_idx,
                                          &tmp_closest_point_dist);
            
            if (tmp_closest_point_dist < *closest_point_dist)
            {
                *closest_point_idx = tmp_closest_point_idx;
                *closest_point_dist = tmp_closest_point_dist;
                *found_node = search_node;
                if (ball_within_bounds(query_point, lower_bounds[search_node], 
                                       upper_bounds[search_node],
                                       *closest_point_dist, num_dims))
                {
                    return;
                }
            }
        }
        else
        {
            /*
             * Search node is the start node, which we have already
             * searched.  Nothing to do here.
             */
        }
    }

}

extern "C"
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const mxArray *tree_array;
    const mxArray *tree_points_array;
    const mxArray *query_points_array;
    mxArray *dist_array;
    mxArray *idx_array;
    mxArray *tmp_array;
    double *points;
    double *query_points;
    double *dist_pr;
    double *idx_pr;
    double **lower_bounds;
    double **upper_bounds;
    int **node_idx;
    int *num_points_in_node;
    int *dimension;
    double *partition;
    double *pr;
    int num_points;
    int num_query_points;
    int num_dims;
    int start_node;
    int found_node;
    int num_nodes;
    int first_terminal_node;
    int k;
    int p;
    int closest_idx;
    double closest_dist;

    infinity = mxGetInf();

    /*
     * No error checking!  This is a private function callable only
     * by IPT functions.
     */
    tree_array = prhs[0];
    tree_points_array = prhs[1];
    query_points_array = prhs[2];
    points = (double *) mxGetData(tree_points_array);
    query_points = (double *) mxGetData(query_points_array);

    /*
     * Figure out the size and dimensionality of the problem.
     */
    num_points = mxGetN(tree_points_array);
    num_query_points = mxGetN(query_points_array);
    num_dims = mxGetM(tree_points_array);
    num_nodes = mxGetNumberOfElements(tree_array);
    first_terminal_node = (num_nodes + 1) / 2 - 1;

    /*
     * Allocate output arrays.
     */
    dist_array = mxCreateDoubleMatrix(num_query_points,1,mxREAL);
    idx_array = mxCreateDoubleMatrix(num_query_points,1,mxREAL);
    plhs[0] = dist_array;
    if (nlhs > 1)
    {
        plhs[1] = idx_array;
    }

    /*
     * If there are no query points we are done.
     */
    if (num_query_points == 0)
    {
        if (nlhs < 2)
        {
            mxDestroyArray(idx_array);
        }
        return;
    }

    dist_pr = (double *) mxGetData(dist_array);
    idx_pr = (double *) mxGetData(idx_array);

    /*
     * If there are no points in the tree, then
     * all distances should be infinity and indices should be zero.
     */
    if (num_points == 0)
    {
        for (k = 0; k < num_query_points; k++)
        {
            dist_pr[k] = infinity;
        }
        if (nlhs < 2)
        {
            mxDestroyArray(idx_array);
        }
        return;
    }
    
    /* 
     * Allocate and fill in arrays that represent k-d tree information.
     */
    lower_bounds = (double **) mxCalloc(num_nodes, sizeof(*lower_bounds));
    upper_bounds = (double **) mxCalloc(num_nodes, sizeof(*upper_bounds));
    node_idx = (int **) mxCalloc(num_nodes, sizeof(*node_idx));
    num_points_in_node = (int *) mxCalloc(num_nodes, 
                                          sizeof(*num_points_in_node));
    dimension = (int *) mxCalloc(num_nodes, sizeof(*dimension));
    partition = (double *) mxCalloc(num_nodes, sizeof(*partition));
    for (k = 0; k < num_nodes; k++)
    {
        lower_bounds[k] = (double *) mxGetData(mxGetField(tree_array, k, 
                                                          "lower_bounds"));
        upper_bounds[k] = (double *) mxGetData(mxGetField(tree_array, k, 
                                                          "upper_bounds"));
        num_points_in_node[k] = mxGetNumberOfElements(mxGetField(tree_array, 
                                                                 k, "idx"));
        node_idx[k] = (int *) mxCalloc(num_points_in_node[k], sizeof(int));
        pr = (double *) mxGetData(mxGetField(tree_array, k, "idx"));
        for (p = 0; p < num_points_in_node[k]; p++)
        {
            node_idx[k][p] = (int) pr[p] - 1;
        }
        tmp_array = mxGetField(tree_array, k, "dimension");
        if (! mxIsEmpty(tmp_array))
        {
            dimension[k] = (int) mxGetScalar(tmp_array) - 1;
        }
        else
        {
            dimension[k] = -1;
        }
        tmp_array = mxGetField(tree_array, k, "partition");
        if (! mxIsEmpty(tmp_array))
        {
            partition[k] = mxGetScalar(tmp_array);
        }
        else
        {
            partition[k] = mxGetNaN();
        }
    }

    /*
     * Allocate and initialize the stack.
     */
    stack = (int *) mxCalloc(num_nodes, sizeof(*stack));
    stack_top = -1;

    /*
     * Initialize the suggested start node to be negative for the
     * first call to search_kdtree.
     */
    start_node = -1;
    for (k = 0; k < num_query_points; k++)
    {
        search_kdtree(points, num_points, num_dims,
                      num_nodes, first_terminal_node,
                      query_points + k*num_dims, start_node,
                      lower_bounds, upper_bounds,
                      node_idx, num_points_in_node, 
                      dimension, partition,
                      &closest_idx, &closest_dist, &found_node);
        dist_pr[k] = closest_dist;
        idx_pr[k] = (double) closest_idx + 1;
        start_node = found_node;
    }

    /*
     * Computation so far has used squared distance, so take square
     * root before returning.
     */
    for (k = 0; k < num_query_points; k++)
    {
        dist_pr[k] = sqrt(dist_pr[k]);
    }

    if (nlhs < 2)
    {
        mxDestroyArray(idx_array);
    }

    /*
     * Free k-d tree arrays.
     */
    mxFree(lower_bounds);
    mxFree(upper_bounds);
    for (k = 0; k < num_nodes; k++)
    {
        mxFree(node_idx[k]);
    }
    mxFree(node_idx);
    mxFree(num_points_in_node);
    mxFree(dimension);
    mxFree(partition);

    /*
     * Free the stack.
     */
    mxFree(stack);
}

    
    


                                          
            
                                    
                  
    
    
