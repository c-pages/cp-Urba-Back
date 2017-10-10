	
	
	
	
	
	
		fn intersection 	_pt_orig 	_pt_2 		_pt_seg_1 	_pt_seg_2  		 =(
			local pt_result
			
			local vec_proj		= _pt_orig - _pt_2
			local vec_seg		= _pt_seg_1 - _pt_seg_2
			
			local norm_proj		= normalize vec_proj
			local norm_seg			= normalize vec_seg
			local dot_proj_seg 	= dot norm_proj norm_seg
			
			---- pas verticale ----------				
			
			local a1, b1, a2, b2 
			local d1_vert = false
			local d2_vert = false
			
			--- données pour les eaquations de droite y = ax + b ----
			-- droite projeté----------------------
			if (( _pt_orig.y *1000) as integer /1000  == ( _pt_2.y *1000) as integer /1000) then (
				-- horizontale --
				a1 = 0
				b1 	= _pt_orig.y 
			) else if (( _pt_orig.x *1000) as integer /1000  == ( _pt_2.x *1000) as integer /1000) then (
				-- verticale --s
				a1 	= 1
				b1 	= _pt_orig.y - _pt_orig.x
				d1_vert = true
			) else (
				a1 	= (_pt_orig.y - _pt_2.y ) / (_pt_orig.x - _pt_2.x)
				b1 	= _pt_orig.y - a1*_pt_orig.x
			)		
			-- droite reception
			if _pt_seg_1.y == _pt_seg_2.y then (
				-- horizontale --
				a2 = 0
				b2 	= _pt_seg_1.y 
			) else if _pt_seg_1.x == _pt_seg_2.x then (
				-- verticale --
				a2 	= 1
				b2 	= _pt_seg_1.y - _pt_seg_1.x
				d2_vert = true
			) else (
				a2 	= (_pt_seg_1.y - _pt_seg_2.y ) / (_pt_seg_1.x - _pt_seg_2.x)
				b2 	= _pt_seg_1.y - a2*_pt_seg_1.x
			)
			
			
			
			
			local x, y
			if 	d1_vert then (
				if not d2_vert do (
					x =   _pt_orig.x
					y =   a2 * x + b2
				)
			) else 	if 	d2_vert then (
				if not d1_vert do (
					x =   _pt_seg_1.x
					y =   a1 * x + b1
				)
			) else (
				if a1 != a2 then (
					x =   ( b2 - b1 ) / (a1  - a2 )
					y =   a1 * x + b1
				)
			)
			
			-- si on a un point on verifie la suite -----------------------------
			if x != undefined do (
				local pt_proj  = [x,y,0]
			
				if   dot  ( normalize ( _pt_orig - _pt_2 ) )  (  normalize (   pt_proj - _pt_orig) )   > 0 do (
					
					local dist_seg 	= distance _pt_seg_1 	_pt_seg_2
					local dist_ptProj 	= distance _pt_seg_1 	pt_proj 		+ distance _pt_seg_2 	pt_proj 
					
					if  dist_ptProj  == dist_seg do 
						pt_result = pt_proj
					
				)
				
			)
			
			pt_result
		)
		
		
				---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			
		pt_orig 	= getKnotPoint $Line_proj 1 1 
		pt_2 		= getKnotPoint $Line_proj 1 2
		
		pt_seg_1 = getKnotPoint $Line_test 1 1
		pt_seg_2 = getKnotPoint $Line_test 1 2
		clearlistener ()
		pt_proj = intersection 	pt_orig 		pt_2 		pt_seg_1 	pt_seg_2 		
		if pt_proj != undefined do popo = point pos:pt_proj 
		
		
		