/*
 * NavierStokes.hpp
 *
 *  Created on: Dec 29, 2012
 *      Author: ataias
 */

#ifndef NAVIERSTOKES_HPP_
#define NAVIERSTOKES_HPP_

#include<stdheader.hpp>
#include <boost/python/detail/wrap_python.hpp>
#include <boost/python.hpp>
#include <numpy/arrayobject.h>
#include <boost/python/module.hpp>
#include <boost/python/detail/api_placeholder.hpp>
#include <boost/python/def.hpp>
using namespace boost::python;

/**This part stands for the sum of velocities in the X axis.
 * @f[\textbf{v}^s=(u^s, v^s) @f]
 * The 's' stands for 'sum'
 * @f[ u_{ij}^s=u_{i+1j}+u_{i-1j}+u_{ij+1}+u_{ij-1}@f]
 * */
#ifndef VELOCITY_X_SUM
#define VELOCITY_X_SUM m_dVelocityX(i+1,j)+m_dVelocityX(i-1,j)\
				       +m_dVelocityX(i,j+1)+m_dVelocityX(i,j-1)
#endif /* VELOCITY_X_SUM */

/**This part stands for the sum of velocities in the Y axis.
 * @f[\textbf{v}^s=(u^s, v^s) @f]
 * The 's' stands for 'sum'
 * @f[ v_{ij}^s=v_{i+1j}+v_{i-1j}+v_{ij+1}+v_{ij-1}@f]
 * */
#ifndef VELOCITY_Y_SUM
#define VELOCITY_Y_SUM	m_dVelocityY(i+1,j)+m_dVelocityY(i-1,j)\
				        +m_dVelocityY(i,j+1)+m_dVelocityY(i,j-1)
#endif /* VELOCITY_Y_SUM */

/**This part stands for the average of velocities in the X axis.
 * @f[\textbf{v}^t=(u^t, v^t) @f]
 * The 't' stands for nothing special
 * @f[ u_{ij}^t=\frac{1}{4}(u_{ij}+u_{i-1j}+u_{i-1j-1}+u_{ij+1})@f]
 * */
#ifndef VELOCITY_X_AVERAGE
#define VELOCITY_X_AVERAGE 0.25*(m_dVelocityX(i,j)+m_dVelocityX(i-1,j)\
				           +m_dVelocityX(i,j+1)+m_dVelocityX(i-1,j-1))
#endif /* VELOCITY_X_AVERAGE */

/**This part stands for the average of velocities in the X axis.
 * @f[\textbf{v}^t=(u^t, v^t) @f]
 * The 't' stands for nothing special
 * @f[ v_{ij}^t=\frac{1}{4}(v_{ij}+v_{i-1j}+v_{i-1j-1}+v_{ij+1})@f]
 * */
#ifndef VELOCITY_Y_AVERAGE
#define VELOCITY_Y_AVERAGE 0.25*(m_dVelocityY(i,j)+m_dVelocityY(i-1,j)\
				           +m_dVelocityY(i,j+1)+m_dVelocityY(i-1,j-1))
#endif /* VELOCITY_Y_AVERAGE */

/** This part stand for the velocity obtained by Navier Stokes equation without considering the pressure
 * @f[u_{ij}^{*}=\left[\frac{\mu}{\rho}\left(\frac{u_{ij}^s-4u_{ij}}{\Delta x^2}\right)+\frac{f_{x,ij}}{\rho}-
 u_{ij}\frac{u_{i+1j}-u_{i-1j}}{2\Delta x}-v_{ij}^t\frac{u_{ij+1}-u_{ij-1}}{2\Delta x}\right]\Delta t + u_{ij}@f]
 * */
#ifndef VELOCITY_X_NO_PRESSURE
#define VELOCITY_X_NO_PRESSURE (m_dNu*(dVelocityXSum-4*m_dVelocityX(i,j))/m_dDeltaX2+m_dExternalForceX(i,j)/m_dRho\
					 -m_dVelocityX(i,j)*(m_dVelocityX(i+1,j)-m_dVelocityX(i-1,j))/(2*m_dDeltaX)\
					 -dVelocityYAverage*(m_dVelocityX(i,j+1)-m_dVelocityX(i,j-1))/(2*m_dDeltaX))*m_dDeltaT\
				     +m_dVelocityX(i,j)
