#include<OwnMath.hpp>

/*
 * Solves Heat Equation by explicit method
 * Boundary conditions are in the file "file.dat"
 */
int main()
{
	/*This programs */
	time_t start;
	clock_t tStart = clock();
	N = 5;

	/*------Time Operations-----*/
	time(&start);
	tStart = clock();

	/*Read matrix with initial and boundary conditions*/
	MatrixATd conditions;
	char file[] = "file2.dat";
	conditions = dnc_U(conditions, file);
	/*------------------------------------------------*/
	MatrixATd *U;
	int N_t = 5000;
	U = SolveHeatEquationE(conditions, 1, N_t, 1, 0.1);
	fileName(file);
	save(file, tStart, &start, U[N_t-1], "u_xx+u_yy=f(x,y)");
        cout << U[0] << endl << endl;
        cout << U[N_t-1] << endl;
<<<<<<< HEAD
    cout << "Hey!\n";
=======
>>>>>>> 31f6b56160b25dcb6dbeb27d4a283eaf3dde5db6
	return(0);
}
