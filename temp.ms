(
traceeTmp 		= $.tracee
matrxAxeTmp 	= $.mtrx_axePrincipal



mtrx_Direction = matrxAxeTmp.rotationpart as matrix3
vec_direction = [0,0,1] * mtrx_Direction

id = 5
vec1 = traceeTmp[id+1] - traceeTmp[id]
vec1_dir = normalize vec1

valTest = abs (dot  vec_direction	vec1_dir ) 
if valTest	 > .75 then 
	#parallele
else if valTest	 < .25 then
	#perpendiculaire
else 	#pasDanslAxe



)
