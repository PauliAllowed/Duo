goal:   duo

tarball:
	tar cfz duo$(PLAT).tar.gz makefile *.f90
        
checkin:
	ci -l Makefile *.f90

#FPATH = 

EXE = j-duo_custom.x

FOR = gfortran   # Fortran compiler switched to gfortran

# Optimization and OpenMP flags for gfortran
FFLAGS = -O3 -fopenmp -std=gnu -ffree-line-length-none -w

# Alternative debugging flags for gfortran (uncomment if needed):
##FFLAGS = -W -Wall -fbounds-check -pedantic-errors -std=f2003 -Wunderflow -O0 -fbacktrace -g -Wextra

# Standard Linux BLAS and LAPACK libraries both within openblas (requires liblapack-dev and libblas-dev)
LAPACK = -lopenblas
# run module load openblas to ensure both are loaded

LIB = $(LAPACK) -fopenmp

###############################################################################

OBJ = F1_hyperfine.o F1_intensity.o grids.o accuracy.o lapack.o timer.o input.o diatom.o refinement.o functions.o  symmetry.o intensity_filters.o magnetic_dipole.o quadrupole.o dipole.o header_info.o atomic_and_nuclear_data.o  Lobatto.o me_numer.o RWF.o intensity.o

diatom.o: symmetry.o functions.o input.o lapack.o Lobatto.o timer.o atomic_and_nuclear_data.o accuracy.o me_numer.o
intensity_filters.o: accuracy.o diatom.o
magnetic_dipole.o: accuracy.o diatom.o
dipole.o: timer.o accuracy.o diatom.o symmetry.o magnetic_dipole.o quadrupole.o intensity_filters.o
quadrupole.o: timer.o accuracy.o diatom.o
intensity.o: accuracy.o diatom.o dipole.o
duo.o: header_info.o diatom.o accuracy.o refinement.o timer.o intensity.o F1_hyperfine.o F1_intensity.o
functions.o: accuracy.o timer.o lapack.o
grids.o: accuracy.o Lobatto.o
header_info.o: accuracy.o
F1_hyperfine.o: accuracy.o diatom.o lapack.o symmetry.o
F1_intensity.o: F1_hyperfine.o accuracy.o diatom.o
me_numer.o : accuracy.o lapack.o timer.o
lapack.o: accuracy.o timer.o
Lobatto.o: accuracy.o timer.o
refinement.o: timer.o accuracy.o diatom.o
symmetry.o: accuracy.o
timer.o: accuracy.o
RWF.o: accuracy.o diatom.o timer.o symmetry.o lapack.o

# clear internal suffix rules
.SUFFIXES:
# specify our own suffix rules
.SUFFIXES: .f90 .o
.f90.o:
	$(FOR) -c -o $@ $< $(FFLAGS)

duo:	$(OBJ) duo.o
	$(FOR) -o $(EXE) $(OBJ) duo.o $(LIB) $(FFLAGS)

clean:
	rm -f $(OBJ) *.mod *__genmod.f90 duo.o duo_test_0* eigen_vectors.chk eigen_vib.chk Bob-Rot_centrifugal_functions.dat  _Lp__functions.dat       Spin-Orbit.dat               Spin-spin_functions.dat Dipole_moment_functions.dat        Potential_functions.dat  Spin-rotation_functions.dat Spin-spin-o__non-diagonal__functions.dat

test:  test_duo.f90
	$(FOR) -O0 test_duo.f90 -o duo_test.exe