#endif /* VELOCITY_X_NO_PRESSURE */

/** This part stand for the velocity obtained by Navier Stokes equation without considering the pressure
 * @f[v_{ij}^{*}=\left[\frac{\mu}{\rho}\left(\frac{v_{ij}^s-4v_{ij}}{\Delta x^2}\right)+
\frac{f_{y,ij}}{\rho}-u_{ij}^t\frac{v_{i+1j}-v_{i-1j}}{2\Delta x}-v_{ij}\frac{v_{ij+1}-v_{ij-1}}{2\Delta x}\right]\Delta t + v_{ij}@f]
 * */
#ifndef VELOCITY_Y_NO_PRESSURE
#define VELOCITY_Y_NO_PRESSURE (m_dNu*(dVelocityYSum-4*m_dVelocityY(i,j))/m_dDeltaX2+m_dExternalForceY(i,j)/m_dRho\
					 -dVelocityXAverage*(m_dVelocityY(i+1,j)-m_dVelocityY(i-1,j))/(2*m_dDeltaX)\
					 -m_dVelocityY(i,j)*(m_dVelocityY(i,j+1)-m_dVelocityY(i,j-1))/(2*m_dDeltaX))*m_dDeltaT\
				     +m_dVelocityY(i,j)
#endif /* VELOCITY_Y_NO_PRESSURE */

#ifndef NON_HOMOGENEITY_NAVIER
#define NON_HOMOGENEITY_NAVIER m_dRho*(\
								(m_dVelocityXNoPressure(i+1,j)-m_dVelocityXNoPressure(i-1,j))/(2*m_dDeltaX)\
								-(m_dVelocityXNoPressure(i+1,j)-m_dVelocityXNoPressure(i-1,j))/(2*m_dDeltaX)\
								)/m_dDeltaT
#endif /*NON_HOMOGENEITY_NAVIER*/

class NavierStokes {
private:

	Eigen::MatrixXd m_dVelocityX;
	Eigen::MatrixXd m_dVelocityY;

	Eigen::MatrixXd m_dVelocityXNoPressure; 	/*term of velocity* in x axis*/
	Eigen::MatrixXd m_dVelocityYNoPressure; 	/*term of velocity* in y axis*/
	/*f = (fx, fy)*/
	Eigen::MatrixXd m_dExternalForceX;
	Eigen::MatrixXd m_dExternalForceY;

	Eigen::MatrixXd m_dVelocityXBoundaryCondition;
	Eigen::MatrixXd m_dVelocityYBoundaryCondition;

	Eigen::MatrixXd m_dNavierStokesSolutionX;
	Eigen::MatrixXd m_dNavierStokesSolutionY;

	int m_nMatrixOrder;

	int m_nTime;
	double m_dDeltaX;
	double m_dDeltaX2;
	double m_dDeltaT;

	/*nu = mi/rho = kinematic viscosity*/
	double m_dMi; /*mi-> dynamic viscosity coefficient*/
	double m_dRho; /*rho-> fluid density*/

	void VelocityNoPressure();
	void PressureSolver();
	void NextStep();

public:
	void NavierStokesSolver();
	int NavierStokesPython(
			PyObject* dVelocityXBoundaryCondition,
			PyObject* dVelocityYBoundaryCondition,
			PyObject* dExternalForceX,
			PyObject* dExternalForceY,
			double dMi, double dRho,
			const int nMatrixOrder,
			const double dDeltaT
			);

	template<typename Derived>
	int NavierStokesInit(
					const Eigen::MatrixBase<Derived>& dVelocityXBoundaryCondition_,
			 	 	const Eigen::MatrixBase<Derived>& dVelocityYBoundaryCondition_,
			 	 	const Eigen::MatrixBase<Derived>& dExternalForceX_,
			 	 	const Eigen::MatrixBase<Derived>& dExternalForceY_,
			 	 	double dMi, double dRho, double dDeltaT
			 	 	);
//	virtual ~NavierStokes();

	void move(PyObject* pyArraySolutionX, PyObject* pyArraySolutionY); //function to move to python variable

};

#endif /* NAVIERSTOKES_HPP_ */
