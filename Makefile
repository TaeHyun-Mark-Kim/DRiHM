# "make test" Compiles everything and runs the regression tests

.PHONY : test
test : all testall.sh
	./testall.sh

# "make all" builds the executable as well as the "printbig" library designed
# to test linking external code

.PHONY : all
all : drihm.native matrix.o
# all : drihm.native printbig.o matrix.o

# "make drihm.native" compiles the compiler
#
# The _tags file controls the operation of ocamlbuild, e.g., by including
# packages, enabling warnings
#
# See https://github.com/ocaml/ocamlbuild/blob/master/manual/manual.adoc

drihm.native : matrix.bc
	opam config exec -- \
	ocamlbuild -use-ocamlfind drihm.native -pkgs llvm,llvm.analysis,llvm.bitreader

# "make clean" removes all generated files

.PHONY : clean
clean :
	ocamlbuild -clean
	rm -rf testall.log ocamlllvm *.diff *.ll *.o *.bc *.exe *.out *.s matrix drihm.native

# Testing the "printbig" example

# printbig : printbig.c
# 	cc -o printbig -DBUILD_TEST printbig.c

matrix : matrix.c
	cc -o matrix -DBUILD_TEST matrix.c -lm

matrix.bc :matrix.c
	clang -emit-llvm -o matrix.bc -c matrix.c -Wno-varargs

.PHONY : demo
demo: 
	./drihm.native tests/demo.dm > demo.ll
	/usr/bin/llc -relocation-model=pic demo.ll > demo.s
	cc -o demo.exe demo.s matrix.o -lm
	./demo.exe

# Building the tarball

TESTS = \
	demo add2 char-add char demo2 float func1 if1 int-assign2 int-assign \
	matrix1 matrix-add1 matrix-add2 matrix-add3 matrix-add4 matrix-arith1 matrix-assign \
	matrix-det1 matrix-det2 matrix-float2 matrix-float3 matrix-float4 matrix-float \
	matrix-for-loop1 matrix-index1 matrix-index2 matrix-mul1 matrix-sub1 matrix-transpose1 \
	matrix-transpose2 string1 string2 string-assign2 string-assign3 string-assign
  # ops2 printbig var1 var2 while1 while2

# FAILS = \
#   assign1 assign2 assign3 dead1 dead2 expr1 expr2 expr3 float1 float2 \
#   for1 for2 for3 for4 for5 func1 func2 func3 func4 func5 func6 func7 \
#   func8 func9 global1 global2 if1 if2 if3 nomain print \
# 	# func8 func9 global1 global2 if1 if2 if3 nomain printbig printb print \
#   return1 return2 while1 while2

TESTFILES = $(TESTS:%=test-%.dm) $(TESTS:%=test-%.out) \	    

TARFILES = ast.ml sast.ml codegen.ml Makefile _tags drihm.ml Parser.mly \
	README scanner.mll semant.ml testall.sh \
	arcade-font.pbm font2c \
	# Dockerfile \
	$(TESTFILES:%=tests/%)
	# printbig.c arcade-font.pbm font2c \
	# Dockerfile \
	# $(TESTFILES:%=tests/%)

drihm.tar.gz : $(TARFILES)
	cd .. && tar czf DRiHM/drihm.tar.gz \
		$(TARFILES:%=DRiHM/%)
